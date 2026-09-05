// Package completions embeds and outputs shell completion scripts for Bash, Zsh, and Fish.
package completions

import (
	_ "embed"
	"fmt"
	"io"
	"strings"
)

//go:embed telcosec.bash
var BashScript string

//go:embed _telcosec
var ZshScript string

//go:embed telcosec.fish
var FishScript string

// SupportedShells lists shells for which autocompletion is implemented.
var SupportedShells = []string{"bash", "zsh", "fish"}

// GenerateCompletion writes the appropriate shell completion script to the provided writer.
func GenerateCompletion(shell string, w io.Writer) error {
	switch strings.ToLower(strings.TrimSpace(shell)) {
	case "bash":
		_, err := io.WriteString(w, BashScript)
		return err
	case "zsh":
		_, err := io.WriteString(w, ZshScript)
		return err
	case "fish":
		_, err := io.WriteString(w, FishScript)
		return err
	default:
		return fmt.Errorf("unsupported shell '%s'. Supported shells: bash, zsh, fish", shell)
	}
}
