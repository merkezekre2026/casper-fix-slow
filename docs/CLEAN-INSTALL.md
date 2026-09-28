# Clean install

[Türkçe](TEMIZ-KURULUM.md)

A Windows install that has been used for years, with many programs installed and removed, will never regain its
original speed through tweaks alone. A clean install gives the best result, especially **after adding an SSD**.

> Back up **all personal files** (Documents, Desktop, Pictures, browser bookmarks, e-mail) to an external drive
> first. A clean install wipes the disk.

## Option A: Windows 10 22H2

1. On another PC, create an 8 GB+ USB stick with Microsoft's **Media Creation Tool**, or download the ISO and use **Rufus**.
2. **Rufus settings:** Casper laptops of this era mostly use legacy BIOS. Choose partition scheme **MBR**, target
   **BIOS (or UEFI-CSM)**. If your BIOS offers UEFI, **GPT + UEFI** also works.
3. Press **F12** (on some models **F11** or **Esc**) at power-on for the boot menu and pick the USB.
   BIOS setup is usually **F2** or **Del**.
4. Choose "Custom: Install Windows only", delete the old partitions and install to unallocated space.
5. If asked for a product key, choose **"I don't have a product key"**. Machines previously activated with
   Windows 7/8/10 usually activate automatically once online.
6. Afterwards: Windows Update → drivers ([DRIVERS.md](DRIVERS.md)) → CasperFix.

## Option B: Linux Mint XFCE (recommended long-term)

Since Windows 10 security updates are ending and these CPUs aren't officially supported by Windows 11, Linux Mint
is a good choice if you want to keep using the laptop **securely** for years:

- Noticeably faster than Windows 10 on 2–4 GB RAM, with free ongoing security updates.
- Web, e-mail, YouTube, LibreOffice (Word/Excel files), e-Devlet and online banking work fine.
- Turkish language and F/Q keyboard layouts are available in the installer.
- **Won't run:** some Windows-only programs (certain accounting software, e-signature drivers, games).
  Try the live USB first if you depend on them.

Install: download the **XFCE Edition** ISO from linuxmint.com, write it with Rufus, boot the USB and try it
without installing; if you like it, use "Install Linux Mint" on the desktop.
