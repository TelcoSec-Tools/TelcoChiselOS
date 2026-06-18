/**
 * Rich SEO and AEO metadata for the supported cellular hardware and drivers.
 */

export const driversMetadata = {
  "usrp-b210-x310": {
    keywords: ["USRP B210 driver install", "Ettus Research USRP Ubuntu setup", "UHD driver compilation USRP", "USRP 5G NR transceiver setup"],
    overview: "Ettus Research USRP (Universal Software Radio Peripheral) B210 and X310 are the gold standard for software-defined radio cellular research. Featuring a fully integrated RF frontend covering 70 MHz to 6 GHz, they support 2x2 MIMO operations, making them ideal for high-bandwidth 5G Standalone (SA) and 4G LTE cellular simulations.",
    config: [
      "Ensure the USRP is connected to a dedicated USB 3.0 host port (Intel/AMD controllers preferred; ASMedia and generic controllers can cause sample drops).",
      "Configure udev permissions to allow non-root access by placing the UHD rules in /etc/udev/rules.d/ and reloading: sudo udevadm control --reload-rules && sudo udevadm trigger",
      "Launch the Conda workspace to load UHD shared libraries: conda activate telcosec-sdr",
      "Run the diagnostic check to verify RF frontend connection and load firmware: uhd_usrp_probe"
    ],
    troubleshooting: "If UHD outputs 'U' (underrun) or 'O' (overrun) characters, the host cannot keep up with USB transfer rates. Check if CPU power-saving modes are active, disable CPU mitigations (mitigations=off in GRUB), or lower the sample rate (e.g. to 5 MSps).",
    faq: [
      { q: "Can I run USRP B210 inside VirtualBox?", a: "Yes, but you must install the VirtualBox Extension Pack, enable the USB 3.0 (xHCI) controller, and pass the Ettus transceiver descriptor. Note that high sample rates will drop packets due to virtualization latency." },
      { q: "Why does USRP probe report firmware mismatch?", a: "The UHD library requires matching FPGA images on the device. TelcoChisel caches these images. Run 'uhd_images_downloader' inside the conda environment to fetch matching binaries if you update the driver." }
    ]
  },
  "hackrf-one": {
    keywords: ["HackRF One Linux tools", "hackrf_info firmware flash update", "HackRF SDR transceiver setup", "HackRF One udev rules"],
    overview: "The Great Scott Gadgets HackRF One is a half-duplex Software Defined Radio transceiver capable of transmission or reception of radio signals from 1 MHz to 6 GHz. While limited to 8-bit resolution and half-duplex operation, its wide frequency coverage and low cost make it essential for passive cellular scanning (GSM/LTE/5G) and signal replay audits.",
    config: [
      "Connect the HackRF One to any USB 2.0 or 3.0 port on the host.",
      "Verify the device status and read internal firmware version: hackrf_info",
      "To scan for active cell towers, activate the Conda workspace and launch a scanning tool: conda activate telcosec-sdr && kal -s GSM900"
    ],
    troubleshooting: "HackRF One operates half-duplex (cannot transmit and receive at the same time). If a cellular base station simulator (like YateBTS) fails, verify that the radio is not configured for full-duplex transceiver loops.",
    faq: [
      { q: "Is HackRF One compatible with 5Ghoul fuzzer?", a: "Yes, but because 5Ghoul relies on OpenAirInterface (which expects full-duplex MIMO operations), it is highly recommended to use USRP B210 or BladeRF instead of HackRF for reliable 5G NR testing." },
      { q: "How do I fix HackRF permissions issues?", a: "Ensure udev rule '50-telcosec-hw.rules' is loaded, which maps USB vendor '1d50' and product '6089' to the 'plugdev' group." }
    ]
  },
  "bladerf-2-0-micro": {
    keywords: ["BladeRF 2.0 micro Linux install", "Nuand BladeRF firmware flash", "BladeRF libbladeRF setup", "BladeRF 5Ghoul fuzzer"],
    overview: "The Nuand BladeRF 2.0 micro is an advanced USB 3.0 SuperSpeed Software Defined Radio featuring a high-performance Altera Cyclone V FPGA. With dual transmit and receive channels (2x2 MIMO) and up to 61.44 MSps sample rates, it is highly optimized for hosting standalone 4G/5G NR cells (srsRAN) and executing low-level baseband fuzzing campaigns (5Ghoul).",
    config: [
      "Connect the BladeRF 2.0 micro using the supplied USB 3.0 cable to a SuperSpeed port.",
      "Check connection and verify current FPGA and firmware configuration: bladeRF-cli -p",
      "If the FPGA is not loaded on boot, run the CLI utility to load the target FPGA image: bladeRF-cli -l /usr/share/Nuand/bladeRF/hosted.rbf"
    ],
    troubleshooting: "FPGA image loading fails if the firmware and FPGA versions mismatch. Use 'bladeRF-cli -V' to check version alignments, and make sure the correct .rbf file is selected.",
    faq: [
      { q: "Does the BladeRF 2.0 micro support 5G Standalone?", a: "Yes, it supports full-duplex operation required by srsRAN and OpenAirInterface to host 5G SA cells." },
      { q: "Why does the device drop connection during transmission?", a: "SDRs draw substantial current during RF transmission. Ensure the BladeRF is connected to an active, powered USB 3.0 hub or supply external DC power (5V)." }
    ]
  },
  "limesdr": {
    keywords: ["LimeSDR drivers installation Ubuntu", "LimeSuite GUI SDR configuration", "LimeSDR SoapySDR compatibility", "LimeSDR cellular BTS"],
    overview: "LimeSDR transceivers, powered by the Lime Microsystems LMS7002M field-programmable RF IC, support 2x2 MIMO operations across a 100 kHz to 3.8 GHz range. Integrated with LimeSuite and SoapySDR drivers, they are excellent tools for running software-defined GSM, UMTS, and LTE cells.",
    config: [
      "Connect the LimeSDR device via USB or PCIe host bus.",
      "Verify driver recognition and print hardware diagnostics: LimeUtil --find",
      "Launch LimeSuiteGUI to calibrate internal RF loops and load custom configuration files: LimeSuiteGUI"
    ],
    troubleshooting: "LimeSDR transceivers require calibration to suppress local oscillator leakage. If the signal quality is poor, run the built-in calibration command: LimeUtil --cal"
  },
  "rtl-sdr": {
    keywords: ["RTL-SDR driver Linux setup", "RTL-SDR PPM frequency calibration", "rtl_sdr command line scanner", "RTL-SDR udev rules"],
    overview: "RTL-SDR is an ultra-low-cost, receive-only Software Defined Radio based on Realtek RTL2832U demodulator chips. While limited to 8-bit ADC resolution and 3.2 MHz bandwidth, it is the entry-level tool for GSM channel sniffing, cell scanner utilities (LTE-CellScanner), and local oscillator frequency calibration.",
    config: [
      "Insert the RTL-SDR dongle into a USB port.",
      "Verify connection and check for frequency tuner details: rtl_test -t",
      "Determine frequency offset using Kalibrate RTL: kal -s GSM900 -g 35"
    ],
    troubleshooting: "By default, Linux kernels load the dvb_usb_rtl28xxu TV tuner driver, which locks access to the SDR. TelcoChisel blacklists this TV driver in /etc/modprobe.d/ to ensure raw USB access.",
    faq: [
      { q: "Can I transmit with RTL-SDR?", a: "No, RTL-SDR is strictly a receive-only hardware device." },
      { q: "What is PPM and why calibration matters?", a: "Parts Per Million (PPM) offset measures oscillator drift. Correcting this offset in software is essential to decode narrow cellular broadcast channels." }
    ]
  },
  "osmocom-simtrace-2": {
    keywords: ["Osmocom SIMtrace 2 smartcard sniffer", "SIMtrace 2 udev hardware driver", "SIMtrace firmware flashing guide", "ISO-7816 smartcard tracing"],
    overview: "The Osmocom SIMtrace 2 is specialized open-source hardware designed for sniffing and intercepting the ISO-7816 smartcard bus interface between physical SIM card readers and mobile handsets. It transmits the sniffed communication logs (APDUs) via USB using the GSMTAP protocol.",
    config: [
      "Insert the SIM card into the SIMtrace board slot, and connect the FPC adapter card from the SIMtrace to the mobile terminal card slot.",
      "Connect the SIMtrace 2 mainboard to the host PC via USB.",
      "Verify device registration: simtrace2-list",
      "Launch the trace forwarder daemon: simtrace2-sniff -i 127.0.0.1"
    ],
    troubleshooting: "If the phone displays 'Insert SIM', the FPC ribbon cable is likely misaligned or damaged. Check contacts carefully.",
    faq: [
      { q: "Can SIMtrace 2 emulate a SIM card?", a: "Yes, in addition to passive sniffing, it can perform card emulation mode to feed simulated SIM profiles from pySim-shell." },
      { q: "How do I read SIMtrace logs?", a: "Run simtrace2-sniff, start Wireshark, and look for packets under the 'gsmtap' protocol filter." }
    ]
  },
  "pcsc-smartcard-readers": {
    keywords: ["PC/SC reader driver install linux", "pcscd smart card service configuration", "Omnikey ACS ACR122U Linux", "SIM card reader PC/SC daemon"],
    overview: "PC/SC (Personal Computer/Smart Card) readers are the industry-standard hardware adapters for communicating with physical smartcards (such as SIM, USIM, and eSIM chips). Supported by the pcscd system service, they provide the necessary transport layers for pySim-shell and lpac profile configurations.",
    config: [
      "Connect your USB CCID-compliant smartcard reader.",
      "Ensure the pcscd system service daemon is active: sudo systemctl start pcscd",
      "Audit connected readers and query the ATR (Answer To Reset) from the inserted SIM: pcsc_scan"
    ],
    troubleshooting: "If the reader is not detected, check if another application is locking the CCID interface, or inspect pcscd system logs: journalctl -u pcscd",
    faq: [
      { q: "What is ATR?", a: "Answer To Reset is the first byte string returned by a smart card upon power-up, identifying card operating protocols and speed parameters." },
      { q: "Does pcscd support eSIM chips?", a: "Yes, eSIMs are physically standard UICCs that communicate using the same ISO-7816 commands through standard PC/SC interfaces." }
    ]
  }
};

/**
 * Returns complete SEO/AEO metadata for a given driver or hardware device.
 */
export function getDriverMetadata(slug) {
  return driversMetadata[slug] || null;
}
