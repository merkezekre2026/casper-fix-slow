<#
    02 - Güç planı
    Prizdeyken işlemciyi kısmadan çalıştıran bir "CasperFix Performans" planı oluşturur.
    Pildeyken işlemci yine düşük hıza inebilir, böylece pil ömrü korunur.
#>

Write-CasperLog 'Güç planı' -Level Step

$highPerf = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
$planName = 'CasperFix Performans'

# Alt grup / ayar GUID'leri
$subProcessor = '54533251-82be-4824-96c1-47b60b740d00'
$procMin = '893dee8e-2bef-41e0-89c6-b55d0929964c'
$procMax = 'bc5038f7-23e0-4960-96da-33abaf5935ec'
$subUsb = '2a737441-1930-4402-8d77-b2bebba308a3'
$usbSuspend = '48e6b7a6-50f5-4782-a5d4-53bb8f07e226'
$subDisk = '0012ee47-9041-4b5d-9b77-535fba8b1442'
$diskIdle = '6738e2c4-e8a5-4a42-b16a-e040e769756e'

# Önceki planı kaydet (01-Backup çalıştırılmadıysa).
$active = (& powercfg.exe /getactivescheme) -join ' '
if ($active -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
    Set-StateExtra -Key 'PowerScheme' -Value $Matches[1]
}

if (Test-DryRun) {
    Write-CasperLog "(önizleme) '$planName' güç planı oluşturulup etkinleştirilecek."
    Write-CasperLog '(önizleme) Prizde: işlemci min %100, USB seçici askıya alma kapalı, disk hiç kapanmaz.'
    Write-CasperLog '(önizleme) Pilde: işlemci min %5 (pil ömrü için).'
    return
}

# Daha önce oluşturulmuş planı bul, yoksa Yüksek Performans'tan kopyala.
$existing = (& powercfg.exe /list) | Where-Object { $_ -match [regex]::Escape($planName) }
$planGuid = $null
if ($existing -and ($existing | Select-Object -First 1) -match '([0-9a-fA-F-]{36})') {
    $planGuid = $Matches[1]
}
else {
    $out = (& powercfg.exe /duplicatescheme $highPerf) -join ' '
    if ($out -notmatch '([0-9a-fA-F-]{36})') {
        # Bazı OEM kurulumlarında Yüksek Performans planı gizli/silinmiş olabilir: Dengeli'den kopyala.
        $out = (& powercfg.exe /duplicatescheme '381b4222-f694-41f0-9685-ff5bb260df2e') -join ' '
    }
    if ($out -match '([0-9a-fA-F-]{36})') {
        $planGuid = $Matches[1]
        & powercfg.exe /changename $planGuid $planName 'Eski Casper notebooklar icin performans plani (CasperFix)' | Out-Null
    }
}

if (-not $planGuid) {
    Write-CasperLog 'Güç planı oluşturulamadı.' -Level Error
    return
}

Invoke-Change -Description 'Prizde işlemci minimum/maksimum %100' -Action {
    & powercfg.exe /setacvalueindex $planGuid $subProcessor $procMin 100
    & powercfg.exe /setacvalueindex $planGuid $subProcessor $procMax 100
}
Invoke-Change -Description 'Pilde işlemci minimum %5, maksimum %100' -Action {
    & powercfg.exe /setdcvalueindex $planGuid $subProcessor $procMin 5
    & powercfg.exe /setdcvalueindex $planGuid $subProcessor $procMax 100
}
Invoke-Change -Description 'Prizde USB seçici askıya alma kapalı (USB fare/klavye takılmaları için)' -Action {
    & powercfg.exe /setacvalueindex $planGuid $subUsb $usbSuspend 0
}
Invoke-Change -Description 'Prizde sabit disk hiç kapanmasın (HDD uyanma gecikmelerini önler)' -Action {
    & powercfg.exe /setacvalueindex $planGuid $subDisk $diskIdle 0
}
Invoke-Change -Description "'$planName' planı etkinleştirildi" -Action {
    & powercfg.exe /setactive $planGuid
}
