package sdr

import (
	"bytes"
	"strings"
	"testing"
)

func TestUSBSDRRegistry(t *testing.T) {
	if len(USBSDRRegistry) == 0 {
		t.Fatal("USBSDRRegistry should not be empty")
	}

	// Verify key SDR transceivers exist
	expected := []string{
		"2500:0020", // Ettus USRP B200 / B210
		"1d50:6089", // HackRF One
		"2cf0:5250", // BladeRF 2.0 micro
		"1d50:6108", // LimeSDR USB
		"0bda:2838", // RTL-SDR
	}

	for _, id := range expected {
		if _, ok := USBSDRRegistry[id]; !ok {
			t.Errorf("expected %s in USBSDRRegistry", id)
		}
	}
}

func TestProbeHardware(t *testing.T) {
	var buf bytes.Buffer
	ProbeHardware(&buf)
	out := buf.String()

	if !strings.Contains(out, "=== Scanning Attached Telecom Hardware ===") {
		t.Errorf("ProbeHardware missing header: %s", out)
	}

	if !strings.Contains(out, "Probing SDR Transceivers via SoapySDR") {
		t.Errorf("ProbeHardware missing SoapySDR step: %s", out)
	}
}

func TestInspectBitstreams(t *testing.T) {
	var buf bytes.Buffer
	InspectBitstreams(&buf)
	out := buf.String()

	if !strings.Contains(out, "=== Offline SDR FPGA Bitstream Management ===") {
		t.Errorf("InspectBitstreams missing header: %s", out)
	}

	if !strings.Contains(out, "BladeRF FPGA Images") {
		t.Errorf("InspectBitstreams missing BladeRF section: %s", out)
	}
}
