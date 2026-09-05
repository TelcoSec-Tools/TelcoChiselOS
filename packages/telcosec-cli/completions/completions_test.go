package completions

import (
	"bytes"
	"strings"
	"testing"
)

func TestGenerateCompletion(t *testing.T) {
	tests := []struct {
		shell       string
		expectSub   string
		expectError bool
	}{
		{"bash", "complete -F _telcosec", false},
		{"BASH", "complete -F _telcosec", false},
		{"zsh", "#compdef telcosec telcochisel", false},
		{"fish", "complete -c telcosec", false},
		{"powershell", "", true},
		{"unknown", "", true},
	}

	for _, tt := range tests {
		var buf bytes.Buffer
		err := GenerateCompletion(tt.shell, &buf)

		if tt.expectError {
			if err == nil {
				t.Errorf("expected error for shell %s, got nil", tt.shell)
			}
		} else {
			if err != nil {
				t.Errorf("unexpected error for shell %s: %v", tt.shell, err)
			}
			out := buf.String()
			if !strings.Contains(out, tt.expectSub) {
				t.Errorf("shell %s output missing expected string '%s'", tt.shell, tt.expectSub)
			}
		}
	}
}
