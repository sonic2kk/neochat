import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import Qt.labs.qmlmodels 1.0

import Spectral.Component 2.0
import Spectral.Component.Emoji 2.0
import Spectral.Component.Timeline 2.0
import Spectral.Effect 2.0

import Spectral 0.1
import Spectral.Setting 0.1
import SortFilterProxyModel 0.2

Item {
    property var currentRoom: null

    id: root

    MessageEventModel {
        id: messageEventModel
        room: currentRoom
    }

    RoomDrawer {
        width: Math.min(root.width * 0.7, 480)
        height: root.height

        id: roomDrawer

        room: currentRoom
    }

    Label {
        anchors.centerIn: parent
        visible: !currentRoom
        text: "Please choose a room."
    }

    Image {
        anchors.fill: parent

        visible: currentRoom && MSettings.enableTimelineBackground

        source: MSettings.timelineBackground || MSettings.darkTheme ? "qrc:/assets/img/roompanel-dark.svg" : "qrc:/assets/img/roompanel.svg"
        fillMode: Image.PreserveAspectCrop
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        visible: currentRoom

        RoomHeader {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            z: 10

            id: roomHeader

            avatar: currentRoom ? currentRoom.avatarMediaId : ""
            topic: currentRoom ? (currentRoom.topic).replace(/(\r\n\t|\n|\r\t)/gm,"") : ""
            atTop: messageListView.atYBeginning

            onClicked: roomDrawer.open()
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: 960
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 16
            Layout.alignment: Qt.AlignHCenter

            spacing: 16

            AutoListView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                id: messageListView

                spacing: 4

                displayMarginBeginning: 100
                displayMarginEnd: 100
                verticalLayoutDirection: ListView.BottomToTop
                highlightMoveDuration: 500

                boundsBehavior: Flickable.DragOverBounds

                model: SortFilterProxyModel {
                    id: sortedMessageEventModel

                    sourceModel: messageEventModel

                    filters: ExpressionFilter {
                        expression: marks !== 0x10 && eventType !== "other"
                    }

                    onModelReset: {
                        if (currentRoom) {
                            var lastScrollPosition = sortedMessageEventModel.mapFromSource(currentRoom.savedTopVisibleIndex())
                            messageListView.currentIndex = lastScrollPosition
                            if (messageListView.contentY < messageListView.originY + 10 || currentRoom.timelineSize < 20)
                                currentRoom.getPreviousContent(50)
                        }
                    }
                }

                property int largestVisibleIndex: count > 0 ? indexAt(contentX, contentY + height - 1) : -1

                onContentYChanged: {
                    if(currentRoom && contentY  - 5000 < originY)
                        currentRoom.getPreviousContent(20);
                }

                displaced: Transition {
                    NumberAnimation {
                        property: "y"; duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                delegate: DelegateChooser {
                    role: "eventType"

                    DelegateChoice {
                        roleValue: "state"
                        delegate: ColumnLayout {
                            width: messageListView.width
                            spacing: 4

                            SectionDelegate {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.margins: 16

                                visible: section !== aboveSection || Math.abs(time - aboveTime) > 600000
                            }

                            StateDelegate {
                                Layout.maximumWidth: parent.width
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    DelegateChoice {
                        roleValue: "emote"
                        delegate: ColumnLayout {
                            width: messageListView.width
                            spacing: 4

                            SectionDelegate {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.margins: 16

                                visible: section !== aboveSection || Math.abs(time - aboveTime) > 600000
                            }

                            StateDelegate {
                                Layout.maximumWidth: parent.width
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    DelegateChoice {
                        roleValue: "message"
                        delegate: ColumnLayout {
                            width: messageListView.width
                            spacing: 4

                            SectionDelegate {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.margins: 16

                                visible: section !== aboveSection || Math.abs(time - aboveTime) > 600000
                            }

                            MessageDelegate {
                            }
                        }
                    }

                    DelegateChoice {
                        roleValue: "notice"
                        delegate: ColumnLayout {
                            width: messageListView.width
                            spacing: 4

                            SectionDelegate {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.margins: 16

                                visible: section !== aboveSection || Math.abs(time - aboveTime) > 600000
                            }

                            MessageDelegate {
                            }
                        }
                    }

                    DelegateChoice {
                        roleValue: "image"
                        delegate: ColumnLayout {
                            width: messageListView.width
                            spacing: 4

                            SectionDelegate {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.margins: 16

                                visible: section !== aboveSection || Math.abs(time - aboveTime) > 600000
                            }

                            ImageDelegate {
                                Layout.maximumWidth: parent.width
                            }
                        }
                    }

                    DelegateChoice {
                        roleValue: "file"
                        delegate: ColumnLayout {
                            width: messageListView.width
                            spacing: 4

                            SectionDelegate {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.margins: 16

                                visible: section !== aboveSection || Math.abs(time - aboveTime) > 600000
                            }

                            FileDelegate {
                                Layout.maximumWidth: parent.width
                            }
                        }
                    }
                }

                RoundButton {
                    width: 64
                    height: 64
                    anchors.right: parent.right
                    anchors.top: parent.top

                    id: goBottomFab

                    visible: currentRoom && currentRoom.hasUnreadMessages

                    contentItem: MaterialIcon {
                        anchors.fill: parent

                        icon: "\ue316"
                        color: "white"
                    }

                    Material.background: Material.accent

                    onClicked: goToEvent(currentRoom.readMarkerEventId)
                }

                RoundButton {
                    width: 64
                    height: 64
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    id: goTopFab

                    visible: !messageListView.atYEnd

                    contentItem: MaterialIcon {
                        anchors.fill: parent

                        icon: "\ue313"
                        color: "white"
                    }

                    Material.background: Material.accent

                    onClicked: messageListView.positionViewAtBeginning()
                }

                Popup {
                    property string sourceText

                    anchors.centerIn: parent
                    width: 480

                    id: sourceDialog

                    parent: ApplicationWindow.overlay

                    padding: 16

                    closePolicy: Dialog.CloseOnEscape | Dialog.CloseOnPressOutside

                    contentItem: ScrollView {
                        clip: true
                        TextArea {
                            readOnly: true
                            selectByMouse: true

                            text: sourceDialog.sourceText
                        }
                    }
                }

                Popup {
                    property alias listModel: readMarkerListView.model

                    x: (window.width - width) / 2
                    y: (window.height - height) / 2
                    width: 320

                    id: readMarkerDialog

                    parent: ApplicationWindow.overlay

                    modal: true
                    padding: 16

                    closePolicy: Dialog.CloseOnEscape | Dialog.CloseOnPressOutside

                    contentItem: AutoListView {
                        implicitHeight: Math.min(window.height - 64,
                                                 readMarkerListView.contentHeight)

                        id: readMarkerListView

                        clip: true
                        boundsBehavior: Flickable.DragOverBounds

                        delegate: ItemDelegate {
                            width: parent.width
                            height: 48

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 12

                                Avatar {
                                    Layout.preferredWidth: height
                                    Layout.fillHeight: true

                                    source: modelData.avatar
                                    hint: modelData.displayName
                                }

                                Label {
                                    Layout.fillWidth: true

                                    text: modelData.displayName
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {}
                    }
                }
            }

            Control {
                Layout.maximumWidth: parent.width * 0.8

                visible: currentRoom && currentRoom.hasUsersTyping
                padding: 8

                contentItem: RowLayout {
                    spacing: 8

                    Repeater {
                        model: currentRoom && currentRoom.hasUsersTyping ? currentRoom.usersTyping : null

                        delegate: Avatar {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24

                            source: modelData.avatarMediaId
                            hint: modelData.displayName
                        }
                    }

                    BusyIndicator {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                    }
                }

                background: Rectangle {
                    color: MPalette.banner
                    radius: height / 2
                }
            }

            RoomPanelInput {
                Layout.fillWidth: true

                id: roomPanelInput
            }
        }
    }

    function goToEvent(eventID) {
        var index = messageEventModel.eventIDToIndex(eventID)
        if (index === -1) return
        //        messageListView.currentIndex = sortedMessageEventModel.mapFromSource(index)
        messageListView.positionViewAtIndex(sortedMessageEventModel.mapFromSource(index), ListView.Contain)
    }

    function saveReadMarker(room) {
        var readMarker = sortedMessageEventModel.get(messageListView.largestVisibleIndex).eventId
        if (!readMarker) return
        room.readMarkerEventId = readMarker
        currentRoom.saveViewport(sortedMessageEventModel.mapToSource(messageListView.indexAt(messageListView.contentX, messageListView.contentY)), sortedMessageEventModel.mapToSource(messageListView.largestVisibleIndex))
    }
}
