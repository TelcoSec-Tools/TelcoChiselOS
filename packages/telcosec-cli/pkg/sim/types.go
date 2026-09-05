// Package sim provides smartcard, SIM, and eSIM hardware diagnostics,
// PC/SC reader enumeration, ISO/IEC 7816-3 Answer-to-Reset (ATR) decoding,
// Osmocom SIMtrace 2 APDU capture, and lpac eSIM profile management.
package sim

// ANSI color constants for terminal output
const (
	Bold    = "\033[1m"
	Cyan    = "\033[1;36m"
	Green   = "\033[1;32m"
	Yellow  = "\033[1;33m"
	Red     = "\033[1;31m"
	Dim     = "\033[2m"
	Reset   = "\033[0m"
)

// SmartcardReader represents an attached PC/SC or USB smartcard reader.
type SmartcardReader struct {
	Name        string `json:"name"`
	VendorID    string `json:"vendor_id,omitempty"`
	ProductID   string `json:"product_id,omitempty"`
	DevicePath  string `json:"device_path,omitempty"`
	CardPresent bool   `json:"card_present"`
	ATRHex      string `json:"atr_hex,omitempty"`
}

// ATRDecoded encapsulates parsed and interpreted ISO/IEC 7816-3 ATR parameters.
type ATRDecoded struct {
	RawHex               string          `json:"raw_hex"`
	TS                   string          `json:"ts"`
	Convention           string          `json:"convention"`
	T0                   string          `json:"t0"`
	HistoricalBytesCount int             `json:"historical_bytes_count"`
	Protocols            []string        `json:"protocols"`
	Fi                   int             `json:"fi"`
	FMaxMHz              float64         `json:"f_max_mhz"`
	Di                   float64         `json:"di"`
	WorkETUCycles        float64         `json:"work_etu_cycles"`
	GuardTimeN           int             `json:"guard_time_n"`
	InterfaceBytes       map[string]string `json:"interface_bytes"`
	HistoricalBytesHex   string          `json:"historical_bytes_hex"`
	HistoricalBytesASCII string          `json:"historical_bytes_ascii"`
	TelecomProfile       string          `json:"telecom_profile"`
	HasTCK               bool            `json:"has_tck"`
	TCK                  string          `json:"tck,omitempty"`
	ChecksumValid        bool            `json:"checksum_valid"`
}

// SIMtraceDevice represents an Osmocom SIMtrace 1 or SIMtrace 2 hardware sniffer.
type SIMtraceDevice struct {
	Path      string `json:"path"`
	VendorID  string `json:"vendor_id"`
	ProductID string `json:"product_id"`
	Model     string `json:"model"`
	Mode      string `json:"mode"`
}

// ESIMProfile represents an installed eSIM MNO profile retrieved from lpac.
type ESIMProfile struct {
	ICCID        string `json:"iccid"`
	ProfileName  string `json:"profile_name"`
	ProviderName string `json:"provider_name"`
	State        string `json:"state"` // Enabled, Disabled
}

// ESIMChipInfo represents the eUICC chip attributes and EID.
type ESIMChipInfo struct {
	EID         string `json:"eid"`
	DefaultSMDP string `json:"default_smdp,omitempty"`
	FreeMemory  string `json:"free_memory,omitempty"`
}

// KnownSmartcardReaders maps USB "vendor:product" hex IDs to reader models.
var KnownSmartcardReaders = map[string]string{
	"072f:90cc": "ACS ACR38U Smart Card Reader",
	"072f:2200": "ACS ACR39U Smart Card Reader",
	"072f:b100": "ACS ACR122U NFC Reader / Contactless",
	"058f:9540": "Alcor Micro AU9540 Smart Card Reader",
	"04e6:5116": "SCM Microsystems SCR3310 / SCR3310v2",
	"04e6:5411": "SCM Microsystems SCR331-DI Smart Card Reader",
	"08e6:3437": "Gemalto PC Twin Reader / IDBridge CT30",
	"08e6:3438": "Gemalto IDBridge CT40",
	"076b:3021": "HID OMNIKEY 3121 USB Smart Card Reader",
	"076b:3022": "HID OMNIKEY 3021 USB Smart Card Reader",
	"1d50:6025": "Osmocom SIMtrace v1 (Sniffer)",
	"1d50:60e3": "Osmocom SIMtrace 2 (APDU Sniffer & Card Emulator)",
	"10c4:ea60": "Silicon Labs CP210x SIM Programmer / Phoenix Adapter",
	"0403:6001": "FTDI FT232R Phoenix / Smartmouse SIM Programmer",
}
