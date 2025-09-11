// config.qml
import QtQuick 6.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "configure"
        source: "ConfigGeneral.qml"
    }
    ConfigCategory {
        name: "Notifications"
        icon: "notifications"
        source: "ConfigNotifications.qml"
    }
}
