package sim

import (
	"bytes"
	"encoding/json"
	"strings"
	"testing"
)

func TestDecodeATR_SysmoUSIMSJS1(t *testing.T) {
	// Official sysmoUSIM-SJS1 ATR (T=0 with T=15 global indicator)
	raw := "3B9F95801FC78031E073FE211B674A4C7380110043"

	atr, err := DecodeATR(raw)
	if err != nil {
		t.Fatalf("Failed to decode sysmoUSIM ATR: %v", err)
	}

	if !strings.Contains(atr.Convention, "Direct") {
		t.Errorf("Expected Direct convention, got: %s", atr.Convention)
	}

	if !atr.ChecksumValid {
		t.Errorf("Expected ATR checksum to be valid per ISO 7816-3")
	}

	if !strings.Contains(atr.TelecomProfile, "sysmoUSIM") {
		t.Errorf("Expected sysmoUSIM profile, got: %s", atr.TelecomProfile)
	}

	if atr.HistoricalBytesCount != 15 {
		t.Errorf("Expected 15 historical bytes, got: %d", atr.HistoricalBytesCount)
	}

	if atr.Fi != 512 {
		t.Errorf("Expected Fi=512 for code 9, got: %d", atr.Fi)
	}

	if atr.Di != 16.0 {
		t.Errorf("Expected Di=16.0 for code 5, got: %f", atr.Di)
	}
}

func TestDecodeATR_3GPPUICC(t *testing.T) {
	// Standard 3GPP TS 31.102 USIM UICC with valid TCK (0xA4)
	raw := "3B 7F 96 00 00 80 31 80 65 B0 85 02 01 20 12 0F 00 82 90 00 A4"

	atr, err := DecodeATR(raw)
	if err != nil {
		t.Fatalf("Failed to decode 3GPP UICC ATR: %v", err)
	}

	if !atr.ChecksumValid {
		t.Errorf("Expected valid ATR checksum")
	}

	if !strings.Contains(atr.TelecomProfile, "3GPP") && !strings.Contains(atr.TelecomProfile, "UICC") {
		t.Errorf("Expected 3GPP/UICC telecom profile, got: %s", atr.TelecomProfile)
	}
}

func TestDecodeATR_T1WithValidTCK(t *testing.T) {
	// T=1 protocol card with mandatory TCK checksum (XOR sum == 0)
	raw := "3BB011810121"

	atr, err := DecodeATR(raw)
	if err != nil {
		t.Fatalf("Failed to decode T=1 ATR: %v", err)
	}

	if !atr.HasTCK {
		t.Errorf("Expected TCK to be detected for T=1")
	}

	if atr.TCK != "0x21" {
		t.Errorf("Expected TCK 0x21, got: %s", atr.TCK)
	}

	if !atr.ChecksumValid {
		t.Errorf("Expected ChecksumValid == true for valid T=1 TCK")
	}
}

func TestDecodeATR_InverseConvention(t *testing.T) {
	// Inverse convention card with TS=0x3F
	raw := "3F 67 25 00 21 20 00 0F 68 90 00"

	atr, err := DecodeATR(raw)
	if err != nil {
		t.Fatalf("Failed to decode inverse convention ATR: %v", err)
	}

	if !strings.Contains(atr.Convention, "Inverse") {
		t.Errorf("Expected Inverse convention, got: %s", atr.Convention)
	}
}

func TestDecodeATR_InvalidInputs(t *testing.T) {
	// 1. Too short
	if _, err := DecodeATR("3B"); err == nil {
		t.Errorf("Expected error for 1-byte ATR, got nil")
	}

	// 2. Invalid TS
	if _, err := DecodeATR("1234"); err == nil {
		t.Errorf("Expected error for invalid TS byte, got nil")
	}

	// 3. Corrupted TCK (T=1 card ending in 0x99 instead of 0x21)
	corruptRaw := "3BB011810199"
	atr, err := DecodeATR(corruptRaw)
	if err != nil {
		t.Fatalf("Unexpected decode error on corrupt TCK: %v", err)
	}
	if atr.ChecksumValid {
		t.Errorf("Expected ChecksumValid == false on corrupt TCK")
	}

	// 4. Invalid hex chars
	if _, err := DecodeATR("3BZZFF"); err == nil {
		t.Errorf("Expected error on invalid hex characters")
	}
}

func TestPrintATR_TableAndJSON(t *testing.T) {
	raw := "3B9F95801FC78031E073FE211B674A4C7380110043"
	atr, err := DecodeATR(raw)
	if err != nil {
		t.Fatalf("Decode failed: %v", err)
	}

	// 1. Text table
	var bufTable bytes.Buffer
	if err := PrintATR(&bufTable, atr, false); err != nil {
		t.Fatalf("PrintATR table error: %v", err)
	}
	if !strings.Contains(bufTable.String(), "sysmoUSIM") {
		t.Errorf("Expected table to mention sysmoUSIM")
	}

	// 2. JSON
	var bufJSON bytes.Buffer
	if err := PrintATR(&bufJSON, atr, true); err != nil {
		t.Fatalf("PrintATR JSON error: %v", err)
	}
	var out ATRDecoded
	if err := json.Unmarshal(bufJSON.Bytes(), &out); err != nil {
		t.Fatalf("Failed to parse JSON output: %v", err)
	}
	if out.RawHex != strings.ToUpper(raw) {
		t.Errorf("Expected %s, got %s", raw, out.RawHex)
	}
}

func TestHardwareRegistry(t *testing.T) {
	expected := []string{
		"072f:90cc",
		"072f:2200",
		"1d50:60e3",
		"08e6:3437",
		"076b:3021",
	}
	for _, id := range expected {
		if _, ok := KnownSmartcardReaders[id]; !ok {
			t.Errorf("Missing expected hardware device in KnownSmartcardReaders: %s", id)
		}
	}
}

func TestEnvironmentStatus(t *testing.T) {
	env := GetEnvironmentStatus()
	if env == nil {
		t.Fatalf("Expected non-nil EnvironmentStatus")
	}
	if len(env.Tools) == 0 {
		t.Errorf("Expected non-empty tools list")
	}

	var buf bytes.Buffer
	if err := PrintEnvironmentStatus(&buf, false); err != nil {
		t.Fatalf("PrintEnvironmentStatus failed: %v", err)
	}
	if !strings.Contains(buf.String(), "Smartcard") {
		t.Errorf("Expected header in output")
	}
}
