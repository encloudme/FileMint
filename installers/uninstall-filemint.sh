#!/usr/bin/env bash
# ==============================================================================
# 🗑️ FileMint App Uninstaller for GNOME (v15.0)
# Cleanly removes local space desktop shortcuts, hicolor icons, and app dirs
# ==============================================================================
set -e

# ANSI Color Styling
GREEN='\033[0;92m'
BLUE='\033[0;94m'
RED='\033[0;91m'
YELLOW='\033[1;93m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${RED}${BOLD}=====================================================================${NC}"
echo -e "${RED}${BOLD} 🗑️  Uninstalling FileMint - File Consolidation & Archiving Engine   ${NC}"
echo -e "${RED}${BOLD}=====================================================================${NC}"

# Prompt for confirmation
read -r -p "$(echo -e " 📥 ${GREEN}${BOLD}Are you sure you want to completely uninstall FileMint? (y/N): ${NC}")" choice
if [[ ! "$choice" =~ ^[Yy]$ ]]; then
    echo -e " 🛑 ${GREEN}${BOLD}[Cancel] Uninstallation aborted by user.${NC}"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Prioritize active user config over repository template
CONFIG_FILE="$HOME/.config/filemint-app/appConfig.json"
if [ ! -f "$CONFIG_FILE" ] && [ -f "$REPO_ROOT/config/appConfig.json" ]; then
    CONFIG_FILE="$REPO_ROOT/config/appConfig.json"
fi

APP_NAME="FileMint"
ICON_NAME="filemint.png"
APP_INSTALL_DIR="$HOME/.local/share/filemint-app"
APPDATA_DIR="$HOME/.config/filemint-app"
DESKTOP_APPS_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"

if [ -f "$CONFIG_FILE" ] && command -v python3 &> /dev/null; then
    eval "$(python3 -c "
import json, os
with open('$CONFIG_FILE') as f:
    cfg = json.load(f)
meta = cfg.get('app_metadata', {})
dirs = cfg.get('directories', {})
home = os.path.expanduser('~')
def expand(p): return str(p or '').replace('{HOME}', home).replace('~', home)
print(f\"APP_NAME='{meta.get('name', 'FileMint')}'\")
print(f\"ICON_NAME='{meta.get('icon_filename', 'filemint.png')}'\")
print(f\"APP_INSTALL_DIR='{expand(dirs.get('APP_INSTALL_DIR', '~/.local/share/filemint-app'))}'\")
print(f\"APPDATA_DIR='{expand(dirs.get('APPDATA_DIR', '~/.config/filemint-app'))}'\")
print(f\"DESKTOP_APPS_DIR='{expand(dirs.get('DESKTOP_APPS_DIR', '~/.local/share/applications'))}'\")
print(f\"ICON_DIR='{expand(dirs.get('ICON_DIR', '~/.local/share/icons'))}'\")
" 2>/dev/null || true)"
fi

DESKTOP_FILE="$DESKTOP_APPS_DIR/filemint.desktop"
HICOLOR_BASE="$ICON_DIR/hicolor"

printf "\n"
echo -e " ▶️ ${YELLOW}Commencing uninstallation sequence...${NC}"
printf "\n"

# 1. Remove Desktop Shortcut
echo -e "\n 🗑️ ${YELLOW}[1/4] Removing GNOME Desktop shortcut entry...${NC}"
if [ -f "$DESKTOP_FILE" ]; then
    rm -f "$DESKTOP_FILE"
    echo -e "${BLUE}     🧹 Removed: $DESKTOP_FILE${NC}"
else
    echo -e "${BLUE}     -> No desktop shortcut entry found to remove.${NC}"
fi

# 2. Remove Application Icons
echo -e "\n 🗑️ ${YELLOW}[2/4] Removing GNOME Desktop application icon & hicolor icons...${NC}"
if [ -f "$ICON_DIR/$ICON_NAME" ]; then
    rm -f "$ICON_DIR/$ICON_NAME"
    echo -e "     ${GREEN}✔ Removed:${NC} $ICON_DIR/$ICON_NAME"
fi

ICON_SIZES=("16x16" "32x32" "48x48" "64x64" "128x128" "256x256" "512x512")
REMOVED_COUNT=0
for SIZE in "${ICON_SIZES[@]}"; do
    TARGET_ICON="$HICOLOR_BASE/$SIZE/apps/$ICON_NAME"
    if [ -f "$TARGET_ICON" ]; then
        rm -f "$TARGET_ICON"
        echo -e "     ${GREEN}✔ Removed ($SIZE):${NC} $TARGET_ICON"
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    fi
done

if [ "$REMOVED_COUNT" -eq 0 ]; then
    echo -e "     ${YELLOW}ℹ No hicolor icons found under: $HICOLOR_BASE${NC}"
fi

# 3. Delete Application Executable Directory
echo -e "\n 🗑️ ${YELLOW}[3/4] Deleting application source directories and binaries...${NC}"
if [ -d "$APP_INSTALL_DIR" ]; then
    rm -rf "$APP_INSTALL_DIR"
    echo -e "${BLUE}     🧹 Removed directory: $APP_INSTALL_DIR${NC}"
else
    echo -e "     ${YELLOW}ℹ Installation directory not found: $APP_INSTALL_DIR${NC}"
fi

# Optional removal of user configuration directory
read -r -p "$(echo -e "\n ${RED}❔ Do you also want to remove user settings ($APPDATA_DIR)? (y/N): ${NC}")" purge_config
if [[ "$purge_config" =~ ^[Yy]$ ]] && [ -d "$APPDATA_DIR" ]; then
    rm -rf "$APPDATA_DIR"
    echo -e "${BLUE}     🧹 Removed user configuration: $APPDATA_DIR${NC}"
else
    echo -e "${GREEN}     ✔ User settings preserved at $APPDATA_DIR${NC}"
fi

# 4. Refresh GNOME Databases
echo -e "\n 🔄 ${YELLOW}[4/4] Refreshing local desktop application indexing registry...${NC}"
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_APPS_DIR" || true
    echo -e "     ${GREEN}✔ Desktop database updated.${NC}"
fi

if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$ICON_DIR" 2>/dev/null || true
    gtk-update-icon-cache -f -t "$HICOLOR_BASE" 2>/dev/null || true
    echo -e "     ${GREEN}✔ GTK icon cache updated.${NC}"
fi

echo -e "\n${GREEN}${BOLD}=====================================================================${NC}"
echo -e "${GREEN}${BOLD}  ✨ Uninstallation of ${APP_NAME} Completed Successfully!           ${NC}"
echo -e "${GREEN}${BOLD}=====================================================================${NC}"
echo -e "Application shortcuts, hicolor icons, and installed files have been stripped."
echo -e "${GREEN}${BOLD}=====================================================================\n${NC}"
