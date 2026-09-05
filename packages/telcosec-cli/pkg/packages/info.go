package packages

import (
	"fmt"
	"io"

	"github.com/TelcoSec-Tools/telcosec-cli/pkg/telemetry"
)

// ShowInfo displays detailed metadata, tools breakdown, and installation status for a package.
func ShowInfo(w io.Writer, query string) error {
	pkg := FindPackage(query)
	if pkg == nil {
		return fmt.Errorf("unknown metapackage '%s'. Run 'telcosec pkg list' to inspect available suites", query)
	}

	installed, ver, _ := CheckStatus(pkg.Name)
	statusStr := fmt.Sprintf("%sAVAILABLE (Not installed)%s", telemetry.Yellow, telemetry.Reset)
	if installed {
		statusStr = fmt.Sprintf("%sINSTALLED (%s)%s", telemetry.Green, ver, telemetry.Reset)
	}

	fmt.Fprintf(w, "%s=== Metapackage: %s (%s) ===%s\n\n", telemetry.Bold, pkg.Name, pkg.Alias, telemetry.Reset)
	fmt.Fprintf(w, "  %-16s: %s\n", "Category", pkg.Category)
	fmt.Fprintf(w, "  %-16s: %s\n", "Debian Package", pkg.Name)
	fmt.Fprintf(w, "  %-16s: %s\n", "Shorthand Alias", pkg.Alias)
	if len(pkg.AltAliases) > 0 {
		fmt.Fprintf(w, "  %-16s: %v\n", "Alt Aliases", pkg.AltAliases)
	}
	fmt.Fprintf(w, "  %-16s: %s\n", "Status", statusStr)
	fmt.Fprintf(w, "  %-16s: %s\n\n", "Overview", pkg.Description)

	fmt.Fprintf(w, "%sIncluded Tools & Subsystems:%s\n", telemetry.Bold, telemetry.Reset)
	for _, tool := range pkg.Tools {
		fmt.Fprintf(w, "  • %s\n", tool)
	}
	fmt.Println()

	if !installed {
		fmt.Fprintf(w, "%sDeployment:%s\n", telemetry.Bold, telemetry.Reset)
		fmt.Fprintf(w, "  Install suite via:  %ssudo telcosec pkg install %s%s\n\n", telemetry.Cyan, pkg.Alias, telemetry.Reset)
	} else {
		fmt.Fprintf(w, "%sMaintenance:%s\n", telemetry.Bold, telemetry.Reset)
		fmt.Fprintf(w, "  Remove suite via:   %ssudo telcosec pkg remove %s%s\n\n", telemetry.Cyan, pkg.Alias, telemetry.Reset)
	}

	return nil
}
