import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import "code/OpenMeteo.js" as OpenMeteo

ColumnLayout {
    id: fullRoot

    Layout.minimumWidth: Kirigami.Units.gridUnit * 22
    Layout.minimumHeight: Kirigami.Units.gridUnit * 24
    Layout.preferredWidth: Kirigami.Units.gridUnit * 25
    Layout.preferredHeight: Kirigami.Units.gridUnit * 26
    spacing: Kirigami.Units.smallSpacing

    property string forecastViewMode: Plasmoid.configuration.forecastMode || "daily"

    // Header: City and controls
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            source: "mark-location"
            implicitWidth: Kirigami.Units.iconSizes.small
            implicitHeight: Kirigami.Units.iconSizes.small
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            QQC2.Label {
                text: Plasmoid.configuration.placeDisplayName || root.tr("No location selected")
                font.weight: Font.Bold
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            QQC2.Label {
                text: root.lastUpdatedText.length > 0 ? root.lastUpdatedText : root.tr("Open-Meteo")
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.7
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        QQC2.ToolButton {
            icon.name: "view-refresh"
            text: root.tr("Refresh")
            display: QQC2.AbstractButton.IconOnly
            enabled: !root.isLoading
            onClicked: root.refreshForecast()

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: root.tr("Refresh weather data")
        }

        QQC2.ToolButton {
            icon.name: "configure"
            text: root.tr("Settings")
            display: QQC2.AbstractButton.IconOnly
            onClicked: Plasmoid.internalAction("configure").trigger()

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: root.tr("Configure widget...")
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    // Main Content or Placeholder
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        // Error message
        PlasmaExtras.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - Kirigami.Units.largeSpacing * 2
            visible: root.hasError && !root.hasData
            iconName: "network-error"
            text: root.tr("Could not load forecast")
            explanation: root.errorMessage
            helpfulAction: QQC2.Action {
                icon.name: "view-refresh"
                text: root.tr("Retry")
                onTriggered: root.refreshForecast()
            }
        }

        // Loading indicator
        QQC2.BusyIndicator {
            anchors.centerIn: parent
            running: root.isLoading && !root.hasData
            visible: running
        }

        // Weather Data Display
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            visible: root.hasData
            spacing: Kirigami.Units.smallSpacing

            // Current Weather Card
            Kirigami.AbstractCard {
                Layout.fillWidth: true
                background: Rectangle {
                    color: Kirigami.Theme.backgroundColor
                    opacity: 0.6
                    radius: Kirigami.Units.smallSpacing
                    border.color: Qt.alpha(Kirigami.Theme.textColor, 0.15)
                    border.width: 1
                }

                contentItem: ColumnLayout {
                    spacing: Kirigami.Units.smallSpacing

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.largeSpacing

                        Kirigami.Icon {
                            source: root.currentWeatherIcon
                            fallback: "weather-few-clouds"
                            implicitWidth: Kirigami.Units.gridUnit * 3.5
                            implicitHeight: Kirigami.Units.gridUnit * 3.5
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            QQC2.Label {
                                text: root.formattedCurrentTemp
                                font.weight: Font.Bold
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 2.2
                            }

                            QQC2.Label {
                                text: root.currentConditionText
                                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
                                opacity: 0.9
                            }
                        }
                    }

                    Kirigami.Separator {
                        Layout.fillWidth: true
                    }

                    // Parameters Grid
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: Kirigami.Units.smallSpacing
                        columnSpacing: Kirigami.Units.largeSpacing

                        RowLayout {
                            Kirigami.Icon {
                                source: "temperature-normal-symbolic"
                                fallback: Qt.resolvedUrl("icons/temperature-normal.svg")
                                implicitWidth: Kirigami.Units.iconSizes.small
                                implicitHeight: Kirigami.Units.iconSizes.small
                            }
                            QQC2.Label {
                                text: root.tr("Feels like:")
                                opacity: 0.7
                            }
                            QQC2.Label {
                                text: root.formattedApparentTemp
                                font.weight: Font.DemiBold
                            }
                        }

                        RowLayout {
                            Kirigami.Icon {
                                source: Qt.resolvedUrl("icons/weather-wind.svg")
                                fallback: "weather-clouds-wind-symbolic"
                                implicitWidth: Kirigami.Units.iconSizes.small
                                implicitHeight: Kirigami.Units.iconSizes.small
                            }
                            QQC2.Label {
                                text: root.tr("Wind:")
                                opacity: 0.7
                            }
                            QQC2.Label {
                                text: root.formattedWind
                                font.weight: Font.DemiBold
                            }
                        }

                        RowLayout {
                            Kirigami.Icon {
                                source: "weather-fog-symbolic"
                                implicitWidth: Kirigami.Units.iconSizes.small
                                implicitHeight: Kirigami.Units.iconSizes.small
                            }
                            QQC2.Label {
                                text: root.tr("Humidity:")
                                opacity: 0.7
                            }
                            QQC2.Label {
                                text: root.currentHumidity + "%"
                                font.weight: Font.DemiBold
                            }
                        }

                        RowLayout {
                            Kirigami.Icon {
                                source: "speedometer"
                                implicitWidth: Kirigami.Units.iconSizes.small
                                implicitHeight: Kirigami.Units.iconSizes.small
                            }
                            QQC2.Label {
                                text: root.tr("Pressure:")
                                opacity: 0.7
                            }
                            QQC2.Label {
                                text: root.formattedPressure
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }

            // Mode Selector: Daily vs Hourly
            RowLayout {
                Layout.fillWidth: true

                QQC2.Label {
                    text: root.tr("Forecast:")
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                QQC2.ButtonGroup { id: viewModeGroup }

                QQC2.Button {
                    text: root.tr("7 days")
                    checkable: true
                    checked: fullRoot.forecastViewMode === "daily"
                    QQC2.ButtonGroup.group: viewModeGroup
                    onClicked: fullRoot.forecastViewMode = "daily"
                }

                QQC2.Button {
                    text: root.tr("24 hours")
                    checkable: true
                    checked: fullRoot.forecastViewMode === "hourly"
                    QQC2.ButtonGroup.group: viewModeGroup
                    onClicked: fullRoot.forecastViewMode = "hourly"
                }
            }

            // Forecast View
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Daily View (7 days)
                ListView {
                    id: dailyListView
                    anchors.fill: parent
                    visible: fullRoot.forecastViewMode === "daily"
                    clip: true
                    model: root.dailyForecastModel
                    spacing: Kirigami.Units.smallSpacing

                    delegate: Rectangle {
                        width: dailyListView.width
                        height: Kirigami.Units.gridUnit * 2.2
                        color: index % 2 === 0 ? Kirigami.Theme.backgroundColor : "transparent"
                        opacity: 0.9
                        radius: Kirigami.Units.smallSpacing

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Kirigami.Units.smallSpacing
                            anchors.rightMargin: Kirigami.Units.smallSpacing
                            spacing: Kirigami.Units.smallSpacing

                            QQC2.Label {
                                text: model.dayName
                                font.weight: Font.DemiBold
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 5.2
                            }

                            Kirigami.Icon {
                                source: model.icon
                                fallback: "weather-few-clouds"
                                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                            }

                            QQC2.Label {
                                text: model.description
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                opacity: 0.8
                            }

                            QQC2.Label {
                                text: model.tempMin + " … " + model.tempMax
                                font.weight: Font.Bold
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }

                // Hourly View (Next 24 hours)
                ListView {
                    id: hourlyListView
                    anchors.fill: parent
                    visible: fullRoot.forecastViewMode === "hourly"
                    orientation: ListView.Horizontal
                    clip: true
                    model: root.hourlyForecastModel
                    spacing: Kirigami.Units.smallSpacing

                    delegate: Rectangle {
                        width: Kirigami.Units.gridUnit * 4.5
                        height: hourlyListView.height
                        color: Kirigami.Theme.backgroundColor
                        opacity: 0.6
                        radius: Kirigami.Units.smallSpacing
                        border.color: Qt.alpha(Kirigami.Theme.textColor, 0.15)
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.smallSpacing
                            spacing: Kirigami.Units.smallSpacing

                            QQC2.Label {
                                text: model.hour
                                Layout.alignment: Qt.AlignHCenter
                                font.weight: Font.DemiBold
                                opacity: 0.8
                            }

                            Kirigami.Icon {
                                source: model.icon
                                fallback: "weather-few-clouds"
                                Layout.alignment: Qt.AlignHCenter
                                implicitWidth: Kirigami.Units.iconSizes.medium
                                implicitHeight: Kirigami.Units.iconSizes.medium
                            }

                            QQC2.Label {
                                text: model.temperature
                                Layout.alignment: Qt.AlignHCenter
                                font.weight: Font.Bold
                            }

                            QQC2.Label {
                                text: model.humidity + "%"
                                Layout.alignment: Qt.AlignHCenter
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                opacity: 0.6
                            }
                        }
                    }
                }
            }
        }
    }
}
