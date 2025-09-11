// ColorChooser.qml
import QtQuick 6.0
import QtQuick.Controls 6.0
import org.kde.kirigami 2.20 as Kirigami

Button {
    id: colorButton
    property color currentColor: "white"
    signal colorSelected(string color)

    width: 30
    height: 30

    background: Rectangle {
        color: currentColor
        radius: 3
        border.width: 1
        border.color: Kirigami.Theme.textColor
    }

    // Einfaches Menu mit vordefinierten Farben
    onClicked: colorMenu.popup()

    Menu {
        id: colorMenu

        MenuItem {
            text: i18n("White")
            onTriggered: {
                colorButton.currentColor = "white";
                colorButton.colorSelected("white");
            }
        }
        MenuItem {
            text: i18n("Green")
            onTriggered: {
                colorButton.currentColor = "green";
                colorButton.colorSelected("green");
            }
        }
        MenuItem {
            text: i18n("Red")
            onTriggered: {
                colorButton.currentColor = "red";
                colorButton.colorSelected("red");
            }
        }
        MenuItem {
            text: i18n("Blue")
            onTriggered: {
                colorButton.currentColor = "blue";
                colorButton.colorSelected("blue");
            }
        }
        MenuItem {
            text: i18n("Light Green (#c6f4c6)")
            onTriggered: {
                colorButton.currentColor = "#c6f4c6";
                colorButton.colorSelected("#c6f4c6");
            }
        }
        MenuItem {
            text: i18n("Light Red (#f4a4a4)")
            onTriggered: {
                colorButton.currentColor = "#f4a4a4";
                colorButton.colorSelected("#f4a4a4");
            }
        }
    }
}
