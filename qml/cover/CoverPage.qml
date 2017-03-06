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

CoverBackground {
    id: coverPage

    property double lastUpdated: 0
    property double tokenInterval: 60

    function refreshToken() {
        var curDate = new Date();
        var seconds_global = curDate.getSeconds() % tokenInterval
        label_token.text = stoken.token_string
        tokenInterval = stoken.token_interval
        // Update the Progressbar
        updateProgress.value = tokenInterval - 1 - seconds_global
        // Set lastUpdate property
        lastUpdated = curDate.getTime();
    }

    Timer {
      interval: 1000
      // Timer only runs when app is inactive and we have a token
      running: !Qt.application.active
      repeat: true
      onTriggered: refreshToken();
    }

    // Show the Logo
    Image {
      id: logo
      source: "../harbour-sftoken.png"
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 48
    }

    ProgressBar {
    id: updateProgress
    width: parent.width
    maximumValue: tokenInterval
    anchors.top: parent.top
    anchors.topMargin: 72 * Theme.pixelRatio
    // Only show when there are enries
    visible: (!Qt.application.active && stoken.initialized)
    }

    Column {
      anchors.top: logo.bottom
      width: parent.width
      spacing: Theme.paddingLarge
      anchors.topMargin: 48 * Theme.pixelRatio
      visible: (!Qt.application.active && stoken.initialized)

        Label {
            id: label_token
            text: qsTr("No Token")
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeExtraLarge
        }
    }
}

