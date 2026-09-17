import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "code/I18n.js" as I18n

Kirigami.FormLayout {
    id: page

    property string cfg_uiLanguage: Plasmoid.configuration.uiLanguage || "en_US"
    property alias cfg_showWeatherIcon: showIconCheck.checked
    property string cfg_forecastMode: Plasmoid.configuration.forecastMode

    function tr(key) {
        return I18n.t(key, page.cfg_uiLanguage);
    }

    QQC2.ComboBox {
        id: languageCombo
        Kirigami.FormData.label: page.tr("Language:")
        textRole: "text"
        valueRole: "value"
        model: I18n.getAvailableLocales()
        currentIndex: count > 0 ? Math.max(0, indexOfValue(page.cfg_uiLanguage)) : 0

        onActivated: {
            page.cfg_uiLanguage = currentValue;
            Plasmoid.configuration.uiLanguage = currentValue;
        }

        Connections {
            target: page
            function onCfg_uiLanguageChanged() {
                var idx = languageCombo.indexOfValue(page.cfg_uiLanguage);
                if (idx >= 0 && languageCombo.currentIndex !== idx) {
                    languageCombo.currentIndex = idx;
                }
            }
        }
    }

    QQC2.CheckBox {
        id: showIconCheck
        Kirigami.FormData.label: page.tr("Task Manager / Panel:")
        text: page.tr("Show weather icon")
        checked: Plasmoid.configuration.showWeatherIcon !== undefined ? Plasmoid.configuration.showWeatherIcon : true
        onToggled: {
            Plasmoid.configuration.showWeatherIcon = checked;
        }
    }

    QQC2.ComboBox {
        id: forecastModeCombo
        Kirigami.FormData.label: page.tr("Default forecast view:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: page.tr("Daily (7 days)"), value: "daily" },
            { text: page.tr("Hourly (24 hours)"), value: "hourly" }
        ]
        currentIndex: count > 0 ? Math.max(0, indexOfValue(page.cfg_forecastMode)) : 0
        onActivated: {
            page.cfg_forecastMode = currentValue;
        }

        Connections {
            target: page
            function onCfg_forecastModeChanged() {
                var idx = forecastModeCombo.indexOfValue(page.cfg_forecastMode);
                if (idx >= 0 && forecastModeCombo.currentIndex !== idx) {
                    forecastModeCombo.currentIndex = idx;
                }
            }
        }
    }
}
