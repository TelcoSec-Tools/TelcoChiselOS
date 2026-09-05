// Package search provides tool catalog and desktop application discovery
// by querying freedesktop .desktop entries and categories.
package search

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
)

// ANSI color constants
const (
	Bold   = "\033[1m"
	Cyan   = "\033[1;36m"
	Green  = "\033[1;32m"
	Yellow = "\033[1;33m"
	Reset  = "\033[0m"
)

// DesktopTool represents an installed telecom or security desktop tool.
type DesktopTool struct {
	Name       string
	Comment    string
	Exec       string
	Categories string
	Keywords   string
	FilePath   string
}

// SearchTools searches .desktop application files for matching keywords or tool names.
func SearchTools(query string, searchDirs []string) ([]DesktopTool, error) {
	if len(searchDirs) == 0 {
		searchDirs = []string{
			"/usr/share/applications",
			"/usr/local/share/applications",
			"/etc/skel/Desktop",
		}
	}

	q := strings.ToLower(strings.TrimSpace(query))
	var matches []DesktopTool
	seen := make(map[string]bool)

	for _, dir := range searchDirs {
		files, err := filepath.Glob(filepath.Join(dir, "*.desktop"))
		if err != nil {
			continue
		}

		for _, f := range files {
			tool, err := ParseDesktopEntry(f)
			if err != nil || tool.Name == "" {
				continue
			}

			// Avoid duplicate tool names from different directories
			if seen[tool.Name] {
				continue
			}

			searchable := strings.ToLower(fmt.Sprintf("%s %s %s %s %s",
				tool.Name, tool.Comment, tool.Exec, tool.Categories, tool.Keywords))

			if strings.Contains(searchable, q) {
				seen[tool.Name] = true
				matches = append(matches, tool)
			}
		}
	}

	return matches, nil
}

// ParseDesktopEntry parses a .desktop file and extracts key metadata fields.
func ParseDesktopEntry(path string) (DesktopTool, error) {
	file, err := os.Open(path)
	if err != nil {
		return DesktopTool{}, err
	}
	defer file.Close()

	tool := DesktopTool{FilePath: path}
	scanner := bufio.NewScanner(file)
	inDesktopEntry := false

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if strings.HasPrefix(line, "[Desktop Entry]") {
			inDesktopEntry = true
			continue
		}
		if strings.HasPrefix(line, "[") && inDesktopEntry {
			// Entered another section
			break
		}
		if !inDesktopEntry || strings.HasPrefix(line, "#") || !strings.Contains(line, "=") {
			continue
		}

		parts := strings.SplitN(line, "=", 2)
		key := strings.TrimSpace(parts[0])
		val := strings.TrimSpace(parts[1])

		switch key {
		case "Name":
			if tool.Name == "" {
				tool.Name = val
			}
		case "Comment":
			if tool.Comment == "" {
				tool.Comment = val
			}
		case "Exec":
			if tool.Exec == "" {
				tool.Exec = val
			}
		case "Categories":
			if tool.Categories == "" {
				tool.Categories = val
			}
		case "Keywords":
			if tool.Keywords == "" {
				tool.Keywords = val
			}
		}
	}

	return tool, scanner.Err()
}

// PrintResults renders the search matches in formatted ANSI output.
func PrintResults(w io.Writer, query string, tools []DesktopTool) {
	fmt.Fprintf(w, "%s=== Searching Tool Catalog for '%s' ===%s\n\n", Bold, query, Reset)

	if len(tools) == 0 {
		fmt.Fprintf(w, "%sNo installed desktop tools matched '%s'.%s\n", Yellow, query, Reset)
		fmt.Fprintf(w, "Tip: Run 'telcosec pkg list' to search downloadable metapackages.\n\n")
		return
	}

	for _, tool := range tools {
		fmt.Fprintf(w, "  %s%-28s%s : %s\n", Green, tool.Name, Reset, tool.Comment)
		fmt.Fprintf(w, "    Command: %s%s%s\n\n", Cyan, tool.Exec, Reset)
	}

	fmt.Fprintf(w, "Found %s%d%s matching tool(s).\n\n", Green, len(tools), Reset)
}
