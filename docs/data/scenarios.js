export const scenariosCatalog = [
  {
    id: "scenario-5g-core-stress",
    slug: "5g-core-stress-and-fuzzing",
    title: "5G Standalone Core Resilience & Multi-UE Stress Testing",
    category: "5g",
    badge: "5G Core / Cloud-Native",
    summary: "Audit 5G Standalone Core Network functions (AMF, SMF, UPF) against high-concurrency registration storms, state exhaustion, and NAS protocol fuzzing.",
    objective: "Evaluate AMF and SMF resilience against synthetic UE connection surges, identify state exhaustion conditions in the N2 NGAP interface, and audit GTP-U data-plane encapsulation handling under heavy load.",
    threatModel: "Rogue or compromised IoT/CPE devices initiating synchronized mass-registration storms to degrade or deny service across the 5G Core control plane.",
    interfaces: ["N1 (NAS-MM / NAS-SM)", "N2 (NGAP over SCTP)", "N3 (GTP-U data plane)"],
    tools: ["my5G-RANTester", "UERANSIM", "Open5GS", "Wireshark", "TShark"],
    academyLab: {
      name: "5G SA Core Load & DoS Simulation Testbed",
      desc: "Deploy an isolated 5G Core cloud container with Open5GS AMF/UPF, synthetic UERANSIM UEs, and live signaling dissectors on app.telcosec.net."
    },
    methodology: [
      "Deploy or attach to an isolated 5G SA testbed (e.g. Open5GS or commercial core) configured with test PLMN 001-01.",
      "Initialize baseline control plane capture using TShark filtering on sctp and ngap protocols.",
      "Launch progressive multi-UE registration tests with my5G-RANTester, incrementing from 50 to 500 concurrent synthetic UEs.",
      "Evaluate PDU Session Establishment latency, AMF authentication reject rates, and UPF throughput.",
      "Analyze captured PCAP for SCTP chunk retransmissions, NGAP Error Indication messages, and abnormal NAS rejects."
    ],
    commands: [
      {
        desc: "Monitor live 5G NGAP/NAS signaling on N2 interface",
        cmd: "tshark -i any -f 'sctp port 38412' -Y 'ngap' -V"
      },
      {
        desc: "Execute 100-UE registration and PDU session storm",
        cmd: "my5g-rantester load-test -n 100 -d 30"
      },
      {
        desc: "Inspect active UPF tunnel status and throughput",
        cmd: "ip -s link show dev ueransim0 2>/dev/null || ip link show upf0"
      }
    ],
    diagram: `sequenceDiagram
    autonumber
    actor RedTeam as Red Team Operator
    participant Tester as my5G-RANTester / UERANSIM
    participant AMF as 5G Core AMF (SCTP:38412)
    participant SMF as 5G Core SMF / UPF

    RedTeam->>Tester: Launch Mass Registration (-n 100)
    Tester->>AMF: Initial UE Message (NGAP + NAS Registration Request)
    AMF->>Tester: Authentication Request (5G-AKA / EAP-AKA')
    Tester->>AMF: Authentication Response (RES*)
    AMF->>Tester: Security Mode Command (NAS Integrity & Ciphering)
    Tester->>AMF: Security Mode Complete
    AMF->>Tester: Registration Accept (5G-GUTI assigned)
    Tester->>SMF: PDU Session Establishment Request (N1/N2)
    SMF-->>Tester: PDU Session Resource Setup (GTP-U TEID assigned)
    Tester->>RedTeam: Measure Latency, Success Rate, & Core Metrics`
  },
  {
    id: "scenario-ota-rf-recon",
    slug: "cellular-rf-reconnaissance",
    title: "Over-the-Air Cellular RF Reconnaissance & Broadcast Auditing",
    category: "rf",
    badge: "Over-the-Air RF / Physical",
    summary: "Perform passive cellular spectrum discovery, decode System Information Blocks (SIB/MIB), map carrier frequencies, and audit broadcast parameters without transmitting.",
    objective: "Identify active 2G, 4G, and 5G cellular carriers in the operational vicinity, extract public broadcast parameters (PLMN, TAC, Cell ID, neighbor cell lists), and verify radio signal integrity without emitting RF.",
    threatModel: "Adversaries gathering target network topology, carrier aggregation bands, and cell identity parameters to plan focused rogue base station or spoofing attacks.",
    interfaces: ["Air Interface (Uu) Downlink", "Broadcast Control Channel (BCCH)", "Physical Downlink Shared Channel (PDSCH)"],
    tools: ["LTESniffer", "LTE-CellScanner", "Modmobmap", "kalibrate-gsm", "Gqrx"],
    academyLab: {
      name: "Virtual SDR Spectrum Analysis & SIB Decoding Lab",
      desc: "Stream high-rate 5G NR and LTE IQ sample captures, decode MIB/SIB broadcast blocks, and practice RF recon in a browser sandbox on app.telcosec.net."
    },
    methodology: [
      "Connect SDR transceiver (Ettus USRP, BladeRF, or HackRF One) and verify clock stability and gain settings.",
      "Scan GSM bands with kal-gsm to calculate local oscillator frequency offsets and establish reference ppm.",
      "Execute wideband LTE spectrum scanning with LTE-CellSearch to identify active EARFCNs, Physical Cell IDs (PCIs), and RSSI levels.",
      "Attach LTESniffer to the strongest detected carrier to capture and decode Downlink Control Information (DCI) and System Information Blocks (SIB1, SIB2).",
      "Correlate mapped cells against AT command telemetry from an active modem using Modmobmap."
    ],
    commands: [
      {
        desc: "Calibrate frequency offset using GSM broadcast carriers",
        cmd: "kal-gsm -s GSM900 -g 40"
      },
      {
        desc: "Scan local LTE bands and extract PCIs and EARFCNs",
        cmd: "LTE-CellSearch --freq-start 1805e6 --freq-end 1880e6"
      },
      {
        desc: "Passively sniff Downlink LTE control traffic into PCAP",
        cmd: "ltesniffer -A 1 -f 1842.5e6 -g 35 -o /tmp/lte_recon.pcap"
      }
    ],
    diagram: `flowchart LR
    SDR[SDR Antenna / Transceiver] --> Scanner[LTE-CellScanner / kal-gsm]
    Scanner --> |Carrier Detected: EARFCN, PCI| Sniffer[LTESniffer Engine]
    Sniffer --> |Decoded MIB / SIB| Wireshark[Wireshark GSMTAP Display]
    Sniffer --> |DCI / RNTI Mapping| Out[(Capture PCAP)]
    Wireshark --> Analyst[Red Team Assessment Report]`
  },
  {
    id: "scenario-rogue-bts-lab",
    slug: "rogue-base-station-simulation",
    title: "Rogue Base Station & Downgrade Attack Simulation (Isolated Lab)",
    category: "4g",
    badge: "Cellular Lab Simulation",
    summary: "Simulate rogue base station and cell reselection vectors in an isolated RF enclosure to evaluate mobile handset cipher suite negotiation and fallback security.",
    objective: "Assess handset behavior when exposed to a higher-priority rogue cell candidate, evaluate 4G-to-2G downgrade resistance, and verify whether the UE alerts the user to NULL ciphering (EEA0 / GEA0).",
    threatModel: "IMSI catchers or rogue cell devices attempting to coerce victim handsets into unencrypted legacy protocols (GSM A5/0 or LTE EEA0) to intercept voice, SMS, or metadata.",
    interfaces: ["LTE Uu (RRC / NAS)", "GSM Um (LAPDm / Layer 3)", "S1-MME (S1AP)"],
    tools: ["srsRAN", "Open5GS", "YateBTS", "Wireshark", "srsUE"],
    academyLab: {
      name: "Isolated Rogue eNodeB & Downgrade Attack Sandbox",
      desc: "Simulate cellular reselection vectors, cleartext IMSI extraction, and NULL-ciphering downgrade scenarios in a safe virtual testbed on app.telcosec.net."
    },
    methodology: [
      "Operate exclusively inside an approved RF Faraday cage or via direct coaxial cabling with 30dB attenuators.",
      "Configure srsRAN eNodeB with ITU-T test PLMN (MCC 001, MNC 01) and advertise priority reselection parameters in SIB3.",
      "Monitor handset RRC Connection Request and NAS Identity Request exchange in Wireshark via GSMTAP.",
      "Simulate ciphering rejection or null-cipher fallback to assess whether the device accepts unauthenticated signaling.",
      "Verify whether the target device implements SUCI / 5G SA null-scheme protections against identity extraction."
    ],
    commands: [
      {
        desc: "Launch isolated Open5GS core network services",
        cmd: "sudo open5gs-start"
      },
      {
        desc: "Start srsRAN eNodeB with BladeRF or USRP in test PLMN",
        cmd: "sudo srsenb /etc/srsran/enb.conf"
      },
      {
        desc: "Capture live GSMTAP air interface signaling frames",
        cmd: "tshark -i lo -f 'udp port 4729' -Y 'gsm_a || lte_rrc'"
      }
    ],
    diagram: `sequenceDiagram
    autonumber
    participant UE as Target Test Handset (in Faraday Cage)
    participant Rogue as Rogue eNodeB (srsRAN / BladeRF)
    participant Core as Open5GS Core Network

    UE->>Rogue: RRC Connection Request (EstablishmentCause: mo-Signalling)
    Rogue->>UE: RRC Connection Setup
    UE->>Rogue: RRC Setup Complete + NAS Attach Request
    Rogue->>Core: S1AP Initial UE Message
    Core->>Rogue: S1AP Downlink NAS (Identity Request)
    Rogue->>UE: NAS Identity Request (Request IMSI)
    UE-->>Rogue: NAS Identity Response (Cleartext IMSI / SUCI Check)
    Note over Rogue,UE: Evaluate Handset Downgrade & NULL Cipher Tolerance`
  },
  {
    id: "scenario-baseband-reverse-engineering",
    slug: "baseband-firmware-and-diag-analysis",
    title: "Baseband Diagnostic Extraction & Firmware Reverse Engineering",
    category: "baseband",
    badge: "Firmware & Diagnostic Port",
    summary: "Extract real-time cellular signaling telemetry over USB diagnostic interfaces and emulate baseband task architectures inside virtual execution environments.",
    objective: "Capture low-level layer 1/2/3 modem logging data over Qualcomm DIAG or MediaTek serial interfaces, extract proprietary protocol telemetry, and perform fuzzing against baseband RTOS tasks.",
    threatModel: "Vulnerabilities in commercial baseband firmware allowing remote code execution via malformed over-the-air signaling frames prior to OS-level authentication.",
    interfaces: ["Qualcomm DIAG (/dev/ttyUSB*)", "MediaTek BROM / PreLoader", "Samsung Shannon Modem Trace"],
    tools: ["QCSuper", "SCAT", "FirmWire", "MTKClient", "Wireshark"],
    academyLab: {
      name: "FirmWire Baseband Firmware Emulation Lab",
      desc: "Fuzz QEMU-emulated Samsung Shannon & MediaTek modem RTOS tasks and capture low-level DIAG telemetry on app.telcosec.net."
    },
    methodology: [
      "Connect a Qualcomm- or MediaTek-based research test device in diagnostic mode via USB.",
      "Verify port detection and driver arbitration under unprivileged dialout / plugdev groups.",
      "Spawn QCSuper or SCAT to establish a diagnostic session, redirecting decoded baseband traffic into a live Wireshark GSMTAP stream.",
      "Capture complete NAS, RRC, and PHY layer traces during network registration and cell handover.",
      "Export target baseband firmware modem.bin image and load into FirmWire for QEMU-based task emulation and fuzzing."
    ],
    commands: [
      {
        desc: "Capture Qualcomm DIAG telemetry and stream to Wireshark",
        cmd: "qcsuper --usb-modem /dev/ttyUSB0 --wireshark-live"
      },
      {
        desc: "Decode Samsung / Qualcomm diagnostic logs using SCAT",
        cmd: "scat -t qualcomm -u /dev/ttyUSB0 -w /tmp/scat_output.pcap"
      },
      {
        desc: "Emulate Shannon baseband task snapshot in FirmWire",
        cmd: "firmwire --shannon --firmware modem.bin --snapshot snapshot.raw"
      }
    ],
    diagram: `flowchart TD
    Modem[Target Test UE / Modem] --> |USB DIAG Port /dev/ttyUSB0| Host[TelcoChisel Host]
    Host --> QCSuper[QCSuper / SCAT Daemon]
    QCSuper --> |Decapsulated GSMTAP| Wireshark[Wireshark Live Dissector]
    Host --> Dump[Modem Firmware Image]
    Dump --> FirmWire[FirmWire QEMU / avatar2 Emulation Engine]
    FirmWire --> CrashAnalysis[Crash & Fuzzing Telemetry]`
  },
  {
    id: "scenario-sim-esim-auditing",
    slug: "smartcard-and-esim-security-auditing",
    title: "SIM, USIM & eSIM Cryptographic and APDU Security Auditing",
    category: "sim",
    badge: "Smartcard & eSIM (eUICC)",
    summary: "Audit physical SIM/USIM smartcard filesystems, trace ISO-7816 APDU transactions during active handset communication, and inspect remote eSIM profile provisioning.",
    objective: "Verify smartcard cryptographic parameter protection (Ki, OPc, PIN/PUK), intercept and analyze SIM-to-handset APDU commands via hardware sniffers, and assess eUICC LPA profile integrity.",
    threatModel: "Weak authentication implementations, insecure SIM OTA applets, or tampered eSIM profile metadata exposing subscriber identities or cryptographic credentials.",
    interfaces: ["ISO-7816-3 (T=0 / T=1 Smartcard Interface)", "PC/SC IFD Subsystem", "GSMA SGP.22 LPA (eSIM)"],
    tools: ["pySim", "lpac", "SIMtrace 2", "SIMTester", "SIMurai"],
    academyLab: {
      name: "Virtual UICC & eSIM LPA Remote Provisioning Lab",
      desc: "Explore ISO-7816 smartcard file systems with pySim-shell, inspect authentication algorithms, and audit GSMA RSP SGP.22 eSIM profiles on app.telcosec.net."
    },
    methodology: [
      "Insert smartcard into a standard PC/SC reader or connect Osmocom SIMtrace 2 sniffer hardware between handset and card.",
      "Verify card communication using pcsc_scan and query ATR (Answer to Reset).",
      "Launch pySim-shell to inspect transparent and linear-fixed Elementary Files (EF.ICCID, EF.IMSI, EF.AD, EF.UST).",
      "Audit SIM application toolkit (SAT) and OTA applet security with SIMTester to detect unauthenticated SMS-OTA execution.",
      "Utilize lpac to interact with the eUICC chip, enumerating installed Profile Information (Metadata, State, Provider)."
    ],
    commands: [
      {
        desc: "Scan and display connected PC/SC smartcard ATR and protocol",
        cmd: "pcsc_scan"
      },
      {
        desc: "Launch interactive pySim smartcard exploration console",
        cmd: "pySim-shell -p 0"
      },
      {
        desc: "List installed profiles on connected eUICC via lpac",
        cmd: "lpac profile list"
      },
      {
        desc: "Sniff live ISO-7816 APDU communication via SIMtrace 2",
        cmd: "simtrace2-sniff -i 0"
      }
    ],
    diagram: `sequenceDiagram
    autonumber
    participant Handset as Mobile Phone Baseband
    participant Sniffer as Osmocom SIMtrace 2
    participant SIM as SIM / USIM Smartcard
    participant Chisel as TelcoChisel pySim / lpac

    Handset->>SIM: Power On & ATR (Answer to Reset)
    SIM-->>Handset: ATR Bytes
    Sniffer->>Chisel: Forward Raw ISO-7816 Signals (USB)
    Handset->>SIM: SELECT EF.IMSI (0x00 0xA4 0x00 0x04)
    SIM-->>Handset: IMSI Data
    Handset->>SIM: AUTHENTICATE (RAND, AUTN)
    SIM-->>Handset: RES, CK, IK
    Sniffer->>Chisel: GSMTAP-SIM PCAP Logged
    Chisel->>SIM: pySim-shell Automated Security Audit`
  },
  {
    id: "scenario-wireline-broadband",
    slug: "wireline-broadband-and-voip-auditing",
    title: "Wireline Broadband, PPPoE & VoIP Telephony Infrastructure Auditing",
    category: "wireline",
    badge: "Wireline & VoIP / IMS",
    summary: "Audit wireline access infrastructure including PPPoE/L2TP authentication, TR-069 CPE router management, DOCSIS security configurations, and VoIP/SIP carrier trunks.",
    objective: "Assess the security posture of subscriber broadband edge connections, evaluate MS-CHAPv2 authentication strength against offline cracking, and stress-test SIP carrier gateways against registration floods.",
    threatModel: "Eavesdropping on unencrypted broadband aggregation links or exploiting default TR-069 CWMP implementations to compromise subscriber edge routers and pivot into carrier backbones.",
    interfaces: ["PPPoE (Point-to-Point Protocol over Ethernet)", "802.1Q VLAN Trunks", "TR-069 / CWMP", "SIP (RFC 3261 over UDP/TCP:5060)"],
    tools: ["Asleap", "RouterSploit", "docsis", "SIPp", "Sipsak", "Twinkle", "Baresip"],
    academyLab: {
      name: "Carrier Broadband & SIP Trunk Penetration Testing Lab",
      desc: "Audit PPPoE MS-CHAPv2 handshakes, test TR-069 ACS endpoints, and perform SIPp carrier signaling stress tests on app.telcosec.net."
    },
    methodology: [
      "Capture PPPoE active discovery (PADI/PADO) and PPP authentication frames across the test VLAN.",
      "Extract MS-CHAPv2 Challenge and Response hashes and perform dictionary validation using Asleap.",
      "Simulate TR-069 CPE client interactions using CWMP testing suites to identify unauthorized parameter manipulation.",
      "Execute automated VoIP signaling stress tests using SIPp against an authorized PBX or SIP gateway.",
      "Audit DOCSIS cable modem configuration files to verify cryptographic HMAC-SHA1 signatures."
    ],
    commands: [
      {
        desc: "Audit captured PPPoE MS-CHAPv2 challenge/response",
        cmd: "asleap -r /tmp/pppoe.pcap -f wordlist.txt -n hash.txt"
      },
      {
        desc: "Stress-test SIP PBX with 100 concurrent call sessions",
        cmd: "sipp -sn uac -r 10 -l 100 192.168.10.1:5060"
      },
      {
        desc: "Decode and verify binary DOCSIS cable modem config",
        cmd: "docsis -d cm_config.bin -o cm_config.txt"
      }
    ],
    diagram: `flowchart LR
    CPE[Customer Premises Equipment] --> |PPPoE / VLAN 802.1Q| BNG[Broadband Gateway / LNS]
    CPE --> |TR-069 CWMP| ACS[Auto-Configuration Server]
    TelcoChisel[TelcoChisel Red Team Node] -.-> |Traffic Capture & Asleap| BNG
    TelcoChisel -.-> |SIPp Stress Testing| SIP[Carrier VoIP / IMS Trunk]
    TelcoChisel -.-> |RouterSploit & docsis| CPE`
  }
];
