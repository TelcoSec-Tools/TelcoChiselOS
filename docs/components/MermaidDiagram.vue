<template>
  <div class="mermaid-container">
    <div ref="mermaidEl" class="mermaid-render">
      {{ chart }}
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import mermaid from 'mermaid'

const props = defineProps({
  chart: {
    type: String,
    required: true
  }
})

const mermaidEl = ref(null)

onMounted(() => {
  mermaid.initialize({
    startOnLoad: false,
    theme: 'base',
    themeVariables: {
      primaryColor: '#161b22',
      primaryTextColor: '#c9d1d9',
      primaryBorderColor: '#30363d',
      lineColor: '#00ffaa',
      secondaryColor: '#0d1117',
      tertiaryColor: '#21262d',
      fontFamily: 'IBM Plex Mono, monospace'
    },
    flowchart: {
      htmlLabels: true,
      curve: 'basis'
    }
  })
  renderChart()
})

watch(() => props.chart, () => {
  renderChart()
})

const renderChart = async () => {
  if (mermaidEl.value) {
    try {
      // Clear previous
      mermaidEl.value.removeAttribute('data-processed')
      mermaidEl.value.innerHTML = props.chart
      // Run mermaid render
      await mermaid.run({
        nodes: [mermaidEl.value]
      })
    } catch (e) {
      console.error('Mermaid rendering failed', e)
    }
  }
}
</script>

<style scoped>
.mermaid-container {
  width: 100%;
  overflow-x: auto;
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 20px;
  margin: 20px 0;
  display: flex;
  justify-content: center;
}
.mermaid-render {
  font-family: 'IBM Plex Mono', monospace;
}
</style>
