<#
    01 - Yedekleme
    Sistem geri yükleme noktası oluşturur ve CasperFix'in dokunduğu registry anahtarlarını
    .reg dosyası olarak dışa aktarır (99-Restore.ps1'e ek bir güvence).
#>

Write-CasperLog 'Yedekleme' -Level Step

New-CasperRestorePoint

$keys = @(
    'HKCU\Control Panel\Desktop'
    'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
    'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved'
    'HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    'HKCU\Software\Microsoft\Windows\CurrentVersion\Run'
    'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
    'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved'
    'HKLM\SOFTWARE\Policies\Microsoft\Windows'
)

if (Test-DryRun) {
    Write-CasperLog "(önizleme) $($keys.Count) registry anahtarı .reg olarak yedeklenecek."
    return
}

$regDir = Join-Path $global:CasperFix.BackupDir 'registry'
New-Item -ItemType Directory -Path $regDir -Force | Out-Null
$i = 0
foreach ($key in $keys) {
    $i++
    $file = Join-Path $regDir ('{0:D2}-{1}.reg' -f $i, ($key -replace '[\\ ]', '_'))
    $null = & reg.exe export $key $file /y 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-CasperLog "Yedeklendi: $key"
    }
}

# Etkin güç planını kaydet (02-PowerPlan değiştirirse geri almak için).
$active = (& powercfg.exe /getactivescheme) -join ' '
if ($active -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
    Set-StateExtra -Key 'PowerScheme' -Value $Matches[1]
}

Write-CasperLog "Yedek klasörü: $($global:CasperFix.BackupDir)" -Level Ok
