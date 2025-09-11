// HelpButton.qml
import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0
import org.kde.kirigami 2.20 as Kirigami

Button {
    property string page: "general"

    icon.name: "help-contents"
    text: i18n("Help")

    onClicked: helpDialog.open()

    Dialog {
        id: helpDialog
        title: i18n("Cryptonite Help")
        standardButtons: Dialog.Close

        width: 400
        height: 300

        ColumnLayout {
            anchors.fill: parent

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TextArea {
                    id: helpText
                    readOnly: true
                    wrapMode: Text.Wrap
                    text: {
                        switch (page) {
                            case "general":
                                return i18n(
                                    "General Settings Help:\n\n" +
                                    "• Widget Title: Custom name for your widget\n" +
                                    "• Cryptocurrencies: Comma-separated symbols (BTC,ETH,XRP)\n" +
                                    "• Update Interval: Data refresh rate in seconds\n" +
                                    "• Colors: Customize widget appearance\n" +
                                    "• Portfolio: Enter your cryptocurrency holdings\n" +
                                    "   - Amount: Quantity you own\n" +
                                    "   - Purchase Price: Price per coin when purchased"
                                );
                            case "notifications":
                                return i18n(
                                    "Notifications Settings Help:\n\n" +
                                    "• Enable notifications: Toggle sound alerts\n" +
                                    "• Gain Sound: Play when portfolio increases by 0.1%\n" +
                                    "• Loss Sound: Play when portfolio decreases by 0.1%\n\n" +
                                    "Sounds will play when your total profit/loss changes by more than 0.1%."
                                );
                            default:
                                return i18n("Select a help topic");
                        }
                    }
                }
            }
        }
    }
}
