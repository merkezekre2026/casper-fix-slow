# Temiz kurulum

[English](CLEAN-INSTALL.md)

Yıllardır kullanılan, üzerine çok program kurulup kaldırılmış bir Windows, hiçbir ayarla eski hızına dönmez.
Özellikle **SSD taktıysanız** temiz kurulum en iyi sonucu verir.

> Başlamadan önce **tüm kişisel dosyalarınızı** (Belgeler, Masaüstü, Resimler, tarayıcı yer imleri, e-posta)
> harici bir diske yedekleyin. Temiz kurulum diski siler.

## Seçenek A: Windows 10 22H2

1. Başka bir bilgisayarda Microsoft'un **Media Creation Tool** aracıyla ya da ISO indirip **Rufus** ile 8 GB+
   bir USB bellek hazırlayın.
2. **Rufus ayarı:** Bu dönemin Casper'ları çoğunlukla eski (Legacy) BIOS kullanır. Bölüm düzeni **MBR**,
   hedef sistem **BIOS (veya UEFI-CSM)** seçin. BIOS'unuzda UEFI seçeneği varsa **GPT + UEFI** de kullanılabilir.
3. Notebook'u açarken **F12** (bazı modellerde **F11** veya **Esc**) ile önyükleme menüsünü açıp USB'yi seçin.
   BIOS ayarları için genellikle **F2** veya **Del**.
4. Kurulumda "Özel: Yalnızca Windows'u yükle" seçip eski bölümleri silin, boş alana kurun.
5. Ürün anahtarı sorulursa **"Ürün anahtarım yok"** deyin. Cihaz daha önce Windows 7/8/10 ile etkinleştirildiyse
   internete bağlanınca genellikle kendiliğinden etkinleşir.
6. Kurulumdan sonra: Windows Update → sürücüler ([SURUCULER.md](SURUCULER.md)) → CasperFix.

Kurulumda Microsoft hesabı yerine yerel hesap açmak ve gereksiz gizlilik seçeneklerini kapatmak da bilgisayarı
biraz hafifletir.

## Seçenek B: Linux Mint XFCE (uzun vadede önerilen)

Windows 10 güvenlik güncellemeleri sona erdiği ve bu işlemciler Windows 11'i resmî olarak desteklemediği için,
bilgisayarı yıllarca **güvenli** kullanmak istiyorsanız Linux Mint iyi bir seçenektir:

- 2–4 GB RAM'de Windows 10'dan belirgin şekilde hızlı çalışır, güvenlik güncellemeleri ücretsiz ve süreklidir.
- İnternet, e-posta, YouTube, LibreOffice (Word/Excel dosyaları), e-Devlet ve internet bankacılığı sorunsuz çalışır.
- Türkçe dil ve F/Q klavye desteği kurulumda seçilebilir.
- **Çalışmayanlar:** Bazı Windows'a özel programlar (ör. bazı muhasebe yazılımları, e-imza sürücüleri, oyunlar).
  Bunlara ihtiyacınız varsa önce USB'den "canlı" modda deneyin.

Kurulum: linuxmint.com'dan **XFCE Edition** ISO'sunu indirin, Rufus ile USB'ye yazın, USB'den açıp önce
kurmadan deneyin, beğenirseniz masaüstündeki "Install Linux Mint" ile kurun.
