// Package ntn provides 3GPP Release 17/18 Non-Terrestrial Network (NTN) and
// satellite telecommunications signal analysis, Doppler shift calculations,
// and satellite SDR receiver management.
package ntn

import (
	"fmt"
	"io"
	"math"
	"os/exec"
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

// SatelliteConstellation describes known satellite telecom systems.
type SatelliteConstellation struct {
	Name        string
	Orbit       string
	Band        string
	CenterFreq  float64 // in Hz
	Description string
}

// KnownConstellations lists standard satellite mobile telecom constellations.
var KnownConstellations = []SatelliteConstellation{
	{
		Name:        "Iridium NEXT",
		Orbit:       "LEO (780 km)",
		Band:        "L-band (1616 - 1626.5 MHz)",
		CenterFreq:  1621.25e6,
		Description: "Global satellite phone, Short Burst Data (SBD), and M2M telemetry",
	},
	{
		Name:        "Inmarsat-4 / Alphasat",
		Orbit:       "GEO (35,786 km)",
		Band:        "L-band (1525 - 1559 MHz)",
		CenterFreq:  1542.0e6,
		Description: "BGAN, FleetBroadband, and Aero satellite voice/data services",
	},
	{
		Name:        "3GPP 5G NTN (Band n256 / n255)",
		Orbit:       "LEO / GEO",
		Band:        "S-band (1980 - 2200 MHz)",
		CenterFreq:  2180.0e6,
		Description: "3GPP Rel-17 Direct-to-Cellular and IoT-NTN satellite communications",
	},
}

// PrintStatus displays available satellite & NTN demodulators and tools.
func PrintStatus(w io.Writer) {
	fmt.Fprintf(w, "%s=== Non-Terrestrial Networks (NTN) & Satellite Telecom ===%s\n\n", Bold+Cyan, Reset)

	// Check gr-satellites
	if p, err := exec.LookPath("gr_satellites"); err == nil {
		fmt.Fprintf(w, "  %s●%s gr-satellites (NTN DSP Suite) : %sAvailable%s (%s)\n", Green, Reset, Green, Reset, p)
	} else {
		fmt.Fprintf(w, "  %s●%s gr-satellites (NTN DSP Suite) : %sAvailable in Conda (telcosec-sdr)%s\n", Green, Reset, Green, Reset)
	}

	// Check iridium-parser
	if p, err := exec.LookPath("iridium-parser"); err == nil {
		fmt.Fprintf(w, "  %s●%s Iridium Protocol Parser       : %sAvailable%s (%s)\n", Green, Reset, Green, Reset, p)
	} else {
		fmt.Fprintf(w, "  %s○%s Iridium Protocol Parser       : %sSetup Available%s (Run 'sudo ntn-sat-install')\n", Yellow, Reset, Yellow, Reset)
	}

	fmt.Fprintf(w, "\n%s=== Supported Satellite Telephony Constellations ===%s\n", Bold, Reset)
	for _, c := range KnownConstellations {
		fmt.Fprintf(w, "  %s● %-30s%s Orbit: %-15s | Freq: %.2f MHz\n", Bold, c.Name, Reset, c.Orbit, c.CenterFreq/1e6)
		fmt.Fprintf(w, "    %s%s%s\n", Dim, c.Description, Reset)
	}
	fmt.Fprintln(w)
}

// CalculateDoppler computes maximum Doppler shift and frequency offsets for specified parameters.
func CalculateDoppler(w io.Writer, centerFreq float64, orbitType string) {
	if centerFreq <= 0 {
		centerFreq = 1621.25e6 // Default Iridium L-band
	}

	// Approximate orbital relative velocities (m/s)
	velocity := 7500.0 // LEO ~ 7.5 km/s
	if strings.EqualFold(orbitType, "geo") {
		velocity = 0.0 // GEO ground-relative Doppler ~ negligible (drift only)
	} else if strings.EqualFold(orbitType, "meo") {
		velocity = 4500.0 // MEO ~ 4.5 km/s
	}

	c := 299792458.0 // speed of light in m/s
	maxDoppler := (velocity / c) * centerFreq

	fmt.Fprintf(w, "%s=== 3GPP Rel-17 NTN Doppler Shift Calculator ===%s\n", Bold+Cyan, Reset)
	fmt.Fprintf(w, "  Carrier Frequency : %.3f MHz\n", centerFreq/1e6)
	fmt.Fprintf(w, "  Orbital Profile   : %s (Velocity: ~%.0f m/s)\n", strings.ToUpper(orbitType), velocity)
	fmt.Fprintf(w, "  Max Doppler Shift : %s±%.2f kHz%s (%.2f Hz)\n\n", Green, maxDoppler/1e3, Reset, maxDoppler)

	fmt.Fprintf(w, "  %sFrequency Tracking Guidance:%s\n", Bold, Reset)
	fmt.Fprintf(w, "  - Downlink Search Range : [%.4f MHz - %.4f MHz]\n", (centerFreq-maxDoppler)/1e6, (centerFreq+maxDoppler)/1e6)
	fmt.Fprintf(w, "  - Recommended PLL Loop  : Costas loop with BW >= %.1f Hz\n\n", math.Max(100.0, maxDoppler*0.05))
}
