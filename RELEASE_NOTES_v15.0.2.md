
# 🚀 FileMint v15.0.2 Release Notes

FileMint **v15.0.2** brings dynamic path resolution, enhanced Windows installer and CI build workflows, software license and privacy UI additions, and refreshed project documentation.

---

### ✨ Highlights &amp; Key Features

* **Dynamic Path Expansion (`{HOME}` &amp; `~`)**: Full cross-platform support for `{HOME}` and `~` macro tokens across `fileOpsConfig.json`, enabling seamless configuration portability between Windows and Linux.
* **App Info Privacy &amp; License Tab**: Added a dedicated License and Privacy Declaration tab to the App Info modal (`gui.py`).
* **Automated Excel Release Tracking**: Release pipeline now synchronises build metadata, SHA-256 checksums, and Git commit history directly into `FileMint_Release_Tracking_Matrix.xlsx` sorted **Newest First**.
* **Hardened Windows &amp; Linux Installers**: Installation scripts verify SHA-256 binary checksums prior to registering desktop launchers and overwriting icon files.
* **CI/CD Build Automation**: Robust GitHub Actions Windows manual build workflows with Nuitka compilation and security hardening.

---

### 📦 Release Assets &amp; Downloads

* `FileMint-v15.0.2` — Standalone Linux Executable (ELF x86_64)
* `filemint_v15.0.2.zip` — Windows / Portable Distribution Bundle
* `filemint_v15.0.2.tar.gz` — Linux Distribution Tarball
* `FileMint_Project_Synopsis.pdf` — Project Architecture &amp; Synopsis Document
* `SHA256SUMS.txt` — Cryptographic Checksum Manifest

---