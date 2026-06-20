<template>
  <div>
    <BootOverlay />
    <div class="sidebar-overlay" :class="{ active: sidebarOpen }" @click="sidebarOpen = false" id="sidebarOverlay"></div>
    <div class="layout-container">
      <AppSidebar :active-section="'tools'" :open="sidebarOpen" @navigate="navigateHome" @toggle-theme="toggleTheme" />

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
          <NuxtLink to="/#tools" class="breadcrumb-link">Tools Directory</NuxtLink>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">{{ categoryLabel }}</span>
        </nav>

        <section class="content-section active">
          <div class="section-header" :data-label="'// Tools :: ' + categoryLabel">
            <h2>{{ categoryLabel }} Tools</h2>
            <p class="subtitle">All tools categorized under {{ categoryLabel }} in TelcoChiselOS.</p>
          </div>

          <div class="grid-3" v-if="filteredTools.length > 0">
            <NuxtLink v-for="t in filteredTools" :key="t.slug" :to="'/tools/' + t.slug" class="card" :class="tagClass(t.category)">
              <div class="card-title">
                {{ t.name }}
                <span class="tag" :class="tagClass(t.category)">{{ tagLabel(t.category) }}</span>
              </div>
              <p class="card-desc">{{ t.desc }}</p>
            </NuxtLink>
          </div>
          <div v-else class="error-container">
            <h2>No Tools Found</h2>
            <p>No tools found for this category.</p>
          </div>

          <!-- Footer CTA -->
          <div class="back-footer-cta">
            <NuxtLink to="/#tools" class="btn-back-link">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
              </svg>
              Back to Tools Directory
            </NuxtLink>
          </div>
        </section>
      </main>
    </div>
  </div>
</template>

<script setup>
import { toolsCatalog } from '~/data/tools.js'

const route = useRoute()
const categoryId = route.params.id
const sidebarOpen = ref(false)
const { gtag } = useGtag()

const filteredTools = computed(() => toolsCatalog.filter(t => t.category === categoryId))

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

const categoryLabel = computed(() => {
  const f = filters.find(f => f.id === categoryId)
  return f ? f.label : categoryId
})

if (filteredTools.value.length === 0) {
  throw createError({ statusCode: 404, statusMessage: 'Category not found' })
}

useHead({
  title: `${categoryLabel.value} Tools - TelcoChiselOS`,
  meta: [
    { name: 'description', content: `List of telecom security tools for ${categoryLabel.value} in TelcoChiselOS.` }
  ]
})

function navigateHome(section) {
  sidebarOpen.value = false
  navigateTo(`/#${section}`)
}

function toggleTheme() {
  const isLight = document.body.classList.toggle('light-theme')
  localStorage.setItem('theme', isLight ? 'light' : 'dark')
}

onMounted(() => {
  if (localStorage.getItem('theme') === 'light') document.body.classList.add('light-theme')
})

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
</script>

<style scoped>
.breadcrumbs {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 24px;
  font-family: var(--mono);
  font-size: 0.75rem;
}

.breadcrumb-link {
  color: var(--tx-dim);
  text-decoration: none;
  transition: color var(--t);
}

.breadcrumb-link:hover {
  color: var(--amber);
}

.breadcrumb-separator {
  color: var(--tx-faint);
  user-select: none;
}

.breadcrumb-current {
  color: var(--amber);
  font-weight: 500;
}

.back-footer-cta {
  margin-top: 60px;
  padding-top: 30px;
  border-top: 1px solid var(--bdr);
}

.btn-back-link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-family: var(--disp);
  font-size: 0.95rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--amber);
  border: 1px solid var(--amber-lo);
  background: var(--amber-g2);
  padding: 8px 16px;
  border-radius: 2px;
  transition: all var(--t);
}

.btn-back-link:hover {
  color: var(--tx);
  background: var(--amber-g);
  border-color: var(--amber);
  transform: translateX(-3px);
  box-shadow: 0 4px 20px var(--amber-g2);
}

.btn-back-link svg {
  transition: transform var(--t);
}

.btn-back-link:hover svg {
  transform: translateX(-3px);
}

.error-container {
  text-align: center;
  padding: 80px 20px;
}

.error-container h2 {
  margin-bottom: 12px;
  border: none;
}

.content-section {
  display: block !important;
}
</style>
