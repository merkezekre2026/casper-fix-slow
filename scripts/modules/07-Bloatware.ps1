<#
    07 - Gereksiz uygulamalar
    Windows 10 ile gelen, çoğu kullanıcının açmadığı ama güncellenip arka planda çalışan
    mağaza uygulamalarını kaldırır. Hepsi Microsoft Store'dan yeniden kurulabilir.
    NOT: Bu adım 99-Restore.ps1 ile otomatik geri alınamaz.
#>

Write-CasperLog 'Gereksiz uygulamalar' -Level Step

$patterns = @(
    'Microsoft.3DBuilder', 'Microsoft.Microsoft3DViewer', 'Microsoft.Print3D', 'Microsoft.MSPaint3D'
    'Microsoft.BingNews', 'Microsoft.BingWeather', 'Microsoft.BingFinance', 'Microsoft.BingSports'
    'Microsoft.GetHelp', 'Microsoft.Getstarted', 'Microsoft.MicrosoftOfficeHub'
    'Microsoft.MicrosoftSolitaireCollection', 'Microsoft.MixedReality.Portal'
    'Microsoft.Messaging', 'Microsoft.OneConnect', 'Microsoft.People', 'Microsoft.SkypeApp'
    'Microsoft.Wallet', 'Microsoft.WindowsFeedbackHub', 'Microsoft.WindowsMaps'
    'Microsoft.XboxApp', 'Microsoft.XboxGameOverlay', 'Microsoft.XboxGamingOverlay'
    'Microsoft.XboxSpeechToTextOverlay', 'Microsoft.Xbox.TCUI'
    'Microsoft.YourPhone', 'Microsoft.ZuneMusic', 'Microsoft.ZuneVideo'
    'king.com.*', '*CandyCrush*', '*BubbleWitch*', '*Facebook*', '*Twitter*', '*Netflix*'
    '*Disney*', '*Spotify*', '*TikTok*', '*Instagram*', '*MarchofEmpires*', '*Asphalt*'
    '*HiddenCity*', '*Duolingo*', '*PandoraMedia*', '*EclipseManager*', '*ActiproSoftware*'
)

# Bu listedekiler hiçbir koşulda kaldırılmaz.
$keep = @(
    'Microsoft.WindowsStore', 'Microsoft.StorePurchaseApp', 'Microsoft.WindowsCalculator',
    'Microsoft.Windows.Photos', 'Microsoft.DesktopAppInstaller', 'Microsoft.WindowsNotepad',
    'Microsoft.ScreenSketch', 'Microsoft.VCLibs*', 'Microsoft.NET*', 'Microsoft.UI.Xaml*',
    'Microsoft.SecHealthUI', 'Microsoft.WindowsCamera', 'Microsoft.HEIFImageExtension',
    'Microsoft.VP9VideoExtensions', 'Microsoft.WebMediaExtensions', 'Microsoft.WebpImageExtension'
)

function Test-AnyLike {
    param([string]$Text, [string[]]$Patterns)
    foreach ($p in $Patterns) {
        if ($Text -like $p) { return $true }
    }
    return $false
}

$installed = @(Get-AppxPackage -ErrorAction SilentlyContinue |
        Where-Object { (Test-AnyLike $_.Name $patterns) -and -not (Test-AnyLike $_.Name $keep) -and -not $_.NonRemovable })
$provisioned = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
        Where-Object { (Test-AnyLike $_.DisplayName $patterns) -and -not (Test-AnyLike $_.DisplayName $keep) })

if ($installed.Count -eq 0 -and $provisioned.Count -eq 0) {
    Write-CasperLog 'Kaldırılacak gereksiz uygulama bulunamadı.' -Level Ok
    return
}

Write-CasperLog "Kaldırılacak uygulamalar ($($installed.Count)):"
foreach ($app in $installed) { Write-CasperLog "  - $($app.Name)" }

if (-not (Read-YesNo -Question 'Bu uygulamalar kaldırılsın mı? (Store''dan tekrar kurulabilir)' -Default $true)) {
    Write-CasperLog 'Uygulama kaldırma atlandı.'
    return
}

foreach ($app in $installed) {
    Invoke-Change -Description "Kaldırıldı: $($app.Name)" -Action {
        Remove-AppxPackage -Package $app.PackageFullName -ErrorAction Stop
    }
}
# Yeni kullanıcı hesaplarına tekrar kurulmasın
foreach ($pkg in $provisioned) {
    Invoke-Change -Description "Hazır paket kaldırıldı: $($pkg.DisplayName)" -Action {
        Remove-AppxProvisionedPackage -Online -PackageName $pkg.PackageName -ErrorAction Stop | Out-Null
    }
}
