# Hardware upgrade guide

[Türkçe](DONANIM.md)

Software tweaks only go so far on an old Casper Nirvana. The list below is ordered by **speed gained per money spent**.

> Run CasperFix menu **[4] System report** first. It shows disk type, number of RAM slots, maximum supported
> RAM and disk health.

## 1. SSD (biggest difference)

The spinning hard drive is the #1 cause of slowness. Windows 10 constantly reads/writes small files; a 5400 rpm
drive can't keep up and Task Manager shows the disk stuck at **100%**.

- **What to buy:** 2.5" SATA SSD, 240–512 GB. (**Not** M.2/NVMe; most of these laptops have no M.2 slot.)
- **SATA II or III?** On Intel 6/7-series chipsets the main drive bay is usually SATA III. Even on SATA II
  (3 Gb/s) you keep the SSD's main benefit, low access time: boot drops from 2–3 minutes to ~30 seconds.
- **Migration:** Do a clean install ([CLEAN-INSTALL.md](CLEAN-INSTALL.md)) or clone the old drive with Macrium
  Reflect Free or the SSD vendor's tool. Shrink the partition in Disk Management first if it's larger than the SSD.
- **Old HDD:** reuse it as a second drive with an optical-bay "HDD caddy" (9.5 mm or 12.7 mm; measure your DVD drive).
- Re-run CasperFix after installing the SSD: it detects the SSD, enables TRIM and disables SysMain.

## 2. RAM: 8 GB

4 GB is no longer enough for Windows 10 plus a modern browser; 2 GB is nearly unusable.

- **Type:** DDR3 SO-DIMM (laptop RAM), usually PC3-10600 (1333 MHz) or PC3-12800 (1600 MHz). Match the speed of
  the existing module shown in the report; faster modules also work but run at the lower speed.
- **Voltage:** dual-voltage 1.35 V / 1.5 V (DDR3L) modules work in most machines. 1.35 V-only modules may fail
  to boot, especially on 2nd gen (Sandy Bridge) systems.
- **Capacity:** 2 × 4 GB is the safest choice for two-slot machines. Most 3rd gen (Ivy Bridge) systems support
  16 GB, but 8 GB is plenty for an old laptop.
- **Dual channel:** two identical modules (e.g. 4 + 4) noticeably improve Intel HD graphics performance.

## 3. Cleaning and thermal paste

Fans and heatsinks clog with dust and thermal paste dries out over the years, causing thermal throttling and
constant fan noise. Cleaning the fan and renewing the paste can lower CPU temperature by 10–20 °C. If unsure,
have a repair shop do it — it's cheap and extends the laptop's life.

## 4. Battery

If battery health in the report is below 50%, it runs down quickly and on some machines can reduce performance
while charging. Use the model/part number on the label underneath to find a compatible battery.

## 5. Wi-Fi card (optional)

Old 802.11n cards can be slow and flaky. A mini PCIe Intel Wi-Fi card is a cheap upgrade, but some laptop BIOSes
whitelist cards and refuse others. Alternative: a USB Wi-Fi adapter.
