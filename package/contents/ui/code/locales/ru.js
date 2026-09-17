.pragma library

var locale = {
    id: "ru",
    name: "Русский",
    geocodingLang: "ru",
    units: {
        ms: "м/с",
        kmh: "км/ч",
        mph: "mph",
        mmhg: "мм рт. ст.",
        hpa: "гПа"
    },
    compass: ["С", "СВ", "В", "ЮВ", "Ю", "ЮЗ", "З", "СЗ"],
    daysOfWeek: ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"],
    monthsShort: ["янв", "фев", "мар", "апр", "мая", "июн", "июл", "авг", "сен", "окт", "ноя", "дек"],
    today: "Сегодня",
    tomorrow: "Завтра",
    formatDate: function(date, diffDays) {
        if (diffDays === 0) return this.today;
        if (diffDays === 1) return this.tomorrow;
        var day = date.getDate();
        var month = date.getMonth() + 1;
        var dayStr = (day < 10 ? "0" : "") + day;
        var monthStr = (month < 10 ? "0" : "") + month;
        return this.daysOfWeek[date.getDay()] + ", " + dayStr + "." + monthStr;
    },
    weatherDescriptions: {
        0: "Ясно",
        1: "Преимущественно ясно",
        2: "Переменная облачность",
        3: "Пасмурно",
        45: "Туман",
        48: "Изморозь",
        51: "Слабая морось",
        53: "Умеренная морось",
        55: "Плотная морось",
        56: "Ледяная морось",
        57: "Плотная ледяная морось",
        61: "Небольшой дождь",
        63: "Умеренный дождь",
        65: "Сильный дождь",
        66: "Слабый ледяной дождь",
        67: "Сильный ледяной дождь",
        71: "Небольшой снегопад",
        73: "Снегопад",
        75: "Сильный снегопад",
        77: "Снежные зёрна",
        80: "Слабый ливень",
        81: "Умеренный ливень",
        82: "Сильный ливень",
        85: "Слабый снежный шквал",
        86: "Сильный снегопад",
        95: "Гроза",
        96: "Гроза с небольшим градом",
        99: "Гроза с крупным градом",
        "default": "Без осадков"
    },
    strings: {
        // Applet & General
        "Weather (Open-Meteo)": "Погода (Open-Meteo)",
        "No location selected": "Локация не выбрана",
        "Not selected": "Не выбрана",
        "Open-Meteo": "Open-Meteo",
        "Loading data...": "Загрузка данных...",
        "No data": "Нет данных",
        "Updated at %1:%2": "Обновлено в %1:%2",
        "Refresh": "Обновить",
        "Refresh weather data": "Обновить данные о погоде",
        "Refresh Forecast": "Обновить прогноз",
        "Settings": "Настройки",
        "Configure widget...": "Открыть настройки виджета",
        "Could not load forecast": "Не удалось загрузить прогноз",
        "Retry": "Повторить",
        "Coordinates are not configured. Open widget settings.": "Координаты не настроены. Откройте настройки виджета.",
        "Coordinates are not set": "Координаты не заданы",
        "Invalid response format from Open-Meteo": "Неверный формат ответа от Open-Meteo",
        "Failed to load forecast: HTTP ": "Ошибка загрузки прогноза: HTTP ",
        "Forecast parsing error: ": "Ошибка парсинга прогноза: ",
        "Network error: HTTP ": "Ошибка сети: HTTP ",
        "Response parsing error: ": "Ошибка обработки ответа: ",

        // Weather details
        "Feels like:": "Ощущается:",
        "Feels like: ": "Ощущается как: ",
        "Wind:": "Ветер:",
        "Wind: ": "Ветер: ",
        "Humidity:": "Влажность:",
        "Pressure:": "Давление:",
        "Pressure: ": "Давление: ",
        "Forecast:": "Прогноз:",
        "7 days": "7 дней",
        "24 hours": "24 часа",

        // Categories
        "Weather Station": "Метеостанция",
        "Units": "Единицы",
        "Appearance": "Внешний вид",

        // Settings: Appearance
        "Language:": "Язык интерфейса:",
        "Task Manager / Panel:": "Панель задач:",
        "Show weather icon": "Показывать значок погоды",
        "Default forecast view:": "Режим прогноза по умолчанию:",
        "Daily (7 days)": "По дням (7 дней)",
        "Hourly (24 hours)": "По часам (24 часа)",

        // Settings: Units
        "Temperature units:": "Единицы температуры:",
        "Celsius (°C)": "Цельсий (°C)",
        "Fahrenheit (°F)": "Фаренгейт (°F)",
        "Wind speed units:": "Скорость ветра:",
        "Meters per second (m/s)": "Метры в секунду (м/с)",
        "Kilometers per hour (km/h)": "Километры в час (км/ч)",
        "Miles per hour (mph)": "Мили в час (mph)",
        "Pressure units:": "Атмосферное давление:",
        "Millimeters of mercury (mmHg)": "Миллиметры ртутного столба (мм рт. ст.)",
        "Hectopascals (hPa)": "Гектопаскали (гПа / hPa)",

        // Settings: Weather Station
        "Current location:": "Текущая локация:",
        "Coordinates:": "Координаты:",
        "Not set": "Не заданы",
        "Update interval (min):": "Интервал обновления (мин):",
        "Search location": "Поиск города",
        "City name:": "Название города:",
        "For example: London, New York, Moscow...": "Например: Москва, Екатеринбург...",
        "Search": "Найти",
        "Searching...": "Поиск...",
        "Search results:": "Результаты поиска:",
        "Latitude: %1°, Longitude: %2°": "Широта: %1°, Долгота: %2°",
        "Selected: %1": "Выбрано: %1",
        "No locations found": "Ничего не найдено",
        "Found options: %1 (click to select)": "Найдено вариантов: %1 (нажмите для выбора)"
    }
};
