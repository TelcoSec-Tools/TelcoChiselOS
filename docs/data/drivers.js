export const driversCatalog = [
    {
        name: "USRP B210 / X310",
        slug: "usrp-b210-x310",
        category: "transceiver",
        desc: "Ettus Research Software Defined Radio (SDR) transceivers. Widely regarded as the industry standard for 5G NR (UERANSIM, OAI) and 4G LTE simulations.",
        udev: 'ATTRS{idVendor}=="2514", ATTRS{idProduct}=="0002", MODE:="0660", GROUP:="plugdev"\nATTRS{idVendor}=="2514", ATTRS{idProduct}=="0020", MODE:="0660", GROUP:="plugdev"',
        cmd: 'uhd_usrp_probe --args="type=b200"'
    },
    {
        name: "HackRF One",
        slug: "hackrf-one",
        category: "transceiver",
        desc: "Great Scott Gadgets half-duplex Software Defined Radio operating from 1 MHz to 6 GHz. Designed for RF sniffing, analysis, and protocol replay audits.",
        udev: 'ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", SYMLINK+="hackrf-%k", MODE:="660", GROUP:="plugdev"',
        cmd: "hackrf_info"
    },
    {
        name: "BladeRF 2.0 micro",
        slug: "bladerf-2-0-micro",
        category: "transceiver",
        desc: "Nuand BladeRF 2.0 micro xA4/xA9 MIMO SDR transceiver. Excellent for running 4G/5G base stations and advanced baseband fuzzing (5Ghoul).",
        udev: 'ATTRS{idVendor}=="2cf0", ATTRS{idProduct}=="5250", MODE:="0660", GROUP:="plugdev"',
        cmd: "bladeRF-cli -p"
    },
    {
        name: "LimeSDR",
        slug: "limesdr",
        category: "transceiver",
        desc: "Lime Microsystems LimeSDR USB, PCIe, and Mini transceivers. Ideal for running software-defined GSM/LTE base stations (Osmocom GSM, OpenBTS).",
        udev: 'SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="601f", MODE:="0666", GROUP:="plugdev"',
        cmd: "LimeUtil --find"
    },
    {
        name: "RTL-SDR",
        slug: "rtl-sdr",
        category: "transceiver",
        desc: "Ultra-low-cost DVB-T dongle repurposed as a receive-only Software Defined Radio. Essential for GSM scanning, frequency offset calibration, and ADS-B capturing.",
        udev: 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", MODE:="0666", GROUP:="plugdev"',
        cmd: "rtl_test -t"
    },
    {
        name: "Osmocom SIMtrace 2",
        slug: "osmocom-simtrace-2",
        category: "sniffing",
        desc: "Osmocom smartcard trace hardware. Intercepts ISO-7816 communication between active handsets and physical SIM cards for live GSMTAP capturing.",
        udev: 'ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="60e3", MODE:="0660", GROUP:="plugdev"',
        cmd: "simtrace2-list"
    },
    {
        name: "PC/SC Smartcard Readers",
        slug: "pcsc-smartcard-readers",
        category: "reader",
        desc: "Generic USB smartcard readers (Gemalto, ACS, Omnikey). Used for SIM/USIM card reading, programming (pySim-shell), and eSIM profile installations (lpac).",
        udev: '# PC/SC readers are managed by pcscd service\n# Rules generally map CCID interfaces to pcscd daemon',
        cmd: "pcsc_scan"
    }
]
