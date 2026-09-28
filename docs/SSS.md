# Sık sorulan sorular

[English](FAQ.md)

**Bilgisayarıma zarar verir mi?**
Hayır. Her çalıştırmada önce sistem geri yükleme noktası ve registry yedeği alınır; Windows Update, Defender ve
Güvenlik Duvarı'na dokunulmaz. Menüdeki **[5] Geri al** ile değişiklikler eski hâline döner.

**Windows SmartScreen "Windows bilgisayarınızı korudu" diyor.**
İnternetten indirilen imzasız dosyalarda bu normaldir. **Ek bilgi → Yine de çalıştır** seçin. Çalıştırmadan önce
scriptlerin içeriğini `scripts\` klasöründe inceleyebilirsiniz; hepsi düz metindir.

**Antivirüsüm uyarı verdi.**
Bazı antivirüsler registry değiştiren PowerShell scriptlerini şüpheli bulabilir. Kodun tamamı açıktır; emin
değilseniz önce **[3] Önizleme** ile neler yapılacağını görün.

**Ne kadar hızlanır?**
HDD'li bir sistemde açılış ve boşta disk kullanımı belirgin şekilde düşer, pencereler daha akıcı açılır. Ancak
mekanik disk ve 4 GB RAM sınırı yazılımla aşılamaz: en büyük fark için [DONANIM.md](DONANIM.md).

**Disk hâlâ %100'de.**
İlk açılışlardan sonra Windows Update ve Defender taraması bir süre diski kullanır; 30–60 dakika bekleyin.
Devam ederse CasperFix'i tekrar çalıştırıp SysMain ve Windows Search sorularına "e" deyin ve disk sağlığını
**[4] Sistem raporu** ile kontrol edin. Sağlığı kötü bir disk sistemi çok yavaşlatır.

**Windows büyük bir güncelleme sonrası ayarları geri açtı.**
Özellik güncellemeleri bazı ayarları sıfırlayabilir. CasperFix'i tekrar çalıştırmanız yeterlidir.

**Birden fazla kullanıcı hesabı var.**
Görsel efektler, başlangıç ve reklam ayarları (HKCU) yalnızca CasperFix'i çalıştıran hesaba uygulanır.
Diğer hesapta oturum açıp o hesap yönetici ise tekrar çalıştırın.

**Windows 7 / 8.1 / 11'de çalışır mı?**
Windows 10 için tasarlanmıştır. Windows 11'de çoğu adım çalışır ama test edilmemiştir. Windows 7/8.1 desteklenmez.
