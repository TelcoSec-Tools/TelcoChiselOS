/**
 * Dynamic metadata and guides for the 88 tools in the TelcoChisel catalog.
 * Provides high-traffic keywords, detailed guides, troubleshooting, and FAQs.
 */

const specificMetadata = {
  "gnu-radio-companion": {
    keywords: ["GNU Radio companion tutorial", "SDR digital signal processing", "GNU Radio flowchart design", "SDR flowchart suite"],
    overview: "GNU Radio is the premier free & open-source software development toolkit that provides signal processing blocks to implement software-defined radios. It is used to design, compile, and run real-time digital signal processing flowgraphs connecting to hardware transceivers.",
    config: [
      "Launch the Conda virtual environment to access driver bindings: conda activate telcosec-sdr",
      "Launch the graphical companion interface: gnuradio-companion",
      "Create or open a flowgraph (.grc file) and set the sample rate, source block (e.g. USRP Source), and sink blocks."
    ],
    troubleshooting: "If running in a virtual machine, high sample rates will cause 'O' (overrun) indicators, signifying dropped packets. Reduce sample rates to 1-2 MSps or run on bare metal.",
    faq: [
      { q: "Why is GNU Radio sandboxed in a Conda environment?", a: "To prevent conflicts between GNU Radio's Python 3 dependencies and the host system Python environment, ensuring stable driver runtimes." },
      { q: "How do I connect my SDR to GNU Radio?", a: "Ensure your SDR udev rules are active, activate the telcosec-sdr Conda environment, and place a SoapySDR Source or USRP Source block in your flowchart." }
    ]
  },
  "soapysdr": {
    keywords: ["SoapySDR vendor neutral API", "SDR hardware abstraction layer", "SoapySDRUtil locate devices", "SDR API Linux"],
    overview: "SoapySDR is a vendor-neutral C/C++ library and API for Software Defined Radio devices. It provides a generalized hardware abstraction layer, allowing software applications to communicate with any supported SDR transceiver without rebuilding.",
    config: [
      "Verify that the system recognizes connected SDR hardware: SoapySDRUtil --find",
      "Print driver details and supported transceiver plugins: SoapySDRUtil --info",
      "Test transceiver streaming rate: SoapySDRUtil --rate=10e6 --direction=RX"
    ],
    troubleshooting: "If your device is not listed, make sure your user is in the 'plugdev' group and that the udev rules in /etc/udev/rules.d/50-telcosec-hw.rules have been reloaded.",
    faq: [
      { q: "What radios does SoapySDR support in TelcoChisel?", a: "It supports USRP, HackRF, BladeRF, LimeSDR, RTL-SDR, and PlutoSDR out of the box." },
      { q: "How do I list all available SoapySDR modules?", a: "Run SoapySDRUtil --info to see the list of loaded hardware support modules." }
    ]
  },
  "uhd-usrp-hardware-driver": {
    keywords: ["USRP hardware driver USRP B210", "Ettus Research SDR device driver", "uhd_usrp_probe test USRP", "UHD driver compile"],
    overview: "The USRP Hardware Driver (UHD) is the official device driver and API developed by Ettus Research for the USRP (Universal Software Radio Peripheral) family. It provides control and data streaming capabilities over USB or Ethernet interfaces.",
    config: [
      "Ensure the USRP B200/B210 is connected via USB 3.0.",
      "Activate the Conda workspace: conda activate telcosec-sdr",
      "Probe the device status and verify firmware version: uhd_usrp_probe --args=\"type=b200\""
    ],
    troubleshooting: "If the firmware is out of date, download the official images using uhd_images_downloader, or check USB connection details in dmesg.",
    faq: [
      { q: "How do I resolve UHD firmware mismatch errors?", a: "TelcoChisel includes pre-downloaded firmware images. Ensure they are loaded to /usr/share/uhd/images or run the built-in images downloader." },
      { q: "Does UHD work inside a VM?", a: "Yes, but VMware or VirtualBox must be configured for USB 3.1 xHCI passthrough, and sample rates must be kept low to avoid buffer underruns." }
    ]
  },
  "hackrf-host-tools": {
    keywords: ["HackRF One RF analysis tools", "hackrf_info firmware flash", "HackRF host tools Linux", "hackrf_transfer TX RX"],
    overview: "HackRF Host Tools consist of CLI command utilities for configuring, updating, and operating the Great Scott Gadgets HackRF One SDR. These tools allow flashing the firmware, controlling the clock, and executing raw RF transfers.",
    config: [
      "Verify connection and display the device serial number: hackrf_info",
      "Record a raw RF capture file (IQ data): hackrf_transfer -r capture.bin -f 433000000 -s 2000000",
      "Transmit a raw IQ sequence file: hackrf_transfer -t capture.bin -f 433000000 -s 2000000"
    ],
    troubleshooting: "Ensure you are using a high-quality USB cable. The HackRF One draws significant power and can fail to initialize on low-quality USB ports.",
    faq: [
      { q: "How do I update HackRF firmware in TelcoChisel?", a: "Use hackrf_spiflash -w <firmware.bin> to write a new firmware binary image directly to the HackRF's SPI flash." },
      { q: "Can I use HackRF Host Tools without root?", a: "Yes, custom udev rules are deployed to grant non-root users in the 'plugdev' group direct access." }
    ]
  },
  "gr-gsm-tools": {
    keywords: ["GSM air interface decoding gr-gsm", "grgsm_livemon GSM sniffing", "SDR GSM monitor", "gr-gsm Wireshark pipe"],
    overview: "gr-gsm is a set of blocks and tools for receiving, decoding, and analyzing the GSM air interface (2G). Built on GNU Radio, it decodes Downlink packets and forwards GSMTAP frames to Wireshark for analysis.",
    config: [
      "Activate the SDR workspace: conda activate telcosec-sdr",
      "Start the graphical live monitor: grgsm_livemon -f 945.2M -g 40",
      "Open Wireshark and filter by 'gsmtap' to view decoded GSM frames in real time."
    ],
    troubleshooting: "Ensure you have calibrated your RTL-SDR or HackRF oscillator frequency offset, otherwise gr-gsm will fail to lock onto the BCCH carrier frequency.",
    faq: [
      { q: "Which bands can gr-gsm monitor?", a: "It can monitor any GSM band (GSM850, GSM900, DCS1800, PCS1900) supported by your RF front-end." },
      { q: "Does gr-gsm decode encrypted traffic?", a: "No, gr-gsm decodes unencrypted control frames and broadcasts. Decrypting voice or SMS requires session key access." }
    ]
  },
  "kalibrate-rtl": {
    keywords: ["Kalibrate RTL frequency offset calibration", "kal GSM channel scanner", "RTL-SDR frequency drift correction", "kalibrate RTL-SDR tutorial"],
    overview: "Kalibrate-RTL (kal) scans for GSM base stations and uses their stable broadcast channel frequency references to calculate and calibrate the local oscillator frequency offset (PPM) of RTL-SDR transceivers.",
    config: [
      "Scan for active GSM base stations to identify calibration carriers: kal -s GSM900 -g 35",
      "Calculate the exact frequency offset of a specific channel: kal -c 12 -g 35",
      "Note the calculated PPM value and pass it to tools like gr-gsm (-p parameter)."
    ],
    troubleshooting: "If no channels are found, ensure an appropriate cellular antenna is connected and increase the gain (-g parameter).",
    faq: [
      { q: "Why is calibrating the RTL-SDR oscillator necessary?", a: "Cheap RTL-SDR dongles experience frequency drift due to temperature, causing tools to scan slightly off-frequency." },
      { q: "Can I use Kalibrate RTL with HackRF or USRP?", a: "No, Kalibrate RTL is specific to RTL-SDR. Use Kalibrate GSM (kal-gsm) for HackRF or BladeRF transceivers." }
    ]
  },
  "firmwire-emulation": {
    keywords: ["Baseband firmware fuzzing FirmWire", "Samsung Shannon MediaTek modem emulation", "FirmWire QEMU cellular audit", "baseband firmware analysis"],
    overview: "FirmWire is a state-of-the-art emulation and fuzzing platform for cellular baseband firmware. Running modems under QEMU, it intercepts Over-The-Air (OTA) packets to analyze, fuzz, and identify vulnerabilities in Shannon (Samsung) and MediaTek protocols.",
    config: [
      "Navigate to the FirmWire workspace: cd /opt/telcosec/firmwire",
      "Activate the python virtual environment: source venv/bin/activate",
      "Run FirmWire with an unpacked baseband modem binary: ./firmwire --help"
    ],
    troubleshooting: "Emulating a baseband firmware requires a decrypted modem memory dump (image). Ensure you have loaded the target firmware image into the workspace.",
    faq: [
      { q: "What chipsets does FirmWire support?", a: "It supports Samsung Shannon (found in Exynos devices) and MediaTek basebands." },
      { q: "Does FirmWire require high-performance hardware?", a: "Yes, baseband emulation runs a full QEMU system. At least 4 CPU cores and 8 GB RAM are recommended." }
    ]
  },
  "qcsuper": {
    keywords: ["QCSuper baseband protocol sniffer", "Qualcomm DIAG protocol parser PCAP", "Qualcomm baseband packet capture", "qcsuper USB sniffer"],
    overview: "QCSuper is a tool for capturing and parsing cellular protocol frames from Qualcomm-based smartphones. It speaks the proprietary Qualcomm DIAG protocol over USB to capture raw OTA network signaling packets (2G, 3G, 4G, 5G) into PCAP files.",
    config: [
      "Connect a Qualcomm device via USB and enable USB debugging and DIAG port mode.",
      "Check the DIAG serial port name (e.g. /dev/ttyUSB0).",
      "Capture packets to a PCAP file: qcsuper --adb --wireshark-live --info-raw-data"
    ],
    troubleshooting: "Ensure your phone is rooted and that the DIAG mode is active (usually activated via AT commands or device-specific service codes).",
    faq: [
      { q: "What protocols can QCSuper capture?", a: "It captures GSM, UMTS, LTE, and 5G NAS protocol layers, including RRC messages." },
      { q: "Can I pipe QCSuper captures into Wireshark live?", a: "Yes, the --wireshark-live parameter automatically spawns Wireshark and streams the packets in real time." }
    ]
  },
  "mtkclient": {
    keywords: ["MediaTek bootloader bypass MTKClient", "MTK bypass BROM utility", "MediaTek flash dump partition", "mtk tool read partition"],
    overview: "MTKClient is a powerful utility designed for MediaTek (MTK) chipset devices. It bypasses bootloader security using low-level BROM exploits, enabling partition dumping, firmware flashing, bootloader unlocking, and physical extraction.",
    config: [
      "Power off the MediaTek device completely.",
      "Run the client in read-partition mode: mtk r boot boot.img",
      "Hold the volume down button and connect the device via USB to trigger BROM bypass."
    ],
    troubleshooting: "If the bypass fails, try different button combinations (volume up + down) or check if udev rules for MediaTek USB devices are installed.",
    faq: [
      { q: "What chipsets does MTKClient support?", a: "Almost all MTK chips from older MT65xx to newer Helio and Dimensity chipsets." },
      { q: "Is root required on the host?", a: "Only udev access is required. TelcoChisel configures host access rules by default." }
    ]
  },
  "osmocom-simtrace-2-host": {
    keywords: ["Osmocom SIMtrace 2 SIM sniffing", "SIMtrace 2 card reader trace", "smartcard ISO-7816 sniffing", "simtrace2-list daemon"],
    overview: "Osmocom SIMtrace 2 Host tools contain companion daemons and command utilities to operate the SIMtrace 2 USB hardware. It captures ISO-7816 APDU communications between a mobile terminal and a physical SIM card, forwarding traces to Wireshark.",
    config: [
      "Connect the SIMtrace 2 hardware via USB.",
      "List the connected SIMtrace devices: simtrace2-list",
      "Run the sniffer daemon: simtrace2-sniff -i 127.0.0.1 -p 4729"
    ],
    troubleshooting: "If the device is not found, check the green status LED on the SIMtrace board and ensure your user is in the 'plugdev' group.",
    faq: [
      { q: "What hardware is required?", a: "The physical SIMtrace 2 board, FPC flat cable, and target SIM card." },
      { q: "What protocol is used to forward traces?", a: "It uses GSMTAP to wrap ISO-7816 smart card frames, allowing Wireshark to dissect SIM interactions." }
    ]
  },
  "osmocom-pysim": {
    keywords: ["pySim-shell USIM configuration", "Osmocom pySim SIM card programmer", "pySim read write USIM credentials", "USIM profile edit command"],
    overview: "Osmocom pySim is an interactive scripting suite and command shell for editing, provisioning, and auditing SIM, USIM, and ISIM cards. It supports raw APDU read/write, file system navigation, and security key modification.",
    config: [
      "Insert your SIM card into a PC/SC compliant USB reader.",
      "Launch the interactive pySim shell: pySim-shell -p 0",
      "Read card information: verify_adm_and_read_imsi or select USIM directory to dump parameters."
    ],
    troubleshooting: "To edit sensitive parameters (IMSI, K, OPc), you must supply the card-specific ADM (Administrative) PIN key.",
    faq: [
      { q: "Does pySim support eSIM?", a: "Yes, it has modules to read and interface with eSIM card structures." },
      { q: "Can I write keys to a retail SIM card?", a: "Retail SIMs are locked and lack writeable flash memory. You must use programmable sysmoUSIM or similar test cards." }
    ]
  },
  "lpac-esim-lpa": {
    keywords: ["lpac eSIM Local Profile Assistant", "GSMA SGP.22 eSIM client Linux", "lpac profile download eSIM", "eSIM LPA command PC/SC"],
    overview: "lpac is an open-source, independent Local Profile Assistant (LPA) implementing GSMA SGP.22 specifications. It communicates with eSIM (eUICC) chips over PC/SC smartcard readers to download, enable, disable, and delete profiles.",
    config: [
      "Insert an eSIM card or connect an eUICC board via USB PC/SC reader.",
      "List current profiles: lpac profile list",
      "Download a profile from a subscription server: lpac profile download --smdp <smdp-address> --code <matching-id>"
    ],
    troubleshooting: "If lpac fails with 'No card reader found', check that the pcscd system service is running.",
    faq: [
      { q: "What is an LPA?", a: "A Local Profile Assistant is the software responsible for communicating with eSIM cards to manage mobile network profiles." },
      { q: "Does lpac support standard QR activation codes?", a: "Yes, you can extract the activation code string from the QR code and pass it directly to the download command." }
    ]
  },
  "simurai-software-sim": {
    keywords: ["SIMurai software SIM emulation", "swsim virtual UICC ISO-7816", "swicc-pcsc virtual SIM card", "SIMurai emulator TCP"],
    overview: "SIMurai (swsim) is a software-defined UICC/SIM card simulator speaking ISO-7816 over TCP. Combined with a virtual PC/SC driver, it presents an emulated SIM containing custom subscriber profiles to cellular terminals or modems.",
    config: [
      "Launch the SIMurai daemon: simurai --profile test_5g_sa.json",
      "Check connection status on port 35000: netstat -antp | grep 35000",
      "Expose the card to pcscd using the swicc-pcsc virtual driver."
    ],
    troubleshooting: "Ensure the swicc-pcsc library is in the pcscd driver search directory, otherwise tools cannot see the virtual card.",
    faq: [
      { q: "Can I test SIM authentication protocols with SIMurai?", a: "Yes, it simulates Milenage authentication algorithms used in 3G, 4G, and 5G SA networks." },
      { q: "Can I inject malformed SIM files?", a: "Yes, you can edit the JSON profile representation to test modem handling of malformed EF (Elementary File) structures." }
    ]
  },
  "srsran-4g-5g-simulator": {
    keywords: ["srsRAN 5G simulator tutorial", "srsenb eNodeB LTE setup", "srsRAN SDR mobile network", "srsenb configuration parameters"],
    overview: "srsRAN is a highly optimized, open-source 4G and 5G software suite implementing eNodeB, gNodeB, and EPC/5GC core functions. It streams LTE/5G waveforms over SDR transceivers to build private or simulated cell sites.",
    config: [
      "Edit /etc/srsran/enb.conf with your SDR hardware settings.",
      "Launch the eNodeB simulator: srsenb /etc/srsran/enb.conf",
      "Check terminal output to ensure the USRP or BladeRF initializes without latency warnings."
    ],
    troubleshooting: "Real-time priorities must be enabled. Ensure your user belongs to the 'realtime' group to prevent sample drops.",
    faq: [
      { q: "What hardware is recommended for srsRAN?", a: "Ettus USRP B210 or BladeRF 2.0 micro are the standard transceivers for real-time cellular over-the-air links." },
      { q: "Does srsRAN support 5G Standalone?", a: "Yes, the srsRAN gNB can connect to an external 5G core network, such as Open5GS." }
    ]
  },
  "wireshark-tshark": {
    keywords: ["Wireshark GSMTAP 5G NAS protocol columns", "TShark command line packet capture", "telecom protocol dissection Wireshark", "GSMTAP column profiles"],
    overview: "Wireshark is the world's foremost packet analysis tool. In TelcoChisel, it is customized with specialized layout profiles for GSMTAP, 5G NAS, Diameter, GTP-C, and GTP-U protocols, presenting clean column views for cellular forensics.",
    config: [
      "Launch the graphical analyzer: wireshark",
      "Open a PCAP file containing telecom packets or select a live monitoring interface.",
      "Switch to the 'TelcoSec' profile from the profile menu to activate customized columns."
    ],
    troubleshooting: "Ensure your user is in the 'wireshark' group to execute non-root captures on network interfaces.",
    faq: [
      { q: "What is GSMTAP?", a: "GSMTAP is a frame encapsulation standard that wraps raw GSM, LTE, and 5G over-the-air packets in UDP headers, allowing Wireshark to dissect them." },
      { q: "How do I run a command-line packet trace?", a: "Use tshark -i <interface> -Y \"gsmtap or s1ap\" to extract cellular protocols directly in the terminal." }
    ]
  },
  "sipvicious": {
    keywords: ["SIPVicious VoIP SIP security scanner", "svmap scan SIP PBX", "SIP extension brute force", "voip penetration testing tool"],
    overview: "SIPVicious is a security auditing suite for Session Initiation Protocol (SIP) VoIP telephony networks. It discovers active SIP servers, sweeps for PBX extensions, and audits authentication configurations via dictionary attacks.",
    config: [
      "Scan a subnet for active SIP endpoints: svmap 192.168.1.0/24",
      "Brute-force extensions on an active target: svwar 192.168.1.100 --range 100-200",
      "Perform password auditing on an extension: svcrack 192.168.1.100 -u 101 -d wordlists/telecom/protocols/sip/sip-passwords.txt"
    ],
    troubleshooting: "Ensure you scan only authorized networks, as SIPvicious generates significant traffic that can trigger SIP server rate-limiting or firewall bans.",
    faq: [
      { q: "Does SIPVicious support encrypted SIP (TLS)?", a: "Yes, newer versions can target TLS and SRTP endpoints." },
      { q: "What is the default port scanned?", a: "It defaults to standard SIP port 5060 over UDP." }
    ]
  },
  "sigploit": {
    keywords: ["SS7 network vulnerability scanner SigPloit", "SigPloit telecom exploit framework", "SS7 Diameter GTP attack tool", "sigploit.py python execution"],
    overview: "SigPloit is a telecom signaling exploitation framework. It is designed to audit mobile core networks (SS7, Diameter, GTP) for vulnerabilities such as subscriber location tracking, call interception, and SMS routing manipulation.",
    config: [
      "Launch the framework: `sudo sigploit`",
      "Select the signaling protocol (e.g. SS7, Diameter, GTP).",
      "Configure the remote signaling gateway (STP/DEA) and run the attack module."
    ],
    troubleshooting: "SigPloit requires a direct connection to a signaling gateway (e.g. via SIGTRAN client config). It cannot audit networks over standard IP routes without gateway routing.",
    faq: [
      { q: "What attacks are supported?", a: "Location tracking (AnyTimeInterrogation), voice interception (SendRoutingInfoForSM), and profile modifications." },
      { q: "Which Python version is required?", a: "SigPloit relies on Python 2.7, which is now containerized seamlessly using Docker." }
    ]
  },
  "diafuzzer": {
    keywords: ["Diameter protocol fuzzer Diafuzzer Orange", "Diameter S6a Gx Gy audit", "diafuzzer.py python configuration", "telecom core network fuzzer"],
    overview: "Diafuzzer is an open-source Diameter protocol fuzzer originally created by Orange Security. It targets core network interfaces (S6a, Gx, Gy, Rx) to check if network functions crash or leak information when sent malformed Diameter AVPs.",
    config: [
      "Navigate to the Diafuzzer folder: cd /opt/telcosec/diafuzzer",
      "Run the fuzzer against a target HSS or PCRF: python3 diafuzzer.py -t 192.168.10.12 -p 3868 --interface s6a"
    ],
    troubleshooting: "Ensure the local Diameter client configuration file is edited to define appropriate Local Host Identity and Realm to pass authentication.",
    faq: [
      { q: "What is Diameter?", a: "Diameter is the authentication, authorization, and accounting (AAA) protocol used in 4G LTE and IMS networks, replacing legacy RADIUS." },
      { q: "Can I fuzz custom AVPs?", a: "Yes, you can edit the Diafuzzer dictionary XML files to inject custom Attribute-Value Pairs (AVPs)." }
    ]
  },
  "5ghoul-fuzzer": {
    keywords: ["5Ghoul 5G NR baseband fuzzer OAI", "5ghoul-run NAS fuzzing", "5G NR rogue base station fuzzer", "5ghoul-install USRP Bladerf"],
    overview: "5Ghoul is a security fuzzer targeting 5G NR baseband modems. It implements an OpenAirInterface (OAI) rogue base station to inject malformed RRC and NAS signaling packets over the air, revealing memory corruption and crash bugs in cellular devices.",
    config: [
      "Run the installer to pull and compile dependencies: sudo 5ghoul-install --radio BLADERF",
      "Add your target IMSI to the Open5GS subscriber database: sudo 5ghoul-add-subscriber",
      "Launch the fuzzer engine: sudo 5ghoul-run --Attack.Name=NAS_5GS_Fuzz"
    ],
    troubleshooting: "Running inside a VM causes USB timing jitter, which interrupts 5G NR signal sync. Use bare metal hardware.",
    faq: [
      { q: "What radios are compatible?", a: "Ettus USRP B210 and Nuand BladeRF micro xA4 are fully supported." },
      { q: "How long does compilation take?", a: "Compiling the patched OpenAirInterface code takes 20-40 minutes on first execution." }
    ]
  },
  "open5gs-core-network": {
    keywords: ["Open5GS 5G core network installation", "Open5GS 5G SA core configuration", "open5gs-start services mongodb", "open5gs-install helper script"],
    overview: "Open5GS is an open-source C-language implementation of 4G EPC and 5G Core Network functions. It includes AMF, SMF, UPF, UDM, HSS, and PCRF nodes, allowing researchers to simulate a complete standalone cellular core network.",
    config: [
      "Verify the Open5GS installation: open5gs-install",
      "Start all 5G SA core network elements: `sudo open5gs-start` (which uses docker compose under the hood)",
      "Access the web administration UI at http://localhost:3000 to manage subscribers."
    ],
    troubleshooting: "If services fail to start, check that MongoDB is active, as Open5GS uses MongoDB as its primary database for subscriber storage.",
    faq: [
      { q: "Does Open5GS support 5G Standalone?", a: "Yes, Open5GS implements complete 3GPP Release 16 Standalone (SA) and Non-Standalone (NSA) architectures." },
      { q: "Can I connect real cells to Open5GS?", a: "Yes, if you configure the AMF binding IP and have a compatible gNodeB transceiver." }
    ]
  },
  "telecom-wordlists": {
    keywords: ["telecom wordlists carrier APN", "APN permutation generator", "telcosec-apn-permutator script", "cellular IMSI generator list"],
    overview: "Telecom Wordlists are specialized dictionaries curated by TelcoSec for auditing telecommunications nodes. They contain default administrator credentials, carrier APNs, SIP PBX extensions, and typical SIM card OTA PINs/keys.",
    config: [
      "List the available directories: ls -l /usr/share/wordlists/telecom/",
      "Run the APN permutator to generate target APN lists: telcosec-apn-permutator --carrier verizon",
      "Generate IMSI prefixes for target PLMNs: telcosec-imsi-generator --mcc 310 --mnc 410"
    ],
    troubleshooting: "Large wordlists may be gzipped to save space. Use zcat or gunzip before feeding them to scanning utilities.",
    faq: [
      { q: "What is an APN?", a: "An Access Point Name is the gateway identifier used by mobile devices to establish data connections on 4G/5G networks." },
      { q: "Where are these lists located?", a: "They are stored globally in the filesystem at /usr/share/wordlists/telecom/." }
    ]
  },
  "sctpscan": {
    keywords: ["SCTP port scanner sctpscan", "sctpscan command line parameters", "SIGTRAN S1AP NGAP ports", "cellular core interface scan"],
    overview: "sctpscan is a specialized network utility optimized for the Stream Control Transmission Protocol (SCTP). It probes cellular signaling gateways to identify open SCTP ports hosting S1AP (LTE), NGAP (5G), M3UA (SS7), or Diameter interfaces.",
    config: [
      "Scan a target IP for open SCTP ports: sctpscan 192.168.10.20",
      "Specify custom port ranges: sctpscan -p 29000-30000 192.168.10.20",
      "Save scan results to file: sctpscan -o results.txt 192.168.10.20"
    ],
    troubleshooting: "Ensure the kernel sctp module is loaded (done automatically by TelcoChisel) before running sctpscan.",
    faq: [
      { q: "Why use sctpscan instead of nmap?", a: "While nmap supports SCTP scanning, sctpscan is faster and handles SCTP multi-homing probes more reliably." },
      { q: "What are common SCTP ports scanned?", a: "3868 (Diameter), 29097 (M3UA), 36412 (S1AP), and 38412 (NGAP)." }
    ]
  },
  "ueransim": {
    keywords: ["UERANSIM 5G NR gNodeB emulator", "UERANSIM 5G SA UE simulator", "nr-gnb configuration yaml", "UERANSIM Open5GS integration"],
    overview: "UERANSIM is the leading open-source 5G Standalone (SA) user equipment (UE) and radio access network (gNodeB) simulator. It implements the N1, N2, and N3 interfaces, allowing complete software-defined testing of 5G SA cores.",
    config: [
      "Configure your AMF binding IP in /etc/telcosec/ueransim/gnb.yaml.",
      "Start the simulated gNodeB: nr-gnb -c /etc/telcosec/ueransim/gnb.yaml",
      "Launch a simulated UE to attach to the network: nr-ue -c /etc/telcosec/ueransim/ue.yaml"
    ],
    troubleshooting: "Ensure the gtp5g kernel module is loaded on the host, otherwise UERANSIM cannot forward user-plane data via the N3 interface.",
    faq: [
      { q: "Does UERANSIM require an SDR transceiver?", a: "No, UERANSIM is a pure software simulation of the 5G radio layer, sending packets over IP tunnels." },
      { q: "Can UERANSIM execute network traffic?", a: "Yes, it creates a virtual tun interface (e.g. uesimtun0) on the host to route standard IP packets through the simulated gNodeB and Open5GS Core." }
    ]
  },
  "inspectrum": {
    keywords: ["Inspectrum SDR visualizer", "offline I/Q spectrograph", "symbol rate preamble analysis", "SigMF file viewer"],
    overview: "Inspectrum is a dedicated offline spectral visualizer and analyzer for captured I/Q radio signals. It provides an intuitive, high-resolution spectrogram view with interactive cursors to measure symbol rates, identify preamble structures, and export demodulated symbols to SigMF format.",
    config: [
      "Open an I/Q capture file: inspectrum capture.sigmf",
      "Adjust FFT size, zoom, and time resolution sliders in the UI.",
      "Enable cursors (Overlay -> Add cursor) to measure frequency shift and symbol duration."
    ],
    troubleshooting: "For large captures (>2 GB), ensure the file is on a fast NVMe drive or Toram RAM disk to prevent UI buffering pauses.",
    faq: [
      { q: "What file formats does Inspectrum support?", a: "Inspectrum supports raw complex float32/int16 files, cs8/cs16 captures, and standard SigMF metadata." },
      { q: "How do I calculate symbol rate in Inspectrum?", a: "Place the symbol cursor overlay over a train of symbols and adjust the rate slider until the vertical markers align with the signal transitions." }
    ]
  },
  "urh": {
    keywords: ["Universal Radio Hacker URH", "wireless protocol reverse engineering", "SDR demodulation replay", "FSK ASK PSK decoder"],
    overview: "Universal Radio Hacker (URH) is a complete wireless protocol investigation suite designed for rapid reverse engineering of unknown RF communications. It automates demodulation of ASK, FSK, and PSK signals, decodes packet structures, infers protocol state machines, and generates replay transmissions.",
    config: [
      "Launch URH via its launcher or wrapper: urh",
      "In the Signal tab, record live RF using your connected SDR (HackRF, RTL-SDR, USRP) or open an existing capture.",
      "Switch to Analysis tab to view auto-detected bits, configure packet sync words, and assign fields (Length, Address, Payload, CRC)."
    ],
    troubleshooting: "If URH crashes on launch, verify it is launched via /usr/local/bin/urh which activates the telcosec-sdr conda environment.",
    faq: [
      { q: "Can URH transmit signals for replay attacks?", a: "Yes, using half-duplex or full-duplex SDRs like HackRF, BladeRF, or USRP, URH can replay edited packets directly from the Generator tab." },
      { q: "Does URH support custom CRC algorithms?", a: "Yes, URH includes a built-in CRC calculator and brute-forcer to reverse engineer unknown checksum polynomials." }
    ]
  },
  "gpredict": {
    keywords: ["Gpredict satellite tracking", "real-time Doppler shift prediction", "satcom 3GPP NTN ground station", "TLE orbit propagation"],
    overview: "Gpredict is a real-time satellite tracking and orbit propagation application utilizing NORAD SGP4/SDP4 models. For telecom security researchers auditing satellite communications and 3GPP Non-Terrestrial Networks (NTN), it predicts orbital passes, calculates real-time Doppler frequency shifts, and controls antenna rotators and SDR receivers.",
    config: [
      "Launch Gpredict from the desktop menu or CLI: gpredict",
      "Update NORAD Two-Line Element (TLE) satellite data: Edit -> Update TLE data from network.",
      "Configure radio control: Preferences -> Interfaces -> Radios, connecting to GQRX (port 7356) for automated Doppler frequency tuning."
    ],
    troubleshooting: "Ensure system clock is synchronized via NTP before tracking. A clock offset of even a few seconds will introduce significant satellite pointing and Doppler calculation errors.",
    faq: [
      { q: "How does Gpredict compensate for Doppler shift in SDR captures?", a: "Gpredict connects to GQRX or GNU Radio via TCP rigctld protocol, dynamically steering the receiver frequency as the satellite passes overhead." },
      { q: "Can Gpredict track LEO telecom constellations (Starlink, Iridium)?", a: "Yes, any satellite with published NORAD TLE orbital data can be tracked in real time." }
    ]
  },
  "pcsc-tools": {
    keywords: ["pcsc_scan smartcard monitor", "Answer-to-Reset ATR decoder", "PC/SC smartcard reader diagnostic", "UICC card detection"],
    overview: "pcsc-tools is a suite of diagnostic utilities for PC/SC smartcard subsystems. Its primary tool, pcsc_scan, polls connected CCID readers, monitors card insertion/removal events, and instantly decodes the ISO 7816 Answer-to-Reset (ATR) string against an extensive smartcard database to identify card manufacturer, protocol capabilities (T=0/T=1), and electrical parameters.",
    config: [
      "Start or check the PC/SC daemon: sudo systemctl status pcscd",
      "Run real-time smartcard prober: pcsc_scan",
      "Insert a physical SIM/USIM to view the decoded ATR and card profile."
    ],
    troubleshooting: "If pcsc_scan outputs 'SCardEstablishContext: Service not available', restart the pcscd system service using 'sudo systemctl restart pcscd'.",
    faq: [
      { q: "What does an ATR tell a telecom researcher?", a: "The ATR indicates whether the card supports T=0 or T=1 protocols, historical bytes identifying carrier/vendor, and clock rate conversion factors." },
      { q: "Does pcsc_scan work with eSIM chips?", a: "Yes, eSIMs on removable M.2 or USB CCID evaluation boards report standard ISO 7816 ATRs and are fully recognized." }
    ]
  },
  "opensc": {
    keywords: ["OpenSC pkcs11-tool", "smartcard cryptographic token", "UICC security applet", "eSIM PKCS#11 key inspection"],
    overview: "OpenSC is a set of open-source tools and libraries for accessing smartcards and cryptographic hardware tokens. It exposes smartcard cryptographic functions through the PKCS#11 standard, enabling telecom auditors to inspect security applets, list RSA/ECC keys, verify PIN retry counters, and execute secure APDU commands on USIM/ISIM cards.",
    config: [
      "List detected cryptographic tokens and slots: pkcs11-tool -L",
      "Enumerate certificates and public keys stored on the card: pkcs11-tool --list-objects",
      "Inspect reader capabilities: opensc-tool -l"
    ],
    troubleshooting: "If OpenSC fails to recognize the card, verify whether the SIM contains a standard PKCS#15 structure or carrier-proprietary JavaCard applet.",
    faq: [
      { q: "What is pkcs11-tool used for in telecom audits?", a: "It audits cryptographic keys, digital certificates, and authentication PIN limits on smartcards without requiring manufacturer software." },
      { q: "Can OpenSC dump subscriber authentication keys (Ki / K)?", a: "No, Ki/K root keys are securely protected inside the SIM's tamper-resistant cryptographic module and cannot be read over APDU." }
    ]
  },
  "sipsak": {
    keywords: ["sipsak SIP swiss army knife", "SIP OPTIONS health check", "SIP traceroute proxy discovery", "VoIP registrar stress test"],
    overview: "sipsak is a command-line utility for testing and auditing SIP-based Voice over IP (VoIP) applications, proxies, and registrars. It sends customizable SIP requests (OPTIONS, REGISTER, INVITE) to measure round-trip times, perform SIP traceroutes, test registrar authentication, and execute stress tests against PBX endpoints.",
    config: [
      "Send SIP OPTIONS ping to target PBX: sipsak -v -s sip:192.168.1.100",
      "Execute SIP traceroute to map proxy hops: sipsak -T -s sip:target@carrier.com",
      "Test user registration authentication: sipsak -U -C sip:tester@carrier.com -a password -s sip:192.168.1.100"
    ],
    troubleshooting: "If sipsak receives no responses, verify local firewall allows outgoing UDP/TCP port 5060 and check that target PBX is not configured with fail2ban blocking aggressive pings.",
    faq: [
      { q: "What is a SIP traceroute?", a: "Similar to IP traceroute, sipsak increments the Max-Forwards header in SIP OPTIONS requests to discover all intermediate SIP proxies and SBCs in the call path." },
      { q: "Can sipsak generate high-load call tests?", a: "Yes, sipsak can run automated flood and stress tests using the -F flag to measure PBX crash limits." }
    ]
  },
  "voiphopper": {
    keywords: ["voiphopper voice VLAN hopping", "Cisco CDP LLDP-MED sniffing", "VoIP VLAN discovery", "802.1Q tagged voice interface"],
    overview: "voiphopper is an automated security validation tool designed to mimic the behavior of an IP phone to bypass network segmentation. It passively sniffs or actively queries Cisco Discovery Protocol (CDP) and LLDP-MED packets to discover VoIP Voice VLAN IDs, then automatically builds an 802.1Q tagged sub-interface, requests an IP address via DHCP on the voice network, and hops from the data VLAN into the voice VLAN.",
    config: [
      "Listen for Cisco CDP broadcast and auto-hop to voice VLAN: sudo voiphopper -i eth0 -c",
      "Discover Voice VLAN via LLDP-MED: sudo voiphopper -i eth0 -l",
      "Manually build 802.1Q sub-interface for known Voice VLAN (e.g. VLAN 200): sudo voiphopper -i eth0 -v 200"
    ],
    troubleshooting: "Ensure you run voiphopper with sudo/root privileges, as creating 802.1Q sub-interfaces requires CAP_NET_ADMIN. Verify the physical switch port is configured as an 802.1Q trunk or multi-VLAN port.",
    faq: [
      { q: "Why is voice VLAN hopping critical in telecom audits?", a: "IP PBX systems and SIP trunking servers are often protected by network isolation inside a dedicated voice VLAN. Hopping into this VLAN gives attackers direct access to phone signaling and audio." },
      { q: "How do switches assign voice VLANs?", a: "Switches broadcast CDP or LLDP-MED frames containing the Voice VLAN ID. When an IP phone boots, it tags its traffic with that VLAN ID." }
    ]
  },
  "rtpbleed": {
    keywords: ["rtpbleed media proxy vulnerability", "RTP stream bleeding scanner", "VoIP audio payload extraction", "CVE-2017-9936 RTP proxy"],
    overview: "rtpbleed is a targeted scanner and audio extraction engine for RTP Bleed vulnerabilities (CVE-2017-9936 and related proxy port bleeding flaws). In vulnerable media proxies (like older versions of RTPproxy, RTPEngine, or Kamailio/OpenSIPS media relays), an unauthenticated attacker sending 1-byte UDP probes to allocated RTP ports causes the proxy to latch onto the attacker's IP and redirect live call audio to the attacker.",
    config: [
      "Scan a media proxy port range for open, bleeding RTP sessions: rtpbleed -t 192.168.1.50 -p 10000-20000",
      "Capture and dump bleeding RTP audio payloads to disk: rtpbleed -t 192.168.1.50 -p 12344 --dump-audio /tmp/session.raw",
      "Run fast non-intrusive port audit: rtpbleed -t 192.168.1.50 --probe-only"
    ],
    troubleshooting: "High-latency WAN connections can cause false negatives. Set a higher socket timeout (-w 500) if scanning across public Internet links.",
    faq: [
      { q: "What is RTP Bleed?", a: "It is an architectural vulnerability where media proxies that implement symmetric RTP without source address validation latch onto the first packet received on a media port, redirecting the real call's audio stream to the attacker." },
      { q: "How can I play back raw audio dumped by rtpbleed?", a: "Import the raw capture into Audacity as 8000 Hz, 1-channel 8-bit (G.711 u-law / A-law) PCM." }
    ]
  },
  "mausezahn": {
    keywords: ["mausezahn mz packet crafter", "carrier Ethernet QinQ 802.1Q", "MPLS label stacking tool", "broadband network stress test"],
    overview: "mausezahn (mz) is a high-speed multi-protocol network traffic generator and raw packet crafter written in C. Designed for carrier-grade Ethernet and telecommunications transport auditing, it can craft custom 802.1Q tagged frames, nested QinQ double tags (802.1ad), MPLS label stacks, BPDU frames, and custom IP/TCP/UDP payloads at line rate.",
    config: [
      "Send tagged 802.1Q packets with VLAN ID 100: mz eth0 -t ip -B 10.0.0.1 -Q 100",
      "Craft double-tagged QinQ frame (Outer VLAN 100, Inner VLAN 20): mz eth0 -t ip -Q 100,20 -P 'TELCO_TEST'",
      "Generate MPLS labeled traffic (Label 500, Exp 3, TTL 64): mz eth0 -t ip -M 500:3:64"
    ],
    troubleshooting: "Ensure your network card supports hardware VLAN offloading or disable offloading via 'ethtool -K eth0 rxvlan off txvlan off' if custom tagged frames are dropped by the NIC.",
    faq: [
      { q: "Why is QinQ double-tagging important in telecom networks?", a: "Service providers use QinQ (802.1ad) to tunnel multiple customer VLANs through a carrier backbone. Fuzzing QinQ tags tests for VLAN hopping and bridge leakage." },
      { q: "Can mausezahn generate full line-rate traffic on Gigabit Ethernet?", a: "Yes, mausezahn is optimized in C and uses raw sockets, allowing it to saturate 1Gbps and 10Gbps interfaces with ease." }
    ]
  },
  "mitmproxy": {
    keywords: ["mitmproxy 5G SBI inspection", "5G Service Based Architecture HTTP/2", "5G Core REST OpenAPI proxy", "5G mTLS decryption proxy"],
    overview: "mitmproxy is an interactive SSL/TLS-capable intercepting HTTP/2 proxy. In 5G Standalone (SA) architectures, core network functions (AMF, SMF, NRF, UDM, AUSF) communicate over the Service Based Architecture (SBA/SBI) using HTTP/2 REST APIs and JSON payloads. Pre-configured with 3GPP OpenAPI schemas and certificates, mitmproxy decrypts, inspects, and modifies 5G SBI control plane traffic in real time.",
    config: [
      "Launch mitmproxy on default port 8080: mitmproxy -p 8080",
      "Launch with web UI interface: mitmweb -p 8080 --web-port 8081",
      "Intercept 5G NRF registration requests: mitmproxy --view-filter '~u /nnrf-nfm/v1/nf-instances'"
    ],
    troubleshooting: "If 5G Core network functions reject the proxy with TLS alert 46 (unknown certificate), export mitmproxy's CA certificate (~/.mitmproxy/mitmproxy-ca-cert.pem) and add it to the system trust store (/usr/local/share/ca-certificates/).",
    faq: [
      { q: "How is mitmproxy used in 5G Core pentesting?", a: "It intercepts HTTP/2 REST API communications between 5G network functions, allowing operators to tamper with subscriber profile updates, authentication tokens, and slice selection parameters." },
      { q: "Does mitmproxy support HTTP/2 multiplexing?", a: "Yes, it fully supports HTTP/2 multiplexed streams, server push, and header compression (HPACK) standard in 3GPP Rel-15 through Rel-18." }
    ]
  }
};

/**
 * Fallback metadata generator to ensure all 88 tools are populated with high-quality SEO/AEO content.
 */
export function getToolMetadata(tool) {
  const slug = tool.slug;
  if (specificMetadata[slug]) {
    return {
      slug,
      ...tool,
      ...specificMetadata[slug]
    };
  }

  // Generate high-quality fallback based on category
  const titleWords = tool.name.split(" ");
  const cleanName = titleWords.filter(w => !w.includes("(") && !w.includes(")")).join(" ");

  const categoryMap = {
    sdr: {
      kw: [`SDR ${cleanName} software`, `${cleanName} transceiver driver`, `Software Defined Radio cellular sniffing`, `I/Q signal processing ${cleanName}`],
      desc: `SDR digital signal processing and RF transceiver implementation tool.`,
      config: [`Activate the telcosec-sdr Conda environment: conda activate telcosec-sdr`, `Check connected SDR hardware: SoapySDRUtil --find`, `Execute command: ${tool.cmd}`],
      ts: "Verify USB 3.0 controller throughput, reload udev rules (/etc/udev/rules.d/50-telcosec-hw.rules), and monitor buffer overruns in VM environments."
    },
    baseband: {
      kw: [`baseband analysis ${cleanName}`, `mobile modem firmware audit ${cleanName}`, `cellular DIAG protocol capture`, `qualcomm mediatek baseband`],
      desc: `Cellular baseband firmware emulation, modem debugging, diagnostic serial logging, and partition extraction utility.`,
      config: [`Connect the target smartphone or modem via USB with DIAG or BROM mode enabled.`, `Verify serial port or USB endpoints using 'lsusb' or 'dmesg | tail -n 20'.`, `Execute command: ${tool.cmd}`],
      ts: "Ensure the modem's diagnostic USB interface is exposed. Handsets often require root access or dialing secret codes (*#*#3424#*#*) to enable DIAG/test mode."
    },
    sim: {
      kw: [`SIM card programming ${cleanName}`, `USIM smartcard audit`, `eSIM SGP.22 profile manager`, `ISO-7816 smartcard APDU`],
      desc: `Physical SIM, USIM, ISIM smartcard filesystem auditing, APDU tracing, and GSMA RSP eSIM profile management utility.`,
      config: [`Connect your CCID PC/SC smartcard reader or SIMtrace 2 probe to USB.`, `Verify smartcard daemon arbitration: systemctl status pcscd`, `Run utility: ${tool.cmd}`],
      ts: "Ensure the pcscd system service is active and the smartcard is firmly seated in the reader. Check pcsc_scan output for ATR response."
    },
    core: {
      kw: [`core network signaling ${cleanName}`, `SS7 Diameter GTP auditing`, `SCTP SIGTRAN port scanner`, `telecom core fuzzer`],
      desc: `Telecommunications core network signaling, interconnect protocol auditing (SS7, Diameter, GTP, SCTP), and network function fuzzing framework.`,
      config: [`Verify SCTP kernel stack configuration: lsmod | grep sctp`, `Set target signaling IP and point codes in tool configuration.`, `Execute signaling scan: ${tool.cmd}`],
      ts: "Check firewall rules on SCTP port 2905/3868/38412. Ensure your network gateway routes SCTP associations without NAT dropping multistream chunks."
    },
    "2g": {
      kw: [`2G GSM BTS emulator ${cleanName}`, `GSM air interface sniffer`, `OpenBTS YateBTS GSM`, `Osmocom Calypso baseband`],
      desc: `2G GSM air-interface auditing, software Base Transceiver Station (BTS) simulation, and legacy cellular protocol testing utility.`,
      config: [`Calibrate transceiver oscillator drift using kalibrate: kal -s GSM900`, `Configure ARFCN, MCC, MNC, and LAC in the transceiver config file.`, `Launch utility: ${tool.cmd}`],
      ts: "Verify RF clock stability (PPM error < 2). Operating without an external TCXO or GPSDO on HackRF will cause mobile handsets to reject cell selection."
    },
    "4g": {
      kw: [`4G LTE protocol analyzer ${cleanName}`, `srsRAN LTE cell scanner`, `LTE downlink sniffer`, `RRC S1AP packet dissector`],
      desc: `4G LTE Radio Access Network testing, downlink sniffing, RRC/NAS ASN.1 decoding, and software User Equipment (UE) simulation utility.`,
      config: [`Configure EARFCN carrier frequency and RF front-end gain in the config file.`, `Ensure low-latency kernel privileges: id | grep realtime`, `Launch LTE tool: ${tool.cmd}`],
      ts: "Reduce RF bandwidth (e.g. from 20 MHz to 5 MHz) if USB 3.0 controllers drop samples. Avoid running 4G high-rate PHY layers inside virtual machines without passthrough."
    },
    "5g": {
      kw: [`5G NR standalone simulator ${cleanName}`, `5G SA gNodeB emulator`, `5G NGAP NAS fuzzer`, `Open5GS UERANSIM 5G`],
      desc: `5G Standalone (SA) and Non-Standalone (NSA) Next Generation Radio Access Network (NG-RAN), UE emulation, and Service Based Architecture (SBA) audit utility.`,
      config: [`Inspect YAML configuration for 5G PLMN (default 001/01) and AMF/gNB IP bindings.`, `Verify TUN interface or GTP5G kernel module if testing user plane forwarding.`, `Execute 5G test suite: ${tool.cmd}`],
      ts: "Ensure the 5G Core AMF SCTP port (38412) is accessible. Confirm gtp5g kernel module is loaded for UPF user-plane acceleration."
    },
    adsl: {
      kw: [`wireline broadband audit ${cleanName}`, `DOCSIS cable modem config`, `PPPoE MS-CHAPv2 cracker`, `carrier Ethernet QinQ 802.1Q`],
      desc: `Wireline broadband infrastructure testing, CPE router exploitation, DOCSIS cable modem configuration, PPPoE discovery, and carrier Ethernet/QinQ audit utility.`,
      config: [`Connect Ethernet interface to the broadband testbed or target DSLAM/CMTS trunk.`, `Configure VLAN sub-interfaces if testing 802.1Q or QinQ encapsulation.`, `Execute tool: ${tool.cmd}`],
      ts: "Ensure your network interface card (NIC) supports raw socket injection, promiscuous mode, and IEEE 802.1Q VLAN tagging without driver frame dropping."
    },
    voip: {
      kw: [`VoIP SIP penetration testing ${cleanName}`, `SIP PBX security auditor`, `voice VLAN hopping`, `RTP media stream bleed`],
      desc: `VoIP telephony security auditing, SIP registrar stress testing, Cisco CDP/LLDP-MED voice VLAN hopping, and RTP media bleeding analysis utility.`,
      config: [`Configure target SIP proxy/registrar IP address and port (default 5060/5061 UDP/TCP).`, `Specify extension wordlist or target user accounts.`, `Launch VoIP audit: ${tool.cmd}`],
      ts: "Verify SIP ports 5060/5061 and RTP port ranges (10000-20000 UDP) are routed. Ensure voice VLAN tag is active if sniffing VoIP subnets."
    },
    mw: {
      kw: [`microwave link security ${cleanName}`, `carrier telecom OSS CLI`, `Nokia NetAct Ericsson ENM`, `PDH SDH microwave transport`],
      desc: `Telecom microwave transport link management, carrier OSS/NMS command-line connector, and backhaul transmission equipment auditing utility.`,
      config: [`Verify network routing and SSH/SNMP credentials to the target OSS gateway or microwave IDU/ODU.`, `Execute carrier CLI wrapper: ${tool.cmd}`],
      ts: "Verify carrier VPN or management VLAN connectivity. Check host SSH key exchange algorithms if connecting to legacy OSS equipment."
    },
    // Backward compatibility aliases
    ue: {
      kw: [`baseband analysis ${cleanName}`, `mobile modem debugging ${cleanName}`, `OTA protocol capture`],
      desc: `Cellular baseband firmware analysis, debugging, and OTA protocol logging utility.`,
      config: [`Connect the device via USB with DIAG/debug mode enabled.`, `Run the command: ${tool.cmd}`],
      ts: "Ensure appropriate USB serial port drivers are loaded. Phone rooting or DIAG port enablement is usually required."
    },
    ran: {
      kw: [`RAN simulation ${cleanName}`, `cellular protocol auditing`, `mobile core network scanner`],
      desc: `Radio Access Network (RAN) simulation, signaling audit, and core network verification framework.`,
      config: [`Configure the target IP and interfaces in the tool configuration file.`, `Execute the tool: ${tool.cmd}`],
      ts: "Ensure the SCTP stack is configured and that you have a direct IP path to the signaling gateway."
    },
    lte: {
      kw: [`LTE downlink sniffer ${cleanName}`, `4G LTE protocol analyzer`, `srsue UE simulator`],
      desc: `4G LTE protocol testing, downlink analysis, and diagnostic parsing utility.`,
      config: [`Configure the RF front-end parameters in the config file.`, `Run the tool: ${tool.cmd}`],
      ts: "Reduce RF bandwidth if your USB controller experiences packet drops."
    },
    device: {
      kw: [`device flash tool ${cleanName}`, `Qualcomm MTK Android audit`, `AT command terminal`],
      desc: `Hardware device interface, recovery mode flashing, and low-level diagnostic utility.`,
      config: [`Connect the target phone or modem via USB.`, `Execute: ${tool.cmd}`],
      ts: "Verify device is in BROM, EDL, or fastboot mode before running."
    },
    sys: {
      kw: [`system configuration ${cleanName}`, `telecom administrative shell`, `core network containers`],
      desc: `System provisioning, container management, and carrier administration utility.`,
      config: [`Verify service statuses on the host system.`, `Execute command: ${tool.cmd}`],
      ts: "Check host logs in journalctl if the service fails to start."
    },
    network: {
      kw: [`wireless packet capture ${cleanName}`, `tcpdump network monitor`, `RF device fingerprinting`],
      desc: `Wireless packet capture, network monitoring, and system interface sniffer.`,
      config: [`Put the network interface into monitor mode.`, `Launch: ${tool.cmd}`],
      ts: "Verify the interface name and ensure you have root permissions to capture traffic."
    }
  };

  const catMeta = categoryMap[tool.category] || {
    kw: [`${cleanName} telecom tool`, `cellular security auditing`],
    desc: `Telecom security and cellular protocol auditing tool.`,
    config: [`Execute command: ${tool.cmd}`],
    ts: "Check logs and configuration scripts in the workspace."
  };

  return {
    slug,
    ...tool,
    keywords: catMeta.kw,
    overview: `${tool.name} is a pre-installed tool in TelcoChisel OS. ${tool.desc} It belongs to the '${tool.category.toUpperCase()}' category, supporting advanced security auditing and network pentesting workflows.`,
    config: catMeta.config,
    troubleshooting: catMeta.ts,
    faq: [
      { q: `How do I run ${tool.name} in TelcoChisel?`, a: `You can execute it directly from the terminal or using the command: ${tool.cmd}` },
      { q: `What is the default installation path?`, a: `The tool or environment is configured at: ${tool.path}` }
    ]
  };
}
