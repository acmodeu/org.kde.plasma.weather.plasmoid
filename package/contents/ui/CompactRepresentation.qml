/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: compactRoot

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool showIcon: root.showWeatherIcon

    Layout.fillWidth: vertical
    Layout.fillHeight: !vertical

    Layout.minimumWidth: vertical ? Kirigami.Units.iconSizes.small : Math.max(Kirigami.Units.iconSizes.small, contentLayout.implicitWidth)
    Layout.preferredWidth: Layout.minimumWidth
    Layout.maximumWidth: vertical ? Infinity : Layout.minimumWidth

    Layout.minimumHeight: vertical ? Math.max(Kirigami.Units.iconSizes.small, contentLayout.implicitHeight) : Kirigami.Units.iconSizes.small
    Layout.preferredHeight: Layout.minimumHeight
    Layout.maximumHeight: vertical ? Layout.minimumHeight : Infinity

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: (compactRoot.showIcon && tempLabel.visible) ? Kirigami.Units.smallSpacing : 0

        PlasmaComponents.Label {
            id: tempLabel
            text: root.formattedCurrentTemp
            visible: text.length > 0

            font.pixelSize: Math.round(Kirigami.Theme.defaultFont.pixelSize * 1.35)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillHeight: !compactRoot.vertical
            Layout.fillWidth: compactRoot.vertical
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: (compactRoot.showIcon && !compactRoot.vertical) ? 0 : Kirigami.Units.smallSpacing
        }

        Kirigami.Icon {
            id: weatherIcon
            visible: compactRoot.showIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillHeight: !compactRoot.vertical
            Layout.fillWidth: compactRoot.vertical
            Layout.preferredWidth: compactRoot.vertical ? width : height
            Layout.preferredHeight: compactRoot.vertical ? width : height
            Layout.minimumWidth: Kirigami.Units.iconSizes.small
            Layout.minimumHeight: Kirigami.Units.iconSizes.small

            source: root.currentWeatherIcon
            fallback: "weather-few-clouds"
            active: compactMouseArea.containsMouse
        }
    }

    MouseArea {
        id: compactMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.expanded = !root.expanded;
        }
    }
}
