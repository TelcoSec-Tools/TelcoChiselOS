// Package sdr provides Software Defined Radio (SDR) hardware enumeration,
// USB transceiver discovery, driver diagnostics, and FPGA bitstream management.
package sdr

import (
	"context"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

// ANSI color constants
const (
	Bold    = "\033[1m"
	Cyan    = "\033[1;36m"
	Green   = "\033[1;32m"
	Yellow  = "\033[1;33m"
	Red     = "\033[1;31m"
	Dim     = "\033[2m"
	Reset   = "\033[0m"
)

// USBSDRDevice represents a discovered USB radio transceiver.
type USBSDRDevice struct {
	VendorID   string
	ProductID  string
	Model      string
	DevicePath string
}

// BitstreamFile represents an offline FPGA image.
type BitstreamFile struct {
	Path     string
	Filename string
	Size     int64
}

// USBSDRRegistry maps "vendor:product" hex IDs to known SDR transceiver names.
var USBSDRRegistry = map[string]string{
	"2500:0020": "Ettus USRP B200 / B210",
	"2500:0021": "Ettus USRP B200mini",
	"2500:0022": "Ettus USRP B205mini",
	"3923:7813": "NI USRP-2900",
	"3923:7814": "NI USRP-2901",
	"1d50:6089": "Great Scott Gadgets HackRF One",
	"1d50:604b": "Great Scott Gadgets HackRF Jawbreaker",
	"1d50:cc15": "Great Scott Gadgets Rad1o",
	"2cf0:5250": "Nuand BladeRF 2.0 micro",
	"2cf0:5246": "Nuand BladeRF x40 / x115",
	"1d50:6108": "MyriadRF LimeSDR USB",
	"0403:601f": "MyriadRF LimeSDR Mini",
	"0bda:2838": "Realtek RTL2838 / RTL-SDR",
	"0bda:2832": "Realtek RTL2832U",
	"1d50:60a1": "Airspy R2 / Mini",
	"03eb:800c": "Airspy HF+",
	"0456:b673": "Analog Devices ADALM-PLUTO",
	"0456:b674": "Analog Devices ADALM-PLUTO (DFU)",
}

// DetectUSBSDRs enumerates connected USB SDRs via /sys/bus/usb/devices or lsusb.
func DetectUSBSDRs() []USBSDRDevice {
	var found []USBSDRDevice

	// 1. Direct sysfs scan
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

			if model, ok := USBSDRRegistry[key]; ok {
				found = append(found, USBSDRDevice{
					VendorID:   vid,
					ProductID:  pid,
					Model:      model,
					DevicePath: dir,
				})
			}
		}
	}

	// 2. Fallback via lsusb if sysfs was empty
	if len(found) == 0 {
		out, err := exec.Command("lsusb").Output()
		if err == nil {
			lines := strings.Split(string(out), "\n")
			for _, line := range lines {
				lineLower := strings.ToLower(line)
				for key, model := range USBSDRRegistry {
					if strings.Contains(lineLower, key) {
						parts := strings.Split(key, ":")
						found = append(found, USBSDRDevice{
							VendorID:   parts[0],
							ProductID:  parts[1],
							Model:      model,
							DevicePath: line,
						})
					}
				}
			}
		}
	}

	return found
}

// DetectSerialModems scans for cellular and AT serial modems in /dev.
func DetectSerialModems() []string {
	var modems []string
	patterns := []string{"/dev/ttyUSB*", "/dev/ttyACM*"}
	for _, pat := range patterns {
		matches, err := filepath.Glob(pat)
		if err == nil {
			modems = append(modems, matches...)
		}
	}
	return modems
}

// CheckPCSCDaemon verifies if pcscd is running for SIM reader access.
func CheckPCSCDaemon() bool {
	if err := exec.Command("systemctl", "is-active", "--quiet", "pcscd").Run(); err == nil {
		return true
	}
	if err := exec.Command("pgrep", "-x", "pcscd").Run(); err == nil {
		return true
	}
	return false
}

// FindDriverBinary searches for driver utilities in PATH or Conda environment.
func FindDriverBinary(binaryName string) (string, bool) {
	if p, err := exec.LookPath(binaryName); err == nil {
		return p, true
	}
	condaPath := filepath.Join("/opt/telcosec/miniconda/envs/telcosec-sdr/bin", binaryName)
	if _, err := os.Stat(condaPath); err == nil {
		return condaPath, true
	}
	return "", false
}

// ProbeHardware runs live hardware detection for SoapySDR, UHD, BladeRF, and Smartcards.
func ProbeHardware(w io.Writer) {
	fmt.Fprintf(w, "%s=== Scanning Attached Telecom Hardware ===%s\n\n", Bold, Reset)

	// 1. SoapySDR
	fmt.Fprintf(w, "%s[1/4] Probing SDR Transceivers via SoapySDR...%s\n", Cyan, Reset)
	if bin, ok := FindDriverBinary("SoapySDRUtil"); ok {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		cmd := exec.CommandContext(ctx, bin, "--find")
		out, err := cmd.CombinedOutput()
		if err == nil && len(strings.TrimSpace(string(out))) > 0 {
			fmt.Fprintln(w, string(out))
		} else {
			fmt.Fprintln(w, "  No SoapySDR devices responded.")
		}
	} else {
		fmt.Fprintln(w, "  SoapySDRUtil not found on system.")
	}

	// 2. UHD USRP
	fmt.Fprintf(w, "\n%s[2/4] Probing Ettus USRP Devices...%s\n", Cyan, Reset)
	if bin, ok := FindDriverBinary("uhd_find_devices"); ok {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		cmd := exec.CommandContext(ctx, bin)
		out, err := cmd.CombinedOutput()
		if err == nil && len(strings.TrimSpace(string(out))) > 0 {
			fmt.Fprintln(w, string(out))
		} else {
			fmt.Fprintln(w, "  No USRP devices responded.")
		}
	} else {
		fmt.Fprintln(w, "  uhd_find_devices not found on system.")
	}

	// 3. Nuand BladeRF
	fmt.Fprintf(w, "\n%s[3/4] Probing Nuand BladeRF Devices...%s\n", Cyan, Reset)
	if bin, ok := FindDriverBinary("bladeRF-cli"); ok {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		cmd := exec.CommandContext(ctx, bin, "-p")
		out, err := cmd.CombinedOutput()
		if err == nil && len(strings.TrimSpace(string(out))) > 0 {
			fmt.Fprintln(w, string(out))
		} else {
			fmt.Fprintln(w, "  No BladeRF devices responded.")
		}
	} else {
		fmt.Fprintln(w, "  bladeRF-cli not found on system.")
	}

	// 4. PC/SC Smartcard
	fmt.Fprintf(w, "\n%s[4/4] Probing SIM Card Readers (PC/SC)...%s\n", Cyan, Reset)
	if bin, ok := FindDriverBinary("pcsc_scan"); ok {
		ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer cancel()
		cmd := exec.CommandContext(ctx, bin, "-n")
		out, err := cmd.CombinedOutput()
		if err == nil && len(strings.TrimSpace(string(out))) > 0 {
			fmt.Fprintln(w, string(out))
		} else {
			fmt.Fprintln(w, "  No smartcard readers detected.")
		}
	} else {
		if CheckPCSCDaemon() {
			fmt.Fprintln(w, "  pcscd is running, but pcsc_scan utility is not installed.")
		} else {
			fmt.Fprintln(w, "  pcscd is not running and pcsc_scan is not installed.")
		}
	}
	fmt.Fprintln(w)
}

// InspectBitstreams lists available FPGA bitstream images for BladeRF and UHD USRP.
func InspectBitstreams(w io.Writer) {
	fmt.Fprintf(w, "%s=== Offline SDR FPGA Bitstream Management ===%s\n\n", Bold, Reset)

	bladeRFDir := "/usr/share/Nuand/bladeRF"
	uhdDir := "/usr/share/uhd/images"

	fmt.Fprintf(w, "%s--- BladeRF FPGA Images (%s) ---%s\n", Cyan, bladeRFDir, Reset)
	rbfs, _ := filepath.Glob(filepath.Join(bladeRFDir, "*.rbf"))
	if len(rbfs) > 0 {
		for _, f := range rbfs {
			info, err := os.Stat(f)
			if err == nil {
				fmt.Fprintf(w, "  %-32s  (%8.1f KB)\n", filepath.Base(f), float64(info.Size())/1024.0)
			}
		}
	} else {
		fmt.Fprintf(w, "%s  No .rbf bitstreams found in %s%s\n", Yellow, bladeRFDir, Reset)
	}

	fmt.Fprintf(w, "\n%s--- USRP FPGA Images (%s) ---%s\n", Cyan, uhdDir, Reset)
	bins, _ := filepath.Glob(filepath.Join(uhdDir, "*.bin"))
	if len(bins) > 0 {
		count := 0
		for _, f := range bins {
			info, err := os.Stat(f)
			if err == nil {
				fmt.Fprintf(w, "  %-32s  (%8.1f MB)\n", filepath.Base(f), float64(info.Size())/(1024.0*1024.0))
				count++
				if count >= 10 {
					fmt.Fprintf(w, "  ... and %d more images\n", len(bins)-10)
					break
				}
			}
		}
	} else {
		fmt.Fprintf(w, "%s  No .bin FPGA images found in %s%s\n", Yellow, uhdDir, Reset)
	}

	fmt.Fprintf(w, "\nTo download or refresh offline FPGA images (requires internet):\n")
	fmt.Fprintf(w, "  sudo /usr/local/bin/bladerf-download-images\n")
	fmt.Fprintf(w, "  sudo /usr/local/bin/uhd-download-images\n\n")
}
