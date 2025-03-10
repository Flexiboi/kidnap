local Translations = {}
if C_Config.locale == 'en' then
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
            recruit = 'Recruit..',
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
