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

    readonly property int hourlyCardWidth: Math.round(Kirigami.Units.gridUnit * 4.4)
    readonly property int hourlyCardSpacing: Math.round(Kirigami.Units.smallSpacing)
    readonly property int hourlyOuterMargin: Math.round(Kirigami.Units.smallSpacing)

    readonly property int fixedWidth: (5 * hourlyCardWidth) + (4 * hourlyCardSpacing) + (2 * hourlyOuterMargin) + 2
    readonly property int fixedHeight: Math.round(Kirigami.Units.gridUnit * 35.8)

    readonly property int totalHourlyCards: (fullRoot.plasmoidItem && fullRoot.plasmoidItem.hourlyForecastModel) ? fullRoot.plasmoidItem.hourlyForecastModel.count : 0
    readonly property int totalHourlyPages: Math.max(1, Math.ceil(totalHourlyCards / 5))
    property int currentHourlyPage: 0

    function targetContentXForPage(page) {
        if (totalHourlyCards <= 5 || page <= 0) {
            return 0;
        }
        var startIndex = page * 5;
        if (startIndex + 5 > totalHourlyCards) {
            startIndex = Math.max(0, totalHourlyCards - 5);
        }
        if (typeof hourlyRepeater !== "undefined" && hourlyRepeater && hourlyRepeater.count > startIndex) {
            var item = hourlyRepeater.itemAt(startIndex);
            if (item) {
                return item.x;
            }
        }
        var cardPitch = hourlyCardWidth + hourlyCardSpacing;
        return startIndex * cardPitch;
    }

    function goToHourlyPage(page) {
        currentHourlyPage = Math.max(0, Math.min(totalHourlyPages - 1, page));
        var targetX = targetContentXForPage(currentHourlyPage);
        if (typeof hourlyScrollAnim !== "undefined" && hourlyScrollAnim) {
            hourlyScrollAnim.stop();
            hourlyScrollAnim.to = targetX;
            hourlyScrollAnim.restart();
        } else if (typeof hourlyFlickable !== "undefined" && hourlyFlickable) {
            hourlyFlickable.contentX = targetX;
        }
    }

    implicitWidth: fixedWidth
    implicitHeight: fixedHeight
    Layout.minimumWidth: fixedWidth
    Layout.maximumWidth: fixedWidth
    Layout.preferredWidth: fixedWidth
    Layout.minimumHeight: fixedHeight
    Layout.maximumHeight: fixedHeight
    Layout.preferredHeight: fixedHeight
    spacing: Kirigami.Units.smallSpacing

    property var plasmoidItem: (typeof root !== "undefined") ? root : null

    function resetScrollPositions() {
        currentHourlyPage = 0;
        if (typeof hourlyScrollAnim !== "undefined" && hourlyScrollAnim) {
            hourlyScrollAnim.stop();
            hourlyScrollAnim.to = 0;
        }
        if (typeof hourlyFlickable !== "undefined" && hourlyFlickable) {
            hourlyFlickable.cancelFlick();
            hourlyFlickable.contentX = 0;
            hourlyFlickable.returnToBounds();
        }
        if (typeof contentScroll !== "undefined" && contentScroll && contentScroll.contentItem) {
            contentScroll.contentItem.cancelFlick();
            contentScroll.contentItem.contentY = 0;
            contentScroll.contentItem.returnToBounds();
        }
    }

    Timer {
        id: resetScrollTimer
        interval: 35
        repeat: false
        onTriggered: fullRoot.resetScrollPositions()
    }

    Timer {
        id: resetScrollTimerLate
        interval: 150
        repeat: false
        onTriggered: fullRoot.resetScrollPositions()
    }

    Connections {
        target: fullRoot.plasmoidItem
        function onExpandedChanged() {
            fullRoot.resetScrollPositions();
            if (fullRoot.plasmoidItem && fullRoot.plasmoidItem.expanded) {
                resetScrollTimer.restart();
                resetScrollTimerLate.restart();
            }
        }
    }

    Connections {
        target: (fullRoot.plasmoidItem && fullRoot.plasmoidItem.hourlyForecastModel) ? fullRoot.plasmoidItem.hourlyForecastModel : null
        function onCountChanged() {
            fullRoot.resetScrollPositions();
            resetScrollTimer.restart();
        }
    }

    Component.onCompleted: {
        resetScrollPositions();
    }

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
        QQC2.ScrollView {
            id: contentScroll
            anchors.fill: parent
            anchors.margins: fullRoot.hourlyOuterMargin
            visible: root.hasData
            clip: true
            contentWidth: availableWidth
            QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

            ColumnLayout {
                width: contentScroll.availableWidth
                spacing: Kirigami.Units.mediumSpacing

                // 1. Current Weather Card
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

                // 2. Hourly Forecast Section (24 hours)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        Kirigami.Icon {
                            source: "clock"
                            fallback: "preferences-system-time"
                            implicitWidth: Kirigami.Units.iconSizes.small
                            implicitHeight: Kirigami.Units.iconSizes.small
                        }

                        QQC2.Label {
                            text: root.tr("Hourly forecast (24 hours)")
                            font.weight: Font.Bold
                            font.pointSize: Kirigami.Theme.defaultFont.pointSize
                            Layout.fillWidth: true
                        }

                        QQC2.ToolButton {
                            icon.name: "go-previous"
                            text: root.tr("Scroll left")
                            display: QQC2.AbstractButton.IconOnly
                            implicitWidth: Kirigami.Units.iconSizes.medium
                            implicitHeight: Kirigami.Units.iconSizes.medium
                            enabled: fullRoot.currentHourlyPage > 0
                            onClicked: fullRoot.goToHourlyPage(fullRoot.currentHourlyPage - 1)
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: root.tr("Scroll left")
                        }

                        QQC2.ToolButton {
                            icon.name: "go-next"
                            text: root.tr("Scroll right")
                            display: QQC2.AbstractButton.IconOnly
                            implicitWidth: Kirigami.Units.iconSizes.medium
                            implicitHeight: Kirigami.Units.iconSizes.medium
                            enabled: fullRoot.currentHourlyPage < (fullRoot.totalHourlyPages - 1)
                            onClicked: fullRoot.goToHourlyPage(fullRoot.currentHourlyPage + 1)
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: root.tr("Scroll right")
                        }
                    }

                    Flickable {
                        id: hourlyFlickable
                        Layout.fillWidth: true
                        implicitHeight: Kirigami.Units.gridUnit * 5.8
                        contentWidth: hourlyRow.implicitWidth + 2
                        contentHeight: height
                        flickableDirection: Flickable.HorizontalFlick
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        onMovementEnded: {
                            var cardPitch = fullRoot.hourlyCardWidth + fullRoot.hourlyCardSpacing;
                            var nearestCard = Math.round(hourlyFlickable.contentX / cardPitch);
                            var page = Math.round(nearestCard / 5);
                            fullRoot.goToHourlyPage(page);
                        }

                        onFlickEnded: {
                            var cardPitch = fullRoot.hourlyCardWidth + fullRoot.hourlyCardSpacing;
                            var nearestCard = Math.round(hourlyFlickable.contentX / cardPitch);
                            var page = Math.round(nearestCard / 5);
                            fullRoot.goToHourlyPage(page);
                        }

                        NumberAnimation {
                            id: hourlyScrollAnim
                            target: hourlyFlickable
                            property: "contentX"
                            duration: 250
                            easing.type: Easing.OutQuad
                        }

                        WheelHandler {
                            target: hourlyFlickable
                            orientation: Qt.Horizontal
                            onWheel: function(event) {
                                if (event.angleDelta.y < 0 || event.angleDelta.x < 0) {
                                    fullRoot.goToHourlyPage(fullRoot.currentHourlyPage + 1);
                                } else if (event.angleDelta.y > 0 || event.angleDelta.x > 0) {
                                    fullRoot.goToHourlyPage(fullRoot.currentHourlyPage - 1);
                                }
                                event.accepted = true;
                            }
                        }

                        RowLayout {
                            id: hourlyRow
                            height: hourlyFlickable.height
                            spacing: fullRoot.hourlyCardSpacing

                            Repeater {
                                id: hourlyRepeater
                                model: root.hourlyForecastModel

                                delegate: Rectangle {
                                    implicitWidth: fullRoot.hourlyCardWidth
                                    implicitHeight: hourlyRow.height
                                    width: implicitWidth
                                    height: implicitHeight
                                    Layout.preferredWidth: implicitWidth
                                    Layout.preferredHeight: implicitHeight
                                    color: Kirigami.Theme.backgroundColor
                                    opacity: 0.7
                                    radius: Kirigami.Units.smallSpacing
                                    border.color: index === 0 
                                        ? Qt.alpha(Kirigami.Theme.highlightColor, 0.6) 
                                        : (model.isFirstOfNextDay 
                                            ? Qt.alpha(Kirigami.Theme.highlightColor, 0.4) 
                                            : Qt.alpha(Kirigami.Theme.textColor, 0.15))
                                    border.width: (index === 0 || model.isFirstOfNextDay) ? 1.5 : 1

                                    HoverHandler {
                                        id: cardHoverHandler
                                    }

                                    QQC2.ToolTip.visible: cardHoverHandler.hovered && !!model.isNextDay
                                    QQC2.ToolTip.delay: 400
                                    QQC2.ToolTip.text: root.tr("Tomorrow")

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: Kirigami.Units.smallSpacing
                                        spacing: 2

                                        Item {
                                            Layout.fillWidth: true
                                            implicitHeight: Math.round(Kirigami.Units.gridUnit * 0.7)

                                            // Badge for tomorrow
                                            Rectangle {
                                                anchors.centerIn: parent
                                                visible: !!model.isNextDay
                                                implicitWidth: Math.min(parent.width, tomorrowBadgeLabel.implicitWidth + Kirigami.Units.smallSpacing * 1.5)
                                                implicitHeight: parent.implicitHeight
                                                radius: Math.round(height / 2)
                                                color: Qt.alpha(Kirigami.Theme.highlightColor, 0.2)

                                                QQC2.Label {
                                                    id: tomorrowBadgeLabel
                                                    anchors.centerIn: parent
                                                    text: model.dayLabel || root.tr("Tomorrow")
                                                    font.pointSize: Kirigami.Theme.smallFont.pointSize * 0.85
                                                    font.weight: Font.DemiBold
                                                    color: Kirigami.Theme.highlightColor
                                                    elide: Text.ElideRight
                                                    maximumLineCount: 1
                                                }
                                            }
                                        }

                                        QQC2.Label {
                                            text: model.hour
                                            Layout.alignment: Qt.AlignHCenter
                                            font.weight: index === 0 ? Font.Bold : Font.DemiBold
                                            opacity: index === 0 ? 1.0 : 0.85
                                        }

                                        Kirigami.Icon {
                                            source: model.icon
                                            fallback: "weather-few-clouds"
                                            Layout.alignment: Qt.AlignHCenter
                                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                                        }

                                        QQC2.Label {
                                            text: model.temperature
                                            Layout.alignment: Qt.AlignHCenter
                                            font.weight: Font.Bold
                                        }

                                        RowLayout {
                                            Layout.alignment: Qt.AlignHCenter
                                            spacing: 2
                                            visible: (model.humidity !== undefined && model.humidity > 0)

                                            Kirigami.Icon {
                                                source: "weather-fog-symbolic"
                                                implicitWidth: Kirigami.Units.iconSizes.small * 0.7
                                                implicitHeight: Kirigami.Units.iconSizes.small * 0.7
                                                opacity: 0.6
                                            }

                                            QQC2.Label {
                                                text: model.humidity + "%"
                                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                                opacity: 0.65
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // 3. Daily Forecast Section (7 days)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        Kirigami.Icon {
                            source: "view-calendar"
                            fallback: "x-office-calendar"
                            implicitWidth: Kirigami.Units.iconSizes.small
                            implicitHeight: Kirigami.Units.iconSizes.small
                        }

                        QQC2.Label {
                            text: root.tr("Daily forecast (7 days)")
                            font.weight: Font.Bold
                            font.pointSize: Kirigami.Theme.defaultFont.pointSize
                            Layout.fillWidth: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Repeater {
                            model: root.dailyForecastModel

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: Kirigami.Units.gridUnit * 1.95
                                color: index % 2 === 0 ? Kirigami.Theme.backgroundColor : "transparent"
                                opacity: 0.8
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
                                        opacity: 0.85
                                    }

                                    QQC2.Label {
                                        text: model.tempMin + " … " + model.tempMax
                                        font.weight: Font.Bold
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
