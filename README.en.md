# CasperFix — Speed up old Casper Nirvana laptops

[🇹🇷 Türkçe](README.md) | 🇬🇧 English

**Casper Nirvana** laptops sold in Turkey around 2011–2014 (Intel 2nd/3rd gen Core i3/i5 or Pentium,
2–4 GB RAM, 5400 rpm hard drive, Intel HD 3000/4000 graphics) usually run Windows 10 painfully slowly:
boot takes minutes, Task Manager shows the disk stuck at **100%**, and the browser stutters.

CasperFix is a Windows 10 toolkit that speeds these machines up **safely and reversibly**.

> **Realistic expectations:** software tweaks give a noticeable improvement, but on an old laptop the biggest
> gain by far comes from an **SSD** and an **8 GB RAM** upgrade. See [docs/HARDWARE.md](docs/HARDWARE.md).

## Quick start

1. Download via **Code → Download ZIP** and extract it.
2. **Right-click `CasperFix.bat` → Run as administrator**.
3. Start with **[4] System report**, then **[3] Preview** to see what would change.
4. Choose **[1] Apply all recommended tweaks** and answer the questions.
5. **Restart** the computer when done.

The menu and messages are in Turkish:

| Menu item | Meaning |
|---|---|
| `[1] Önerilen tüm iyileştirmeleri uygula` | Apply all recommended tweaks |
| `[2] Adımları tek tek seç` | Pick individual steps |
| `[3] Önizleme` | Preview (dry run, changes nothing) |
| `[4] Sistem raporu oluştur` | Create system report (hardware, disk health, recommendations) |
| `[5] Yapılan değişiklikleri geri al` | Undo changes |
| `[0] Çıkış` | Exit |

Yes/no prompts accept `e` (evet = yes) or `h` (hayır = no).

## What it does

| Step | What it does | Reversible |
|---|---|---|
| Backup | System restore point + `.reg` export + record of every previous value | — |
| Power plan | "CasperFix Performans" plan: no CPU throttling on AC, USB selective suspend and disk sleep off; battery saving kept on DC | ✅ |
| Visual effects | Animations, shadows, transparency, Aero Peek off; font smoothing and thumbnails kept | ✅ |
| Services | Telemetry, Xbox, Fax, Maps, Remote Registry etc. off. Asks about SysMain / Windows Search / Print Spooler | ✅ |
| Startup | Asks about each auto-start program (OneDrive, Skype, Adobe updater…). Antivirus and audio/touchpad drivers protected | ✅ |
| Privacy | Telemetry, advertising ID, Start suggestions, silent app installs, News and Interests off | ✅ |
| Apps | Removes preinstalled apps like Candy Crush, Xbox, Bing News, Solitaire (Store, Calculator, Photos kept) | ❌ (reinstall from Store) |
| Cleanup | Temp files, Windows Update cache, Disk Cleanup, old update components (DISM) | ❌ (junk files only) |
| Disk | Defrag on HDD, TRIM on SSD; re-enables a disabled page file | ✅ |
| Memory | Background apps, Cortana, Edge background mode, Game DVR off | ✅ |

**Never touched:** Windows Update, Windows Defender and the Firewall. "Speed-up" tools that disable them leave
the machine exposed and gain nothing meaningful.

## Undo

- Menu **[5]** restores registry values, services and the power plan.
- Or: **Control Panel → Recovery → System Restore → "CasperFix oncesi"**.
- Backups live in `backups\`, logs in `logs\`. Don't delete them.

## Command line

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -All -DryRun       # preview
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -All               # everything, interactive
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -All -Unattended   # everything, default answers
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -Only Services,Startup
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -Restore
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -Report
```

## ⚠️ About Windows 10 support

Free Windows 10 support ended on **October 14, 2025**; consumer Extended Security Updates (ESU) end on
**October 13, 2026**. These CPUs are not officially supported by Windows 11. Be careful with online banking and
e-mail on an unpatched system. For a safe, fast long-term option see the **Linux Mint XFCE** section in
[docs/CLEAN-INSTALL.md](docs/CLEAN-INSTALL.md).

## Docs

- [Hardware upgrade guide (SSD, RAM, cleaning)](docs/HARDWARE.md)
- [Drivers](docs/DRIVERS.md)
- [Clean install](docs/CLEAN-INSTALL.md)
- [FAQ](docs/FAQ.md)

## Disclaimer

Not affiliated with Casper Bilgisayar Sistemleri A.Ş. Provided "as is"; back up important files first.
License: [MIT](LICENSE).
