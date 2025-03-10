local Translations = {}
if C_Config.locale == 'nl' then
    Translations = {
        error = {
        },
        success = {
        },
        info = {
        },
        progress = {
        },
        menu = {
        },
        target = {
            recruit = 'Recruteer..',
            kidnap = 'Kidnap..',
        },
        commands = {
        },
    }

    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true
    })
end
