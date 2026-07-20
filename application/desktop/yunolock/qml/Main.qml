import QtQuick.Controls
import "components"

ApplicationWindow {
    id: window

    width: 1180
    height: 760
    minimumWidth: 900
    minimumHeight: 620
    visible: true
    title: "YunoLock"
    color: "#130d18"

    AuthScreen {
        anchors.fill: parent
        auth: authViewModel
        backgroundSource: "qrc:/resources/images/background.webp"
        mascotNormalSource: "qrc:/resources/images/mascot_normal.png"
        mascotPoutSource: "qrc:/resources/images/mascot_pout.png"
        mascotSadSource: "qrc:/resources/images/mascot_sad.png"
    }
}
