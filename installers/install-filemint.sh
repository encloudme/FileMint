#!/usr/bin/env bash
# ==============================================================================
# 🧮 FileMint Public Interactive Installer Engine (v15.0)
# Supports pre-compiled standalone binary deployment & Python source fallback.
# ==============================================================================
set -e

# ==============================================================================
# --- ANSI Styling Palette ---
# ==============================================================================
GREEN='\033[0;92m'
BLUE='\033[0;94m'
YELLOW='\033[1;93m'
RED='\033[0;91m'
NC='\033[0m'
BOLD='\033[1m'

log_separator() { echo -e "${BLUE}${BOLD}=========================================================================\n${NC}"; }

# Helper function to compute SHA-256 hash safely
get_file_sha256() {
    if [ ! -f "$1" ]; then
        echo "MISSING"
        return
    fi
    if command -v sha256sum &>/dev/null; then
        sha256sum "$1" 2>/dev/null | awk '{print $1}'
    elif command -v shasum &>/dev/null; then
        shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'
    else
        echo "UNKNOWN"
    fi
}

DESKTOP_UPDATED=false
ICON_UPDATED=false


# ==============================================================================
# --- Installer header ---
# ==============================================================================

echo -e "${BLUE}${BOLD}=========================================================================${NC}"
echo -e "${BLUE}${BOLD}      ⚙️  FileMint Interactive Desktop Installer & Setup Engine (v15.0)    ${NC}"
log_separator

# Prompt for installation confirmation
read -r -p "$(echo -e " 📥 ${GREEN}${BOLD}Do you want to proceed with installing FileMint? (y/N): ${NC}")" choice
if [[ ! "$choice" =~ ^[Yy]$ ]]; then
    echo -e " 🛑 ${RED}${BOLD}[Cancel] Installation aborted by user.${NC}"
    exit 0
fi

# ==============================================================================
# 1. System Resolution & Payload Scanning
# ==============================================================================
echo -e "\n${BOLD}📁 Step 1: Setting up directories and scanning installation executables...${NC}"
HOME_DIR="$HOME"

# Resolve project root directory relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Define installation target directories
APP_INSTALL_DIR="$HOME_DIR/.local/share/filemint-app"
APPDATA_DIR="$HOME_DIR/.config/filemint-app"
DESKTOP_APPS_DIR="$HOME_DIR/.local/share/applications"

# Icon directories and hicolor sizes
ICON_BASE_DIR="$HOME_DIR/.local/share/icons"
HICOLOR_DIR="$ICON_BASE_DIR/hicolor"
HICOLOR_SIZES=("16x16" "32x32" "48x48" "64x64" "128x128" "256x256" "512x512")

# Default paths for interactive overrides
DEFAULT_INSTALL_DIR="$HOME_DIR/.local/share/filemint-app"
DEFAULT_APPDATA_DIR="$HOME_DIR/.config/filemint-app"
DEFAULT_OUTPUT_DIR="$HOME_DIR/Documents/FileMint/Output"
DEFAULT_ARCHIVE_DIR="$HOME_DIR/Documents/FileMint/Archive"

# Scan repository for executables
echo -e "\n${BOLD}🔍 Scanning payload repository for executables...${NC}"

SEARCH_PATHS=("$REPO_ROOT")
# searches executables, standalone, raw source files in folders viz. /releases, /installers, and /src
for dir in releases installers src; do
    [[ -d "$REPO_ROOT/$dir" ]] && SEARCH_PATHS+=("$REPO_ROOT/$dir")
done

# Match pre-compiled binaries:
# filemint, filemint.bin, filemint-v15.0.1, FileMint, FileMint.bin, etc.
BIN_FILE=$(
    find "${SEARCH_PATHS[@]}" -maxdepth 1 -type f \
        \( -iname 'filemint' -o -iname 'filemint.bin' -o -iname 'filemint-*' \) \
        ! -iname '*.zip' ! -iname '*.tar.gz' ! -iname '*.txt' ! -iname '*.sh' ! -iname '*.py' ! -iname '*.png' \
        ! -iname '*.ico' ! -iname '*.bat' ! -iname '*.md' ! -iname '*.bak' 2>/dev/null | head -n 1
)

# Match Python entry script case-insensitively (e.g. filemint.py, FileMint.py, FILEMINT.PY):
PY_FILE=$(
    find "${SEARCH_PATHS[@]}" -maxdepth 1 -type f \
        -iname 'filemint.py' 2>/dev/null | head -n 1
)

INSTALLED_BIN=""
INSTALLED_PY=""
# ==============================================================================
#  --- Installation flow decided by executable file availability ---
# ==============================================================================

# Fail fast if no runnable payload exists
if [ -z "$BIN_FILE" ] && [ -z "$PY_FILE" ]; then
    echo -e "${RED}🛑 Neither compiled binary nor Python source entry point found in:${NC}"
    for p in "${SEARCH_PATHS[@]}"; do echo -e "   - $p"; done
    log_separator
    exit 1
fi

# Pre-flight selection & audits
if [ -n "$BIN_FILE" ] && [ -f "$BIN_FILE" ]; then
    echo -e "   -> ${GREEN}✔ Standalone binary executable detected: $(basename "$BIN_FILE")${NC}"
    echo -e "   -> ${GREEN}✔ Skipping Python/Tkinter runtime dependency audit (Zero-dependency binary deployment).${NC}"
    read -r -p "$(echo -e "   ${BLUE}❔ Verify the binary/executable file and proceed with installation [CONFIRM]? (y/N): ${NC}")" inst_choice
    if [[ ! "$inst_choice" =~ ^[Yy]$ ]]; then
        echo -e "${RED}🛑 Installation aborted by user. Please check payload directory.${NC}\n"
        log_separator
        exit 1
    fi
elif [ -n "$PY_FILE" ] && [ -f "$PY_FILE" ]; then
    echo -e "   -> ${YELLOW}ℹ No pre-compiled binary found${NC}"
    echo -e "   -> ${GREEN}✔ Raw source code detected: $(basename "$PY_FILE")${NC}"
    read -r -p "$(echo -e "   ${BLUE}❔ Would you like to proceed installation using source code [CONFIRM]? (y/N): ${NC}")" py_choice
    if [[ ! "$py_choice" =~ ^[Yy]$ ]]; then
        echo -e "${RED}🛑 Installation aborted by user.${NC}\n"
        log_separator
        exit 1
    fi
    log_separator
    echo -e "   -> ${YELLOW}Initiating Python source dependency audit...${NC}"

    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}❌ [Error] Python3 runtime command is not installed on your system.${NC}"
        log_separator
        exit 1
    fi

    # Check CLI utilities
    MISSING_DEPS=()
    for cmd in tar zip update-desktop-database; do
        if ! command -v "$cmd" &> /dev/null; then
            MISSING_DEPS+=("$cmd")
        fi
    done

    if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
        echo -e "   -> ${YELLOW}Warning: Missing optional utilities: ${MISSING_DEPS[*]}${NC}"
        echo -e "      Refer to README.md for complete dependency installation steps."
    fi

    # Check Tkinter
    if ! python3 -c "import tkinter" &> /dev/null; then
        echo -e "   -> ${YELLOW}⚠ Warning: Python Tkinter GUI library was not detected on this environment.${NC}"
        echo -e "      Installation commands to enable Tkinter:"
        echo -e "        - Debian/Ubuntu:  ${BOLD}sudo apt install python3-tk${NC}"
        echo -e "        - Fedora/RHEL:    ${BOLD}sudo dnf install python3-tkinter${NC}"
        echo -e "        - Arch Linux:     ${BOLD}sudo pacman -S tk${NC}"
        read -r -p "$(echo -e "   ${BLUE}❔ Proceed with desktop installation anyway? (y/N): ${NC}")" tk_choice
        if [[ ! "$tk_choice" =~ ^[Yy]$ ]]; then
            echo -e "${RED}🛑 Installation aborted by user. Please install Tkinter and retry.${NC}\n"
            log_separator
            exit 1
        fi
    else
        echo -e "   -> ${GREEN}✔ Tkinter library detected successfully.${NC}"
    fi

    echo -e "   -> ${GREEN}✔ Source dependencies verified successfully.${NC}"
fi

# ==============================================================================
# 2. Interactive Target Directory Configuration
# ==============================================================================
log_separator
echo -e "${BOLD}📁 Step 2: Configure Target Installation & System Folders...${NC}\n"

read -rp "$(echo -e "   Application Install Directory [Default: ${BLUE}$DEFAULT_INSTALL_DIR${NC}] (hit ⤶ to accept):\n   > ")" USER_INSTALL_DIR
APP_INSTALL_DIR="${USER_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"

read -rp "$(echo -e "   Configuration Path Directory [Default: ${BLUE}$DEFAULT_APPDATA_DIR${NC}] (hit ⤶ to accept):\n   > ")" USER_APPDATA_DIR
APPDATA_DIR="${USER_APPDATA_DIR:-$DEFAULT_APPDATA_DIR}"

read -rp "$(echo -e "   Default Output Directory [Default: ${BLUE}$DEFAULT_OUTPUT_DIR${NC}] (hit ⤶ to accept):\n   > ")" USER_OUTPUT_DIR
OUTPUT_DIR="${USER_OUTPUT_DIR:-$DEFAULT_OUTPUT_DIR}"

read -rp "$(echo -e "   Default Archive Directory [Default: ${BLUE}$DEFAULT_ARCHIVE_DIR${NC}] (hit ⤶ to accept):\n   > ")" USER_ARCHIVE_DIR
ARCHIVE_DIR="${USER_ARCHIVE_DIR:-$DEFAULT_ARCHIVE_DIR}"

# ==============================================================================
# 3. Interactive File Exclusion Configuration
# ==============================================================================
log_separator
echo -e "${BOLD}🛠️ Step 3: Configure File Operations & Exclusions...${NC}\n"

DEFAULT_EXCLUDE_EXTN=".pyc, .bak, .tmp, .log, .mp3, .m4a, .mov, .mp4, .jpg, .jpeg, .png, .pdf, .zip, .rar, .tgz"
echo -e "${BOLD}   Enter file extensions to exclude...${NC}"
echo -e "   Default file extensions excluded: ${BLUE}$DEFAULT_EXCLUDE_EXTN${NC} (hit ⤶ to accept)\n "
read -rp "$(echo -e "   Waiting for user input (comma-separated): ")" USER_EXCLUDE_EXTN
EXCLUDE_EXTN="${USER_EXCLUDE_EXTN:-$DEFAULT_EXCLUDE_EXTN}"

DEFAULT_EXCLUDE_FILE="secret_key.py, __init__.py, __pycache__, __tests__, __test__"
echo -e "\n${BOLD}   Enter folder/file patterns to exclude...${NC}"
echo -e "   Default exclude patterns: ${BLUE}$DEFAULT_EXCLUDE_FILE${NC} (hit ⤶ to accept)\n"
read -rp "$(echo -e "   Waiting for user input (comma-separated): ")" USER_EXCLUDE_FILE
EXCLUDE_FILE="${USER_EXCLUDE_FILE:-$DEFAULT_EXCLUDE_FILE}"

MERGED_EXCLUDES="${EXCLUDE_EXTN},${EXCLUDE_FILE}"

EXCLUDED_PATTERNS_JSON_ARRAY="[]"
if [ -n "$MERGED_EXCLUDES" ]; then
    if command -v python3 &> /dev/null; then
      EXCLUDED_PATTERNS_JSON_ARRAY=$(python3 -c "import sys, json; print(json.dumps(list(dict.fromkeys([x.strip() for x in sys.argv[1].split(',') if x.strip()]))))" "$MERGED_EXCLUDES")
    else
        # Pure Bash JSON formatting fallback (ensures zero-dependency standalone binary install)
        IFS=',' read -ra RAW_ITEMS <<< "$MERGED_EXCLUDES"
        FORMATTED_ITEMS=()
        for item in "${RAW_ITEMS[@]}"; do
            trimmed=$(echo "$item" | xargs)
            if [ -n "$trimmed" ]; then
                FORMATTED_ITEMS+=("\"$trimmed\"")
            fi
        done
        EXCLUDED_PATTERNS_JSON_ARRAY="[$(IFS=,; echo "${FORMATTED_ITEMS[*]}")]"
    fi
fi

# ==============================================================================
# 4. Deploy Payload
# ==============================================================================
mkdir -p "$APPDATA_DIR" "$APP_INSTALL_DIR" "$OUTPUT_DIR" "$ARCHIVE_DIR" "$DESKTOP_APPS_DIR" "$ICON_BASE_DIR"

log_separator
echo -e "${BOLD}📦 Step 4: Deploying FileMint application payload...${NC}\n"

if [ -n "$BIN_FILE" ] && [ -f "$BIN_FILE" ]; then
    BIN_NAME=$(basename "$BIN_FILE")
    cp -f "$BIN_FILE" "$APP_INSTALL_DIR/$BIN_NAME"
    chmod +x "$APP_INSTALL_DIR/$BIN_NAME"
    INSTALLED_BIN="$APP_INSTALL_DIR/$BIN_NAME"
    echo -e "   -> ${GREEN}✔ Deployed binary executable to: $INSTALLED_BIN${NC}"

elif [ -n "$PY_FILE" ] && [ -f "$PY_FILE" ]; then
    mkdir -p "$APP_INSTALL_DIR/src"
    PY_DIR=$(dirname "$PY_FILE")

    PY_NAME=$(basename "$PY_FILE")
    cp -f "$PY_FILE" "$APP_INSTALL_DIR/src/$PY_NAME"
    chmod +x "$APP_INSTALL_DIR/src/$PY_NAME"

    # Copy sibling modules if present alongside the entry script
    if compgen -G "$PY_DIR/*.py" > /dev/null; then
        cp -f "$PY_DIR"/*.py "$APP_INSTALL_DIR/src/" 2>/dev/null || true
    fi

    INSTALLED_PY="$APP_INSTALL_DIR/src/$PY_NAME"
    echo -e "   -> ${GREEN}✔ Deployed Python source scripts to $APP_INSTALL_DIR/src/${NC}"
fi

# ==============================================================================
# 5. Generate Dynamic Configuration Files (`appConfig.json` & `fileOpsConfig.json`)
# ==============================================================================
log_separator
echo -e "\n${BOLD}📝 Step 5: Generating Dynamic App & Operations Config Templates...${NC}"


cat <<EOF > "$APPDATA_DIR/appConfig.json"
{
  "app_metadata": {
    "name": "FileMint",
    "version": "v15.0 (Build 15.0.10 | Release v15.0.2)",
    "license": "MIT Open Source License",
    "copyright": "\u00a9 2026 FileMint Development Team",
    "website": "https://github.com/encloudme",
    "feedback": "https://github.com/encloudme/FileMint/issues",
    "contact": "filemint.help@proton.me",
    "icon_filename": "filemint.png",
    "window_title": "FileMint - File Consolidation & Archiving Engine"
  },
  "directories": {
    "HOME": "$HOME_DIR",
    "DESKTOP_DIR": "$HOME_DIR/Desktop",
    "DESKTOP_APPS_DIR": "$HOME_DIR/.local/share/applications",
    "ICON_DIR": "$HOME_DIR/.local/share/icons",
    "DOCUMENTS_DIR": "$HOME_DIR/Documents",
    "APPDATA_DIR": "$APPDATA_DIR",
    "APP_INSTALL_DIR": "$APP_INSTALL_DIR",
    "DEFAULT_OUTPUT_DIR": "$OUTPUT_DIR",
    "DEFAULT_ARCHIVE_DIR": "$ARCHIVE_DIR"
  },
  "rules": {
    "strict_pattern": "^(combined|merged|merge)_([^\\\\s]+?)_[vV](\\\\d+(?:\\\\.\\\\d+){1,3})\\\\.txt$",
    "default_theme": "light"
  }
}
EOF

cat <<EOF > "$APPDATA_DIR/fileOpsConfig.json"
{
  "excluded_patterns": $EXCLUDED_PATTERNS_JSON_ARRAY,
  "output_dir": "$OUTPUT_DIR",
  "archive_dir": "$ARCHIVE_DIR"
}
EOF

echo -e "   -> ${GREEN}✔ Configuration templates generated in $APPDATA_DIR${NC}"

# Maintain local application mirror copies
mkdir -p "$APP_INSTALL_DIR/config"
cp -f "$APPDATA_DIR/appConfig.json" "$APP_INSTALL_DIR/config/" 2>/dev/null || true
cp -f "$APPDATA_DIR/fileOpsConfig.json" "$APP_INSTALL_DIR/config/" 2>/dev/null || true
echo -e "   -> ${GREEN}✔ Configuration templates mirrored in $APP_INSTALL_DIR/config/${NC}"

# Maintain repo root mirror copies
mkdir -p "$REPO_ROOT/config"
cp -f "$APPDATA_DIR/appConfig.json" "$REPO_ROOT/config/" 2>/dev/null || true
cp -f "$APPDATA_DIR/fileOpsConfig.json" "$REPO_ROOT/config/" 2>/dev/null || true
echo -e "   -> ${GREEN}✔ Configuration templates mirrored in $REPO_ROOT/config/${NC}"

# ==============================================================================
# 6. Deploy Icon Assets & Audit Hicolor Path Structure
# ==============================================================================
log_separator
echo -e "${BOLD}🎨 Step 6: Auditing Icon Paths & Deploying Hicolor Multi-Resolution Icons...${NC}\n"

if [ ! -d "$HICOLOR_DIR" ]; then
    echo -e "   -> ${YELLOW}⚠ Warning: System hicolor icon theme directory not found at $HICOLOR_DIR.${NC}"
    echo -e "   -> Creating custom hicolor directory structure automatically."
fi

ICON_SRC=""
if [ -f "$REPO_ROOT/assets/icons/filemint.png" ]; then
    ICON_SRC="$REPO_ROOT/assets/icons/filemint.png"
elif [ -f "$REPO_ROOT/icons/filemint.png" ]; then
    ICON_SRC="$REPO_ROOT/icons/filemint.png"
elif [ -f "$REPO_ROOT/filemint.png" ]; then
    ICON_SRC="$REPO_ROOT/filemint.png"
fi

# 1. Conditional Icon Deployment

if [ -n "$ICON_SRC" ]; then

    NEW_ICON_HASH=$(get_file_sha256 "$ICON_SRC")
    SYS_ICON_HASH=$(get_file_sha256 "$ICON_BASE_DIR/filemint.png")

    if [ "$NEW_ICON_HASH" != "$SYS_ICON_HASH" ]; then
      mkdir -p "$ICON_BASE_DIR"
      cp -f "$ICON_SRC" "$ICON_BASE_DIR/filemint.png"

      for size in "${HICOLOR_SIZES[@]}"; do
          target_path="$HICOLOR_DIR/$size/apps"
          mkdir -p "$target_path"
          cp -f "$ICON_SRC" "$target_path/filemint.png"
      done
      ICON_UPDATED=true
      echo -e "   -> ${GREEN}✔ Icons successfully deployed across 7 hicolor resolutions (16x16 -> 512x512)${NC}"
    else
      echo " -> 🎨 ${GREEN}System icons are identical (Skipped overwrite).${NC}"
    fi
else
    echo -e "   -> ${YELLOW}⚠ Warning: 'filemint.png' icon not found in package root ($REPO_ROOT). Refer to README.md.${NC}"
fi

# ==============================================================================
# 7. Deploy Executable Path & Register GNOME Shortcut
# ==============================================================================
log_separator
echo -e "${BOLD}🖥️ Step 7: Deploying Application Executable Path & Registering GNOME Shortcut...${NC}\n"

if [ -n "$INSTALLED_BIN" ] && [ -x "$INSTALLED_BIN" ]; then
    EXEC_CMD="$INSTALLED_BIN"
elif [ -n "$INSTALLED_PY" ] &&  [ -x "$INSTALLED_PY" ]; then
    EXEC_CMD="python3 $INSTALLED_PY"
elif [ -f "$APP_INSTALL_DIR/src/filemint.py" ]; then
    EXEC_CMD="python3 $APP_INSTALL_DIR/src/filemint.py"
else
    EXEC_CMD="python3 $APP_INSTALL_DIR/filemint.py"
fi

DESKTOP_FILE="$DESKTOP_APPS_DIR/filemint.desktop"
TEMP_DESKTOP=$(mktemp)

cat <<EOF > "$TEMP_DESKTOP"
[Desktop Entry]
Version=1.0
Type=Application
Name=FileMint
GenericName=File Consolidation & Archiving Engine
Comment=Offline zero-dependency data sanitization and archiving engine
Exec=$EXEC_CMD
Path=$APP_INSTALL_DIR
Icon=filemint
Terminal=false
Categories=Utility;Development;Archiving;
StartupNotify=true
StartupWMClass=FileMint
Keywords=filemint;merge;combine;archive;consolidate;version;
EOF

NEW_DESKTOP_HASH=$(get_file_sha256 "$TEMP_DESKTOP")
SYS_DESKTOP_HASH=$(get_file_sha256 "$DESKTOP_FILE")

if [ "$NEW_DESKTOP_HASH" != "$SYS_DESKTOP_HASH" ]; then
    rm -f "$DESKTOP_FILE"
    mv -f "$TEMP_DESKTOP" "$DESKTOP_FILE"
    DESKTOP_UPDATED=true
    chmod +x "$DESKTOP_FILE"
    echo " -> ${GREEN}🖥️ Registered updated desktop launcher entry."

    # Maintain repo root mirror copies
    cp -f "$DESKTOP_FILE" "$REPO_ROOT/config/" 2>/dev/null || true
    echo -e "   -> ${GREEN}✔ Desktop Entry mirrored in $REPO_ROOT/config/${NC}"

else
    rm -f "$TEMP_DESKTOP"
    echo " -> ${YELLOW}🖥️ Desktop launcher entry is identical (Skipped overwrite).${NC}"
fi

log_separator
# Trigger System Cache Refresh ONLY if Assets Were Modified
if [ "$DESKTOP_UPDATED" = true ] || [ "$ICON_UPDATED" = true ]; then
    echo "🔄 Modified launcher assets detected. Refreshing system caches..."
    if command -v update-desktop-database &> /dev/null; then
        echo -e "   -> 🔄 Refreshing local desktop application indexing registry..."
        update-desktop-database "$DESKTOP_APPS_DIR" || true
    fi

     echo -e "   -> ${GREEN}✔ Registered desktop shortcut launching: $EXEC_CMD.${NC}"

    if command -v gtk-update-icon-cache &> /dev/null; then
        echo -e "   -> 🔄 Refreshing GTK system icon cache database..."
        gtk-update-icon-cache -f -t "$ICON_BASE_DIR" 2>/dev/null || true
        gtk-update-icon-cache -f -t "$HICOLOR_DIR" 2>/dev/null || true
    fi

    echo -e "   -> ${GREEN}✔ Icon Cache database updated.${NC}"
else
    echo "✅${GREEN} No desktop or icon changes detected — System caches preserved intact.${NC}"
fi
# ==============================================================================
# 8. Summary & Installation Complete
# ==============================================================================

echo -e "\n${GREEN}${BOLD}=========================================================================${NC}"
echo -e "${GREEN}${BOLD}  🎉 FileMint v15.0 Installation Successfully Completed!               ${NC}"
echo -e "${GREEN}${BOLD}=========================================================================${NC}"
echo -e "📁 App Directory:       ${BLUE}$APP_INSTALL_DIR${NC}"
echo -e "⚙️ Configuration Path:   ${BLUE}$APPDATA_DIR${NC}"
echo -e "🖥️ Desktop Shortcut:    ${BLUE}$DESKTOP_APPS_DIR/filemint.desktop${NC}"
echo -e "🎨 System Icon:         ${BLUE}$ICON_BASE_DIR/filemint.png${NC}"
echo -e "\n👉 You can launch FileMint from your GNOME Applications Overview."
echo -e "💡 If you encounter any execution issues, please refer to ${BOLD}README.md${NC}."
echo -e "${GREEN}${BOLD}=========================================================================\n${NC}"
