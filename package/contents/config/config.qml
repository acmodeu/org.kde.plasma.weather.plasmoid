import QtQuick
import org.kde.plasma.configuration
import org.kde.plasma.plasmoid
import "../ui/code/I18n.js" as I18n

ConfigModel {
    readonly property string currentLanguage: (typeof Plasmoid !== "undefined" && Plasmoid.configuration?.uiLanguage) ? Plasmoid.configuration.uiLanguage : "en_US"

    ConfigCategory {
        name: I18n.t("Weather Station", currentLanguage)
        icon: "weather-few-clouds"
        source: "ConfigWeatherStation.qml"
    }
    ConfigCategory {
        name: I18n.t("Units", currentLanguage)
        icon: "measure"
        source: "ConfigUnits.qml"
    }
    ConfigCategory {
        name: I18n.t("Appearance", currentLanguage)
        icon: "preferences-desktop-color"
        source: "ConfigAppearance.qml"
    }
}
