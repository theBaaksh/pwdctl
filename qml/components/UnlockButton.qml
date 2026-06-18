import QtQuick
import QtQuick.Controls

Button {
    id: root

    property bool busy: false

    implicitHeight: 62
    hoverEnabled: true

    background: Rectangle {
        id: bg
        radius: 22
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.enabled ? "#ff7fb0" : "#dfb5c6" }
            GradientStop { position: 1.0; color: root.enabled ? "#18cfc0" : "#bacfcb" }
        }
        border.color: "#fff7fb"
        border.width: 1
        scale: root.down ? 0.985 : (root.hovered && root.enabled ? 1.012 : 1)

        Behavior on scale {
            NumberAnimation { duration: 110; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -5
            radius: parent.radius + 5
            color: "transparent"
            border.color: "#9ff7ee"
            border.width: 2
            opacity: root.enabled ? glowPulse.opacityValue : 0
        }
    }

    contentItem: Item {
        Text {
            anchors.centerIn: parent
            text: root.busy ? root.text + busyDots.text : root.text
            color: "#ffffff"
            font.pixelSize: 18
            font.weight: Font.DemiBold
        }
    }

    SequentialAnimation {
        id: glowPulse
        property real opacityValue: 0.18
        loops: Animation.Infinite
        running: root.enabled
        NumberAnimation { target: glowPulse; property: "opacityValue"; to: 0.48; duration: 1100; easing.type: Easing.InOutSine }
        NumberAnimation { target: glowPulse; property: "opacityValue"; to: 0.18; duration: 1100; easing.type: Easing.InOutSine }
    }

    Timer {
        interval: 260
        running: root.busy
        repeat: true
        onTriggered: busyDots.step = (busyDots.step + 1) % 4
    }

    QtObject {
        id: busyDots
        property int step: 0
        property string text: step === 0 ? "" : step === 1 ? "." : step === 2 ? ".." : "..."
    }
}
