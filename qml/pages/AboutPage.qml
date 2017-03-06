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

Page {
  id: aboutPage

  allowedOrientations: Orientation.All

  SilicaFlickable {
    id: flickable
    anchors.fill: parent
    width: parent.width
    contentHeight: column.height

    Column {
      id: column
      width: parent.width
      spacing: Theme.paddingLarge

      Image {
        id: logo
        source: "../harbour-sftoken.png"
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
      }
      Label {
        id: name
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        text: "SFToken " + Qt.application.version
      }
      TextArea {
        id: desc
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: TextEdit.Center
        readOnly: true
        text:  qsTr("A simple Sailfish OS tokencode generator compatible with RSA SecurID 128-bit (AES) tokens")
        color: "white"
      }
      TextArea {
        id: copyright
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: TextEdit.Center
        readOnly: true
        text: qsTr("Copyright: Guhl\nLicense: BSD (3-clause)")
        color: "white"
      }
      Button {
        id: homepage
        anchors.horizontalCenter: parent.horizontalCenter
        text: '<a href=\"https://github.com/guhl/harbour-sftoken">Source Code</a>'
        onClicked: {
          Qt.openUrlExternally("https://github.com/guhl/harbour-sftoken")
        }
      }
      TextArea {
        id: acknowledgement
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: TextEdit.Center
        readOnly: true
        text: qsTr("SFToken is based on the stoken library created by cernekee:")+"\n\nhttps://github.com/cernekee/stoken"
        color: "white"
      }

    }
    VerticalScrollDecorator { }
  }
}
