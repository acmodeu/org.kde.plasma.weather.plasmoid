import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "code/I18n.js" as I18n

Kirigami.FormLayout {
    id: page

    property string cfg_uiLanguage: "en_US"
    readonly property string currentLanguage: cfg_uiLanguage || "en_US"
    property string cfg_temperatureUnit: "celsius"
    property string cfg_speedUnit: "ms"
    property string cfg_pressureUnit: "mmhg"

    function tr(key) {
        return I18n.t(key, page.currentLanguage);
    }

    QQC2.ComboBox {
        id: tempCombo
        Kirigami.FormData.label: page.tr("Temperature units:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: page.tr("Celsius (°C)"), value: "celsius" },
            { text: page.tr("Fahrenheit (°F)"), value: "fahrenheit" }
        ]
        currentIndex: count > 0 ? Math.max(0, indexOfValue(page.cfg_temperatureUnit)) : 0
        onActivated: {
            page.cfg_temperatureUnit = currentValue;
        }

        Connections {
            target: page
            function onCfg_temperatureUnitChanged() {
                var idx = tempCombo.indexOfValue(page.cfg_temperatureUnit);
                if (idx >= 0 && tempCombo.currentIndex !== idx) {
                    tempCombo.currentIndex = idx;
                }
            }
        }
    }

    QQC2.ComboBox {
        id: speedCombo
        Kirigami.FormData.label: page.tr("Wind speed units:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: page.tr("Meters per second (m/s)"), value: "ms" },
            { text: page.tr("Kilometers per hour (km/h)"), value: "kmh" },
            { text: page.tr("Miles per hour (mph)"), value: "mph" }
        ]
        currentIndex: count > 0 ? Math.max(0, indexOfValue(page.cfg_speedUnit)) : 0
        onActivated: {
            page.cfg_speedUnit = currentValue;
        }

        Connections {
            target: page
            function onCfg_speedUnitChanged() {
                var idx = speedCombo.indexOfValue(page.cfg_speedUnit);
                if (idx >= 0 && speedCombo.currentIndex !== idx) {
                    speedCombo.currentIndex = idx;
                }
            }
        }
    }

    QQC2.ComboBox {
        id: pressureCombo
        Kirigami.FormData.label: page.tr("Pressure units:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: page.tr("Millimeters of mercury (mmHg)"), value: "mmhg" },
            { text: page.tr("Hectopascals (hPa)"), value: "hpa" }
        ]
        currentIndex: count > 0 ? Math.max(0, indexOfValue(page.cfg_pressureUnit)) : 0
        onActivated: {
            page.cfg_pressureUnit = currentValue;
        }

        Connections {
            target: page
            function onCfg_pressureUnitChanged() {
                var idx = pressureCombo.indexOfValue(page.cfg_pressureUnit);
                if (idx >= 0 && pressureCombo.currentIndex !== idx) {
                    pressureCombo.currentIndex = idx;
                }
            }
        }
    }
}
