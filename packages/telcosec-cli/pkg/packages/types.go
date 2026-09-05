package packages

import "strings"

// Metapackage defines the metadata for a modular TelcoChisel Debian metapackage.
type Metapackage struct {
	Name        string   `json:"name"`
	Alias       string   `json:"alias"`
	AltAliases  []string `json:"alt_aliases,omitempty"`
	Category    string   `json:"category"`
	Description string   `json:"description"`
	Tools       []string `json:"tools"`
}

// CanonicalRegistry contains all 10 official TelcoChisel telecom metapackages.
var CanonicalRegistry = []Metapackage{
	{
		Name:        "telcochisel-base",
		Alias:       "base",
		AltAliases:  []string{"core"},
		Category:    "Base System & Telecom Core",
		Description: "Core OS kernel latency tuning, PAM limits, SCTP stack & curated telecom wordlists",
		Tools: []string{
			"Low-latency RT scheduling limits (limits.d/99-realtime.conf)",
			"SCTP kernel module autoloading & buffer tuning (sysctl 64MB)",
			"Core CLI analysis utilities (tshark, Scapy, nmap, tcpdump, sctpscan)",
			"Curated telecommunications wordlists (/usr/share/wordlists/telecom)",
		},
	},
	{
		Name:        "telcochisel-hardware-sdr",
		Alias:       "hardware",
		AltAliases:  []string{"hw", "drivers"},
		Category:    "Hardware & SDR Drivers",
		Description: "SDR USB udev rules & FPGA bitstream loaders (BladeRF, USRP, Lime, Pluto, HackRF)",
		Tools: []string{
			"UHD & USRP USB 3.0/Ethernet driver libraries (libuhd, uhd-host)",
			"HackRF One host tools & CPLD firmware (hackrf_info, hackrf_transfer)",
			"BladeRF 2.0 micro FPGA bitstream loader & CLI (bladeRF-cli, libbladeRF)",
			"LimeSuite USB/PCIe transceiver driver (LimeUtil, SoapyLime)",
			"RTL-SDR dongle drivers & direct sampling (rtl_sdr, rtl_tcp, rtl_test)",
			"ADALM-Pluto IIO drivers (libiio, SoapyPlutoSDR)",
			"Non-root USB access rules (/etc/udev/rules.d/50-telcosec-hw.rules)",
		},
	},
	{
		Name:        "telcochisel-tools-sdr",
		Alias:       "sdr",
		AltAliases:  []string{"rf", "dsp"},
		Category:    "Radio Frequency & Satcom",
		Description: "RF signal analysis, DSP flowgraphs & Satcom suite (GNU Radio, Gqrx, URH, Inspectrum)",
		Tools: []string{
			"GNU Radio 3.10 companion & runtime environment",
			"Gqrx SDR receiver & spectrum waterfall",
			"Universal Radio Hacker (URH) wireless protocol reverse engineering",
			"Inspectrum spectral capture analyzer & FSK/OOK demodulator",
			"Gpredict real-time satellite tracking & Doppler compensation",
			"gr-gsm GSM air-interface capture blocks",
		},
	},
	{
		Name:        "telcochisel-tools-2g-3g",
		Alias:       "2g-3g",
		AltAliases:  []string{"gsm", "umts"},
		Category:    "Legacy Cellular Infrastructure",
		Description: "Cellular 2G/3G Osmocom infrastructure, YateBTS, OpenBTS & gr-gsm",
		Tools: []string{
			"Osmocom 2G stack (osmo-bts, osmo-bsc, osmo-msc, osmo-hlr)",
			"YateBTS SDR 2G GSM cellular basestation",
			"OpenBTS GSM software-defined radio stack",
			"Airprobe & gr-gsm cellular protocol dissection",
			"OsmocomBB mobile phone baseband firmware auditing",
		},
	},
	{
		Name:        "telcochisel-tools-4g",
		Alias:       "4g",
		AltAliases:  []string{"lte"},
		Category:    "4G LTE Security & eNodeB",
		Description: "4G LTE eNodeB/EPC simulation & protocol audit (srsRAN 4G, Open5GS, LTESniffer)",
		Tools: []string{
			"srsRAN 4G software eNodeB and User Equipment emulator",
			"Open5GS Evolved Packet Core (MME, SGW-C/U, PGW-C/U, HSS, PCRF)",
			"LTESniffer passive LTE uplink/downlink sniffer",
			"LTE-Cell-Scanner RF frequency and cell identifier discovery",
			"OpenAirInterface (OAI) 4G stack components",
		},
	},
	{
		Name:        "telcochisel-tools-5g",
		Alias:       "5g",
		AltAliases:  []string{"nr", "5g-sa", "5gsa"},
		Category:    "5G Standalone Core & RAN",
		Description: "5G SA Core (Open5GS), UERANSIM, mitmproxy (5G SBI) & 5Ghoul protocol fuzzer",
		Tools: []string{
			"Open5GS 5G Core Network (AMF, SMF, UPF, NRF, AUSF, UDM, UDR, PCF, NSSF, BSF)",
			"UERANSIM 5G NR UE & gNodeB software simulator",
			"5Ghoul 5G NR over-the-air exploitation & fuzzer engine",
			"mitmproxy HTTP/2 SBI (Service-Based Architecture) inspection proxies",
			"srsRAN Project gNodeB software radio framework",
		},
	},
	{
		Name:        "telcochisel-tools-sim",
		Alias:       "sim",
		AltAliases:  []string{"usim", "esim", "smartcard"},
		Category:    "SIM & Smartcard Auditing",
		Description: "SIM & eSIM auditing suite (pySim-shell, SIMtrace 2, lpac, SIMurai, OpenSC)",
		Tools: []string{
			"pySim-shell SIM card exploration and file system management",
			"Osmocom SIMtrace 2 smartcard APDU sniffing hardware host tools",
			"lpac C-based local profile assistant for eSIM / RSP management",
			"SIMurai SIM toolkit & proactive command simulator",
			"OpenSC smartcard PKCS#11/15 cryptographic token middleware",
			"pcsc-tools & pcscd smartcard reader daemon",
		},
	},
	{
		Name:        "telcochisel-tools-pstn-adsl",
		Alias:       "wireline",
		AltAliases:  []string{"pstn", "adsl", "voip"},
		Category:    "Wireline, VoIP & Telecom Broadband",
		Description: "Wireline broadband, QinQ, mausezahn, voiphopper, rtpbleed, sipsak, SIPp, DOCSIS",
		Tools: []string{
			"netsniff-ng / mausezahn hardware-rate packet crafter & generator",
			"VoIP Hopper automated VLAN hopping to VoIP infrastructure",
			"rtpbleed RTP proxy media stream information disclosure scanner",
			"sipsak SIP stress and diagnostic utility",
			"SIPp telecom traffic generator and benchmark tool",
			"docsis cable modem configuration file decoder and encoder",
		},
	},
	{
		Name:        "telcochisel-tools-ue",
		Alias:       "ue",
		AltAliases:  []string{"baseband", "modem"},
		Category:    "Mobile UE & Baseband Diagnostics",
		Description: "Mobile UE & baseband diagnostics (UERANSIM, SCAT, QCSuper, FirmWire, MTKClient)",
		Tools: []string{
			"SCAT cellular diagnostic and protocol logging tool",
			"QCSuper Qualcomm modem diagnostic protocol capture tool",
			"FirmWire baseband firmware emulation and fuzzing platform",
			"MTKClient MediaTek bootROM and preloader manipulation tool",
			"OsmocomBB mobile phone software baseband stack",
		},
	},
	{
		Name:        "telcochisel-meta-full",
		Alias:       "full",
		AltAliases:  []string{"all", "complete"},
		Category:    "Complete Umbrella Metapackage",
		Description: "Complete TelcoChisel telecom security distribution umbrella (88 tools)",
		Tools: []string{
			"All 10 domain metapackages installed concurrently",
			"All 88 telecom security and penetration testing utilities",
			"Offline local documentation and scenario training bundles",
		},
	},
}

// FindPackage resolves a query string (exact package name, alias, or alternate alias) to a Metapackage.
func FindPackage(query string) *Metapackage {
	q := strings.ToLower(strings.TrimSpace(query))
	if q == "" {
		return nil
	}

	for i := range CanonicalRegistry {
		pkg := &CanonicalRegistry[i]
		if strings.ToLower(pkg.Name) == q {
			return pkg
		}
		if strings.ToLower(pkg.Alias) == q {
			return pkg
		}
		for _, alt := range pkg.AltAliases {
			if strings.ToLower(alt) == q {
				return pkg
			}
		}
	}

	return nil
}
