@{
    Severity     = @('Error', 'Warning')
    ExcludeRules = @(
        # Etkileşimli, renkli konsol çıktısı bilinçli olarak kullanılıyor.
        'PSAvoidUsingWriteHost'
        # Durum global bir nesnede tutuluyor (modüller dot-source ile çalışır).
        'PSAvoidGlobalVars'
        # -DryRun kendi önizleme mekanizmamız; ShouldProcess kullanılmıyor.
        'PSUseShouldProcessForStateChangingFunctions'
        # Türkçe karakterler için dosyalar UTF-8 BOM ile kaydedilir; kural yanlış pozitif verir.
        'PSUseBOMForUnicodeEncodedFile'
    )
}
