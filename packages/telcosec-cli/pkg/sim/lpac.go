package sim

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os/exec"
	"strings"
	"time"
)

// FindLPACBinary locates the lpac executable in standard paths.
func FindLPACBinary() (string, error) {
	candidates := []string{
		"lpac",
		"/usr/local/bin/lpac",
		"/opt/telcosec/lpac/build/src/lpac",
	}
	for _, c := range candidates {
		if p, err := exec.LookPath(c); err == nil {
			return p, nil
		}
	}
	return "", fmt.Errorf("lpac executable not found (compile via 'telcochisel-tools-sim' or /opt/telcosec/lpac)")
}

// LPACOutputWrapper represents lpac's standard JSON envelope.
type LPACOutputWrapper struct {
	Type    string          `json:"type"`
	Payload LPACOutputPayload `json:"payload"`
}

// LPACOutputPayload represents payload data inside lpac responses.
type LPACOutputPayload struct {
	Code    int             `json:"code"`
	Message string          `json:"message"`
	Data    json.RawMessage `json:"data"`
}

// LPACChipData represents eUICC chip properties from 'lpac chip info'.
type LPACChipData struct {
	EID         string `json:"eid"`
	DefaultSMDP string `json:"default_smdp"`
	FreeMemory  int64  `json:"free_memory"`
}

// LPACProfileData represents individual profile objects from 'lpac profile list'.
type LPACProfileData struct {
	ICCID        string `json:"iccid"`
	ProfileName  string `json:"profile_name"`
	ProviderName string `json:"provider_name"`
	ProfileState int    `json:"profile_state"` // 1 = Enabled, 0 = Disabled
}

// GetChipInfo queries eUICC chip information via lpac.
func GetChipInfo() (*ESIMChipInfo, error) {
	bin, err := FindLPACBinary()
	if err != nil {
		return nil, err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, bin, "chip", "info")
	out, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("lpac chip info failed: %v (%s)", err, strings.TrimSpace(string(out)))
	}

	var wrapper LPACOutputWrapper
	if err := json.Unmarshal(out, &wrapper); err == nil && len(wrapper.Payload.Data) > 0 {
		var chip LPACChipData
		if err := json.Unmarshal(wrapper.Payload.Data, &chip); err == nil {
			memStr := "-"
			if chip.FreeMemory > 0 {
				memStr = fmt.Sprintf("%d KB", chip.FreeMemory/1024)
			}
			return &ESIMChipInfo{
				EID:         chip.EID,
				DefaultSMDP: chip.DefaultSMDP,
				FreeMemory:  memStr,
			}, nil
		}
	}

	// Fallback text parsing if output was not JSON
	str := string(out)
	info := &ESIMChipInfo{FreeMemory: "-"}
	for _, line := range strings.Split(str, "\n") {
		line = strings.TrimSpace(line)
		if strings.Contains(strings.ToLower(line), "eid:") {
			parts := strings.SplitN(line, ":", 2)
			info.EID = strings.TrimSpace(parts[1])
		}
	}

	if info.EID == "" {
		return nil, fmt.Errorf("could not parse EID from lpac output: %s", str)
	}

	return info, nil
}

// ListProfiles retrieves installed eSIM profiles via lpac.
func ListProfiles() ([]ESIMProfile, error) {
	bin, err := FindLPACBinary()
	if err != nil {
		return nil, err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, bin, "profile", "list")
	out, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("lpac profile list failed: %v (%s)", err, strings.TrimSpace(string(out)))
	}

	var profiles []ESIMProfile

	var wrapper LPACOutputWrapper
	if err := json.Unmarshal(out, &wrapper); err == nil && len(wrapper.Payload.Data) > 0 {
		var list []LPACProfileData
		if err := json.Unmarshal(wrapper.Payload.Data, &list); err == nil {
			for _, p := range list {
				st := "Disabled"
				if p.ProfileState == 1 {
					st = "Enabled"
				}
				profiles = append(profiles, ESIMProfile{
					ICCID:        p.ICCID,
					ProfileName:  p.ProfileName,
					ProviderName: p.ProviderName,
					State:        st,
				})
			}
			return profiles, nil
		}
	}

	return profiles, nil
}

// ListDrivers queries available APDU driver interfaces in lpac.
func ListDrivers() ([]string, error) {
	bin, err := FindLPACBinary()
	if err != nil {
		return nil, err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, bin, "driver", "apdu", "list")
	out, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("lpac driver apdu list failed: %v (%s)", err, strings.TrimSpace(string(out)))
	}

	var drivers []string
	var wrapper LPACOutputWrapper
	if err := json.Unmarshal(out, &wrapper); err == nil && len(wrapper.Payload.Data) > 0 {
		var list []string
		if err := json.Unmarshal(wrapper.Payload.Data, &list); err == nil {
			return list, nil
		}
	}

	// Plain lines fallback
	for _, l := range strings.Split(string(out), "\n") {
		trimmed := strings.TrimSpace(l)
		if len(trimmed) > 0 && !strings.HasPrefix(trimmed, "{") {
			drivers = append(drivers, trimmed)
		}
	}

	return drivers, nil
}

// PrintLPACStatus outputs comprehensive eSIM diagnostics.
func PrintLPACStatus(w io.Writer, subAction string, jsonOutput bool) error {
	bin, err := FindLPACBinary()
	if err != nil {
		if jsonOutput {
			return json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
		}
		fmt.Fprintf(w, "%s=== eSIM Local Profile Assistant (lpac) ===%s\n\n", Bold, Reset)
		fmt.Fprintf(w, "  %s%v%s\n\n", Yellow, err, Reset)
		fmt.Fprintf(w, "  To install lpac, run: sudo apt-get install telcochisel-tools-sim\n\n")
		return nil
	}

	if jsonOutput {
		chip, _ := GetChipInfo()
		profiles, _ := ListProfiles()
		drivers, _ := ListDrivers()
		res := map[string]interface{}{
			"binary":   bin,
			"chip":     chip,
			"profiles": profiles,
			"drivers":  drivers,
		}
		enc := json.NewEncoder(w)
		enc.SetIndent("", "  ")
		return enc.Encode(res)
	}

	fmt.Fprintf(w, "%s=== eSIM Local Profile Assistant (lpac) ===%s\n\n", Bold, Reset)
	fmt.Fprintf(w, "  lpac Binary : %s%s%s\n\n", Green, bin, Reset)

	// Drivers
	drivers, _ := ListDrivers()
	fmt.Fprintf(w, "%s--- Available APDU Reader Drivers ---%s\n", Bold, Reset)
	if len(drivers) == 0 {
		fmt.Fprintf(w, "  None detected or reader not inserted.\n")
	} else {
		for _, d := range drivers {
			fmt.Fprintf(w, "  - %s\n", d)
		}
	}
	fmt.Fprintln(w)

	// Chip info
	chip, chipErr := GetChipInfo()
	if chipErr == nil && chip != nil {
		fmt.Fprintf(w, "%s--- eUICC Chip Information ---%s\n", Bold, Reset)
		fmt.Fprintf(w, "  EID          : %s%s%s\n", Cyan, chip.EID, Reset)
		if chip.DefaultSMDP != "" {
			fmt.Fprintf(w, "  Default SMDP : %s\n", chip.DefaultSMDP)
		}
		if chip.FreeMemory != "" && chip.FreeMemory != "-" {
			fmt.Fprintf(w, "  Free Memory  : %s\n", chip.FreeMemory)
		}
		fmt.Fprintln(w)
	}

	// Profiles
	profiles, _ := ListProfiles()
	fmt.Fprintf(w, "%s--- Installed eSIM Profiles (%d) ---%s\n", Bold, len(profiles), Reset)
	if len(profiles) == 0 {
		fmt.Fprintf(w, "  No installed eSIM profiles found on target card/chip.\n\n")
	} else {
		fmt.Fprintf(w, "  %-22s %-24s %-20s %s\n", "ICCID", "PROFILE NAME", "PROVIDER", "STATE")
		fmt.Fprintf(w, "  %-22s %-24s %-20s %s\n", "----------------------", "------------------------", "--------------------", "-------")
		for _, p := range profiles {
			stColor := Dim
			if p.State == "Enabled" {
				stColor = Green
			}
			fmt.Fprintf(w, "  %-22s %-24s %-20s %s%s%s\n",
				p.ICCID,
				truncateStr(p.ProfileName, 24),
				truncateStr(p.ProviderName, 20),
				stColor, p.State, Reset)
		}
		fmt.Fprintln(w)
	}

	return nil
}
