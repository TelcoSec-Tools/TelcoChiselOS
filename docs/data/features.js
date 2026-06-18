export const featuresCatalog = [
  {
    name: "Real-time Scheduling",
    slug: "realtime-scheduling",
    category: "kernel",
    desc: "PAM limits granting the telcosec user SCHED_RR priority 99 and unlimited memory locking — essential for GNU Radio and srsRAN to avoid sample drops.",
    cmd: "grep -r realtime /etc/security/limits.d/ && chrt -m"
  },
  {
    name: "SCTP Stack Tuning",
    slug: "sctp-stack-tuning",
    category: "network",
    desc: "Kernel sysctl optimizations for SCTP buffer sizes, RTO values, and retransmission limits — tuned for high-speed SIGTRAN, S1AP, NGAP, and Diameter scanning.",
    cmd: "sysctl net.sctp.rto_min net.sctp.association_max_retrans && lsmod | grep sctp"
  },
  {
    name: "Low-Latency USB & GRUB",
    slug: "usb-low-latency",
    category: "kernel",
    desc: "udev autosuspend disable rules for USRP B210 and HackRF, plus GRUB kernel parameters (mitigations=off, clocksource=tsc) for stable 5G NR signal streaming.",
    cmd: "cat /etc/default/grub.d/99-telcosec-rt.cfg && cat /etc/udev/rules.d/51-usb-latency.rules"
  },
  {
    name: "Kernel Security Hardening",
    slug: "kernel-hardening",
    category: "security",
    desc: "sysctl parameters enabling ASLR, kptr restriction, dmesg access control, ICMP redirect blocking, reverse path filtering, and TCP SYN cookie protection.",
    cmd: "sysctl kernel.randomize_va_space kernel.dmesg_restrict net.ipv4.conf.all.accept_redirects"
  },
  {
    name: "udev Hardware Access Rules",
    slug: "udev-hardware-access",
    category: "hardware",
    desc: "The 50-telcosec-hw.rules file mapping all SDR transceivers, SIMtrace 2, Samsung/Qualcomm/MediaTek devices to the plugdev group for non-root USB access.",
    cmd: "cat /etc/udev/rules.d/50-telcosec-hw.rules && groups telcosec"
  },
  {
    name: "Wireshark Telecom Profiles",
    slug: "wireshark-profiles",
    category: "tools",
    desc: "Pre-configured Wireshark dissector profile with GSMTAP, 5G NAS, Diameter, GTP, and SCTP column layouts plus custom Lua plugins deployed system-wide.",
    cmd: "wireshark --version && ls /usr/share/wireshark/plugins/"
  },
  {
    name: "Firewall & Network Privacy",
    slug: "firewall-network-hardening",
    category: "security",
    desc: "UFW firewall with deny-incoming default, SSH allow, Bluetooth blocked by rfkill, LLMNR/mDNS disabled in resolved, and restrictive umask 027 for all sessions.",
    cmd: "sudo ufw status verbose && systemd-resolve --status | grep -E 'LLMNR|MulticastDNS'"
  },
  {
    name: "Conda SDR Sandbox",
    slug: "conda-sdr-sandbox",
    category: "environment",
    desc: "Isolated Conda virtual environment (telcosec-sdr) housing GNU Radio, UHD, SoapySDR, HackRF, BladeRF, and LimeSDR libraries — separate from system Python.",
    cmd: "conda activate telcosec-sdr && SoapySDRUtil --find && python3 -c 'import gnuradio; print(gnuradio.__version__)'"
  }
]
