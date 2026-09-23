import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "code/I18n.js" as I18n

Kirigami.FormLayout {
    id: page

    property string cfg_uiLanguage: "en_US"
    property alias cfg_showWeatherIcon: showIconCheck.checked
    property string cfg_forecastMode: "daily"
    property alias cfg_enableLogging: enableLoggingCheck.checked

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
    }

    QQC2.CheckBox {
        id: enableLoggingCheck
        Kirigami.FormData.label: page.tr("Logging:")
        text: page.tr("Enable debug logging")
    }
}
