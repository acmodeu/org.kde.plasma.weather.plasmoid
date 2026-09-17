#!/usr/bin/env bash

# Packaging script for Open-Meteo Weather Plasma 6 Plasmoid (.plasmoid file for GUI installation)

PLASMOID_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="${PLASMOID_DIR}/package"
OUTPUT_FILE="${PLASMOID_DIR}/org.kde.plasma.weather.openmeteo.plasmoid"

echo "Packaging Plasmoid into ${OUTPUT_FILE}..."

# Create .plasmoid archive using Python zipfile module
python3 -c "
import os, zipfile
package_dir = '${PACKAGE_DIR}'
output_filename = '${OUTPUT_FILE}'
with zipfile.ZipFile(output_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk(package_dir):
        for file in files:
            file_path = os.path.join(root, file)
            arcname = os.path.relpath(file_path, package_dir)
            zipf.write(file_path, arcname)
print('Package created successfully!')
"

if command -v kpackagetool6 >/dev/null 2>&1; then
    echo "Verifying package with kpackagetool6:"
    kpackagetool6 --type Plasma/Applet --show "${OUTPUT_FILE}"
fi

echo "Done! File ready for 'Install Widget from Local File...': ${OUTPUT_FILE}"
