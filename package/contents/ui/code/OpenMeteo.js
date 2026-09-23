.pragma library
.import "I18n.js" as I18n

var FORECAST_HOSTS = [
    "api.open-meteo.com",
    "customer-api-eu02.open-meteo.com",
    "historical-forecast-api.open-meteo.com"
];
var activeHostIndex = 0;

function createTimeoutTimer(parent, callback, delay) {
    if (!parent || typeof Qt === "undefined" || !Qt.createQmlObject) {
        return null;
    }
    try {
        var timer = Qt.createQmlObject('import QtQuick; Timer { interval: ' + delay + '; repeat: false; running: true; }', parent);
        if (timer && timer.triggered) {
            timer.triggered.connect(function() {
                try { timer.destroy(); } catch (e) {}
                callback();
            });
            return timer;
        }
    } catch (e) {
        // Fallback if dynamic object creation fails
    }
    return null;
}

function clearTimer(timer) {
    if (timer) {
        try {
            timer.stop();
            timer.destroy();
        } catch (e) {}
    }
}

function log(enabled, msg) {
    if (enabled) {
        console.log("[OpenMeteo] " + msg);
    }
}

function warn(enabled, msg) {
    if (enabled) {
        console.warn("[OpenMeteo] " + msg);
    }
}

function searchLocations(query, callback, errorCallback, lang, parentItem, enableLogging) {
    if (!query || query.trim().length === 0) {
        callback([]);
        return;
    }

    var cleanQuery = query.trim();
    var primaryLang = I18n.geocodingLanguage(lang);
    if (/[а-яё\u0400-\u04FF]/i.test(cleanQuery)) {
        primaryLang = "ru";
    }

    log(enableLogging, "Geocoding search: '" + cleanQuery + "' (" + primaryLang + ")");

    function doRequest(targetLang, onEmptyFallback) {
        var url = "https://geocoding-api.open-meteo.com/v1/search?name=" 
            + encodeURIComponent(cleanQuery) 
            + "&count=10&language=" + targetLang + "&format=json";

        var xhr = new XMLHttpRequest();
        var isHandled = false;
        var timer = null;

        function handleError(msg) {
            if (isHandled) return;
            isHandled = true;
            if (timer) {
                clearTimer(timer);
                timer = null;
            }
            try { xhr.abort(); } catch (e) {}
            warn(enableLogging, "Geocoding error: " + msg);
            if (errorCallback) {
                errorCallback(msg);
            }
        }

        timer = createTimeoutTimer(parentItem, function() {
            handleError(I18n.t("Network request timed out", lang));
        }, 10000);

        xhr.onerror = function() {
            handleError(I18n.t("Network request failed", lang));
        };

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (isHandled) return;
                if (timer) {
                    clearTimer(timer);
                    timer = null;
                }
                if (xhr.status === 200) {
                    isHandled = true;
                    try {
                        var data = JSON.parse(xhr.responseText);
                        var results = data.results || [];
                        if (results.length === 0 && onEmptyFallback) {
                            onEmptyFallback();
                        } else {
                            log(enableLogging, "Geocoding found " + results.length + " locations");
                            callback(results);
                        }
                    } catch (e) {
                        handleError(I18n.t("Response parsing error: ", lang) + e.message);
                    }
                } else if (xhr.status > 0) {
                    handleError(I18n.t("Network error: HTTP ", lang) + xhr.status);
                }
            }
        };

        try {
            xhr.open("GET", url, true);
            xhr.send();
        } catch (e) {
            handleError(I18n.t("Network request failed", lang) + ": " + e.message);
        }
    }

    var fallbackLang = (primaryLang === "ru") ? "en" : "ru";
    doRequest(primaryLang, function() {
        doRequest(fallbackLang, null);
    });
}

function fetchForecast(lat, lon, callback, errorCallback, lang, parentItem, enableLogging) {
    if (lat === undefined || lon === undefined) {
        if (errorCallback) {
            errorCallback(I18n.t("Coordinates are not set", lang));
        }
        return;
    }

    var query = "latitude=" + lat 
        + "&longitude=" + lon 
        + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure"
        + "&hourly=temperature_2m,weather_code,relative_humidity_2m,is_day"
        + "&daily=weather_code,temperature_2m_max,temperature_2m_min"
        + "&wind_speed_unit=ms&timezone=auto&forecast_days=7";

    var lastErrorMessage = "";

    function tryHost(offset) {
        if (offset >= FORECAST_HOSTS.length) {
            warn(enableLogging, "All " + FORECAST_HOSTS.length + " hosts failed to load forecast");
            if (errorCallback) {
                errorCallback(lastErrorMessage || I18n.t("Network request failed", lang));
            }
            return;
        }

        var hostIdx = (activeHostIndex + offset) % FORECAST_HOSTS.length;
        var host = FORECAST_HOSTS[hostIdx];
        var url = "https://" + host + "/v1/forecast?" + query;

        log(enableLogging, "Requesting forecast from " + host + " (attempt " + (offset + 1) + "/" + FORECAST_HOSTS.length + ")");

        var xhr = new XMLHttpRequest();
        var isHandled = false;
        var timer = null;

        function tryNext(msg) {
            if (isHandled) return;
            isHandled = true;
            if (timer) {
                clearTimer(timer);
                timer = null;
            }
            lastErrorMessage = msg;
            warn(enableLogging, "Host " + host + " failed (" + msg + "), trying next mirror...");
            try { xhr.abort(); } catch (e) {}
            tryHost(offset + 1);
        }

        // 3.5s timeout per host for fast failover when IP is blocked
        timer = createTimeoutTimer(parentItem, function() {
            tryNext(I18n.t("Network request timed out", lang));
        }, 3500);

        xhr.onerror = function() {
            tryNext(I18n.t("Network request failed", lang));
        };

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (isHandled) return;
                if (timer) {
                    clearTimer(timer);
                    timer = null;
                }
                if (xhr.status === 200) {
                    isHandled = true;
                    try {
                        var data = JSON.parse(xhr.responseText);
                        activeHostIndex = hostIdx; // Remember working host for subsequent fast requests
                        log(enableLogging, "Forecast successfully loaded from " + host);
                        callback(data);
                    } catch (e) {
                        tryNext(I18n.t("Forecast parsing error: ", lang) + e.message);
                    }
                } else if (xhr.status > 0) {
                    tryNext(I18n.t("Failed to load forecast: HTTP ", lang) + xhr.status);
                }
            }
        };

        try {
            xhr.open("GET", url, true);
            xhr.send();
        } catch (e) {
            tryNext(I18n.t("Network request failed", lang) + ": " + e.message);
        }
    }

    tryHost(0);
}

function wmoToIcon(code, isDay) {
    var day = (isDay === undefined || isDay === 1);
    switch (code) {
        case 0:
            return day ? "weather-clear" : "weather-clear-night";
        case 1:
            return day ? "weather-few-clouds" : "weather-few-clouds-night";
        case 2:
            return day ? "weather-clouds" : "weather-clouds-night";
        case 3:
            return "weather-overcast";
        case 45:
        case 48:
            return "weather-fog";
        case 51:
        case 53:
        case 55:
            return "weather-showers-scattered";
        case 56:
        case 57:
        case 66:
        case 67:
            return "weather-freezing-rain";
        case 61:
            return "weather-showers-scattered";
        case 63:
        case 65:
        case 80:
        case 81:
            return "weather-showers";
        case 71:
        case 77:
        case 85:
            return "weather-snow-scattered";
        case 73:
        case 75:
        case 86:
            return "weather-snow";
        case 82:
        case 95:
        case 96:
        case 99:
            return "weather-storm";
        default:
            return day ? "weather-few-clouds" : "weather-few-clouds-night";
    }
}

function wmoToDescription(code, lang) {
    return I18n.weatherDescription(code, lang);
}

function convertTemperature(celsius, unit) {
    if (celsius === null || celsius === undefined || isNaN(celsius)) {
        return "--";
    }

    if (unit === "fahrenheit") {
        var f = Math.round(celsius * 9 / 5 + 32);
        return f + "°";
    } else {
        var c = Math.round(celsius);
        var sign = c > 0 ? "+" : "";
        return sign + c + "°";
    }
}

function convertSpeed(ms, unit, lang) {
    return I18n.formatSpeed(ms, unit, lang);
}

function convertPressure(hPa, unit, lang) {
    return I18n.formatPressure(hPa, unit, lang);
}

function degreesToCompass(deg, lang) {
    return I18n.compassDirection(deg, lang);
}

function formatDayOfWeek(dateStr, lang) {
    return I18n.formatDayOfWeek(dateStr, lang);
}

function formatHour(timeStr) {
    if (!timeStr) return "";
    var parts = timeStr.split("T");
    if (parts.length > 1) {
        return parts[1];
    }
    return timeStr;
}
