<#
    10 - Bellek (RAM) tasarrufu
    2-4 GB RAM'li eski notebooklarda en çok bellek tüketen arka plan özelliklerini kapatır:
    arka plan uygulamaları, Cortana, Edge'in arka planda açık kalması, Oyun DVR.
#>

Write-CasperLog 'Bellek tasarrufu' -Level Step

$ramGB = Get-TotalRamGB
Write-CasperLog "Toplam RAM: $ramGB GB"
if ($ramGB -gt 0 -and $ramGB -lt 4) {
    Write-CasperLog '4 GB altı RAM Windows 10 için çok az. docs/DONANIM.md dosyasındaki RAM yükseltme önerisine bakın.' -Level Warn
}

# Mağaza uygulamalarının arka planda çalışması
Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Name 'GlobalUserDisabled' -Value 1
Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'BackgroundAppGlobalToggle' -Value 0

# Cortana
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -Value 0

# Microsoft Edge (Chromium): pencere kapansa bile arka planda açık kalmasın, açılışta ön-yüklenmesin
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'StartupBoostEnabled' -Value 0
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'BackgroundModeEnabled' -Value 0

# Oyun DVR / Game Bar arka plan kaydı (Intel HD grafikte ciddi yük)
Set-RegValue -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Value 0
Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Value 0
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' -Name 'AllowGameDVR' -Value 0
