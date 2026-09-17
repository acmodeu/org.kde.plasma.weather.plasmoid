# Weather Report (Open-Meteo) for KDE Plasma 6

[![KDE Plasma 6](https://img.shields.io/badge/KDE%20Plasma-6.0%2B-blue.svg)](https://kde.org/plasma-desktop/)
[![Qt 6](https://img.shields.io/badge/Qt-6-green.svg)](https://www.qt.io/)
[![License: GPL v2+](https://img.shields.io/badge/License-GPLv2%2B-blue.svg)](LICENSE)

A native KDE Plasma 6 desktop and panel widget providing accurate weather forecasts powered by **[Open-Meteo](https://open-meteo.com/)**.

---

## ✨ Features / Возможности

- 🌐 **No API Keys Required**: Zero configuration setup, no registration, tokens, or subscription limits needed.
- 🚀 **Unrestricted Global Access**: Works reliably worldwide (including Russia without VPN or proxy services, unlike many default weather providers).
- 🔍 **Multi-Language City Search**: Built-in Open-Meteo Geocoding finds cities, towns, and regions in both English and Russian.
- 🌡️ **Flexible Units of Measurement**:
  - **Temperature**: Celsius (°C) or Fahrenheit (°F).
  - **Wind Speed**: m/s (meters/second), km/h, or mph with 16-point compass directions.
  - **Pressure**: **mmHg** (мм рт. ст.) or **hPa** (hectopascals).
- 📅 **Dual Forecast Modes in Card**:
  - **7-day daily forecast**: Includes min/max temperatures and specific calendar dates for upcoming days.
  - **24-hour hourly forecast**: Temperature, weather conditions, and precipitation tracking.
- 🎨 **Panel Integration**:
  - Compact panel mode displaying current temperature and weather icon.
  - Fully reactive to Plasma themes and color schemes.
  - Option to hide/show weather icon on panel.
- 🌍 **Modular Extensible Localization**:
  - English (US) by default, optional Russian interface.
  - Modular architecture with standalone locale definitions (`en_US.js`, `ru.js`) in `package/contents/ui/code/locales/`.

---

## 📋 Prerequisites

- **KDE Plasma 6** (`plasma-workspace` >= 6.0)
- **KDE Frameworks 6** & **Qt 6** (with `qml-module-org-kde-plasma-plasmoid`, `kirigami`)
- **KDE Development Tools** (`kpackagetool6`, included in `plasma-sdk` or standard base development packages)

---

## 🚀 Installation

### Option 1: Automatic Installer (Recommended)

Clone the repository and run the installation script:

```bash
git clone https://github.com/acmodeu/org.kde.plasma.weather.plasmoid.git
cd org.kde.plasma.weather.plasmoid
./install.sh
```

The installer script (`install.sh`) automates the following steps:
1. **Clears Plasma QML cache**: Removes `~/.cache/plasmashell/qmlcache` and `~/.cache/plasma*` to ensure modified QML files and assets are recompiled fresh instead of using outdated cached bytecode.
2. **Pauses `plasmashell`**: Gracefully stops the running Plasma desktop shell (via `systemd` or `kquitapp6`) to prevent file-locking issues during installation.
3. **Installs/Updates package**: Uses `kpackagetool6` to install or upgrade the plasmoid into `~/.local/share/plasma/plasmoids/org.kde.plasma.weather.openmeteo`.
4. **Rebuilds system cache**: Runs `kbuildsycoca6` to register the new/updated applet in KDE's plugin database.
5. **Restarts `plasmashell`**: Relaunches the Plasma shell so the widget is immediately available without logging out or rebooting.

---

### Option 2: Install via KDE GUI Widget Installer

1. Generate the `.plasmoid` archive:
   ```bash
   ./pack.sh
   ```
2. Right-click on your Plasma panel or Desktop.
3. Select **Add Widgets...** -> **Get New Widgets** -> **Install Widget From Local File...**
4. Choose the generated `org.kde.plasma.weather.openmeteo.plasmoid` file.

---

### Option 3: Developer Symlink Mode

If you are developing or modifying the widget, link the package directory directly into your user plasmoids folder:

```bash
ln -sfn "$(pwd)/package" ~/.local/share/plasma/plasmoids/org.kde.plasma.weather.openmeteo
kbuildsycoca6
systemctl --user restart plasma-plasmashell.service
```

---

## ⚙️ How to Add to Panel

1. Right-click on the panel -> **Add Widgets...**.
2. Search for **"Weather (Open-Meteo)"** or **"Погода"**.
3. Drag and drop the widget onto your panel.
4. Right-click the widget -> **Configure Weather (Open-Meteo)...** to select your city and preferred units.

---

## 📂 Project Structure

```text
.
├── package/
│   ├── metadata.json                 # Plasma 6 applet metadata (ID: org.kde.plasma.weather.openmeteo)
│   └── contents/
│       ├── config/
│       │   ├── main.xml              # KConfigXT settings schema
│       │   └── config.qml            # Settings dialog tabs model
│       └── ui/
│           ├── main.qml              # Main applet entry point & data controller
│           ├── CompactRepresentation.qml  # Panel representation (temperature & icon)
│           ├── FullRepresentation.qml     # Detailed forecast popup card
│           ├── ConfigWeatherStation.qml   # City search & location settings
│           ├── ConfigUnits.qml            # Temperature, wind, pressure & language units
│           ├── ConfigAppearance.qml       # Visual appearance settings
│           ├── icons/
│           │   ├── weather-wind.svg       # Bundled wind condition icon
│           │   └── temperature-normal.svg # Bundled feels-like icon
│           └── code/
│               ├── OpenMeteo.js      # API client & weather conversions
│               ├── I18n.js           # Translation dispatcher
│               └── locales/
│                   ├── en_US.js      # English (US) translations
│                   └── ru.js         # Russian translations
├── install.sh                        # Automated installer script
├── uninstall.sh                      # Clean removal script
├── pack.sh                           # .plasmoid bundle packager
├── .gitignore                        # Git ignore rules
├── LICENSE                           # GNU General Public License v2.0 or later
└── README.md                         # Project documentation
```

---

## 🗑️ Uninstallation

To remove the plasmoid and clean up cached files:

```bash
./uninstall.sh
```

---

## 📄 License

This project is licensed under the [GNU General Public License v2.0 or later](LICENSE).
Weather data provided by [Open-Meteo](https://open-meteo.com/) under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
