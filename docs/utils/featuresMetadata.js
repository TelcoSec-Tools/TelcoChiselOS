/**
 * Rich SEO/AEO metadata for TelcoChisel OS Customization topics.
 * All config snippets sourced directly from builder/scripts/08-system-optimization.sh
 * and builder/security/ configuration files.
 */

export const featuresMetadata = {

  "realtime-scheduling": {
    keywords: [
      "Linux real-time scheduling SDR",
      "PAM rtprio limits GNU Radio",
      "SCHED_RR srsRAN Ubuntu setup",
      "realtime group Linux memlock unlimited"
    ],
    overview: "Software Defined Radio applications like GNU Radio and srsRAN require real-time CPU scheduling to maintain continuous RF sample streams. Without elevated scheduling priority, the Linux kernel can preempt the radio processing threads, causing sample drops (underruns/overruns) that corrupt the air interface waveform. TelcoChisel configures PAM limits and the `realtime` system group so the `telcosec` user can run threads at SCHED_RR priority 99 and lock memory pages into RAM.",
    config: [
      "The PAM limits file `/etc/security/limits.d/99-realtime.conf` is deployed by the build script with the following content:\n\n@realtime  -  rtprio  99\n@realtime  -  memlock  unlimited",
      "The `realtime` system group is created via `groupadd -r realtime` and the live user is added: `usermod -aG realtime telcosec`.",
      "Verify the group membership is active: `groups telcosec` should list `realtime` in the output.",
      "Verify the limits are applied inside the session: `ulimit -r` should return `99` and `ulimit -l` should return `unlimited`.",
      "When launching GNU Radio or srsRAN, the framework automatically requests SCHED_RR if the limits allow it. Check with: `chrt -p $(pgrep gnuradio_companion)`"
    ],
    troubleshooting: "If you see 'SCHED_RR: Operation not permitted', your session may not have picked up the PAM limits. Log out and log back in, or verify the file path is exactly /etc/security/limits.d/99-realtime.conf (not limits.conf). Also check that the user is in the `realtime` group with `id telcosec`.",
    faq: [
      { q: "Why does TelcoChisel use real-time scheduling instead of just running as root?", a: "Running SDR applications as root is a significant security risk and is discouraged by the GNU Radio project. PAM real-time group membership is the correct, per-user mechanism to grant SCHED_RR priority without exposing the entire system." },
      { q: "What is memlock and why is it set to unlimited?", a: "memlock controls the maximum amount of memory a process can lock into physical RAM, preventing it from being swapped out. SDR sample buffers must remain in physical RAM for consistent DMA transfers. Setting it to unlimited allows GNU Radio and UHD to lock all required buffers." },
      { q: "Does this affect non-SDR processes on the same system?", a: "Only processes launched by a user in the `realtime` group can request elevated priority. Standard system processes, browsers, and other applications are unaffected." }
    ]
  },

  "sctp-stack-tuning": {
    keywords: [
      "Linux SCTP sysctl tuning telecom",
      "SCTP buffer optimization SIGTRAN",
      "net.sctp.rto_min Ubuntu configuration",
      "SCTP S1AP NGAP Diameter kernel settings"
    ],
    overview: "SCTP (Stream Control Transmission Protocol) is the transport backbone of 4G/5G core networks. S1AP, NGAP (5G), Diameter, and M3UA all run over SCTP associations. Default Linux kernel SCTP parameters are tuned for generic internet traffic — not for the aggressive scanning and fuzzing workloads of telecom security research. TelcoChisel deploys `/etc/sysctl.d/99-sctp-tuning.conf` to optimize buffers, reduce retransmission timeouts, and enable faster fail detection of unresponsive peers.",
    config: [
      "The full sysctl configuration deployed to `/etc/sysctl.d/99-sctp-tuning.conf`:\n\nnet.sctp.sctp_mem = 16777216 20971520 25165824\nnet.sctp.sctp_rmem = 4096 87380 16777216\nnet.sctp.sctp_wmem = 4096 16384 16777216\nnet.core.rmem_max = 16777216\nnet.core.wmem_max = 16777216\nnet.core.somaxconn = 2048\nnet.core.netdev_max_backlog = 5000\nnet.sctp.max_init_retransmits = 3\nnet.sctp.association_max_retrans = 3\nnet.sctp.path_max_retrans = 2\nnet.sctp.rto_min = 200",
      "The SCTP kernel module is registered for auto-load at boot by adding `sctp` to `/etc/modules`.",
      "Apply settings to the running kernel immediately (without reboot): `sudo sysctl --system`",
      "Verify the SCTP module is loaded: `lsmod | grep sctp`",
      "Confirm RTO minimum is applied: `sysctl net.sctp.rto_min` should return `200`"
    ],
    troubleshooting: "If `sysctl --system` returns 'No such file or directory' for SCTP keys, the sctp module is not loaded. Run `sudo modprobe sctp` first, then re-apply sysctl settings. On Ubuntu 24.04 the module is present but not loaded by default until the /etc/modules entry is processed on the next boot.",
    faq: [
      { q: "Why is net.sctp.rto_min set to 200ms instead of the default 1000ms?", a: "The standard 1000ms initial RTO causes SCTP scanners (like sctpscan or SigPloit) to hang for one second per unresponsive peer during port discovery. Reducing it to 200ms makes scans complete 5× faster without affecting established associations." },
      { q: "Will these settings break normal TCP/IP networking?", a: "No. The SCTP-specific sysctl keys only affect SCTP associations. The net.core.rmem_max and wmem_max increases benefit all socket types (TCP, UDP, SCTP) for large-transfer workloads, but do not change default socket buffer sizes for normal applications." },
      { q: "What is net.core.somaxconn used for?", a: "somaxconn controls the maximum backlog of pending connections in the kernel's listen queue. Increasing it to 2048 prevents connection drops when running high-rate SCTP association tests against core network elements." }
    ]
  },

  "usb-low-latency": {
    keywords: [
      "Linux USB low latency SDR USRP",
      "mitigations=off GRUB kernel 5G NR",
      "USRP B210 USB autosuspend disable udev",
      "clocksource tsc Linux SDR timing"
    ],
    overview: "Running a 5G NR gNodeB requires streaming RF samples continuously at rates of 7.68–61.44 MSps. Any USB polling jitter or kernel scheduling delay causes sample drops that corrupt the RRC/NAS waveform. TelcoChisel deploys two low-latency configurations: udev rules that disable USB autosuspend for SDR devices, and GRUB kernel parameters that disable CPU speculative-execution mitigations and force the TSC clocksource for consistent, low-jitter timing.",
    config: [
      "udev rule file `/etc/udev/rules.d/51-usb-latency.rules` disables power management for SDR vendor IDs:\n\nACTION==\"add\", SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2514\", ATTR{power/autosuspend_delay_ms}=\"0\"\nACTION==\"add\", SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2514\", ATTR{power/control}=\"on\"\nACTION==\"add\", SUBSYSTEM==\"usb\", ATTR{idVendor}==\"1d50\", ATTR{power/control}=\"on\"",
      "GRUB configuration `/etc/default/grub.d/99-telcosec-rt.cfg` adds kernel parameters:\n\nGRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_CMDLINE_LINUX_DEFAULT mitigations=off clocksource=tsc tsc=reliable intel_idle.max_cstate=1 processor.max_cstate=1\"",
      "After editing GRUB config, regenerate the boot entry: `sudo update-grub`",
      "For advanced CPU isolation (dedicated OAI cores), add to GRUB_CMDLINE_LINUX_DEFAULT: `isolcpus=2-5 nohz_full=2-5 rcu_nocbs=2-5` (adjust core range to match your CPU topology)",
      "After boot, verify TSC clocksource is active: `cat /sys/devices/system/clocksource/clocksource0/current_clocksource` should print `tsc`",
      "For isolated CPU setups, run the IRQ affinity helper: `sudo set-irq-affinity` to pin all hardware IRQs to housekeeping CPUs"
    ],
    troubleshooting: "If you see 'U' (underrun) or 'O' (overrun) characters in the UHD output during srsRAN operation, USB latency is still too high. Check: (1) the USB controller is Intel/AMD xHCI (not ASMedia), (2) the USRP is on a dedicated USB 3.0 port with no hubs, and (3) the mitigations=off kernel parameter is active via `cat /proc/cmdline`.",
    faq: [
      { q: "Is mitigations=off safe to use?", a: "On a dedicated research machine, yes. It disables Spectre and Meltdown CPU mitigations which impose a 5–15% CPU overhead. Since TelcoChisel is used in isolated lab environments, this trade-off is acceptable for achieving stable 5G NR timing. Do not use on shared or multi-tenant systems." },
      { q: "What is clocksource=tsc and why does it help SDR?", a: "The TSC (Time Stamp Counter) is a high-resolution CPU counter that provides consistent, low-latency time reads. Alternative clocksources like HPET have higher access overhead. OAI's real-time scheduler uses high-frequency timing calls, and TSC minimizes the jitter introduced by those calls." },
      { q: "Can hugepages help with SDR performance?", a: "Yes. TelcoChisel also deploys `/etc/sysctl.d/99-hugepages.conf` which reserves 512 × 2MB hugepages (1 GB total) for DPDK-based OAI fronthaul and USRP DMA buffers, reducing TLB pressure during high-rate sample streaming." }
    ]
  },

  "kernel-hardening": {
    keywords: [
      "Linux kernel hardening sysctl security",
      "ASLR kptr_restrict dmesg_restrict Ubuntu",
      "kernel.randomize_va_space telecom security",
      "ICMP redirect disable Linux hardening"
    ],
    overview: "While TelcoChisel is a research platform, its kernel is pre-hardened against common local and network-based exploitation vectors. The `/etc/sysctl.d/99-security-hardening.conf` file applies ASLR, restricted kernel pointer exposure, symlink/hardlink protection, ICMP redirect filtering, reverse path filtering, and TCP SYN cookie protection — following CIS Benchmark and kernel self-protection best practices.",
    config: [
      "Full security hardening configuration deployed to `/etc/sysctl.d/99-security-hardening.conf`:\n\n# ASLR — randomize virtual address space\nkernel.randomize_va_space = 2\n\n# Restrict kernel symbol lookup and dmesg for non-root\nkernel.dmesg_restrict = 1\nkernel.kptr_restrict = 2\n\n# Filesystem protection\nfs.protected_hardlinks = 1\nfs.protected_symlinks = 1\n\n# Disable ICMP redirects\nnet.ipv4.conf.all.accept_redirects = 0\nnet.ipv4.conf.default.accept_redirects = 0\nnet.ipv6.conf.all.accept_redirects = 0\n\n# Disable source routing\nnet.ipv4.conf.all.accept_source_route = 0\n\n# TCP SYN cookies\nnet.ipv4.tcp_syncookies = 1\n\n# Reverse path filtering\nnet.ipv4.conf.all.rp_filter = 1\n\n# Log martian packets\nnet.ipv4.conf.all.log_martians = 1\n\n# Ignore ICMP broadcast\nnet.ipv4.icmp_echo_ignore_broadcasts = 1\n\n# Disable send redirects (not a router)\nnet.ipv4.conf.all.send_redirects = 0",
      "Apply settings immediately without reboot: `sudo sysctl --system`",
      "Verify ASLR is enabled: `sysctl kernel.randomize_va_space` → should return `2`",
      "Verify dmesg is restricted: `sysctl kernel.dmesg_restrict` → should return `1`"
    ],
    troubleshooting: "Some tools that perform low-level kernel introspection (like certain eBPF programs or debugging tools) may be affected by kptr_restrict=2. If a tool reports 'permission denied' reading /proc/kallsyms, temporarily lower kptr_restrict: `sudo sysctl kernel.kptr_restrict=1` (reset after use).",
    faq: [
      { q: "What does kernel.randomize_va_space = 2 do?", a: "It enables full ASLR (Address Space Layout Randomization), randomizing the positions of the stack, heap, and shared library mappings in memory. This makes exploitation of memory corruption vulnerabilities significantly harder by preventing attackers from reliably predicting memory addresses." },
      { q: "Why is kptr_restrict set to 2?", a: "kptr_restrict=2 hides kernel symbol addresses (/proc/kallsyms) from all users including root, preventing information leakage that could aid kernel exploit development. A value of 1 hides addresses only from non-root users." },
      { q: "Does disabling ICMP redirects affect network reachability?", a: "No. ICMP redirects are messages that tell a host to use a different router — they are rarely needed in controlled lab networks and are a known vector for MitM routing attacks. Disabling them has no negative impact on normal internet connectivity." }
    ]
  },

  "udev-hardware-access": {
    keywords: [
      "udev rules SDR non-root access Linux",
      "50-telcosec-hw.rules plugdev group setup",
      "udev USRP HackRF BladeRF Samsung Qualcomm",
      "Linux hardware permissions telecom devices"
    ],
    overview: "TelcoChisel's `/etc/udev/rules.d/50-telcosec-hw.rules` provides non-root USB access to all supported telecom hardware: SDR transceivers (USRP, HackRF, BladeRF, LimeSDR, RTL-SDR), SIMtrace 2 sniffers, and mobile device programmers (Samsung Odin/Heimdall mode, Qualcomm EDL 9008, MediaTek BROM). All devices are mapped to the `plugdev` group at permission `0660`.",
    config: [
      "Reload udev rules without reboot after any modification: `sudo udevadm control --reload-rules && sudo udevadm trigger`",
      "Verify the user is in the plugdev group: `groups telcosec` — should list `plugdev`",
      "Add a new user to plugdev group: `sudo usermod -aG plugdev <username>`",
      "Check which rule matched a connected device: `udevadm info -a -n /dev/bus/usb/<bus>/<device> | grep idVendor`",
      "Monitor udev events in real-time when plugging hardware: `udevadm monitor --environment --udev`",
      "Key vendor IDs covered: USRP=2514, HackRF=1d50/6089, BladeRF=2cf0, LimeSDR=1d50/6108, RTL-SDR=0bda, Samsung=04e8, Qualcomm EDL=05c6/9008, MediaTek BROM=0e8d/0003"
    ],
    troubleshooting: "If a device shows 'Permission denied' or 'Access denied (insufficient permissions)', first verify: (1) the udev rule file exists at /etc/udev/rules.d/50-telcosec-hw.rules, (2) rules have been reloaded, (3) the user is in the `plugdev` group and has logged out/in since being added. Use `lsusb` to get the exact vendor:product ID and cross-reference with the rules file.",
    faq: [
      { q: "Why use plugdev instead of running tools as root?", a: "Running SDR applications as root is strongly discouraged — a crash or exploit in GNU Radio or UHD could give an attacker full system access. plugdev group membership restricts the elevated access to only USB device nodes, following the principle of least privilege." },
      { q: "Does the Qualcomm EDL rule cover all phones?", a: "The rule covers the standard Qualcomm 9008 Emergency Download Mode (idProduct 9008). Some manufacturers use custom EDL product IDs. Add additional lines to 50-telcosec-hw.rules for any vendor-specific product IDs using the same GROUP=plugdev pattern." },
      { q: "Why are modem dongles (Huawei, ZTE) mapped to dialout instead of plugdev?", a: "Serial-over-USB modems create /dev/ttyUSB* character devices, which are owned by the `dialout` group by default in Linux. The AT command tools (minicom, gammu, ModMobMap) expect /dev/ttyUSB* access via dialout membership, not raw USB descriptor access." }
    ]
  },

  "wireshark-profiles": {
    keywords: [
      "Wireshark GSMTAP 5G NAS dissector profile",
      "Wireshark Lua plugin GTP Diameter telecom",
      "Wireshark custom profile TelcoChisel setup",
      "Wireshark SCTP S1AP NGAP columns configuration"
    ],
    overview: "TelcoChisel pre-configures Wireshark with a custom dissector profile tailored for telecom protocol analysis. The profile sets up dedicated columns for GSMTAP protocol, 5G NAS (Non-Access Stratum), Diameter, GTP, and S1AP/NGAP — replacing the generic 'Info' column layout. Custom Lua plugins are deployed to `/usr/share/wireshark/plugins/` for all users, and a directory for 5G SBI OpenAPI YAML definitions is created at `/etc/wireshark/openapi/`.",
    config: [
      "The Wireshark preferences file is deployed to both `/etc/skel/.config/wireshark/preferences` (for new users) and `/home/telcosec/.config/wireshark/preferences` (for the live user).",
      "Custom Lua dissector plugins are installed system-wide: `ls /usr/share/wireshark/plugins/`",
      "To open the telecom profile inside Wireshark: Edit → Configuration Profiles → TelcoSec",
      "Capture live traffic from a loopback interface (GSMTAP from srsRAN): `sudo wireshark -i lo -k`",
      "Use TShark for CLI-based 5G NAS extraction: `tshark -i lo -Y 'nas_5gs' -T fields -e nas_5gs.mm.message_type`",
      "Useful capture filters: `gsmtap` (GSM air interface), `diameter` (S6a/Gx/Gy), `ngap` (5G NGAP), `s1ap` (4G LTE), `pfcp` (5G user plane)"
    ],
    troubleshooting: "If Lua plugins fail to load on startup ('Lua: Error during loading'), check that the plugin files have correct permissions (644) with `ls -la /usr/share/wireshark/plugins/`. Also ensure Wireshark is launched by the telcosec user (not root) so it picks up the user-level profile preferences.",
    faq: [
      { q: "What is GSMTAP and how does srsRAN generate it?", a: "GSMTAP is a pseudo-header format used to encapsulate radio layer frames (like GSM bursts, LTE MAC PDUs, or 5G NR messages) in UDP packets on port 4729, making them capturable by Wireshark on the loopback interface. srsRAN and OAI generate GSMTAP streams by default when PCAP logging is enabled." },
      { q: "Can I add my own Lua plugins?", a: "Yes. Place .lua files in /usr/share/wireshark/plugins/ for system-wide availability, or in ~/.config/wireshark/plugins/ for user-level plugins. Restart Wireshark or reload Lua plugins via Analyze → Reload Lua Plugins." },
      { q: "How do I decode 5G SBI (Service Based Interface) traffic?", a: "5G SBI uses HTTP/2 with JSON payloads, and Wireshark decodes it automatically when the port is recognized. TelcoChisel creates /etc/wireshark/openapi/ for placing 3GPP OpenAPI YAML files, which Wireshark can use for enhanced field decoding of NRF, AMF, SMF, and UDM service messages." }
    ]
  },

  "firewall-network-hardening": {
    keywords: [
      "UFW firewall Linux telecom security setup",
      "LLMNR mDNS disable Ubuntu systemd-resolved",
      "Linux umask 027 security profile",
      "Bluetooth disable rfkill Linux security"
    ],
    overview: "TelcoChisel applies multiple layers of network and system security hardening beyond kernel sysctl parameters. UFW is configured to block all incoming connections by default (allowing only SSH), Bluetooth is disabled via rfkill, LLMNR and mDNS are disabled in systemd-resolved to prevent unintended network announcements, unnecessary daemons are masked, and a restrictive umask of 027 is set for all user sessions.",
    config: [
      "UFW firewall default policy: `sudo ufw default deny incoming && sudo ufw default allow outgoing && sudo ufw allow ssh && sudo ufw enable`",
      "Verify UFW status and active rules: `sudo ufw status verbose`",
      "Bluetooth is disabled at boot via rfkill: `rfkill block bluetooth` — verify with `rfkill list`",
      "LLMNR and mDNS disabled in `/etc/systemd/resolved.conf.d/telcosec-privacy.conf`:\n\n[Resolve]\nLLMNR=no\nMulticastDNS=no",
      "Apply resolved changes: `sudo systemctl restart systemd-resolved`",
      "Verify resolved settings: `systemd-resolve --status | grep -E 'LLMNR|MulticastDNS'`",
      "Restrictive umask (027) is set in `/etc/profile.d/telcosec_umask.sh` — verify with `umask` in a new shell",
      "Masked daemons: `systemctl is-enabled avahi-daemon` should return `masked` or `disabled`"
    ],
    troubleshooting: "If UFW blocks a required tool connection (e.g., Open5GS AMF port or srsRAN S1/NG interface), add specific rules: `sudo ufw allow from 127.0.0.1` for loopback-only tools, or `sudo ufw allow <port>/sctp` for SCTP-based core interfaces. Avahi/mDNS being masked may affect some network discovery tools — re-enable if required: `sudo systemctl unmask avahi-daemon`.",
    faq: [
      { q: "Why is Bluetooth disabled by default?", a: "Bluetooth exposes attack surface on a research machine that handles sensitive protocol captures. BLE/Bluetooth can also interfere with 2.4 GHz SDR captures (GSM 1800, certain ISM band measurements). It can be re-enabled when needed: `rfkill unblock bluetooth`." },
      { q: "What does LLMNR=no protect against?", a: "Link-Local Multicast Name Resolution (LLMNR) is a protocol that allows Windows and Linux hosts to resolve hostnames on the local network without DNS. It is a well-known vector for MITM name poisoning attacks (Responder tool). Disabling it prevents unintended hostname resolution from LAN traffic during assessments." },
      { q: "What is umask 027 and how does it differ from the default?", a: "The default Linux umask is 022, which creates files with permissions 644 (rw-r--r--). A umask of 027 creates files with 640 (rw-r-----), making new files unreadable by others and new directories non-accessible by others. This prevents accidental exposure of capture files or configuration exports." }
    ]
  },

  "conda-sdr-sandbox": {
    keywords: [
      "Conda SDR environment GNU Radio Ubuntu",
      "telcosec-sdr conda activate SoapySDR",
      "GNU Radio Conda isolation UHD BladeRF",
      "SDR Python virtual environment telecom security"
    ],
    overview: "All Software Defined Radio drivers and GNU Radio are isolated inside a dedicated Conda virtual environment named `telcosec-sdr`. This prevents dependency conflicts between the SDR driver stack (which needs specific versions of Python, Boost, UHD, and SoapySDR) and the system Python environment used by other tools. The environment is built from source during the ISO compilation phase by `02-install-sdr.sh`.",
    config: [
      "Activate the SDR sandbox environment: `conda activate telcosec-sdr`",
      "Verify SoapySDR can enumerate connected hardware: `SoapySDRUtil --find`",
      "Verify UHD (USRP) driver is available: `uhd_usrp_probe` (connect USRP first)",
      "Verify HackRF tools are inside the environment: `which hackrf_info`",
      "Verify GNU Radio Python bindings: `python3 -c 'import gnuradio; print(gnuradio.__version__)'`",
      "List all packages installed in the environment: `conda list -n telcosec-sdr`",
      "Deactivate the environment and return to system Python: `conda deactivate`",
      "If USRP FPGA images are missing after UHD update: `uhd_images_downloader` (inside telcosec-sdr)"
    ],
    troubleshooting: "If `conda activate telcosec-sdr` fails with 'conda: command not found', run `source /opt/conda/etc/profile.d/conda.sh` first to initialize the Conda shell hooks. If GNU Radio crashes with a Python import error, ensure you are inside the telcosec-sdr environment (the prompt should show `(telcosec-sdr)`), not the base or system Python.",
    faq: [
      { q: "Why not install GNU Radio from apt instead of Conda?", a: "The apt version of GNU Radio (3.9.x on Ubuntu 22/24) does not include the latest OOT (Out-of-Tree) module support required by gr-gsm, gr-lte, and SoapySDR companion blocks. Compiling from source inside Conda allows pinning exact versions compatible with UHD and SoapySDR, avoiding runtime ABI mismatches." },
      { q: "Can I install additional Python packages into telcosec-sdr?", a: "Yes, but be careful about breaking SoapySDR or UHD bindings. Use `conda install -n telcosec-sdr <package>` for packages available in Conda repositories, or `pip install` inside the activated environment for PyPI packages. Always test that `SoapySDRUtil --find` still works after adding packages." },
      { q: "How do I run a GNU Radio flowgraph from the terminal?", a: "Activate the environment first (`conda activate telcosec-sdr`), then run the flowgraph Python file directly: `python3 my_flowgraph.py`. For the GUI companion, launch: `gnuradio-companion my_flowgraph.grc`. The environment provides all necessary Qt and GTK GUI dependencies." }
    ]
  }
}

/**
 * Returns complete SEO/AEO metadata for a given OS customization feature.
 */
export function getFeatureMetadata(slug) {
  return featuresMetadata[slug] || null
}
