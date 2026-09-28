<#
    04 - Servisler
    Ev kullanıcısının ihtiyaç duymadığı, arka planda RAM/disk tüketen servisleri kapatır.
    Windows Update, Defender ve Güvenlik Duvarı servislerine DOKUNULMAZ.
#>

Write-CasperLog 'Servisler' -Level Step

$diskType = Get-SystemDiskType
$ramGB = Get-TotalRamGB
Write-CasperLog "Sistem diski: $diskType, RAM: $ramGB GB"

# Güvenle kapatılabilecek servisler
$disable = [ordered]@{
    'DiagTrack'        = 'Telemetri (Bağlı Kullanıcı Deneyimleri)'
    'dmwappushservice' = 'Telemetri WAP yönlendirme'
    'RetailDemo'       = 'Mağaza tanıtım modu'
    'MapsBroker'       = 'Çevrimdışı harita indirici'
    'Fax'              = 'Faks'
    'RemoteRegistry'   = 'Uzak kayıt defteri (güvenlik)'
    'WMPNetworkSvc'    = 'Windows Media Player ağ paylaşımı'
    'XblAuthManager'   = 'Xbox Live kimlik doğrulama'
    'XblGameSave'      = 'Xbox Live oyun kaydı'
    'XboxNetApiSvc'    = 'Xbox Live ağ'
    'XboxGipSvc'       = 'Xbox aksesuar yönetimi'
}
foreach ($name in $disable.Keys) {
    Set-ServiceStartup -Name $name -StartupType Disabled -Reason $disable[$name]
}

# Talep hâlinde çalışsın yeterli olanlar
$manual = [ordered]@{
    'WerSvc'   = 'Hata raporlama'
    'lfsvc'    = 'Konum servisi'
    'TabletInputService' = 'Dokunmatik klavye (dokunmatik ekran yoksa gereksiz)'
}
foreach ($name in $manual.Keys) {
    Set-ServiceStartup -Name $name -StartupType Manual -Reason $manual[$name]
}

# SysMain (Superfetch): SSD'de gereksiz. HDD'de açılışı hızlandırır ama düşük RAM'de
# "disk %100" sorununa yol açabilir.
if ($diskType -eq 'SSD') {
    Set-ServiceStartup -Name 'SysMain' -StartupType Disabled -Reason 'SSD kullanılıyor'
}
elseif (Read-YesNo -Question "SysMain (Superfetch) kapatılsın mı? Görev Yöneticisi'nde disk sürekli %100 görünüyorsa 'e' deyin." -Default $false) {
    Set-ServiceStartup -Name 'SysMain' -StartupType Disabled -Reason 'Disk %100 sorunu'
}
else {
    Write-CasperLog 'SysMain HDD üzerinde açık bırakıldı (uygulama açılışlarını hızlandırır).'
}

# Windows Search dizinleme: HDD'de sürekli disk kullanır. Kapatılırsa Başlat menüsünde arama
# yine çalışır ama dosya içeriği aramaları yavaşlar.
if (Read-YesNo -Question 'Windows Search (dosya dizinleme) kapatılsın mı? Outlook kullanıyorsanız hayır deyin.' -Default $false) {
    Set-ServiceStartup -Name 'WSearch' -StartupType Disabled -Reason 'Dizinleme kapatıldı'
}

# Yazıcı kullanılmıyorsa yazdırma biriktiricisi gereksizdir (ayrıca PrintNightmare riski).
if (Read-YesNo -Question 'Bu bilgisayara hiç yazıcı bağlamıyor musunuz? (e = yazdırma servisini kapat)' -Default $false) {
    Set-ServiceStartup -Name 'Spooler' -StartupType Disabled -Reason 'Yazıcı kullanılmıyor'
}
