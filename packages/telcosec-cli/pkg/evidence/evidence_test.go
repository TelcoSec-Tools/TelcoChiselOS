package evidence

import (
	"bytes"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestCreateEvidenceBundle(t *testing.T) {
	tempDir, err := os.MkdirTemp("", "telcosec-evidence-test")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	// Create a dummy pcap
	dummyPcap := filepath.Join(tempDir, "test.pcap")
	if err := os.WriteFile(dummyPcap, []byte("DUMMY_PCAP_DATA"), 0644); err != nil {
		t.Fatalf("Failed to write dummy pcap: %v", err)
	}

	buf := new(bytes.Buffer)
	res, err := CreateEvidenceBundle(buf, BundleConfig{
		OutputDir:   tempDir,
		IncludePCAP: false,
		IncludeLogs: false,
		Label:       "testrun",
	})

	if err != nil {
		t.Fatalf("CreateEvidenceBundle failed: %v", err)
	}

	if res.FileCount < 1 {
		t.Errorf("Expected at least manifest file, got count: %d", res.FileCount)
	}

	if res.SHA256 == "" || len(res.SHA256) != 64 {
		t.Errorf("Expected valid 64-char hex SHA256, got: %s", res.SHA256)
	}

	out := buf.String()
	if !strings.Contains(out, "Evidence Bundle Successfully Created") {
		t.Errorf("Expected success banner in output, got:\n%s", out)
	}
}
