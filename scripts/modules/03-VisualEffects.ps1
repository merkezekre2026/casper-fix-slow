<#
    03 - Görsel efektler
    "En iyi performans" ayarına yakın bir profil uygular; yazı tipi yumuşatma ve küçük resimler
    korunur (aksi hâlde ekran okunaksız ve kullanışsız olur).
    Değişikliklerin tamamı oturumu kapatıp açınca görünür.
#>

Write-CasperLog 'Görsel efektler' -Level Step

$desktop = 'HKCU:\Control Panel\Desktop'
$advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

# 3 = Özel (aşağıdaki ayrı ayarlar geçerli olur)
Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Value 3

# Animasyonları, gölgeleri ve solma efektlerini kapatan maske (yazı tipi yumuşatma açık kalır).
[byte[]]$mask = 0x90, 0x12, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00
Set-RegValue -Path $desktop -Name 'UserPreferencesMask' -Value $mask -Type Binary
Set-RegValue -Path $desktop -Name 'DragFullWindows' -Value '0' -Type String
Set-RegValue -Path $desktop -Name 'MenuShowDelay' -Value '100' -Type String
Set-RegValue -Path $desktop -Name 'FontSmoothing' -Value '2' -Type String
Set-RegValue -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name 'MinAnimate' -Value '0' -Type String

Set-RegValue -Path $advanced -Name 'TaskbarAnimations' -Value 0
Set-RegValue -Path $advanced -Name 'ListviewAlphaSelect' -Value 0
Set-RegValue -Path $advanced -Name 'ListviewShadow' -Value 0
Set-RegValue -Path $advanced -Name 'IconsOnly' -Value 0

# Şeffaflık ve Aero Peek (Intel HD 3000/4000 için belirgin rahatlama)
Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value 0
Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\DWM' -Name 'EnableAeroPeek' -Value 0

Write-CasperLog 'Görsel ayarların tamamı için oturumu kapatıp açın.' -Level Info
