package sbi

import (
	"bytes"
	"strings"
	"testing"
)

func TestPrintStatus(t *testing.T) {
	buf := new(bytes.Buffer)
	PrintStatus(buf)
	out := buf.String()

	if !strings.Contains(out, "5G Service Based Interface") {
		t.Errorf("Expected output to contain '5G Service Based Interface', got:\n%s", out)
	}
}

func TestValidateEndpoint(t *testing.T) {
	buf := new(bytes.Buffer)
	ValidateEndpoint(buf, "http://127.0.0.1:7777", "amf")
	out := buf.String()

	if !strings.Contains(out, "Contract Validation") {
		t.Errorf("Expected output to contain 'Contract Validation', got:\n%s", out)
	}
	if !strings.Contains(out, "NAMF") {
		t.Errorf("Expected output to mention NAMF, got:\n%s", out)
	}
}
