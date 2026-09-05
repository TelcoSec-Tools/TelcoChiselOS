package search

import (
	"bytes"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestParseDesktopEntry(t *testing.T) {
	tmpDir := t.TempDir()
	desktopFile := filepath.Join(tmpDir, "test-tool.desktop")
	content := `[Desktop Entry]
Name=Open5GS WebUI
Comment=Open5GS 5G/4G Core Network Subscriber Web Console
Exec=xdg-open http://localhost:9999
Icon=network-wireless
Terminal=false
Type=Application
Categories=TelcoChisel-Core;TelecomSecurity;
Keywords=5g;core;open5gs;amf;upf;subscriber;
`
	if err := os.WriteFile(desktopFile, []byte(content), 0644); err != nil {
		t.Fatal(err)
	}

	tool, err := ParseDesktopEntry(desktopFile)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if tool.Name != "Open5GS WebUI" {
		t.Errorf("expected Name 'Open5GS WebUI', got %s", tool.Name)
	}
	if !strings.Contains(tool.Comment, "Subscriber Web Console") {
		t.Errorf("unexpected Comment: %s", tool.Comment)
	}
	if tool.Exec != "xdg-open http://localhost:9999" {
		t.Errorf("unexpected Exec: %s", tool.Exec)
	}
	if !strings.Contains(tool.Keywords, "open5gs") {
		t.Errorf("unexpected Keywords: %s", tool.Keywords)
	}
}

func TestSearchTools(t *testing.T) {
	tmpDir := t.TempDir()
	desktopFile := filepath.Join(tmpDir, "sctp-scan.desktop")
	content := `[Desktop Entry]
Name=SCTP Scanner
Comment=Advanced SCTP telecom signaling port scanner
Exec=sctpscan -h
Categories=TelcoChisel-Signaling;
Keywords=sctp;ss7;diameter;sigtran;
`
	if err := os.WriteFile(desktopFile, []byte(content), 0644); err != nil {
		t.Fatal(err)
	}

	// Search for 'sigtran'
	results, err := SearchTools("sigtran", []string{tmpDir})
	if err != nil {
		t.Fatalf("SearchTools failed: %v", err)
	}
	if len(results) != 1 {
		t.Fatalf("expected 1 result, got %d", len(results))
	}
	if results[0].Name != "SCTP Scanner" {
		t.Errorf("expected 'SCTP Scanner', got %s", results[0].Name)
	}

	// Print results test
	var buf bytes.Buffer
	PrintResults(&buf, "sigtran", results)
	out := buf.String()
	if !strings.Contains(out, "SCTP Scanner") {
		t.Errorf("PrintResults missing tool name: %s", out)
	}
}
