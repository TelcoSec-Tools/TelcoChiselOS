export const toolsCatalog = [
    {
        name: "GNU Radio 3.10",
        category: "sdr",
        status: "ready",
        desc: "The primary digital signal processing (DSP) framework and graphical flowchart design suite for SDR transceiver implementation.",
        path: "Conda env (telcosec-sdr)",
        cmd: "conda activate telcosec-sdr && gnuradio-companion"
    },
    {
        name: "SoapySDR",
        category: "sdr",
        status: "ready",
        desc: "A vendor-neutral SDR hardware abstraction layer and API, allowing software built against it to work with a wide range of transceivers.",
        path: "Conda env (telcosec-sdr)",
        cmd: "SoapySDRUtil --info"
    },
    {
        name: "UHD (USRP Hardware Driver)",
        category: "sdr",
        status: "ready",
        desc: "Official device driver and interface software for Ettus Research USRP software-defined radios (B210, X310, etc.), compiled from source.",
        path: "Conda env (telcosec-sdr)",
        cmd: 'uhd_usrp_probe --args="type=b200"'
    },
    {
        name: "HackRF Host Tools",
        category: "sdr",
        status: "ready",
        desc: "Command-line configuration and operation tools for the Great Scott Gadgets HackRF One, including firmware flashers and receiver utilities.",
        path: "Conda env (telcosec-sdr)",
        cmd: "hackrf_info"
    },
    {
        name: "gr-gsm Tools",
        category: "sdr",
        status: "ready",
        desc: "Gnu Radio blocks and scripts for receiving, decoding, and analyzing the GSM air interface (2G). Includes live channel monitoring.",
        path: "Conda env (telcosec-sdr)",
        cmd: "grgsm_livemon"
    },
    {
        name: "Kalibrate RTL (kal)",
        category: "sdr",
        status: "ready",
        desc: "Scans for GSM base stations and uses their broadcasts to calibrate the local oscillator frequency offset on RTL-SDR dongles.",
        path: "Conda env (telcosec-sdr)",
        cmd: "kal -s GSM900"
    },
    {
        name: "FirmWire Emulation",
        category: "ue",
        status: "ready",
        desc: "A baseband firmware emulation and fuzzing platform. Emulates Samsung Shannon and MediaTek modems under QEMU, enabling analysis of baseband OTA packets.",
        path: "/opt/telcosec/firmwire/",
        cmd: "/opt/telcosec/firmwire/venv/bin/firmwire --help"
    },
    {
        name: "QCSuper",
        category: "ue",
        status: "ready",
        desc: "Qualcomm diagnostic protocol log parser that generates PCAP files from baseband OTA messages sniffed from a phone connected via USB.",
        path: "System-wide (pip: qcsuper)",
        cmd: "qcsuper --help"
    },
    {
        name: "MTKClient",
        category: "ue",
        status: "ready",
        desc: "A powerful dump, flash, partition editor, and bootloader/BROM bypass tool for MediaTek (MTK) chipset devices.",
        path: "System-wide python",
        cmd: "mtk --help"
    },
    {
        name: "Balong-Flash & Balongtool",
        category: "ue",
        status: "ready",
        desc: "Firmware compilation, modification, and direct USB flasher utilities targeting Huawei Balong-based LTE modems and routers.",
        path: "/usr/local/bin/",
        cmd: "balong-flash --help"
    },
    {
        name: "Osmocom SIMtrace 2 Host",
        category: "sim",
        status: "ready",
        desc: "Host-side companion daemon and sniffer utilities to inspect smartcard ISO-7816 communication between SIM readers and actual handsets.",
        path: "System-wide binaries",
        cmd: "simtrace2-list"
    },
    {
        name: "Osmocom pySim",
        category: "sim",
        status: "ready",
        desc: "An interactive smartcard management shell and scripting library capable of reading, writing, and configuring USIM/SIM credentials.",
        path: "System-wide binaries",
        cmd: "pySim-shell --help"
    },
    {
        name: "lpac (eSIM LPA)",
        category: "sim",
        status: "ready",
        desc: "An independent Local Profile Assistant (LPA) for eSIM profiles, implementing GSMA SGP.22 specifications over PC/SC readers.",
        path: "/usr/local/bin/lpac",
        cmd: "lpac profile list"
    },
    {
        name: "SIMurai (swsim)",
        category: "sim",
        status: "ready",
        desc: "A software SIM platform that emulates a full UICC/SIM card speaking ISO-7816 over TCP/IP, plus a virtual PC/SC IFD driver (swicc-pcsc) that exposes the emulated card to any pcscd-aware tool.",
        path: "/usr/local/bin/simurai",
        cmd: "simurai --help"
    },
    {
        name: "PCSC Daemon (pcscd)",
        category: "sim",
        status: "ready",
        desc: "Smartcard interface daemon facilitating reader communication between hardware card slot readers and software tools.",
        path: "System service",
        cmd: "systemctl status pcscd"
    },
    {
        name: "srsRAN 4G/5G Simulator",
        category: "ran",
        status: "setup",
        desc: "Full open-source SDR-based 4G/5G mobile network simulator implementing gNodeB, eNodeB, and User Equipment (UE). Suitable for virtual cell testing.",
        path: "System-wide",
        cmd: "srsenb --help"
    },
    {
        name: "Wireshark & TShark",
        category: "ran",
        status: "ready",
        desc: "World-class packet sniffer customized with layout profiles displaying GSMTAP, 5G NAS, Diameter codes, and GTP headers.",
        path: "System desktop application",
        cmd: "wireshark"
    },
    {
        name: "SIPVicious",
        category: "ran",
        status: "ready",
        desc: "Audit toolset for SIP-based VoIP systems. Designed to scan target networks, brute-force extensions, and audit registration systems.",
        path: "System-wide python",
        cmd: "svmap --help"
    },
    {
        name: "sctpscan",
        category: "ran",
        status: "ready",
        desc: "A fast SCTP port scanner to map host capabilities and discover ports running S1AP, NGAP, Diameter, or M3UA SIGTRAN protocols.",
        path: "/usr/local/bin/sctpscan",
        cmd: "sctpscan --help"
    },
    {
        name: "SigPloit",
        category: "ran",
        status: "ready",
        desc: "Signaling exploitation framework targeting SS7, Diameter, and GTP protocols to audit core telecom networks for routing vulnerabilities.",
        path: "/opt/telcosec/sigploit/",
        cmd: "/opt/telcosec/python2/bin/python2.7 /opt/telcosec/sigploit/sigploit.py"
    },
    {
        name: "Diafuzzer",
        category: "ran",
        status: "ready",
        desc: "Diameter protocol fuzzer written by Orange Security, designed to test core interfaces (S6a, Gx, Gy) for vulnerability to malformed requests.",
        path: "/opt/telcosec/diafuzzer/",
        cmd: "python3 /opt/telcosec/diafuzzer/diafuzzer.py --help"
    },
    {
        name: "Scapy (with SS7/Diameter modules)",
        category: "ran",
        status: "ready",
        desc: "Interactive packet manipulation program extended to support construction of custom MAP, TCAP, M3UA, and Diameter network frames.",
        path: "System-wide python",
        cmd: "scapy"
    },
    {
        name: "5Ghoul Fuzzer Wrapper",
        category: "ran",
        status: "setup",
        desc: "Custom launcher wrapper that simplifies executing the 5Ghoul fuzzer, automatically patching configurations for BladeRF and USRP transceivers.",
        path: "/usr/local/bin/5ghoul-run",
        cmd: "sudo 5ghoul-run --Attack.Name=NAS_5GS_Fuzz"
    },
    {
        name: "Open5GS Core Network",
        category: "ran",
        status: "setup",
        desc: "A complete open-source implementation of 4G EPC and 5G Core Network functions (AMF, SMF, UPF, UDM, HSS) built with high performance in C.",
        path: "/usr/local/bin/open5gs-install",
        cmd: "sudo open5gs-install"
    },
    {
        name: "Docker & Docker Compose",
        category: "sys",
        status: "ready",
        desc: "Containerization engine pre-configured for non-root management. Used to spin up large-scale core network elements quickly.",
        path: "System services",
        cmd: "docker ps"
    },
    {
        name: "Telecom Wordlists",
        category: "sys",
        status: "ready",
        desc: "Bundled telecom-specific wordlist collection covering carrier APNs, VoIP/SIP credentials, RAN element passwords, SIM OTA test keys, hardware defaults, PLMNs/IMSI prefixes, and protocol-level lists for 5G NAS, GTP, SS7, Diameter, SMS, and USSD. Includes telcosec-apn-permutator and telcosec-imsi-generator helper scripts on PATH.",
        path: "/usr/share/wordlists/telecom/",
        cmd: "ls -lR /usr/share/wordlists/telecom/"
    },
    // ── GSM / 2G ──────────────────────────────────────────────────────────
    {
        name: "YateBTS",
        category: "gsm",
        status: "setup",
        desc: "Open-source GSM/UMTS BTS implementation built on the Yate telephony engine. Optimized for BladeRF A4 with a dedicated hardware config.",
        path: "/opt/telcosec/yatebts/ (helper: yatebts-install)",
        cmd: "sudo yatebts-install"
    },
    {
        name: "OpenBTS",
        category: "gsm",
        status: "setup",
        desc: "Pioneering open-source GSM base transceiver station. Implements the Um air interface enabling rogue GSM cell and protocol audit scenarios.",
        path: "/opt/telcosec/openbts/ (helper: openbts-install)",
        cmd: "sudo openbts-install"
    },
    {
        name: "Osmocom GSM Stack",
        category: "gsm",
        status: "ready",
        desc: "Complete Osmocom GSM network stack: OsmoBSC, OsmoMSC, OsmoHLR, OsmoBTS-TRX. Supports osmo-trx-bladerf for BladeRF A4 hardware.",
        path: "System packages",
        cmd: "osmo-bsc --help"
    },
    {
        name: "Kalibrate GSM",
        category: "gsm",
        status: "ready",
        desc: "GSM-band frequency offset calibration tool using broadcast channel timing from live base stations. Complements kalibrate-rtl for calibrating BladeRF.",
        path: "/usr/local/bin/kal-gsm",
        cmd: "kal-gsm -s GSM900 -g 40"
    },
    // ── LTE / 4G ──────────────────────────────────────────────────────────
    {
        name: "srsUE",
        category: "lte",
        status: "ready",
        desc: "Software-defined LTE UE (User Equipment) that connects to real or simulated eNodeBs. Used for protocol testing, attach procedures, and downlink captures.",
        path: "System-wide",
        cmd: "srsue /etc/srsran/ue.conf"
    },
    {
        name: "srsGUI",
        category: "lte",
        status: "ready",
        desc: "Real-time visualization GUI for srsRAN metrics: constellation diagrams, spectrum, BER counters, and RLC/PDCP throughput graphs.",
        path: "srsgui",
        cmd: "srsgui"
    },
    {
        name: "LTE-CellScanner",
        category: "lte",
        status: "ready",
        desc: "Open-source LTE cell searcher and MIB/SIB decoder. Scans a frequency range and decodes cell IDs, bandwidth, and system information blocks.",
        path: "/opt/telcosec/lte-cellscanner/",
        cmd: "LTE-CellSearch -s 2650e6"
    },
    {
        name: "LTESniffer",
        category: "lte",
        status: "ready",
        desc: "Open-source LTE downlink and uplink sniffer. Decodes physical layer frames and logs RRC, NAS, and user-plane traffic to PCAP.",
        path: "/opt/telcosec/ltesniffer/",
        cmd: "ltesniffer -A 2 -f 2630e6 -C -m 0"
    },
    {
        name: "SCAT",
        category: "lte",
        status: "ready",
        desc: "DIAG protocol parser for Qualcomm and Samsung modems. Decodes OTA messages from USB-connected phones to PCAP with full NAS/RRC content.",
        path: "System-wide (pip: scat)",
        cmd: "scat -t qc -d /dev/ttyUSB0 -o capture.pcap"
    },
    {
        name: "Modmobmap",
        category: "lte",
        status: "ready",
        desc: "Maps 2G/3G/4G cells visible to a USB modem by issuing AT commands. Generates cell-tower geolocation data and signal reports.",
        path: "/opt/telcosec/modmobmap/",
        cmd: "modmobmap -m /dev/ttyUSB1"
    },
    // ── 5G NR ─────────────────────────────────────────────────────────────
    {
        name: "UERANSIM",
        category: "5g",
        status: "ready",
        desc: "The most complete open-source 5G SA UE and gNB simulator. Emulates full N1/N2/N3 interfaces, compatible with Open5GS. Pre-configured for test PLMN 001/01.",
        path: "/opt/telcosec/ueransim/",
        cmd: "nr-gnb -c /etc/telcosec/ueransim/gnb.yaml"
    },
    {
        name: "GTP5G Kernel Module",
        category: "5g",
        status: "setup",
        desc: "Linux kernel module implementing the GTP-U encapsulation layer required by UERANSIM and free5GC for 5G user-plane forwarding.",
        path: "/opt/telcosec/gtp5g/ (helper: gtp5g-load)",
        cmd: "sudo gtp5g-load"
    },
    {
        name: "OAI UE (OpenAirInterface)",
        category: "5g",
        status: "setup",
        desc: "OpenAirInterface 5G NR UE implementation from EURECOM. Full PHY/MAC/RLC stack for 5G SA and NSA testing with real radio hardware.",
        path: "Helper: oai-install (deferred build)",
        cmd: "sudo oai-install"
    },
    // ── Device Tools ──────────────────────────────────────────────────────
    {
        name: "Heimdall (Samsung)",
        category: "device",
        status: "ready",
        desc: "Open-source, cross-platform Samsung Odin replacement for flashing firmware on Samsung devices in Download Mode.",
        path: "System-wide",
        cmd: "heimdall detect"
    },
    {
        name: "ADB & Fastboot",
        category: "device",
        status: "ready",
        desc: "Android Debug Bridge and Fastboot tools for communicating with Android devices in normal, recovery, and bootloader modes.",
        path: "System-wide",
        cmd: "adb devices -l"
    },
    {
        name: "EDL (Qualcomm Emergency Download)",
        category: "device",
        status: "ready",
        desc: "Comprehensive Qualcomm EDL/9008 mode toolkit for reading, writing, and erasing partitions on Snapdragon devices via Sahara/Firehose protocols.",
        path: "System-wide (pip: edl)",
        cmd: "edl --help"
    },
    {
        name: "SIMTester",
        category: "device",
        status: "ready",
        desc: "Java-based SIM card security audit tool from SRLabs. Tests for roaming, OTA update vulnerabilities, and SIM application exploits.",
        path: "/opt/telcosec/simtester/ (/usr/local/bin/simtester)",
        cmd: "simtester"
    },
    {
        name: "AT Command Console",
        category: "device",
        status: "ready",
        desc: "Interactive AT command terminal (minicom) pre-configured for modem control. Supports querying IMEI, network registration, signal strength, and USSD.",
        path: "/usr/local/bin/at-console",
        cmd: "at-console /dev/ttyUSB0"
    },
    {
        name: "Gammu",
        category: "device",
        status: "ready",
        desc: "Universal mobile device manager supporting SMS sending/receiving, USSD queries, call management, and phonebook access via AT commands.",
        path: "System-wide",
        cmd: "gammu --port /dev/ttyUSB0 --connection at115200 identify"
    },
    // ── Network Analysis ──────────────────────────────────────────────────
    {
        name: "Kismet",
        category: "network",
        status: "ready",
        desc: "Wireless network detector, sniffer, and intrusion detection system. Captures raw 802.11 frames on mon0 and logs device fingerprints.",
        path: "System-wide",
        cmd: "sudo kismet -c mon0"
    },
    {
        name: "tcpdump",
        category: "network",
        status: "ready",
        desc: "CLI packet capture tool. Used in TelcoSec scripts to capture raw traffic on the monitoring interface and pipe to Wireshark.",
        path: "System-wide",
        cmd: "sudo tcpdump -i mon0 -w capture.pcap"
    },
    // ── VoIP & Messaging ──────────────────────────────────────────────────
    {
        name: "Zoiper5",
        category: "voip",
        status: "ready",
        desc: "Commercial-grade VoIP softphone supporting SIP and IAX2. Used for testing SIP registrars, call flows, and intercepted credential replays.",
        path: "System application (zoiper5)",
        cmd: "zoiper5"
    },
    {
        name: "SIPp",
        category: "voip",
        status: "ready",
        desc: "SIP load tester and traffic generator. Sends scripted SIP scenarios (INVITE storms, registration floods) to audit VoIP infrastructure.",
        path: "System-wide",
        cmd: "sipp -h"
    },
    // ── Newly Added Tools ─────────────────────────────────────────────────
    {
        name: "atinout",
        category: "device",
        status: "ready",
        desc: "Quick command-line tool to send AT commands to a modem and capture the output. Excellent for scripting USSD or SMS tasks.",
        path: "/usr/local/bin/atinout",
        cmd: "echo 'AT+CGMI' | atinout - /dev/ttyUSB0 -"
    },
    {
        name: "ModemManager GUI",
        category: "device",
        status: "ready",
        desc: "Graphical frontend for ModemManager, dbus, and NetworkManager. Allows sending SMS, USSD, and reading SIM contacts directly from the desktop.",
        path: "System application",
        cmd: "modem-manager-gui"
    },
    {
        name: "SP Flash Tool (Helper)",
        category: "device",
        status: "setup",
        desc: "Proprietary flash tool for MediaTek devices. The pre-installed helper script provides download links and extraction instructions.",
        path: "/usr/local/bin/spflashtool-install",
        cmd: "spflashtool-install"
    },
    {
        name: "Linphone",
        category: "voip",
        status: "ready",
        desc: "Open-source SIP softphone used for voice and video over IP. Useful as an alternative to Zoiper for testing PBX configurations and SIP registrars.",
        path: "System application (linphone)",
        cmd: "linphone"
    },
    {
        name: "Nokia NetAct CLI",
        category: "sys",
        status: "ready",
        desc: "Wrapper for connecting to Nokia NetAct OSS systems using standard telecom administrative protocols.",
        path: "/usr/local/bin/nokia-netact-cli",
        cmd: "nokia-netact-cli <host>"
    },
    {
        name: "Ericsson ENM CLI",
        category: "sys",
        status: "ready",
        desc: "Wrapper for connecting to Ericsson Network Manager (ENM) infrastructure via SSH.",
        path: "/usr/local/bin/ericsson-enm-cli",
        cmd: "ericsson-enm-cli <host>"
    },
    {
        name: "Huawei U2000 CLI",
        category: "sys",
        status: "ready",
        desc: "Wrapper for accessing Huawei U2000 management interfaces using telnet or SSH fallback.",
        path: "/usr/local/bin/huawei-u2000-cli",
        cmd: "huawei-u2000-cli <host>"
    }
]
