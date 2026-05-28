pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property url normalSource
    property url poutSource
    property url sadSource
    property string mood: "normal"
    property bool unlocked: false
    property real vanishOpacity: 1
    property real vanishX: 0
    property real vanishY: 0
    property real vanishScale: 1
    property real reactionHop: 0
    property real reactionTilt: 0
    property int burstSerial: 0
    property bool successBurst: false
    property bool goneForever: false

    function playReaction(nextMood, shouldVanish, intensity, autoRestore) {
        if (goneForever) {
            return
        }

        resetTimer.stop()
        vanishSequence.stop()
        vanishOpacity = 1
        vanishX = 0
        vanishY = 0
        vanishScale = 1
        reactionHop = 0
        reactionTilt = 0
        mood = nextMood
        successBurst = false
        burstSerial += 1
        hopSequence.intensity = Math.max(1, intensity)
        hopSequence.restart()

        if (shouldVanish) {
            vanishSequence.restart()
        } else if (autoRestore) {
            resetTimer.restart()
        }
    }

    function restoreNormal() {
        if (goneForever) {
            return
        }

        resetTimer.stop()
        vanishSequence.stop()
        vanishOpacity = 1
        vanishX = 0
        vanishY = 0
        vanishScale = 1
        reactionHop = 0
        reactionTilt = 0
        successBurst = false
        mood = "normal"
    }

    function playSuccess() {
        if (goneForever) {
            return
        }

        resetTimer.stop()
        vanishSequence.stop()
        vanishOpacity = 1
        vanishX = 0
        vanishY = 0
        vanishScale = 1
        reactionHop = 0
        reactionTilt = 0
        mood = "success"
        successBurst = true
        burstSerial += 1
        successHop.restart()
    }

    function playFinalExit() {
        resetTimer.stop()
        vanishSequence.stop()
        hopSequence.stop()
        finalExitSequence.stop()
        goneForever = true
        vanishOpacity = 1
        vanishX = 0
        vanishY = 0
        vanishScale = 1
        reactionHop = 0
        reactionTilt = 0
        successBurst = false
        mood = "sad"
        burstSerial += 1
        finalExitSequence.restart()
    }

    Item {
        id: characterLayer
        anchors.fill: parent
        opacity: root.unlocked ? 0.3 : root.vanishOpacity
        x: root.vanishX
        y: root.vanishY + root.reactionHop + Math.sin(breathe.value) * 5
        rotation: root.reactionTilt
        scale: root.vanishScale * (1 + Math.sin(breathe.value) * 0.012)

        Behavior on opacity {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }

        Image {
            anchors.centerIn: mascotNormal
            width: mascotNormal.paintedWidth * 0.92
            height: mascotNormal.paintedHeight * 0.82
            source: root.mood === "sad" ? root.sadSource : root.normalSource
            fillMode: Image.PreserveAspectFit
            opacity: 0.20
            scale: 1.045
            smooth: true
        }

        Image {
            id: mascotNormal
            anchors.fill: parent
            source: root.normalSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: root.mood === "normal" || root.mood === "success" ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 190; easing.type: Easing.OutCubic }
            }
        }

        Image {
            anchors.fill: parent
            source: root.poutSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: root.mood === "pout" ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 190; easing.type: Easing.OutCubic }
            }
        }

        Image {
            anchors.fill: parent
            source: root.sadSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: root.mood === "sad" ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 190; easing.type: Easing.OutCubic }
            }
        }
    }

    Item {
        id: burstLayer
        anchors.fill: parent
        z: 2

        Repeater {
            model: 18

            Text {
                id: petal

                required property int index
                property real originX: root.width * (0.46 + Math.random() * 0.18)
                property real originY: root.height * (0.26 + Math.random() * 0.18)
                property real spreadX: (Math.random() - 0.5) * root.width * 0.52
                property real spreadY: -root.height * (0.08 + Math.random() * 0.26)

                text: root.successBurst ? (index % 4 === 0 ? "chu" : index % 3 === 0 ? "♥" : "♡") : (index % 5 === 0 ? "♡" : "✦")
                color: root.successBurst ? (index % 3 === 0 ? "#ff5f9d" : "#ffd1e4") : (index % 5 === 0 ? "#ff9fc5" : "#9ff7ee")
                font.pixelSize: root.successBurst ? (index % 4 === 0 ? 16 : 21) : (index % 5 === 0 ? 18 : 14)
                opacity: 0
                x: originX
                y: originY
                rotation: Math.random() * 120 - 60

                SequentialAnimation {
                    id: petalBurst

                    PauseAnimation { duration: petal.index * 22 }
                    ParallelAnimation {
                        NumberAnimation { target: petal; property: "opacity"; from: 0; to: 0.88; duration: 90 }
                        NumberAnimation { target: petal; property: "x"; from: petal.originX; to: petal.originX + petal.spreadX; duration: 680; easing.type: Easing.OutCubic }
                        NumberAnimation { target: petal; property: "y"; from: petal.originY; to: petal.originY + petal.spreadY; duration: 680; easing.type: Easing.OutCubic }
                        NumberAnimation { target: petal; property: "rotation"; to: petal.rotation + 120 + petal.index * 9; duration: 680; easing.type: Easing.OutCubic }
                    }
                    NumberAnimation { target: petal; property: "opacity"; to: 0; duration: 220 }
                }

                Connections {
                    target: root

                    function onBurstSerialChanged() {
                        petal.originX = root.width * (root.successBurst ? (0.42 + Math.random() * 0.24) : (0.46 + Math.random() * 0.18))
                        petal.originY = root.height * (root.successBurst ? (0.18 + Math.random() * 0.22) : (0.26 + Math.random() * 0.18))
                        petal.spreadX = (Math.random() - 0.5) * root.width * (root.successBurst ? 0.76 : 0.52)
                        petal.spreadY = -root.height * (root.successBurst ? (0.16 + Math.random() * 0.34) : (0.08 + Math.random() * 0.26))
                        petalBurst.restart()
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: hopSequence

        property real intensity: 1

        ParallelAnimation {
            NumberAnimation { target: root; property: "reactionHop"; to: -16 - hopSequence.intensity * 4; duration: 80; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "reactionTilt"; to: -2.5 - hopSequence.intensity; duration: 80; easing.type: Easing.OutCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "reactionHop"; to: 8 + hopSequence.intensity * 2; duration: 110; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "reactionTilt"; to: 2.2 + hopSequence.intensity * 0.6; duration: 110; easing.type: Easing.InCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "reactionHop"; to: -5; duration: 78; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "reactionTilt"; to: -1.2; duration: 78; easing.type: Easing.OutCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "reactionHop"; to: 0; duration: 120; easing.type: Easing.OutBack }
            NumberAnimation { target: root; property: "reactionTilt"; to: 0; duration: 120; easing.type: Easing.OutCubic }
        }
    }

    SequentialAnimation {
        id: successHop

        ParallelAnimation {
            NumberAnimation { target: root; property: "reactionHop"; to: -34; duration: 130; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "reactionTilt"; to: 5; duration: 130; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "vanishScale"; to: 1.055; duration: 130; easing.type: Easing.OutCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "reactionHop"; to: 8; duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "reactionTilt"; to: -3; duration: 150; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "vanishScale"; to: 0.985; duration: 150; easing.type: Easing.InCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "reactionHop"; to: -18; duration: 115; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "reactionTilt"; to: 2; duration: 115; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "vanishScale"; to: 1.035; duration: 115; easing.type: Easing.OutCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "reactionHop"; to: 0; duration: 260; easing.type: Easing.OutBack }
            NumberAnimation { target: root; property: "reactionTilt"; to: 0; duration: 260; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "vanishScale"; to: 1; duration: 260; easing.type: Easing.OutBack }
        }
    }

    Rectangle {
        width: Math.min(parent.width * 0.72, 320)
        height: 42
        radius: height / 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 26
        color: "#0b061240"
        opacity: root.vanishOpacity * (root.unlocked ? 0.25 : 1)
        scale: 1 + Math.sin(breathe.value) * 0.018
    }

    Timer {
        id: resetTimer
        interval: 1900
        repeat: false
        onTriggered: root.restoreNormal()
    }

    SequentialAnimation {
        id: vanishSequence

        ParallelAnimation {
            NumberAnimation { target: root; property: "vanishOpacity"; to: 0; duration: 280; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "vanishX"; to: 72; duration: 280; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "vanishY"; to: -42; duration: 280; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "vanishScale"; to: 0.9; duration: 280; easing.type: Easing.InCubic }
        }
        PauseAnimation { duration: 1450 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "vanishOpacity"; to: 1; duration: 430; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "vanishX"; to: 0; duration: 430; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "vanishY"; to: 0; duration: 430; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "vanishScale"; to: 1; duration: 430; easing.type: Easing.OutBack }
        }
    }

    SequentialAnimation {
        id: finalExitSequence

        ParallelAnimation {
            NumberAnimation { target: root; property: "reactionHop"; to: -32; duration: 140; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "reactionTilt"; to: -8; duration: 140; easing.type: Easing.OutCubic }
        }
        PauseAnimation { duration: 320 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "vanishOpacity"; to: 0; duration: 850; easing.type: Easing.InOutCubic }
            NumberAnimation { target: root; property: "vanishX"; to: 220; duration: 850; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "vanishY"; to: -120; duration: 850; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "vanishScale"; to: 0.72; duration: 850; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "reactionTilt"; to: 18; duration: 850; easing.type: Easing.InCubic }
        }
    }

    NumberAnimation {
        id: breathe
        property real value: 0
        from: 0
        to: Math.PI * 2
        duration: 4200
        loops: Animation.Infinite
        running: true
    }
}
