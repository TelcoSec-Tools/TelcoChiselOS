export const featuresCatalog = [
  {
    name: "Real-Time DSP Engine & Zero-Drop Scheduling",
    slug: "realtime-scheduling",
    category: "kernel",
    desc: "Pre-configured real-time SCHED_RR scheduling priorities and unlimited memory locking (RLIMIT_MEMLOCK), ensuring zero sample under/overruns during high-throughput 5G NR and LTE multi-carrier signal captures.",
    cmd: "ulimit -r -l && chrt -m"
  },
  {
    name: "High-Concurrency SCTP Signaling Engine",
    slug: "sctp-stack-tuning",
    category: "network",
    desc: "Kernel transport optimization for high-density SCTP streams, retransmission backoff, and 64 MB socket buffers — optimized for high-rate SIGTRAN (M3UA/SUA), Diameter, S1AP, and NGAP signaling assessments.",
    cmd: "sysctl net.sctp.rto_min net.sctp.association_max_retrans && lsmod | grep sctp"
  },
  {
    name: "Universal Non-Root SDR Hardware Access",
    slug: "sdr-hardware-access",
    category: "hardware",
    desc: "Automated hardware arbitration granting unprivileged access to Ettus USRP (B200/B210/X300), HackRF One, Nuand BladeRF, LimeSDR, RTL-SDR, Airspy, and PlutoSDR with USB autosuspend disabled.",
    cmd: "SoapySDRUtil --find"
  },
  {
    name: "Cellular Diagnostic Port & Baseband Interface",
    slug: "baseband-diag-access",
    category: "hardware",
    desc: "Dedicated serial and USB diagnostic interface arbitration for Qualcomm EDL (9008) / DIAG ports, MediaTek PreLoader / BROM modes, Samsung Odin / Shannon interfaces, and Osmocom SIMtrace 2.",
    cmd: "qcsuper --help && scat --help"
  },
  {
    name: "Pre-Tuned Telecom Protocol Dissection",
    slug: "wireshark-profiles",
    category: "tools",
    desc: "Production-ready Wireshark and TShark protocol dissector profiles pre-configured for GSMTAP, 3GPP NAS-5GS, NGAP, S1AP, PFCP, GTPv1/v2-U, Diameter, and SS7/SIGTRAN decoding.",
    cmd: "tshark -G protocols | grep -E 'gsm|nas_5gs|s1ap|ngap'"
  },
  {
    name: "Isolated RF & DSP Conda Sandbox",
    slug: "conda-sdr-sandbox",
    category: "environment",
    desc: "Dedicated virtualized environment (telcosec-sdr) isolating GNU Radio 3.10, Gqrx, UHD, and vendor-neutral SoapySDR drivers from system Python to ensure zero dependency collisions.",
    cmd: "conda activate telcosec-sdr && python3 -c 'import gnuradio; print(gnuradio.__version__)'"
  },
  {
    name: "Modular 10-Tier Metapackage Architecture",
    slug: "modular-metapackages",
    category: "system",
    desc: "Granular Debian metapackages hosted via Cloudflare Pages edge CDN (meta.telcosec.net), enabling targeted tool deployment across SDR, 2G/3G, 4G, 5G, SIM, Mobile UE, and Wireline/PSTN domains.",
    cmd: "apt-cache search telcochisel-"
  },
  {
    name: "Wireline Broadband & VoIP Telephony Suite",
    slug: "wireline-broadband-suite",
    category: "network",
    desc: "Integrated wireline telecommunications toolchain covering PPPoE session auditing, VLAN 802.1Q injection, TR-069 CWMP emulation, DOCSIS cable modem security, and SIP/VoIP signaling stress testing.",
    cmd: "pppoe -h && sipp -h"
  }
];

