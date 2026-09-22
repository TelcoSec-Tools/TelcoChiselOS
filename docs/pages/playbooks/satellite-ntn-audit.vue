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
          <span class="breadcrumb-current">Satellite NTN &amp; Doppler DSP Audit</span>
        </nav>

        <article class="feature-details-page">
          <!-- Page Header -->
          <header class="section-header" data-label="// Operator Playbook :: Satellite Telecom & NTN">
            <h1 class="feature-name">3GPP Rel-17 NTN &amp; Satellite Telecommunications Audit</h1>
            <div class="feature-meta-badges">
              <span class="tag tag-sdr">NTN / SATCOM</span>
              <span class="tag tag-5g">3GPP Rel-17</span>
              <span class="tag status-ready">SDR Ready</span>
            </div>
          </header>

          <!-- Technical Overview -->
          <section class="feature-info-section">
            <h2>Overview &amp; Audit Objective</h2>
            <div class="feature-long-desc">
              <p>
                3GPP Release 17 introduces Non-Terrestrial Networks (NTN) to integrate satellite constellations (LEO, MEO, GEO)
                directly with 5G NR User Equipment and IoT devices. This playbook guides operators through tracking LEO satellite orbits,
                calculating dynamic Doppler frequency offsets, capturing L-band/S-band satellite bursts (Iridium / Inmarsat / 5G NTN), and decoding telemetry with <code>gr-satellites</code>.
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
                  <strong>Inspect Satellite Tooling &amp; Constellations:</strong>
                  <p>Display available satellite demodulators, center frequencies, and orbit profiles:</p>
                  <TerminalBlock title="Terminal — NTN Status Check" code="telcosec ntn status" />
                </div>
              </li>
              <li>
                <span class="guide-number">2</span>
                <div class="guide-text-block">
                  <strong>Calculate LEO Orbital Doppler Shift:</strong>
                  <p>Compute carrier frequency shifts and receiver search bands for satellite passes:</p>
                  <TerminalBlock title="Terminal — Calculate Doppler" code="telcosec ntn doppler leo" />
                </div>
              </li>
              <li>
                <span class="guide-number">3</span>
                <div class="guide-text-block">
                  <strong>Receive &amp; Demodulate Satellite Signals with SDR:</strong>
                  <p>Capture L-band satellite downlink signals using SDR hardware (USRP / HackRF / LimeSDR) and gr-satellites:</p>
                  <TerminalBlock title="Terminal — Demodulate with gr-satellites" code="conda activate telcosec-sdr&#10;gr_satellites --hexfmt --demod BPSK --rate 250000 /tmp/satellite_iq.raw" />
                </div>
              </li>
              <li>
                <span class="guide-number">4</span>
                <div class="guide-text-block">
                  <strong>Parse Satellite Packets &amp; SBD Telemetry:</strong>
                  <p>Extract burst data packets and parse mobile messaging streams using the Iridium Toolkit:</p>
                  <TerminalBlock title="Terminal — Parse Satellite Bursts" code="sudo ntn-sat-install&#10;iridium-parser -i /tmp/satellite_bursts.bits -o /tmp/iridium-frames.pcap" />
                </div>
              </li>
            </ol>
          </section>

          <!-- Evidence Collection -->
          <section class="feature-info-section">
            <h2>Evidence &amp; Artifact Archiving</h2>
            <p>Archive satellite IQ captures and parsed frame PCAPs into a timestamped evidence archive:</p>
            <TerminalBlock title="Terminal — Bundle Evidence" code="telcosec bundle-evidence satellite-ntn-audit" />
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
  title: '3GPP Rel-17 NTN & Satellite Telecom Playbook | TelcoChisel',
  description: 'Operator guide for auditing 3GPP Non-Terrestrial Networks (NTN), LEO satellite Doppler tracking, and SATCOM demodulation.'
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
