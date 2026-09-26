# TelcoChisel OS — Virtual Machine Appliance Deployment Guide

This guide covers deployment, configuration, and SDR hardware passthrough for TelcoChisel OS virtual appliances on **Proxmox VE**, **VMware Workstation/ESXi**, and **Oracle VirtualBox**.

---

## 1. Appliance Architecture & Highlights

| Feature | Proxmox VE | VMware Workstation / ESXi | Oracle VirtualBox |
| :--- | :--- | :--- | :--- |
| **Package Format** | `.qcow2` | `.ova` (OVF 1.0) | `.ova` (OVF 2.0) |
| **Disk Type** | Thin QCOW2 (40GB max) | Stream-optimized VMDK | Stream-optimized VMDK |
| **Default RAM / Cores** | 8 GB / 4 vCPUs | 8 GB / 4 vCPUs | 8 GB / 4 vCPUs |
| **Network Adapter** | VirtIO (Bridged / NAT) | VMXNET3 | Intel PRO/1000 MT / VirtIO |
| **Guest Integration** | `qemu-guest-agent`, `spice` | `open-vm-tools-desktop` | `virtualbox-guest-x11` |
| **Cloud-Init Support** | Yes (NoCloud / ConfigDrive) | Optional | Optional |
| **SDR USB Passthrough** | QEMU USB 3.0 (xHCI) | VMware USB 3.1 (xHCI) | VirtualBox USB 3.0 (xHCI) |

---

## 2. Proxmox VE / KVM Deployment

### A. One-Command CLI Deployment
Download `TelcoChisel-<VERSION>-Proxmox.qcow2` to your Proxmox host (e.g., `/var/lib/vz/template/qemu/` or root) and run:

```bash
# Set your desired VM ID, storage pool, and bridge:
VMID=1050
STORAGE="local-lvm"
BRIDGE="vmbr0"
IMAGE="TelcoChisel-2026.2-Proxmox.qcow2"

# 1. Create VM shell with optimal telco settings (host CPU, q35, UEFI OVMF)
qm create $VMID \
  --name "TelcoChisel-2026.2" \
  --memory 8192 \
  --cores 4 \
  --cpu host \
  --machine q35 \
  --bios ovmf \
  --efidisk0 ${STORAGE}:0,format=raw,efitype=4m,pre-enrolled-keys=0 \
  --scsihw virtio-scsi-pci \
  --net0 virtio,bridge=${BRIDGE} \
  --vga virtio \
  --agent enabled=1

# 2. Import virtual disk into storage
qm importdisk $VMID "$IMAGE" "$STORAGE" --format qcow2

# 3. Attach imported disk as primary boot drive with SSD discard
qm set $VMID --scsi0 ${STORAGE}:vm-${VMID}-disk-1,discard=on,ssd=1
qm set $VMID --boot order=scsi0

# 4. Attach Cloud-Init drive (for root disk auto-expansion and SSH keys)
qm set $VMID --ide2 ${STORAGE}:cloudinit
qm set $VMID --citype nocloud

# 5. Start VM
qm start $VMID
```

*(Alternatively, run the generated `./TelcoChisel-<VERSION>-Proxmox-import.sh` script included in the distribution).*

### B. Proxmox USB Passthrough for SDRs
For software-defined radios (USRP B200/B210, HackRF One, LimeSDR, BladeRF):
1. In the Proxmox Web GUI, select the VM -> **Hardware** -> **Add** -> **USB Device**.
2. Select **Use USB Vendor/Device ID**.
3. Enable **USB3 (xHCI)**.
4. Select your SDR from the dropdown list.

---

## 3. VMware Workstation / Fusion / ESXi Deployment

### A. Workstation / Fusion (Desktop)
1. Open VMware Workstation or VMware Fusion.
2. Navigate to **File** -> **Open...** and select `TelcoChisel-<VERSION>-VMware.ova`.
3. Choose a name and local storage directory for the imported virtual machine.
4. Click **Import**.
5. Once imported, navigate to **Virtual Machine Settings**:
   - **Processors**: Check **Virtualize Intel VT-x/EPT or AMD-V/RVI** (enables nested virtualization for Docker cellular testbeds).
   - **USB Controller**: Verify **USB compatibility: USB 3.1** is selected.
6. Power on the virtual machine.

### B. VMware ESXi / vSphere
1. Log in to the vSphere Client or ESXi Host Client.
2. Right-click your Cluster/Host -> **Deploy OVF Template**.
3. Select `TelcoChisel-<VERSION>-VMware.ova`.
4. Select compute resource, storage datastore, and target network (e.g. `VM Network`).
5. Complete the wizard and power on the VM.

### C. VMware SDR USB Passthrough
When connecting an SDR to the host machine:
1. Go to **VM** -> **Removable Devices** -> select your SDR (e.g., `Ettus Research USRP B210` or `Great Scott Gadgets HackRF One`).
2. Select **Connect (Disconnect from Host)**.
3. In the TelcoChisel terminal, verify detection with `uhd_find_devices` or `hackrf_info`.

---

## 4. Oracle VirtualBox Deployment

### A. Prerequisites
- Install **Oracle VM VirtualBox Extension Pack** (mandatory for USB 2.0 / USB 3.0 xHCI controller support).

### B. Appliance Import
1. Open VirtualBox and navigate to **File** -> **Import Appliance...** (or press `Ctrl+I`).
2. Select `TelcoChisel-<VERSION>-VirtualBox.ova`.
3. In appliance settings:
   - Verify RAM is set to at least 4096 MB (8192 MB recommended).
   - Verify Network Adapter is set to **Bridged Adapter** (for active RF audit/packet capture) or **NAT** (for general research).
4. Click **Finish**.

### C. VirtualBox SDR USB Filter Setup
1. In VirtualBox, select the VM -> **Settings** -> **Ports** -> **USB**.
2. Confirm **USB 3.0 (xHCI) Controller** is enabled.
3. Click the **+** (Add USB Filter) icon on the right.
4. Plug in your SDR and select it from the list to create a persistent USB capture filter.
5. Boot the VM. VirtualBox will automatically capture the SDR whenever it is connected.

---

## 5. SDR & Cellular Hardware USB IDs Reference

When configuring hypervisor USB filters or Proxmox device rules, use these standard USB Vendor/Product IDs:

| Hardware Device | Vendor ID | Product ID | Notes |
| :--- | :--- | :--- | :--- |
| **Ettus USRP B200/B210 (Bootloader)** | `2500` | `0020` | Initial FX3 bootloader state |
| **Ettus USRP B200/B210 (Firmware)** | `2500` | `0021` | Active operational state after firmware load |
| **Ettus USRP B200mini** | `2500` | `0022` | Miniature xHCI SDR |
| **HackRF One** | `1d50` | `6089` | Great Scott Gadgets HackRF One |
| **Nuand bladeRF (Bootloader)** | `2cf0` | `0024` | FX3 Cypress Bootloader |
| **Nuand bladeRF 2.0 micro** | `2cf0` | `5246` | Operational BladeRF state |
| **MyriadRF LimeSDR-USB** | `0403` | `601f` | FTDI FT601 USB 3.0 controller |
| **Sysmocom SIMtrace 2** | `1d50` | `60e3` | SIM card trace / APDU sniffer |
| **Quectel RM500Q-GL (5G Modem)** | `2c7c` | `0800` | Qualcomm Snapdragon X55 5G module |
| **Telit FN980m (5G Modem)** | `1bc7` | `1050` | M.2 to USB 3.0 adapter |

> [!TIP]
> For Ettus USRP B200/B210 devices, always create **two** USB filters in VirtualBox/VMware: one for `2500:0020` (uninitialized FX3 bootloader) and one for `2500:0021` (FPGA-loaded operational device).
