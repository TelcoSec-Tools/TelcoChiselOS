<template>
  <div>
    <BootOverlay />
    <div class="sidebar-overlay" :class="{ active: sidebarOpen }" @click="sidebarOpen = false" id="sidebarOverlay"></div>
    <div class="layout-container">
      <AppSidebar :active-section="'playbooks'" :open="sidebarOpen" @navigate="navigateHome" @toggle-theme="toggleTheme" />

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
          <span class="breadcrumb-current">Playbooks</span>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">Virtual Machine Appliances</span>
        </nav>

        <article class="feature-details-page">
          <!-- Page Header -->
          <header class="section-header" data-label="// Deployment Guide :: Hypervisors">
            <h1 class="feature-name">Virtual Machine Appliance Deployment Guide</h1>
            <p class="feature-subtitle">Turn-key deployment, guest agent configuration, and SDR hardware passthrough for Proxmox VE, VMware, and VirtualBox.</p>
            <div class="feature-meta-badges">
              <span class="tag tag-core">Proxmox QCOW2</span>
              <span class="tag tag-5g">VMware OVA</span>
              <span class="tag tag-sdr">VirtualBox OVA</span>
              <span class="tag status-ready">Production Ready</span>
            </div>
          </header>

          <!-- Technical Overview -->
          <section class="feature-info-section">
            <h2>Appliance Architecture &amp; Hypervisor Matrix</h2>
            <div class="feature-long-desc">
              <p>
                TelcoChisel OS provides pre-built virtual appliances tailored for laboratory testbeds and enterprise virtualization stacks.
                Each image is tuned with appropriate guest agent integration, VirtIO drivers, and optimal default resource allocations for telecom security workloads.
              </p>
            </div>

            <div class="table-container" style="overflow-x: auto; margin: 1.5rem 0;">
              <table style="width: 100%; border-collapse: collapse; font-family: var(--font-sans); font-size: 0.9rem;">
                <thead>
                  <tr style="border-bottom: 2px solid var(--bdr-mid); text-align: left;">
                    <th style="padding: 10px; color: var(--cyan-primary);">Hypervisor</th>
                    <th style="padding: 10px; color: var(--cyan-primary);">Package Format</th>
                    <th style="padding: 10px; color: var(--cyan-primary);">Default Resources</th>
                    <th style="padding: 10px; color: var(--cyan-primary);">Guest Integration</th>
                    <th style="padding: 10px; color: var(--cyan-primary);">SDR USB Passthrough</th>
                  </tr>
                </thead>
                <tbody>
                  <tr style="border-bottom: 1px solid var(--bdr);">
                    <td style="padding: 10px; font-weight: 600;">Proxmox VE / KVM</td>
                    <td style="padding: 10px; font-family: var(--mono); color: var(--amber);">.qcow2 (Thin 40GB)</td>
                    <td style="padding: 10px;">8 GB RAM / 4 vCPUs</td>
                    <td style="padding: 10px;">qemu-guest-agent</td>
                    <td style="padding: 10px;">QEMU USB 3.0 (xHCI)</td>
                  </tr>
                  <tr style="border-bottom: 1px solid var(--bdr);">
                    <td style="padding: 10px; font-weight: 600;">VMware Workstation / ESXi</td>
                    <td style="padding: 10px; font-family: var(--mono); color: var(--amber);">.ova (OVF 1.0)</td>
                    <td style="padding: 10px;">8 GB RAM / 4 vCPUs</td>
                    <td style="padding: 10px;">open-vm-tools-desktop</td>
                    <td style="padding: 10px;">VMware USB 3.1 (xHCI)</td>
                  </tr>
                  <tr style="border-bottom: 1px solid var(--bdr);">
                    <td style="padding: 10px; font-weight: 600;">Oracle VirtualBox</td>
                    <td style="padding: 10px; font-family: var(--mono); color: var(--amber);">.ova (OVF 2.0)</td>
                    <td style="padding: 10px;">8 GB RAM / 4 vCPUs</td>
                    <td style="padding: 10px;">virtualbox-guest-x11</td>
                    <td style="padding: 10px;">VirtualBox USB 3.0 (xHCI)</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>

          <!-- Workflow Steps -->
          <section class="feature-info-section">
            <h2>Deployment Walkthrough</h2>
            <ol class="numbered-guide-list">
              <li>
                <span class="guide-number">1</span>
                <div class="guide-text-block">
                  <strong>Proxmox VE One-Command CLI Deployment:</strong>
                  <p>Download the <code>TelcoChisel-2026.2-Proxmox.qcow2</code> image to your Proxmox host and execute the following automated provisioning script:</p>
                  <TerminalBlock title="Bash — Proxmox Shell" code="VMID=1050
STORAGE=&quot;local-lvm&quot;
BRIDGE=&quot;vmbr0&quot;
IMAGE=&quot;TelcoChisel-2026.2-Proxmox.qcow2&quot;

qm create $VMID --name &quot;TelcoChisel-2026.2&quot; \
  --memory 8192 --cores 4 --cpu host --machine q35 --bios ovmf \
  --efidisk0 ${STORAGE}:0,format=raw,efitype=4m,pre-enrolled-keys=0 \
  --scsihw virtio-scsi-pci --net0 virtio,bridge=${BRIDGE} \
  --vga virtio --agent enabled=1

qm importdisk $VMID $IMAGE $STORAGE
qm set $VMID --scsi0 ${STORAGE}:vm-${VMID}-disk-1,discard=on,ssd=1
qm set $VMID --boot order=scsi0
qm start $VMID" />
                </div>
              </li>
              <li>
                <span class="guide-number">2</span>
                <div class="guide-text-block">
                  <strong>VMware Workstation &amp; ESXi Deployment:</strong>
                  <p>Import the pre-configured OVF template directly into your hypervisor:</p>
                  <p style="font-size: 0.9rem; color: var(--tx-dim); margin-top: 0.5rem;">
                    1. In VMware Workstation / Fusion: <em>File &rarr; Open &rarr; select TelcoChisel-2026.2-VMware.ova</em>.<br/>
                    2. In vSphere / ESXi: <em>Deploy OVF Template &rarr; upload OVA &rarr; select compute cluster and datastore</em>.<br/>
                    3. Under <strong>VM Settings &rarr; USB Controller</strong>, verify that <strong>USB Compatibility is set to USB 3.1 (xHCI)</strong> to support SDR transceivers.<br/>
                    4. Power on the VM. Default login: <code>telcosec</code> / <code>telcosec</code>.
                  </p>
                </div>
              </li>
              <li>
                <span class="guide-number">3</span>
                <div class="guide-text-block">
                  <strong>Oracle VirtualBox Deployment:</strong>
                  <p>Import the appliance and enable USB 3.0 controller extensions:</p>
                  <TerminalBlock title="Bash / Command Prompt — VirtualBox CLI" code="# Import OVA appliance
VBoxManage import TelcoChisel-2026.2-VirtualBox.ova --vsys 0 --vmname &quot;TelcoChisel-2026.2&quot;

# Ensure USB 3.0 xHCI controller is active
VBoxManage modifyvm &quot;TelcoChisel-2026.2&quot; --usbehci off --usbxhci on

# Start the appliance
VBoxManage startvm &quot;TelcoChisel-2026.2&quot; --type gui" />
                </div>
              </li>
              <li>
                <span class="guide-number">4</span>
                <div class="guide-text-block">
                  <strong>SDR Hardware USB Passthrough:</strong>
                  <p>Attach physical Software Defined Radio transceivers directly into the virtual guest:</p>
                  <TerminalBlock title="Terminal — Verify Passthrough inside Guest" code="# Enumerate USB SDR hardware inside TelcoChisel VM
telcosec hardware

# Run pre-flight checks on low-latency buffers and permissions
telcosec check" />
                </div>
              </li>
            </ol>
          </section>

          <!-- Post-Boot Verification -->
          <section class="feature-info-section">
            <h2>Post-Deployment Diagnostics</h2>
            <p>Once booted, run the built-in diagnostic doctor to verify real-time capabilities and driver initialization:</p>
            <TerminalBlock title="Terminal — Diagnostic Audit" code="telcosec check --verbose" />
          </section>
        </article>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const sidebarOpen = ref(false)

const navigateHome = () => {
  navigateTo('/')
}

const toggleTheme = () => {
  // handled globally
}

useSeoMeta({
  title: 'Virtual Machine Appliance Deployment Guide | TelcoChisel',
  description: 'Complete deployment, guest integration, and SDR hardware passthrough guide for TelcoChisel OS on Proxmox, VMware, and VirtualBox.'
})
</script>

<style scoped>
.layout-container {
  display: flex;
  min-height: 100vh;
}
.main-content {
  flex: 1;
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}
.breadcrumbs {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  font-family: var(--mono);
  font-size: 0.85rem;
  color: var(--amber-lo);
  margin-bottom: 2rem;
}
.breadcrumb-link {
  color: var(--amber);
  text-decoration: none;
}
.breadcrumb-link:hover {
  text-decoration: underline;
}
.feature-name {
  font-size: 2.2rem;
  font-weight: 700;
  color: var(--amber-hi);
  margin-bottom: 0.5rem;
}
.feature-subtitle {
  font-size: 1.1rem;
  color: var(--tx-dim);
  margin-bottom: 1rem;
}
.feature-meta-badges {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}
.numbered-guide-list {
  list-style: none;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}
.numbered-guide-list li {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
}
.guide-number {
  background: var(--amber-g);
  color: var(--amber-hi);
  font-family: var(--mono);
  font-weight: 700;
  width: 2rem;
  height: 2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  flex-shrink: 0;
}
.guide-text-block {
  flex: 1;
}
</style>
