package sim

import (
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"strings"
)

// DecodeATR parses a raw hex string representing an ISO/IEC 7816-3 Answer-to-Reset.
func DecodeATR(rawHex string) (*ATRDecoded, error) {
	// Clean string: remove 0x prefix, spaces, colons, tabs, newlines
	clean := strings.TrimSpace(rawHex)
	clean = strings.TrimPrefix(clean, "0x")
	clean = strings.TrimPrefix(clean, "0X")
	clean = strings.ReplaceAll(clean, " ", "")
	clean = strings.ReplaceAll(clean, ":", "")
	clean = strings.ReplaceAll(clean, "-", "")

	data, err := hex.DecodeString(clean)
	if err != nil {
		return nil, fmt.Errorf("invalid ATR hex format: %w", err)
	}

	if len(data) < 2 {
		return nil, fmt.Errorf("ATR too short (length %d bytes, minimum is 2)", len(data))
	}
	if len(data) > 33 {
		return nil, fmt.Errorf("ATR exceeds ISO 7816-3 maximum length of 33 bytes (got %d)", len(data))
	}

	res := &ATRDecoded{
		RawHex:         strings.ToUpper(hex.EncodeToString(data)),
		InterfaceBytes: make(map[string]string),
		Protocols:      []string{},
		Fi:             372,
		FMaxMHz:        4.0,
		Di:             1.0,
		WorkETUCycles:  372.0,
		GuardTimeN:     0,
	}

	// 1. Initial Character TS
	ts := data[0]
	res.TS = fmt.Sprintf("0x%02X", ts)
	if ts == 0x3B {
		res.Convention = "Direct Convention (0x3B, LSB first, High=1)"
	} else if ts == 0x3F {
		res.Convention = "Inverse Convention (0x3F, MSB first, Low=1)"
	} else {
		return nil, fmt.Errorf("invalid initial byte TS 0x%02X (must be 0x3B or 0x3F)", ts)
	}

	// 2. Format Byte T0
	t0 := data[1]
	res.T0 = fmt.Sprintf("0x%02X", t0)
	y := (t0 >> 4) & 0x0F
	k := int(t0 & 0x0F)
	res.HistoricalBytesCount = k

	// Transmission protocols (T=0, T=1, etc. excluding T=15 which indicates global bytes)
	hasTransmissionProtocol := false
	protocolSet := make(map[string]bool)
	hasNonT0Protocol := false

	idx := 2
	round := 1

	for y != 0 && idx < len(data) {
		// TA(round)
		if (y & 0x01) != 0 {
			if idx >= len(data) {
				break
			}
			val := data[idx]
			tag := fmt.Sprintf("TA%d", round)
			res.InterfaceBytes[tag] = fmt.Sprintf("0x%02X", val)
			idx++

			if round == 1 {
				// Clock rate Fi & Baud rate adjustment Di
				fiCode := (val >> 4) & 0x0F
				diCode := val & 0x0F
				res.Fi, res.FMaxMHz = lookupFi(fiCode)
				res.Di = lookupDi(diCode)
				if res.Di > 0 {
					res.WorkETUCycles = float64(res.Fi) / res.Di
				}
			}
		}

		// TB(round)
		if (y & 0x02) != 0 {
			if idx >= len(data) {
				break
			}
			val := data[idx]
			tag := fmt.Sprintf("TB%d", round)
			res.InterfaceBytes[tag] = fmt.Sprintf("0x%02X", val)
			idx++
		}

		// TC(round)
		if (y & 0x04) != 0 {
			if idx >= len(data) {
				break
			}
			val := data[idx]
			tag := fmt.Sprintf("TC%d", round)
			res.InterfaceBytes[tag] = fmt.Sprintf("0x%02X", val)
			idx++

			if round == 1 {
				res.GuardTimeN = int(val)
			}
		}

		// TD(round)
		if (y & 0x08) != 0 {
			if idx >= len(data) {
				break
			}
			val := data[idx]
			tag := fmt.Sprintf("TD%d", round)
			res.InterfaceBytes[tag] = fmt.Sprintf("0x%02X", val)
			idx++

			proto := val & 0x0F
			if proto != 15 {
				pName := fmt.Sprintf("T=%d", proto)
				protocolSet[pName] = true
				hasTransmissionProtocol = true
				if proto != 0 {
					hasNonT0Protocol = true
				}
			}

			y = (val >> 4) & 0x0F
			round++
		} else {
			y = 0
		}
	}

	if !hasTransmissionProtocol {
		protocolSet["T=0"] = true
	}
	for p := range protocolSet {
		res.Protocols = append(res.Protocols, p)
	}

	// Historical Bytes
	if idx+k <= len(data) {
		hist := data[idx : idx+k]
		res.HistoricalBytesHex = strings.ToUpper(hex.EncodeToString(hist))
		var ascii strings.Builder
		for _, b := range hist {
			if b >= 32 && b <= 126 {
				ascii.WriteByte(b)
			} else {
				ascii.WriteByte('.')
			}
		}
		res.HistoricalBytesASCII = ascii.String()
		idx += k
	}

	// Check byte TCK
	// ISO/IEC 7816-3 Section 8.2.5:
	// "TCK is present if and only if any protocol other than T=0 is indicated in TD1, TD2, ...
	// except T=15 which does not indicate a protocol."
	if idx < len(data) {
		res.HasTCK = true
		tck := data[idx]
		res.TCK = fmt.Sprintf("0x%02X", tck)

		// Verification: XOR sum of all bytes from T0 (index 1) to TCK (index idx) must equal 0x00
		var xorSum byte = 0
		for i := 1; i <= idx; i++ {
			xorSum ^= data[i]
		}
		res.ChecksumValid = (xorSum == 0)
	} else if hasNonT0Protocol {
		// Required but missing from data
		res.HasTCK = false
		res.ChecksumValid = false
	} else {
		// Pure T=0 without TCK is standard and valid
		res.HasTCK = false
		res.ChecksumValid = true
	}

	// Detect Telecom Profile
	res.TelecomProfile = classifyTelecomProfile(res)

	return res, nil
}

func lookupFi(code byte) (int, float64) {
	switch code {
	case 0:
		return 372, 4.0 // Internal clock
	case 1:
		return 372, 4.0
	case 2:
		return 512, 5.0
	case 3:
		return 744, 6.0
	case 4:
		return 1116, 8.0
	case 5:
		return 1488, 12.0
	case 6:
		return 1860, 16.0
	case 9:
		return 512, 5.0
	case 10:
		return 744, 7.5
	case 11:
		return 1116, 10.0
	case 12:
		return 1488, 15.0
	case 13:
		return 1860, 20.0
	default:
		return 372, 4.0
	}
}

func lookupDi(code byte) float64 {
	switch code {
	case 1:
		return 1.0
	case 2:
		return 2.0
	case 3:
		return 4.0
	case 4:
		return 8.0
	case 5:
		return 16.0
	case 6:
		return 32.0
	case 7:
		return 64.0
	case 8:
		return 12.0
	case 9:
		return 20.0
	default:
		return 1.0
	}
}

func classifyTelecomProfile(atr *ATRDecoded) string {
	raw := strings.ToUpper(atr.RawHex)
	histHex := strings.ToUpper(atr.HistoricalBytesHex)
	histASCII := strings.ToUpper(atr.HistoricalBytesASCII)

	// sysmoUSIM-SJS1 / sysmoSIM signatures
	if strings.Contains(raw, "3B9F95801FC78031E073FE211B674A4C7380110043") ||
		strings.Contains(raw, "3B9F96801FC78031E073FE211B674A4C7380110042") ||
		strings.Contains(histASCII, "SYSMO") {
		return "sysmoUSIM-SJS1 LTE/5G Multi-Profile Test SIM (Sysmocom)"
	}

	// 3GPP TS 31.102 USIM / ETSI TS 102 221 UICC (Category indicator 0x80, Tag 0x31)
	if strings.HasPrefix(histHex, "8031") || strings.Contains(histHex, "8031E0") || strings.Contains(histHex, "801FC7") {
		return "3GPP TS 31.102 4G LTE/5G NR UICC (USIM + ISIM Applications)"
	}

	// GSM Phase 2+ SIM (Category 0x80, Tag 0x25 or 0x8025)
	if strings.HasPrefix(histHex, "8025") || strings.Contains(histHex, "8025") {
		return "2G/3G GSM Phase 2+ SIM (GSM 11.11 / ETSI TS 100 977)"
	}

	// Well-known vendor identifiers in historical bytes
	if strings.Contains(histASCII, "G&D") || strings.Contains(histASCII, "GIESECKE") {
		return "Giesecke+Devrient (G&D) Telecom Smartcard / eSIM"
	}
	if strings.Contains(histASCII, "GEMALTO") || strings.Contains(histASCII, "THALES") {
		return "Thales / Gemalto Upteq Multi-Megabyte Telecom UICC"
	}
	if strings.Contains(histASCII, "OBERTHUR") || strings.Contains(histASCII, "IDEMIA") {
		return "IDEMIA / Oberthur Technologies Telecom SIM"
	}

	// Check protocol support
	if len(atr.Protocols) > 0 {
		return fmt.Sprintf("ISO/IEC 7816-3 Smartcard (%s)", strings.Join(atr.Protocols, ", "))
	}

	return "Standard ISO/IEC 7816 Smartcard"
}

// PrintATR prints the formatted ATR analysis to the provided writer.
func PrintATR(w io.Writer, atr *ATRDecoded, jsonOutput bool) error {
	if jsonOutput {
		enc := json.NewEncoder(w)
		enc.SetIndent("", "  ")
		return enc.Encode(atr)
	}

	fmt.Fprintf(w, "%s=== ISO/IEC 7816-3 Answer-to-Reset (ATR) Analysis ===%s\n\n", Bold, Reset)
	fmt.Fprintf(w, "  Raw ATR Hex        : %s%s%s\n", Bold, atr.RawHex, Reset)
	fmt.Fprintf(w, "  Convention         : %s%s%s\n", Green, atr.Convention, Reset)
	fmt.Fprintf(w, "  Telecom Profile    : %s%s%s\n", Cyan, atr.TelecomProfile, Reset)
	fmt.Fprintf(w, "  Supported Protocol : %s%s%s\n", Yellow, strings.Join(atr.Protocols, ", "), Reset)

	fmt.Fprintf(w, "\n%s--- Transmission Parameters & Clock Conversion ---%s\n", Bold, Reset)
	fmt.Fprintf(w, "  Clock Factor (Fi)  : %d (Max Frequency: %.1f MHz)\n", atr.Fi, atr.FMaxMHz)
	fmt.Fprintf(w, "  Baud Factor (Di)   : %.1f\n", atr.Di)
	fmt.Fprintf(w, "  Work ETU           : %.2f clock cycles\n", atr.WorkETUCycles)
	if atr.GuardTimeN == 255 {
		fmt.Fprintf(w, "  Extra Guard Time   : 0 (Minimum 12 ETU)\n")
	} else {
		fmt.Fprintf(w, "  Extra Guard Time   : %d ETU\n", atr.GuardTimeN)
	}

	if len(atr.InterfaceBytes) > 0 {
		fmt.Fprintf(w, "\n%s--- Interface Characters ---%s\n", Bold, Reset)
		for _, k := range []string{"TA1", "TB1", "TC1", "TD1", "TA2", "TB2", "TC2", "TD2", "TA3", "TB3", "TC3", "TD3"} {
			if v, ok := atr.InterfaceBytes[k]; ok {
				fmt.Fprintf(w, "  %-4s : %s\n", k, v)
			}
		}
	}

	fmt.Fprintf(w, "\n%s--- Historical Bytes (%d bytes) ---%s\n", Bold, atr.HistoricalBytesCount, Reset)
	if atr.HistoricalBytesCount > 0 {
		fmt.Fprintf(w, "  Hex   : %s%s%s\n", Yellow, atr.HistoricalBytesHex, Reset)
		fmt.Fprintf(w, "  ASCII : %s\n", atr.HistoricalBytesASCII)
	} else {
		fmt.Fprintf(w, "  None present.\n")
	}

	fmt.Fprintf(w, "\n%s--- Integrity & Checksum ---%s\n", Bold, Reset)
	if atr.HasTCK {
		if atr.ChecksumValid {
			fmt.Fprintf(w, "  Check Byte (TCK)   : %s (Status: %sVALID%s)\n", atr.TCK, Green, Reset)
		} else {
			fmt.Fprintf(w, "  Check Byte (TCK)   : %s (Status: %sCORRUPT / INVALID%s)\n", atr.TCK, Red, Reset)
		}
	} else {
		fmt.Fprintf(w, "  Check Byte (TCK)   : Not required for pure T=0 protocol (Valid per ISO 7816-3)\n")
	}
	fmt.Fprintln(w)

	return nil
}
