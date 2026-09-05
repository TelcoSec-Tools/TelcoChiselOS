<template>
  <!-- SIDEBAR VARIANT -->
  <div v-if="variant === 'sidebar'" class="academy-sidebar-card">
    <div class="sidebar-badge">
      <span class="live-dot"></span>
      <span>ONLINE LABS</span>
    </div>
    <h4 class="sidebar-title">TelcoSec Academy</h4>
    <p class="sidebar-desc">Practice 5G SA Core hacking &amp; RF security in live browser sandboxes.</p>
    <a :href="targetUrl" target="_blank" class="sidebar-btn" @click="handleClick">
      Launch Labs
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="5" y1="12" x2="19" y2="12"></line>
        <polyline points="12 5 19 12 12 19"></polyline>
      </svg>
    </a>
  </div>

  <!-- SCENARIO LAB BRIDGE VARIANT -->
  <div v-else-if="variant === 'scenario'" class="academy-scenario-card">
    <div class="scenario-lab-header">
      <div class="scenario-lab-badge">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polygon points="12 2 2 7 12 12 22 7 12 2"></polygon>
          <polyline points="2 17 12 22 22 17"></polyline>
          <polyline points="2 12 12 17 22 12"></polyline>
        </svg>
        <span>INTERACTIVE LAB TESTBED AVAILABLE</span>
      </div>
      <span class="lab-env-tag">Pre-Configured Sandbox</span>
    </div>
    <div class="scenario-lab-body">
      <div>
        <h4 class="scenario-lab-title">{{ labName || effectiveTitle }}</h4>
        <p class="scenario-lab-desc">
          Skip hardware setup and deploy this exact assessment scenario inside an isolated, containerized 5G/LTE testbed on the TelcoSec Academy platform.
        </p>
      </div>
      <a :href="targetUrl" target="_blank" class="scenario-lab-btn" @click="handleClick">
        <span>Start Lab Testbed</span>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <line x1="5" y1="12" x2="19" y2="12"></line>
          <polyline points="12 5 19 12 12 19"></polyline>
        </svg>
      </a>
    </div>
  </div>

  <!-- CONTEXTUAL IN-PAGE CARD VARIANT (Tool / Feature / Driver pages) -->
  <div v-else class="academy-contextual-card">
    <div class="contextual-content">
      <div class="contextual-badge">
        <span class="live-dot"></span>
        <span>{{ effectiveBadge }}</span>
      </div>
      <h3 class="contextual-title">{{ effectiveTitle }}</h3>
      <p class="contextual-desc">{{ effectiveDesc }}</p>
      <div class="contextual-perks">
        <span class="perk-item">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
          Interactive Cloud Labs
        </span>
        <span class="perk-item">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
          No Hardware Required
        </span>
        <span class="perk-item">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
          CTSP Certification
        </span>
      </div>
    </div>
    <div class="contextual-action">
      <a :href="targetUrl" target="_blank" class="contextual-btn" @click="handleClick">
        <span>{{ ctaText }}</span>
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <line x1="5" y1="12" x2="19" y2="12"></line>
          <polyline points="12 5 19 12 12 19"></polyline>
        </svg>
      </a>
      <span class="contextual-meta">app.telcosec.net &middot; Instant access</span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'contextual',
    validator: (v) => ['sidebar', 'contextual', 'scenario', 'banner'].includes(v)
  },
  category: {
    type: String,
    default: 'general'
  },
  title: String,
  desc: String,
  badge: String,
  labName: String,
  ctaText: {
    type: String,
    default: 'Launch Live Sandbox'
  },
  campaign: {
    type: String,
    default: 'academy_funnel'
  }
})

const { gtag } = useGtag()

const categoryDefaults = {
  '5g': {
    badge: '5G SA CORE SANDBOX',
    title: 'Master 5G SA Core & Protocol Security',
    desc: 'Practice 5G Standalone authentication, NAS protocol fuzzing, and UPF data-plane bypass attacks inside isolated, containerized 5G core environments.'
  },
  '4g': {
    badge: 'LTE / 4G LAB',
    title: 'Cellular Radio & Core Security Labs',
    desc: 'Simulate rogue eNodeB reselection, audit S1AP/Diameter signaling, and evaluate mobile handset downgrade resistance in controlled testbeds.'
  },
  'sdr': {
    badge: 'VIRTUAL RF LAB',
    title: 'SDR Digital Signal Processing & OTA Labs',
    desc: 'Learn software-defined radio analysis without physical hardware. Stream RF sample traces, decode SIB broadcasts, and audit cellular PHY layers.'
  },
  '2g': {
    badge: 'GSM / 2G SECURITY',
    title: 'Legacy Cellular Security & Downgrade Audits',
    desc: 'Audit A5/1 and A5/0 cipher negotiation, evaluate IMSI catcher detection, and analyze GSM air interface signaling.'
  },
  'sim': {
    badge: 'SMARTCARD & ESIM LAB',
    title: 'SIM, USIM & eSIM Profile Auditing',
    desc: 'Inspect UICC file systems over ISO-7816, test Milenage authentication vectors, and explore GSMA RSP eSIM remote provisioning security.'
  },
  'baseband': {
    badge: 'BASEBAND REVERSING',
    title: 'Baseband Firmware Emulation & Fuzzing',
    desc: 'Emulate Samsung Shannon and MediaTek baseband RTOS tasks in FirmWire, and capture low-level modem telemetry over Qualcomm DIAG ports.'
  },
  'voip': {
    badge: 'CARRIER VOIP LAB',
    title: 'VoIP Trunking & SIP Security Assessments',
    desc: 'Audit carrier SIP trunks, test PBX authentication resilience, and execute high-concurrency SIP signaling stress tests.'
  },
  'core': {
    badge: 'SIGNALING CORE LAB',
    title: 'Telecom Core Signaling (SS7 / Diameter / GTP)',
    desc: 'Conduct structured signaling audits across Diameter S6a, GTP-C/U interfaces, and legacy SS7/SIGTRAN transport stacks.'
  },
  'wireline': {
    badge: 'FIXED BROADBAND LAB',
    title: 'Wireline Access & Carrier Network Auditing',
    desc: 'Audit ISP PPPoE MS-CHAPv2 handshakes, test TR-069 ACS remote management security, and inspect 802.1Q VLAN carrier configurations.'
  },
  'general': {
    badge: 'HANDS-ON TELECOM LABS',
    title: 'TelcoSec Academy Certification Program',
    desc: 'Accelerate your telecom security career. Access interactive sandboxes, practice real cellular network attacks, and earn the CTSP certification.'
  }
}

const config = computed(() => {
  return categoryDefaults[props.category] || categoryDefaults['general']
})

const effectiveBadge = computed(() => props.badge || config.value.badge)
const effectiveTitle = computed(() => props.title || config.value.title)
const effectiveDesc = computed(() => props.desc || config.value.desc)

const targetUrl = computed(() => {
  const base = 'https://app.telcosec.net/'
  const params = new URLSearchParams()
  params.set('utm_source', 'telcochisel_docs')
  params.set('utm_medium', props.variant)
  params.set('utm_campaign', props.campaign)
  if (props.category && props.category !== 'general') {
    params.set('utm_content', props.category)
  }
  return `${base}?${params.toString()}`
})

function handleClick() {
  gtag('event', 'outbound_academy', {
    event_category: 'outbound',
    event_label: `Academy_${props.variant}_${props.category}`,
    variant: props.variant,
    category: props.category,
    destination: targetUrl.value
  })
}
</script>

<style scoped>
/* ─── Sidebar Variant ─────────────────────────────────────────────────── */
.academy-sidebar-card {
  margin: 16px 12px 14px 12px;
  padding: 14px 14px;
  background: linear-gradient(145deg, #0e1220 0%, #0a0d18 100%);
  border: 1px solid var(--bdr-mid);
  border-left: 3px solid var(--amber);
  border-radius: 2px;
  transition: all var(--t);
  position: relative;
  overflow: hidden;
}

.academy-sidebar-card:hover {
  border-left-color: var(--amber-hi);
  box-shadow: 0 0 16px var(--amber-g);
  transform: translateY(-1px);
}

.sidebar-badge {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  font-family: var(--mono);
  font-size: 0.6rem;
  font-weight: 700;
  letter-spacing: 0.12em;
  color: var(--amber);
  margin-bottom: 6px;
}

.live-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--amber);
  box-shadow: 0 0 8px var(--amber);
  animation: pulse-dot 2s infinite ease-in-out;
}

@keyframes pulse-dot {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.4; transform: scale(0.8); }
}

.sidebar-title {
  font-family: var(--disp);
  font-size: 0.95rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: #fff;
  margin: 0 0 4px 0;
}

.sidebar-desc {
  font-size: 0.72rem;
  color: var(--tx-dim);
  line-height: 1.4;
  margin: 0 0 10px 0;
}

.sidebar-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  width: 100%;
  background: transparent;
  border: 1px solid var(--amber);
  color: var(--amber);
  font-family: var(--mono);
  font-size: 0.7rem;
  font-weight: 600;
  padding: 6px 10px;
  border-radius: 1px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  text-decoration: none;
  transition: all var(--t);
}

.sidebar-btn:hover {
  background: var(--amber);
  color: #040507;
  box-shadow: 0 0 12px var(--amber-g);
}

/* ─── Scenario Lab Bridge Variant ─────────────────────────────────────── */
.academy-scenario-card {
  background: linear-gradient(135deg, rgba(232, 146, 30, 0.05) 0%, rgba(10, 15, 30, 0.85) 100%);
  border: 1px solid var(--amber-lo);
  border-left: 3px solid var(--amber);
  border-radius: 2px;
  padding: 16px 20px;
  margin: 18px 0;
}

.scenario-lab-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.scenario-lab-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: var(--amber);
  font-family: var(--mono);
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.1em;
}

.lab-env-tag {
  font-family: var(--mono);
  font-size: 0.65rem;
  color: var(--tx-dim);
  background: rgba(0, 0, 0, 0.3);
  padding: 2px 8px;
  border-radius: 1px;
  border: 1px solid var(--bdr);
}

.scenario-lab-body {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}

@media (max-width: 768px) {
  .scenario-lab-body {
    flex-direction: column;
    align-items: flex-start;
  }
  .scenario-lab-btn {
    width: 100%;
    justify-content: center;
  }
}

.scenario-lab-title {
  font-family: var(--disp);
  font-size: 1.05rem;
  font-weight: 700;
  text-transform: uppercase;
  color: #fff;
  margin: 0 0 4px 0;
}

.scenario-lab-desc {
  font-size: 0.82rem;
  color: var(--tx-dim);
  line-height: 1.5;
  margin: 0;
}

.scenario-lab-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
  background: var(--amber-g2);
  border: 1px solid var(--amber);
  color: var(--amber);
  font-family: var(--mono);
  font-size: 0.78rem;
  font-weight: 600;
  padding: 9px 18px;
  border-radius: 1px;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  text-decoration: none;
  transition: all var(--t);
  flex-shrink: 0;
}

.scenario-lab-btn:hover {
  background: var(--amber);
  color: #040507;
  box-shadow: 0 0 20px var(--amber-g);
}

/* ─── Contextual Variant (Tools, Features, Drivers) ───────────────────── */
.academy-contextual-card {
  background: linear-gradient(135deg, #0a0d18 0%, #070912 100%);
  border: 1px solid var(--bdr-mid);
  border-left: 3px solid var(--amber);
  border-radius: 2px;
  padding: 24px 26px;
  margin: 32px 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 28px;
  position: relative;
  overflow: hidden;
  transition: border-left-color var(--t), box-shadow var(--t), transform var(--t);
}

@media (max-width: 860px) {
  .academy-contextual-card {
    flex-direction: column;
    align-items: flex-start;
  }
  .contextual-action {
    width: 100%;
    align-items: stretch !important;
  }
}

.academy-contextual-card:hover {
  border-left-color: var(--amber-hi);
  box-shadow: 0 0 24px var(--amber-g);
  transform: translateY(-1px);
}

.contextual-content {
  flex: 1;
}

.contextual-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: var(--amber-g2);
  border: 1px solid var(--amber-lo);
  color: var(--amber);
  font-family: var(--mono);
  font-size: 0.64rem;
  font-weight: 700;
  padding: 3px 8px;
  border-radius: 1px;
  margin-bottom: 10px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.contextual-title {
  font-family: var(--disp);
  font-size: 1.25rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  color: #fff;
  margin: 0 0 8px 0;
}

.contextual-desc {
  font-size: 0.85rem;
  color: var(--tx-dim);
  line-height: 1.6;
  margin: 0 0 14px 0;
}

.contextual-perks {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
}

.perk-item {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-family: var(--mono);
  font-size: 0.72rem;
  color: var(--tx);
}

.perk-item svg {
  color: var(--green);
}

.contextual-action {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.contextual-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: var(--amber);
  color: #040507;
  font-family: var(--mono);
  font-size: 0.82rem;
  font-weight: 600;
  padding: 12px 22px;
  border-radius: 1px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  text-decoration: none;
  transition: all var(--t);
  white-space: nowrap;
}

.contextual-btn:hover {
  background: var(--amber-hi);
  box-shadow: 0 0 24px var(--amber-g);
  transform: translateX(2px);
}

.contextual-meta {
  font-family: var(--mono);
  font-size: 0.65rem;
  color: var(--tx-dim);
}
</style>
