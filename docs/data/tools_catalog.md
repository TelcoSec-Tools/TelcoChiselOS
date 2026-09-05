# TelcoChiselOS Default Tools Catalog

TelcoChiselOS includes **88 default tools** organized across 10 specialized functional domains. Tools marked `Ready` are pre-configured and executable immediately. Tools marked `Setup` feature automated first-run helper scripts.

## Software Defined Radio (SDR) & DSP (10 tools)

| Tool Name | Status | Command / Executable | Description |
| :--- | :---: | :--- | :--- |
| **GNU Radio 3.10** | `Ready` | `conda activate telcosec-sdr && gnuradio-companion` | The primary digital signal processing (DSP) framework and graphical flowchart design suite for SDR transceiver implementation. |
| **SoapySDR** | `Ready` | `SoapySDRUtil --info` | A vendor-neutral SDR hardware abstraction layer and API, allowing software built against it to work with a wide range of transceivers. |
| **UHD (USRP Hardware Driver)** | `Ready` | `uhd_usrp_probe --args="type=b200"` | Official device driver and interface software for Ettus Research USRP software-defined radios (B210, X310, etc.), compiled from source. |
| **HackRF Host Tools** | `Ready` | `hackrf_info` | Command-line configuration and operation tools for the Great Scott Gadgets HackRF One, including firmware flashers and receiver utilities. |
| **gr-gsm Tools** | `Ready` | `grgsm_livemon` | Gnu Radio blocks and scripts for receiving, decoding, and analyzing the GSM air interface (2G). Includes live channel monitoring. |
| **Kalibrate RTL (kal)** | `Ready` | `kal -s GSM900` | Scans for GSM base stations and uses their broadcasts to calibrate the local oscillator frequency offset on RTL-SDR dongles. |
| **GQRX** | `Ready` | `gqrx` | An open source software defined radio (SDR) receiver GUI and spectrum analyzer powered by GNU Radio and Qt. |
| **Inspectrum** | `Ready` | `inspectrum --help` | Offline I/Q file visualizer and signal analyzer for measuring symbol periods, FSK frequency deviation, and preamble detection. |
| **URH (Universal Radio Hacker)** | `Ready` | `urh --help` | Complete wireless protocol reverse engineering suite supporting demodulation, bit extraction, frame parsing, and signal replay. |
| **Gpredict** | `Ready` | `gpredict --help` | Real-time satellite tracking and orbit prediction system for calculating Doppler frequency shifts in 3GPP NTN and satellite SDR captures. |

## 2G / GSM Security (5 tools)

| Tool Name | Status | Command / Executable | Description |
| :--- | :---: | :--- | :--- |
| **YateBTS** | `Setup` | `sudo yatebts-install` | Open-source GSM/UMTS BTS implementation built on the Yate telephony engine. Optimized for BladeRF A4 with a dedicated hardware config. |
| **OpenBTS** | `Setup` | `sudo openbts-install` | Pioneering open-source GSM base transceiver station. Implements the Um air interface enabling rogue GSM cell and protocol audit scenarios. |
| **Osmocom GSM Stack** | `Ready` | `osmo-bsc --help` | Complete Osmocom GSM network stack: OsmoBSC, OsmoMSC, OsmoHLR, OsmoBTS-TRX. Supports osmo-trx-bladerf for BladeRF A4 hardware. |
| **Kalibrate GSM** | `Ready` | `kal-gsm -s GSM900 -g 40` | GSM-band frequency offset calibration tool using broadcast channel timing from live base stations. Complements kalibrate-rtl for calibrating BladeRF. |
| **OsmocomBB** | `Ready` | `sudo osmocombb-install` | Osmocom GSM Mobile Station baseband protocol stack, providing layer 1-3 mobile phone emulation and CCCH/BCCH channel scanning. |

## 4G LTE Security (5 tools)

| Tool Name | Status | Command / Executable | Description |
| :--- | :---: | :--- | :--- |
| **srsUE** | `Ready` | `srsue /etc/srsran/ue.conf` | Software-defined LTE UE (User Equipment) that connects to real or simulated eNodeBs. Used for protocol testing, attach procedures, and downlink captures. |
| **LTE-CellScanner** | `Ready` | `LTE-CellSearch -s 2650e6` | Open-source LTE cell searcher and MIB/SIB decoder. Scans a frequency range and decodes cell IDs, bandwidth, and system information blocks. |
| **LTESniffer** | `Ready` | `ltesniffer -A 2 -f 2630e6 -C -m 0` | Open-source LTE downlink and uplink sniffer. Decodes physical layer frames and logs RRC, NAS, and user-plane traffic to PCAP. |
| **SCAT** | `Ready` | `scat -t qc -d /dev/ttyUSB0 -o capture.pcap` | DIAG protocol parser for Qualcomm and Samsung modems. Decodes OTA messages from USB-connected phones to PCAP with full NAS/RRC content. |
| **Modmobmap** | `Ready` | `modmobmap -m /dev/ttyUSB1` | Maps 2G/3G/4G cells visible to a USB modem by issuing AT commands. Generates cell-tower geolocation data and signal reports. |

## 5G NR Security & Fuzzing (5 tools)

| Tool Name | Status | Command / Executable | Description |
| :--- | :---: | :--- | :--- |
| **UERANSIM** | `Ready` | `nr-gnb -c /etc/telcosec/ueransim/gnb.yaml` | The most complete open-source 5G SA UE and gNB simulator. Emulates full N1/N2/N3 interfaces, compatible with Open5GS. Pre-configured for test PLMN 001/01. |
| **GTP5G Kernel Module** | `Setup` | `sudo gtp5g-load` | Linux kernel module implementing the GTP-U encapsulation layer required by UERANSIM and free5GC for 5G user-plane forwarding. |
| **OAI UE (OpenAirInterface)** | `Setup` | `sudo oai-install` | OpenAirInterface 5G NR UE implementation from EURECOM. Full PHY/MAC/RLC stack for 5G SA and NSA testing with real radio hardware. |
| **my5G-RANTester** | `Ready` | `my5g-rantester --help` | Scalable 5G Standalone multi-UE and gNodeB simulator for load testing and traffic generation over N1, N2, and N3 interfaces. |
| **mitmproxy (5G SBI)** | `Ready` | `mitmproxy --version` | Interactive HTTP/2, mTLS, and WebSockets interception proxy tailored for 5G Service Based Architecture (SBI) API auditing. |

## Baseband & UE Firmware Analysis (13 tools)

| Tool Name | Status | Command / Executable | Description |
| :--- | :---: | :--- | :--- |
| **FirmWire Emulation** | `Ready` | `firmwire --help` | A baseband firmware emulation and fuzzing platform. Emulates Samsung Shannon and MediaTek modems under QEMU, enabling analysis of baseband OTA packets. |
| **QCSuper** | `Ready` | `qcsuper --help` | Qualcomm diagnostic protocol log parser that generates PCAP files from baseband OTA messages sniffed from a phone connected via USB. |
| **MTKClient** | `Ready` | `mtk --help` | A powerful dump, flash, partition editor, and bootloader/BROM bypass tool for MediaTek (MTK) chipset devices. |
| **Balong-Flash & Balongtool** | `Ready` | `balong-flash --help` | Firmware compilation, modification, and direct USB flasher utilities targeting Huawei Balong-based LTE modems and routers. |
| **Heimdall (Samsung)** | `Ready` | `heimdall detect` | Open-source, cross-platform Samsung Odin replacement for flashing firmware on Samsung devices in Download Mode. |
| **ADB & Fastboot** | `Ready` | `adb devices -l` | Android Debug Bridge and Fastboot tools for communicating with Android devices in normal, recovery, and bootloader modes. |
| **EDL (Qualcomm Emergency Download)** | `Ready` | `edl --help` | Comprehensive Qualcomm EDL/9008 mode toolkit for reading, writing, and erasing partitions on Snapdragon devices via Sahara/Firehose protocols. |
| **SIMTester** | `Ready` | `simtester` | Java-based SIM card security audit tool from SRLabs. Tests for roaming, OTA update vulnerabilities, and SIM application exploits. |
| **AT Command Console** | `Ready` | `at-console /dev/ttyUSB0` | Interactive AT command terminal (minicom) pre-configured for modem control. Supports querying IMEI, network registration, signal strength, and USSD. |
| **Gammu** | `Ready` | `gammu --port /dev/ttyUSB0 --connection at115200 identify` | Universal mobile device manager supporting SMS sending/receiving, USSD queries, call management, and phonebook access via AT commands. |
| **atinout** | `Ready` | `echo 'AT+CGMI' | atinout - /dev/ttyUSB0 -` | Quick command-line tool to send AT commands to a modem and capture the output. Excellent for scripting USSD or SMS tasks. |
| **ModemManager GUI** | `Ready` | `modem-manager-gui` | Graphical frontend for ModemManager, dbus, and NetworkManager. Allows sending SMS, USSD, and reading SIM contacts directly from the desktop. |
| **SP Flash Tool (Helper)** | `Setup` | `spflashtool-install` | Proprietary flash tool for MediaTek devices. The pre-installed helper script provides download links and extraction instructions. |

## Core Signaling & Protocol Auditing (14 tools)

| Tool Name | Status | Command / Executable | Description |
| :--- | :---: | :--- | :--- |
| **srsRAN 4G/5G Simulator** | `Setup` | `srsenb --help` | Full open-source SDR-based 4G/5G mobile network simulator implementing gNodeB, eNodeB, and User Equipment (UE). Suitable for virtual cell testing. |
| **Wireshark & TShark** | `Ready` | `wireshark` | World-class packet sniffer customized with layout profiles displaying GSMTAP, 5G NAS, Diameter codes, and GTP headers. |
| **SIPVicious** | `Ready` | `svmap --help` | Audit toolset for SIP-based VoIP systems. Designed to scan target networks, brute-force extensions, and audit registration systems. |
| **sctpscan** | `Ready` | `sctpscan --help` | A fast SCTP port scanner to map host capabilities and discover ports running S1AP, NGAP, Diameter, or M3UA SIGTRAN protocols. |
| **SigPloit** | `Ready` | `sudo sigploit` | Signaling exploitation framework targeting SS7, Diameter, and GTP protocols to audit core telecom networks for routing vulnerabilities. |
| **Diafuzzer** | `Ready` | `diafuzzer --help` | Diameter protocol fuzzer written by Orange Security, designed to test core interfaces (S6a, Gx, Gy) for vulnerability to malformed requests. |
| **Scapy (with SS7/Diameter modules)** | `Ready` | `scapy` | Interactive packet manipulation program extended to support construction of custom MAP, TCAP, M3UA, and Diameter network frames. |
| **5Ghoul Fuzzer Wrapper** | `Setup` | `sudo 5ghoul-run --Attack.Name=NAS_5GS_Fuzz` | Custom launcher wrapper that simplifies executing the 5Ghoul fuzzer, automatically patching configurations for BladeRF and USRP transceivers. |
| **Open5GS Core Network** | `Setup` | `cd /opt/telcosec/open5gs/docker_open5gs && sudo docker compose up -d` | A complete open-source implementation of 4G EPC and 5G Core Network functions (AMF, SMF, UPF, UDM, HSS) built with high performance in C. |
| **Docker & Docker Compose** | `Ready` | `docker ps` | Containerization engine pre-configured for non-root management. Used to spin up large-scale core network elements quickly. |
| **Telecom Wordlists** | `Ready` | `ls -lR /usr/share/wordlists/telecom/` | Bundled telecom-specific wordlist collection covering carrier APNs, VoIP/SIP credentials, RAN element passwords, SIM OTA test keys, hardware defaults, PLMNs/IMSI prefixes, and protocol-level lists for 5G NAS, GTP, SS7, Diameter, SMS, and USSD. Includes telcosec-apn-permutator and telcosec-imsi-generator helper scripts on PATH. |
| **Kismet** | `Ready` | `sudo kismet -c mon0` | Wireless network detector, sniffer, and intrusion detection system. Captures raw 802.11 frames on mon0 and logs device fingerprints. |
| **tcpdump** | `Ready` | `sudo tcpdump -i mon0 -w capture.pcap` | CLI packet capture tool. Used in TelcoSec scripts to capture raw traffic on the monitoring interface and pipe to Wireshark. |
| **TelcoSec Profile Switcher** | `Ready` | `sudo telcosec-profile status` | Operational security profile switcher to toggle between Lab Mode (SDR low-latency, rp_filter=0) and Field Mode (hardened firewall, strict rp_filter, rate-limited SSH). |

## SIM & eSIM Smartcard Auditing (7 tools)

| Tool Name | Status | Command / Executable | Description |
| :--- | :---: | :--- | :--- |
| **Osmocom SIMtrace 2 Host** | `Ready` | `simtrace2-list` | Host-side companion daemon and sniffer utilities to inspect smartcard ISO-7816 communication between SIM readers and actual handsets. |
| **Osmocom pySim** | `Ready` | `pySim-shell --help` | An interactive smartcard management shell and scripting library capable of reading, writing, and configuring USIM/SIM credentials. |
| **lpac (eSIM LPA)** | `Ready` | `lpac profile list` | An independent Local Profile Assistant (LPA) for eSIM profiles, implementing GSMA SGP.22 specifications over PC/SC readers. |
| **SIMurai (swsim)** | `Ready` | `simurai --help` | A software SIM platform that emulates a full UICC/SIM card speaking ISO-7816 over TCP/IP, plus a virtual PC/SC IFD driver (swicc-pcsc) that exposes the emulated card to any pcscd-aware tool. |
| **PCSC Daemon (pcscd)** | `Ready` | `systemctl status pcscd` | Smartcard interface daemon facilitating reader communication between hardware card slot readers and software tools. |
| **pcsc-tools** | `Ready` | `pcsc_scan -v` | Smartcard reader discovery toolset featuring pcsc_scan to monitor card insertions and decode Answer-to-Reset (ATR) strings. |
| **OpenSC** | `Ready` | `pkcs11-tool -L` | Comprehensive smartcard and UICC management library and tools (pkcs11-tool, opensc-tool, opensc-explorer) for cryptographic tokens. |

## VoIP & SIP Security (8 tools)

| Tool Name | Status | Command / Executable | Description |
| :--- | :---: | :--- | :--- |
| **Zoiper5** | `Ready` | `zoiper5` | Commercial-grade VoIP softphone supporting SIP and IAX2. Used for testing SIP registrars, call flows, and intercepted credential replays. |
| **SIPp** | `Ready` | `sipp -h` | SIP load tester and traffic generator. Sends scripted SIP scenarios (INVITE storms, registration floods) to audit VoIP infrastructure. |
| **Linphone** | `Ready` | `linphone` | Open-source SIP softphone used for voice and video over IP. Useful as an alternative to Zoiper for testing PBX configurations and SIP registrars. |
| **Twinkle** | `Ready` | `twinkle` | A SIP softphone for voice over IP and instant messaging communications, useful for VoIP security and signaling audits. |
| **Baresip** | `Ready` | `baresip` | A modular, command-line based SIP user agent with audio and video support, ideal for scriptable VoIP and PBX testing. |
| **sipsak** | `Ready` | `sipsak --help` | SIP swiss army knife command-line tool for sending OPTIONS health checks, tracerouting SIP hops, and stress testing SIP proxies. |
| **voiphopper** | `Ready` | `voiphopper --help` | Security assessment tool that mimics IP phone behavior by spoofing Cisco CDP and LLDP-MED packets to hop into VoIP voice VLANs. |
| **rtpbleed** | `Ready` | `rtpbleed --help` | Scanner and audio extractor targeting RTP Bleed vulnerabilities in media proxies and SBCs to discover leaky RTP ports. |

## Telecom Middleware & OSS Management (3 tools)

| Tool Name | Status | Command / Executable | Description |
| :--- | :---: | :--- | :--- |
| **Nokia NetAct CLI** | `Ready` | `nokia-netact-cli <host>` | Wrapper for connecting to Nokia NetAct OSS systems using standard telecom administrative protocols. |
| **Ericsson ENM CLI** | `Ready` | `ericsson-enm-cli <host>` | Wrapper for connecting to Ericsson Network Manager (ENM) infrastructure via SSH. |
| **Huawei U2000 CLI** | `Ready` | `huawei-u2000-cli <host>` | Wrapper for accessing Huawei U2000 management interfaces using telnet or SSH fallback. |

## Broadband, ADSL & DOCSIS / HFC Security (18 tools)

| Tool Name | Status | Command / Executable | Description |
| :--- | :---: | :--- | :--- |
| **RDNSx** | `Ready` | `rdnsx` | Rapid DNS Reverse Resolver for fast network enumeration and reconnaissance. |
| **Macchanger** | `Ready` | `macchanger --help` | Utility for viewing/manipulating the MAC address of network interfaces to bypass sticky-MAC port security. |
| **VLAN (vconfig)** | `Ready` | `vconfig` | VLAN hopping and manipulation tool for executing attacks against DSLAM and Open vSwitch configurations. |
| **Asleap** | `Ready` | `asleap -h` | Performs offline dictionary attacks against captured PPPoE MS-CHAPv2 challenge/response hashes. |
| **FreeRADIUS Utils** | `Ready` | `radtest -h` | Includes radtest and radclient to craft malicious RADIUS Access-Request packets or test dictionary attacks. |
| **Hashcat** | `Ready` | `hashcat -h` | Advanced password recovery utility supporting multiple algorithms including RADIUS shared secrets and MS-CHAPv2. |
| **John the Ripper** | `Ready` | `john` | Fast password cracker, useful for intercepted RADIUS shared secrets or MS-CHAPv2 hashes. |
| **PPPoE Tools** | `Ready` | `pppoe-setup` | Includes ppp and pppoe tools to establish rogue PPPoE sessions, acting as a rogue CPE. |
| **Nikto** | `Ready` | `nikto -H` | Web server scanner which performs comprehensive tests against web servers for multiple items, including CPE local Web UIs. |
| **Gobuster** | `Ready` | `gobuster help` | Directory/File, DNS and VHost busting tool written in Go, for directory enumeration on CPE or GenieACS dashboards. |
| **SNMP Check** | `Ready` | `snmpcheck -h` | Tool to automate the process of gathering information via SNMP protocols, exploiting intentionally weak community strings. |
| **RouterSploit** | `Ready` | `routersploit` | Exploitation framework tailored for embedded devices like CPE routers and cable modems. |
| **docsis** | `Ready` | `docsis` | Utility to compile and decompile DOCSIS binary configuration files to uncover hidden SNMP settings. |
| **tftpd-hpa** | `Ready` | `systemctl status tftpd-hpa` | Highly configurable TFTP server and client for intercepting or spoofing cable modem provisioning downloads. |
| **isc-dhcp-server** | `Ready` | `systemctl status isc-dhcp-server` | Used to set up a rogue DHCP server injecting custom DOCSIS DHCP options (like Option 122 or 54) to direct modems. |
| **yersinia** | `Ready` | `yersinia` | Powerful framework for exploiting Layer 2 protocols (DHCP exhaustion, STP/CDP/VTP manipulation) against the switching infrastructure. |
| **ettercap** | `Ready` | `ettercap-text-only` | Comprehensive suite for man-in-the-middle attacks on LAN (e.g. ARP spoofing) to intercept unencrypted TFTP configuration downloads. |
| **mausezahn (mz)** | `Ready` | `mz --help` | High-speed carrier Ethernet and multi-protocol packet crafter supporting 802.1Q tagged VLANs, QinQ, MPLS labels, and BPDU injection. |

