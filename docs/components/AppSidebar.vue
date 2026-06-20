<template>
  <aside class="sidebar" :class="{ open: open }">
    <div class="brand">
      <div class="brand-logo">T</div>
      <div class="brand-text">Telco<span>Chisel</span></div>
    </div>

    <div class="sidebar-status">
      <span class="status-dot"></span>
      <span class="sidebar-status-text">System Active</span>
    </div>

    <nav>
      <div class="nav-section-title">Getting Started</div>
      <ul class="nav-menu">
        <li>
          <a class="nav-link" :class="{ active: activeSection === 'overview' }" href="#overview" @click.prevent="emit('navigate', 'overview')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="3" width="7" height="9"></rect>
              <rect x="14" y="3" width="7" height="5"></rect>
              <rect x="14" y="12" width="7" height="9"></rect>
              <rect x="3" y="16" width="7" height="5"></rect>
            </svg>
            Overview
          </a>
        </li>
        <li>
          <a class="nav-link" :class="{ active: activeSection === 'features' }" href="#features" @click.prevent="emit('navigate', 'features')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
              <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
            </svg>
            OS Optimizations
          </a>
        </li>
        <li>
          <a class="nav-link" :class="{ active: activeSection === 'installation' }" href="#installation" @click.prevent="emit('navigate', 'installation')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
              <polyline points="7 10 12 15 17 10"></polyline>
              <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
            Installation
          </a>
        </li>
      </ul>

      <div class="nav-section-title">Reference</div>
      <ul class="nav-menu">
        <li>
          <a class="nav-link" :class="{ active: activeSection === 'tools' }" href="#tools" @click.prevent="emit('navigate', 'tools')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
              <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
              <line x1="12" y1="22.08" x2="12" y2="12"></line>
            </svg>
            Tools Directory
          </a>
        </li>
        <li>
          <a class="nav-link" :class="{ active: activeSection === 'drivers' }" href="#drivers" @click.prevent="emit('navigate', 'drivers')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="10"></circle>
              <line x1="14.31" y1="8" x2="20.05" y2="17.94"></line>
              <line x1="9.69" y1="8" x2="21.17" y2="8"></line>
              <line x1="7.38" y1="12" x2="13.12" y2="2.06"></line>
              <line x1="9.69" y1="16" x2="3.95" y2="6.06"></line>
              <line x1="14.31" y1="16" x2="2.83" y2="16"></line>
              <line x1="16.62" y1="12" x2="10.88" y2="21.94"></line>
            </svg>
            Drivers &amp; Hardware
          </a>
        </li>
        <li>
          <a class="nav-link" :class="{ active: activeSection === 'projects' }" href="#projects" @click.prevent="emit('navigate', 'projects')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
              <circle cx="12" cy="13" r="4"></circle>
            </svg>
            TelcoSec Projects
          </a>
        </li>
        <li>
          <a class="nav-link" :class="{ active: activeSection === 'legal' }" href="#legal" @click.prevent="emit('navigate', 'legal')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="10"></circle>
              <line x1="12" y1="8" x2="12" y2="12"></line>
              <line x1="12" y1="16" x2="12.01" y2="16"></line>
            </svg>
            Legal Disclaimer
          </a>
        </li>
      </ul>

      <div class="nav-section-title">Specialized Guides</div>
      <ul class="nav-menu">
        <li>
          <a class="nav-link" :class="{ active: activeSection === 'fuzzer' }" href="#fuzzer" @click.prevent="emit('navigate', 'fuzzer')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
            </svg>
            5Ghoul Fuzzing
          </a>
        </li>
        <li>
          <a class="nav-link" :class="{ active: activeSection === 'builder' }" href="#builder" @click.prevent="emit('navigate', 'builder')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"></path>
            </svg>
            ISO Builder
          </a>
        </li>
        <li>
          <a class="nav-link" :class="{ active: activeSection === 'virtualization' }" href="#virtualization" @click.prevent="emit('navigate', 'virtualization')">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect>
              <line x1="8" y1="21" x2="16" y2="21"></line>
              <line x1="12" y1="17" x2="12" y2="21"></line>
            </svg>
            Virtualization
          </a>
        </li>
      </ul>
    </nav>

    <!-- Theme Toggle -->
    <div class="theme-switch-container">
      <span class="theme-switch-label">Light Theme</span>
      <button class="theme-toggle-btn" aria-label="Toggle Theme" @click="emit('toggleTheme')">
        <span class="theme-toggle-slider"></span>
      </button>
    </div>

    <div class="nav-footer">
      <p>TelcoChisel v1.1.0</p>
      <a href="https://github.com/TelcoSec-Tools/TelcoChiselOS" target="_blank">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"></path>
        </svg>
        GitHub Repository
      </a>
      <a href="https://sourceforge.net/projects/telcochisel/" target="_blank">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
        </svg>
        SourceForge
      </a>
    </div>
  </aside>
</template>
<script setup>
defineProps({
  activeSection: String,
  open: Boolean
})
const emit = defineEmits(['navigate', 'toggleTheme'])
</script>
