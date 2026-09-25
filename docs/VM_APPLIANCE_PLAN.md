# TelcoChisel OS — Virtual Machine Appliances Engineering Plan
**Targets:** Proxmox VE (QCOW2/Cloud-Init), VirtualBox (OVA), VMware Workstation/ESXi (OVA/VMDK)

---

## 1. Architectural Objectives

While the **TelcoChisel Live ISO** excels for bare-metal field laptops with direct PCI/USB hardware access, many telecom security researchers, academic labs, and enterprise red teams require **pre-built Virtual Machine appliances**:
1. **Proxmox VE / KVM Clusters**: For spinning up multi-node 5G Core, gNodeB, and O-RAN testbeds with network bridging and VLAN trunking.
2. **VMware Workstation Pro / Fusion / ESXi**: The de facto corporate standard for offensive security consultants and defense contractors.
3. **Oracle VirtualBox**: Zero-cost, cross-platform local research environment for individual analysts.

---

## 2. Hypervisor Technical Matrix

| Hypervisor Target | Primary Format | Disk Type | Guest Agent | Virtual Hardware Profile |
| :--- | :--- | :--- | :--- | :--- |
| **Proxmox VE / KVM** | `.qcow2` (or `.vma.zst`) | Thin-provisioned (40GB max, ~3.5GB packed) | `qemu-guest-agent`, `spice-vdagent` | CPU: `host`, Machine: `q35`, SCSI: `virtio-scsi-pci`, NIC: `virtio`, Display: `virtio-vga` |
| **VMware (Workstation / ESXi)** | `.ova` / `.vmdk` | Stream-optimized VMDK | `open-vm-tools`, `open-vm-tools-desktop` | HW Version: `vmx-19`, NIC: `vmxnet3`, USB: `xHCI 3.1`, Display: Auto-resize with 3D accel |
| **Oracle VirtualBox** | `.ova` | OVF 2.0 with streamOptimized VMDK | `virtualbox-guest-utils`, `virtualbox-guest-x11` | Chipset: `ICH9`, NIC: `VirtIO` or `Intel PRO/1000 MT`, USB: `xHCI 3.0`, Display: `VBoxSVGA` |

---

## 3. Core Technical Decisions

### A. Build Pipeline Strategy: Direct Rootfs-to-Disk Conversion
Rather than running slow nested virtualization (which is fragile in CI and requires 90+ minutes per VM), we will build **`builder/vm/build-vm.sh`**:
1. **Source of Truth**: Reuses the exact same consolidated rootfs produced by `builder/scripts/` (or extracts `filesystem.squashfs` from the already-built ISO).
2. **Disk Creation**:
   - Creates a 40 GB sparse raw disk image (`raw`).
   - Formats with GPT partition table:
     - Partition 1: EFI System Partition (512 MB, FAT32)
     - Partition 2: Linux Root filesystem (ext4)
   - Synchronizes rootfs into partition via `guestfish`, `kpartx`, or `qemu-nbd`.
   - Installs GRUB EFI (`grub-efi-amd64`) and sets `/etc/fstab` with UUIDs.
3. **Appliance Conversion**:
   - Proxmox: `qemu-img convert -c -f raw -O qcow2 disk.raw telcochisel-2026.1-proxmox.qcow2`
   - VMware: `qemu-img convert -f raw -O vmdk -o subformat=streamOptimized disk.raw telcochisel-2026.1-vmware.vmdk`
   - VirtualBox: Packages streamOptimized VMDK + custom `.ovf` descriptor + SHA256 manifest into `.ova`.

### B. Guest Additions & System Services
Update `builder/scripts/lib/packages.sh` to install all three hypervisor integrations in the base image:
- `qemu-guest-agent` + `spice-vdagent` (Proxmox / KVM)
- `open-vm-tools` + `open-vm-tools-desktop` (VMware)
- `virtualbox-guest-utils` + `virtualbox-guest-x11` (VirtualBox)
- `cloud-init` + `cloud-initramfs-growroot` (Automated Proxmox root disk expansion on boot)

### C. Radio / Hardware Passthrough Configurations
In telecommunications security, SDRs (USRP B210, HackRF, LimeSDR, BladeRF) require high-speed USB 3.0/3.1 passthrough.
The OVF descriptors and documentation will pre-configure:
- **USB 3.0 / 3.1 xHCI Controller** enabled by default in all VM templates.
- **CPU Virtualization Extensions**: VMX/SVM flags passed through (`nested-hv`) to allow nested Docker/Podman cellular containers and QEMU baseband emulation (`FirmWire`).

---

## 4. Phase-by-Phase Implementation Plan

```mermaid
flowchart LR
    A["Phase 1: Package Prerequisites"] --> B["Phase 2: VM Build Engine (build-vm.sh)"]
    B --> C["Phase 3: OVF Descriptors & Appliance Packaging"]
    C --> D["Phase 4: CI/CD & SourceForge Distribution"]
    D --> E["Phase 5: Documentation & Cheatsheets"]
```

### Phase 1: Package & Kernel Prerequisites (`builder/scripts/`)
1. Add `qemu-guest-agent`, `spice-vdagent`, `virtualbox-guest-utils`, `virtualbox-guest-x11`, `cloud-init`, and `cloud-initramfs-growroot` to `PKGS_BASE` in `builder/scripts/lib/packages.sh`.
2. Configure systemd services to gracefully detect hypervisors at boot without throwing errors when running on bare metal.

### Phase 2: VM Build Engine (`builder/vm/build-vm.sh`)
Create a single modular script `builder/vm/build-vm.sh` capable of:
- Accepting `--iso` (extracting `filesystem.squashfs`) or `--rootfs`.
- Assembling partitioned sparse virtual disk.
- Injecting hypervisor-optimized fstab, GRUB configuration, and cloud-init defaults.
- Exporting `.qcow2`, `.vmdk`, and generating checksums.

### Phase 3: OVF Descriptors & OVA Packaging
1. Create `builder/vm/templates/virtualbox.ovf`:
   - Configured with 4 vCPUs, 8 GB RAM, 40 GB dynamic disk, VirtIO/Intel NIC, xHCI USB 3.0 controller.
2. Create `builder/vm/templates/vmware.ovf`:
   - Configured with Hardware Version 19, VMXNET3 NIC, xHCI USB 3.1 controller, 3D accelerated SVGA.
3. Automated OVA assembly: `tar -cf TelcoChisel-2026.1-VirtualBox.ova template.ovf disk.vmdk ...` with SHA-256 `.mf` manifest.

### Phase 4: CI/CD & SourceForge Distribution
1. Add `release-vm.yml` workflow or integrate into `release.yml` under an on-demand trigger:
   - Publishes to SourceForge under `virtual-machines/proxmox/`, `virtual-machines/virtualbox/`, and `virtual-machines/vmware/`.
2. Generate `.sha256` and `.zst` compressed artifacts.

### Phase 5: Operator Guides & Docs Portal
Add a comprehensive **Virtual Machine Deployment Guide** to `docs/`:
- **Proxmox VE Guide**: One-command `qm importdisk` + cloud-init setup.
- **VMware Guide**: Importing OVA + SDR USB 3.1 passthrough configuration.
- **VirtualBox Guide**: Extension pack installation + USB 3.0 filter setup.
