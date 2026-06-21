export const toolsCatalog = [
    {
        name: "GNU Radio 3.10",
        slug: "gnu-radio-companion",
        category: "sdr",
        status: "ready",
        desc: "The primary digital signal processing (DSP) framework and graphical flowchart design suite for SDR transceiver implementation.",
        path: "Conda env (telcosec-sdr)",
        cmd: "conda activate telcosec-sdr && gnuradio-companion"
    },
    {
        name: "SoapySDR",
        slug: "soapysdr",
        category: "sdr",
        status: "ready",
        desc: "A vendor-neutral SDR hardware abstraction layer and API, allowing software built against it to work with a wide range of transceivers.",
        path: "Conda env (telcosec-sdr)",
        cmd: "SoapySDRUtil --info"
    },
    {
        name: "UHD (USRP Hardware Driver)",
        slug: "uhd-usrp-hardware-driver",
        category: "sdr",
        status: "ready",
        desc: "Official device driver and interface software for Ettus Research USRP software-defined radios (B210, X310, etc.), compiled from source.",
        path: "Conda env (telcosec-sdr)",
        cmd: 'uhd_usrp_probe --args="type=b200"'
    },
    {
        name: "HackRF Host Tools",
        slug: "hackrf-host-tools",
        category: "sdr",
        status: "ready",
        desc: "Command-line configuration and operation tools for the Great Scott Gadgets HackRF One, including firmware flashers and receiver utilities.",
        path: "Conda env (telcosec-sdr)",
        cmd: "hackrf_info"
    },
    {
        name: "gr-gsm Tools",
        slug: "gr-gsm-tools",
        category: "sdr",
        status: "ready",
        desc: "Gnu Radio blocks and scripts for receiving, decoding, and analyzing the GSM air interface (2G). Includes live channel monitoring.",
        path: "Conda env (telcosec-sdr)",
        cmd: "grgsm_livemon"
    },
    {
        name: "Kalibrate RTL (kal)",
        slug: "kalibrate-rtl",
        category: "sdr",
        status: "ready",
        desc: "Scans for GSM base stations and uses their broadcasts to calibrate the local oscillator frequency offset on RTL-SDR dongles.",
        path: "Conda env (telcosec-sdr)",
        cmd: "kal -s GSM900"
    },
    {
        name: "FirmWire Emulation",
        slug: "firmwire-emulation",
        category: "baseband",
        status: "ready",
        desc: "A baseband firmware emulation and fuzzing platform. Emulates Samsung Shannon and MediaTek modems under QEMU, enabling analysis of baseband OTA packets.",
        path: "/opt/telcosec/firmwire/",
        cmd: "/opt/telcosec/firmwire/venv/bin/firmwire --help"
    },
    {
        name: "QCSuper",
        slug: "qcsuper",
        category: "baseband",
        status: "ready",
        desc: "Qualcomm diagnostic protocol log parser that generates PCAP files from baseband OTA messages sniffed from a phone connected via USB.",
        path: "System-wide (pip: qcsuper)",
        cmd: "qcsuper --help"
    },
    {
        name: "MTKClient",
        slug: "mtkclient",
        category: "baseband",
        status: "ready",
        desc: "A powerful dump, flash, partition editor, and bootloader/BROM bypass tool for MediaTek (MTK) chipset devices.",
        path: "System-wide python",
        cmd: "mtk --help"
    },
    {
        name: "Balong-Flash & Balongtool",
        slug: "balong-flash-balongtool",
        category: "baseband",
        status: "ready",
        desc: "Firmware compilation, modification, and direct USB flasher utilities targeting Huawei Balong-based LTE modems and routers.",
        path: "/usr/local/bin/",
        cmd: "balong-flash --help"
    },
    {
        name: "Osmocom SIMtrace 2 Host",
        slug: "osmocom-simtrace-2-host",
        category: "sim",
        status: "ready",
        desc: "Host-side companion daemon and sniffer utilities to inspect smartcard ISO-7816 communication between SIM readers and actual handsets.",
        path: "System-wide binaries",
        cmd: "simtrace2-list"
    },
    {
        name: "Osmocom pySim",
        slug: "osmocom-pysim",
        category: "sim",
        status: "ready",
        desc: "An interactive smartcard management shell and scripting library capable of reading, writing, and configuring USIM/SIM credentials.",
        path: "System-wide binaries",
        cmd: "pySim-shell --help"
    },
    {
        name: "lpac (eSIM LPA)",
        slug: "lpac-esim-lpa",
        category: "sim",
        status: "ready",
        desc: "An independent Local Profile Assistant (LPA) for eSIM profiles, implementing GSMA SGP.22 specifications over PC/SC readers.",
        path: "/usr/local/bin/lpac",
        cmd: "lpac profile list"
    },
    {
        name: "SIMurai (swsim)",
        slug: "simurai-software-sim",
        category: "sim",
        status: "ready",
        desc: "A software SIM platform that emulates a full UICC/SIM card speaking ISO-7816 over TCP/IP, plus a virtual PC/SC IFD driver (swicc-pcsc) that exposes the emulated card to any pcscd-aware tool.",
        path: "/usr/local/bin/simurai",
        cmd: "simurai --help"
    },
    {
        name: "PCSC Daemon (pcscd)",
        slug: "pcsc-daemon-pcscd",
        category: "sim",
        status: "ready",
        desc: "Smartcard interface daemon facilitating reader communication between hardware card slot readers and software tools.",
        path: "System service",
        cmd: "systemctl status pcscd"
    },
    {
        name: "srsRAN 4G/5G Simulator",
        slug: "srsran-4g-5g-simulator",
        category: "core",
        status: "setup",
        desc: "Full open-source SDR-based 4G/5G mobile network simulator implementing gNodeB, eNodeB, and User Equipment (UE). Suitable for virtual cell testing.",
        path: "System-wide",
        cmd: "srsenb --help"
    },
    {
        name: "Wireshark & TShark",
        slug: "wireshark-tshark",
        category: "core",
        status: "ready",
        desc: "World-class packet sniffer customized with layout profiles displaying GSMTAP, 5G NAS, Diameter codes, and GTP headers.",
        path: "System desktop application",
        cmd: "wireshark"
    },
    {
        name: "SIPVicious",
        slug: "sipvicious",
        category: "core",
        status: "ready",
        desc: "Audit toolset for SIP-based VoIP systems. Designed to scan target networks, brute-force extensions, and audit registration systems.",
        path: "System-wide python",
        cmd: "svmap --help"
    },
    {
        name: "sctpscan",
        slug: "sctpscan",
        category: "core",
        status: "ready",
        desc: "A fast SCTP port scanner to map host capabilities and discover ports running S1AP, NGAP, Diameter, or M3UA SIGTRAN protocols.",
        path: "/usr/local/bin/sctpscan",
        cmd: "sctpscan --help"
    },
    {
        name: "SigPloit",
        slug: "sigploit",
        category: "core",
        status: "ready",
        desc: "Signaling exploitation framework targeting SS7, Diameter, and GTP protocols to audit core telecom networks for routing vulnerabilities.",
        path: "/opt/telcosec/sigploit/",
        cmd: "sudo sigploit"
    },
    {
        name: "Diafuzzer",
        slug: "diafuzzer",
        category: "core",
        status: "ready",
        desc: "Diameter protocol fuzzer written by Orange Security, designed to test core interfaces (S6a, Gx, Gy) for vulnerability to malformed requests.",
        path: "/opt/telcosec/diafuzzer/",
        cmd: "python3 /opt/telcosec/diafuzzer/diafuzzer.py --help"
    },
    {
        name: "Scapy (with SS7/Diameter modules)",
        slug: "scapy-ss7-diameter",
        category: "core",
        status: "ready",
        desc: "Interactive packet manipulation program extended to support construction of custom MAP, TCAP, M3UA, and Diameter network frames.",
        path: "System-wide python",
        cmd: "scapy"
    },
    {
        name: "5Ghoul Fuzzer Wrapper",
        slug: "5ghoul-fuzzer",
        category: "core",
        status: "setup",
        desc: "Custom launcher wrapper that simplifies executing the 5Ghoul fuzzer, automatically patching configurations for BladeRF and USRP transceivers.",
        path: "/usr/local/bin/5ghoul-run",
        cmd: "sudo 5ghoul-run --Attack.Name=NAS_5GS_Fuzz"
    },
    {
        name: "Open5GS Core Network",
        slug: "open5gs-core-network",
        category: "core",
        status: "setup",
        desc: "A complete open-source implementation of 4G EPC and 5G Core Network functions (AMF, SMF, UPF, UDM, HSS) built with high performance in C.",
        path: "/usr/local/bin/open5gs-install",
        cmd: "cd /opt/telcosec/open5gs/docker_open5gs && sudo docker compose up -d"
    },
    {
        name: "Docker & Docker Compose",
        slug: "docker-docker-compose",
        category: "core",
        status: "ready",
        desc: "Containerization engine pre-configured for non-root management. Used to spin up large-scale core network elements quickly.",
        path: "System services",
        cmd: "docker ps"
    },
    {
        name: "Telecom Wordlists",
        slug: "telecom-wordlists",
        category: "core",
        status: "ready",
        desc: "Bundled telecom-specific wordlist collection covering carrier APNs, VoIP/SIP credentials, RAN element passwords, SIM OTA test keys, hardware defaults, PLMNs/IMSI prefixes, and protocol-level lists for 5G NAS, GTP, SS7, Diameter, SMS, and USSD. Includes telcosec-apn-permutator and telcosec-imsi-generator helper scripts on PATH.",
        path: "/usr/share/wordlists/telecom/",
        cmd: "ls -lR /usr/share/wordlists/telecom/"
    },
    {
        name: "YateBTS",
        slug: "yatebts",
        category: "2g",
        status: "setup",
        desc: "Open-source GSM/UMTS BTS implementation built on the Yate telephony engine. Optimized for BladeRF A4 with a dedicated hardware config.",
        path: "/opt/telcosec/yatebts/ (helper: yatebts-install)",
        cmd: "sudo yatebts-install"
    },
    {
        name: "OpenBTS",
        slug: "openbts",
        category: "2g",
        status: "setup",
        desc: "Pioneering open-source GSM base transceiver station. Implements the Um air interface enabling rogue GSM cell and protocol audit scenarios.",
        path: "/opt/telcosec/openbts/ (helper: openbts-install)",
        cmd: "sudo openbts-install"
    },
    {
        name: "Osmocom GSM Stack",
        slug: "osmocom-gsm-stack",
        category: "2g",
        status: "ready",
        desc: "Complete Osmocom GSM network stack: OsmoBSC, OsmoMSC, OsmoHLR, OsmoBTS-TRX. Supports osmo-trx-bladerf for BladeRF A4 hardware.",
        path: "System packages",
        cmd: "osmo-bsc --help"
    },
    {
        name: "Kalibrate GSM",
        slug: "kalibrate-gsm",
        category: "2g",
        status: "ready",
        desc: "GSM-band frequency offset calibration tool using broadcast channel timing from live base stations. Complements kalibrate-rtl for calibrating BladeRF.",
        path: "/usr/local/bin/kal-gsm",
        cmd: "kal-gsm -s GSM900 -g 40"
    },
    {
        name: "srsUE",
        slug: "srsue",
        category: "4g",
        status: "ready",
        desc: "Software-defined LTE UE (User Equipment) that connects to real or simulated eNodeBs. Used for protocol testing, attach procedures, and downlink captures.",
        path: "System-wide",
        cmd: "srsue /etc/srsran/ue.conf"
    },
    {
        name: "srsGUI",
        slug: "srsgui",
        category: "4g",
        status: "ready",
        desc: "Real-time visualization GUI for srsRAN metrics: constellation diagrams, spectrum, BER counters, and RLC/PDCP throughput graphs.",
        path: "srsgui",
        cmd: "srsgui"
    },
    {
        name: "LTE-CellScanner",
        slug: "lte-cellscanner",
        category: "4g",
        status: "ready",
        desc: "Open-source LTE cell searcher and MIB/SIB decoder. Scans a frequency range and decodes cell IDs, bandwidth, and system information blocks.",
        path: "/opt/telcosec/lte-cellscanner/",
        cmd: "LTE-CellSearch -s 2650e6"
    },
    {
        name: "LTESniffer",
        slug: "ltesniffer",
        category: "4g",
        status: "ready",
        desc: "Open-source LTE downlink and uplink sniffer. Decodes physical layer frames and logs RRC, NAS, and user-plane traffic to PCAP.",
        path: "/opt/telcosec/ltesniffer/",
        cmd: "ltesniffer -A 2 -f 2630e6 -C -m 0"
    },
    {
        name: "SCAT",
        slug: "scat",
        category: "4g",
        status: "ready",
        desc: "DIAG protocol parser for Qualcomm and Samsung modems. Decodes OTA messages from USB-connected phones to PCAP with full NAS/RRC content.",
        path: "System-wide (pip: scat)",
        cmd: "scat -t qc -d /dev/ttyUSB0 -o capture.pcap"
    },
    {
        name: "Modmobmap",
        slug: "modmobmap",
        category: "4g",
        status: "ready",
        desc: "Maps 2G/3G/4G cells visible to a USB modem by issuing AT commands. Generates cell-tower geolocation data and signal reports.",
        path: "/opt/telcosec/modmobmap/",
        cmd: "modmobmap -m /dev/ttyUSB1"
    },
    {
        name: "UERANSIM",
        slug: "ueransim",
        category: "5g",
        status: "ready",
        desc: "The most complete open-source 5G SA UE and gNB simulator. Emulates full N1/N2/N3 interfaces, compatible with Open5GS. Pre-configured for test PLMN 001/01.",
        path: "/opt/telcosec/ueransim/",
        cmd: "nr-gnb -c /etc/telcosec/ueransim/gnb.yaml"
    },
    {
        name: "GTP5G Kernel Module",
        slug: "gtp5g-kernel-module",
        category: "5g",
        status: "setup",
        desc: "Linux kernel module implementing the GTP-U encapsulation layer required by UERANSIM and free5GC for 5G user-plane forwarding.",
        path: "/opt/telcosec/gtp5g/ (helper: gtp5g-load)",
        cmd: "sudo gtp5g-load"
    },
    {
        name: "OAI UE (OpenAirInterface)",
        slug: "oai-ue-openairinterface",
        category: "5g",
        status: "setup",
        desc: "OpenAirInterface 5G NR UE implementation from EURECOM. Full PHY/MAC/RLC stack for 5G SA and NSA testing with real radio hardware.",
        path: "Helper: oai-install (deferred build)",
        cmd: "sudo oai-install"
    },
    {
        name: "Heimdall (Samsung)",
        slug: "heimdall-samsung",
        category: "baseband",
        status: "ready",
        desc: "Open-source, cross-platform Samsung Odin replacement for flashing firmware on Samsung devices in Download Mode.",
        path: "System-wide",
        cmd: "heimdall detect"
    },
    {
        name: "ADB & Fastboot",
        slug: "adb-fastboot",
        category: "baseband",
        status: "ready",
        desc: "Android Debug Bridge and Fastboot tools for communicating with Android devices in normal, recovery, and bootloader modes.",
        path: "System-wide",
        cmd: "adb devices -l"
    },
    {
        name: "EDL (Qualcomm Emergency Download)",
        slug: "edl-qualcomm-emergency-download",
        category: "baseband",
        status: "ready",
        desc: "Comprehensive Qualcomm EDL/9008 mode toolkit for reading, writing, and erasing partitions on Snapdragon devices via Sahara/Firehose protocols.",
        path: "System-wide (pip: edl)",
        cmd: "edl --help"
    },
    {
        name: "SIMTester",
        slug: "simtester",
        category: "baseband",
        status: "ready",
        desc: "Java-based SIM card security audit tool from SRLabs. Tests for roaming, OTA update vulnerabilities, and SIM application exploits.",
        path: "/opt/telcosec/simtester/ (/usr/local/bin/simtester)",
        cmd: "simtester"
    },
    {
        name: "RDNSx",
        slug: "rdnsx",
        category: "baseband",
        status: "ready",
        desc: "Rapid DNS Reverse Resolver for fast network enumeration and reconnaissance.",
        path: "/usr/local/bin/rdnsx",
        cmd: "rdnsx"
    },
    {
        name: "AT Command Console",
        slug: "at-command-console",
        category: "baseband",
        status: "ready",
        desc: "Interactive AT command terminal (minicom) pre-configured for modem control. Supports querying IMEI, network registration, signal strength, and USSD.",
        path: "/usr/local/bin/at-console",
        cmd: "at-console /dev/ttyUSB0"
    },
    {
        name: "Gammu",
        slug: "gammu",
        category: "baseband",
        status: "ready",
        desc: "Universal mobile device manager supporting SMS sending/receiving, USSD queries, call management, and phonebook access via AT commands.",
        path: "System-wide",
        cmd: "gammu --port /dev/ttyUSB0 --connection at115200 identify"
    },
    {
        name: "Kismet",
        slug: "kismet",
        category: "core",
        status: "ready",
        desc: "Wireless network detector, sniffer, and intrusion detection system. Captures raw 802.11 frames on mon0 and logs device fingerprints.",
        path: "System-wide",
        cmd: "sudo kismet -c mon0"
    },
    {
        name: "tcpdump",
        slug: "tcpdump",
        category: "core",
        status: "ready",
        desc: "CLI packet capture tool. Used in TelcoSec scripts to capture raw traffic on the monitoring interface and pipe to Wireshark.",
        path: "System-wide",
        cmd: "sudo tcpdump -i mon0 -w capture.pcap"
    },
    {
        name: "Zoiper5",
        slug: "zoiper5",
        category: "voip",
        status: "ready",
        desc: "Commercial-grade VoIP softphone supporting SIP and IAX2. Used for testing SIP registrars, call flows, and intercepted credential replays.",
        path: "System application (zoiper5)",
        cmd: "zoiper5"
    },
    {
        name: "SIPp",
        slug: "sipp",
        category: "voip",
        status: "ready",
        desc: "SIP load tester and traffic generator. Sends scripted SIP scenarios (INVITE storms, registration floods) to audit VoIP infrastructure.",
        path: "System-wide",
        cmd: "sipp -h"
    },
    {
        name: "atinout",
        slug: "atinout",
        category: "baseband",
        status: "ready",
        desc: "Quick command-line tool to send AT commands to a modem and capture the output. Excellent for scripting USSD or SMS tasks.",
        path: "/usr/local/bin/atinout",
        cmd: "echo 'AT+CGMI' | atinout - /dev/ttyUSB0 -"
    },
    {
        name: "ModemManager GUI",
        slug: "modem-manager-gui",
        category: "baseband",
        status: "ready",
        desc: "Graphical frontend for ModemManager, dbus, and NetworkManager. Allows sending SMS, USSD, and reading SIM contacts directly from the desktop.",
        path: "System application",
        cmd: "modem-manager-gui"
    },
    {
        name: "SP Flash Tool (Helper)",
        slug: "sp-flash-tool",
        category: "baseband",
        status: "setup",
        desc: "Proprietary flash tool for MediaTek devices. The pre-installed helper script provides download links and extraction instructions.",
        path: "/usr/local/bin/spflashtool-install",
        cmd: "spflashtool-install"
    },
    {
        name: "Linphone",
        slug: "linphone",
        category: "voip",
        status: "ready",
        desc: "Open-source SIP softphone used for voice and video over IP. Useful as an alternative to Zoiper for testing PBX configurations and SIP registrars.",
        path: "System application (linphone)",
        cmd: "linphone"
    },
    {
        name: "Nokia NetAct CLI",
        slug: "nokia-netact-cli",
        category: "mw",
        status: "ready",
        desc: "Wrapper for connecting to Nokia NetAct OSS systems using standard telecom administrative protocols.",
        path: "/usr/local/bin/nokia-netact-cli",
        cmd: "nokia-netact-cli <host>"
    },
    {
        name: "Ericsson ENM CLI",
        slug: "ericsson-enm-cli",
        category: "mw",
        status: "ready",
        desc: "Wrapper for connecting to Ericsson Network Manager (ENM) infrastructure via SSH.",
        path: "/usr/local/bin/ericsson-enm-cli",
        cmd: "ericsson-enm-cli <host>"
    },
    {
        name: "Huawei U2000 CLI",
        slug: "huawei-u2000-cli",
        category: "mw",
        status: "ready",
        desc: "Wrapper for accessing Huawei U2000 management interfaces using telnet or SSH fallback.",
        path: "/usr/local/bin/huawei-u2000-cli",
    },
    {
        name: "GQRX",
        slug: "gqrx",
        category: "sdr",
        status: "ready",
        desc: "An open source software defined radio (SDR) receiver GUI and spectrum analyzer powered by GNU Radio and Qt.",
        path: "Conda env (telcosec-sdr)",
        cmd: "gqrx"
    },
    {
        name: "MobileInsight",
        slug: "mobileinsight",
        category: "baseband",
        status: "ready",
        desc: "A mobile network diagnostic analysis framework that extracts, parses, and analyzes 3G/4G/5G baseband messages.",
        path: "System-wide",
        cmd: "mobileinsight --help"
    },
    {
        name: "Twinkle",
        slug: "twinkle",
        category: "voip",
        status: "ready",
        desc: "A SIP softphone for voice over IP and instant messaging communications, useful for VoIP security and signaling audits.",
        path: "System application (twinkle)",
        cmd: "twinkle"
    },
    {
        name: "Baresip",
        slug: "baresip",
        category: "voip",
        status: "ready",
        desc: "A modular, command-line based SIP user agent with audio and video support, ideal for scriptable VoIP and PBX testing.",
        path: "System-wide",
        cmd: "baresip"
    },
    {
        name: "Macchanger",
        slug: "macchanger",
        category: "adsl",
        status: "ready",
        desc: "Utility for viewing/manipulating the MAC address of network interfaces to bypass sticky-MAC port security.",
        path: "System-wide",
        cmd: "macchanger --help"
    },
    {
        name: "VLAN (vconfig)",
        slug: "vconfig",
        category: "adsl",
        status: "ready",
        desc: "VLAN hopping and manipulation tool for executing attacks against DSLAM and Open vSwitch configurations.",
        path: "System-wide",
        cmd: "vconfig"
    },
    {
        name: "Asleap",
        slug: "asleap",
        category: "adsl",
        status: "ready",
        desc: "Performs offline dictionary attacks against captured PPPoE MS-CHAPv2 challenge/response hashes.",
        path: "System-wide",
        cmd: "asleap -h"
    },
    {
        name: "FreeRADIUS Utils",
        slug: "freeradius-utils",
        category: "adsl",
        status: "ready",
        desc: "Includes radtest and radclient to craft malicious RADIUS Access-Request packets or test dictionary attacks.",
        path: "System-wide",
        cmd: "radtest -h"
    },
    {
        name: "Hashcat",
        slug: "hashcat",
        category: "adsl",
        status: "ready",
        desc: "Advanced password recovery utility supporting multiple algorithms including RADIUS shared secrets and MS-CHAPv2.",
        path: "System-wide",
        cmd: "hashcat -h"
    },
    {
        name: "John the Ripper",
        slug: "john",
        category: "adsl",
        status: "ready",
        desc: "Fast password cracker, useful for intercepted RADIUS shared secrets or MS-CHAPv2 hashes.",
        path: "System-wide",
        cmd: "john"
    },
    {
        name: "PPPoE Tools",
        slug: "pppoe",
        category: "adsl",
        status: "ready",
        desc: "Includes ppp and pppoe tools to establish rogue PPPoE sessions, acting as a rogue CPE.",
        path: "System-wide",
        cmd: "pppoe-setup"
    },
    {
        name: "Nikto",
        slug: "nikto",
        category: "adsl",
        status: "ready",
        desc: "Web server scanner which performs comprehensive tests against web servers for multiple items, including CPE local Web UIs.",
        path: "System-wide",
        cmd: "nikto -H"
    },
    {
        name: "Gobuster",
        slug: "gobuster",
        category: "adsl",
        status: "ready",
        desc: "Directory/File, DNS and VHost busting tool written in Go, for directory enumeration on CPE or GenieACS dashboards.",
        path: "System-wide",
        cmd: "gobuster help"
    },
    {
        name: "SNMP Check",
        slug: "snmpcheck",
        category: "adsl",
        status: "ready",
        desc: "Tool to automate the process of gathering information via SNMP protocols, exploiting intentionally weak community strings.",
        path: "System-wide",
        cmd: "snmpcheck -h"
    },
    {
        name: "RouterSploit",
        slug: "routersploit",
        category: "adsl",
        status: "ready",
        desc: "Exploitation framework tailored for embedded devices like CPE routers and cable modems.",
        path: "/usr/local/bin/routersploit",
        cmd: "routersploit"
    },
    {
        name: "docsis",
        slug: "docsis",
        category: "adsl",
        status: "ready",
        desc: "Utility to compile and decompile DOCSIS binary configuration files to uncover hidden SNMP settings.",
        path: "/usr/bin/docsis",
        cmd: "docsis"
    },
    {
        name: "tftpd-hpa",
        slug: "tftpd-hpa",
        category: "adsl",
        status: "ready",
        desc: "Highly configurable TFTP server and client for intercepting or spoofing cable modem provisioning downloads.",
        path: "System Service",
        cmd: "systemctl status tftpd-hpa"
    },
    {
        name: "isc-dhcp-server",
        slug: "isc-dhcp-server",
        category: "adsl",
        status: "ready",
        desc: "Used to set up a rogue DHCP server injecting custom DOCSIS DHCP options (like Option 122 or 54) to direct modems.",
        path: "System Service",
        cmd: "systemctl status isc-dhcp-server"
    },
    {
        name: "yersinia",
        slug: "yersinia",
        category: "adsl",
        status: "ready",
        desc: "Powerful framework for exploiting Layer 2 protocols (DHCP exhaustion, STP/CDP/VTP manipulation) against the switching infrastructure.",
        path: "/usr/bin/yersinia",
        cmd: "yersinia"
    },
    {
        name: "ettercap",
        slug: "ettercap",
        category: "adsl",
        status: "ready",
        desc: "Comprehensive suite for man-in-the-middle attacks on LAN (e.g. ARP spoofing) to intercept unencrypted TFTP configuration downloads.",
        path: "System-wide",
        cmd: "ettercap-text-only"
    }
]
