<template>
  <canvas ref="canvasEl" id="spectrumCanvas" aria-hidden="true"></canvas>
</template>
<script setup>
const canvasEl = ref(null)

onMounted(() => {
  const canvas = canvasEl.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  const COUNT = 42
  const BAR_W = 3
  const GAP = 2
  const TOTAL_W = COUNT * (BAR_W + GAP)

  canvas.width = TOTAL_W

  function resize() {
    const h = canvas.parentElement ? canvas.parentElement.offsetHeight : 140
    canvas.height = Math.max(h, 80)
  }
  resize()
  window.addEventListener('resize', resize)

  const bars = Array.from({ length: COUNT }, () => ({
    h: Math.random() * 0.55 + 0.08,
    target: Math.random() * 0.55 + 0.08,
    speed: Math.random() * 0.035 + 0.012,
    jitter: Math.random() * 0.18 + 0.04
  }))

  function draw() {
    const H = canvas.height
    ctx.clearRect(0, 0, canvas.width, H)

    bars.forEach((bar, i) => {
      bar.h += (bar.target - bar.h) * bar.speed

      if (Math.random() < 0.018) {
        bar.target = Math.random() * 0.78 + 0.05
        bar.speed = Math.random() * 0.04 + 0.01
      }

      const jitter = (Math.random() - 0.5) * bar.jitter
      const barH = Math.max(3, (bar.h + jitter) * H)
      const x = i * (BAR_W + GAP)
      const y = H - barH

      const grad = ctx.createLinearGradient(0, H, 0, y)
      grad.addColorStop(0, 'rgba(232, 146, 30, 0.95)')
      grad.addColorStop(0.55, 'rgba(245, 170, 53, 0.72)')
      grad.addColorStop(1, 'rgba(255, 210, 100, 0.35)')

      ctx.fillStyle = grad
      ctx.fillRect(x, y, BAR_W, barH)

      // Peak pixel
      ctx.fillStyle = 'rgba(255, 230, 160, 0.88)'
      ctx.fillRect(x, y, BAR_W, 1)
    })

    requestAnimationFrame(draw)
  }

  draw()
})
</script>
