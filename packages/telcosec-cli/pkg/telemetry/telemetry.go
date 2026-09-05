// Package telemetry provides kernel, PAM limits, USBFS memory, hugepages,
// and systemd service health diagnostics for telecom security operations.
package telemetry

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

// ANSI color constants
const (
	Bold    = "\033[1m"
	Cyan    = "\033[1;36m"
	Green   = "\033[1;32m"
	Yellow  = "\033[1;33m"
	Red     = "\033[1;31m"
	Blue    = "\033[1;34m"
	Magenta = "\033[1;35m"
	Reset   = "\033[0m"
)

// AuditResult holds comprehensive system telemetry findings.
type AuditResult struct {
	KernelVersion   string
	IsLowLatency    bool
	DistroFlavor    string
	PAMRealtime     bool
	PAMDetails      string
	USBFSMemoryMB   int
	HugepagesTotal  int
	ProfileMode     string
	ServiceStatuses map[string]bool
}

// GetKernelVersion reads the kernel release and detects if lowlatency/real-time is enabled.
func GetKernelVersion() (string, bool) {
	data, err := os.ReadFile("/proc/sys/kernel/osrelease")
	if err == nil {
		kver := strings.TrimSpace(string(data))
		isRT := strings.Contains(strings.ToLower(kver), "lowlatency") ||
			strings.Contains(strings.ToLower(kver), "rt") ||
			strings.Contains(strings.ToLower(kver), "preempt")
		return kver, isRT
	}

	out, err := exec.Command("uname", "-r").Output()
	if err == nil {
		kver := strings.TrimSpace(string(out))
		isRT := strings.Contains(strings.ToLower(kver), "lowlatency") ||
			strings.Contains(strings.ToLower(kver), "rt") ||
			strings.Contains(strings.ToLower(kver), "preempt")
		return kver, isRT
	}
	return "unknown", false
}

// GetDistroFlavor detects TelcoChisel flavor or OS variant.
func GetDistroFlavor() string {
	if data, err := os.ReadFile("/etc/telcochisel-flavor"); err == nil {
		flavor := strings.TrimSpace(string(data))
		if flavor != "" {
			return flavor
		}
	}

	if file, err := os.Open("/etc/os-release"); err == nil {
		defer file.Close()
		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			line := strings.TrimSpace(scanner.Text())
			if strings.HasPrefix(line, "VARIANT=") {
				return strings.Trim(strings.TrimPrefix(line, "VARIANT="), "\"")
			}
		}
	}
	return "Generic Linux"
}

// CheckPAMLimits verifies whether real-time priority and unlimited memlock are configured.
func CheckPAMLimits() (bool, string) {
	candidates := []string{
		"/etc/security/limits.d/99-telcochisel-rt.conf",
		"/etc/security/limits.d/99-realtime.conf",
	}

	for _, path := range candidates {
		data, err := os.ReadFile(path)
		if err == nil {
			content := string(data)
			if strings.Contains(content, "rtprio") && strings.Contains(content, "memlock") {
				return true, fmt.Sprintf("Active (rtprio 99, memlock unlimited via %s)", path)
			}
			return true, fmt.Sprintf("Present (%s)", path)
		}
	}
	return false, "Not detected in /etc/security/limits.d/"
}

// GetUSBFSMemoryMB retrieves the USB buffer size allocated by the kernel usbcore module.
func GetUSBFSMemoryMB() int {
	data, err := os.ReadFile("/sys/module/usbcore/parameters/usbfs_memory_mb")
	if err != nil {
		return 0
	}
	val, err := strconv.Atoi(strings.TrimSpace(string(data)))
	if err != nil {
		return 0
	}
	return val
}

// GetHugepages retrieves allocated hugepages count from procfs.
func GetHugepages() int {
	data, err := os.ReadFile("/proc/sys/vm/nr_hugepages")
	if err != nil {
		return 0
	}
	val, err := strconv.Atoi(strings.TrimSpace(string(data)))
	if err != nil {
		return 0
	}
	return val
}

// GetProfileMode inspects IPv4 reverse path filter to determine Lab vs Field mode.
func GetProfileMode() (string, string) {
	data, err := os.ReadFile("/proc/sys/net/ipv4/conf/all/rp_filter")
	val := "1"
	if err == nil {
		val = strings.TrimSpace(string(data))
	} else {
		out, cmdErr := exec.Command("sysctl", "-n", "net.ipv4.conf.all.rp_filter").Output()
		if cmdErr == nil {
			val = strings.TrimSpace(string(out))
		}
	}

	if val == "0" {
		return "lab", "[ LAB MODE (Packet crafting unblocked, rp_filter=0) ]"
	}
	return "field", "[ FIELD MODE (Hardened firewall, rp_filter=1) ]"
}

// CheckServiceActive checks if a given systemd service is active.
func CheckServiceActive(serviceName string) bool {
	cmd := exec.Command("systemctl", "is-active", "--quiet", serviceName)
	err := cmd.Run()
	return err == nil
}

// CollectAudit gathers all system telemetry into an AuditResult.
func CollectAudit() *AuditResult {
	kver, isRT := GetKernelVersion()
	flavor := GetDistroFlavor()
	pamOK, pamDesc := CheckPAMLimits()
	usbfs := GetUSBFSMemoryMB()
	hp := GetHugepages()
	_, profileDesc := GetProfileMode()

	services := []string{"open5gs-amfd", "open5gs-upfd", "nginx", "docker", "NetworkManager"}
	serviceMap := make(map[string]bool)
	for _, s := range services {
		serviceMap[s] = CheckServiceActive(s)
	}

	return &AuditResult{
		KernelVersion:   kver,
		IsLowLatency:    isRT,
		DistroFlavor:    flavor,
		PAMRealtime:     pamOK,
		PAMDetails:      pamDesc,
		USBFSMemoryMB:   usbfs,
		HugepagesTotal:  hp,
		ProfileMode:     profileDesc,
		ServiceStatuses: serviceMap,
	}
}

// RunAudit outputs formatted telemetry to the provided writer.
func RunAudit(w io.Writer) {
	res := CollectAudit()

	fmt.Fprintf(w, "%s=== System & Kernel Status ===%s\n", Bold, Reset)
	if res.IsLowLatency {
		fmt.Fprintf(w, "  Kernel Architecture : %s%s [Low-Latency / Real-Time SDR]%s\n", Green, res.KernelVersion, Reset)
	} else {
		fmt.Fprintf(w, "  Kernel Architecture : %s%s [Generic Scheduler]%s\n", Yellow, res.KernelVersion, Reset)
	}

	fmt.Fprintf(w, "  Distribution Flavor : %s%s%s\n", Cyan, res.DistroFlavor, Reset)

	if res.PAMRealtime {
		fmt.Fprintf(w, "  PAM Real-Time Limits: %s%s%s\n", Green, res.PAMDetails, Reset)
	} else {
		fmt.Fprintf(w, "  PAM Real-Time Limits: %s%s%s\n", Yellow, res.PAMDetails, Reset)
	}

	if res.USBFSMemoryMB >= 500 {
		fmt.Fprintf(w, "  USBFS Memory Buffer : %s%d MB (High-throughput SDR ready)%s\n", Green, res.USBFSMemoryMB, Reset)
	} else if res.USBFSMemoryMB > 0 {
		fmt.Fprintf(w, "  USBFS Memory Buffer : %s%d MB (Default: may drop samples under high MSPS)%s\n", Yellow, res.USBFSMemoryMB, Reset)
	} else {
		fmt.Fprintf(w, "  USBFS Memory Buffer : %sunknown / not loaded%s\n", Yellow, Reset)
	}

	fmt.Fprintf(w, "  Allocated Hugepages : %s%d pages%s\n", Cyan, res.HugepagesTotal, Reset)
	if strings.Contains(res.ProfileMode, "LAB") {
		fmt.Fprintf(w, "  Active Profile Mode : %s%s%s\n", Green, res.ProfileMode, Reset)
	} else {
		fmt.Fprintf(w, "  Active Profile Mode : %s%s%s\n", Yellow, res.ProfileMode, Reset)
	}

	fmt.Fprintf(w, "\n%s=== Core Telecom Services ===%s\n", Bold, Reset)
	serviceOrder := []string{"open5gs-amfd", "open5gs-upfd", "nginx", "docker", "NetworkManager"}
	for _, svc := range serviceOrder {
		active := res.ServiceStatuses[svc]
		if active {
			fmt.Fprintf(w, "  %-20s: %srunning%s\n", svc, Green, Reset)
		} else {
			fmt.Fprintf(w, "  %-20s: %sinactive / stopped%s\n", svc, Yellow, Reset)
		}
	}
	fmt.Fprintln(w)
}
