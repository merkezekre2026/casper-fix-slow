<#
    05 - Başlangıç uygulamaları
    Windows ile birlikte açılan programları listeler ve seçilenleri Görev Yöneticisi'nin
    kullandığı yöntemle (StartupApproved) devre dışı bırakır. Programlar silinmez;
    Görev Yöneticisi > Başlangıç sekmesinden tekrar açılabilir.
#>

Write-CasperLog 'Başlangıç uygulamaları' -Level Step

# Asla kapatılmayacaklar: güvenlik, ses/dokunmatik yüzey sürücüleri.
$protected = @(
    'SecurityHealth', 'WindowsDefender', 'Windows Security',
    'RtkAudUService', 'RTHDVCPL', 'Realtek',
    'SynTPEnh', 'Synaptics', 'ETDCtrl', 'Elan',
    'IgfxTray', 'HotKeysCmds', 'Persistence',
    'avast', 'avg', 'kaspersky', 'eset', 'egui', 'bitdefender', 'norton', 'mcafee'
)

# Gözetimsiz modda otomatik kapatılacak, bilinen gereksiz başlangıç öğeleri.
$knownJunk = @(
    'OneDrive', 'Skype', 'Spotify', 'Discord', 'Steam', 'EpicGamesLauncher',
    'AdobeARM', 'Adobe Acrobat', 'AdobeGCInvoker', 'CCXProcess',
    'iTunesHelper', 'QuickTime', 'jusched', 'SunJavaUpdateSched',
    'GoogleDriveFS', 'Dropbox', 'uTorrent', 'BitTorrent', 'CCleaner',
    'MicrosoftEdgeAutoLaunch', 'Opera Browser Assistant', 'Teams', 'com.squirrel.Teams'
)

$disabledBytes = [byte[]](0x03, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
$approvedBase = 'Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved'

$sources = @(
    @{ Hive = 'HKCU:'; Key = 'Software\Microsoft\Windows\CurrentVersion\Run'; Approved = 'Run' }
    @{ Hive = 'HKLM:'; Key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run'; Approved = 'Run' }
    @{ Hive = 'HKLM:'; Key = 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'; Approved = 'Run32' }
)

$items = New-Object System.Collections.ArrayList
foreach ($src in $sources) {
    $path = Join-Path $src.Hive $src.Key
    if (-not (Test-Path $path)) { continue }
    $key = Get-Item -Path $path
    foreach ($valueName in $key.GetValueNames()) {
        if ([string]::IsNullOrEmpty($valueName)) { continue }
        [void]$items.Add([pscustomobject]@{
                Name         = $valueName
                Command      = [string]$key.GetValue($valueName)
                ApprovedPath = Join-Path $src.Hive (Join-Path $approvedBase $src.Approved)
            })
    }
}

$startupFolders = @(
    @{ Hive = 'HKCU:'; Dir = [Environment]::GetFolderPath('Startup') }
    @{ Hive = 'HKLM:'; Dir = [Environment]::GetFolderPath('CommonStartup') }
)
foreach ($folder in $startupFolders) {
    if (-not $folder.Dir -or -not (Test-Path $folder.Dir)) { continue }
    foreach ($file in Get-ChildItem -Path $folder.Dir -File -ErrorAction SilentlyContinue) {
        if ($file.Name -eq 'desktop.ini') { continue }
        [void]$items.Add([pscustomobject]@{
                Name         = $file.Name
                Command      = $file.FullName
                ApprovedPath = Join-Path $folder.Hive (Join-Path $approvedBase 'StartupFolder')
            })
    }
}

function Test-StartupItemDisabled {
    param($Item)
    if (-not (Test-Path $Item.ApprovedPath)) { return $false }
    $value = (Get-Item -Path $Item.ApprovedPath).GetValue($Item.Name, $null)
    return ($value -is [byte[]]) -and ($value.Length -gt 0) -and (($value[0] -band 1) -eq 1)
}

function Test-NameMatch {
    param([string]$Text, [string[]]$Patterns)
    foreach ($p in $Patterns) {
        if ($Text -like "*$p*") { return $true }
    }
    return $false
}

if ($items.Count -eq 0) {
    Write-CasperLog 'Başlangıçta açılan program bulunamadı.'
    return
}

Write-CasperLog "$($items.Count) başlangıç öğesi bulundu."
foreach ($item in $items) {
    $text = "$($item.Name) $($item.Command)"
    if (Test-StartupItemDisabled -Item $item) {
        Write-CasperLog "Zaten kapalı: $($item.Name)"
        continue
    }
    if (Test-NameMatch -Text $text -Patterns $protected) {
        Write-CasperLog "Korunuyor (güvenlik/sürücü): $($item.Name)"
        continue
    }

    $isJunk = Test-NameMatch -Text $text -Patterns $knownJunk
    Write-Host ''
    Write-Host "    $($item.Name)" -ForegroundColor White
    Write-Host "      $($item.Command)" -ForegroundColor DarkGray
    if (Read-YesNo -Question 'Başlangıçta açılması engellensin mi?' -Default $isJunk) {
        Set-RegValue -Path $item.ApprovedPath -Name $item.Name -Value $disabledBytes -Type Binary
    }
}
