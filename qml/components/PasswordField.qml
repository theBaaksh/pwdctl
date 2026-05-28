import QtQuick
import QtQuick.Controls

Item {
    id: root

    property alias password: input.text
    property string errorText: ""
    property bool capsLockActive: false

    signal accepted()
    signal edited()

    implicitHeight: capsHint.visible ? 118 : 86

    function clearPassword() {
        input.text = ""
    }

    function focusPassword() {
        input.forceActiveFocus()
    }

    Rectangle {
        id: fieldFrame
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 66
        radius: 22
        color: "#ffffff"
        border.width: 1
        border.color: root.errorText.length > 0 ? "#df3f70" : (input.activeFocus ? "#69eee3" : "#f1bbd2")

        Behavior on border.color {
            ColorAnimation { duration: 160 }
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 21
            anchors.verticalCenter: parent.verticalCenter
            text: "✦"
            color: input.activeFocus ? "#17bfb1" : "#d797b2"
            font.pixelSize: 18
        }

        TextInput {
            id: input
            anchors.left: parent.left
            anchors.leftMargin: 56
            anchors.right: revealButton.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            color: "#20151e"
            selectedTextColor: "#20151e"
            selectionColor: "#9ff7ee"
            echoMode: revealButton.checked ? TextInput.Normal : TextInput.Password
            font.pixelSize: 20
            clip: true
            verticalAlignment: TextInput.AlignVCenter
            passwordCharacter: "•"

            Keys.onReturnPressed: root.accepted()
            Keys.onEnterPressed: root.accepted()
            onTextEdited: root.edited()
        }

        Text {
            anchors.left: input.left
            anchors.verticalCenter: input.verticalCenter
            visible: input.length === 0 && !input.activeFocus
            text: "Master password"
            color: "#b98ca0"
            font.pixelSize: 18
        }

        Button {
            id: revealButton
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 42
            height: 42
            checkable: true
            flat: true
            hoverEnabled: true

            background: Rectangle {
                radius: 15
                color: revealButton.checked ? "#ddfff9" : (revealButton.hovered ? "#fff0f7" : "transparent")
            }

            contentItem: Text {
                text: revealButton.checked ? "◉" : "◎"
                color: revealButton.checked ? "#17bfb1" : "#ad7890"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 18
            }
        }
    }

    Text {
        id: capsHint
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: fieldFrame.bottom
        anchors.topMargin: 10
        visible: root.capsLockActive
        text: "Caps Lock is on"
        color: "#8a6472"
        font.pixelSize: 13
    }
}
