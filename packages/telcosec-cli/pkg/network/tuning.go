// Package network provides 10Gbps SFP+ interface optimization, Jumbo Frame (MTU 9000)
// configuration, ring descriptor tuning, and sysctl socket buffer sizing for Ettus USRP X310/N310.
package network

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
)

// ANSI color constants
const (
	Bold   = "\033[1m"
	Cyan   = "\033[1;36m"
	Green  = "\033[1;32m"
	Yellow = "\033[1;33m"
	Red    = "\033[1;31m"
	Reset  = "\033[0m"
)

// InterfaceInfo contains network interface parameters.
type InterfaceInfo struct {
	Name      string
	OperState string
	MTU       int
	SpeedMbps int
	IPAddress string
}

// PresetConfig defines predefined IP configurations for Ettus network SDRs.
var PresetConfigs = map[string]string{
	"x310-0": "192.168.10.1/24",
	"x310-1": "192.168.20.1/24",
	"n310-0": "192.168.10.1/24",
	"n310-1": "192.168.20.1/24",
}

// ListInterfaces lists non-loopback network interfaces.
func ListInterfaces() ([]InterfaceInfo, error) {
	ifaces, err := filepath.Glob("/sys/class/net/*")
	if err != nil {
		return nil, err
	}

	var results []InterfaceInfo
	for _, p := range ifaces {
		name := filepath.Base(p)
		if name == "lo" {
			continue
		}

		oper := "unknown"
		if b, err := os.ReadFile(filepath.Join(p, "operstate")); err == nil {
			oper = strings.TrimSpace(string(b))
		}

		mtu := 1500
		if b, err := os.ReadFile(filepath.Join(p, "mtu")); err == nil {
			if v, err := strconv.Atoi(strings.TrimSpace(string(b))); err == nil {
				mtu = v
			}
		}

		speed := 0
		if b, err := os.ReadFile(filepath.Join(p, "speed")); err == nil {
			if v, err := strconv.Atoi(strings.TrimSpace(string(b))); err == nil && v > 0 {
				speed = v
			}
		}

		results = append(results, InterfaceInfo{
			Name:      name,
			OperState: oper,
			MTU:       mtu,
			SpeedMbps: speed,
		})
	}
	return results, nil
}

// GetSysctlValue retrieves a kernel sysctl parameter value.
func GetSysctlValue(key string) string {
	procPath := "/proc/sys/" + strings.ReplaceAll(key, ".", "/")
	if data, err := os.ReadFile(procPath); err == nil {
		return strings.TrimSpace(string(data))
	}
	out, err := exec.Command("sysctl", "-n", key).Output()
	if err == nil {
		return strings.TrimSpace(string(out))
	}
	return "unknown"
}

// PrintStatus displays 10GbE network interfaces, link state, MTU, and buffer settings.
func PrintStatus(w io.Writer) {
	fmt.Fprintf(w, "%s=== 10GbE & Network SDR Interface Diagnostics ===%s\n\n", Bold, Reset)

	ifaces, err := ListInterfaces()
	if err != nil || len(ifaces) == 0 {
		fmt.Fprintf(w, "  %sNo network interfaces detected.%s\n\n", Yellow, Reset)
	} else {
		fmt.Fprintf(w, "  %-14s %-10s %-8s %-12s\n", "INTERFACE", "STATE", "MTU", "LINK SPEED")
		fmt.Fprintf(w, "  %-14s %-10s %-8s %-12s\n", "---------", "-----", "---", "----------")
		for _, iface := range ifaces {
			stateColor := Yellow
			if iface.OperState == "up" {
				stateColor = Green
			}

			mtuColor := Yellow
			if iface.MTU >= 9000 {
				mtuColor = Green
			}

			speedStr := "unknown"
			if iface.SpeedMbps > 0 {
				speedStr = fmt.Sprintf("%d Mbps", iface.SpeedMbps)
			}

			fmt.Fprintf(w, "  %-14s %s%-10s%s %s%-8d%s %-12s\n",
				iface.Name,
				stateColor, iface.OperState, Reset,
				mtuColor, iface.MTU, Reset,
				speedStr,
			)
		}
	}

	fmt.Fprintf(w, "\n%s=== Kernel Socket Buffer Parameters ===%s\n", Bold, Reset)
	rmemMax := GetSysctlValue("net.core.rmem_max")
	wmemMax := GetSysctlValue("net.core.wmem_max")
	rmemDef := GetSysctlValue("net.core.rmem_default")
	wmemDef := GetSysctlValue("net.core.wmem_default")

	printSysctl := func(name, val string, target int) {
		num, _ := strconv.Atoi(val)
		if num >= target {
			fmt.Fprintf(w, "  %-24s: %s%s bytes (Optimized for 10G SDR)%s\n", name, Green, val, Reset)
		} else {
			fmt.Fprintf(w, "  %-24s: %s%s bytes (Default: recommends %d)%s\n", name, Yellow, val, target, Reset)
		}
	}

	printSysctl("net.core.rmem_max", rmemMax, 67108864)
	printSysctl("net.core.wmem_max", wmemMax, 67108864)
	printSysctl("net.core.rmem_default", rmemDef, 33554432)
	printSysctl("net.core.wmem_default", wmemDef, 33554432)
	fmt.Fprintln(w)
}

// TuneInterface configures MTU 9000, 4096 ring descriptors, and 64MB socket buffers.
func TuneInterface(w io.Writer, iface string) error {
	fmt.Fprintf(w, "%s[*] Applying 10GbE Network Tuning on %s...%s\n", Bold, iface, Reset)

	// 1. Set MTU 9000
	fmt.Fprintf(w, "  -> Setting MTU 9000 (Jumbo Frames)... ")
	cmdMTU := exec.Command("sudo", "ip", "link", "set", "dev", iface, "mtu", "9000")
	if out, err := cmdMTU.CombinedOutput(); err != nil {
		fmt.Fprintf(w, "%sFAILED%s (%s)\n", Red, Reset, strings.TrimSpace(string(out)))
	} else {
		fmt.Fprintf(w, "%sOK%s\n", Green, Reset)
	}

	// 2. Set RX/TX Ring Descriptors to 4096 via ethtool
	fmt.Fprintf(w, "  -> Maximizing RX/TX Ring Buffers (4096 descriptors)... ")
	cmdEth := exec.Command("sudo", "ethtool", "-G", iface, "rx", "4096", "tx", "4096")
	if out, err := cmdEth.CombinedOutput(); err != nil {
		fmt.Fprintf(w, "%sSKIPPED%s (Hardware/Driver does not support 4096 rings: %s)\n", Yellow, Reset, strings.TrimSpace(string(out)))
	} else {
		fmt.Fprintf(w, "%sOK%s\n", Green, Reset)
	}

	// 3. Sysctl socket buffers
	sysctls := []struct {
		key string
		val string
	}{
		{"net.core.rmem_max", "67108864"},
		{"net.core.wmem_max", "67108864"},
		{"net.core.rmem_default", "33554432"},
		{"net.core.wmem_default", "33554432"},
		{"net.core.netdev_max_backlog", "10000"},
	}

	for _, sc := range sysctls {
		fmt.Fprintf(w, "  -> Setting %s = %s... ", sc.key, sc.val)
		cmdSys := exec.Command("sudo", "sysctl", "-w", fmt.Sprintf("%s=%s", sc.key, sc.val))
		if out, err := cmdSys.CombinedOutput(); err != nil {
			fmt.Fprintf(w, "%sFAILED%s (%s)\n", Red, Reset, strings.TrimSpace(string(out)))
		} else {
			fmt.Fprintf(w, "%sOK%s\n", Green, Reset)
		}
	}

	fmt.Fprintf(w, "%s[+] 10GbE network optimization complete for %s.%s\n\n", Green, iface, Reset)
	return nil
}

// SetupInterface configures IP and subnet preset for Ettus USRP X310/N310.
func SetupInterface(w io.Writer, iface, preset string) error {
	cidr, ok := PresetConfigs[strings.ToLower(preset)]
	if !ok {
		cidr = "192.168.10.1/24"
	}

	fmt.Fprintf(w, "%s[*] Configuring %s for USRP preset '%s' (IP: %s)...%s\n", Bold, iface, preset, cidr, Reset)

	// Flush old address and assign new
	_ = exec.Command("sudo", "ip", "addr", "flush", "dev", iface).Run()
	cmdAdd := exec.Command("sudo", "ip", "addr", "add", cidr, "dev", iface)
	if out, err := cmdAdd.CombinedOutput(); err != nil {
		fmt.Fprintf(w, "  %sFailed to set IP %s on %s: %s%s\n", Red, cidr, iface, strings.TrimSpace(string(out)), Reset)
	} else {
		fmt.Fprintf(w, "  %sAssigned %s to %s%s\n", Green, cidr, iface, Reset)
	}

	// Bring link UP
	cmdUp := exec.Command("sudo", "ip", "link", "set", "dev", iface, "up")
	_ = cmdUp.Run()

	// Apply 10G tuning
	return TuneInterface(w, iface)
}

// ProbeNetwork searches for Ettus USRP devices on the network.
func ProbeNetwork(w io.Writer, targetIP string) {
	fmt.Fprintf(w, "%s=== Probing Network for USRP Transceivers ===%s\n\n", Bold, Reset)

	uhdBin := "uhd_find_devices"
	if p, err := exec.LookPath(uhdBin); err == nil {
		uhdBin = p
	} else if _, err := os.Stat("/opt/telcosec/miniconda/envs/telcosec-sdr/bin/uhd_find_devices"); err == nil {
		uhdBin = "/opt/telcosec/miniconda/envs/telcosec-sdr/bin/uhd_find_devices"
	} else {
		fmt.Fprintf(w, "  %suhd_find_devices not found on system.%s\n\n", Yellow, Reset)
		return
	}

	var args []string
	if targetIP != "" {
		args = append(args, fmt.Sprintf("--args=addr=%s", targetIP))
	}

	cmd := exec.Command(uhdBin, args...)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		fmt.Fprintf(w, "  Failed to execute %s: %v\n", uhdBin, err)
		return
	}

	if err := cmd.Start(); err != nil {
		fmt.Fprintf(w, "  Failed to start %s: %v\n", uhdBin, err)
		return
	}

	scanner := bufio.NewScanner(stdout)
	for scanner.Scan() {
		fmt.Fprintln(w, "  "+scanner.Text())
	}
	_ = cmd.Wait()
	fmt.Fprintln(w)
}
