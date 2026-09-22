// Package assets provides inspection, verification, and on-demand synchronization
// for telecom assets including UHD FPGA bitstreams, 5G SBI OpenAPI definitions,
// and specialized telecom wordlists.
package assets

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// ANSI Color definitions
const (
	Bold   = "\033[1m"
	Cyan   = "\033[1;36m"
	Green  = "\033[1;32m"
	Yellow = "\033[1;33m"
	Red    = "\033[1;31m"
	Dim    = "\033[2m"
	Reset  = "\033[0m"
)

// AssetGroup represents a managed offline asset directory.
type AssetGroup struct {
	Name        string
	Path        string
	Description string
	UpdateCmd   string
	FilePattern string
}

// DefaultAssetGroups lists the key offline telecom asset collections in TelcoChisel.
var DefaultAssetGroups = []AssetGroup{
	{
		Name:        "UHD FPGA Images",
		Path:        "/usr/share/uhd/images",
		Description: "USRP B200/B210/X310/N310 FPGA bitstreams and firmware",
		UpdateCmd:   "uhd_images_downloader",
		FilePattern: "*.bin",
	},
	{
		Name:        "5G SBI OpenAPI Definitions",
		Path:        "/etc/wireshark/openapi",
		Description: "3GPP Rel-16/17/18 OpenAPI YAML specs for Wireshark HTTP/2 SBI dissection",
		UpdateCmd:   "telcosec-download-openapi",
		FilePattern: "*.yaml",
	},
	{
		Name:        "Telecom Security Wordlists",
		Path:        "/usr/share/wordlists/telecom",
		Description: "APN, IMSI, SS7 Global Title, and VoIP brute-force dictionaries",
		UpdateCmd:   "apt-get install --only-upgrade telcochisel-wordlists",
		FilePattern: "*.txt",
	},
}

// AssetStatus contains information about an asset directory's state.
type AssetStatus struct {
	Group     AssetGroup
	Exists    bool
	FileCount int
	SizeBytes int64
}

// CheckAssets inspects the presence and size of telecom assets.
func CheckAssets() []AssetStatus {
	statuses := make([]AssetStatus, 0, len(DefaultAssetGroups))

	for _, group := range DefaultAssetGroups {
		status := AssetStatus{
			Group: group,
		}

		info, err := os.Stat(group.Path)
		if err == nil && info.IsDir() {
			status.Exists = true
			var totalSize int64
			var count int

			_ = filepath.Walk(group.Path, func(path string, f os.FileInfo, err error) error {
				if err == nil && !f.IsDir() {
					count++
					totalSize += f.Size()
				}
				return nil
			})
			status.FileCount = count
			status.SizeBytes = totalSize
		}

		statuses = append(statuses, status)
	}

	return statuses
}

// PrintAssetReport renders formatted status of all offline assets.
func PrintAssetReport(w io.Writer, statuses []AssetStatus) {
	fmt.Fprintf(w, "%s=== TelcoChisel Offline Asset & Firmware Status ===%s\n\n", Bold+Cyan, Reset)

	for _, s := range statuses {
		fmt.Fprintf(w, "%s● %s%s (%s)\n", Bold, s.Group.Name, Reset, s.Group.Path)
		fmt.Fprintf(w, "  %s%s%s\n", Dim, s.Group.Description, Reset)

		if s.Exists && s.FileCount > 0 {
			mb := float64(s.SizeBytes) / (1024 * 1024)
			fmt.Fprintf(w, "  Status: %sReady%s (%d files, %.1f MB)\n", Green, Reset, s.FileCount, mb)
		} else if s.Exists {
			fmt.Fprintf(w, "  Status: %sEmpty directory%s (Run '%s')\n", Yellow, Reset, s.Group.UpdateCmd)
		} else {
			fmt.Fprintf(w, "  Status: %sNot Installed%s (Run '%s')\n", Red, Reset, s.Group.UpdateCmd)
		}
		fmt.Fprintln(w)
	}
}

// UpdateAsset triggers update command for a specific asset group or all groups.
func UpdateAsset(w io.Writer, targetGroup string) error {
	for _, group := range DefaultAssetGroups {
		if targetGroup != "" && targetGroup != "all" && !strings.EqualFold(group.Name, targetGroup) && !strings.Contains(strings.ToLower(group.Name), strings.ToLower(targetGroup)) {
			continue
		}

		fmt.Fprintf(w, "%s--> Updating %s...%s\n", Bold+Cyan, group.Name, Reset)
		fmt.Fprintf(w, "  Executing: %s\n", group.UpdateCmd)

		cmdParts := strings.Fields(group.UpdateCmd)
		if len(cmdParts) == 0 {
			continue
		}

		cmd := exec.Command(cmdParts[0], cmdParts[1:]...)
		cmd.Stdout = w
		cmd.Stderr = w

		if err := cmd.Run(); err != nil {
			fmt.Fprintf(w, "  %sUpdate failed: %v%s\n", Yellow, err, Reset)
		} else {
			fmt.Fprintf(w, "  %sSuccessfully updated %s%s\n", Green, group.Name, Reset)
		}
	}
	return nil
}
