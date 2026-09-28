<#
    99 - Geri alma
    backups\<tarih>\state.json dosyasındaki kayıtları kullanarak registry değerlerini,
    servis başlangıç türlerini, güç planını ve sanal bellek ayarını eski hâline getirir.
    Kaldırılan mağaza uygulamaları ve silinen geçici dosyalar geri getirilemez.
#>

Write-CasperLog 'Geri alma' -Level Step

$backupRoot = Join-Path $global:CasperFix.Root 'backups'
$candidates = @(Get-ChildItem -Path $backupRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName 'state.json') } |
        Sort-Object Name -Descending)

if ($candidates.Count -eq 0) {
    Write-CasperLog 'Geri alınacak yedek bulunamadı (backups klasörü boş).' -Level Warn
    Write-CasperLog 'Alternatif: Denetim Masası > Kurtarma > Sistem Geri Yükleme > "CasperFix oncesi".'
    return
}

$selected = $candidates[0]
if ($candidates.Count -gt 1 -and -not $global:CasperFix.Unattended) {
    Write-Host ''
    for ($i = 0; $i -lt $candidates.Count; $i++) {
        Write-Host ('    [{0}] {1}' -f ($i + 1), $candidates[$i].Name)
    }
    $choice = Read-Host '    Hangi yedek geri yüklensin? (Enter = en yenisi)'
    $n = 0
    if ([int]::TryParse($choice, [ref]$n) -and $n -ge 1 -and $n -le $candidates.Count) {
        $selected = $candidates[$n - 1]
    }
}

Write-CasperLog "Seçilen yedek: $($selected.Name)"
$state = Get-Content -Path (Join-Path $selected.FullName 'state.json') -Raw -Encoding UTF8 | ConvertFrom-Json

foreach ($entry in @($state.Registry)) {
    if (-not $entry) { continue }
    $label = "$($entry.Path)\$($entry.Name)"
    if ($entry.Existed) {
        $value = $entry.OldValue
        switch ($entry.OldKind) {
            'Binary' { $value = [byte[]]@($entry.OldValue) }
            'MultiString' { $value = [string[]]@($entry.OldValue) }
        }
        Invoke-Change -Description "Registry eski değerine döndü: $label" -Action {
            New-ItemProperty -Path $entry.Path -Name $entry.Name -Value $value -PropertyType $entry.OldKind -Force -ErrorAction Stop | Out-Null
        }
    }
    else {
        Invoke-Change -Description "Registry değeri kaldırıldı (önceden yoktu): $label" -Action {
            Remove-ItemProperty -Path $entry.Path -Name $entry.Name -ErrorAction SilentlyContinue
        }
    }
}

foreach ($svc in @($state.Services)) {
    if (-not $svc -or -not $svc.OldStartup) { continue }
    Invoke-Change -Description "Servis $($svc.Name) -> $($svc.OldStartup)" -Action {
        Set-Service -Name $svc.Name -StartupType $svc.OldStartup -ErrorAction Stop
        if ($svc.WasRunning) {
            Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
        }
    }
}

$extra = $state.Extra
if ($extra) {
    if ($extra.PSObject.Properties['PowerScheme'] -and $extra.PowerScheme) {
        Invoke-Change -Description 'Önceki güç planı etkinleştirildi' -Action {
            & powercfg.exe /setactive $extra.PowerScheme
        }
    }
    if ($extra.PSObject.Properties['Hibernate'] -and $extra.Hibernate -eq 'on') {
        Invoke-Change -Description 'Hazırda bekletme tekrar açıldı' -Action {
            & powercfg.exe /hibernate on
        }
    }
    if ($extra.PSObject.Properties['AutomaticManagedPagefile'] -and $extra.AutomaticManagedPagefile -eq $false) {
        Write-CasperLog 'Sanal bellek otomatik yönetimde bırakıldı (önceki elle ayar güvenli olmadığı için geri alınmadı).'
    }
}

Write-CasperLog 'Geri alma tamamlandı. Bilgisayarı yeniden başlatın.' -Level Ok
