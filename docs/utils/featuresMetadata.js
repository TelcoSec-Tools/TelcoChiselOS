/**
 * Rich SEO/AEO metadata for TelcoChisel Telecom OS Capabilities.
 * Aligned with the 8 core operational features in featuresCatalog.
 */

export const featuresMetadata = {

  "realtime-scheduling": {
    keywords: [
      "Linux real-time scheduling SDR",
      "SCHED_RR priority 99 GNU Radio",
      "RLIMIT_MEMLOCK unlimited srsRAN",
      "DSP zero sample drop Linux tuning",
      "TelcoChisel real-time audio RF streaming"
    ],
    overview: "Software Defined Radio applications such as GNU Radio, srsRAN, and OpenAirInterface require real-time CPU scheduling and unconstrained physical memory allocation. Under high sample rates (e.g. 30.72–61.44 MSps for LTE and 5G NR), standard time-sharing kernels preempt radio processing threads, causing packet buffer underruns and corrupting air interface frames. TelcoChisel pre-configures real-time SCHED_RR scheduling and unlimited memory locking (RLIMIT_MEMLOCK), ensuring zero sample drops.",
    config: [
      "Verify that real-time scheduling limits and memory locking are active in your user session:\nulimit -r -l",
      "Inspect the maximum real-time priority supported by the running kernel scheduler:\nchrt -m",
      "Check the real-time scheduling policy of active SDR processes:\nchrt -p $(pgrep -f 'srsenb|openair|gnuradio' 2>/dev/null || echo $$)",
      "Monitor thread-level CPU affinity and scheduling jitter during live RF operations:\ntop -H -p $(pgrep -f srsenb 2>/dev/null || echo $$)"
    ],
    troubleshooting: "If your SDR application reports 'SCHED_RR: Operation not permitted', verify that your session limits return `99` for `ulimit -r` and `unlimited` for `ulimit -l`. In virtualized environments or containers, ensure the hypervisor or container runtime delegates real-time capabilities (CAP_SYS_NICE).",
    faq: [
      { q: "Why does TelcoChisel use SCHED_RR priority instead of running tools as root?", a: "Running complex DSP stacks like GNU Radio as root introduces unnecessary attack surface. Granting real-time limits to unprivileged user sessions adheres to the principle of least privilege while providing the exact timing guarantees needed for RF streaming." },
      { q: "What is RLIMIT_MEMLOCK and why is it set to unlimited?", a: "RLIMIT_MEMLOCK controls the amount of memory a process can pin to physical RAM, preventing the OS from swapping it to disk. SDR buffers must remain pinned in RAM to guarantee low-latency Direct Memory Access (DMA) transfers to and from the transceiver." },
      { q: "How does real-time scheduling prevent sample drops?", a: "SCHED_RR ensures that critical DSP and baseband signal processing threads preempt lower-priority user-space tasks immediately whenever new RF samples arrive from the transceiver." }
    ]
  },

  "sctp-stack-tuning": {
    keywords: [
      "Linux SCTP stack tuning telecom",
      "SCTP buffer optimization SIGTRAN",
      "S1AP NGAP Diameter kernel settings",
      "high concurrency SCTP scanner",
      "TelcoChisel SCTP networking"
    ],
    overview: "Stream Control Transmission Protocol (SCTP) is the transport layer standard for telecom signaling across 3G, 4G, and 5G networks, including M3UA/SUA (SS7 SIGTRAN), S1AP (4G LTE), NGAP (5G Core), and Diameter (3GPP S6a/Gx). Standard Linux distributions ship with SCTP socket buffers tuned for lightweight desktop traffic, causing socket exhaustion and packet drops during security scans. TelcoChisel optimizes the kernel SCTP stack for 64 MB maximum socket buffers and fast failover RTO thresholds.",
    config: [
      "Verify that the SCTP kernel module is loaded and operational:\nlsmod | grep sctp",
      "Inspect current SCTP retransmission timeouts and association limits:\nsysctl net.sctp.rto_min net.sctp.association_max_retrans",
      "Check maximum socket buffer allocation limits across core networks:\nsysctl net.core.rmem_max net.core.wmem_max net.core.somaxconn",
      "Review active SCTP associations and endpoints across the testbed:\ncat /proc/net/sctp/eps && cat /proc/net/sctp/assocs"
    ],
    troubleshooting: "If SCTP scanning tools (such as sctpscan or SigPloit) return connection timeouts on live networks, confirm that local firewall rules do not restrict SCTP transport: `sudo ufw status`. Check that the target gNodeB or AMF IP is reachable via ICMP or ARP.",
    faq: [
      { q: "Why optimize net.sctp.rto_min to 200ms?", a: "The default Linux initial RTO of 1000ms causes SCTP port scanners and fuzzers to stall for a full second per unresponsive endpoint. Lowering RTO to 200ms accelerates discovery sweeps by up to 500% without degrading established associations." },
      { q: "Which 5G core network interfaces rely on SCTP?", a: "The N2 interface between the 5G gNodeB (RAN) and the Access and Mobility Management Function (AMF) carries NGAP signaling exclusively over SCTP on port 38412." },
      { q: "Does this optimization interfere with standard TCP or UDP traffic?", a: "No. The kernel SCTP parameters strictly govern SCTP sockets, while the elevated rmem_max and wmem_max thresholds benefit high-throughput UDP and TCP streams as well." }
    ]
  },

  "sdr-hardware-access": {
    keywords: [
      "SDR non-root access Linux",
      "USRP B210 HackRF BladeRF udev rules",
      "SoapySDR hardware enumeration",
      "plugdev non-root SDR permissions",
      "TelcoChisel transceiver drivers"
    ],
    overview: "Hardware transceiver access in security distributions frequently forces users into running analysis tools as root. TelcoChisel implements automated udev device arbitration, mapping Ettus Research USRP (B200, B210, X300), Great Scott Gadgets HackRF One, Nuand BladeRF 2.0 micro, LimeSDR, RTL-SDR, Airspy, and PlutoSDR to the standard unprivileged `plugdev` group while disabling USB power autosuspend.",
    config: [
      "Enumerate all connected SDR transceivers via the vendor-neutral abstraction layer:\nSoapySDRUtil --find",
      "Query Ettus Research USRP transceivers for onboard FPGA firmware and daughterboard sensors:\nuhd_usrp_probe --args='type=b200'",
      "Query connected Great Scott Gadgets HackRF hardware and firmware versions:\nhackrf_info",
      "Check Nuand BladeRF FPGA version and USB speed negotiation:\nbladeRF-cli -e info"
    ],
    troubleshooting: "If a connected SDR is recognized by `lsusb` but fails to open in software with 'Access denied', verify that your current user account belongs to the `plugdev` group (`id -nG`) and trigger a udev rule refresh with `sudo udevadm control --reload-rules && sudo udevadm trigger`.",
    faq: [
      { q: "Why is USB autosuspend disabled for SDR devices?", a: "USB power management can automatically put idle transceivers into low-power sleep states. In bursty RF signal environments, the latency of waking the USB controller drops the first hundreds of radio samples, causing synchronization failure." },
      { q: "Does TelcoChisel support both USB 2.0 and USB 3.0 transceivers?", a: "Yes. High-bandwidth transceivers like USRP B210 and BladeRF 2.0 micro utilize USB 3.0 SuperSpeed (5 Gbps), while HackRF and RTL-SDR operate over USB 2.0 HighSpeed (480 Mbps)." },
      { q: "Can multiple SDR transceivers be used simultaneously?", a: "Yes. Each transceiver is addressed by its unique serial number or bus ID (e.g. `uhd_find_devices` or `hackrf_info -d <serial>`), enabling full-duplex transmission and multi-carrier sniffing setups." }
    ]
  },

  "baseband-diag-access": {
    keywords: [
      "Qualcomm DIAG mode extraction",
      "MediaTek PreLoader BROM serial",
      "Samsung Shannon baseband reverse engineering",
      "QCSuper live GSMTAP Wireshark",
      "TelcoChisel cellular diagnostic"
    ],
    overview: "Modern smartphones and cellular modems expose low-level diagnostic and bootloader interfaces over USB. TelcoChisel provides out-of-the-box arbitration and user-space toolchains to communicate with Qualcomm DIAG interfaces (/dev/ttyUSB*), MediaTek BROM/PreLoader ports, Samsung Shannon trace interfaces, and Osmocom SIMtrace 2 sniffers without root privileges.",
    config: [
      "Inspect connected diagnostic USB modems and serial ports:\nls -l /dev/ttyUSB* /dev/cdc-wdm* 2>/dev/null",
      "Launch QCSuper to capture Qualcomm DIAG telemetry and stream directly to Wireshark:\nqcsuper --usb-modem /dev/ttyUSB0 --wireshark-live",
      "Decode cellular signaling telemetry from diagnostic captures using SCAT:\nscat -t qualcomm -u /dev/ttyUSB0 -w /tmp/diag_trace.pcap",
      "Verify permissions and group ownership for dialout communication:\nid -nG | grep -E 'dialout|plugdev'"
    ],
    troubleshooting: "If `/dev/ttyUSB0` does not appear when connecting a diagnostic smartphone, verify that USB debugging is enabled on the device and that the modem diagnostic mode was activated via device dialer codes or ADB command (`setprop sys.usb.config diag,serial_cdev,rmnet,adb`).",
    faq: [
      { q: "What protocols can be observed over the Qualcomm DIAG interface?", a: "The DIAG interface exposes unencrypted radio layer frames directly from the baseband processor, including 2G/3G/4G/5G RRC signaling, NAS mobility management messages, and low-level physical layer CQI/RSSI measurements." },
      { q: "Can FirmWire emulate extracted baseband firmware images?", a: "Yes. TelcoChisel ships FirmWire, an emulation platform based on QEMU and avatar2 that models Samsung Shannon and MediaTek baseband firmware for vulnerability analysis and fuzzing." },
      { q: "Is root required on the smartphone to capture DIAG logs?", a: "On commercial Android handsets, enabling DIAG mode typically requires root privileges or engineering firmware. Dedicated USB modem dongles (such as Quectel or Fibocom) expose DIAG ports natively without handset modification." }
    ]
  },

  "wireshark-profiles": {
    keywords: [
      "Wireshark telecom dissector profile",
      "GSMTAP 5G NAS dissector Wireshark",
      "Diameter GTP NGAP Wireshark layout",
      "TShark telecom packet capture",
      "TelcoChisel Wireshark configuration"
    ],
    overview: "Standard Wireshark installations display packet captures using generic IP and TCP columns that hide crucial telecom headers. TelcoChisel includes pre-configured Wireshark and TShark profiles optimized specifically for telecom security audits. The profile features dedicated columns for GSMTAP radio burst types, 3GPP 5G NAS message names, NGAP/S1AP procedure codes, Diameter Command Codes, and GTP TEID values.",
    config: [
      "Verify telecom protocol dissection engine capabilities in TShark:\ntshark -G protocols | grep -E 'gsm|nas_5gs|s1ap|ngap|diameter'",
      "Capture and extract 5G NAS Registration messages on live interfaces:\ntshark -i any -Y 'nas_5gs' -T fields -e frame.time -e nas_5gs.mm.message_type",
      "Filter and inspect GSMTAP air interface signaling from local SDR simulations:\ntshark -i lo -f 'udp port 4729' -Y 'gsm_a.dtap || lte_rrc'",
      "Launch Wireshark using the pre-tuned TelcoSec profile:\nwireshark -k -i lo"
    ],
    troubleshooting: "If Wireshark does not show decoded 5G NAS or Diameter fields, ensure the capture interface is receiving the expected transport port (e.g. UDP 4729 for GSMTAP, SCTP 38412 for 5G NGAP, TCP/SCTP 3868 for Diameter). Use 'Decode As' to bind custom ports to the target dissector.",
    faq: [
      { q: "What is GSMTAP?", a: "GSMTAP is an encapsulation protocol that wraps cellular radio interface frames (GSM Um, LTE Uu, 5G NR) inside standard UDP packets on port 4729, allowing Wireshark to dissect over-the-air radio signaling." },
      { q: "How do srsRAN and Open5GS interact with Wireshark?", a: "srsRAN eNodeB/gNodeB transmits live GSMTAP streams to 127.0.0.1:4729, while Open5GS core network functions exchange standard NGAP/S1AP signaling over SCTP on local or physical network interfaces." },
      { q: "Can TShark extract decrypted NAS payloads from PCAPs?", a: "Yes. When provided with the 5G NAS ciphering/integrity keys or when analyzing unencrypted initial registration requests, TShark fully parses the Plaintext NAS protocol elements." }
    ]
  },

  "conda-sdr-sandbox": {
    keywords: [
      "Conda SDR environment isolation",
      "telcosec-sdr GNU Radio Python",
      "SoapySDR UHD Conda sandbox",
      "SDR dependency isolation Ubuntu",
      "TelcoChisel Conda environment"
    ],
    overview: "Software Defined Radio toolchains rely on complex C++ and Python bindings that frequently conflict with standard OS package managers. TelcoChisel isolates GNU Radio 3.10, Gqrx, UHD, and vendor-neutral SoapySDR bindings inside a dedicated Conda sandbox environment named `telcosec-sdr`. This guarantees that Python pip installations or OS updates never break core RF transceivers or DSP flowgraphs.",
    config: [
      "Activate the isolated SDR research sandbox:\nconda activate telcosec-sdr",
      "Verify GNU Radio version and core Python module import inside the sandbox:\npython3 -c 'import gnuradio; print(gnuradio.__version__)'",
      "Verify SoapySDR driver bindings inside the activated sandbox:\nSoapySDRUtil --info",
      "List installed SDR libraries and OOT signal processing modules:\nconda list -n telcosec-sdr"
    ],
    troubleshooting: "If `conda activate telcosec-sdr` returns 'conda: command not found', initialize the shell environment with `source /opt/conda/etc/profile.d/conda.sh` or ensure that the Conda initialization block in your shell profile has executed.",
    faq: [
      { q: "Why use a Conda sandbox instead of native apt packages?", a: "Native distribution repositories often ship outdated versions of GNU Radio or lack support for third-party Out-of-Tree (OOT) modules. A dedicated sandbox allows exact library pinning without risking system-level package corruption." },
      { q: "Can custom GNU Radio flowgraphs be run outside the sandbox?", a: "Flowgraphs compiled into standalone Python scripts require the GNU Radio runtime, which resides inside the `telcosec-sdr` sandbox. Always activate the sandbox before executing SDR scripts." },
      { q: "Can I install additional Python libraries into the sandbox?", a: "Yes. You can run `conda install` or `pip install` within the active `telcosec-sdr` environment to add specialized DSP algorithms, Scapy telecom extensions, or machine learning frameworks." }
    ]
  },

  "modular-metapackages": {
    keywords: [
      "TelcoChisel Debian metapackages",
      "Cloudflare Pages APT repository",
      "meta.telcosec.net package manager",
      "modular telecom security packages",
      "APT repo TelcoChisel"
    ],
    overview: "TelcoChisel distributes its 78+ telecom security tools through a modular 10-tier Debian metapackage architecture hosted on the Cloudflare Pages global edge network (`meta.telcosec.net`). Security teams can deploy lightweight, domain-specific toolchains — such as SDR, 5G Core, SIM smartcards, mobile modems, or PSTN wireline — onto any standard Ubuntu 24.04 system without installing the complete 20 GB operating system image.",
    config: [
      "Query all available TelcoChisel modular metapackages:\napt-cache search telcochisel-",
      "Inspect package dependencies for the 5G Core assessment suite:\napt-cache depends telcochisel-5g",
      "Inspect package dependencies for the wireline broadband toolchain:\napt-cache depends telcochisel-pstn-adsl",
      "Verify official TelcoSec APT repository configuration and GPG key:\ncat /etc/apt/sources.list.d/telcochisel.list"
    ],
    troubleshooting: "If `apt-get update` reports an unsigned repository error for `meta.telcosec.net`, re-import the official TelcoSec GPG signing key: `curl -fsSL https://meta.telcosec.net/telcosec.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/telcosec.gpg`.",
    faq: [
      { q: "What metapackages are available in the repository?", a: "The repository provides 10 modular tiers: telcochisel-core, telcochisel-sdr, telcochisel-2g-3g, telcochisel-4g, telcochisel-5g, telcochisel-sim, telcochisel-mobile-ue, telcochisel-pstn-adsl, telcochisel-voip, and telcochisel-full." },
      { q: "Can I install TelcoChisel metapackages on an existing Ubuntu server?", a: "Yes. Any Ubuntu 24.04 LTS (Noble Numbat) system can add the `meta.telcosec.net` APT source and install individual metapackages to equip the system for specialized telecom testing." },
      { q: "How is package integrity guaranteed?", a: "All Debian packages and release manifests in the repository are cryptographically signed using the official TelcoSec GPG key via automated CI/CD build pipelines." }
    ]
  },

  "wireline-broadband-suite": {
    keywords: [
      "Wireline broadband penetration testing",
      "PPPoE MS-CHAPv2 dictionary audit",
      "TR-069 CWMP security auditing",
      "SIP VoIP signaling fuzzing",
      "TelcoChisel wireline PSTN ADSL tools"
    ],
    overview: "While wireless cellular security receives significant focus, the underlying carrier transport network relies on fixed wireline access concentrators, copper DSLAMs, optical OLTs, and IP PBX trunks. TelcoChisel incorporates a dedicated wireline and fixed broadband assessment suite, enabling red teams to audit PPPoE authentication handshakes, inspect TR-069 CWMP management protocols, and perform SIP/VoIP signaling stress testing.",
    config: [
      "Audit captured PPPoE MS-CHAPv2 authentication handshakes against credential wordlists:\nasleap -r /tmp/pppoe_auth.pcap -W /usr/share/wordlists/telecom-passwords.txt",
      "Enumerate SIP user agents and PBX extensions on carrier VoIP gateways:\nsvmap 192.168.1.0/24 -p 5060",
      "Stress test SIP proxy handling under high-volume UAC call floods:\nsipp -sn uac -r 50 -rp 1000 -m 500 192.168.1.1:5060",
      "Inject 802.1Q tagged VLAN carrier frames to verify trunk isolation:\nscapy --eval \"sendp(Ether()/Dot1Q(vlan=100)/IP(dst='10.0.0.1')/ICMP(), iface='eth0')\""
    ],
    troubleshooting: "If PPPoE discovery fails, verify that raw Ethernet frames can traverse your physical interface: `sudo tcpdump -i eth0 pppoes or pppoed`. In virtualized labs, ensure that the virtual switch enables promiscuous mode and forged transmits.",
    faq: [
      { q: "Why is PPPoE MS-CHAPv2 auditing important for telecom operators?", a: "Many ISP broadband access networks authenticate consumer and business routers via PPPoE MS-CHAPv2. If weak passwords are used, passive wireline eavesdropping can capture the challenge-response and recover cleartext credentials." },
      { q: "What is TR-069 and how is it audited?", a: "TR-069 (CWMP) is the broadband standard used by carriers to configure and manage customer premises equipment (CPE) remotely. Security audits inspect whether the ACS endpoints enforce strict TLS mutual authentication." },
      { q: "Can SIPp test carrier IMS (IP Multimedia Subsystem) cores?", a: "Yes. SIPp is the industry-standard SIP benchmarking tool capable of generating high-rate SIP INVITE, REGISTER, and OPTIONS traffic with custom authentication digests." }
    ]
  }

};

/**
 * Returns complete SEO/AEO metadata for a given OS customization feature.
 */
export function getFeatureMetadata(slug) {
  return featuresMetadata[slug] || null;
}
