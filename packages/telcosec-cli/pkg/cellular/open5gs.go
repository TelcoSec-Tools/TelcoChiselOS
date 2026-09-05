// Package cellular provides lifecycle management and subscriber provisioning
// for local 5G Standalone (5G SA) and 4G LTE core networks using Open5GS.
package cellular

import (
	"bufio"
	"fmt"
	"io"
	"os/exec"
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

// Open5GSServices lists all 5G SA network function daemons in initialization order.
var Open5GSServices = []string{
	"open5gs-nrfd",
	"open5gs-scpd",
	"open5gs-amfd",
	"open5gs-smfd",
	"open5gs-upfd",
	"open5gs-ausfd",
	"open5gs-udmd",
	"open5gs-udrd",
	"open5gs-pcfd",
	"open5gs-nssfd",
	"open5gs-bsfd",
}

// StartCore starts all Open5GS 5G Standalone core services via systemctl.
func StartCore(w io.Writer) error {
	fmt.Fprintf(w, "%s=== Starting Open5GS 5G Standalone Core Services ===%s\n", Bold, Reset)

	args := append([]string{"systemctl", "start"}, Open5GSServices...)
	cmd := exec.Command("sudo", args...)
	if out, err := cmd.CombinedOutput(); err != nil {
		fmt.Fprintf(w, "  %sWarning starting core services: %s%s\n", Yellow, strings.TrimSpace(string(out)), Reset)
	}

	fmt.Fprintf(w, "%s5G Core started. Verifying AMF & UPF status:%s\n", Green, Reset)
	return StatusCore(w)
}

// StopCore stops all running Open5GS services.
func StopCore(w io.Writer) error {
	fmt.Fprintf(w, "%s=== Stopping Open5GS 5G Standalone Core Services ===%s\n", Bold, Reset)

	cmd := exec.Command("sudo", "systemctl", "stop", "open5gs-*")
	if out, err := cmd.CombinedOutput(); err != nil {
		fmt.Fprintf(w, "  %sWarning stopping core services: %s%s\n", Yellow, strings.TrimSpace(string(out)), Reset)
	} else {
		fmt.Fprintf(w, "%sAll Open5GS services stopped successfully.%s\n", Green, Reset)
	}
	return nil
}

// StatusCore checks the status of core network functions (AMF, UPF).
func StatusCore(w io.Writer) error {
	fmt.Fprintf(w, "%s=== Open5GS Core Services Status ===%s\n", Bold, Reset)

	cmd := exec.Command("systemctl", "status", "open5gs-amfd", "open5gs-upfd", "--no-pager")
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return err
	}
	if err := cmd.Start(); err != nil {
		return err
	}

	scanner := bufio.NewScanner(stdout)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.Contains(line, "Loaded:") || strings.Contains(line, "Active:") {
			if strings.Contains(line, "active (running)") {
				fmt.Fprintf(w, "  %s%s%s\n", Green, line, Reset)
			} else {
				fmt.Fprintf(w, "  %s%s%s\n", Yellow, line, Reset)
			}
		}
	}
	_ = cmd.Wait()
	fmt.Fprintln(w)
	return nil
}

// AddSubscriber provisions subscriber credentials into the Open5GS MongoDB database via open5gs-dbctl.
func AddSubscriber(w io.Writer, imsi, k, opc string) error {
	if imsi == "" {
		imsi = "001011234567890"
	}
	if k == "" {
		k = "465B5CE8B199B49FAA5F0A2EE238A6BC"
	}
	if opc == "" {
		opc = "E8ED289DEBA952E4283B54E88E6183CA"
	}

	fmt.Fprintf(w, "%s=== Provisioning 5G Test Subscriber ===%s\n", Bold, Reset)
	fmt.Fprintf(w, "  IMSI : %s%s%s\n", Cyan, imsi, Reset)
	fmt.Fprintf(w, "  Key  : %s%s%s\n", Cyan, k, Reset)
	fmt.Fprintf(w, "  OPc  : %s%s%s\n\n", Cyan, opc, Reset)

	dbctl, err := exec.LookPath("open5gs-dbctl")
	if err != nil {
		fmt.Fprintf(w, "%sERROR: open5gs-dbctl not found in PATH. Is Open5GS installed?%s\n\n", Red, Reset)
		return fmt.Errorf("open5gs-dbctl not found")
	}

	cmd := exec.Command("sudo", dbctl, "add", imsi, k, opc)
	if out, err := cmd.CombinedOutput(); err != nil {
		fmt.Fprintf(w, "%sFailed to add subscriber: %s%s\n\n", Red, strings.TrimSpace(string(out)), Reset)
		return err
	}

	fmt.Fprintf(w, "%s[+] Successfully provisioned subscriber %s into Open5GS database.%s\n\n", Green, imsi, Reset)
	return nil
}
