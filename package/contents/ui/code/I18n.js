.pragma library
.import "locales/en_US.js" as LocaleEn
.import "locales/ru.js" as LocaleRu

var DEFAULT_LOCALE = "en_US";

var locales = {
    "en_US": LocaleEn.locale,
    "ru": LocaleRu.locale
};

function getLocale(lang) {
    if (lang && locales[lang]) {
        return locales[lang];
    }
    return locales[DEFAULT_LOCALE];
}

function getAvailableLocales() {
    var list = [];
    for (var key in locales) {
        if (locales.hasOwnProperty(key)) {
            list.push({ text: locales[key].name, value: locales[key].id });
        }
    }
    return list;
}

function t(key, lang, p1, p2) {
    var loc = getLocale(lang);
    var defLoc = locales[DEFAULT_LOCALE];
    var str = (loc.strings && loc.strings[key] !== undefined)
        ? loc.strings[key]
        : ((defLoc.strings && defLoc.strings[key] !== undefined) ? defLoc.strings[key] : key);
    if (p1 !== undefined) {
        str = str.replace("%1", p1);
    }
    if (p2 !== undefined) {
        str = str.replace("%2", p2);
    }
    return str;
}

function weatherDescription(code, lang) {
    var loc = getLocale(lang);
    var defLoc = locales[DEFAULT_LOCALE];
    if (loc.weatherDescriptions && loc.weatherDescriptions[code] !== undefined) {
        return loc.weatherDescriptions[code];
    }
    if (defLoc.weatherDescriptions && defLoc.weatherDescriptions[code] !== undefined) {
        return defLoc.weatherDescriptions[code];
    }
    return loc.weatherDescriptions["default"] || "Clear";
}

function compassDirection(deg, lang) {
    if (deg === null || deg === undefined || isNaN(deg)) return "";
    var loc = getLocale(lang);
    var idx = Math.round(deg / 45) % 8;
    return loc.compass[idx] || "";
}

function formatSpeed(ms, unit, lang) {
    if (ms === null || ms === undefined || isNaN(ms)) return "--";
    var loc = getLocale(lang);
    if (unit === "kmh") {
        return Math.round(ms * 3.6) + " " + loc.units.kmh;
    } else if (unit === "mph") {
        return Math.round(ms * 2.23694) + " " + loc.units.mph;
    } else {
        return (Math.round(ms * 10) / 10) + " " + loc.units.ms;
    }
}

function formatPressure(hPa, unit, lang) {
    if (hPa === null || hPa === undefined || isNaN(hPa)) return "--";
    var loc = getLocale(lang);
    if (unit === "hpa") {
        return Math.round(hPa) + " " + loc.units.hpa;
    } else {
        return Math.round(hPa * 0.75006375541921) + " " + loc.units.mmhg;
    }
}

function formatDayOfWeek(dateStr, lang) {
    if (!dateStr) return "";
    var parts = dateStr.split("-");
    if (parts.length < 3) return dateStr;
    var targetDate = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
    var today = new Date();
    today.setHours(0, 0, 0, 0);

    var diffDays = Math.round((targetDate - today) / (1000 * 60 * 60 * 24));
    var loc = getLocale(lang);
    return loc.formatDate(targetDate, diffDays);
}

function geocodingLanguage(lang) {
    var loc = getLocale(lang);
    return loc.geocodingLang || "en";
}
