<template>
  <div>
    <BootOverlay />
    <div class="sidebar-overlay" :class="{ active: sidebarOpen }" @click="sidebarOpen = false" id="sidebarOverlay"></div>
    <div class="layout-container">
      <AppSidebar :active-section="'playbooks'" :open="sidebarOpen" @navigate="navigateHome" @toggle-theme="toggleTheme" />

      <button class="mobile-nav-toggle" id="mobileToggle" @click="sidebarOpen = !sidebarOpen">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="3" y1="12" x2="21" y2="12"></line>
          <line x1="3" y1="6" x2="21" y2="6"></line>
          <line x1="3" y1="18" x2="21" y2="18"></line>
        </svg>
      </button>

      <main class="main-content">
        <!-- Breadcrumbs -->
        <nav class="breadcrumbs" aria-label="Breadcrumb">
          <NuxtLink to="/" class="breadcrumb-link">Home</NuxtLink>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">Playbooks</span>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">Baseband Emulation with FirmWire</span>
        </nav>

        <article class="feature-details-page">
          <!-- Page Header -->
          <header class="section-header" data-label="// Operator Playbook :: Baseband Reverse Engineering">
            <h1 class="feature-name">Cellular Baseband Emulation &amp; Fuzzing with FirmWire</h1>
            <div class="feature-meta-badges">
              <span class="tag tag-baseband">Baseband</span>
              <span class="tag status-ready">QEMU / AFL++</span>
            </div>
          </header>

          <!-- Technical Overview -->
          <section class="feature-info-section">
            <h2>Overview &amp; Audit Objective</h2>
            <div class="feature-long-desc">
              <p>
                FirmWire allows researchers to run uncompressed vendor baseband firmware binaries (Samsung Shannon and MediaTek)
                in an instrumented QEMU emulator. This playbook guides operators through extracting modem firmware images,
                booting the virtualized baseband RTOS, attaching GDB debuggers, and fuzzing GSM/LTE/5G protocol handlers with AFL++.
              </p>
            </div>
          </section>

          <!-- Workflow Steps -->
          <section class="feature-info-section">
            <h2>Execution Steps</h2>
            <ol class="numbered-guide-list">
              <li>
                <span class="guide-number">1</span>
                <div class="guide-text-block">
                  <strong>Prepare Baseband Firmware Image:</strong>
                  <p>Extract modem image (e.g. <code>modem.bin</code>) from device OTA or vendor TAR archive:</p>
                  <TerminalBlock title="Terminal — Extract Image" code="mkdir -p /tmp/firmware &amp;&amp; cd /tmp/firmware&#10;tar -xf firmware.tar.md5 modem.bin 2>/dev/null || true" />
                </div>
              </li>
              <li>
                <span class="guide-number">2</span>
                <div class="guide-text-block">
                  <strong>Launch FirmWire Baseband Emulator:</strong>
                  <p>Boot the virtualized modem OS with interactive logging and GDB server enabled on port 1234:</p>
                  <TerminalBlock title="Terminal — Boot Shannon Baseband" code="cd /opt/telcosec/firmwire&#10;python3 -m firmwire.firmwire --gdb /tmp/firmware/modem.bin" />
                </div>
              </li>
              <li>
                <span class="guide-number">3</span>
                <div class="guide-text-block">
                  <strong>Inject Cellular Signalling Frames:</strong>
                  <p>Transmit crafted RRC or NAS protocol packets directly into the baseband virtual transceiver:</p>
                  <TerminalBlock title="Terminal — Inject RRC Frame" code="python3 firmwire/scripts/inject_frame.py --pcap test_rrc.pcap" />
                </div>
              </li>
              <li>
                <span class="guide-number">4</span>
                <div class="guide-text-block">
                  <strong>Attach Debugger &amp; Triage Crashes:</strong>
                  <p>Inspect CPU registers and stack traces when memory corruptions or panics occur:</p>
                  <TerminalBlock title="Terminal — GDB Multiarch" code="gdb-multiarch -ex &quot;target remote localhost:1234&quot;" />
                </div>
              </li>
            </ol>
          </section>

          <!-- Evidence Collection -->
          <section class="feature-info-section">
            <h2>Evidence &amp; Artifact Archiving</h2>
            <p>Export baseband crash dumps, execution traces, and reproduction PCAPs:</p>
            <TerminalBlock title="Terminal — Bundle Evidence" code="telcosec bundle-evidence firmwire-crash-triage" />
          </section>
        </article>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const sidebarOpen = ref(false)

const navigateHome = () => {
  navigateTo('/')
}

const toggleTheme = () => {
  // handled globally
}

useSeoMeta({
  title: 'Baseband Emulation with FirmWire Playbook | TelcoChisel',
  description: 'Step-by-step guide for emulating and fuzzing Samsung Shannon and MediaTek cellular basebands using FirmWire on TelcoChisel.'
})
</script>

<style scoped>
.layout-container {
  display: flex;
  min-height: 100vh;
}
.main-content {
  flex: 1;
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}
.breadcrumbs {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  font-family: var(--mono);
  font-size: 0.85rem;
  color: var(--amber-lo);
  margin-bottom: 2rem;
}
.breadcrumb-link {
  color: var(--amber);
  text-decoration: none;
}
.breadcrumb-link:hover {
  text-decoration: underline;
}
.feature-name {
  font-size: 2.2rem;
  font-weight: 700;
  color: var(--amber-hi);
  margin-bottom: 0.5rem;
}
.feature-meta-badges {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
}
.numbered-guide-list {
  list-style: none;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}
.numbered-guide-list li {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
}
.guide-number {
  background: var(--amber-g);
  color: var(--amber-hi);
  font-family: var(--mono);
  font-weight: 700;
  width: 2rem;
  height: 2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  flex-shrink: 0;
}
.guide-text-block {
  flex: 1;
}
</style>
