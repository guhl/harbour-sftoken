import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property string pin
    property bool acceptEmpty: true

    Column {
        width: parent.width

        DialogHeader {
            title: "Enter PIN"
        }

        TextField {
            id: tokenPIN
            width: parent.width
            placeholderText: "Enter 4-8 digits PIN"
            label: "PIN"
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhDigitsOnly
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            pin = tokenPIN.text
        }
    }
}
