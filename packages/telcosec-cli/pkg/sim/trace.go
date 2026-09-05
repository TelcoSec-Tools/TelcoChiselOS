package sim

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// DetectSIMtraceDevices probes for Osmocom SIMtrace 1 and SIMtrace 2 hardware probes.
func DetectSIMtraceDevices() []SIMtraceDevice {
	var devices []SIMtraceDevice

	// 1. Scan sysfs for VID 0x1d50 and PID 0x6025 (v1) or 0x60e3 (v2)
	usbDirs, err := filepath.Glob("/sys/bus/usb/devices/*")
	if err == nil && len(usbDirs) > 0 {
		for _, dir := range usbDirs {
			vBytes, errV := os.ReadFile(filepath.Join(dir, "idVendor"))
			pBytes, errP := os.ReadFile(filepath.Join(dir, "idProduct"))
			if errV != nil || errP != nil {
				continue
			}

			vid := strings.ToLower(strings.TrimSpace(string(vBytes)))
			pid := strings.ToLower(strings.TrimSpace(string(pBytes)))

			if vid == "1d50" && (pid == "6025" || pid == "60e3") {
				model := "Osmocom SIMtrace 2 (APDU Sniffer & Card Emulator)"
				if pid == "6025" {
					model = "Osmocom SIMtrace v1"
				}

				prodBytes, _ := os.ReadFile(filepath.Join(dir, "product"))
				mode := strings.TrimSpace(string(prodBytes))
				if mode == "" {
					mode = "Sniffer / Trace Mode"
				}

				devices = append(devices, SIMtraceDevice{
					Path:      dir,
					VendorID:  vid,
					ProductID: pid,
					Model:     model,
					Mode:      mode,
				})
			}
		}
	}

	// 2. Fallback via simtrace2-list
	if len(devices) == 0 {
		if bin, err := exec.LookPath("simtrace2-list"); err == nil {
			out, err := exec.Command(bin).Output()
			if err == nil && strings.Contains(string(out), "SIMtrace") {
				devices = append(devices, SIMtraceDevice{
					Path:      "USB",
					VendorID:  "1d50",
					ProductID: "60e3",
					Model:     "Osmocom SIMtrace 2",
					Mode:      "Active (detected via simtrace2-list)",
				})
			}
		}
	}

	return devices
}

// PrintSIMtraceStatus prints attached SIMtrace probes and firmware diagnostics.
func PrintSIMtraceStatus(w io.Writer, jsonOutput bool) error {
	devices := DetectSIMtraceDevices()

	if jsonOutput {
		enc := json.NewEncoder(w)
		enc.SetIndent("", "  ")
		return enc.Encode(devices)
	}

	fmt.Fprintf(w, "%s=== Osmocom SIMtrace 2 Hardware Probes ===%s\n\n", Bold, Reset)

	if len(devices) == 0 {
		fmt.Fprintf(w, "  %sNo Osmocom SIMtrace hardware probes detected on USB bus.%s\n", Yellow, Reset)
		fmt.Fprintf(w, "  Expected USB ID: %s1d50:60e3%s (SIMtrace 2) or %s1d50:6025%s (SIMtrace 1)\n\n", Cyan, Reset, Cyan, Reset)
	} else {
		for i, dev := range devices {
			fmt.Fprintf(w, "  [%d] %s%s%s [USB: %s:%s]\n", i+1, Green, dev.Model, Reset, dev.VendorID, dev.ProductID)
			fmt.Fprintf(w, "      Mode      : %s\n", dev.Mode)
			fmt.Fprintf(w, "      Sysfs Path: %s\n\n", dev.Path)
		}
	}

	fmt.Fprintf(w, "%s--- Installed SIMtrace Utilities & Firmware ---%s\n", Bold, Reset)

	binList := []string{"simtrace2-list", "simtrace2-sniff", "simtrace2-cardem-pcsc", "simtrace2-remsim"}
	for _, b := range binList {
		if p, err := exec.LookPath(b); err == nil {
			fmt.Fprintf(w, "  %-24s : %sInstalled%s (%s)\n", b, Green, Reset, p)
		} else {
			fmt.Fprintf(w, "  %-24s : %sNot in PATH%s\n", b, Dim, Reset)
		}
	}

	fwPath := "/opt/telcosec/simtrace2/firmware"
	if entries, err := os.ReadDir(fwPath); err == nil && len(entries) > 0 {
		fmt.Fprintf(w, "\n%s--- Firmware Binaries (%s) ---%s\n", Bold, fwPath, Reset)
		for _, e := range entries {
			if strings.HasSuffix(e.Name(), ".bin") {
				fmt.Fprintf(w, "  - %s\n", e.Name())
			}
		}
	}
	fmt.Fprintln(w)

	return nil
}

// RunSniffer launches the simtrace2-sniff utility with user options.
func RunSniffer(w io.Writer, args []string) error {
	bin, err := exec.LookPath("simtrace2-sniff")
	if err != nil {
		return fmt.Errorf("simtrace2-sniff binary not found on system (install telcochisel-tools-sim)")
	}

	fmt.Fprintf(w, "%s=== Launching Osmocom SIMtrace 2 APDU Sniffer ===%s\n", Bold, Reset)
	fmt.Fprintf(w, "  Streaming APDU packets over GSMTAP (UDP port 4729) to Wireshark...\n\n")

	cmd := exec.Command(bin, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	return cmd.Run()
}
