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
          <span class="breadcrumb-current">5G NR Over-The-Air Fuzzing with 5Ghoul</span>
        </nav>

        <article class="feature-details-page">
          <!-- Page Header -->
          <header class="section-header" data-label="// Operator Playbook :: Cellular Protocol Fuzzing">
            <h1 class="feature-name">5G NR &amp; LTE Over-The-Air Fuzzing with 5Ghoul</h1>
            <div class="feature-meta-badges">
              <span class="tag tag-5g">5G NR</span>
              <span class="tag tag-sdr">USRP / BladeRF</span>
              <span class="tag status-ready">OTA Ready</span>
            </div>
          </header>

          <!-- Technical Overview -->
          <section class="feature-info-section">
            <h2>Overview &amp; Audit Objective</h2>
            <div class="feature-long-desc">
              <p>
                5Ghoul is an automated over-the-air (OTA) fuzzing framework designed to uncover vulnerabilities and zero-day
                exploits in commercial 5G modems, smartphones, IoT modules, and routers. This playbook details how to configure
                RF transceivers (Ettus USRP or Nuand BladeRF), execute 5G NAS/RRC fuzzing campaigns, and detect baseband crashes.
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
                  <strong>Verify SDR Radio Hardware &amp; Latency:</strong>
                  <p>Confirm the transceiver is enumerated and kernel parameters are tuned for low latency:</p>
                  <TerminalBlock title="Terminal — Hardware Verification" code="telcosec doctor&#10;sudo telcosec-profile set lab" />
                </div>
              </li>
              <li>
                <span class="guide-number">2</span>
                <div class="guide-text-block">
                  <strong>Build / Verify 5Ghoul Framework:</strong>
                  <p>Run the first-run installation helper for your specific radio frontend (USRP or BladeRF):</p>
                  <TerminalBlock title="Terminal — 5Ghoul Setup" code="sudo 5ghoul-install --radio USRP" />
                </div>
              </li>
              <li>
                <span class="guide-number">3</span>
                <div class="guide-text-block">
                  <strong>Launch 5G NAS &amp; RRC Mutation Campaign:</strong>
                  <p>Start the Rogue gNB transmitter targeting nearby test UEs in a shielded RF enclosure / Faraday cage:</p>
                  <TerminalBlock title="Terminal — Launch Fuzzer" code="sudo 5ghoul-run --Attack.Name=NAS_5GS_Fuzz --Radio=USRP" />
                </div>
              </li>
              <li>
                <span class="guide-number">4</span>
                <div class="guide-text-block">
                  <strong>Monitor Crash Signals &amp; Re-registration:</strong>
                  <p>Observe the live diagnostic console for UE disconnections, memory faults, and radio link failures (RLF):</p>
                  <TerminalBlock title="Terminal — Monitor Logs" code="tail -f /var/log/5ghoul/fuzzer.log" />
                </div>
              </li>
            </ol>
          </section>

          <!-- Evidence Collection -->
          <section class="feature-info-section">
            <h2>Evidence &amp; Artifact Archiving</h2>
            <p>Archive the fuzzing payload seeds, mutation logs, and capture files:</p>
            <TerminalBlock title="Terminal — Bundle Evidence" code="telcosec bundle-evidence 5ghoul-campaign" />
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
  title: '5G NR Fuzzing with 5Ghoul Playbook | TelcoChisel',
  description: 'Step-by-step guide for over-the-air 5G NR and LTE baseband fuzzing using 5Ghoul on TelcoChisel.'
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
