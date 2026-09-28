# Donanım yükseltme rehberi

[English](HARDWARE.md)

Eski bir Casper Nirvana'da yazılım ayarları ancak bir yere kadar yardımcı olur. Aşağıdaki sıralama,
**harcanan para başına en çok hız** kazandıran yükseltmelere göredir.

> Önce CasperFix menüsünden **[4] Sistem raporu** alın. Rapor; disk türünü, RAM yuva sayısını,
> anakartın desteklediği maksimum RAM'i ve disk sağlığını gösterir.

## 1. SSD (en büyük fark)

Mekanik disk (HDD) bu bilgisayarların yavaşlığının 1 numaralı sebebidir. Windows 10 sürekli küçük dosyalar
okur/yazar; 5400 rpm bir disk buna yetişemez ve Görev Yöneticisi'nde disk **%100**'de kalır.

- **Ne alınmalı:** 2.5" SATA SSD, 240–512 GB. (M.2/NVMe **değil**; bu notebookların çoğunda M.2 yuvası yoktur.)
- **SATA II mi III mü?** Intel 6/7 serisi yonga setlerinde ana disk yuvası genellikle SATA III'tür. SATA II
  (3 Gb/s) olsa bile SSD'nin asıl faydası olan düşük erişim süresi korunur; açılış 2–3 dakikadan ~30 saniyeye iner.
- **Taşıma:** Ya temiz kurulum yapın ([TEMIZ-KURULUM.md](TEMIZ-KURULUM.md)) ya da Macrium Reflect Free /
  SSD üreticisinin klonlama aracıyla eski diski kopyalayın. Yeni diske eski diskten büyük olmayan bir bölüm
  sığmıyorsa önce Disk Yönetimi'nden bölümü küçültün.
- **Eski HDD:** DVD sürücüsünün yerine takılan "HDD caddy" (9.5 mm veya 12.7 mm; DVD sürücünüzün kalınlığını
  ölçün) ile ikinci disk olarak kullanılabilir.
- SSD taktıktan sonra CasperFix'i tekrar çalıştırın: SSD'yi tanır, TRIM'i açar ve SysMain'i kapatır.

## 2. RAM: 8 GB

Windows 10 + güncel bir tarayıcı için 4 GB artık yetersizdir; 2 GB ile neredeyse kullanılamaz.

- **Tür:** DDR3 SO-DIMM (notebook RAM'i), genellikle PC3-10600 (1333 MHz) veya PC3-12800 (1600 MHz).
  Raporda görünen mevcut modülün hızına uygun alın; daha hızlı modül de çalışır ama düşük hızda çalışır.
- **Voltaj:** Hem 1.35 V hem 1.5 V destekleyen (DDR3L, "dual voltage") modüller çoğu cihazda sorunsuzdur.
  Özellikle 2. nesil (Sandy Bridge) sistemlerde yalnızca 1.35 V çalışan modüller açılmayabilir.
- **Kapasite:** 2 yuvalı cihazlarda 2 × 4 GB en güvenli seçimdir. 3. nesil (Ivy Bridge) sistemlerin çoğu
  16 GB'a kadar destekler, ama eski notebooklar için 8 GB yeterlidir.
- **Çift kanal:** Aynı boyutta iki modül (örn. 4 + 4) Intel HD grafikte belirgin performans artışı sağlar.

## 3. Temizlik ve termal macun

Yıllar içinde fan ve soğutucu toz dolar, termal macun kurur. Sonuç: işlemci ısınır ve kendini yavaşlatır
(termal kısılma), fan sürekli yüksek sesle çalışır.

- Fan ızgarasındaki tozu temizlemek, çoğu zaman alt kapağı açıp fanı fırçalamak yeterlidir.
- 10 yıllık bir cihazda termal macunun yenilenmesi işlemci sıcaklığını 10–20 °C düşürebilir.
- Emin değilseniz bir teknik servise yaptırın; bu işlem ucuzdur ve cihazın ömrünü uzatır.

## 4. Pil

Rapordaki pil sağlığı %50'nin altındaysa pil hem kısa dayanır hem de bazı cihazlarda şarj sırasında
performansı düşürür. Uyumlu pil için alttaki etiketteki model/parça numarasını kullanın.

## 5. Kablosuz ağ kartı (isteğe bağlı)

Eski 802.11n kartlar yavaş ve kararsız olabilir. mini PCIe bir Intel Wi-Fi kartı ucuz bir yükseltmedir; ancak
bazı notebook BIOS'ları "beyaz liste" nedeniyle yabancı kartları kabul etmeyebilir. Alternatif: USB Wi-Fi adaptörü.
