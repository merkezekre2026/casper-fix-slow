# Değişiklik günlüğü

## 1.0.0 — 2026-09-28

İlk sürüm.

- Menülü `CasperFix.bat` başlatıcı ve `scripts/CasperFix.ps1` (tümü / seçili / önizleme / rapor / geri al).
- 10 adım: yedekleme, güç planı, görsel efektler, servisler, başlangıç, gizlilik, gereksiz uygulamalar,
  disk temizliği, disk optimizasyonu, bellek tasarrufu.
- Her registry/servis değişikliği `backups/<tarih>/state.json` dosyasına kaydedilir; `-Restore` ile geri alınır.
- `SystemReport.ps1`: donanım, disk sağlığı (SMART), RAM yuvaları, pil, sorunlu sürücüler ve yükseltme önerileri.
- Türkçe ve İngilizce belgeler: donanım, sürücüler, temiz kurulum, SSS.
