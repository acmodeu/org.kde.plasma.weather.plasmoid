import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "code/OpenMeteo.js" as OpenMeteo
import "code/I18n.js" as I18n

Kirigami.FormLayout {
    id: page

    property string currentLanguage: Plasmoid.configuration.uiLanguage || "en_US"
    property alias cfg_updateInterval: updateIntervalSpin.value
    property string cfg_placeDisplayName: Plasmoid.configuration.placeDisplayName
    property double cfg_latitude: Plasmoid.configuration.latitude
    property double cfg_longitude: Plasmoid.configuration.longitude

    function tr(key, p1, p2) {
        return I18n.t(key, page.currentLanguage, p1, p2);
    }

    QQC2.Label {
        Kirigami.FormData.label: page.tr("Current location:")
        text: page.cfg_placeDisplayName ? page.cfg_placeDisplayName : page.tr("Not selected")
        font.bold: true
    }

    QQC2.Label {
        Kirigami.FormData.label: page.tr("Coordinates:")
        text: (typeof page.cfg_latitude === "number" && !isNaN(page.cfg_latitude)) ? (page.cfg_latitude.toFixed(4) + "°, " + page.cfg_longitude.toFixed(4) + "°") : page.tr("Not set")
        opacity: 0.7
    }

    QQC2.SpinBox {
        id: updateIntervalSpin
        Kirigami.FormData.label: page.tr("Update interval (min):")
        from: 5
        to: 360
        stepSize: 5
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: page.tr("Search location")
    }

    RowLayout {
        Kirigami.FormData.label: page.tr("City name:")
        Layout.fillWidth: true

        Kirigami.SearchField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: page.tr("For example: London, New York, Moscow...")

            Timer {
                id: debounceTimer
                interval: 500
                repeat: false
                onTriggered: performSearch()
            }

            onTextChanged: {
                if (text.trim().length >= 2) {
                    debounceTimer.restart();
                } else {
                    resultsModel.clear();
                }
            }

            onAccepted: performSearch()
        }

        QQC2.Button {
            text: page.tr("Search")
            icon.name: "edit-find"
            onClicked: performSearch()
        }
    }

    QQC2.BusyIndicator {
        id: busyIndicator
        Layout.alignment: Qt.AlignHCenter
        running: false
        visible: running
    }

    QQC2.Label {
        id: statusLabel
        Layout.fillWidth: true
        visible: text.length > 0
        wrapMode: Text.Wrap
        color: Kirigami.Theme.disabledTextColor
    }

    ListModel {
        id: resultsModel
    }

    ListView {
        id: resultsList
        Kirigami.FormData.label: page.tr("Search results:")
        Layout.fillWidth: true
        implicitHeight: Math.min(contentHeight, Kirigami.Units.gridUnit * 12)
        clip: true
        model: resultsModel
        visible: count > 0

        delegate: QQC2.ItemDelegate {
            id: itemDelegate
            width: ListView.view.width

            contentItem: ColumnLayout {
                spacing: Kirigami.Units.smallSpacing

                QQC2.Label {
                    text: model.name + (model.country ? " (" + model.country + ")" : "")
                    font.bold: true
                }

                QQC2.Label {
                    text: (model.admin1 ? model.admin1 + ", " : "") + 
                          page.tr("Latitude: %1°, Longitude: %2°", model.latitude.toFixed(3), model.longitude.toFixed(3))
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    opacity: 0.7
                }
            }

            onClicked: {
                var displayName = model.name;
                if (model.country) {
                    displayName += ", " + model.country;
                }
                page.cfg_placeDisplayName = displayName;
                page.cfg_latitude = model.latitude;
                page.cfg_longitude = model.longitude;
                statusLabel.text = page.tr("Selected: %1", displayName);
                statusLabel.color = Kirigami.Theme.positiveTextColor;
            }
        }
    }

    function performSearch() {
        var query = searchField.text.trim();
        if (query.length === 0) return;

        busyIndicator.running = true;
        statusLabel.text = page.tr("Searching...");
        statusLabel.color = Kirigami.Theme.disabledTextColor;
        resultsModel.clear();

        OpenMeteo.searchLocations(query, function(results) {
            busyIndicator.running = false;
            if (results.length === 0) {
                statusLabel.text = page.tr("No locations found");
                return;
            }
            statusLabel.text = page.tr("Found options: %1 (click to select)", results.length);
            for (var i = 0; i < results.length; i++) {
                resultsModel.append({
                    name: results[i].name || "",
                    country: results[i].country || "",
                    admin1: results[i].admin1 || "",
                    latitude: results[i].latitude || 0,
                    longitude: results[i].longitude || 0
                });
            }
        }, function(err) {
            busyIndicator.running = false;
            statusLabel.text = err;
            statusLabel.color = Kirigami.Theme.negativeTextColor;
        }, page.currentLanguage);
    }
}
