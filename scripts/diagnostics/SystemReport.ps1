#Requires -Version 5.1
<#
.SYNOPSIS
    Eski Casper notebook için donanım/yazılım sağlık raporu oluşturur.

.DESCRIPTION
    İşlemci, RAM (yuva sayısı ve maksimum kapasite dahil), disk türü ve sağlığı, ekran kartı
    sürücüsü, pil, hatalı sürücüler ve en çok RAM kullanan işlemleri raporlar; sonunda
    donanım yükseltme önerileri verir. Hiçbir ayarı değiştirmez.

.PARAMETER OutFile
    Raporun kaydedileceği dosya. Varsayılan: Masaüstü\CasperFix-Rapor.txt
#>
[CmdletBinding()]
param(
    [string]$OutFile = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'CasperFix-Rapor.txt')
)

$ErrorActionPreference = 'SilentlyContinue'
$lines = New-Object System.Collections.Generic.List[string]
$tips = New-Object System.Collections.Generic.List[string]

function Add-Line { param([string]$Text = '') $lines.Add($Text) }
function Add-Section { param([string]$Title) Add-Line ''; Add-Line "=== $Title ===" }

$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

Add-Line "CasperFix Sistem Raporu - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

Add-Section 'Bilgisayar'
Add-Line "Üretici / Model : $($cs.Manufacturer) / $($cs.Model)"
Add-Line "BIOS            : $($bios.SMBIOSBIOSVersion) ($($bios.ReleaseDate))"
Add-Line "İşletim sistemi : $($os.Caption) sürüm $($os.Version) (build $($os.BuildNumber))"
Add-Line "Son açılış      : $($os.LastBootUpTime)"
$uptime = (Get-Date) - $os.LastBootUpTime
if ($uptime.TotalDays -gt 7) {
    $tips.Add("Bilgisayar $([int]$uptime.TotalDays) gündür yeniden başlatılmamış. Haftada en az bir kez yeniden başlatın.")
}
if ($os.Caption -match 'Windows 10') {
    $tips.Add('Windows 10 desteği 14 Ekim 2025''te sona erdi (ESU ile 13 Ekim 2026''ya kadar). Güvenlik güncellemesi alamayan bir sistemde internet bankacılığı vb. için dikkatli olun; uzun vadede docs/TEMIZ-KURULUM.md dosyasındaki Linux Mint seçeneğini değerlendirin.')
}

Add-Section 'İşlemci'
Add-Line "$($cpu.Name.Trim())"
Add-Line "Çekirdek/İş parçacığı: $($cpu.NumberOfCores)/$($cpu.NumberOfLogicalProcessors), Anlık hız: $($cpu.CurrentClockSpeed) MHz / Maks: $($cpu.MaxClockSpeed) MHz"
if ($cpu.CurrentClockSpeed -and $cpu.MaxClockSpeed -and $cpu.CurrentClockSpeed -lt ($cpu.MaxClockSpeed * 0.5)) {
    Add-Line 'Not: İşlemci şu an düşük hızda. Prizdeyken sürekli düşükse aşırı ısınma (fan/termal macun) olabilir.'
}

Add-Section 'Bellek (RAM)'
$totalGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
$modules = @(Get-CimInstance Win32_PhysicalMemory)
$array = Get-CimInstance Win32_PhysicalMemoryArray | Select-Object -First 1
Add-Line "Toplam: $totalGB GB"
foreach ($m in $modules) {
    Add-Line ("  Yuva {0}: {1} GB, {2} MHz, {3} {4}" -f $m.DeviceLocator, [math]::Round($m.Capacity / 1GB, 1), $m.Speed, $m.Manufacturer, $m.PartNumber)
}
if ($array) {
    $maxGB = if ($array.MaxCapacity) { [math]::Round($array.MaxCapacity / 1MB, 0) } else { '?' }
    Add-Line "Yuva sayısı: $($array.MemoryDevices), anakartın bildirdiği maksimum: $maxGB GB"
    if ($totalGB -lt 8 -and $array.MemoryDevices -gt $modules.Count) {
        $tips.Add("Boş RAM yuvası var ($($modules.Count)/$($array.MemoryDevices) dolu). Aynı hızda bir DDR3 SO-DIMM ekleyerek RAM'i 8 GB'a çıkarabilirsiniz.")
    }
    elseif ($totalGB -lt 8) {
        $tips.Add('RAM 8 GB''ın altında. Mevcut modülleri 2x4 GB DDR3 SO-DIMM ile değiştirmek büyük fark yaratır (bkz. docs/DONANIM.md).')
    }
}
$free = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
Add-Line "Şu an boş: $free GB"

Add-Section 'Diskler'
$systemIsHdd = $false
foreach ($d in Get-PhysicalDisk) {
    Add-Line ("{0}: {1}, {2} GB, Bağlantı: {3}, Sağlık: {4}" -f $d.FriendlyName, $d.MediaType, [math]::Round($d.Size / 1GB, 0), $d.BusType, $d.HealthStatus)
    $rel = $d | Get-StorageReliabilityCounter
    if ($rel) {
        Add-Line ("  Sıcaklık: {0} °C, Okuma hatası: {1}, Yazma hatası: {2}, Aşınma: {3}%, Çalışma saati: {4}" -f $rel.Temperature, $rel.ReadErrorsTotal, $rel.WriteErrorsTotal, $rel.Wear, $rel.PowerOnHours)
        if ($rel.ReadErrorsUncorrected -gt 0 -or $rel.WriteErrorsUncorrected -gt 0) {
            $tips.Add("DİKKAT: $($d.FriendlyName) diskinde düzeltilemeyen hatalar var. Verilerinizi hemen yedekleyin ve diski değiştirin.")
        }
    }
    if ($d.HealthStatus -and $d.HealthStatus -ne 'Healthy') {
        $tips.Add("DİKKAT: $($d.FriendlyName) sağlık durumu '$($d.HealthStatus)'. Verilerinizi yedekleyin.")
    }
    if ($d.MediaType -ne 'SSD' -and $d.BusType -ne 'USB') { $systemIsHdd = $true }
}
foreach ($v in Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' }) {
    $pct = if ($v.Size) { [math]::Round(100 * $v.SizeRemaining / $v.Size, 0) } else { 0 }
    Add-Line ("Sürücü {0}: {1} GB boş / {2} GB (%{3})" -f $v.DriveLetter, [math]::Round($v.SizeRemaining / 1GB, 1), [math]::Round($v.Size / 1GB, 0), $pct)
    if ($v.DriveLetter -eq $env:SystemDrive.TrimEnd(':') -and $pct -lt 15) {
        $tips.Add("Sistem diskinde boş alan %$pct. En az %15-20 boş alan bırakın.")
    }
}
if ($systemIsHdd) {
    $tips.Add('Mekanik disk (HDD) kullanılıyor. En büyük hız artışı 2.5" SATA SSD''ye geçmektir (bkz. docs/DONANIM.md).')
}

Add-Section 'Ekran kartı'
foreach ($g in Get-CimInstance Win32_VideoController) {
    Add-Line "$($g.Name) - sürücü $($g.DriverVersion) ($($g.DriverDate))"
    if ($g.Name -match 'Basic Display|Temel Görüntü') {
        $tips.Add('Ekran kartı sürücüsü yüklü değil (Microsoft Temel Görüntü Bağdaştırıcısı). docs/SURUCULER.md dosyasına bakın.')
    }
}

Add-Section 'Pil'
$battery = Get-CimInstance Win32_Battery
if ($battery) {
    Add-Line "Durum: $($battery.Status), Şarj: %$($battery.EstimatedChargeRemaining)"
    $full = Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity | Select-Object -First 1
    $design = Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData | Select-Object -First 1
    if ($full -and $design -and $design.DesignedCapacity) {
        $health = [math]::Round(100 * $full.FullChargedCapacity / $design.DesignedCapacity, 0)
        Add-Line "Pil sağlığı: %$health (tam şarj $($full.FullChargedCapacity) / tasarım $($design.DesignedCapacity) mWh)"
        if ($health -lt 50) { $tips.Add("Pil kapasitesi %$health'e düşmüş. Pil değişimi düşünülebilir.") }
    }
}
else {
    Add-Line 'Pil bulunamadı veya takılı değil.'
}

Add-Section 'Sorunlu aygıtlar'
$bad = @(Get-CimInstance Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 })
if ($bad.Count -eq 0) {
    Add-Line 'Sorunlu aygıt yok.'
}
else {
    foreach ($b in $bad) { Add-Line "  [$($b.ConfigManagerErrorCode)] $($b.Name) ($($b.DeviceID))" }
    $tips.Add("$($bad.Count) aygıtın sürücüsü eksik veya hatalı. Aygıt Yöneticisi'nde sarı ünlemlere bakın (docs/SURUCULER.md).")
}

Add-Section 'Başlangıç programları'
$startup = @(Get-CimInstance Win32_StartupCommand)
foreach ($s in $startup) { Add-Line "  $($s.Name) -> $($s.Command)" }
if ($startup.Count -gt 8) { $tips.Add("$($startup.Count) program Windows ile birlikte açılıyor. CasperFix 'Başlangıç uygulamaları' adımını çalıştırın.") }

Add-Section 'En çok RAM kullanan 10 işlem'
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 | ForEach-Object {
    Add-Line ("  {0,-30} {1,8} MB" -f $_.ProcessName, [math]::Round($_.WorkingSet64 / 1MB, 0))
}

Add-Section 'Öneriler'
if ($tips.Count -eq 0) {
    Add-Line 'Belirgin bir sorun bulunamadı.'
}
else {
    $n = 1
    foreach ($t in $tips) { Add-Line "$n. $t"; $n++ }
}

$lines | Set-Content -Path $OutFile -Encoding UTF8
$lines | ForEach-Object { Write-Output $_ }
Write-Output ''
Write-Output "Rapor kaydedildi: $OutFile"
