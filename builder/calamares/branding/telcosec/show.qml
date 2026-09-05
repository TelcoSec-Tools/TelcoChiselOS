import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#181a1b"
    anchors.fill: parent

    // Animated background grid (telecom-style)
    Canvas {
        id: bgGrid
        anchors.fill: parent
        opacity: 0.06
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "#e8921e";
            ctx.lineWidth = 0.5;
            var step = 40;
            for (var x = 0; x < width; x += step) {
                ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke();
            }
            for (var y = 0; y < height; y += step) {
                ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke();
            }
        }
    }

    // Animated glowing background orb
    Rectangle {
        id: glowOrb
        width: 340; height: 340
        radius: 170
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -40
        color: "transparent"
        border.color: "#e8921e"
        border.width: 1
        opacity: 0.12

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.22; duration: 2500 }
            NumberAnimation { to: 0.08; duration: 2500 }
        }
    }

    // Carousel Data & Index
    property int currentSlide: 0

    Timer {
        interval: 6500
        running: true
        repeat: true
        onTriggered: {
            root.currentSlide = (root.currentSlide + 1) % 5;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 0

        // Header Brand Banner
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Image {
                source: "logo.png"
                sourceSize.width: 42
                sourceSize.height: 42
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "TelcoSec TelcoChisel"
                color: "#e8921e"
                font.pixelSize: 24
                font.bold: true
                font.letterSpacing: 2
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Item { height: 15 }

        // Separator Line
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: parent.width * 0.8; height: 1; color: "#e8921e"; opacity: 0.4
        }

        Item { Layout.fillHeight: true }

        // Slide Container with Fade Transitions
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 260

            // Slide 1: Welcome & OS Vision
            Item {
                anchors.fill: parent
                opacity: root.currentSlide === 0 ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 600 } }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: "Advanced Telecom Security OS"
                        color: "#f5aa35"
                        font.pixelSize: 22
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Bootable Live & Installable Linux Environment for 4G/5G Network Auditing"
                        color: "#e8e6e3"
                        font.pixelSize: 13
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item { height: 8 }

                    Text {
                        text: "• Pre-loaded with 88+ specialized cellular & radio analysis tools\n• Configured for USRP, HackRF One, BladeRF, LimeSDR & RTL-SDR\n• Standardized training platform for TelcoSec Academy"
                        color: "#a0a5aa"
                        font.pixelSize: 12
                        lineHeight: 1.4
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Slide 2: Software Defined Radio (SDR)
            Item {
                anchors.fill: parent
                opacity: root.currentSlide === 1 ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 600 } }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: "Software Defined Radio (SDR) Suite"
                        color: "#f5aa35"
                        font.pixelSize: 22
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "GNU Radio 3.10 • SoapySDR • UHD • HackRF • GQRX • gr-gsm"
                        color: "#e8e6e3"
                        font.pixelSize: 13
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item { height: 8 }

                    Text {
                        text: "• Isolated telcosec-sdr Conda environment to prevent Python ABI conflicts\n• Low-latency kernel tuning with USB autosuspend disabled for RF stability\n• Pre-compiled drivers for USRP B210/X310, BladeRF 2.0 xA4 & LimeSDR"
                        color: "#a0a5aa"
                        font.pixelSize: 12
                        lineHeight: 1.4
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Slide 3: 4G/5G RAN & Core Network Simulation
            Item {
                anchors.fill: parent
                opacity: root.currentSlide === 2 ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 600 } }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: "4G/5G RAN & Core Network Simulation"
                        color: "#f5aa35"
                        font.pixelSize: 22
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "UERANSIM 5G SA • srsRAN • Open5GS 5G Core • 5Ghoul Baseband Fuzzer"
                        color: "#e8e6e3"
                        font.pixelSize: 13
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item { height: 8 }

                    Text {
                        text: "• Complete 5G Standalone (SA) gNodeB and UE emulation pre-configured\n• Automated 5Ghoul fuzzer harness for 5G NR baseband vulnerability testing\n• Zero-ZMQ backend support for high-speed local core network simulation"
                        color: "#a0a5aa"
                        font.pixelSize: 12
                        lineHeight: 1.4
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Slide 4: Baseband & SIM Smartcard Auditing
            Item {
                anchors.fill: parent
                opacity: root.currentSlide === 3 ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 600 } }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: "Baseband Emulation & SIM Smartcard Auditing"
                        color: "#f5aa35"
                        font.pixelSize: 22
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "FirmWire • QCSuper • MTKClient • pySim • Osmocom SIMtrace 2 • lpac"
                        color: "#e8e6e3"
                        font.pixelSize: 13
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item { height: 8 }

                    Text {
                        text: "• QEMU-based firmware emulation for Samsung Shannon & MediaTek modems\n• Hardware ISO 7816 smartcard sniffing with SIMtrace 2 & SIMurai\n• Command-line eSIM (SGP.22) profile management via lpac"
                        color: "#a0a5aa"
                        font.pixelSize: 12
                        lineHeight: 1.4
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Slide 5: Core Signaling & Protocol Security
            Item {
                anchors.fill: parent
                opacity: root.currentSlide === 4 ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 600 } }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: "Core Signaling & Protocol Auditing"
                        color: "#f5aa35"
                        font.pixelSize: 22
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Wireshark (GSMTAP/GTP Profiles) • SigPloit • Diafuzzer • sctpscan • Scapy"
                        color: "#e8e6e3"
                        font.pixelSize: 13
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item { height: 8 }

                    Text {
                        text: "• Custom Wireshark protocol column formats for 5G NAS, GTP-U & GSMTAP\n• SS7, Diameter & GTP signaling exploitation & fuzzing toolkits\n• Scapy packet crafting with MAP, TCAP, and Diameter protocol definitions"
                        color: "#a0a5aa"
                        font.pixelSize: 12
                        lineHeight: 1.4
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Slide Indicator Dots
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Repeater {
                model: 5
                Rectangle {
                    width: index === root.currentSlide ? 24 : 8
                    height: 8
                    radius: 4
                    color: index === root.currentSlide ? "#e8921e" : "#444444"
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }
        }

        Item { height: 20 }

        // Installation Progress Message
        Text {
            id: progressMsg
            Layout.alignment: Qt.AlignHCenter
            text: "Installing TelcoChisel to disk..."
            color: "#e8921e"
            font.pixelSize: 13
            opacity: 0.85

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.4; duration: 1500 }
                NumberAnimation { to: 0.95; duration: 1500 }
            }
        }

        Item { height: 10 }
    }
}
