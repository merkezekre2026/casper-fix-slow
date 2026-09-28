# Sürücüler

[English](DRIVERS.md)

Doğru sürücüler olmadan ekran kartı, Wi-Fi ve touchpad yavaş veya hatalı çalışır. Rapordaki
**Sorunlu aygıtlar** bölümü ve Aygıt Yöneticisi'ndeki sarı ünlemler eksik sürücüleri gösterir.

## Önerilen sıra

1. **Windows Update → İsteğe bağlı güncelleştirmeler → Sürücü güncelleştirmeleri**: Windows 10 bu dönemin
   donanımlarının çoğu için (Realtek ses, Atheros/Realtek/Intel Wi-Fi, Realtek kart okuyucu) sürücüyü kendisi bulur.
2. **Casper destek sitesi** (casper.com.tr → Destek → Sürücüler): Modelinizi etiketteki koddan bulun. Buradaki
   sürücüler çoğunlukla Windows 7/8 içindir; özellikle **kısayol tuşları (Fn)** ve **touchpad** için işe yarar.
3. **Donanım üreticisinin sitesi:** Intel, Realtek, Synaptics/Elan.

## Ekran kartı (Intel HD Graphics)

| İşlemci nesli | Grafik | Windows 10 durumu |
|---|---|---|
| 2. nesil (i3/i5-2xxx, Sandy Bridge) | Intel HD 2000/3000 | Intel resmî Windows 10 sürücüsü yayınlamadı. Windows Update'in sunduğu sürücüyü kullanın. |
| 3. nesil (i3/i5-3xxx, Ivy Bridge) | Intel HD 2500/4000 | Intel'in Windows 10 destekli son sürücüsü (15.33 serisi) çalışır; Windows Update de sunar. |

Rapor ekran kartını **"Microsoft Temel Görüntü Bağdaştırıcısı"** olarak gösteriyorsa sürücü yüklü değildir:
video oynatma ve pencere hareketleri çok yavaşlar. Önce Windows Update'i deneyin.

Harici ekran kartı (NVIDIA GeForce 6xx/7xx M, AMD Radeon HD 7xxx M) olan modellerde çoğu zaman Windows Update'in
sunduğu sürücü yeterlidir. Tarayıcıda video takılıyorsa tarayıcı ayarlarında **donanım hızlandırmayı** açıp
kapatarak deneyin.

## Sürücü güncelleme programlarından uzak durun

"Driver Booster" gibi üçüncü parti sürücü güncelleyiciler sıklıkla yanlış sürücü kurar, reklam yazılımı getirir
ve başlangıçta çalışarak bilgisayarı daha da yavaşlatır.
