# Changelog

All notable changes to the **FileMint** (File Consolidation and Archiving Engine) project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v15.0.2] - 2026-09-27

### ✨ Features & Core Improvements
* **Dynamic Path Resolution (`{HOME}` & `~`)**: Resolved `{HOME}` and `~` (tilde) macro tokens when loading workspace configuration (`fileOpsConfig.json`) across `gui.py` and `core.py`. (`8584f61`, `23f3126`)
* **Software License & Privacy Tab**: Added a dedicated Software License and Privacy Declaration tab to the App Info dialog (`gui.py`). (`56e90fe`)
* **Regex Validation & Config Backup**: Updated schema validation regex and added automated backup routine for `fileOpsConfig.json`. (`9b8c613`)
* **Excel Release Matrix Integration**: Integrated automated Excel tracking matrix updater (`update_release_matrix.py`) into the release pipeline. (`f5b273f`)

### 🚀 Build, Release & Windows Suite
* **v15.0.2 Release Pipeline**: Updated build tools (`build_release.sh`), Windows installer suite (`install-filemint-win.bat`), and v15.0.2 build engine. (`29f368a`, `d73058a`, `95c4d0a`)
* **SHA-256 Verified Installation**: Updated installation scripts with SHA-256 checksum verification prior to desktop shortcut creation and icon overwrites. (`dae43e5`)
* **Multi-Resolution Windows ICO**: Regenerated valid multi-resolution Windows ICO file (`filemint.ico`). (`ccb5145`)

### ⚙️ CI/CD & Security Hardening
* **Windows CI Build Workflows**: Implemented GitHub Actions manual build workflow with checkpoint validation, fixed step indentation, PowerShell array splatting for Nuitka arguments, and binary handling (`-AsByteStream`). (`bef8f73`, `ec5cdd6`, `027b882`, `d4e3902`, `5b90728`, `e468320`, `e277807`)
* **Workflow Security Enforcement**: Enforced least privilege permissions and restricted insecure Node.js runner versions across CI workflows. (`51eddc5`)

### 📚 Documentation & Synopsis Assets
* **Documentation Suite Refresh**: Updated `README.md`, added application UI screenshots to the repository, refreshed icon files, and generated updated Project Synopsis documents and PDF distribution copy. (`d73fe40`, `a41d5b8`)

---

## [v15.0.1] - 2026-09-20

### 🚀 Build & Release Engineering
* **v15.0.1 Release Publishing**: Published `v15.0.1` standalone Linux executables (`FileMint-v15.0.1`), distribution archives (`.zip` and `.tar.gz`), and generated cryptographic `SHA256SUMS.txt` manifests. (`5719bfa`)
* **Public Directory Path Resolution**: Updated release build engine (`build_release.sh`) to dynamically target the renamed portfolio directory (`FileMint_Public`). (`d8dcdd9`)
* **Asset & Icon Synchronization**: Fixed icon staging (`assets/icons/`) and public folder mirroring logic during release assembly. (`0739a69`)
* **Packaging Workflow**: Added public release packaging workflow and 2-tier storage pipeline for core and public repositories. (`7527118`)

### 🛠️ Installation & Setup Hardening
* **Installer Suite Hardening**: Hardened local Linux (`install-filemint.sh`) and Windows (`install-filemint-win.bat`) installers and uninstallers. (`d81e495`)
  * Fixed Windows Python environment audit checks and batch delayed expansion traps.
  * Automated seeding of default `appConfig.json` and `fileOpsConfig.json` templates into user configuration directories (`~/.config/filemint-app` and `%APPDATA%\FileMint`).
  * Corrected uninstaller configuration priority and purge summary logging.
  * Added dynamic selection of windowless launcher executables (`pythonw` / `pyw`) for shortcut registration.

---

## [v15.0.0] - 2026-09-18

### ✨ Initial Architecture & Repository Setup
* **Repository Restructure**: Restructured personal repository layout, modularized script folders, and updated relative asset paths. (`f6730e6`)
* **Showcase Setup**: Established initial release framework and public portfolio setup for the FileMint engine showcase. (`7b3f3db`)

---