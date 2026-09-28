# Drivers

[Türkçe](SURUCULER.md)

Without proper drivers the graphics, Wi-Fi and touchpad run slowly or glitch. The **Problem devices** section of
the report and yellow marks in Device Manager show missing drivers.

## Recommended order

1. **Windows Update → Optional updates → Driver updates**: Windows 10 finds drivers for most hardware of this era
   (Realtek audio, Atheros/Realtek/Intel Wi-Fi, Realtek card reader).
2. **Casper support site** (casper.com.tr → Support → Drivers): find your model by the code on the label. These are
   mostly Windows 7/8 drivers; useful mainly for **hotkeys (Fn)** and the **touchpad**.
3. **Vendor sites:** Intel, Realtek, Synaptics/Elan.

## Graphics (Intel HD Graphics)

| CPU generation | Graphics | Windows 10 status |
|---|---|---|
| 2nd gen (i3/i5-2xxx, Sandy Bridge) | Intel HD 2000/3000 | No official Intel Windows 10 driver. Use the one Windows Update offers. |
| 3rd gen (i3/i5-3xxx, Ivy Bridge) | Intel HD 2500/4000 | Intel's last Windows 10 driver (15.33 series) works; Windows Update also offers it. |

If the report lists the GPU as **"Microsoft Basic Display Adapter"**, no driver is installed and video/window
movement will be very slow. Try Windows Update first.

Models with discrete graphics (NVIDIA GeForce 6xx/7xx M, AMD Radeon HD 7xxx M) are usually fine with the Windows
Update driver. If browser video stutters, try toggling **hardware acceleration** in the browser settings.

## Avoid driver updater programs

Third-party updaters like "Driver Booster" often install wrong drivers, bundle adware and run at startup, making
the machine even slower.
