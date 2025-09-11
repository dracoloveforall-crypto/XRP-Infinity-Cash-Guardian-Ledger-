// ConfigNotifications.qml
import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0
import QtQuick.Dialogs 6.3
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasmoid 2.0

Item {
    id: notificationsPage
    Layout.fillWidth: true

    // Properties
    property alias cfg_notificationsEnabled: notificationsCheckbox.checked
    property alias cfg_gainSound: gainSoundField.text
    property alias cfg_lossSound: lossSoundField.text

    SoundPlayer {
        id: soundPlayer
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        CheckBox {
            id: notificationsCheckbox
            text: i18n("Enable notifications")
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            visible: notificationsCheckbox.checked
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true
            visible: notificationsCheckbox.checked

            // Gain Sound mit Browse-Button und Help-Button
            RowLayout {
                Kirigami.FormData.label: i18n("Gain Sound:")

                TextField {
                    id: gainSoundField
                    placeholderText: i18n("Path to sound file")
                    Layout.fillWidth: true
                }

                Button {
                    text: i18n("Browse")
                    onClicked: {
                        fileDialog.currentField = "gain";
                        fileDialog.open();
                    }
                }

                HelpButton {
                    page: "notifications"
                }
            }

            // Test-Button für Gain Sound
            Button {
                text: i18n("Test Gain Sound")
                enabled: gainSoundField.text !== ""
                onClicked: soundPlayer.playSound(gainSoundField.text)
                Layout.alignment: Qt.AlignRight
            }

            // Loss Sound mit Browse-Button
            RowLayout {
                Kirigami.FormData.label: i18n("Loss Sound:")

                TextField {
                    id: lossSoundField
                    placeholderText: i18n("Path to sound file")
                    Layout.fillWidth: true
                }

                Button {
                    text: i18n("Browse")
                    onClicked: {
                        fileDialog.currentField = "loss";
                        fileDialog.open();
                    }
                }
            }

            // Test-Button für Loss Sound
            Button {
                text: i18n("Test Loss Sound")
                enabled: lossSoundField.text !== ""
                onClicked: soundPlayer.playSound(lossSoundField.text)
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    // FileDialog für Soundauswahl
    FileDialog {
        id: fileDialog
        title: i18n("Please choose a sound file")
        nameFilters: [i18n("Sound files (*.ogg *.wav *.mp3)")]
        property string currentField: ""

        onAccepted: {
            if (currentField === "gain") {
                gainSoundField.text = selectedFile;
            } else if (currentField === "loss") {
                lossSoundField.text = selectedFile;
            }
        }
    }

    Component.onCompleted: {
        notificationsCheckbox.checked = plasmoid.configuration.notificationsEnabled !== undefined ?
        plasmoid.configuration.notificationsEnabled : true;
        gainSoundField.text = plasmoid.configuration.gainSound || "";
        lossSoundField.text = plasmoid.configuration.lossSound || "";
    }
}
