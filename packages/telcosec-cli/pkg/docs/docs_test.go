package docs

import (
	"bytes"
	"strings"
	"testing"
)

func TestOpenDocs(t *testing.T) {
	var buf bytes.Buffer
	OpenDocs(&buf)
	out := buf.String()

	if !strings.Contains(out, "=== TelcoChisel Interactive Documentation ===") {
		t.Errorf("OpenDocs missing header: %s", out)
	}

	if !strings.Contains(out, "documentation:") {
		t.Errorf("OpenDocs missing documentation path/url: %s", out)
	}
}

func TestOpenAcademy(t *testing.T) {
	var buf bytes.Buffer
	OpenAcademy(&buf)
	out := buf.String()

	if !strings.Contains(out, "=== TelcoSec Academy -- Hands-On Telecom Security Labs ===") {
		t.Errorf("OpenAcademy missing header: %s", out)
	}

	if !strings.Contains(out, "https://app.telcosec.net") {
		t.Errorf("OpenAcademy missing academy URL: %s", out)
	}
}

func TestOpenFeedback(t *testing.T) {
	var buf bytes.Buffer
	OpenFeedback(&buf)
	out := buf.String()

	if !strings.Contains(out, "=== Community Support & SourceForge Reviews ===") {
		t.Errorf("OpenFeedback missing header: %s", out)
	}

	if !strings.Contains(out, "SourceForge") {
		t.Errorf("OpenFeedback missing SourceForge mention: %s", out)
	}
}
