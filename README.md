# CasperFix — Eski Casper Nirvana notebookları hızlandırın

🇹🇷 Türkçe | [🇬🇧 English](README.en.md)

2011–2014 döneminde satılan **Casper Nirvana** notebooklar (Intel 2./3. nesil Core i3/i5 veya Pentium,
2–4 GB RAM, 5400 rpm mekanik disk, Intel HD 3000/4000 grafik) Windows 10 ile genellikle çok yavaş çalışır:
açılış dakikalar sürer, Görev Yöneticisi'nde disk sürekli **%100** görünür, tarayıcı takılır.

CasperFix, bu bilgisayarları **güvenli ve geri alınabilir** şekilde hızlandıran bir Windows 10 araç setidir.

> **Gerçekçi beklenti:** Yazılım ayarları hissedilir bir iyileşme sağlar, ama eski bir notebook'ta en büyük
> fark **SSD** ve **8 GB RAM** yükseltmesinden gelir. Ayrıntılar: [docs/DONANIM.md](docs/DONANIM.md)

## Hızlı başlangıç

1. Sağ üstteki **Code → Download ZIP** ile indirin ve bir klasöre çıkarın.
2. `CasperFix.bat` dosyasına **sağ tıklayın → Yönetici olarak çalıştır**.
3. Menüden önce **[4] Sistem raporu** alın, sonra **[3] Önizleme** ile neler değişeceğine bakın.
4. **[1] Önerilen tüm iyileştirmeleri uygula** seçin ve soruları yanıtlayın.
5. Bitince bilgisayarı **yeniden başlatın**.

```
   [1] Önerilen tüm iyileştirmeleri uygula
   [2] Adımları tek tek seç
   [3] Önizleme (hiçbir şeyi değiştirmeden ne yapılacağını göster)
   [4] Sistem raporu oluştur (donanım, disk sağlığı, öneriler)
   [5] Yapılan değişiklikleri geri al
   [0] Çıkış
```

## Ne yapar?

| Adım | Yaptığı | Geri alınabilir |
|---|---|---|
| Yedekleme | Sistem geri yükleme noktası + registry `.reg` yedeği + önceki değerlerin kaydı | — |
| Güç planı | "CasperFix Performans" planı: prizde işlemci kısılmaz, USB askıya alma ve disk uykusu kapalı; pilde tasarruf korunur | ✅ |
| Görsel efektler | Animasyon, gölge, şeffaflık, Aero Peek kapalı; yazı tipi yumuşatma ve küçük resimler açık | ✅ |
| Servisler | Telemetri, Xbox, Faks, Haritalar, Uzak Kayıt Defteri vb. kapalı. SysMain / Windows Search / Yazdırma için size sorulur | ✅ |
| Başlangıç | Windows ile açılan programları tek tek sorar (OneDrive, Skype, Adobe güncelleyici…). Antivirüs ve ses/touchpad sürücüleri korunur | ✅ |
| Gizlilik | Telemetri, reklam kimliği, Başlat önerileri, sessiz uygulama kurulumu, Haberler ve İlgi Alanları kapalı | ✅ |
| Uygulamalar | Candy Crush, Xbox, Bing Haberler, Solitaire gibi hazır uygulamaları kaldırır (Store, Hesap Makinesi, Fotoğraflar korunur) | ❌ (Store'dan tekrar kurulur) |
| Temizlik | Geçici dosyalar, Windows Update önbelleği, Disk Temizleme, eski güncelleme bileşenleri (DISM) | ❌ (sadece çöp dosyalar) |
| Disk | HDD'de birleştirme, SSD'de TRIM; kapatılmış sanal belleği düzeltir | ✅ |
| Bellek | Arka plan uygulamaları, Cortana, Edge arka plan modu, Oyun DVR kapalı | ✅ |

**Dokunulmayanlar:** Windows Update, Windows Defender ve Güvenlik Duvarı **asla kapatılmaz**. Bunları kapatan
"hızlandırma" araçları bilgisayarınızı virüslere açık hâle getirir ve kayda değer bir hız kazandırmaz.

## Geri alma

- Menüden **[5] Yapılan değişiklikleri geri al** → registry değerleri, servisler, güç planı eski hâline döner.
- Ya da: **Denetim Masası → Kurtarma → Sistem Geri Yükleme → "CasperFix oncesi"**.
- Yedekler `backups\` klasöründe, loglar `logs\` klasöründe tutulur. Bu klasörleri silmeyin.

## Komut satırı

```powershell
# Yönetici PowerShell'de, proje klasöründe:
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -All -DryRun       # önizleme
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -All               # hepsi (sorulu)
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -All -Unattended   # hepsi, varsayılan cevaplarla
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -Only Services,Startup
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -Restore
powershell -ExecutionPolicy Bypass -File .\scripts\CasperFix.ps1 -Report
```

## ⚠️ Windows 10 desteği hakkında

Windows 10'un ücretsiz desteği **14 Ekim 2025**'te bitti; Genişletilmiş Güvenlik Güncellemeleri (ESU)
programı ev kullanıcıları için **13 Ekim 2026**'da sona eriyor. Bu notebookların işlemcileri Windows 11'i
resmî olarak desteklemiyor. Güncelleme almayan bir sistemde internet bankacılığı ve e-posta gibi işler için
dikkatli olun. Uzun vadede güvenli ve hızlı bir seçenek için
[docs/TEMIZ-KURULUM.md](docs/TEMIZ-KURULUM.md) dosyasındaki **Linux Mint XFCE** bölümüne bakın.

## Belgeler

- [Donanım yükseltme rehberi (SSD, RAM, fan temizliği)](docs/DONANIM.md)
- [Sürücüler](docs/SURUCULER.md)
- [Temiz kurulum](docs/TEMIZ-KURULUM.md)
- [Sık sorulan sorular](docs/SSS.md)

## Katkı

Kendi Casper modelinizdeki sonuçları [model raporu](../../issues/new?template=model-raporu.md) açarak paylaşın.
Hata bulursanız veya yeni bir iyileştirme önermek isterseniz issue/PR açabilirsiniz.

## Sorumluluk reddi

Bu proje Casper Bilgisayar Sistemleri A.Ş. ile bağlantılı değildir. Yazılım "olduğu gibi" sunulur; çalıştırmadan
önce önemli dosyalarınızı yedekleyin. Lisans: [MIT](LICENSE).
