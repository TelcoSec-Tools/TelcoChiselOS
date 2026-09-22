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
          <span class="breadcrumb-current">O-RAN E2 &amp; O1 Interface Security Audit</span>
        </nav>

        <article class="feature-details-page">
          <!-- Page Header -->
          <header class="section-header" data-label="// Operator Playbook :: Open RAN Security">
            <h1 class="feature-name">O-RAN E2 Node &amp; O1 Management Interface Audit</h1>
            <div class="feature-meta-badges">
              <span class="tag tag-5g">O-RAN</span>
              <span class="tag tag-core">Near-RT RIC</span>
              <span class="tag status-ready">Lab Ready</span>
            </div>
          </header>

          <!-- Technical Overview -->
          <section class="feature-info-section">
            <h2>Overview &amp; Audit Objective</h2>
            <div class="feature-long-desc">
              <p>
                The O-RAN Alliance specifies open, disaggregated interfaces across the Radio Access Network.
                This playbook demonstrates how to audit O-RAN architectures by simulating E2 Nodes (E2-DU / E2-CU),
                testing E2AP v2/v3 SCTP connections to Near-RT RICs, auditing E2SM-KPM telemetry streams, and scanning O1 NETCONF/YANG servers.
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
                  <strong>Inspect O-RAN Subsystem Status:</strong>
                  <p>Verify that O-RAN emulation tools and SCTP network sockets are operational:</p>
                  <TerminalBlock title="Terminal — O-RAN Status Check" code="telcosec oran status" />
                </div>
              </li>
              <li>
                <span class="guide-number">2</span>
                <div class="guide-text-block">
                  <strong>Scan O1 NETCONF Management Interface:</strong>
                  <p>Audit target O1 management nodes for open ports, TLS certificate strength, and YANG model exposures:</p>
                  <TerminalBlock title="Terminal — O1 NETCONF Audit" code="telcosec oran o1-scan 192.168.1.50" />
                </div>
              </li>
              <li>
                <span class="guide-number">3</span>
                <div class="guide-text-block">
                  <strong>Launch E2 Node Simulation &amp; xApp Telemetry:</strong>
                  <p>Emulate an E2 Node streaming E2SM-KPM metrics to the Near-RT RIC:</p>
                  <TerminalBlock title="Terminal — E2 Node Simulator" code="sudo oran-e2sim-install&#10;telcosec oran e2-sim 127.0.0.1" />
                </div>
              </li>
              <li>
                <span class="guide-number">4</span>
                <div class="guide-text-block">
                  <strong>Capture E2AP SCTP Packets in Wireshark:</strong>
                  <p>Decode O-RAN E2 Application Protocol packets (PPID 70 over SCTP port 36421):</p>
                  <TerminalBlock title="Terminal — Wireshark E2AP Capture" code="wireshark -k -i any -f &quot;sctp port 36421&quot; &amp;" />
                </div>
              </li>
            </ol>
          </section>

          <!-- Evidence Collection -->
          <section class="feature-info-section">
            <h2>Evidence &amp; Artifact Archiving</h2>
            <p>Export all E2AP PCAP traces and O1 scan logs into a signed audit bundle:</p>
            <TerminalBlock title="Terminal — Bundle Evidence" code="telcosec bundle-evidence oran-audit" />
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
  title: 'O-RAN E2 & O1 Security Audit Playbook | TelcoChisel',
  description: 'Operator guide for auditing Open RAN E2AP protocol connections, Near-RT RIC xApps, and O1 NETCONF interfaces on TelcoChisel.'
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
