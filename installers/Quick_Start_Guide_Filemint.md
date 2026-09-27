# 🚀 FileMint — Quick Start & Operational Guide

Welcome to **FileMint**! FileMint is an offline, zero-dependency file consolidation, filtering, version tracking, and archiving engine. This guide details installation, workflow operations, configuration management, and troubleshooting steps for both Linux and Windows environments.

---

## 📁 1. Directory & Repository Layout

The standard FileMint distribution follows a clean, modular structure across both development and public portfolio repositories:

```text
FileMint/
├── assets/
│   ├── banners/
│   │   └── filemint_github_banner.png
│   └── icons/
│       ├── filemint.png
│       └── icon.png
├── config/
│   ├── appConfig.json
│   ├── filemint.desktop
│   └── fileOpsConfig.json
├── installers/
│   ├── install-filemint.sh
│   ├── uninstall-filemint.sh
│   ├── install-filemint-win.bat
│   └── Quick_Start_Guide_FileMint.md
├── releases/
│   ├── FileMint-v15.0.2
│   ├── FileMint-v15.0.2.exe
│   ├── filemint_v15.0.2.tar.gz
│   ├── filemint_v15.0.2.zip
│   └── SHA256SUMS.txt
└── README.md
```

---

## 💻 2. Quick Installation Guide

### Option A: Linux Installation (GNOME / KDE / XFCE)
1. Open terminal inside the FileMint repository or extracted release folder.
2. Grant execution permissions and run the interactive installer:
   ```bash
   chmod +x installers/install-filemint.sh
   ./installers/install-filemint.sh
   ```
3. **What it does**:
   * Audits Python 3 and Tkinter system dependencies.
   * Prompts for custom installation, output, and archive paths.
   * Deploys standalone binaries (or Python fallback) to ~/.local/share/filemint-app/.
   * Deploys multi-resolution icon assets across 7 hicolor themes (16x16 → 512x512).
   * Registers "filemint.desktop" in ~/.local/share/applications/.
   * Refreshes system GTK icon and desktop database caches.

### Option B: Windows Installation
1. Navigate to `installers\` folder and run **`install-filemint-win.bat`** (or execute from Command Prompt / PowerShell).  
     
2. **What it does**:
   * Detects Python runtime (python / py) or standalone FileMint.exe binary.
   * Deploys application files to %LOCALAPPDATA%\FileMint.
   * Deploys operational settings to %APPDATA%\FileMint.
   * Creates windowless background launch wrappers.
   * Automatically registers Desktop and Start Menu shortcuts with custom icons.
   
---

## ⚙️ 3. Standard Operational Workflow

1. **Select Source Folders (Section 1)**:
   * Click **`📁 Add Source Folder`** to choose code directories for scanning.
   * Toggle **`Search all subfolders (Recursive)`** to traverse nested directories.
2. **Filter File Extensions (Section 2)**:
   * Select or unselect extension checkboxes (e.g., `.py`, `.json`, `.md`, `.txt`) to filter candidate files.
3. **Configure Output & Archive Paths (Section 3)**:
   * Select the **Output Directory** where the compiled baseline file will be written.
   * Select the **Archive Directory** where existing compilations will be backed up.
   * Enter your output filename (e.g., `combined_source_v15.0.1.txt`).
4. **Run Engine & Merge (Section 4)**:
   * Click **`⚡ Run Consolidation Engine`**.
   * Review the **Verification Summary Check** modal.
   * Click **`⚡ Confirm & Merge`**.

---

## ⚠️ 4. Non-Compliant File Repair Assistant

If legacy or third-party consolidated files violate schema naming conventions (`combined_`, `merged_`, or `merge_` prefix with numeric version segments):

1. Click **`⚠️ Fix Formatting`** in Section 3 to open the **Version History Repair Dialog**.
2. Review the **Non-Compliant Files** table. FileMint automatically detects version collisions and generates suggested bumped names (e.g., `combined_app_v15.0.2.1.txt`).
3. Click **`⚡ Accept & Fix All Suggested`** to automatically rename and fix non-compliant files on disk in a single click.

---

## 🛠️ 5. Troubleshooting & FAQ

### Issue 1: Missing Tkinter Dependency on Linux
* **Symptom**: Terminal reports `ModuleNotFoundError: No module named 'tkinter'`.
* **Fix**: Install Python Tkinter module via system package manager:
  * **Ubuntu / Debian / Pop!_OS**: `sudo apt install python3-tk`
  * **Fedora / RHEL**: `sudo dnf install python3-tkinter`
  * **Arch Linux**: `sudo pacman -S tk`

### Issue 2: Windows Script Execution Policy & Python PATH
* **Symptom**: Double-clicking `.bat` opens Command Prompt and immediately closes.
* **Fix**: Ensure Python 3 is installed with "Add Python to PATH" checked, or download the pre-compiled `FileMint.exe` release binary into `releases/`.

### Issue 3: Desktop Launcher Icon Not Showing on GNOME
* **Fix**: Force GTK icon cache refresh:
  ```bash
  gtk-update-icon-cache -f -t ~/.local/share/icons
  gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor
  update-desktop-database ~/.local/share/applications
  ```

---

## 🧹 6. Uninstallation & Cleanup

* **Linux**:
  ```bash
  ./installers/uninstall-filemint.sh
  ```
Prompts will let you choose whether to preserve or purge your configuration directory (~/.config/filemint-app).


* **Windows Uninstallation**:

Use uninstall script:
  ```bash
  .\installers\uninstall-filemint-win.bat
  ```
Or:
  
 ```bash
    rmdir /s /q "%LOCALAPPDATA%\FileMint"
    rmdir /s /q "%APPDATA%\FileMint"
    del /f /q "%USERPROFILE%\Desktop\FileMint.lnk"
    del /f /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\FileMint.lnk"
 ```
  Delete `%LOCALAPPDATA%\FileMint`, `%APPDATA%\FileMint`, and the Desktop/Start Menu `FileMint.lnk` shortcuts if present.
