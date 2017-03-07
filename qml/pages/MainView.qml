/*
  Copyright (C) 2017 Guhl.
  Contact: Guhl <guhl@dershampoonierte.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.notifications 1.0
import "../components"

Page {
    id: mainPage

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    property double lastUpdated: 0
    property double tokenInterval: 60
    property bool pinEntered: false
    property bool firstInit: true

    function refreshToken() {
        if (firstInit && !stoken.initialized) {
            stoken.token_init()
            firstInit = false
            if (stoken.initialized) {
                pageStack.clear()
                pageStack.push(Qt.resolvedUrl("MainView.qml"))
            }
        } else {
        var curDate = new Date();
        var seconds_global = curDate.getSeconds() % tokenInterval
            if (stoken.initialized) {
                if (!pinEntered) {
                    var dialog = pageStack.push(Qt.resolvedUrl("../components/PinDialog.qml"))
                    dialog.accepted.connect(function() {
                                            stoken.pin = dialog.pin
                                        })
                    pinEntered = true
                }
                label_token.text = stoken.token_string
                tokenInterval = stoken.token_interval
                label_r2c1.text = stoken.next_token_string
                if (stoken.token_uses_pin)
                    label_r2c2.text = "Yes"
                else
                    label_r2c2.text = "No"
                label_r4c1.text = stoken.token_serial
                label_r4c2.text = stoken.expiration_date
                // Update the Progressbar
                updateProgress.value = tokenInterval - 1 - seconds_global
            }
        }
        // Set lastUpdate property
        lastUpdated = curDate.getTime();
    }

    function fileSelected(filename) {
        console.log("###", filename)
        var rc = stoken.importToken(filename)
        if (rc)
            stoken.token_init()
        pageStack.clear()
    }

    Notification {
        id: notification
    }

    function notify(message) {
        notification.previewBody = message;
        notification.previewSummary = "SFToken";
        notification.close();
        notification.publish();
    }

    Timer {
      interval: 1000
      // Timer only runs when app is acitive and we have a token
      running: Qt.application.active
      repeat: true
      onTriggered: refreshToken();
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Import Token")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ImportToken.qml"), {
                                       homePath: "/home/nemo",
                                       showFormat: true,
                                       title: "Select sdtid file",
                                       callback: fileSelected
                                   })
                }
            }
            MenuItem {
                visible: (Qt.application.active && stoken.initialized)
                text: qsTr("Enter Pin")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("../components/PinDialog.qml"))
                    dialog.accepted.connect(function() {
                                            stoken.pin = dialog.pin
                                        })
                    pinEntered = true
                }
            }
        }

        ProgressBar {
          id: updateProgress
          width: parent.width
          maximumValue: tokenInterval
          anchors.top: parent.top
          anchors.topMargin: 72 * Theme.pixelRatio
          // Only show when there are enries
          visible: (Qt.application.active && stoken.initialized)
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column_empty
            visible: (!stoken.initialized && !firstInit)
            width: parent.width - 8
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Sailfish RSA Token")
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("No Token initialized")
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
            }
            Label {
                wrapMode: Text.Wrap
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Choose 'Import Token' from the menu to import a new token. Select a valid SDTID file from the following file system browser.")
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }

        Column {
            id: column
            visible: (stoken.initialized)
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 16
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Sailfish RSA Token")
            }
            Label {
                id: label_token
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Current Token")
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
            }
            Button {
                id: button_copy
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthLarge
                text: qsTr("Copy")
                onClicked: {
                  Clipboard.text = label_token.text
                  notify(qsTr("Token copied to clipboard"));
                }
            }
            Grid {
                id: grid
                width: parent.width
                columns: 2
                Label {
                    id: label_r1c1
                    width: parent.width / 2
                    text: qsTr("Next tokencode:")
                    font.pixelSize: Theme.fontSizeMedium
                }
                Label {
                    id: label_r1c2
                    width: parent.width / 2
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("Token uses PIN:")
                    font.pixelSize: Theme.fontSizeMedium
                }
                Label {
                    id: label_r2c1
                    width: parent.width / 2
                    text: qsTr("")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                }
                Label {
                    id: label_r2c2
                    width: parent.width / 2
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                }
                Label {
                    id: label_r3c1
                    width: parent.width / 2
                    text: qsTr("Token S/N:")
                    font.pixelSize: Theme.fontSizeMedium
                }
                Label {
                    id: label_r3c2
                    width: parent.width / 2
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("Expiration Date:")
                    font.pixelSize: Theme.fontSizeMedium
                }
                Label {
                    id: label_r4c1
                    width: parent.width / 2
                    text: qsTr("")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                }
                Label {
                    id: label_r4c2
                    width: parent.width / 2
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                }
            }
        }
    }
}

