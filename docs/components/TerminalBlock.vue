<template>
  <div class="terminal-block">
    <div v-if="title" class="terminal-header">
      <div class="terminal-dots">
        <span class="terminal-dot red"></span>
        <span class="terminal-dot yellow"></span>
        <span class="terminal-dot green"></span>
      </div>
      <div class="terminal-title">{{ title }}</div>
    </div>
    <div class="terminal-body">
      <pre><code>{{ code }}</code></pre>
      <button
        class="terminal-copy-btn"
        @click="copy"
        :class="{ 'is-copied': copied }"
        aria-label="Copy to clipboard"
      >
        <span class="copy-icon-wrapper">
          <!-- Copy Icon -->
          <svg v-if="!copied" class="icon-copy" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
            <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
          </svg>
          <!-- Check Icon -->
          <svg v-else class="icon-check" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="20 6 9 17 4 12"></polyline>
          </svg>
        </span>
        <span class="copy-text">{{ copied ? 'Copied' : 'Copy' }}</span>
      </button>
    </div>
  </div>
</template>

<style scoped>
.terminal-copy-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  overflow: hidden;
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  background: rgba(255, 255, 255, 0.03);
}

.terminal-copy-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.terminal-copy-btn.is-copied {
  color: var(--cyan);
  border-color: rgba(0, 189, 180, 0.4);
  background: rgba(0, 189, 180, 0.08);
  box-shadow: 0 0 15px rgba(0, 189, 180, 0.15);
}

.copy-icon-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
}

.icon-copy, .icon-check {
  animation: popIn 0.25s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
}

@keyframes popIn {
  0% { transform: scale(0.5); opacity: 0; }
  100% { transform: scale(1); opacity: 1; }
}
</style>
<script setup>
const props = defineProps({
  title: String,
  code: { type: String, required: true }
})
const copied = ref(false)
function copy() {
  navigator.clipboard.writeText(props.code).then(() => {
    copied.value = true
    setTimeout(() => { copied.value = false }, 1500)
  })
}
</script>
