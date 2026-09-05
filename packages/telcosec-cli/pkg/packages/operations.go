package packages

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/TelcoSec-Tools/telcosec-cli/pkg/telemetry"
)

const (
	OfficialRepoURL = "https://meta.telcosec.net"
	Deb822Sources   = "/etc/apt/sources.list.d/telcochisel.sources"
	LegacySources   = "/etc/apt/sources.list.d/telcosec.list"
	ArchiveKeyring  = "/etc/apt/keyrings/telcochisel-archive-keyring.asc"
	LegacyKeyring   = "/etc/apt/trusted.gpg.d/telcosec.gpg"
)

// InstallPackage deploys a requested metapackage suite using the available package manager.
func InstallPackage(w io.Writer, query string) error {
	pkg := FindPackage(query)
	if pkg == nil {
		return fmt.Errorf("unknown metapackage '%s'. Run 'telcosec pkg list' for valid suites", query)
	}

	fmt.Fprintf(w, "%sDeploying %s (%s)...%s\n", telemetry.Bold, pkg.Name, pkg.Alias, telemetry.Reset)

	// If telcosec-pkg wrapper script is present on system, delegate
	if p, err := exec.LookPath("telcosec-pkg"); err == nil {
		cmd := exec.Command(p, "install", pkg.Alias)
		cmd.Stdout = w
		cmd.Stderr = os.Stderr
		cmd.Stdin = os.Stdin
		return cmd.Run()
	}

	// Native fallback via apt-get
	fmt.Fprintf(w, "Running 'sudo apt-get install -y %s'...\n", pkg.Name)
	cmd := exec.Command("sudo", "apt-get", "install", "-y", pkg.Name)
	cmd.Stdout = w
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}

// RemovePackage uninstalls a requested metapackage suite from the system.
func RemovePackage(w io.Writer, query string) error {
	pkg := FindPackage(query)
	if pkg == nil {
		return fmt.Errorf("unknown metapackage '%s'. Run 'telcosec pkg list' for valid suites", query)
	}

	fmt.Fprintf(w, "%sRemoving %s (%s)...%s\n", telemetry.Bold, pkg.Name, pkg.Alias, telemetry.Reset)

	if p, err := exec.LookPath("telcosec-pkg"); err == nil {
		cmd := exec.Command(p, "remove", pkg.Alias)
		cmd.Stdout = w
		cmd.Stderr = os.Stderr
		cmd.Stdin = os.Stdin
		return cmd.Run()
	}

	cmd := exec.Command("sudo", "apt-get", "remove", "-y", pkg.Name)
	cmd.Stdout = w
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}

// AuditPackages inspects the system to verify installed suites and broken dependencies.
func AuditPackages(w io.Writer) error {
	fmt.Fprintf(w, "%s=== Metapackage System Audit ===%s\n\n", telemetry.Bold, telemetry.Reset)

	installedCount := 0
	for _, pkg := range CanonicalRegistry {
		inst, ver, _ := CheckStatus(pkg.Name)
		if inst {
			installedCount++
			fmt.Fprintf(w, "  %s%-28s%s: %sINSTALLED%s (%s)\n", telemetry.Bold, pkg.Name, telemetry.Reset, telemetry.Green, telemetry.Reset, ver)
		}
	}

	fmt.Println()
	if installedCount == 0 {
		fmt.Fprintf(w, "  %sNo modular metapackages currently installed.%s\n", telemetry.Yellow, telemetry.Reset)
		fmt.Fprintf(w, "  Install foundational tools via: %ssudo telcosec pkg install base%s\n", telemetry.Cyan, telemetry.Reset)
	} else {
		fmt.Fprintf(w, "  %s%d of %d%s official metapackage suites installed.\n",
			telemetry.Green, installedCount, len(CanonicalRegistry), telemetry.Reset)
	}

	// Verify dpkg integrity
	if dpkg, err := exec.LookPath("dpkg"); err == nil {
		cmd := exec.Command(dpkg, "--audit")
		out, err := cmd.CombinedOutput()
		if err == nil && len(strings.TrimSpace(string(out))) == 0 {
			fmt.Fprintf(w, "  dpkg database state: %sCLEAN%s (no broken or half-configured packages)\n\n", telemetry.Green, telemetry.Reset)
		} else {
			fmt.Fprintf(w, "  dpkg database state: %sATTENTION REQUIRED%s\n  %s\n\n", telemetry.Red, telemetry.Reset, string(out))
		}
	}

	return nil
}

// RepoStatus audits the official APT repository enrollment and CDN network reachability.
func RepoStatus(w io.Writer) error {
	fmt.Fprintf(w, "%s=== Official APT Repository Status ===%s\n\n", telemetry.Bold, telemetry.Reset)
	fmt.Fprintf(w, "  Repository Endpoint : %s%s%s\n", telemetry.Cyan, OfficialRepoURL, telemetry.Reset)

	// Check sources configuration
	sourcesConfigured := false
	if _, err := os.Stat(Deb822Sources); err == nil {
		sourcesConfigured = true
		fmt.Fprintf(w, "  APT Sources Config  : %sCONFIGURED%s (%s)\n", telemetry.Green, telemetry.Reset, Deb822Sources)
	} else if _, err := os.Stat(LegacySources); err == nil {
		sourcesConfigured = true
		fmt.Fprintf(w, "  APT Sources Config  : %sCONFIGURED%s (%s)\n", telemetry.Green, telemetry.Reset, LegacySources)
	} else {
		fmt.Fprintf(w, "  APT Sources Config  : %sNOT CONFIGURED%s\n", telemetry.Yellow, telemetry.Reset)
	}

	// Check Keyring
	keyringConfigured := false
	if _, err := os.Stat(ArchiveKeyring); err == nil {
		keyringConfigured = true
		fmt.Fprintf(w, "  GPG Signing Keyring : %sVERIFIED%s (%s)\n", telemetry.Green, telemetry.Reset, ArchiveKeyring)
	} else if _, err := os.Stat(LegacyKeyring); err == nil {
		keyringConfigured = true
		fmt.Fprintf(w, "  GPG Signing Keyring : %sVERIFIED%s (%s)\n", telemetry.Green, telemetry.Reset, LegacyKeyring)
	} else {
		fmt.Fprintf(w, "  GPG Signing Keyring : %sNOT FOUND%s\n", telemetry.Yellow, telemetry.Reset)
	}

	// Network reachability test
	client := http.Client{
		Timeout: 4 * time.Second,
	}
	resp, err := client.Get(OfficialRepoURL)
	if err == nil && (resp.StatusCode == 200 || resp.StatusCode == 301 || resp.StatusCode == 302) {
		resp.Body.Close()
		fmt.Fprintf(w, "  CDN Edge Reachability: %sONLINE%s (HTTP %d)\n\n", telemetry.Green, telemetry.Reset, resp.StatusCode)
	} else {
		fmt.Fprintf(w, "  CDN Edge Reachability: %sOFFLINE / UNREACHABLE%s\n\n", telemetry.Red, telemetry.Reset)
	}

	if !sourcesConfigured || !keyringConfigured {
		fmt.Fprintf(w, "%sTo enroll this system in the official repository:%s\n", telemetry.Bold, telemetry.Reset)
		fmt.Fprintf(w, "  %ssudo telcosec pkg repo enable%s\n\n", telemetry.Cyan, telemetry.Reset)
	}

	return nil
}

// RepoEnable enrolls the host system in the official meta.telcosec.net repository.
func RepoEnable(w io.Writer) error {
	fmt.Fprintf(w, "%sEnrolling system in %s APT repository...%s\n", telemetry.Bold, OfficialRepoURL, telemetry.Reset)

	if p, err := exec.LookPath("telcosec-pkg"); err == nil {
		cmd := exec.Command(p, "repo", "enable")
		cmd.Stdout = w
		cmd.Stderr = os.Stderr
		cmd.Stdin = os.Stdin
		return cmd.Run()
	}

	scriptURL := "https://raw.githubusercontent.com/TelcoSec-Tools/TelcoChiselOS/main/scripts/install-telcochisel-repo.sh"
	fmt.Fprintf(w, "Executing automated setup script from %s...\n", scriptURL)
	cmd := exec.Command("bash", "-c", fmt.Sprintf("curl -fsSL %s | sudo bash", scriptURL))
	cmd.Stdout = w
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
