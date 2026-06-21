<template>
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="isSearchOpen" class="search-modal-overlay" @click="closeSearch">
        <div class="search-modal" @click.stop>
          <div class="search-header">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="search-icon">
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
            <input 
              ref="searchInput" 
              v-model="query" 
              type="text" 
              placeholder="Search tools, features, and drivers..." 
              @keydown.esc="closeSearch"
              @keydown.down.prevent="navigateResults('down')"
              @keydown.up.prevent="navigateResults('up')"
              @keydown.enter.prevent="selectResult(selectedIndex)"
            />
            <button class="close-btn" @click="closeSearch">ESC</button>
          </div>
          
          <div class="search-results">
            <div v-if="query && results.length === 0" class="no-results">
              No results found for "{{ query }}"
            </div>
            
            <ul v-else-if="results.length > 0" class="result-list">
              <li 
                v-for="(result, index) in results" 
                :key="result.item.id"
                :class="{ selected: selectedIndex === index }"
                @mouseover="selectedIndex = index"
                @click="selectResult(index)"
              >
                <div class="result-icon">
                  <svg v-if="result.item.type === 'tool'" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--accent-teal)" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"></path></svg>
                  <svg v-else-if="result.item.type === 'feature'" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--accent-teal)" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                  <svg v-else width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--accent-teal)" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="14.31" y1="8" x2="20.05" y2="17.94"></line></svg>
                </div>
                <div class="result-content">
                  <div class="result-title">{{ result.item.name }}</div>
                  <div class="result-desc">{{ result.item.desc }}</div>
                </div>
                <div class="result-badge">{{ result.item.type }}</div>
              </li>
            </ul>
            
            <div v-else class="search-hint">
              Search for protocol analyzers, SDR drivers, or OS features.
            </div>
          </div>
          
          <div class="search-footer">
            <span class="key-hint"><span>↑</span><span>↓</span> to navigate</span>
            <span class="key-hint"><span>↵</span> to select</span>
            <span class="key-hint"><span>ESC</span> to close</span>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import Fuse from 'fuse.js'
import { useSearch } from '~/composables/useSearch'

import { toolsCatalog } from '~/data/tools.js'
import { featuresCatalog } from '~/data/features.js'
import { driversCatalog } from '~/data/drivers.js'

const { isSearchOpen, closeSearch } = useSearch()
const router = useRouter()
const { gtag } = useGtag()

const query = ref('')
const searchInput = ref(null)
const selectedIndex = ref(0)
const results = ref([])

// Build combined index
const searchData = [
  ...toolsCatalog.map(t => ({ ...t, type: 'tool', id: `tool_${t.slug}`, url: `/tools/${t.slug}` })),
  ...featuresCatalog.map(f => ({ ...f, type: 'feature', id: `feature_${f.slug}`, url: `/features/${f.slug}` })),
  ...driversCatalog.map(d => ({ ...d, type: 'driver', id: `driver_${d.slug}`, url: `/drivers/${d.slug}` }))
]

const fuse = new Fuse(searchData, {
  keys: ['name', 'desc', 'category', 'cmd', 'path'],
  threshold: 0.3,
  includeMatches: true
})

watch(query, (newQuery) => {
  if (newQuery) {
    results.value = fuse.search(newQuery).slice(0, 10)
  } else {
    results.value = []
  }
  selectedIndex.value = 0
})

watch(isSearchOpen, async (isOpen) => {
  if (isOpen) {
    query.value = ''
    results.value = []
    selectedIndex.value = 0
    await nextTick()
    searchInput.value?.focus()
  }
})

const navigateResults = (direction) => {
  if (results.value.length === 0) return
  if (direction === 'down') {
    selectedIndex.value = (selectedIndex.value + 1) % results.value.length
  } else {
    selectedIndex.value = (selectedIndex.value - 1 + results.value.length) % results.value.length
  }
}

const selectResult = (index) => {
  if (results.value[index]) {
    const targetUrl = results.value[index].item.url
    
    // GA4 Search tracking
    if (query.value) {
      gtag('event', 'search', {
        search_term: query.value
      })
    }

    closeSearch()
    router.push(targetUrl)
  }
}

// Global shortcut listener
const handleKeydown = (e) => {
  if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
    e.preventDefault()
    isSearchOpen.value = !isSearchOpen.value
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.15s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.search-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  z-index: 10000;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding-top: 10vh;
}

.search-modal {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  width: 100%;
  max-width: 600px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.search-header {
  display: flex;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color);
  background: var(--bg-body);
}

.search-icon {
  color: var(--text-muted);
  margin-right: 12px;
}

.search-header input {
  flex: 1;
  background: transparent;
  border: none;
  color: var(--text-main);
  font-size: 1.1rem;
  outline: none;
}

.search-header input::placeholder {
  color: var(--text-muted);
}

.close-btn {
  background: var(--bg-hover);
  border: 1px solid var(--border-color);
  color: var(--text-muted);
  font-size: 0.75rem;
  padding: 4px 8px;
  border-radius: 4px;
  cursor: pointer;
  font-family: monospace;
}

.search-results {
  max-height: 400px;
  overflow-y: auto;
  padding: 10px 0;
}

.search-hint, .no-results {
  padding: 30px 20px;
  text-align: center;
  color: var(--text-muted);
}

.result-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.result-list li {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  cursor: pointer;
  border-left: 3px solid transparent;
}

.result-list li.selected {
  background: var(--bg-hover);
  border-left-color: var(--accent-teal);
}

.result-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: rgba(0, 255, 170, 0.1);
  border-radius: 6px;
  margin-right: 16px;
}

.result-content {
  flex: 1;
  overflow: hidden;
}

.result-title {
  font-weight: 600;
  color: var(--text-main);
  margin-bottom: 4px;
}

.result-list li.selected .result-title {
  color: var(--accent-teal);
}

.result-desc {
  font-size: 0.85rem;
  color: var(--text-secondary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.result-badge {
  font-size: 0.7rem;
  text-transform: uppercase;
  background: var(--bg-body);
  border: 1px solid var(--border-color);
  padding: 2px 6px;
  border-radius: 4px;
  color: var(--text-muted);
  margin-left: 12px;
}

.search-footer {
  display: flex;
  align-items: center;
  padding: 10px 20px;
  border-top: 1px solid var(--border-color);
  background: var(--bg-body);
  font-size: 0.75rem;
  color: var(--text-muted);
}

.key-hint {
  display: flex;
  align-items: center;
  margin-right: 16px;
}

.key-hint span {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: 3px;
  padding: 2px 6px;
  margin: 0 4px;
  font-family: monospace;
}
</style>
