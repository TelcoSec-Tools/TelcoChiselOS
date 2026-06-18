<template>
  <div class="callout" :class="type === 'warning' ? 'callout-warning' : 'callout-info'">
    <svg v-if="type === 'info'" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <circle cx="12" cy="12" r="10"></circle>
      <line x1="12" y1="16" x2="12" y2="12"></line>
      <line x1="12" y1="8" x2="12.01" y2="8"></line>
    </svg>
    <svg v-else-if="type === 'warning'" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
      <line x1="12" y1="9" x2="12" y2="13"></line>
      <line x1="12" y1="17" x2="12.01" y2="17"></line>
    </svg>
    <div>
      <div v-if="title" class="callout-title">{{ title }}</div>
      <div class="callout-content">
        <slot />
      </div>
    </div>
  </div>
</template>
<script setup>
defineProps({
  type: {
    type: String,
    default: 'info',
    validator: (v) => ['info', 'warning'].includes(v)
  },
  title: String
})
</script>
