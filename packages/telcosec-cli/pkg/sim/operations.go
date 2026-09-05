package sim

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
)

// ToolStatus represents the availability of a specific smartcard tool.
type ToolStatus struct {
	Name        string `json:"name"`
	Installed   bool   `json:"installed"`
	Path        string `json:"path,omitempty"`
	Description string `json:"description"`
}

// EnvironmentStatus captures the full SIM/eSIM auditing setup.
type EnvironmentStatus struct {
	PCSCDaemonActive bool              `json:"pcscd_active"`
	Readers          []SmartcardReader `json:"readers"`
	SIMtraceProbes   []SIMtraceDevice  `json:"simtrace_probes"`
	Tools            []ToolStatus      `json:"tools"`
}

// GetEnvironmentStatus audits all SIM/eSIM components on the host.
func GetEnvironmentStatus() *EnvironmentStatus {
	env := &EnvironmentStatus{
		PCSCDaemonActive: CheckPCSCDaemon(),
		Readers:          DetectUSBReaders(),
		SIMtraceProbes:   DetectSIMtraceDevices(),
		Tools:            []ToolStatus{},
	}

	// Also check PC/SC readers
	if pcscReaders, err := ListPCScReaders(); err == nil && len(pcscReaders) > 0 {
		env.Readers = pcscReaders
	}

	// Tool inventory
	toolDefs := []struct {
		name string
		desc string
		alt  string
	}{
		{"pcsc_scan", "PC/SC smartcard real-time reader and ATR poller", "/opt/telcosec/miniconda/envs/telcosec-sdr/bin/pcsc_scan"},
		{"pySim-shell", "Osmocom interactive SIM/USIM filesystem & APDU shell", "/opt/telcosec/pysim/pySim-shell.py"},
		{"lpac", "eSIM Local Profile Assistant for eUICC profiles", "/opt/telcosec/lpac/build/src/lpac"},
		{"simtrace2-list", "Osmocom SIMtrace 2 USB hardware enumerator", "/opt/telcosec/simtrace2/host/simtrace2-list"},
		{"simtrace2-sniff", "Osmocom SIMtrace 2 real-time APDU sniffer to GSMTAP", "/opt/telcosec/simtrace2/host/simtrace2-sniff"},
		{"swsim", "SIMurai software-emulated ISO-7816 SIM card", "/opt/telcosec/simurai/swsim/swsim"},
		{"swicc-pcsc", "SIMurai virtual PC/SC IFD driver bridge", "/usr/lib/pcsc/drivers/libswicc-pcsc.so"},
	}

	for _, td := range toolDefs {
		ts := ToolStatus{
			Name:        td.name,
			Description: td.desc,
			Installed:   false,
		}
		if p, err := exec.LookPath(td.name); err == nil {
			ts.Installed = true
			ts.Path = p
		} else if _, err := os.Stat(td.alt); err == nil {
			ts.Installed = true
			ts.Path = td.alt
		}
		env.Tools = append(env.Tools, ts)
	}

	return env
}

// PrintEnvironmentStatus prints an overview of SIM/eSIM facilities.
func PrintEnvironmentStatus(w io.Writer, jsonOutput bool) error {
	env := GetEnvironmentStatus()

	if jsonOutput {
		enc := json.NewEncoder(w)
		enc.SetIndent("", "  ")
		return enc.Encode(env)
	}

	fmt.Fprintf(w, "%s=== Telecom Smartcard, SIM & eSIM Environment Status ===%s\n\n", Bold, Reset)

	if env.PCSCDaemonActive {
		fmt.Fprintf(w, "  PC/SC Daemon (pcscd)     : %sACTIVE%s\n", Green, Reset)
	} else {
		fmt.Fprintf(w, "  PC/SC Daemon (pcscd)     : %sINACTIVE%s (Run: sudo systemctl start pcscd)\n", Yellow, Reset)
	}

	fmt.Fprintf(w, "  Attached Readers         : %s%d detected%s\n", Cyan, len(env.Readers), Reset)
	fmt.Fprintf(w, "  SIMtrace 2 Probes        : %s%d detected%s\n\n", Cyan, len(env.SIMtraceProbes), Reset)

	fmt.Fprintf(w, "%s--- Installed SIM/eSIM Utilities ---%s\n", Bold, Reset)
	fmt.Fprintf(w, "  %-18s %-12s %s\n", "TOOL", "STATUS", "FUNCTION")
	fmt.Fprintf(w, "  %-18s %-12s %s\n", "------------------", "------------", "----------------------------------------------------")

	for _, t := range env.Tools {
		st := fmt.Sprintf("%s[READY]%s", Green, Reset)
		if !t.Installed {
			st = fmt.Sprintf("%s[NOT FOUND]%s", Dim, Reset)
		}
		fmt.Fprintf(w, "  %-18s %-21s %s\n", t.Name, st, t.Description)
	}

	fmt.Fprintf(w, "\n%s--- Quick Operations Guide ---%s\n", Bold, Reset)
	fmt.Fprintf(w, "  List smartcard readers   : %stelcosec sim readers%s\n", Cyan, Reset)
	fmt.Fprintf(w, "  Decode inserted card ATR : %stelcosec sim atr%s\n", Cyan, Reset)
	fmt.Fprintf(w, "  Decode arbitrary ATR hex : %stelcosec sim atr <hex_string>%s\n", Cyan, Reset)
	fmt.Fprintf(w, "  Launch pySim APDU shell  : %stelcosec sim shell%s\n", Cyan, Reset)
	fmt.Fprintf(w, "  Inspect eSIM profiles    : %stelcosec sim lpac%s\n", Cyan, Reset)
	fmt.Fprintf(w, "  Launch SIMtrace sniffer  : %stelcosec sim trace sniff%s\n\n", Cyan, Reset)

	return nil
}

// LaunchPySimShell starts an interactive pySim-shell session.
func LaunchPySimShell(w io.Writer, args []string) error {
	bin := "pySim-shell"
	if p, err := exec.LookPath("pySim-shell"); err == nil {
		bin = p
	} else if p, err := exec.LookPath("/opt/telcosec/pysim/pySim-shell.py"); err == nil {
		bin = p
	} else {
		return fmt.Errorf("pySim-shell not found on system (install telcochisel-tools-sim)")
	}

	fmt.Fprintf(w, "%s=== Launching Osmocom pySim-shell Interactive Console ===%s\n\n", Bold, Reset)

	cmd := exec.Command(bin, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	return cmd.Run()
}
