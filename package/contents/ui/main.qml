import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "code/OpenMeteo.js" as OpenMeteo
import "code/I18n.js" as I18n

PlasmoidItem {
    id: root

    // Language and translation
    readonly property string currentLanguage: Plasmoid.configuration?.uiLanguage || "en_US"

    function tr(key, p1, p2) {
        return I18n.t(key, currentLanguage, p1, p2);
    }

    // State properties
    property bool isLoading: false
    property bool hasError: false
    property bool hasData: false
    property string errorMessage: ""
    property string lastUpdatedText: ""
    property var lastWeatherData: null
    property double lastSuccessfulFetchTimestamp: 0
    property double lastWatchdogTimestamp: Date.now()

    // Current weather data
    property double currentTemp: 0.0
    property double apparentTemp: 0.0
    property int currentHumidity: 0
    property double currentWindSpeed: 0.0
    property int currentWindDir: 0
    property double currentPressure: 0.0
    property int currentWeatherCode: 0
    property int currentIsDay: 1

    // Models for forecast
    property ListModel dailyForecastModel: ListModel {}
    property ListModel hourlyForecastModel: ListModel {}

    // Formatted strings (automatically reactive to unit and language settings changes)
    readonly property string formattedCurrentTemp: hasData ? OpenMeteo.convertTemperature(currentTemp, Plasmoid.configuration?.temperatureUnit) : ""
    readonly property string formattedApparentTemp: hasData ? OpenMeteo.convertTemperature(apparentTemp, Plasmoid.configuration?.temperatureUnit) : ""
    readonly property string formattedWind: hasData ? (OpenMeteo.convertSpeed(currentWindSpeed, Plasmoid.configuration?.speedUnit, currentLanguage) + ", " + OpenMeteo.degreesToCompass(currentWindDir, currentLanguage)) : ""
    readonly property string formattedPressure: hasData ? OpenMeteo.convertPressure(currentPressure, Plasmoid.configuration?.pressureUnit, currentLanguage) : ""
    readonly property string currentConditionText: hasData ? OpenMeteo.wmoToDescription(currentWeatherCode, currentLanguage) : ""
    readonly property string currentWeatherIcon: hasData ? OpenMeteo.wmoToIcon(currentWeatherCode, currentIsDay) : "weather-few-clouds"

    // Representations
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}

    // Plasma icon, status and tooltips
    Plasmoid.icon: currentWeatherIcon
    Plasmoid.status: PlasmaCore.Types.ActiveStatus
    toolTipMainText: Plasmoid.configuration?.placeDisplayName || tr("Weather (Open-Meteo)")
    toolTipSubText: {
        if (!hasData) {
            return isLoading ? tr("Loading data...") : (hasError ? errorMessage : tr("No data"));
        }
        return formattedCurrentTemp + " (" + currentConditionText + ")\n"
            + tr("Feels like: ") + formattedApparentTemp + "\n"
            + tr("Wind: ") + formattedWind + "\n"
            + tr("Pressure: ") + formattedPressure;
    }

    // Context menu actions
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: root.tr("Refresh Forecast")
            icon.name: "view-refresh"
            onTriggered: root.refreshForecast()
        }
    ]

    // Configuration properties with reactive change handlers
    readonly property bool showWeatherIcon: Plasmoid.configuration?.showWeatherIcon ?? true
    readonly property double targetLatitude: Plasmoid.configuration?.latitude ?? 55.7522
    readonly property double targetLongitude: Plasmoid.configuration?.longitude ?? 37.6156
    readonly property int updateIntervalMinutes: Plasmoid.configuration?.updateInterval ?? 30

    onTargetLatitudeChanged: root.refreshForecast()
    onTargetLongitudeChanged: root.refreshForecast()
    onCurrentLanguageChanged: {
        if (lastWeatherData) {
            parseWeatherData(lastWeatherData);
        }
    }
    onUpdateIntervalMinutesChanged: {
        updateTimer.interval = Math.max(5, updateIntervalMinutes) * 60 * 1000;
        updateTimer.restart();
    }

    // Refresh timer
    Timer {
        id: updateTimer
        interval: Math.max(5, root.updateIntervalMinutes) * 60 * 1000
        repeat: true
        running: true
        onTriggered: root.refreshForecast()
    }

    // Watchdog timer: checks wall-clock time every 30 seconds to detect suspend/hibernate/resume
    // and ensures weather updates even when QTimer freezes during system sleep
    Timer {
        id: watchdogTimer
        interval: 30000 // 30 seconds
        repeat: true
        running: true
        onTriggered: {
            var now = Date.now();
            var elapsedSinceLastCheck = now - root.lastWatchdogTimestamp;
            root.lastWatchdogTimestamp = now;

            if (elapsedSinceLastCheck < 0) {
                return;
            }

            // If elapsed time is significantly greater than 30s (e.g. > 60s),
            // the system was in suspend or hibernate state!
            var wasSuspended = elapsedSinceLastCheck > 60000;
            var updateIntervalMs = Math.max(5, root.updateIntervalMinutes) * 60 * 1000;
            var timeSinceLastFetch = now - root.lastSuccessfulFetchTimestamp;
            var isStale = root.lastSuccessfulFetchTimestamp === 0 || timeSinceLastFetch >= updateIntervalMs;

            if (wasSuspended) {
                // Give network 3.5 seconds to re-establish connection after sleep
                wakeReconnectTimer.restart();
            } else if (isStale && !root.isLoading) {
                root.refreshForecast();
            }
        }
    }

    // Delay timer on wake-up: allows Wi-Fi/Ethernet to reconnect before sending request
    Timer {
        id: wakeReconnectTimer
        interval: 3500 // 3.5 seconds
        repeat: false
        onTriggered: {
            if (!root.isLoading) {
                root.refreshForecast();
            }
        }
    }

    // Network retry timer: retries after 10s if connection was temporarily down
    Timer {
        id: retryTimer
        interval: 10000 // 10 seconds
        repeat: false
        onTriggered: {
            if (root.hasError && !root.isLoading) {
                root.refreshForecast();
            }
        }
    }

    // Refresh when user expands widget card if data is stale
    onExpandedChanged: {
        if (root.expanded) {
            var now = Date.now();
            var updateIntervalMs = Math.max(5, root.updateIntervalMinutes) * 60 * 1000;
            if (root.lastSuccessfulFetchTimestamp === 0 || (now - root.lastSuccessfulFetchTimestamp >= updateIntervalMs)) {
                if (!root.isLoading) {
                    root.refreshForecast();
                }
            }
        }
    }

    function parseWeatherData(data) {
        lastWeatherData = data;
        lastSuccessfulFetchTimestamp = Date.now();
        updateTimer.restart();

        // Update Current Weather
        currentTemp = data.current.temperature_2m;
        apparentTemp = data.current.apparent_temperature;
        currentHumidity = data.current.relative_humidity_2m;
        currentWindSpeed = data.current.wind_speed_10m;
        currentWindDir = data.current.wind_direction_10m;
        currentPressure = data.current.surface_pressure;
        currentWeatherCode = data.current.weather_code;
        currentIsDay = data.current.is_day !== undefined ? data.current.is_day : 1;

        var now = new Date();
        var hours = ("0" + now.getHours()).slice(-2);
        var minutes = ("0" + now.getMinutes()).slice(-2);
        lastUpdatedText = tr("Updated at %1:%2", hours, minutes);

        // Update Daily Forecast Model
        dailyForecastModel.clear();
        if (data.daily && data.daily.time) {
            var times = data.daily.time;
            var codes = data.daily.weather_code;
            var maxTemps = data.daily.temperature_2m_max;
            var minTemps = data.daily.temperature_2m_min;

            for (var i = 0; i < times.length; i++) {
                var dayName = OpenMeteo.formatDayOfWeek(times[i], currentLanguage);
                var icon = OpenMeteo.wmoToIcon(codes[i], 1);
                var desc = OpenMeteo.wmoToDescription(codes[i], currentLanguage);
                var tempMax = OpenMeteo.convertTemperature(maxTemps[i], Plasmoid.configuration?.temperatureUnit, false);
                var tempMin = OpenMeteo.convertTemperature(minTemps[i], Plasmoid.configuration?.temperatureUnit, false);

                dailyForecastModel.append({
                    dayName: dayName,
                    date: times[i],
                    icon: icon,
                    description: desc,
                    tempMax: tempMax,
                    tempMin: tempMin
                });
            }
        }

        // Update Hourly Forecast Model (next 24 hours)
        hourlyForecastModel.clear();
        if (data.hourly && data.hourly.time) {
            var hTimes = data.hourly.time;
            var hTemps = data.hourly.temperature_2m;
            var hCodes = data.hourly.weather_code;
            var hHumidities = data.hourly.relative_humidity_2m;

            var currentHourStr = now.toISOString().slice(0, 13); // "YYYY-MM-DDTHH"
            var startIndex = 0;
            for (var j = 0; j < hTimes.length; j++) {
                if (hTimes[j].startsWith(currentHourStr)) {
                    startIndex = j;
                    break;
                }
            }

            var count = Math.min(24, hTimes.length - startIndex);
            for (var k = startIndex; k < startIndex + count; k++) {
                var hourStr = OpenMeteo.formatHour(hTimes[k]);
                var hDate = new Date(hTimes[k]);
                var isHourDay = (hDate.getHours() >= 6 && hDate.getHours() < 22) ? 1 : 0;
                var hIcon = OpenMeteo.wmoToIcon(hCodes[k], isHourDay);
                var hTemp = OpenMeteo.convertTemperature(hTemps[k], Plasmoid.configuration?.temperatureUnit, false);

                hourlyForecastModel.append({
                    hour: hourStr,
                    icon: hIcon,
                    temperature: hTemp,
                    humidity: hHumidities ? hHumidities[k] : 0
                });
            }
        }

        hasData = true;
    }

    function refreshForecast() {
        var lat = root.targetLatitude;
        var lon = root.targetLongitude;

        if (lat === undefined || lon === undefined || isNaN(lat) || isNaN(lon)) {
            hasError = true;
            errorMessage = tr("Coordinates are not configured. Open widget settings.");
            return;
        }

        isLoading = true;
        hasError = false;

        OpenMeteo.fetchForecast(lat, lon, function(data) {
            isLoading = false;
            retryTimer.stop();
            if (!data || !data.current) {
                hasError = true;
                errorMessage = root.tr("Invalid response format from Open-Meteo");
                return;
            }

            parseWeatherData(data);
        }, function(err) {
            isLoading = false;
            hasError = true;
            errorMessage = err;
            if (!hasData || (Date.now() - root.lastSuccessfulFetchTimestamp > 5 * 60 * 1000)) {
                retryTimer.restart();
            }
        }, currentLanguage);
    }

    Component.onCompleted: {
        lastWatchdogTimestamp = Date.now();
        refreshForecast();
    }
}
