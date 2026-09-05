package network

import (
	"bytes"
	"strings"
	"testing"
)

func TestPresetConfigs(t *testing.T) {
	expected := []string{"x310-0", "x310-1", "n310-0", "n310-1"}
	for _, p := range expected {
		if _, ok := PresetConfigs[p]; !ok {
			t.Errorf("expected preset %s in PresetConfigs", p)
		}
	}
}

func TestPrintStatus(t *testing.T) {
	var buf bytes.Buffer
	PrintStatus(&buf)
	out := buf.String()

	if !strings.Contains(out, "=== 10GbE & Network SDR Interface Diagnostics ===") {
		t.Errorf("PrintStatus missing header: %s", out)
	}

	if !strings.Contains(out, "Kernel Socket Buffer Parameters") {
		t.Errorf("PrintStatus missing socket buffer section: %s", out)
	}
}
