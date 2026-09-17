.pragma library
.import "I18n.js" as I18n

function searchLocations(query, callback, errorCallback, lang) {
    if (!query || query.trim().length === 0) {
        callback([]);
        return;
    }

    var cleanQuery = query.trim();
    var primaryLang = I18n.geocodingLanguage(lang);
    if (/[а-яё\u0400-\u04FF]/i.test(cleanQuery)) {
        primaryLang = "ru";
    }

    function doRequest(targetLang, onEmptyFallback) {
        var url = "https://geocoding-api.open-meteo.com/v1/search?name=" 
            + encodeURIComponent(cleanQuery) 
            + "&count=10&language=" + targetLang + "&format=json";

        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        var results = data.results || [];
                        if (results.length === 0 && onEmptyFallback) {
                            onEmptyFallback();
                        } else {
                            callback(results);
                        }
                    } catch (e) {
                        if (errorCallback) {
                            errorCallback(I18n.t("Response parsing error: ", lang) + e.message);
                        }
                    }
                } else {
                    if (errorCallback) {
                        errorCallback(I18n.t("Network error: HTTP ", lang) + xhr.status);
                    }
                }
            }
        };
        xhr.open("GET", url, true);
        xhr.send();
    }

    var fallbackLang = (primaryLang === "ru") ? "en" : "ru";
    doRequest(primaryLang, function() {
        doRequest(fallbackLang, null);
    });
}

function fetchForecast(lat, lon, callback, errorCallback, lang) {
    if (lat === undefined || lon === undefined) {
        if (errorCallback) {
            errorCallback(I18n.t("Coordinates are not set", lang));
        }
        return;
    }

    var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat 
        + "&longitude=" + lon 
        + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure"
        + "&hourly=temperature_2m,weather_code,relative_humidity_2m"
        + "&daily=weather_code,temperature_2m_max,temperature_2m_min"
        + "&wind_speed_unit=ms&timezone=auto&forecast_days=7";

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    callback(data);
                } catch (e) {
                    if (errorCallback) {
                        errorCallback(I18n.t("Forecast parsing error: ", lang) + e.message);
                    }
                }
            } else {
                if (errorCallback) {
                    errorCallback(I18n.t("Failed to load forecast: HTTP ", lang) + xhr.status);
                }
            }
        }
    };
    xhr.open("GET", url, true);
    xhr.send();
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
