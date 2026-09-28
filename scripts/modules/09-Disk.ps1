<#
    09 - Disk optimizasyonu
    HDD ise birleştirme (defrag), SSD ise TRIM uygular. Daha önce kapatılmış sanal belleği
    (pagefile) düşük RAM'li sistemlerde tekrar otomatik yönetime alır.
#>

Write-CasperLog 'Disk optimizasyonu' -Level Step

$diskType = Get-SystemDiskType
$ramGB = Get-TotalRamGB
$letter = $env:SystemDrive.TrimEnd(':')

if ($diskType -eq 'SSD') {
    Invoke-Change -Description 'SSD için TRIM etkin' -Action {
        & fsutil.exe behavior set DisableDeleteNotify 0 | Out-Null
    }
    Invoke-Change -Description "SSD TRIM uygulandı ($letter`:)" -Action {
        Optimize-Volume -DriveLetter $letter -ReTrim -ErrorAction Stop
    }
}
else {
    Write-CasperLog 'HDD tespit edildi. Birleştirme 15 dakika ile 1-2 saat arasında sürebilir.'
    if (Read-YesNo -Question 'Disk birleştirme (defrag) şimdi yapılsın mı?' -Default $true) {
        Invoke-Change -Description "Disk birleştirme tamamlandı ($letter`:)" -Action {
            Write-CasperLog 'Birleştirme çalışıyor, bilgisayarı kapatmayın...'
            Optimize-Volume -DriveLetter $letter -Defrag -ErrorAction Stop
        }
    }
}

# Zamanlanmış disk iyileştirme görevinin açık olduğundan emin ol
$task = Get-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName 'ScheduledDefrag' -ErrorAction SilentlyContinue
if ($task -and $task.State -eq 'Disabled') {
    Invoke-Change -Description 'Haftalık otomatik disk iyileştirme tekrar açıldı' -Action {
        Enable-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName 'ScheduledDefrag' | Out-Null
    }
}

# Sanal bellek: internetteki "hızlandırma" rehberleri genelde kapattırır; 2-4 GB RAM'de bu
# donma ve program çökmelerine yol açar.
$cs = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
if ($cs -and -not $cs.AutomaticManagedPagefile -and $ramGB -le 8) {
    $pagefiles = @(Get-CimInstance -ClassName Win32_PageFileSetting -ErrorAction SilentlyContinue)
    Write-CasperLog "Sanal bellek elle ayarlanmış ($($pagefiles.Count) dosya). Düşük RAM için otomatik yönetim önerilir." -Level Warn
    if (Read-YesNo -Question 'Sanal bellek Windows tarafından otomatik yönetilsin mi?' -Default $true) {
        Set-StateExtra -Key 'AutomaticManagedPagefile' -Value $false
        Invoke-Change -Description 'Sanal bellek otomatik yönetime alındı (yeniden başlatma gerekir)' -Action {
            Set-CimInstance -InputObject $cs -Property @{ AutomaticManagedPagefile = $true } -ErrorAction Stop
        }
    }
}
else {
    Write-CasperLog 'Sanal bellek ayarı uygun.'
}

# Hazırda bekletme: hiberfil.sys RAM kadar yer kaplar. HDD'de "Hızlı başlatma" açılışı
# belirgin şekilde hızlandırdığı için yalnızca SSD'de ve disk doluysa kapatmayı öner.
$psDrive = Get-PSDrive -Name $letter -ErrorAction SilentlyContinue
$freeGB = if ($psDrive) { [math]::Round($psDrive.Free / 1GB, 1) } else { 0 }
if ($diskType -eq 'SSD' -and $psDrive -and $freeGB -lt 15) {
    Write-CasperLog "Diskte yalnızca $freeGB GB boş alan var." -Level Warn
    if (Read-YesNo -Question "Hazırda bekletme kapatılsın mı? (~$ramGB GB yer açar, Hızlı başlatma da kapanır)" -Default $false) {
        Set-StateExtra -Key 'Hibernate' -Value 'on'
        Invoke-Change -Description 'Hazırda bekletme kapatıldı' -Action {
            & powercfg.exe /hibernate off
        }
    }
}
