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
        opacity: 0.07
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "#00d1b2";
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

    // Animated glowing orb
    Rectangle {
        id: glowOrb
        width: 300; height: 300
        radius: 150
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -30
        color: "transparent"
        border.color: "#00d1b2"
        border.width: 1
        opacity: 0.15

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.25; duration: 2000 }
            NumberAnimation { to: 0.1;  duration: 2000 }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item { Layout.fillHeight: true }

        // Logo text
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "TelcoSec"
            color: "#00d1b2"
            font.pixelSize: 52
            font.bold: true
            font.letterSpacing: 4
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Chisel"
            color: "#e8e6e3"
            font.pixelSize: 30
            font.letterSpacing: 12
        }

        Item { height: 20 }

        // Separator line
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 200; height: 1; color: "#00d1b2"; opacity: 0.5
        }

        Item { height: 16 }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Telecom Security Linux Distribution"
            color: "#888888"
            font.pixelSize: 14
            font.letterSpacing: 1
        }

        Item { Layout.fillHeight: true }

        // Progress message at bottom
        Text {
            id: progressMsg
            Layout.alignment: Qt.AlignHCenter
            anchors.bottomMargin: 30
            text: "Setting up your secure environment..."
            color: "#00d1b2"
            font.pixelSize: 13
            opacity: 0.8
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 1500 }
                NumberAnimation { to: 0.9; duration: 1500 }
            }
        }

        Item { height: 40 }
    }
}
