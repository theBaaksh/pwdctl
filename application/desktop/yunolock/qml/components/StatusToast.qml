import QtQuick

Rectangle {
    id: root

    property string text: ""
    property string kind: "error"

    implicitHeight: Math.max(42, messageText.implicitHeight + 20)
    radius: 16
    color: kind === "error" ? "#ffe0eb" : "#ddfff9"
    border.color: kind === "error" ? "#ee8ead" : "#85eee5"
    border.width: 1
    opacity: visible ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: 160 }
    }

    Text {
        id: messageText

        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        color: root.kind === "error" ? "#9b224d" : "#137e77"
        wrapMode: Text.WordWrap
        maximumLineCount: root.kind === "success" ? 5 : 3
        elide: Text.ElideRight
        font.pixelSize: 14
        font.weight: Font.Medium
    }
}
