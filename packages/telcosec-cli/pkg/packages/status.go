package packages

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"os/exec"
	"strings"

	"github.com/TelcoSec-Tools/telcosec-cli/pkg/telemetry"
)

// PackageStatusInfo contains metadata and local installation state of a metapackage.
type PackageStatusInfo struct {
	Metapackage
	Installed bool   `json:"installed"`
	Version   string `json:"version"`
}

// CheckStatus queries dpkg on the local system for the installation status and version of a package.
func CheckStatus(pkgName string) (bool, string, error) {
	dpkg, err := exec.LookPath("dpkg")
	if err != nil {
		return false, "-", nil
	}

	cmd := exec.Command(dpkg, "-s", pkgName)
	out, err := cmd.Output()
	if err != nil {
		return false, "-", nil
	}

	installed := false
	version := "-"

	scanner := bufio.NewScanner(strings.NewReader(string(out)))
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasPrefix(line, "Status:") {
			if strings.Contains(line, "installed") && !strings.Contains(line, "not-installed") {
				installed = true
			}
		} else if strings.HasPrefix(line, "Version:") {
			parts := strings.SplitN(line, ":", 2)
			if len(parts) == 2 {
				version = strings.TrimSpace(parts[1])
			}
		}
	}

	return installed, version, nil
}

// ListPackages audits and displays all 10 canonical TelcoChisel metapackages.
func ListPackages(w io.Writer, jsonOutput bool) error {
	var list []PackageStatusInfo

	for _, p := range CanonicalRegistry {
		inst, ver, _ := CheckStatus(p.Name)
		list = append(list, PackageStatusInfo{
			Metapackage: p,
			Installed:   inst,
			Version:     ver,
		})
	}

	if jsonOutput {
		enc := json.NewEncoder(w)
		enc.SetIndent("", "  ")
		return enc.Encode(list)
	}

	fmt.Fprintf(w, "%s=== TelcoChisel 10-Tier Modular Metapackages ===%s\n\n", telemetry.Bold, telemetry.Reset)
	fmt.Fprintf(w, "%s%-10s %-28s %-13s %-10s %s%s\n",
		telemetry.Bold, "ALIAS", "PACKAGE NAME", "STATUS", "VERSION", "DESCRIPTION", telemetry.Reset)
	fmt.Fprintln(w, strings.Repeat("─", 96))

	for _, item := range list {
		statusStr := fmt.Sprintf("%s[AVAILABLE]%s", telemetry.Yellow, telemetry.Reset)
		if item.Installed {
			statusStr = fmt.Sprintf("%s[INSTALLED]%s", telemetry.Green, telemetry.Reset)
		}

		fmt.Fprintf(w, "%-10s %-28s %-22s %-10s %s\n",
			item.Alias,
			item.Name,
			statusStr,
			item.Version,
			item.Description,
		)
	}

	fmt.Fprintf(w, "\n%sTip:%s Use 'telcosec pkg info <alias>' for tool breakdowns or 'telcosec pkg install <alias>' to deploy suites.\n", telemetry.Bold, telemetry.Reset)
	return nil
}
