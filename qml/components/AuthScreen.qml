pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var auth
    property url backgroundSource
    property url mascotNormalSource
    property url mascotPoutSource
    property url mascotSadSource
    property string feedbackMessage: ""
    property real sceneShakeX: 0
    property real sceneShakeY: 0
    property real punishmentFlash: 0
    property bool punishmentCooldown: false
    property bool finalExit: false
    property bool successRewardPlaying: false

    readonly property bool compact: width < 980
    property bool unlocked: false

    readonly property var emptyMessages: [
        "Скажи секретную фразу, милый.",
        "Юно не откроет пустое обещание."
    ]
    readonly property var wrongMessages: [
        "М-м... это не наш маленький секрет.",
        "Еще раз, дорогой. Я знаю, ты помнишь.",
        "Нетушки. Теперь Юно дуется."
    ]
    readonly property var repeatedWrongMessages: [
        "Ошибся снова? Юно устроит маленькую месть.",
        "Нет. Ты потерял Юно на целых две секунды.",
        "Ай. Теперь Юно нужен драматичный выход."
    ]
    readonly property var lateWrongMessages: [
        "Офицер ФСБ, если вы не мой хозяин, не расстраивайте его. Он хороший. А секреты не отдам: они наши личные.",
        "Милый незнакомец, лапки прочь. Хозяин Юно хороший, а его секреты я берегу ревниво.",
        "Нет пароля - нет поцелуя от хранилища. Такая вот суровая романтика безопасности."
    ]
    readonly property string finalExitMessage: "На этом Юно ссылается на Первую, Четвертую и Пятую поправки к Конституции США, хранит молчание, защищает личные секреты и драматично покидает сцену."
    readonly property string successRewardMessage: "Да, это ты, любимый. Юно узнала твое прикосновение... твоя любимая хранительница открывает для тебя самое личное."

    function pickMessage(pool) {
        return pool[Math.floor(Math.random() * pool.length)]
    }

    function showFailure(code) {
        if (finalExit || successRewardPlaying) {
            return
        }

        if (code === "empty_password") {
            feedbackMessage = pickMessage(emptyMessages)
            mascot.playReaction("pout", false, 1)
            return
        }

        const attempts = root.auth.failedAttempts
        const finalAttempt = attempts >= 7
        const repeated = attempts >= 3
        const late = attempts >= 5
        const vanish = repeated && Math.random() < 0.88
        const sad = attempts >= 2 || Math.random() < 0.35

        if (finalAttempt) {
            feedbackMessage = finalExitMessage
            finalExit = true
            mascot.playFinalExit()
            screenShake.restart()
            finalPunishmentPulse.restart()
            return
        }

        feedbackMessage = pickMessage(late ? lateWrongMessages : (repeated ? repeatedWrongMessages : wrongMessages))
        mascot.playReaction(sad ? "sad" : "pout", vanish, Math.min(attempts, 4), false)

        if (attempts >= 2) {
            screenShake.restart()
        }

        if (attempts >= 3) {
            punishmentPulse.restart()
        }
    }

    function clearFeedback() {
        if (finalExit || successRewardPlaying) {
            return
        }

        feedbackMessage = ""
        mascot.restoreNormal()
        root.auth.clearError()
    }

    transform: Translate {
        x: root.sceneShakeX
        y: root.sceneShakeY
    }

    Image {
        id: backdrop
        anchors.fill: parent
        source: root.backgroundSource
        fillMode: Image.PreserveAspectCrop
        smooth: true
        scale: 1.035
        x: Math.sin(driftPhase.value) * 8
        y: Math.cos(driftPhase.value * 0.7) * 5
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#7a1838aa" }
            GradientStop { position: 0.45; color: "#120b18a8" }
            GradientStop { position: 1.0; color: "#21122bcc" }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#ff4f8d"
        opacity: root.punishmentFlash
    }

    Repeater {
        model: 22

        Rectangle {
            id: particle

            required property int index

            width: 4 + (index % 3)
            height: width
            radius: width / 2
            color: index % 4 === 0 ? "#9ff7ee" : "#ffc4dc"
            opacity: 0.18 + ((index % 5) * 0.04)
            x: (particle.index * 83) % Math.max(root.width, 1)
            y: root.height + 30

            SequentialAnimation on y {
                loops: Animation.Infinite
                PauseAnimation { duration: particle.index * 160 }
                NumberAnimation {
                    from: root.height + 36
                    to: -44
                    duration: 8200 + particle.index * 260
                    easing.type: Easing.InOutSine
                }
            }

            NumberAnimation on x {
                loops: Animation.Infinite
                from: ((particle.index * 83) % Math.max(root.width, 1)) - 18
                to: ((particle.index * 83) % Math.max(root.width, 1)) + 18
                duration: 2600 + particle.index * 90
                easing.type: Easing.InOutSine
            }
        }
    }

    MascotScene {
        id: mascot
        normalSource: root.mascotNormalSource
        poutSource: root.mascotPoutSource
        sadSource: root.mascotSadSource
        visible: !root.compact
        width: Math.min(Math.max(root.width * 0.34, root.height * 0.64), 780)
        height: root.height * 0.97
        anchors.right: parent.right
        anchors.rightMargin: Math.max(18, root.width * 0.035)
        anchors.bottom: parent.bottom
        unlocked: root.unlocked
    }

    Rectangle {
        id: panelShadow
        width: authPanel.width
        height: authPanel.height
        radius: 30
        x: authPanel.x + 18
        y: authPanel.y + 24
        color: "#05020a70"
    }

    Rectangle {
        id: authPanel
        width: root.compact ? Math.min(root.width - 64, 520) : 450
        height: 474
        radius: 30
        anchors.left: parent.left
        anchors.leftMargin: root.compact ? (root.width - width) / 2 : Math.max(70, root.width * 0.075)
        anchors.verticalCenter: parent.verticalCenter
        color: "#fff6fbdd"
        border.color: "#ffd3e8"
        border.width: 1
        antialiasing: true
        opacity: root.unlocked ? 0 : 1

        Behavior on opacity {
            NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 34
            spacing: 18

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 88

                Text {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    text: "YunoLock"
                    color: "#211421"
                    font.pixelSize: 40
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    width: 44
                    height: 44
                    radius: 16
                    color: "#ddfff9"
                    border.color: "#80f2e6"

                    Text {
                        anchors.centerIn: parent
                        text: "◇"
                        color: "#17bfb1"
                        font.pixelSize: 25
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    text: root.auth.vaultName + " · доступ по мастер-фразе"
                    color: "#8b6473"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                }
            }

            PasswordField {
                id: passwordInput
                Layout.fillWidth: true
                enabled: !root.auth.isUnlocking && !root.unlocked && !root.finalExit && !root.successRewardPlaying
                errorText: root.successRewardPlaying ? "" : root.feedbackMessage
                capsLockActive: root.auth.capsLockActive
                onAccepted: unlockButton.trigger()
                onEdited: root.clearFeedback()
            }

            StatusToast {
                Layout.fillWidth: true
                text: root.feedbackMessage
                kind: root.successRewardPlaying ? "success" : "error"
                visible: root.feedbackMessage.length > 0
                Layout.preferredHeight: visible ? Math.min(root.successRewardPlaying ? 142 : 112, implicitHeight) : 0
            }

            Item { Layout.fillHeight: true }

            UnlockButton {
                id: unlockButton
                Layout.fillWidth: true
                text: root.finalExit ? "Юно ушла" : (root.successRewardPlaying ? "Юно открывается" : (root.auth.isUnlocking ? "Разблокирую" : "Разблокировать"))
                busy: root.auth.isUnlocking
                enabled: !root.auth.isUnlocking && !root.unlocked && !root.punishmentCooldown && !root.finalExit && !root.successRewardPlaying

                onClicked: trigger()

                function trigger() {
                    root.auth.unlock(passwordInput.password)
                }
            }

            Text {
                Layout.fillWidth: true
                text: "Демо-фраза: sakura"
                color: "#a77b8d"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 13
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#ffeaf4"
        opacity: root.unlocked ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 460; easing.type: Easing.OutCubic }
        }

            Text {
                anchors.centerIn: parent
            text: "Юно открыла тебе свои секреты."
            color: "#231520"
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
    }

    NumberAnimation {
        id: driftPhase
        property real value: 0
        target: driftPhase
        property: "value"
        from: 0
        to: Math.PI * 2
        duration: 15000
        loops: Animation.Infinite
        running: true
    }

    SequentialAnimation {
        id: screenShake

        ParallelAnimation {
            NumberAnimation { target: root; property: "sceneShakeX"; to: -12; duration: 28 }
            NumberAnimation { target: root; property: "sceneShakeY"; to: 4; duration: 28 }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "sceneShakeX"; to: 14; duration: 32 }
            NumberAnimation { target: root; property: "sceneShakeY"; to: -5; duration: 32 }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "sceneShakeX"; to: -8; duration: 34 }
            NumberAnimation { target: root; property: "sceneShakeY"; to: 3; duration: 34 }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "sceneShakeX"; to: 5; duration: 34 }
            NumberAnimation { target: root; property: "sceneShakeY"; to: -2; duration: 34 }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "sceneShakeX"; to: 0; duration: 46; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "sceneShakeY"; to: 0; duration: 46; easing.type: Easing.OutCubic }
        }
    }

    SequentialAnimation {
        id: punishmentPulse

        PropertyAction { target: root; property: "punishmentCooldown"; value: true }
        NumberAnimation { target: root; property: "punishmentFlash"; from: 0; to: 0.16; duration: 70 }
        NumberAnimation { target: root; property: "punishmentFlash"; to: 0; duration: 340; easing.type: Easing.OutCubic }
        PauseAnimation { duration: 520 }
        PropertyAction { target: root; property: "punishmentCooldown"; value: false }
    }

    SequentialAnimation {
        id: finalPunishmentPulse

        PropertyAction { target: root; property: "punishmentCooldown"; value: true }
        NumberAnimation { target: root; property: "punishmentFlash"; from: 0; to: 0.28; duration: 90 }
        NumberAnimation { target: root; property: "punishmentFlash"; to: 0.04; duration: 420; easing.type: Easing.OutCubic }
    }

    SequentialAnimation {
        id: successReward

        PropertyAction { target: root; property: "successRewardPlaying"; value: true }
        NumberAnimation { target: root; property: "punishmentFlash"; from: 0; to: 0.12; duration: 140; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "punishmentFlash"; to: 0; duration: 520; easing.type: Easing.OutCubic }
        PauseAnimation { duration: 4000 }
        PropertyAction { target: root; property: "unlocked"; value: true }
    }

    Connections {
        target: root.auth

        function onUnlockFailed(reason) {
            passwordInput.clearPassword()
            passwordInput.focusPassword()
            root.showFailure(reason)
        }

        function onUnlockSucceeded() {
            passwordInput.clearPassword()
            root.feedbackMessage = root.successRewardMessage
            mascot.playSuccess()
            successReward.restart()
        }
    }

    Component.onCompleted: passwordInput.focusPassword()
}
