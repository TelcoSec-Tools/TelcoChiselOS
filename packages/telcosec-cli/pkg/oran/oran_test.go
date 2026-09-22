package oran

import (
	"bytes"
	"strings"
	"testing"
)

func TestPrintStatus(t *testing.T) {
	buf := new(bytes.Buffer)
	PrintStatus(buf)
	out := buf.String()

	if !strings.Contains(out, "O-RAN Alliance Security") {
		t.Errorf("Expected output to contain 'O-RAN Alliance Security', got:\n%s", out)
	}
	if !strings.Contains(out, "O-RAN E2 Node Simulator") {
		t.Errorf("Expected output to contain 'O-RAN E2 Node Simulator', got:\n%s", out)
	}
}

func TestRunO1Scan(t *testing.T) {
	buf := new(bytes.Buffer)
	RunO1Scan(buf, "127.0.0.1", 830)
	out := buf.String()

	if !strings.Contains(out, "Scanning O-RAN O1") {
		t.Errorf("Expected output to contain 'Scanning O-RAN O1', got:\n%s", out)
	}
	if !strings.Contains(out, "O-RAN O1 Security Scan Complete") {
		t.Errorf("Expected completion message, got:\n%s", out)
	}
}
