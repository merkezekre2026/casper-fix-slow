<#
    06 - Gizlilik ve arka plan gürültüsü
    Telemetri, reklam kimliği, Başlat menüsü önerileri, sessiz uygulama kurulumları ve
    görev çubuğundaki Haberler ve İlgi Alanları gibi kaynak tüketen özellikleri kapatır.
#>

Write-CasperLog 'Gizlilik ve öneriler' -Level Step

# Telemetri (Home/Pro sürümlerinde en düşük seviye "Temel" olarak uygulanır)
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 0
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'DoNotShowFeedbackNotifications' -Value 1
Set-RegValue -Path 'HKCU:\Software\Microsoft\Siuf\Rules' -Name 'NumberOfSIUFInPeriod' -Value 0

# Reklam kimliği
Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 0

# Başlat menüsü önerileri, kilit ekranı ipuçları, sessizce kurulan uygulamalar
$cdm = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
foreach ($name in @(
        'SilentInstalledAppsEnabled', 'SystemPaneSuggestionsEnabled', 'SoftLandingEnabled',
        'PreInstalledAppsEnabled', 'OemPreInstalledAppsEnabled', 'ContentDeliveryAllowed',
        'SubscribedContent-310093Enabled', 'SubscribedContent-338388Enabled',
        'SubscribedContent-338389Enabled', 'SubscribedContent-353694Enabled',
        'SubscribedContent-353696Enabled')) {
    Set-RegValue -Path $cdm -Name $name -Value 0
}
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableWindowsConsumerFeatures' -Value 1
Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement' -Name 'ScoobeSystemSettingEnabled' -Value 0

# Etkinlik geçmişi (Zaman Çizelgesi)
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'EnableActivityFeed' -Value 0
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'PublishUserActivities' -Value 0

# Görev çubuğunda Haberler ve İlgi Alanları (sürekli internetten veri çeker, RAM tüketir)
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds' -Name 'EnableFeeds' -Value 0

# Teslim İyileştirme: güncellemeleri internetteki başka bilgisayarlara yüklemeyi kapat (yalnızca yerel ağ)
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DODownloadMode' -Value 1
