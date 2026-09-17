.pragma library

var locale = {
    id: "en_US",
    name: "English (US)",
    geocodingLang: "en",
    units: {
        ms: "m/s",
        kmh: "km/h",
        mph: "mph",
        mmhg: "mmHg",
        hpa: "hPa"
    },
    compass: ["N", "NE", "E", "SE", "S", "SW", "W", "NW"],
    daysOfWeek: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
    monthsShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    today: "Today",
    tomorrow: "Tomorrow",
    formatDate: function(date, diffDays) {
        if (diffDays === 0) return this.today;
        if (diffDays === 1) return this.tomorrow;
        return this.daysOfWeek[date.getDay()] + ", " + this.monthsShort[date.getMonth()] + " " + date.getDate();
    },
    weatherDescriptions: {
        0: "Clear sky",
        1: "Mainly clear",
        2: "Partly cloudy",
        3: "Overcast",
        45: "Fog",
        48: "Rime fog",
        51: "Light drizzle",
        53: "Moderate drizzle",
        55: "Dense drizzle",
        56: "Light freezing drizzle",
        57: "Dense freezing drizzle",
        61: "Slight rain",
        63: "Moderate rain",
        65: "Heavy rain",
        66: "Light freezing rain",
        67: "Heavy freezing rain",
        71: "Slight snow fall",
        73: "Moderate snow fall",
        75: "Heavy snow fall",
        77: "Snow grains",
        80: "Slight rain showers",
        81: "Moderate rain showers",
        82: "Violent rain showers",
        85: "Slight snow showers",
        86: "Heavy snow showers",
        95: "Thunderstorm",
        96: "Thunderstorm with slight hail",
        99: "Thunderstorm with heavy hail",
        "default": "Clear"
    },
    strings: {
        // Applet & General
        "Weather (Open-Meteo)": "Weather (Open-Meteo)",
        "No location selected": "No location selected",
        "Not selected": "Not selected",
        "Open-Meteo": "Open-Meteo",
        "Loading data...": "Loading data...",
        "No data": "No data",
        "Updated at %1:%2": "Updated at %1:%2",
        "Refresh": "Refresh",
        "Refresh weather data": "Refresh weather data",
        "Refresh Forecast": "Refresh Forecast",
        "Settings": "Settings",
        "Configure widget...": "Configure widget...",
        "Could not load forecast": "Could not load forecast",
        "Retry": "Retry",
        "Coordinates are not configured. Open widget settings.": "Coordinates are not configured. Open widget settings.",
        "Coordinates are not set": "Coordinates are not set",
        "Invalid response format from Open-Meteo": "Invalid response format from Open-Meteo",
        "Failed to load forecast: HTTP ": "Failed to load forecast: HTTP ",
        "Forecast parsing error: ": "Forecast parsing error: ",
        "Network error: HTTP ": "Network error: HTTP ",
        "Response parsing error: ": "Response parsing error: ",

        // Weather details
        "Feels like:": "Feels like:",
        "Feels like: ": "Feels like: ",
        "Wind:": "Wind:",
        "Wind: ": "Wind: ",
        "Humidity:": "Humidity:",
        "Pressure:": "Pressure:",
        "Pressure: ": "Pressure: ",
        "Forecast:": "Forecast:",
        "7 days": "7 days",
        "24 hours": "24 hours",

        // Categories
        "Weather Station": "Weather Station",
        "Units": "Units",
        "Appearance": "Appearance",

        // Settings: Appearance
        "Language:": "Language:",
        "Task Manager / Panel:": "Task Manager / Panel:",
        "Show weather icon": "Show weather icon",
        "Default forecast view:": "Default forecast view:",
        "Daily (7 days)": "Daily (7 days)",
        "Hourly (24 hours)": "Hourly (24 hours)",

        // Settings: Units
        "Temperature units:": "Temperature units:",
        "Celsius (°C)": "Celsius (°C)",
        "Fahrenheit (°F)": "Fahrenheit (°F)",
        "Wind speed units:": "Wind speed units:",
        "Meters per second (m/s)": "Meters per second (m/s)",
        "Kilometers per hour (km/h)": "Kilometers per hour (km/h)",
        "Miles per hour (mph)": "Miles per hour (mph)",
        "Pressure units:": "Pressure units:",
        "Millimeters of mercury (mmHg)": "Millimeters of mercury (mmHg)",
        "Hectopascals (hPa)": "Hectopascals (hPa)",

        // Settings: Weather Station
        "Current location:": "Current location:",
        "Coordinates:": "Coordinates:",
        "Not set": "Not set",
        "Update interval (min):": "Update interval (min):",
        "Search location": "Search location",
        "City name:": "City name:",
        "For example: London, New York, Moscow...": "For example: London, New York, Moscow...",
        "Search": "Search",
        "Searching...": "Searching...",
        "Search results:": "Search results:",
        "Latitude: %1°, Longitude: %2°": "Latitude: %1°, Longitude: %2°",
        "Selected: %1": "Selected: %1",
        "No locations found": "No locations found",
        "Found options: %1 (click to select)": "Found options: %1 (click to select)"
    }
};
