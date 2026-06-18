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
        :style="copied ? { borderColor: 'var(--cyan)', color: 'var(--cyan)' } : {}"
      >
        {{ copied ? 'Copied!' : 'Copy' }}
      </button>
    </div>
  </div>
</template>
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
