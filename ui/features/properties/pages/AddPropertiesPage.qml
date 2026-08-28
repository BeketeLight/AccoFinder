import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule

Page {
    id: root

    property int currentStep: 0

    // Each step's page is taller than the viewport, so the outer Flickable gets
    // scrolled down to reach "Continue". Reset it back to the top whenever the
    // step changes so the next page opens at its start (not scrolled to the bottom).
    onCurrentStepChanged: wizardFlick.contentY = 0

    readonly property bool hasRoomsStep: infoStep.needsRooms

    function stepTitleFor(i) {
        if (infoStep.needsRooms)
            return [qsTr("Information"), qsTr("Rooms"), qsTr("Photos"), qsTr("Review")][i]
        return [qsTr("Information"), qsTr("Photos"), qsTr("Review")][i]
    }

    function stepHintFor(i) {
        if (infoStep.needsRooms)
            return [
                qsTr("Name, type, location, landlord and pricing."),
                qsTr("Add every bookable room with its own price."),
                qsTr("Upload photos and choose the primary cover."),
                qsTr("Confirm the details, then submit or save a draft.")
            ][i]
        return [
            qsTr("Name, type, location and landlord."),
            qsTr("Upload photos and choose the primary cover."),
            qsTr("Confirm the details, then submit or save a draft.")
        ][i]
    }

    function totalSteps() {
        return infoStep.needsRooms ? 4 : 3
    }

    // Whole-property listings have no per-room step, so the rooms page is
    // omitted from the StackLayout; map the logical step to its physical index.
    function stepStackIndexFor(step) {
        if (infoStep.needsRooms)
            return step
        return step >= 1 ? step + 1 : step
    }

    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color pageColor: "#FFFFFF"
    property color surfaceColor: "#F5F5F5"
    property color softBlueColor: "#EFF6FF"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"

    signal propertySubmitted(var payload)
    signal draftSaved(var payload)
    signal registrationFinished(var payload)

    property var lastPayload: null

    property string pageTitle: qsTr("Add Property")
    property bool showBack: true
    property bool showHeader: true

    function goBack() {
        if (currentStep > 0) {
            currentStep -= 1
            stepStack.currentIndex = root.stepStackIndexFor(currentStep)
            return
        }
        UtilsModule.NavigationUtils.pop()
    }

    anchors.fill: parent

    background: Rectangle {
        color: root.pageColor
    }

    Flickable {
        id: wizardFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 56
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        ColumnLayout {
            id: contentColumn
            width: Math.min(parent.width - 40, 480)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 24
            spacing: 20

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: introColumn.implicitHeight + 36
                radius: 18
                color: root.softBlueColor
                border.color: "#DBEAFE"
                border.width: 1

                ColumnLayout {
                    id: introColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 5

                    Label {
                        text: qsTr("List a new property")
                        color: root.textColor
                        font.pixelSize: 25
                        font.bold: true
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Label {
                        text: qsTr("A guided flow from property details to verification.")
                        color: root.mutedColor
                        font.pixelSize: 13
                        lineHeight: 1.12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: root.totalSteps()

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: index <= root.currentStep ? root.primaryColor : root.borderColor

                            Behavior on color {
                                ColorAnimation {
                                    duration: 160
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: root.stepTitleFor(root.currentStep)
                        color: root.textColor
                        font.pixelSize: 14
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.preferredWidth: 58
                        Layout.preferredHeight: 28
                        radius: 14
                        color: root.currentStep === root.totalSteps() - 1 ? "#ECFDF5" : root.softBlueColor
                        border.color: root.currentStep === root.totalSteps() - 1 ? "#BBF7D0" : "#BFDBFE"

                        Label {
                            anchors.centerIn: parent
                            text: (root.currentStep + 1) + qsTr(" of ") + root.totalSteps()
                            color: root.currentStep === root.totalSteps() - 1 ? "#166534" : root.primaryColor
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }

                Label {
                    text: root.stepHintFor(root.currentStep)
                    color: root.mutedColor
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: stepStack.implicitHeight + 30
                radius: 16
                color: root.pageColor
                border.color: root.borderColor
                border.width: 1

                StackLayout {
                    id: stepStack
                    anchors.fill: parent
                    anchors.margins: 15
                    currentIndex: root.stepStackIndexFor(root.currentStep)

                    PropertyInfoPage {
                        id: infoStep
                        primaryColor: root.primaryColor
                        secondaryColor: root.secondaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        errorColor: "#EF4444"
                        Layout.fillWidth: true
                        onNextRequested: root.currentStep = 1
                    }

                    PropertyRoomsPage {
                        id: roomsStep
                        primaryColor: root.primaryColor
                        secondaryColor: root.secondaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        errorColor: "#EF4444"
                        Layout.fillWidth: true
                        onNextRequested: root.currentStep = 2
                    }

                    PropertyPhotosPage {
                        id: photosStep
                        roomsModelRef: roomsStep.roomsModel
                        primaryColor: root.primaryColor
                        secondaryColor: root.secondaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        errorColor: "#EF4444"
                        Layout.fillWidth: true
                        onNextRequested: root.currentStep = infoStep.needsRooms ? 3 : 2
                    }

                    PropertyReviewPage {
                        id: reviewStep
                        titleValue: infoStep.titleValue
                        districtValue: infoStep.districtValue
                        villageValue: infoStep.villageValue
                        amenitiesValue: infoStep.amenitiesValue
                        landlordValue: infoStep.landlordValue
                        landlordPhoneValue: infoStep.landlordPhoneValue
                        priceValue: infoStep.priceValue
                        descriptionValue: infoStep.descriptionValue
                        roomsModelRef: roomsStep.roomsModel
                        photosModelRef: photosStep.photosModel
                        primaryColor: root.primaryColor
                        secondaryColor: root.secondaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        Layout.fillWidth: true
                        onSubmitRequested: root.submitProperty()
                        onDraftRequested: root.saveDraft()
                    }
                }
            }

            Button {
                id: previousStepButton
                text: qsTr("Back to previous step")
                visible: root.currentStep > 0
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 48 : 0

                contentItem: Text {
                    text: previousStepButton.text
                    color: root.primaryColor
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 12
                    color: previousStepButton.down ? root.softBlueColor : root.pageColor
                    border.color: root.primaryColor
                    border.width: 1
                }

                onClicked: root.goBack()
            }
        }
    }

    Rectangle {
        id: successOverlay
        visible: false
        anchors.fill: parent
        color: Qt.rgba(1, 1, 1, 0.96)
        z: 100

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 14

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 72
                Layout.preferredHeight: 72
                radius: 36
                color: "#16A34A"

                Label {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "#FFFFFF"
                    font.pixelSize: 34
                    font.bold: true
                }
            }

            Label {
                id: successTitleLabel
                Layout.alignment: Qt.AlignHCenter
                text: ""
                color: root.textColor
                font.pixelSize: 18
                font.bold: true
            }

            Label {
                id: successMessageLabel
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 280
                text: ""
                color: root.mutedColor
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

        Timer {
            id: successTimer
            interval: 1400
            onTriggered: root.registrationFinished(root.lastPayload)
        }
    }

    // Payload mirrors the backend Property schema:
    // title, description, physicalAddress{district,village}, verificationStatus,
    // amenities[], isActive — plus client extras (price/landlord) and room/media refs.
    function buildPayload(status, verificationStatus) {
        var rooms = []
        for (var i = 0; i < roomsStep.roomsModel.count; i++) {
            var r = roomsStep.roomsModel.get(i)
            rooms.push({ roomId: r.roomId, roomType: r.roomType, price: r.price, available: r.available })
        }
        var photos = []
        for (var j = 0; j < photosStep.photosModel.count; j++) {
            var p = photosStep.photosModel.get(j)
            photos.push({ path: p.path, isPrimary: p.isPrimary, roomId: p.roomId })
        }
        return {
            title: infoStep.titleValue,
            description: infoStep.descriptionValue,
            owner: AppSettings.isLoggedIn() ? AppSettings.userName() : "",
            propertyType: infoStep.propertyTypeValue,
            physicalAddress: {
                district: infoStep.districtValue,
                village: infoStep.villageValue
            },
            verificationStatus: verificationStatus,
            amenities: infoStep.amenitiesValue,
            isActive: true,
            price: infoStep.priceValue,
            landlord: infoStep.landlordValue,
            landlordPhone: infoStep.landlordPhoneValue,
            rooms: rooms,
            photos: photos
        }
    }

    function submitProperty() {
        var payload = root.buildPayload("Pending", "PENDING")
        root.lastPayload = payload
        root.propertySubmitted(payload)
        showSuccess(qsTr("Submitted for verification"),
                    qsTr("The verification team has been notified. You can track progress from your properties list."))
    }

    function saveDraft() {
        var payload = root.buildPayload("Draft", "")
        root.lastPayload = payload
        root.draftSaved(payload)
        showSuccess(qsTr("Draft saved"),
                    qsTr("You can complete this property anytime from Properties requiring attention."))
    }

    function showSuccess(title, message) {
        successTitleLabel.text = title
        successMessageLabel.text = message
        successOverlay.visible = true
        successTimer.restart()
    }
}
