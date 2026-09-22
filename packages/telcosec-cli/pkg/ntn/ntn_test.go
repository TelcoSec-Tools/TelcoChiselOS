package ntn

import (
	"bytes"
	"strings"
	"testing"
)

func TestPrintStatus(t *testing.T) {
	buf := new(bytes.Buffer)
	PrintStatus(buf)
	out := buf.String()

	if !strings.Contains(out, "Non-Terrestrial Networks") {
		t.Errorf("Expected output to contain 'Non-Terrestrial Networks', got:\n%s", out)
	}
	if !strings.Contains(out, "Iridium NEXT") {
		t.Errorf("Expected output to list Iridium NEXT, got:\n%s", out)
	}
}

func TestCalculateDoppler(t *testing.T) {
	buf := new(bytes.Buffer)
	CalculateDoppler(buf, 1621.25e6, "leo")
	out := buf.String()

	if !strings.Contains(out, "Doppler Shift Calculator") {
		t.Errorf("Expected output to contain Doppler calculator banner, got:\n%s", out)
	}
	if !strings.Contains(out, "±40.56 kHz") && !strings.Contains(out, "40.") {
		t.Errorf("Expected Doppler shift computation around 40 kHz for LEO L-band, got:\n%s", out)
	}
}
