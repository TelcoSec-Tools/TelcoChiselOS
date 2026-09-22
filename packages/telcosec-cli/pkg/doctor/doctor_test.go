package doctor

import (
	"bytes"
	"strings"
	"testing"
)

func TestRunDoctor(t *testing.T) {
	buf := new(bytes.Buffer)
	report := RunDoctor(buf)

	if len(report.Items) == 0 {
		t.Fatalf("Expected diagnostic items to be populated, got 0")
	}

	out := buf.String()
	if !strings.Contains(out, "Diagnostic Summary") {
		t.Errorf("Expected output to contain 'Diagnostic Summary', got:\n%s", out)
	}

	if !strings.Contains(out, "Kernel") {
		t.Errorf("Expected output to contain 'Kernel' category, got:\n%s", out)
	}
}

func TestAddItem(t *testing.T) {
	r := &DoctorReport{}
	r.addItem("TestCat", "TestCheck", "PASS", "Details")
	if r.PassCount != 1 {
		t.Errorf("Expected PassCount 1, got %d", r.PassCount)
	}
	r.addItem("TestCat", "WarnCheck", "WARN", "WarnDetails")
	if r.WarnCount != 1 {
		t.Errorf("Expected WarnCount 1, got %d", r.WarnCount)
	}
	r.addItem("TestCat", "FailCheck", "FAIL", "FailDetails")
	if r.FailCount != 1 {
		t.Errorf("Expected FailCount 1, got %d", r.FailCount)
	}
}
