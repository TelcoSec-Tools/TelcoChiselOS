package cellular

import (
	"bytes"
	"strings"
	"testing"
)

func TestOpen5GSServices(t *testing.T) {
	if len(Open5GSServices) != 11 {
		t.Errorf("expected 11 Open5GS services, got %d", len(Open5GSServices))
	}

	expectedServices := map[string]bool{
		"open5gs-amfd": false,
		"open5gs-upfd": false,
		"open5gs-smfd": false,
		"open5gs-nrfd": false,
	}

	for _, s := range Open5GSServices {
		if _, ok := expectedServices[s]; ok {
			expectedServices[s] = true
		}
	}

	for k, found := range expectedServices {
		if !found {
			t.Errorf("expected %s in Open5GSServices list", k)
		}
	}
}

func TestAddSubscriberValidation(t *testing.T) {
	var buf bytes.Buffer
	// When open5gs-dbctl is not found on dev host, should gracefully report error
	err := AddSubscriber(&buf, "001010000000001", "00112233445566778899AABBCCDDEEFF", "00112233445566778899AABBCCDDEEFF")
	out := buf.String()

	if !strings.Contains(out, "=== Provisioning 5G Test Subscriber ===") {
		t.Errorf("missing header: %s", out)
	}

	if err != nil && !strings.Contains(out, "open5gs-dbctl") {
		t.Errorf("expected open5gs-dbctl error message: %s", out)
	}
}
