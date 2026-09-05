package telemetry

import (
	"bytes"
	"strings"
	"testing"
)

func TestCollectAudit(t *testing.T) {
	audit := CollectAudit()
	if audit == nil {
		t.Fatal("CollectAudit returned nil")
	}

	if audit.KernelVersion == "" {
		t.Errorf("expected non-empty KernelVersion")
	}

	if audit.DistroFlavor == "" {
		t.Errorf("expected non-empty DistroFlavor")
	}
}

func TestRunAudit(t *testing.T) {
	var buf bytes.Buffer
	RunAudit(&buf)
	output := buf.String()

	if !strings.Contains(output, "=== System & Kernel Status ===") {
		t.Errorf("output missing header: %s", output)
	}

	if !strings.Contains(output, "Kernel Architecture") {
		t.Errorf("output missing Kernel Architecture: %s", output)
	}

	if !strings.Contains(output, "=== Core Telecom Services ===") {
		t.Errorf("output missing Core Telecom Services: %s", output)
	}
}
