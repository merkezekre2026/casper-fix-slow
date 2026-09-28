# FAQ

[Türkçe](SSS.md)

**Can it harm my computer?**
No. Every run first creates a system restore point and registry backup; Windows Update, Defender and the Firewall
are never touched. Menu **[5] Undo** reverts the changes.

**Windows SmartScreen says "Windows protected your PC".**
Normal for unsigned files downloaded from the internet. Click **More info → Run anyway**. You can read every
script in `scripts\` beforehand; they are plain text.

**My antivirus flagged it.**
Some antivirus products consider registry-changing PowerShell scripts suspicious. All code is open; use
**[3] Preview** first if unsure.

**How much faster will it be?**
On an HDD system, boot time and idle disk usage drop noticeably and windows open more smoothly. But the limits of
a spinning disk and 4 GB RAM can't be fixed in software: see [HARDWARE.md](HARDWARE.md).

**Disk still at 100%.**
After the first boots Windows Update and Defender scans use the disk for a while; wait 30–60 minutes. If it
persists, re-run CasperFix and answer "e" (yes) to the SysMain and Windows Search questions, and check disk health
with **[4] System report**. A failing disk makes everything very slow.

**A big Windows update turned settings back on.**
Feature updates can reset some settings. Just run CasperFix again.

**There are multiple user accounts.**
Visual effects, startup and advertising settings (HKCU) apply only to the account that runs CasperFix. Log in to
the other account and run it again (the account must be an administrator).

**Does it work on Windows 7 / 8.1 / 11?**
Designed for Windows 10. Most steps work on Windows 11 but it is untested. Windows 7/8.1 are not supported.
