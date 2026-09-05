// Package docs provides offline/online documentation launch,
// TelcoSec Academy field lab bridge, and community support links.
package docs

import (
	"fmt"
	"io"
	"os"
	"os/exec"
)

// ANSI color constants
const (
	Bold    = "\033[1m"
	Cyan    = "\033[1;36m"
	Green   = "\033[1;32m"
	Yellow  = "\033[1;33m"
	Blue    = "\033[1;34m"
	Magenta = "\033[1;35m"
	Reset   = "\033[0m"
)

const (
	OfflineDocPath   = "/usr/share/doc/telcosec/index.html"
	OnlineDocURL     = "https://chisel.telcosec.net"
	AcademyURL       = "https://app.telcosec.net/?utm_source=telcochisel_cli"
	SourceForgeURL   = "https://sourceforge.net/projects/telcochisel/reviews/new"
	CommunityForum   = "https://community.telcosec.net"
	GitHubIssuesURL  = "https://github.com/TelcoSec-Tools/TelcoChiselOS/issues"
	DiscordChatURL   = "https://discord.gg/RykzXTQFXF"
)

// HasDisplay checks if a graphical display environment is available.
func HasDisplay() bool {
	return os.Getenv("DISPLAY") != "" || os.Getenv("WAYLAND_DISPLAY") != ""
}

// LaunchURL attempts to open a URL in the user's default browser.
func LaunchURL(targetURL string) error {
	if !HasDisplay() {
		return nil
	}

	browsers := []string{"xdg-open", "sensible-browser", "firefox", "chromium"}
	for _, b := range browsers {
		if path, err := exec.LookPath(b); err == nil {
			cmd := exec.Command(path, targetURL)
			if err := cmd.Start(); err == nil {
				return nil
			}
		}
	}
	return fmt.Errorf("no browser launcher found")
}

// OpenDocs displays documentation references and opens the documentation in a browser.
func OpenDocs(w io.Writer) {
	fmt.Fprintf(w, "%s=== TelcoChisel Interactive Documentation ===%s\n\n", Bold, Reset)

	if _, err := os.Stat(OfflineDocPath); err == nil {
		fmt.Fprintf(w, "  Offline documentation: %s%s%s\n", Green, OfflineDocPath, Reset)
		if HasDisplay() {
			fmt.Fprintf(w, "  Opening offline documentation in browser...\n")
			_ = LaunchURL("file://" + OfflineDocPath)
		}
	} else {
		fmt.Fprintf(w, "  Online documentation: %s%s%s\n", Cyan, OnlineDocURL, Reset)
		if HasDisplay() {
			fmt.Fprintf(w, "  Opening online documentation in browser...\n")
			_ = LaunchURL(OnlineDocURL)
		}
	}
	fmt.Fprintln(w)
}

// OpenAcademy displays TelcoSec Academy hands-on lab details.
func OpenAcademy(w io.Writer) {
	fmt.Fprintf(w, "%s=== TelcoSec Academy -- Hands-On Telecom Security Labs ===%s\n\n", Bold, Reset)
	fmt.Fprintf(w, "Access live interactive testbeds for:\n")
	fmt.Fprintf(w, "  - 5G Standalone Core & RAN exploitation\n")
	fmt.Fprintf(w, "  - SS7, Diameter & GTP-C signaling audits\n")
	fmt.Fprintf(w, "  - SDR over-the-air cellular attacks & SIB analysis\n")
	fmt.Fprintf(w, "  - Baseband reverse engineering & FirmWire fuzzing\n\n")
	fmt.Fprintf(w, "Portal URL: %s%s%s\n\n", Yellow, AcademyURL, Reset)

	if HasDisplay() {
		_ = LaunchURL(AcademyURL)
	}
}

// OpenFeedback displays community support channels and SourceForge reviews.
func OpenFeedback(w io.Writer) {
	fmt.Fprintf(w, "%s=== Community Support & SourceForge Reviews ===%s\n", Bold, Reset)
	fmt.Fprintf(w, "  Your feedback helps telecom security researchers and operators discover TelcoChisel.\n\n")

	fmt.Fprintf(w, "  %s⭐ Rate TelcoChisel on SourceForge:%s\n", Cyan, Reset)
	fmt.Fprintf(w, "     %s\n\n", SourceForgeURL)

	fmt.Fprintf(w, "  %s💬 Community Discussion Forum:%s\n", Green, Reset)
	fmt.Fprintf(w, "     %s\n\n", CommunityForum)

	fmt.Fprintf(w, "  %s🐛 Bug Reports & Feature Requests (GitHub Issues):%s\n", Blue, Reset)
	fmt.Fprintf(w, "     %s\n\n", GitHubIssuesURL)

	fmt.Fprintf(w, "  %s🎮 Official Discord Chat Server:%s\n", Magenta, Reset)
	fmt.Fprintf(w, "     %s\n\n", DiscordChatURL)

	if HasDisplay() {
		fmt.Fprintf(w, "  Opening SourceForge review portal in browser...\n")
		_ = LaunchURL(SourceForgeURL)
	}
}
