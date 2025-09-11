import QtQuick 6.0
import QtQuick.Layouts 6.0
import org.kde.kirigami 2.20 as Kirigami

Item {
    Layout.fillWidth: true
    property string title: "About Cryptonite" // Title property

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        // Header mit Logo
        RowLayout {
            Layout.fillWidth: true


        Kirigami.Heading {
            level: 1
            text: "Cryptonite 1.0"
            color: Kirigami.Theme.textColor
        }

        Text {
            text: "A cryptocurrency tracker widget for KDE Plasma"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            color: Kirigami.Theme.textColor
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Text {
            text: "Copyright: SonnyDee"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            color: Kirigami.Theme.textColor
        }

        Text {
            text: "License: GPL-2.0+"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            color: Kirigami.Theme.textColor
        }

        Text {
            text: "Author: Marcus Ratajczyk (info@ruewag.de)"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            color: Kirigami.Theme.textColor
        }
    }
}
