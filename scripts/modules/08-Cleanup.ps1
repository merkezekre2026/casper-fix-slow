<#
    08 - Disk temizliği
    Geçici dosyaları, Windows Update önbelleğini ve eski güncelleme bileşenlerini temizler.
    Kişisel dosyalara (Belgeler, Masaüstü, İndirilenler vb.) DOKUNULMAZ.
#>

Write-CasperLog 'Disk temizliği' -Level Step

function Get-FreeSpaceGB {
    $drive = Get-PSDrive -Name $env:SystemDrive.TrimEnd(':') -ErrorAction SilentlyContinue
    if ($drive) { return [math]::Round($drive.Free / 1GB, 2) }
    return 0
}

function Clear-Folder {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path $Path)) { return }
    Invoke-Change -Description "Temizlendi: $Label" -Action {
        Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$before = Get-FreeSpaceGB
Write-CasperLog "Temizlik öncesi boş alan: $before GB"

Clear-Folder -Path $env:TEMP -Label 'Kullanıcı geçici dosyaları'
Clear-Folder -Path (Join-Path $env:SystemRoot 'Temp') -Label 'Windows geçici dosyaları'

# Windows Update indirme önbelleği
$wuCache = Join-Path $env:SystemRoot 'SoftwareDistribution\Download'
Invoke-Change -Description 'Temizlendi: Windows Update indirme önbelleği' -Action {
    Stop-Service -Name wuauserv, bits -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $wuCache -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name bits, wuauserv -ErrorAction SilentlyContinue
}

# Disk Temizleme (cleanmgr) kategorilerini seçip sessiz çalıştır
$volumeCaches = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches'
$categories = @(
    'Active Setup Temp Folders', 'Delivery Optimization Files', 'Downloaded Program Files',
    'Internet Cache Files', 'Old ChkDsk Files', 'Previous Installations', 'Setup Log Files',
    'System error memory dump files', 'System error minidump files', 'Temporary Files',
    'Temporary Setup Files', 'Thumbnail Cache', 'Update Cleanup', 'Upgrade Discarded Files',
    'Windows Error Reporting Files', 'Windows Upgrade Log Files'
)
Invoke-Change -Description 'Disk Temizleme (cleanmgr) çalıştırıldı' -Action {
    foreach ($cat in $categories) {
        $key = Join-Path $volumeCaches $cat
        if (Test-Path $key) {
            New-ItemProperty -Path $key -Name 'StateFlags0777' -Value 2 -PropertyType DWord -Force | Out-Null
        }
    }
    Start-Process -FilePath cleanmgr.exe -ArgumentList '/sagerun:777' -Wait -WindowStyle Hidden
}

if (Read-YesNo -Question 'Geri dönüşüm kutusu boşaltılsın mı?' -Default $false) {
    Invoke-Change -Description 'Geri dönüşüm kutusu boşaltıldı' -Action {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    }
}

# Bileşen deposu temizliği (WinSxS). HDD'de 10-30 dakika sürebilir.
if (Read-YesNo -Question 'Eski güncelleme bileşenleri temizlensin mi? (HDD''de 10-30 dk sürebilir)' -Default $true) {
    Invoke-Change -Description 'DISM bileşen deposu temizliği tamamlandı' -Action {
        Write-CasperLog 'DISM çalışıyor, lütfen bekleyin...'
        & dism.exe /Online /Cleanup-Image /StartComponentCleanup /NoRestart | Out-Null
    }
}

if (-not (Test-DryRun)) {
    $after = Get-FreeSpaceGB
    Write-CasperLog ("Temizlik sonrası boş alan: {0} GB (kazanç: {1} GB)" -f $after, [math]::Round($after - $before, 2)) -Level Ok
}
