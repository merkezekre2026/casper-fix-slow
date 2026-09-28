#Requires -Version 5.1
<#
.SYNOPSIS
    CasperFix - Eski Casper Nirvana notebooklar için Windows 10 hızlandırma aracı.

.DESCRIPTION
    Parametresiz çalıştırılırsa menü açılır. Tüm değişiklikler öncesinde sistem geri yükleme
    noktası ve registry yedeği alınır; "Geri al" seçeneği ile eski hâline döndürülebilir.

.EXAMPLE
    .\CasperFix.ps1                       # Menü
    .\CasperFix.ps1 -All                  # Önerilen tüm adımlar (sorular sorulur)
    .\CasperFix.ps1 -All -Unattended      # Soru sormadan, varsayılan cevaplarla
    .\CasperFix.ps1 -All -DryRun          # Hiçbir şey değiştirmeden ne yapılacağını göster
    .\CasperFix.ps1 -Only Services,Startup
    .\CasperFix.ps1 -Restore
    .\CasperFix.ps1 -Report
#>
[CmdletBinding()]
param(
    [switch]$All,
    [ValidateSet('Backup', 'PowerPlan', 'VisualEffects', 'Services', 'Startup', 'Privacy', 'Bloatware', 'Cleanup', 'Disk', 'Memory')]
    [string[]]$Only,
    [switch]$Restore,
    [switch]$Report,
    [switch]$DryRun,
    [switch]$Unattended
)

$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'lib\Common.ps1')

$modulesDir = Join-Path $PSScriptRoot 'modules'
$modules = @(
    [pscustomobject]@{ Id = 'Backup'; File = '01-Backup.ps1'; Title = 'Yedekleme (geri yükleme noktası + registry)' }
    [pscustomobject]@{ Id = 'PowerPlan'; File = '02-PowerPlan.ps1'; Title = 'Performans güç planı' }
    [pscustomobject]@{ Id = 'VisualEffects'; File = '03-VisualEffects.ps1'; Title = 'Görsel efektleri azalt' }
    [pscustomobject]@{ Id = 'Services'; File = '04-Services.ps1'; Title = 'Gereksiz servisleri kapat' }
    [pscustomobject]@{ Id = 'Startup'; File = '05-Startup.ps1'; Title = 'Başlangıç uygulamalarını düzenle' }
    [pscustomobject]@{ Id = 'Privacy'; File = '06-Privacy.ps1'; Title = 'Telemetri, reklam ve önerileri kapat' }
    [pscustomobject]@{ Id = 'Bloatware'; File = '07-Bloatware.ps1'; Title = 'Gereksiz mağaza uygulamalarını kaldır' }
    [pscustomobject]@{ Id = 'Cleanup'; File = '08-Cleanup.ps1'; Title = 'Disk temizliği' }
    [pscustomobject]@{ Id = 'Disk'; File = '09-Disk.ps1'; Title = 'Disk optimizasyonu (defrag / TRIM, sanal bellek)' }
    [pscustomobject]@{ Id = 'Memory'; File = '10-Memory.ps1'; Title = 'Bellek (RAM) tasarrufu' }
)

function Show-Banner {
    Write-Host ''
    Write-Host '  ================================================' -ForegroundColor Cyan
    Write-Host '   CasperFix - Eski Casper Nirvana hızlandırıcı' -ForegroundColor Cyan
    Write-Host '  ================================================' -ForegroundColor Cyan
    Write-Host ''
}

function Invoke-CasperStep {
    param(
        [object[]]$Selected,
        [switch]$Preview,
        [switch]$Quiet
    )

    $global:CasperFix = $null
    Initialize-CasperFix -DryRun:$Preview -Unattended:$Quiet
    Assert-Admin

    # Yedekleme her zaman ilk sırada çalışır.
    if (-not ($Selected | Where-Object { $_.Id -eq 'Backup' })) {
        $Selected = @($modules | Where-Object { $_.Id -eq 'Backup' }) + @($Selected)
    }

    foreach ($m in $Selected) {
        Write-Host ''
        try {
            . (Join-Path $modulesDir $m.File)
        }
        catch {
            Write-CasperLog "$($m.Title) sırasında hata: $($_.Exception.Message)" -Level Error
        }
    }

    Write-Host ''
    if ($global:CasperFix.DryRun) {
        Write-CasperLog 'Önizleme bitti. Hiçbir değişiklik yapılmadı.' -Level Ok
    }
    else {
        Write-CasperLog 'Tamamlandı! Değişikliklerin tamamı için bilgisayarı YENİDEN BAŞLATIN.' -Level Ok
        Write-CasperLog "Yedek: $($global:CasperFix.BackupDir)"
    }
    Write-CasperLog "Log dosyası: $($global:CasperFix.LogFile)"
}

function Invoke-Restore {
    param([switch]$Quiet)
    $global:CasperFix = $null
    Initialize-CasperFix -NoBackup -Unattended:$Quiet
    Assert-Admin
    . (Join-Path $modulesDir '99-Restore.ps1')
}

function Invoke-Report {
    & (Join-Path $PSScriptRoot 'diagnostics\SystemReport.ps1')
}

function Select-ModulesInteractive {
    Write-Host ''
    for ($i = 0; $i -lt $modules.Count; $i++) {
        Write-Host ('   [{0,2}] {1}' -f ($i + 1), $modules[$i].Title)
    }
    Write-Host ''
    $raw = Read-Host '   Çalıştırılacak adımların numaraları (örn: 2,3,5)'
    $picked = @()
    foreach ($part in ($raw -split '[,\s]+')) {
        $n = 0
        if ([int]::TryParse($part, [ref]$n) -and $n -ge 1 -and $n -le $modules.Count) {
            $picked += $modules[$n - 1]
        }
    }
    return $picked
}

# İnternetten indirilen ZIP'teki dosyaların "engellendi" işaretini kaldır.
Get-ChildItem -Path (Split-Path -Parent $PSScriptRoot) -Recurse -Include *.ps1 -ErrorAction SilentlyContinue |
    Unblock-File -ErrorAction SilentlyContinue

# --- Komut satırı modu ---
if ($Report) { Invoke-Report; return }
if ($Restore) { Invoke-Restore -Quiet:$Unattended; return }
if ($All) { Invoke-CasperStep -Selected $modules -Preview:$DryRun -Quiet:$Unattended; return }
if ($Only) {
    $sel = @($modules | Where-Object { $Only -contains $_.Id })
    Invoke-CasperStep -Selected $sel -Preview:$DryRun -Quiet:$Unattended
    return
}

# --- Menü modu ---
while ($true) {
    Show-Banner
    if (-not $DryRun -and -not (Test-IsAdmin)) {
        Write-Host '  UYARI: Yönetici olarak çalışmıyor. Değişiklik yapmak için CasperFix.bat' -ForegroundColor Yellow
        Write-Host '  dosyasına sağ tıklayıp "Yönetici olarak çalıştır" seçin.' -ForegroundColor Yellow
        Write-Host ''
    }
    Write-Host '   [1] Önerilen tüm iyileştirmeleri uygula'
    Write-Host '   [2] Adımları tek tek seç'
    Write-Host '   [3] Önizleme (hiçbir şeyi değiştirmeden ne yapılacağını göster)'
    Write-Host '   [4] Sistem raporu oluştur (donanım, disk sağlığı, öneriler)'
    Write-Host '   [5] Yapılan değişiklikleri geri al'
    Write-Host '   [0] Çıkış'
    Write-Host ''
    $choice = Read-Host '   Seçiminiz'

    switch ($choice) {
        '1' { Invoke-CasperStep -Selected $modules }
        '2' {
            $sel = Select-ModulesInteractive
            if ($sel.Count -gt 0) { Invoke-CasperStep -Selected $sel }
        }
        '3' { Invoke-CasperStep -Selected $modules -Preview }
        '4' { Invoke-Report }
        '5' { Invoke-Restore }
        '0' { return }
        default { Write-Host '   Geçersiz seçim.' -ForegroundColor Yellow }
    }
    Write-Host ''
    Read-Host '   Menüye dönmek için Enter'
}
