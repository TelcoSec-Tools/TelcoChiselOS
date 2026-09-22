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
          <span class="breadcrumb-current">eSIM RSP &amp; LPA Profile Security Audit</span>
        </nav>

        <article class="feature-details-page">
          <!-- Page Header -->
          <header class="section-header" data-label="// Operator Playbook :: eSIM & Smartcards">
            <h1 class="feature-name">eSIM Remote Provisioning (RSP) &amp; LPA Security Audit</h1>
            <div class="feature-meta-badges">
              <span class="tag tag-sim">SIM &amp; eSIM</span>
              <span class="tag status-ready">PCSC Ready</span>
            </div>
          </header>

          <!-- Technical Overview -->
          <section class="feature-info-section">
            <h2>Overview &amp; Audit Objective</h2>
            <div class="feature-long-desc">
              <p>
                eSIM and eUICC architectures rely on the GSMA SGP.22 Remote SIM Provisioning specification.
                This playbook demonstrates how to audit eSIM profiles, interrogate eUICC chips via standard PCSC readers using
                <code>lpac</code> and <code>pySim-shell</code>, verify CI Public Key certificates, and monitor APDU commands.
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
                  <strong>Detect Connected Smartcard Readers:</strong>
                  <p>Enumerate USB PCSC readers and verify card presence:</p>
                  <TerminalBlock title="Terminal — Enumerate Readers" code="telcosec sim readers&#10;telcosec doctor" />
                </div>
              </li>
              <li>
                <span class="guide-number">2</span>
                <div class="guide-text-block">
                  <strong>Inspect eUICC Information (EID &amp; Profiles):</strong>
                  <p>Query the chip Identification Data (EID) and list installed operational profile packages:</p>
                  <TerminalBlock title="Terminal — LPA Profile List" code="lpac chip info&#10;lpac profile list" />
                </div>
              </li>
              <li>
                <span class="guide-number">3</span>
                <div class="guide-text-block">
                  <strong>Sniff ISO 7816 APDU Transactions:</strong>
                  <p>Capture real-time ATR and APDU exchanges between the host and smartcard using SIMtrace 2:</p>
                  <TerminalBlock title="Terminal — APDU Sniffer" code="sudo telcosec sim trace sniff -o /tmp/esim-apdu-trace.pcap" />
                </div>
              </li>
              <li>
                <span class="guide-number">4</span>
                <div class="guide-text-block">
                  <strong>Interactive SIM File System Analysis:</strong>
                  <p>Explore 3GPP USIM/ISIM elementary files (EF.IMSI, EF.AD, EF.UST) in pySim-shell:</p>
                  <TerminalBlock title="Terminal — Launch pySim-shell" code="telcosec sim shell -p 0" />
                </div>
              </li>
            </ol>
          </section>

          <!-- Evidence Collection -->
          <section class="feature-info-section">
            <h2>Evidence &amp; Artifact Archiving</h2>
            <p>Bundle the resulting APDU PCAP traces and pySim output for your audit deliverables:</p>
            <TerminalBlock title="Terminal — Bundle Evidence" code="telcosec bundle-evidence esim-audit" />
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
  title: 'eSIM RSP & LPA Security Audit Playbook | TelcoChisel',
  description: 'Operator guide for auditing GSMA Remote SIM Provisioning, eUICC chips, and ISO 7816 APDUs with lpac and pySim.'
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
