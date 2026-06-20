<template>
  <div>
    <BootOverlay />
    <div class="sidebar-overlay" :class="{ active: sidebarOpen }" @click="sidebarOpen = false" id="sidebarOverlay"></div>
    <div class="layout-container">
      <AppSidebar :active-section="activeSection" :open="sidebarOpen" @navigate="navigate" @toggle-theme="toggleTheme" />

      <button class="mobile-nav-toggle" id="mobileToggle" @click="sidebarOpen = !sidebarOpen">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="3" y1="12" x2="21" y2="12"></line>
          <line x1="3" y1="6" x2="21" y2="6"></line>
          <line x1="3" y1="18" x2="21" y2="18"></line>
        </svg>
      </button>

      <main class="main-content">

        <!-- SECTION: OVERVIEW -->
        <section id="overview" class="content-section" :class="{ active: activeSection === 'overview' }" v-show="activeSection === 'overview'">
          <div class="section-header" data-label="// Overview :: TelcoChisel v1.1.0">
            <h1>TelcoChisel: Advanced Telecom Security OS by TelcoSec</h1>
            <p class="subtitle">The ultimate bootable live OS for Telecom Security, 5G/4G research, and SDR analysis</p>
            <SpectrumCanvas />
          </div>

          <p>
            <strong>TelcoChisel</strong> is a free, bootable live Linux distribution developed by <strong>TelcoSec</strong>, purpose-built for advanced <strong>Telecom Security</strong> research. Based on <strong>Ubuntu 24.04 LTS (Noble Numbat)</strong>, it ships with 50+ pre-configured tools for Software Defined Radio (SDR) engineering, baseband auditing, and cellular network penetration testing — ready to use without installation.
          </p>

          <!-- Download CTA -->
          <div class="download-cta">
            <span class="beta-badge">Beta</span>
            <button class="btn-download" @click="trackDownload">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
              Download TelcoChisel ISO
            </button>
            <a href="https://github.com/TelcoSec-Tools/TelcoChiselOS" target="_blank" class="btn-gh">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor"><path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z"/></svg>
              View on GitHub
            </a>
            <span class="download-status">OS stable &middot; Tools integration in progress &middot; <span class="status-ok">&#9733; Users will love it</span></span>
          </div>

          <!-- Academy Banner Promotion -->
          <div class="academy-banner">
            <div class="academy-banner-content">
              <span class="academy-badge">RECOMMENDED TRAINING</span>
              <h2>TelcoSec Academy Certification Program</h2>
              <p>Accelerate your career in telecom security. Access interactive sandbox labs, practice 5G Standalone core network hacking, simulate baseband firmware fuzzing, and earn the Certified Telecom Security Practitioner (CTSP) credential.</p>
              <a href="https://app.telcosec.net/" class="academy-btn" target="_blank" @click="trackAcademy">Access Live Labs at app.telcosec.cloud &rarr;</a>
            </div>
            <div class="academy-banner-icon">
              <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                <path d="M12 8v4"></path>
                <path d="M12 16h.01"></path>
              </svg>
            </div>
          </div>

          <AppCallout type="info" title="Live Boot Credentials">
            When booting the ISO image on bare metal or virtual environments, the system defaults to graphical autologin. If prompted for passwords:
            <br><strong>Username:</strong> <code class="inline-code">telcosec</code>
            <br><strong>Password:</strong> <code class="inline-code">telcosec</code>
          </AppCallout>

          <h2>Key Platform Capabilities</h2>
          <div class="grid-2">
            <div class="card">
              <div class="card-title">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--accent-teal);"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                SDR Sandbox
              </div>
              <p class="card-desc">Radio drivers (UHD, HackRF, BladeRF, LimeSDR) are compiled from source and sandboxed in a dedicated Conda virtual environment, preserving system Python integrity.</p>
            </div>
            <div class="card">
              <div class="card-title">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--accent-teal);"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                Baseband Emulation
              </div>
              <p class="card-desc">Audit baseband firmware binaries using FirmWire. QCSuper parses diagnostic logs directly from active test UE devices connected via Qualcomm DIAG USB.</p>
            </div>
            <div class="card">
              <div class="card-title">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--accent-teal);"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                SIM &amp; eSIM Utilities
              </div>
              <p class="card-desc">Audit SIM interfaces using Osmocom SIMtrace 2 and pySim-shell. Manage profiles on eSIM chips using the lpac Local Profile Assistant (LPA).</p>
            </div>
            <div class="card">
              <div class="card-title">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--accent-teal);"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                Signaling Scanners
              </div>
              <p class="card-desc">Audit SIGTRAN, Diameter, SIP/VoIP, and GTP cores with Diafuzzer, SigPloit, SIPVicious, and custom Wireshark protocol dissecting profiles.</p>
            </div>
          </div>

          <!-- FAQ -->
          <h2>Frequently Asked Questions</h2>
          <div class="faq-list">

            <details class="faq-item">
              <summary class="faq-question">What is TelcoChisel?</summary>
              <div class="faq-answer">
                TelcoChisel is a free, bootable live Linux distribution based on Ubuntu 24.04 LTS with a GNOME desktop, purpose-built for telecommunications security research. It includes 50+ pre-configured tools for Software Defined Radio (SDR) analysis, baseband firmware auditing, SIM and eSIM inspection, and 5G/4G core network penetration testing — no installation required.
              </div>
            </details>

            <details class="faq-item">
              <summary class="faq-question">What SDR hardware does TelcoChisel support?</summary>
              <div class="faq-answer">
                Drivers compiled from source for the Ettus Research <strong>USRP B210</strong>, Great Scott Gadgets <strong>HackRF One</strong>, Nuand <strong>BladeRF 2.0 micro xA4</strong>, <strong>LimeSDR</strong>, and <strong>RTL-SDR</strong> dongles. All SDR drivers and GNU Radio are sandboxed in a Conda environment named <code class="inline-code">telcosec-sdr</code> to prevent system Python conflicts.
              </div>
            </details>

            <details class="faq-item">
              <summary class="faq-question">Can I run TelcoChisel in a virtual machine?</summary>
              <div class="faq-answer">
                Most analysis and protocol tools work in a VM. However, SDR tools that stream high-bandwidth samples — particularly the <strong>5Ghoul 5G NR fuzzer</strong> — require bare metal installation with native USB 3.0 passthrough for reliable operation. Running inside VirtualBox or VMware will cause USB overrun errors.
              </div>
            </details>

            <details class="faq-item">
              <summary class="faq-question">How do I install 5Ghoul for 5G NR fuzzing?</summary>
              <div class="faq-answer">
                All build dependencies are pre-installed. Run <code class="inline-code">sudo 5ghoul-install</code> for a USRP B210, or <code class="inline-code">sudo 5ghoul-install --radio BLADERF</code> for a BladeRF A4. The installer clones the repository, applies radio patches, and compiles OpenAirInterface. Allow 20–60 minutes for compilation. See the <strong>5Ghoul Fuzzing</strong> guide in this documentation for the full workflow.
              </div>
            </details>

            <details class="faq-item">
              <summary class="faq-question">What telecom protocol tools are included?</summary>
              <div class="faq-answer">
                <strong>Protocol scanners:</strong> sctpscan (SCTP/S1AP/NGAP/Diameter), SIPVicious (SIP/VoIP). <strong>Exploitation:</strong> SigPloit (SS7/Diameter/GTP), Diafuzzer (Diameter). <strong>Packet analysis:</strong> Wireshark with custom GSMTAP, 5G NAS, Diameter, and GTP column profiles; Scapy with M3UA, TCAP, and MAP modules. <strong>Core network:</strong> Open5GS (5G SA), srsRAN (4G/5G RAN simulator).
              </div>
            </details>

            <details class="faq-item">
              <summary class="faq-question">What are the default live boot credentials?</summary>
              <div class="faq-answer">
                Username: <code class="inline-code">telcosec</code> — Password: <code class="inline-code">telcosec</code>. The system is configured for graphical autologin; you will only be prompted if autologin has been disabled.
              </div>
            </details>

          </div>

          <h2>Quick Links</h2>
          <div class="grid-3" style="margin-top: 10px;">
            <a href="https://community.telcosec.cloud/" class="card highlight-teal" target="_blank">
              <div class="card-title" style="color: var(--accent-teal);">Community Hub</div>
              <p class="card-desc" style="font-size: 0.85rem;">Discuss protocols, SDR designs, and share telemetry audits with other security analysts.</p>
            </a>
            <a href="https://app.telcosec.net/" class="card highlight-teal" target="_blank">
              <div class="card-title" style="color: var(--accent-teal);">Academy</div>
              <p class="card-desc" style="font-size: 0.85rem;">Master telecom penetration testing from basic GSM up to 5G Standalone core exploits.</p>
            </a>
            <a href="https://blog.telcosec.cloud/" class="card highlight-teal" target="_blank">
              <div class="card-title" style="color: var(--accent-teal);">Research Blog</div>
              <p class="card-desc" style="font-size: 0.85rem;">In-depth writeups on baseband vulnerabilities, IMS fuzzing, and rogue gNB simulations.</p>
            </a>
          </div>
        </section>

        <!-- SECTION: INSTALLATION / BOOTING -->
        <section id="installation" class="content-section" :class="{ active: activeSection === 'installation' }" v-show="activeSection === 'installation'">
          <div class="section-header" data-label="// Getting Started :: Installation">
            <h2>Installation &amp; Booting Guide</h2>
            <p class="subtitle">Flash TelcoChiselOS to a USB drive and boot on bare metal</p>
          </div>
          <p>
            TelcoChisel is distributed as a bootable ISO image. For optimal performance with SDR hardware and the lowest latency, we recommend running TelcoChisel on bare metal from a live USB stick rather than inside a Virtual Machine.
          </p>
          <h3>1. Download the ISO</h3>
          <p>
            Download the latest TelcoChisel ISO image from our official <a href="https://sourceforge.net/projects/telcochisel/" target="_blank">SourceForge repository</a>. The ISO is approximately 4.5 GB in size.
          </p>
          <h3>2. Flash to a USB Drive</h3>
          <p>
            You will need a USB flash drive with at least 8 GB of capacity. Note that flashing the ISO will erase all existing data on the USB drive.
          </p>
          <div class="grid-2">
            <div class="card">
              <div class="card-title">Using BalenaEtcher (Windows/macOS/Linux)</div>
              <p class="card-desc">
                1. Download and install <a href="https://etcher.balena.io/" target="_blank">BalenaEtcher</a>.<br>
                2. Select the downloaded TelcoChisel ISO file.<br>
                3. Select your target USB drive.<br>
                4. Click <strong>Flash!</strong> and wait for the process and validation to complete.
              </p>
            </div>
            <div class="card">
              <div class="card-title">Using Rufus (Windows only)</div>
              <p class="card-desc">
                1. Download <a href="https://rufus.ie/" target="_blank">Rufus</a>.<br>
                2. Select your USB drive under "Device".<br>
                3. Click "Select" and choose the TelcoChisel ISO.<br>
                4. Leave other settings as default (Partition scheme: MBR, Target system: BIOS or UEFI).<br>
                5. Click <strong>Start</strong>. If prompted, write in DD Image mode.
              </p>
            </div>
          </div>
          <h3>3. Booting from the USB</h3>
          <p>
            1. Insert the flashed USB drive into your target computer.<br>
            2. Reboot the computer and enter the BIOS/UEFI Boot Menu (usually by pressing F12, F10, F8, or Esc during startup).<br>
            3. Select the USB drive from the boot options.<br>
            4. The GRUB bootloader will appear. Select the first option: <strong>Try or Install TelcoChisel</strong>.
          </p>
          <AppCallout type="info" title="Default Live Credentials">
            By default, TelcoChisel will automatically log you into the graphical desktop. If you are ever prompted for a login on the console or lock screen, use:<br>
            <strong>Username:</strong> <code>telcosec</code><br>
            <strong>Password:</strong> <code>telcosec</code>
          </AppCallout>
        </section>

        <!-- SECTION: FEATURES / OS OPTIMIZATIONS -->
        <section id="features" class="content-section" :class="{ active: activeSection === 'features' }" v-show="activeSection === 'features'">
          <div class="section-header" data-label="// Kernel &amp; OS Tuning">
            <h2>OS Customizations &amp; Kernel Tuning for Telecom Security</h2>
            <p class="subtitle">Real-time scheduling, SCTP stack tuning, and low-latency USB for SDR and signaling tools</p>
          </div>

          <p>
            Telecom software suites (like srsRAN, OAI, or SigPloit) place extreme demands on kernel timers, socket memory buffers, and transceiver streaming rates. TelcoChisel applies specific kernel and PAM optimizations by default.
          </p>

          <h3>1. Real-time Scheduling (PAM &amp; Groups)</h3>
          <p>
            Software Defined Radios require consistent scheduling intervals to avoid sample drops (under/overruns). Under standard Linux settings, non-root users cannot request real-time execution priority.
          </p>
          <TerminalBlock title="/etc/security/limits.d/99-realtime.conf" :code="`# Enable real-time scheduling priority up to 99 and unlimited locked memory\n@realtime       -       rtprio          99\n@realtime       -       memlock         unlimited`" />
          <p>
            The default user <code class="inline-code">telcosec</code> belongs to the system <code class="inline-code">realtime</code> group, enabling GNU Radio and srsRAN threads to lock samples into physical RAM and run at scheduling priority 99.
          </p>

          <h3>2. Kernel SCTP Stack Optimizations</h3>
          <p>
            SCTP (Stream Control Transmission Protocol) is the transport layer backbone of telecom networks (SS7/M3UA, Diameter over SCTP, S1AP, and NGAP). Standard OS kernels are optimized for TCP/UDP. TelcoChisel preloads the kernel SCTP module and tunes socket limits in <code class="inline-code">/etc/sysctl.d/99-sctp-tuning.conf</code>:
          </p>
          <TerminalBlock title="SCTP sysctl parameters" :code="`# Increase buffer limits for telecom signaling\nnet.sctp.sctp_mem = 94500000 915000000 927000000\nnet.sctp.sctp_rmem = 4096 87380 8388608\nnet.sctp.sctp_wmem = 4096 16384 8388608\n\n# Tuning retransmission timeouts (prevent scanner hangs)\nnet.sctp.rto_min = 200\nnet.sctp.rto_max = 800\nnet.sctp.association_max_retrans = 4\nnet.sctp.path_max_retrans = 2`" />

          <h3>3. Low-Latency USB &amp; GRUB Configurations</h3>
          <p>
            To run high-bandwidth 5G NR Rogue Base Stations, USB polling jitter must be eliminated. The system deploys udev rules to turn off autosuspend delay on USRP B210 and HackRF hardware:
          </p>
          <TerminalBlock title="/etc/udev/rules.d/51-usb-latency.rules" :code='`ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2514", ATTR{power/autosuspend_delay_ms}="0"\nACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2514", ATTR{power/control}="on"\nACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{power/control}="on"`' />
          <p>
            Additionally, GRUB configs disable CPU mitigations (<code class="inline-code">mitigations=off</code>) and set the clocksource to TSC for stable timing on bare metal installations.
          </p>

          <!-- OS Customizations Card Grid -->
          <h3 style="margin-top: 40px;">OS Customization Guides</h3>
          <p>Each kernel and system configuration topic has a dedicated guide with exact config files, verification commands, and troubleshooting steps:</p>
          <div class="grid-2">
            <div v-for="feat in featuresCatalog" :key="feat.slug" class="card highlight-teal" style="display: flex; flex-direction: column; justify-content: space-between;">
              <div>
                <div class="card-title">
                  {{ feat.name }}
                  <span class="tag" :class="featureCatClass(feat.category)">{{ featureCatLabel(feat.category) }}</span>
                </div>
                <p class="card-desc" style="margin-bottom: 15px;">{{ feat.desc }}</p>
                <TerminalBlock :code="feat.cmd" />
              </div>
              <div class="card-footer-action" style="margin-top: 14px; display: flex; justify-content: flex-end;">
                <NuxtLink :to="`/features/${feat.slug}`" class="btn-tool-link">
                  View Guide
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                    <polyline points="12 5 19 12 12 19"></polyline>
                  </svg>
                </NuxtLink>
              </div>
            </div>
          </div>
        </section>

        <!-- SECTION: TOOLS -->
        <section id="tools" class="content-section" :class="{ active: activeSection === 'tools' }" v-show="activeSection === 'tools'">
          <div class="section-header" data-label="// Tool Catalog :: 50+ Instruments">
            <h2>Tools Directory — 50+ Pre-installed Telecom Security Tools</h2>
            <p class="subtitle">Complete catalog of SDR, baseband, SIM, RAN, and signaling tools pre-installed in TelcoChisel</p>
          </div>

          <div class="directory-controls">
            <div class="search-wrapper" id="searchWrapper">
              <svg class="search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="11" cy="11" r="8"></circle>
                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
              </svg>
              <input
                ref="searchInput"
                type="text"
                id="toolSearch"
                class="search-input"
                placeholder="Search tools by name, command, or details..."
                v-model="searchQuery"
              >
              <div class="search-shortcut" id="searchShortcut" v-show="!searchQuery">
                <kbd>/</kbd>
              </div>
              <button
                v-show="searchQuery"
                class="search-clear-btn"
                aria-label="Clear Search"
                @click="searchQuery = ''"
              >
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <line x1="18" y1="6" x2="6" y2="18"></line>
                  <line x1="6" y1="6" x2="18" y2="18"></line>
                </svg>
              </button>
            </div>
            <div class="filter-tags">
              <button
                v-for="f in filters"
                :key="f.id"
                class="filter-btn"
                :class="{ active: activeFilter === f.id }"
                @click="activeFilter = f.id"
              >
                {{ f.label }} ({{ filterCount(f.id) }})
              </button>
            </div>
          </div>

          <div class="grid-2">
            <div v-if="filteredTools.length === 0" style="grid-column:1/-1; text-align:center; padding:40px; color:var(--text-muted);">
              <p>No tools match your query.</p>
            </div>
            <div v-for="tool in filteredTools" :key="tool.name" class="card highlight-teal" style="display: flex; flex-direction: column; justify-content: space-between;">
              <div>
                <div class="card-title">
                  {{ tool.name }}
                  <span class="tag" :class="tagClass(tool.category)">{{ tagLabel(tool.category) }}</span>
                  <span class="tag" :class="tool.status === 'setup' ? 'status-setup' : 'status-ready'">{{ tool.status === 'setup' ? 'Setup required' : 'Ready' }}</span>
                </div>
                <p class="card-desc" style="margin-bottom:15px;">{{ tool.desc }}</p>
                <div style="font-size:0.8rem;color:var(--text-muted);margin-bottom:6px;">
                  <strong>Location:</strong> <code class="inline-code" style="color:var(--text-secondary);">{{ tool.path }}</code>
                </div>
                <TerminalBlock :code="tool.cmd" />
              </div>
              <div class="card-footer-action" style="margin-top: 14px; display: flex; justify-content: flex-end;">
                <NuxtLink :to="`/tools/${tool.slug}`" class="btn-tool-link">
                  View Guide
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                    <polyline points="12 5 19 12 12 19"></polyline>
                  </svg>
                </NuxtLink>
              </div>
            </div>
          </div>
        </section>

        <!-- SECTION: DRIVERS -->
        <section id="drivers" class="content-section" :class="{ active: activeSection === 'drivers' }" v-show="activeSection === 'drivers'">
          <div class="section-header" data-label="// Hardware :: RF Transceiver Access">
            <h2>SDR Drivers &amp; Hardware Access — USRP, HackRF, BladeRF, LimeSDR, RTL-SDR</h2>
            <p class="subtitle">Non-root USB access for SDR transceivers and smartcard readers via custom udev rules</p>
          </div>

          <p>
            Traditional security environments force you to run RF interfaces as root to access raw USB descriptors. TelcoChisel utilizes custom udev permissions, allowing members of the standard <code class="inline-code">plugdev</code> group to read and write directly to transceivers.
          </p>

          <h3>1. Non-Root Hardware Access Rules</h3>
          <p>
            The file <code class="inline-code">/etc/udev/rules.d/50-telcosec-hw.rules</code> maps USB product and vendor codes, assigning ownership group to <code class="inline-code">plugdev</code> and opening permissions:
          </p>
          <TerminalBlock title="udev Vendor / Product Maps" :code='`# RTL-SDR Dongles\nSUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", MODE:="0666", GROUP:="plugdev"\n# HackRF One\nATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", SYMLINK+="hackrf-%k", MODE:="660", GROUP:="plugdev"\n# Ettus USRP B-Series\nATTRS{idVendor}=="2514", ATTRS{idProduct}=="0002", MODE:="0660", GROUP:="plugdev"\n# Osmocom SIMtrace 2 sniffer\nATTRS{idVendor}=="1d50", ATTRS{idProduct}=="60e3", MODE:="0660", GROUP:="plugdev"`' />

          <h3>2. Software Defined Radio (SDR) Drivers Sandbox</h3>
          <p>
            GNU Radio and hardware transceiver drivers are isolated in a custom Conda environment named <code class="inline-code">telcosec-sdr</code>. This prevents host apt-package scripts or pip executions from breaking driver configurations.
          </p>
          <p>
            To execute commands that require UHD, HackRF, LimeSDR, or SoapySDR bindings, activate the virtual environment:
          </p>
          <TerminalBlock title="Activate Conda Environment" :code="`# Activate sandbox\nconda activate telcosec-sdr\n\n# Verify SoapySDR driver bindings are visible\nSoapySDRUtil --find`" />

          <h3>3. Smartcard PC/SC Readers (SIM Auditing)</h3>
          <p>
            Auditing physical smartcards requires communicating with USB smartcard adapters. TelcoChisel preconfigures the standard PC/SC daemon (<code class="inline-code">pcscd</code>). Insert your card reader (e.g. Omnikey, ACS) and run:
          </p>
          <TerminalBlock title="Query Smartcard Readers" :code="`# Check daemon state\nsudo systemctl status pcscd\n\n# List connected card readers and cards\npcsc_scan`" />

          <!-- Hardware / Driver Card Grid -->
          <h3 style="margin-top: 40px;">4. Supported Hardware — Setup Guides</h3>
          <p>Each supported transceiver and smartcard reader has a dedicated setup guide with udev rules, diagnostic commands, and troubleshooting steps:</p>
          <div class="grid-2">
            <div v-for="drv in driversCatalog" :key="drv.slug" class="card highlight-teal" style="display: flex; flex-direction: column; justify-content: space-between;">
              <div>
                <div class="card-title">
                  {{ drv.name }}
                  <span class="tag" :class="driverTagClass(drv.category)">{{ driverTagLabel(drv.category) }}</span>
                </div>
                <p class="card-desc" style="margin-bottom: 15px;">{{ drv.desc }}</p>
                <TerminalBlock :code="drv.cmd" />
              </div>
              <div class="card-footer-action" style="margin-top: 14px; display: flex; justify-content: flex-end;">
                <NuxtLink :to="`/drivers/${drv.slug}`" class="btn-tool-link">
                  View Guide
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                    <polyline points="12 5 19 12 12 19"></polyline>
                  </svg>
                </NuxtLink>
              </div>
            </div>
          </div>
        </section>

        <!-- SECTION: FUZZER -->
        <section id="fuzzer" class="content-section" :class="{ active: activeSection === 'fuzzer' }" v-show="activeSection === 'fuzzer'">
          <div class="section-header" data-label="// 5Ghoul :: 5G NR Baseband Fuzzer">
            <h2>5Ghoul — 5G NR Baseband Fuzzer Setup Guide</h2>
            <p class="subtitle">Install, configure, and run the 5Ghoul fuzzer against 5G NR UE modems using USRP B210 or BladeRF A4</p>
          </div>

          <p>
            <strong>5Ghoul</strong> is a 5G NR baseband fuzzer. It uses an OpenAirInterface (OAI) rogue base station implementation to transmit malformed RRC, NAS, and MAC messages over the air, uncovering vulnerabilities in smartphones, baseband modems, and IoT modules.
          </p>

          <AppCallout type="warning" title="Compile Deferred to First Run">
            To avoid inflating the ISO size and build times (compiling OAI libraries takes over 30 minutes), the framework dependencies are pre-installed in the OS, but the cloning and compiling steps are deferred to first execution. Do not run 5Ghoul inside a Virtual Machine; it requires native USB 3.0 throughput to stream RF.
          </AppCallout>

          <h3>Deploying 5Ghoul on your Live System</h3>
          <div class="steps-container">
            <div class="step-item">
              <div class="step-badge">1</div>
              <div class="step-title">Execute the Installer</div>
              <div class="step-content">
                Run the installer helper. Provide the radio backend parameter to target either your <strong>USRP B210</strong> (default) or a <strong>BladeRF micro A4</strong>.
                <TerminalBlock title="Compile for Hardware" :code="`# Option A: Compile for USRP B210\nsudo 5ghoul-install\n\n# Option B: Compile for BladeRF A4 (performs patch translations)\nsudo 5ghoul-install --radio BLADERF`" />
              </div>
            </div>

            <div class="step-item">
              <div class="step-badge">2</div>
              <div class="step-title">Start the Core Network</div>
              <div class="step-content">
                5Ghoul simulates the radio interfaces, but requires an active mobile core database to process cellular attachment. Launch Open5GS services and add the default test credentials to the network subscriber database:
                <TerminalBlock title="Setup 5G Core Subscriber" :code="`# Start local 5G SA core functions\nsudo open5gs-start\n\n# Register test subscriber profile\nsudo 5ghoul-add-subscriber`" />
              </div>
            </div>

            <div class="step-item">
              <div class="step-badge">3</div>
              <div class="step-title">Run the Fuzzer</div>
              <div class="step-content">
                Connect your SDR to a USB 3.0 port on the host, place the test smartphone inside an RF shield box connected via coaxial cable, and boot the fuzzer.
                <TerminalBlock title="Launch Fuzzer Engine" :code="`# Run NAS fuzzer suite\nsudo 5ghoul-run --Attack.Name=NAS_5GS_Fuzz --UE.IMSI=001011234567890`" />
              </div>
            </div>
          </div>
        </section>

        <!-- SECTION: BUILDER -->
        <section id="builder" class="content-section" :class="{ active: activeSection === 'builder' }" v-show="activeSection === 'builder'">
          <div class="section-header" data-label="// ISO Build Pipeline :: Ubuntu 24.04">
            <h2>Developer Guide — Building the TelcoChisel Live ISO</h2>
            <p class="subtitle">Build the bootable Ubuntu 24.04 ISO from source on any Ubuntu/Debian host or WSL2</p>
          </div>

          <p>
            TelcoChisel uses an automated bash orchestration build chain to bootstrap, configure, and output bootable GNOME live desktop images.
          </p>

          <h3>1. Setup Compilation Host</h3>
          <p>
            The build environment must be run on a native Ubuntu or Debian host machine (or inside a WSL2 container with systemd enabled). You need approximately 20 GB of free storage.
          </p>
          <TerminalBlock title="Install Host Dependencies" :code="`# Update and install build packages\nsudo apt-get update\nsudo apt-get install -y debootstrap squashfs-tools grub-pc-bin grub-efi-amd64-bin xorriso mtools zstd`" />

          <h3>2. Run the Build Pipeline</h3>
          <p>
            Clone this repository, review configurations inside <code class="inline-code">builder/</code>, and execute the master build script.
          </p>
          <TerminalBlock title="Compile Live ISO" :code="`# Execute compilation\nsudo ./build-iso.sh`" />

          <h3>3. Pipeline Phase Execution Order</h3>
          <p>
            The orchestrator bootstraps a minimal chroot container and runs provisioning scripts sequentially. Do not alter their index prefixes, as each step relies on outputs of the previous scripts:
          </p>
          <table style="width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 0.95rem;">
            <thead>
              <tr style="border-bottom: 2px solid var(--border-color); text-align: left;">
                <th style="padding: 12px; color: #ffffff;">Script File</th>
                <th style="padding: 12px; color: #ffffff;">Provisioning Operation</th>
              </tr>
            </thead>
            <tbody>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">00-install-all-packages.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Pre-downloads all apt packages to speed up provisioning.</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">01-install-base.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Installs GNOME Shell, GDM3, Firefox, base compilers, and sets the live boot user.</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">02-install-sdr.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Creates Conda environment; compiles UHD, HackRF, and BladeRF SDR drivers.</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">03-install-core-network.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Compiles and sets up the srsRAN simulation suite.</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">04-install-tools.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Deploys Wireshark, SigPloit, Diafuzzer, SIPVicious, Scapy, softphones, and dictionaries.</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">05-desktop-customization.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Sets desktop custom wallpapers, icons, Firefox bookmarks toolbar, and start documentation page.</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">06-install-ue-analysis.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Deploys FirmWire baseband QEMU environment, QCSuper, and card programming scripts.</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">07-install-installer.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Integrates the Calamares installer engine with customized TelcoSec branding graphics.</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">08-system-optimization.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Injects the low-latency udev configs, SCTP limits, CPU isolation limits, and CA certificates.</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">09-install-5ghoul.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Deploys the 5Ghoul ogstun virtual network adapters and compilation frameworks.</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">10-install-telecom-advanced.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Clones and builds advanced telecom tools to /opt/telcosec in parallel (UERANSIM, SCAT, kalibrate-gsm, YateBTS, OpenBTS, srsGUI, LTE-CellScanner, LTESniffer, gtp5g).</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">11-install-device-tools.sh</td>
                <td style="padding: 12px; color: var(--text-secondary);">Installs Samsung, Qualcomm, and MediaTek device wrapper scripts to /usr/local/bin.</td>
              </tr>
            </tbody>
          </table>
        </section>

        <!-- SECTION: VIRTUALIZATION -->
        <section id="virtualization" class="content-section" :class="{ active: activeSection === 'virtualization' }" v-show="activeSection === 'virtualization'">
          <div class="section-header" data-label="// Virtualization :: VM Setup & Troubleshooting">
            <h2>Virtualization Guide — VMware, VirtualBox &amp; USB Passthrough</h2>
            <p class="subtitle">Running TelcoChisel in virtual machines: USB passthrough, input device fixes, and SSH-based log extraction</p>
          </div>

          <p>
            Most analysis and protocol tools in TelcoChisel work correctly inside a virtual machine. VMware Workstation and VirtualBox are both supported with some configuration. However, tools relying on high-bandwidth, low-latency USB streams — particularly the <strong>5Ghoul 5G NR baseband fuzzer</strong> — require bare metal or hardware USB 3.0 passthrough.
          </p>

          <AppCallout type="warning" title="USB Bandwidth Constraint for 5Ghoul">
            The 5Ghoul fuzzer streams live RF samples through a USRP B210 or BladeRF A4. These radios require sustained USB 3.0 throughput at ~61 MS/s (megasamples per second). Hypervisors add latency that causes <code class="inline-code">O</code> (overrun) and <code class="inline-code">U</code> (underrun) errors in the UHD driver, which corrupts the 5G NR waveform and makes fuzzing unreliable. Run 5Ghoul on bare metal only.
          </AppCallout>

          <h3>1. Enabling USB 3.0 Passthrough (Non-SDR Tools)</h3>
          <p>
            For non-SDR USB devices (SIM card readers, HID hardware dongles), USB passthrough works reliably when correctly configured:
          </p>
          <div class="steps-container">
            <div class="step-item">
              <div class="step-badge">VMware</div>
              <div class="step-title">VMware Workstation Pro / Fusion</div>
              <div class="step-content">
                <p>In the VM settings, go to <strong>USB Controller</strong> and set compatibility to <strong>USB 3.1</strong>. Enable <strong>"Show all USB input devices"</strong>. For SIM reader passthrough, use <strong>VM → Removable Devices → [Your Reader] → Connect</strong>.
                <TerminalBlock title="Manual filter entry in .vmx file" :code='`usb.autoConnect.device0 = "vid:08e6 pid:3438"  # Gemalto/Thales reader
usb.autoConnect.device1 = "vid:072f pid:2200"  # ACS ACR122U`' /></p>
              </div>
            </div>
            <div class="step-item">
              <div class="step-badge">VBox</div>
              <div class="step-title">VirtualBox USB 3.0 Controller</div>
              <div class="step-content">
                <p>Install the <strong>VirtualBox Extension Pack</strong> (required for USB 3.0). Enable the <strong>USB 3.0 (xHCI) Controller</strong> in VM settings. Add a USB filter for your smartcard reader's vendor/product ID. Without the Extension Pack, only USB 1.1 is available.</p>
              </div>
            </div>
          </div>

          <h3>2. Input Device Freeze — systemd-udevd Initialization Bug</h3>
          <AppCallout type="info" title="Known Issue: Keyboard &amp; Mouse Freeze on Boot">
            On some VMware and VirtualBox configurations, the keyboard and mouse may become completely unresponsive after the GNOME desktop loads. This is caused by a <strong>race condition between <code class="inline-code">systemd-udevd</code> and the virtual HID drivers</strong> during early boot. The udevd daemon re-initializes USB input devices before the virtual bus controller is fully settled, causing the kernel to unbind the HID driver.
          </AppCallout>

          <h4>Root Cause</h4>
          <p>
            The TelcoChisel ISO applies aggressive udev rule reloads and hardware initialization during boot (for the SDR and SIM card hardware). In a virtual environment, this causes <code class="inline-code">systemd-udevd</code> to trigger a <code class="inline-code">REMOVE</code> event for virtual input devices (keyboard, mouse) before the VMware or VirtualBox input controller registers them as settled. The result is the desktop loads but input is dead.
          </p>

          <h4>Fix A: VMware — Edit .vmx Configuration</h4>
          <p>
            Power off the VM completely. Open the <code class="inline-code">.vmx</code> configuration file in a text editor and append the following lines. These settings force VMware to use a legacy PS/2-compatible input model that is immune to udev re-initialization:
          </p>
          <TerminalBlock title="Append to TelcoChisel.vmx" :code='`# Force VMware to use PS/2 keyboard and mouse (avoids udevd race condition)
vmmouse.present = "TRUE"
usb.keyboard.vmport = "FALSE"
keyboard.allowBothIRQs = "FALSE"

# Disable USB HID takeover by VMware Tools
usb.generic.allowHID = "TRUE"
usb.generic.allowLastHID = "TRUE"`' />

          <h4>Fix B: VirtualBox — PS/2 Controller Mode</h4>
          <p>
            In VirtualBox, navigate to <strong>Settings → System → Motherboard</strong> and ensure the <strong>Pointing Device</strong> is set to <strong>"PS/2 Mouse"</strong> (not USB tablet or USB multi-touch). For the keyboard, navigate to <strong>Settings → USB</strong> and disable the USB HID filter if one is present.
          </p>

          <h4>Fix C: Emergency SSH Recovery (If Input Is Already Frozen)</h4>
          <p>
            TelcoChisel pre-configures <code class="inline-code">ufw</code> with an SSH allow rule and starts the <code class="inline-code">openssh-server</code> service at boot. If your input is frozen, you can connect from your host machine and recover:
          </p>
          <TerminalBlock title="SSH into frozen VM from host" :code='`# Find the VM guest IP address (from VMware/VirtualBox network info)
# or check the VM console for IP via: ip addr show

# Connect using default credentials
ssh telcosec@<guest-ip>

# Once inside, collect logs for diagnosis
sudo journalctl -u systemd-udevd --since="1 minute ago" > /tmp/udevd.log
journalctl -k | grep -iE "input|hid|usb" > /tmp/kernel_hid.log

# Copy logs to host for analysis (from host)
scp telcosec@<guest-ip>:/tmp/udevd.log ./guest_udevd.log`' />

          <h3>3. Extracting Xorg Display Logs via SSH</h3>
          <p>
            If the display environment loads but input is unresponsive, the Xorg log captures which input drivers initialized. Retrieve it via SSH:
          </p>
          <TerminalBlock title="Collect Xorg log from frozen VM" :code='`# Option A: Standard Xorg log path
cat /var/log/Xorg.0.log | grep -iE "(EE|WW|Input|Mouse|Keyboard)"

# Option B: If using Xorg with rootless mode (common in Ubuntu 24.04)
journalctl -b --no-pager | grep -i xorg

# Check active input event nodes
ls -la /dev/input/by-id/
evemu-record /dev/input/event0 2>&1 | head -20`' />

          <h3>4. Recommended VM Configuration Summary</h3>
          <table style="width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 0.95rem;">
            <thead>
              <tr style="border-bottom: 2px solid var(--border-color); text-align: left;">
                <th style="padding: 12px; color: #ffffff;">Setting</th>
                <th style="padding: 12px; color: #ffffff;">VMware Workstation</th>
                <th style="padding: 12px; color: #ffffff;">VirtualBox</th>
              </tr>
            </thead>
            <tbody>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; color: var(--text-secondary);">RAM</td>
                <td style="padding: 12px; color: var(--text-secondary);">4 GB minimum, 8 GB recommended</td>
                <td style="padding: 12px; color: var(--text-secondary);">4 GB minimum, 8 GB recommended</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; color: var(--text-secondary);">CPU Cores</td>
                <td style="padding: 12px; color: var(--text-secondary);">2 cores minimum</td>
                <td style="padding: 12px; color: var(--text-secondary);">2 cores minimum</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; color: var(--text-secondary);">USB Controller</td>
                <td style="padding: 12px; color: var(--text-secondary);">USB 3.1 xHCI</td>
                <td style="padding: 12px; color: var(--text-secondary);">USB 3.0 xHCI (requires Extension Pack)</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; color: var(--text-secondary);">Input Device Mode</td>
                <td style="padding: 12px; font-family: monospace; color: var(--accent-teal);">vmmouse.present = TRUE<br>usb.keyboard.vmport = FALSE</td>
                <td style="padding: 12px; color: var(--text-secondary);">Pointing: PS/2 Mouse</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; color: var(--text-secondary);">Network</td>
                <td style="padding: 12px; color: var(--text-secondary);">NAT or Bridged</td>
                <td style="padding: 12px; color: var(--text-secondary);">NAT or Bridged</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; color: var(--text-secondary);">3D Acceleration</td>
                <td style="padding: 12px; color: var(--text-secondary);">Optional (for UI smoothness)</td>
                <td style="padding: 12px; color: var(--text-secondary);">Optional (VMSVGA adapter)</td>
              </tr>
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 12px; color: var(--text-secondary);">5Ghoul / SDR</td>
                <td style="padding: 12px; color: var(--text-secondary); color: #ff6b6b;">❌ Not supported (USB latency)</td>
                <td style="padding: 12px; color: #ff6b6b;">❌ Not supported (USB latency)</td>
              </tr>
            </tbody>
          </table>
        </section>

        <!-- SECTION: PROJECTS -->
        <section id="projects" class="content-section" :class="{ active: activeSection === 'projects' }" v-show="activeSection === 'projects'">
          <div class="section-header" data-label="// Research Ecosystem :: Open Source">
            <h2>TelcoSec Open-Source Projects &amp; Research Ecosystem</h2>
            <p class="subtitle">Tools, labs, vulnerability databases, and community resources for telecom security professionals</p>
          </div>

          <p>
            TelcoSec is an open-source research collective developing security auditing platforms, simulation nodes, and vulnerability databases for mobile telecom networks. Explore our core open source projects included in the distribution:
          </p>

          <h3>Core Repositories</h3>
          <div class="grid-2">
            <div class="card highlight-teal">
              <div class="card-title">
                SctpX
                <span class="tag tag-ran">Rust</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                A high-performance, multi-threaded SCTP protocol scanner and interface auditing framework written in Rust. Designed specifically to map cellular core signaling surfaces (SIGTRAN, M3UA, S1AP, NGAP, Diameter) and audit link capacity.
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Repository:</strong> <a href="https://github.com/TelcoSec/SctpX" target="_blank">github.com/TelcoSec/SctpX</a>
              </div>
            </div>

            <div class="card highlight-teal">
              <div class="card-title">
                TelcoChisel
                <span class="tag tag-sys">Shell / Config</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                The official build ecosystem for compiling this custom GNOME Debian/Ubuntu live ISO. Contains baseband configurations, customized system-wide Wireshark columns, real-time udev configs, and kernel tuners.
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Repository:</strong> <a href="https://github.com/TelcoSec-Tools/TelcoChiselOS" target="_blank">github.com/TelcoSec-Tools/TelcoChiselOS</a>
              </div>
            </div>

            <div class="card highlight-teal">
              <div class="card-title">
                TelcoSec Wordlists
                <span class="tag tag-sim">Data</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                Telecom-specific wordlist collection bundled in the ISO at <code>/usr/share/wordlists/telecom/</code>. Covers carrier APNs, VoIP/SIP credentials, RAN element passwords, SIM OTA test keys, hardware defaults, PLMNs/IMSI prefixes, and protocol-level lists for 5G NAS, GTP, SS7, Diameter, SMS, and USSD. Helper scripts <code>telcosec-apn-permutator</code> and <code>telcosec-imsi-generator</code> are available on PATH.
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Location:</strong> <code>/usr/share/wordlists/telecom/</code>
              </div>
            </div>

            <div class="card highlight-teal">
              <div class="card-title">
                Downstream Security Patches
                <span class="tag tag-ue">Forks</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                Optimized downstream forks of critical security tools such as FirmWire (modified QEMU fuzzers), lpac (enhanced eSIM LPA profiles), and QCSuper (Noble Numbat USB descriptor fixes).
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Repositories:</strong> <a href="https://github.com/TelcoSec" target="_blank">github.com/TelcoSec</a>
              </div>
            </div>
          </div>

          <h3 style="margin-top: 40px;">Platforms &amp; Research Ecosystem</h3>
          <div class="grid-2">
            <div class="card highlight-teal">
              <div class="card-title">
                TelcoSec Labs
                <span class="tag tag-ue">Environments</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                Open-source network lab topologies, Docker-based test setups (Open5GS, srsRAN, Kamailio), and experimental codebases for protocol testing and fuzzing.
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Repository:</strong> <a href="https://github.com/TelcoSec-Labs" target="_blank">github.com/TelcoSec-Labs</a>
              </div>
            </div>

            <div class="card highlight-teal">
              <div class="card-title">
                Vulnerability Database (VulnDB)
                <span class="tag tag-sys">Research</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                A curated CVE and hardware vulnerability database tracking baseband memory leaks, IMS signaling bypasses, and air interface flaws in production equipment.
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Platform:</strong> <a href="https://vulndb.telcosec.cloud/" target="_blank">vulndb.telcosec.cloud</a>
              </div>
            </div>

            <div class="card highlight-teal">
              <div class="card-title">
                Telecom Calculators
                <span class="tag tag-sim">Tools</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                Web-based engineering calculators for telecom protocols, enabling calculations for ARFCN/EARFCN/NR-ARFCN, IMSI check-digits, diameter AVPs, and network planning.
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Platform:</strong> <a href="https://calculators.telcosec.cloud/" target="_blank">calculators.telcosec.cloud</a>
              </div>
            </div>

            <div class="card highlight-teal">
              <div class="card-title">
                Capture The Flag (CTF) Portal
                <span class="tag tag-ran">Training</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                Structured security challenges focusing on mobile networking, SIGTRAN packet analysis, baseband firmware decompilation, and GSM air capture decoding.
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Platform:</strong> <a href="https://ctf.telcosec.cloud/" target="_blank">ctf.telcosec.cloud</a>
              </div>
            </div>

            <div class="card highlight-teal">
              <div class="card-title">
                3GPP Specification Tracker
                <span class="tag tag-ran">Standards</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                A tracker mapping standards modifications, security releases, and technical reports across releases 15 to 18 of the 3GPP standards body.
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Platform:</strong> <a href="https://3gpp.telcosec.cloud/" target="_blank">3gpp.telcosec.cloud</a>
              </div>
            </div>

            <div class="card highlight-teal">
              <div class="card-title">
                Research Library
                <span class="tag tag-sys">Docs</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                A curated collection of baseband security research papers, RAN exploit walkthroughs, and technical specifications for telecom consultants.
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Platform:</strong> <a href="https://library.telcosec.cloud/" target="_blank">library.telcosec.cloud</a>
              </div>
            </div>

            <div class="card highlight-teal">
              <div class="card-title">
                Portable BTS Blueprints
                <span class="tag tag-ran">Hardware</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                Blueprints, hardware bill of materials (BOM), and software setup instructions for deploying portable SDR-based base stations and over-the-air test labs.
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Platform:</strong> <a href="https://portable-bts.telcosec.cloud/" target="_blank">portable-bts.telcosec.cloud</a>
              </div>
            </div>

            <div class="card highlight-teal">
              <div class="card-title">
                Technical Newsletter (Substack)
                <span class="tag tag-sys">Advisories</span>
              </div>
              <p class="card-desc" style="margin-bottom: 15px;">
                Monthly research notes, telecom security advisories, vulnerability disclosures, and CTF writeups straight to your inbox.
              </p>
              <div style="font-size: 0.85rem; color: var(--text-muted);">
                <strong>Subscribe:</strong> <a href="https://telcosec.substack.com/" target="_blank">telcosec.substack.com</a>
              </div>
            </div>
          </div>

          <h3>Community &amp; Collaboration Channels</h3>
          <div class="grid-3" style="margin-top: 10px;">
            <a href="https://discord.gg/RykzXTQFXF" class="card highlight-teal" target="_blank">
              <div class="card-title" style="color: var(--accent-teal);">Discord Chat</div>
              <p class="card-desc" style="font-size: 0.85rem;">Join telecom security discussions, help threads, and share radio captures in real time.</p>
            </a>
            <a href="https://www.linkedin.com/company/telco-sec" class="card highlight-teal" target="_blank">
              <div class="card-title" style="color: var(--accent-teal);">LinkedIn Updates</div>
              <p class="card-desc" style="font-size: 0.85rem;">Follow the official TelcoSec company page for announcements and event listings.</p>
            </a>
            <a href="https://www.youtube.com/@Telecom-Security" class="card highlight-teal" target="_blank">
              <div class="card-title" style="color: var(--accent-teal);">YouTube Channel</div>
              <p class="card-desc" style="font-size: 0.85rem;">Video tutorials, lab walkthroughs, conference presentations, and hardware reviews.</p>
            </a>
          </div>
        </section>

        <!-- SECTION: LEGAL -->
        <section id="legal" class="content-section" :class="{ active: activeSection === 'legal' }" v-show="activeSection === 'legal'">
          <div class="section-header" data-label="// Reference :: Legal Disclaimer">
            <h2>Legal Disclaimer</h2>
            <p class="subtitle">Important notices regarding RF transmissions and liability</p>
          </div>
          <AppCallout type="warning" title="Strictly For Authorized Use">
            <strong>TelcoChisel is designed solely for authorized security audits, academic research, and educational experimentation in controlled laboratories.</strong>
          </AppCallout>
          <p>
            Radio frequencies are heavily regulated by government authorities worldwide (e.g., the FCC in the United States, Ofcom in the UK, CEPT in Europe). Users of TelcoChisel are strictly responsible for complying with all local regulations, radio licensing requirements, and privacy laws.
          </p>
          <p>
            Intercepting, decoding, or transmitting over public cellular channels without explicit authorization and an appropriate experimental radio license is illegal in most countries and can result in severe civil and criminal penalties. TelcoSec and the contributors to TelcoChisel assume no liability for the misuse of this software.
          </p>
        </section>

      </main>
    </div>

    <!-- Download Responsibility Modal -->
    <Teleport to="body">
      <div v-if="downloadModalOpen" class="dl-modal-backdrop" @click.self="downloadModalOpen = false">
        <div class="dl-modal" role="dialog" aria-modal="true" aria-labelledby="dl-modal-title">
          <div class="dl-modal-header">
            <svg class="dl-modal-icon" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
            </svg>
            <div>
              <div class="dl-modal-title" id="dl-modal-title">Download TelcoChisel</div>
              <div class="dl-modal-sub">Public Beta &mdash; v1.1.0</div>
            </div>
          </div>

          <div class="dl-modal-body">
            <p>TelcoChisel is a <strong>solo project</strong> in public beta — built and maintained by one person in their spare time. New fixes ship as I go. If you find it useful, I'd love your help.</p>

            <div class="dl-modal-status">
              <div class="dl-modal-status-dot"></div>
              <div class="dl-modal-status-text">
                <strong>OS: Stable.</strong> The Ubuntu 24.04 GNOME desktop, boot sequence, and core system are production-ready.<br>
                <strong>Tools:</strong> Integration ongoing — some launchers may need a rebuild to reflect the latest fixes.
              </div>
            </div>

            <div class="dl-modal-disclaimer">
              <strong style="color: var(--amber);">Responsible Use.</strong> TelcoChisel is built for authorized security research, penetration testing with written permission, academic study, and CTF competitions. You are solely responsible for ensuring your use complies with applicable laws and regulations. I accept no liability for misuse.
            </div>
          </div>

          <div class="dl-modal-actions">
            <a href="https://sourceforge.net/projects/telcochisel/" target="_blank" class="btn-download" @click="downloadModalOpen = false">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
              I Understand — Download
            </a>
            <button class="btn-cancel" @click="downloadModalOpen = false">Cancel</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>
<script setup>
import { toolsCatalog } from '~/data/tools.js'
import { driversCatalog } from '~/data/drivers.js'
import { featuresCatalog } from '~/data/features.js'

const { gtag } = useGtag()

function trackDownload() {
  gtag('event', 'download_iso_intent', { event_category: 'engagement', event_label: 'TelcoChisel_ISO' })
  downloadModalOpen.value = true
}

function trackAcademy() {
  gtag('event', 'outbound_academy', { event_category: 'outbound', event_label: 'TelcoSec_Academy' })
}

// SEO metadata
useHead({
  title: 'TelcoChisel: Advanced Telecom Security OS by TelcoSec',
  meta: [
    { name: 'description', content: 'TelcoChisel by TelcoSec is the ultimate free bootable Linux OS for advanced Telecom Security research. Ships with 50+ tools for SDR analysis and cellular penetration testing.' },
    { name: 'keywords', content: 'TelcoSec, TelcoChisel, Telecom Security, 5G security research, 4G LTE penetration testing, SDR security, baseband analysis, FirmWire, GNU Radio, srsRAN, Open5GS' },
    { name: 'author', content: 'TelcoSec' },
    { name: 'robots', content: 'index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1' },
    { name: 'theme-color', content: '#00ffd5' },
    { property: 'og:type', content: 'website' },
    { property: 'og:site_name', content: 'TelcoSec' },
    { property: 'og:url', content: 'https://tschisel.telcosec.net/' },
    { property: 'og:title', content: 'TelcoChisel: Advanced Telecom Security OS by TelcoSec' },
    { property: 'og:description', content: 'TelcoChisel by TelcoSec is the ultimate free bootable Linux OS for advanced Telecom Security research. Ships with 50+ tools for SDR analysis and cellular penetration testing.' },
    { property: 'og:image', content: 'https://raw.githubusercontent.com/TelcoSec-Tools/TelcoChiselOS/main/assets/repo_cover.png' },
    { property: 'og:image:width', content: '1280' },
    { property: 'og:image:height', content: '640' },
    { property: 'og:image:alt', content: 'TelcoChisel — Telecom Security Linux Distribution' },
    { property: 'og:locale', content: 'en_US' },
    { name: 'twitter:card', content: 'summary_large_image' },
    { name: 'twitter:site', content: '@TelcoSec' },
    { name: 'twitter:creator', content: '@TelcoSec' },
    { name: 'twitter:url', content: 'https://tschisel.telcosec.net/' },
    { name: 'twitter:title', content: 'TelcoChisel: Advanced Telecom Security OS by TelcoSec' },
    { name: 'twitter:description', content: 'TelcoChisel by TelcoSec is the ultimate free bootable Linux OS for advanced Telecom Security research. Ships with 50+ tools for SDR analysis and cellular penetration testing.' },
    { name: 'twitter:image', content: 'https://raw.githubusercontent.com/TelcoSec-Tools/TelcoChiselOS/main/assets/repo_cover.png' }
  ],
  link: [
    { rel: 'canonical', href: 'https://tschisel.telcosec.net/' },
    { rel: 'icon', type: 'image/svg+xml', href: "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2300ffd5' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z'/%3E%3Cpath d='M12 8v4'/%3E%3Cpath d='M12 16h.01'/%3E%3C/svg%3E" }
  ],
  script: [
    {
      type: 'application/ld+json',
      children: JSON.stringify([
        {
          "@context": "https://schema.org",
          "@type": "SoftwareApplication",
          "name": "TelcoChisel",
          "applicationCategory": "SecurityApplication",
          "applicationSubCategory": "Telecommunications Security, Software Defined Radio, Baseband Analysis",
          "operatingSystem": "Linux (Ubuntu 24.04 LTS)",
          "description": "TelcoChisel is a free, bootable live Linux distribution purpose-built for 5G and 4G telecom security research. It ships with 50+ pre-configured tools including GNU Radio, FirmWire baseband emulation, srsRAN, Open5GS, SIMtrace 2, QCSuper, Wireshark, and the 5Ghoul 5G NR fuzzer.",
          "url": "https://tschisel.telcosec.net/",
          "downloadUrl": "https://sourceforge.net/projects/telcochisel/",
          "softwareVersion": "1.1.0",
          "releaseNotes": "https://github.com/TelcoSec-Tools/TelcoChiselOS/releases",
          "screenshot": "https://raw.githubusercontent.com/TelcoSec-Tools/TelcoChiselOS/main/assets/repo_cover.png",
          "featureList": [
            "SDR drivers for USRP B210, HackRF One, BladeRF, LimeSDR, and RTL-SDR compiled from source",
            "Baseband firmware emulation with FirmWire (Samsung Shannon and MediaTek MTK)",
            "5G NR fuzzing with 5Ghoul over OAI rogue gNodeB",
            "SIM and eSIM auditing with pySim-shell, SIMtrace 2, and lpac LPA",
            "5G SA core network with Open5GS and MongoDB",
            "4G/5G RAN simulation with srsRAN",
            "SS7, Diameter, GTP, and SIP protocol exploitation tools",
            "Custom Wireshark dissector profiles for GSMTAP, 5G NAS, Diameter, and GTP",
            "SCTP kernel tuning and real-time scheduling for SDR stability",
            "Calamares live-to-disk installer"
          ],
          "license": "https://github.com/TelcoSec-Tools/TelcoChiselOS/blob/main/LICENSE",
          "offers": {
            "@type": "Offer",
            "price": "0",
            "priceCurrency": "USD",
            "availability": "https://schema.org/InStock"
          },
          "publisher": {
            "@type": "Organization",
            "name": "TelcoSec",
            "url": "https://telcosec.cloud/",
            "sameAs": [
              "https://github.com/TelcoSec",
              "https://sourceforge.net/projects/telcochisel/",
              "https://www.linkedin.com/company/telco-sec",
              "https://www.youtube.com/@Telecom-Security"
            ]
          }
        },
        {
          "@context": "https://schema.org",
          "@type": "WebSite",
          "name": "TelcoChisel Documentation",
          "url": "https://tschisel.telcosec.net/",
          "description": "Official documentation for TelcoChisel — a free Linux distribution for 5G/4G telecom security research.",
          "publisher": {
            "@type": "Organization",
            "name": "TelcoSec",
            "url": "https://telcosec.cloud/"
          },
          "potentialAction": {
            "@type": "SearchAction",
            "target": "https://tschisel.telcosec.net/#tools?q={search_term_string}",
            "query-input": "required name=search_term_string"
          }
        },
        {
          "@context": "https://schema.org",
          "@type": "FAQPage",
          "mainEntity": [
            {
              "@type": "Question",
              "name": "What is TelcoChisel?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "TelcoChisel is a free, bootable live Linux distribution based on Ubuntu 24.04 LTS (Noble Numbat) with a GNOME desktop, purpose-built for telecommunications security research. It includes 50+ pre-configured tools for Software Defined Radio (SDR) analysis, baseband firmware auditing, SIM and eSIM inspection, and 5G/4G core network penetration testing."
              }
            },
            {
              "@type": "Question",
              "name": "What SDR hardware does TelcoChisel support?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "TelcoChisel includes drivers compiled from source for the Ettus Research USRP B210, Great Scott Gadgets HackRF One, Nuand BladeRF 2.0 micro xA4, LimeSDR, and RTL-SDR dongles. All radio drivers and GNU Radio are isolated in a Conda virtual environment named telcosec-sdr to prevent dependency conflicts."
              }
            },
            {
              "@type": "Question",
              "name": "What are the default login credentials for TelcoChisel?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "The default live boot credentials are username: telcosec and password: telcosec. The system is configured for graphical autologin, so you will only be prompted if autologin is disabled."
              }
            },
            {
              "@type": "Question",
              "name": "How do I build the TelcoChisel ISO?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "Run 'sudo ./build-iso.sh' on an Ubuntu or Debian host after installing: debootstrap, squashfs-tools, grub-pc-bin, grub-efi-amd64-bin, xorriso, and mtools. The build requires approximately 20 GB of free disk space and takes 30 to 60 minutes. On Windows, you can build inside WSL2."
              }
            },
            {
              "@type": "Question",
              "name": "Can I run TelcoChisel in a virtual machine?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "Most analysis tools work in a VM. However, SDR tools requiring native USB 3.0 passthrough — particularly when running the 5Ghoul 5G NR fuzzer — need bare metal installation for reliable operation due to USB latency requirements."
              }
            },
            {
              "@type": "Question",
              "name": "How do I install 5Ghoul on TelcoChisel?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "Run 'sudo 5ghoul-install' for a USRP B210, or 'sudo 5ghoul-install --radio BLADERF' for a BladeRF A4. The installer clones the 5Ghoul repository, applies radio-specific patches, and compiles OpenAirInterface. This takes 20–60 minutes on first run. All build dependencies are pre-installed in the ISO."
              }
            },
            {
              "@type": "Question",
              "name": "What telecom protocol analysis tools are included?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "TelcoChisel includes: Wireshark with custom GSMTAP/5G NAS/Diameter/GTP dissector profiles, SigPloit (SS7/Diameter/GTP exploitation), Diafuzzer (Diameter fuzzer by Orange), SIPVicious (SIP/VoIP scanner), sctpscan (SCTP port scanner for SIGTRAN/S1AP/NGAP), and Scapy with built-in modules for M3UA, TCAP, MAP, and Diameter packet crafting."
              }
            }
          ]
        },
        {
          "@context": "https://schema.org",
          "@type": "HowTo",
          "name": "How to deploy 5Ghoul 5G NR Baseband Fuzzer",
          "description": "Install, configure, and run the 5Ghoul fuzzer against 5G NR UE modems using USRP B210 or BladeRF A4.",
          "step": [
            {
              "@type": "HowToStep",
              "name": "Execute the Installer",
              "text": "Run the installer helper. Provide the radio backend parameter to target either your USRP B210 (sudo 5ghoul-install) or a BladeRF micro A4 (sudo 5ghoul-install --radio BLADERF)."
            },
            {
              "@type": "HowToStep",
              "name": "Start the Core Network",
              "text": "Launch Open5GS services and add the default test credentials to the network subscriber database using sudo open5gs-start and sudo 5ghoul-add-subscriber."
            },
            {
              "@type": "HowToStep",
              "name": "Run the Fuzzer",
              "text": "Connect your SDR to a USB 3.0 port on the host, place the test smartphone inside an RF shield box connected via coaxial cable, and run the fuzzer engine (sudo 5ghoul-run --Attack.Name=NAS_5GS_Fuzz --UE.IMSI=001011234567890)."
            }
          ]
        }
      ])
    }
  ]
})

// Section navigation
const VALID_SECTIONS = ['overview', 'installation', 'features', 'tools', 'drivers', 'fuzzer', 'builder', 'virtualization', 'projects', 'legal']
const activeSection = ref('overview')
const sidebarOpen = ref(false)
const downloadModalOpen = ref(false)

function navigate(section) {
  if (!VALID_SECTIONS.includes(section)) section = 'overview'
  activeSection.value = section
  if (import.meta.client) {
    history.pushState(null, '', '#' + section)
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
  sidebarOpen.value = false
}

onMounted(() => {
  const hash = window.location.hash.slice(1)
  if (hash) navigate(hash)
  window.addEventListener('popstate', () => navigate(window.location.hash.slice(1) || 'overview'))
  if (localStorage.getItem('theme') === 'light') document.body.classList.add('light-theme')
})

// Theme
function toggleTheme() {
  const isLight = document.body.classList.toggle('light-theme')
  localStorage.setItem('theme', isLight ? 'light' : 'dark')
}

// Tools directory
const activeFilter = ref('all')
const searchQuery = ref('')
const filters = [
  { id: 'all',      label: 'All Tools' },
  { id: 'adsl',     label: 'ADSL & Broadband' },
  { id: 'sim',      label: 'SIM Cards & Smartcards' },
  { id: '2g',       label: 'Mobile (2G / GSM)' },
  { id: '3g',       label: 'Mobile (3G / UMTS)' },
  { id: '4g',       label: 'Mobile (4G / LTE)' },
  { id: '5g',       label: 'Mobile (5G / NR)' },
  { id: 'mw',       label: 'Microwave (MW) & Transport' },
  { id: 'voip',     label: 'VoIP & PBX' },
  { id: 'core',     label: 'Core Network & Signaling' },
  { id: 'baseband', label: 'Baseband & UE Devices' },
  { id: 'sdr',      label: 'SDR & RF Hardware' }
]
const filteredTools = computed(() => toolsCatalog.filter(t => {
  const matchCat = activeFilter.value === 'all' || t.category === activeFilter.value
  const q = searchQuery.value.toLowerCase()
  const matchSearch = !q || t.name.toLowerCase().includes(q) || t.desc.toLowerCase().includes(q) || t.cmd.toLowerCase().includes(q)
  return matchCat && matchSearch
}))
function filterCount(id) {
  if (id === 'all') return toolsCatalog.length
  return toolsCatalog.filter(t => t.category === id).length
}

// Keyboard shortcut for search
const searchInput = ref(null)
onMounted(() => {
  document.addEventListener('keydown', (e) => {
    const tag = document.activeElement.tagName.toLowerCase()
    if ((e.key === '/' || ((e.ctrlKey || e.metaKey) && e.key === 'k')) && tag !== 'input' && tag !== 'textarea') {
      e.preventDefault()
      searchInput.value?.focus()
      navigate('tools')
    }
  })
})

// Tag helpers
function tagClass(cat) {
  return {
    adsl:     'tag-network',
    sim:      'tag-sim',
    '2g':     'tag-gsm',
    '3g':     'tag-lte',
    '4g':     'tag-lte',
    '5g':     'tag-5g',
    mw:       'tag-sys',
    voip:     'tag-voip',
    core:     'tag-ran',
    baseband: 'tag-ue',
    sdr:      'tag-sdr'
  }[cat] || ''
}
function tagLabel(cat) {
  return {
    adsl:     'ADSL & Broadband',
    sim:      'SIM Cards & Smartcards',
    '2g':     'Mobile (2G / GSM)',
    '3g':     'Mobile (3G / UMTS)',
    '4g':     'Mobile (4G / LTE)',
    '5g':     'Mobile (5G / NR)',
    mw:       'Microwave (MW) & Transport',
    voip:     'VoIP & PBX',
    core:     'Core Network & Signaling',
    baseband: 'Baseband & UE Devices',
    sdr:      'SDR & RF Hardware'
  }[cat] || cat
}

// Driver / hardware tag helpers
function driverTagClass(cat) {
  return {
    transceiver: 'tag-sdr',
    sniffing:    'tag-sim',
    reader:      'tag-device'
  }[cat] || ''
}
function driverTagLabel(cat) {
  return {
    transceiver: 'RF Transceiver',
    sniffing:    'Sniffer Hardware',
    reader:      'Smartcard Reader'
  }[cat] || cat
}

// OS Customizations / Features tag helpers
function featureCatClass(cat) {
  return {
    kernel:      'tag-5g',
    network:     'tag-ran',
    security:    'tag-sim',
    hardware:    'tag-sdr',
    tools:       'tag-lte',
    environment: 'tag-ue'
  }[cat] || ''
}
function featureCatLabel(cat) {
  return {
    kernel:      'Kernel Tuning',
    network:     'Network Stack',
    security:    'Security Hardening',
    hardware:    'Hardware Access',
    tools:       'Tool Config',
    environment: 'Dev Environment'
  }[cat] || cat
}
</script>
