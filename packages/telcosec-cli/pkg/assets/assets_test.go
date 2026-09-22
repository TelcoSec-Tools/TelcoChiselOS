package assets

import (
	"bytes"
	"strings"
	"testing"
)

func TestCheckAssets(t *testing.T) {
	statuses := CheckAssets()
	if len(statuses) != len(DefaultAssetGroups) {
		t.Fatalf("Expected %d asset groups, got %d", len(DefaultAssetGroups), len(statuses))
	}

	buf := new(bytes.Buffer)
	PrintAssetReport(buf, statuses)
	out := buf.String()

	if !strings.Contains(out, "UHD FPGA Images") {
		t.Errorf("Expected output to contain 'UHD FPGA Images', got:\n%s", out)
	}

	if !strings.Contains(out, "5G SBI OpenAPI") {
		t.Errorf("Expected output to contain '5G SBI OpenAPI', got:\n%s", out)
	}
}
