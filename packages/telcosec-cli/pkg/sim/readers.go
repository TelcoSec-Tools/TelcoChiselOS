package sim

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

// CheckPCSCDaemon checks whether the PC/SC Smart Card daemon (pcscd) is running.
func CheckPCSCDaemon() bool {
	// 1. Direct socket/PID check (instantaneous, never hangs)
	socketPaths := []string{
		"/run/pcscd/pcscd.comm",
		"/var/run/pcscd/pcscd.comm",
		"/run/pcscd.comm",
		"/var/run/pcscd.pid",
	}
	for _, p := range socketPaths {
		if _, err := os.Stat(p); err == nil {
			return true
		}
	}

	// 2. Fast pgrep with 200ms context timeout
	ctx, cancel := context.WithTimeout(context.Background(), 200*time.Millisecond)
	defer cancel()

	if err := exec.CommandContext(ctx, "pgrep", "-x", "pcscd").Run(); err == nil {
		return true
	}

	return false
}

// DetectUSBReaders scans sysfs and lsusb for connected USB CCID and known smartcard readers.
func DetectUSBReaders() []SmartcardReader {
	var readers []SmartcardReader

	// 1. Scan sysfs /sys/bus/usb/devices
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
			key := fmt.Sprintf("%s:%s", vid, pid)

			name, isKnown := KnownSmartcardReaders[key]

			// Check USB interface class 0x0b (CCID) if not known by VID:PID
			if !isKnown {
				if isCCIDInterface(dir) {
					prodBytes, _ := os.ReadFile(filepath.Join(dir, "product"))
					pName := strings.TrimSpace(string(prodBytes))
					if pName == "" {
						pName = "Generic USB CCID Smart Card Reader"
					}
					name = pName
					isKnown = true
				}
			}

			if isKnown {
				readers = append(readers, SmartcardReader{
					Name:        name,
					VendorID:    vid,
					ProductID:   pid,
					DevicePath:  dir,
					CardPresent: false,
				})
			}
		}
	}

	// 2. Fallback via lsusb if sysfs returned nothing
	if len(readers) == 0 {
		ctx, cancel := context.WithTimeout(context.Background(), 500*time.Millisecond)
		defer cancel()
		out, err := exec.CommandContext(ctx, "lsusb").Output()
		if err == nil {
			lines := strings.Split(string(out), "\n")
			for _, line := range lines {
				lineLower := strings.ToLower(line)
				for key, model := range KnownSmartcardReaders {
					if strings.Contains(lineLower, key) {
						parts := strings.Split(key, ":")
						readers = append(readers, SmartcardReader{
							Name:        model,
							VendorID:    parts[0],
							ProductID:   parts[1],
							CardPresent: false,
						})
					}
				}
			}
		}
	}

	return readers
}

func isCCIDInterface(deviceDir string) bool {
	entries, err := filepath.Glob(filepath.Join(deviceDir, "*:*/bInterfaceClass"))
	if err != nil {
		return false
	}
	for _, entry := range entries {
		classBytes, err := os.ReadFile(entry)
		if err == nil {
			class := strings.ToLower(strings.TrimSpace(string(classBytes)))
			if class == "0b" || class == "b" {
				return true
			}
		}
	}
	return false
}

// ListPCScReaders queries the active PC/SC subsystem using pcsc_scan.
func ListPCScReaders() ([]SmartcardReader, error) {
	// If daemon is not active, fallback directly to USB detection without delaying
	if !CheckPCSCDaemon() {
		return DetectUSBReaders(), nil
	}

	pcscScanBin := "pcsc_scan"
	if p, err := exec.LookPath("pcsc_scan"); err == nil {
		pcscScanBin = p
	} else if p, err := exec.LookPath("/opt/telcosec/miniconda/envs/telcosec-sdr/bin/pcsc_scan"); err == nil {
		pcscScanBin = p
	} else {
		return DetectUSBReaders(), nil
	}

	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, pcscScanBin, "-n")
	out, err := cmd.CombinedOutput()
	outputStr := string(out)

	if err != nil && len(outputStr) == 0 {
		return DetectUSBReaders(), nil
	}

	lines := strings.Split(outputStr, "\n")
	var readers []SmartcardReader
	var currentReader *SmartcardReader

	for _, line := range lines {
		trimmed := strings.TrimSpace(line)

		if strings.HasPrefix(trimmed, "Reader ") && strings.Contains(trimmed, ":") {
			if currentReader != nil {
				readers = append(readers, *currentReader)
			}
			parts := strings.SplitN(trimmed, ":", 2)
			rName := strings.TrimSpace(parts[1])
			currentReader = &SmartcardReader{
				Name:        rName,
				CardPresent: false,
			}
			continue
		}

		if currentReader != nil {
			if strings.Contains(trimmed, "Card state: Card inserted") {
				currentReader.CardPresent = true
			} else if strings.Contains(trimmed, "Card state: Card removed") {
				currentReader.CardPresent = false
			}

			if strings.HasPrefix(trimmed, "ATR:") {
				atrParts := strings.SplitN(trimmed, ":", 2)
				currentReader.ATRHex = strings.ToUpper(strings.ReplaceAll(strings.TrimSpace(atrParts[1]), " ", ""))
				currentReader.CardPresent = true
			}
		}
	}

	if currentReader != nil {
		readers = append(readers, *currentReader)
	}

	if len(readers) == 0 {
		return DetectUSBReaders(), nil
	}

	return readers, nil
}

// GetActiveATR retrieves the ATR of the first smartcard detected in any connected reader.
func GetActiveATR() (string, error) {
	readers, err := ListPCScReaders()
	if err != nil {
		return "", err
	}
	for _, r := range readers {
		if r.CardPresent && len(r.ATRHex) > 0 {
			return r.ATRHex, nil
		}
	}
	return "", fmt.Errorf("no smartcard detected in any attached reader (card removed or reader empty)")
}

// PrintReaders lists all smartcard readers and their status.
func PrintReaders(w io.Writer, jsonOutput bool) error {
	readers, err := ListPCScReaders()
	if err != nil {
		return err
	}

	if jsonOutput {
		enc := json.NewEncoder(w)
		enc.SetIndent("", "  ")
		return enc.Encode(readers)
	}

	fmt.Fprintf(w, "%s=== Attached Smartcard & SIM Card Readers ===%s\n\n", Bold, Reset)

	daemonActive := CheckPCSCDaemon()
	if daemonActive {
		fmt.Fprintf(w, "  PC/SC Daemon (pcscd) : %sACTIVE%s\n\n", Green, Reset)
	} else {
		fmt.Fprintf(w, "  PC/SC Daemon (pcscd) : %sINACTIVE%s (Run: sudo systemctl start pcscd)\n\n", Yellow, Reset)
	}

	if len(readers) == 0 {
		fmt.Fprintf(w, "  %sNo smartcard readers or SIM programmers detected.%s\n", Yellow, Reset)
		fmt.Fprintf(w, "  Attach a USB CCID reader (e.g. Gemalto IDBridge, SCM SCR3310, ACS ACR39U) or SIMtrace probe.\n\n")
		return nil
	}

	fmt.Fprintf(w, "  %-4s %-42s %-16s %s\n", "ID", "READER MODEL", "STATUS", "DETECTED ATR")
	fmt.Fprintf(w, "  %-4s %-42s %-16s %s\n", "----", "------------------------------------------", "----------------", "----------------------------------------------------")

	for i, r := range readers {
		statusStr := fmt.Sprintf("%s[CARD INSERTED]%s", Green, Reset)
		if !r.CardPresent {
			statusStr = fmt.Sprintf("%s[NO CARD]%s", Dim, Reset)
		}

		atrDisplay := r.ATRHex
		if atrDisplay == "" {
			atrDisplay = "-"
		} else if len(atrDisplay) > 36 {
			atrDisplay = atrDisplay[:36] + "..."
		}

		fmt.Fprintf(w, "  #%-3d %-42s %-25s %s\n", i, truncateStr(r.Name, 42), statusStr, atrDisplay)
	}
	fmt.Fprintln(w)

	return nil
}

func truncateStr(s string, max int) string {
	if len(s) <= max {
		return s
	}
	return s[:max-3] + "..."
}
