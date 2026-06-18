<template>
  <div id="bootOverlay" aria-hidden="true"><div class="boot-scan"></div></div>
</template>
<script setup>
onMounted(() => {
  setTimeout(() => {
    const el = document.getElementById('bootOverlay')
    if (el) {
      el.classList.add('done')
      el.addEventListener('animationend', () => el.remove(), { once: true })
    }
  }, 920)
})
</script>
