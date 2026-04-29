local CNH = require("scripts.core.context")
local _ENV = CNH

-- Aba General: opcoes globais, referencia de player, hit feedback e champion styling.

function registerMCMGeneralPage(mcmName)
    MCM.AddText(mcmName, "General", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.BOTH, PREVIEW_EFFECT_MODE.CHAMPION, cursorIsAtThisOption)
        return "Quick actions"
    end)
    MCM.AddSpace(mcmName, "General")

    addActionButton(
        mcmName,
        "General",
        function()
            if state.previewBuildDone then
                return "Randomize preview names"
            end

            return "Randomize preview names (loading list)"
        end,
        PREVIEW_OWNER.BOTH,
        RandomizeCombatNameHUDPreviewNames,
        nil,
        "Randomizes both boss and enemy names used by Mod Config Menu previews."
    )

    addResetButton(mcmName, "General", "Reset General Settings", PREVIEW_OWNER.BOTH, resetGeneralConfig, "Restores only General settings to their defaults.")
    addResetButton(mcmName, "General", "Reset All Settings", PREVIEW_OWNER.BOTH, resetAllConfig, "Restores every Combat Name HUD setting to its default value.")
    MCM.AddSpace(mcmName, "General")

    MCM.AddText(mcmName, "General", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.BOTH, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Display"
    end)

    addGeneralPreviewReferenceSetting(mcmName, "General")
    addBooleanSetting(mcmName, "General", "showTextOutline", "Text outline", PREVIEW_OWNER.BOTH, nil, nil, "Draws a dark pixel outline around labels.")
    MCM.AddSpace(mcmName, "General")

    MCM.AddText(mcmName, "General", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.BOTH, PREVIEW_EFFECT_MODE.HIT, cursorIsAtThisOption)
        return "Hit feedback"
    end)

    addBooleanSetting(mcmName, "General", "showHitFlash", "Hit flash", PREVIEW_OWNER.BOTH, nil, PREVIEW_EFFECT_MODE.HIT, "Flashes the label color when the player hits a tracked boss or enemy.")
    addBooleanSetting(mcmName, "General", "showHitPunch", "Hit punch", PREVIEW_OWNER.BOTH, nil, PREVIEW_EFFECT_MODE.HIT, "Briefly enlarges the label when the player hits a tracked boss or enemy.")
    addHitEffectFramesSetting(mcmName, "General")
    MCM.AddSpace(mcmName, "General")

    MCM.AddText(mcmName, "General", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.BOTH, PREVIEW_EFFECT_MODE.CHAMPION, cursorIsAtThisOption)
        return "Champion labels"
    end)

    addBooleanSetting(mcmName, "General", "showChampionStyling", "Champion effects", PREVIEW_OWNER.BOTH, nil, PREVIEW_EFFECT_MODE.CHAMPION, "Uses champion-specific colors, active effects, and death effects.")
    addNumberSetting(mcmName, "General", function() return "Champion descriptor: " .. getChampionDescriptorModeLabel(config.championDescriptorMode) end, function() return config.championDescriptorMode end, 1, 3, PREVIEW_OWNER.BOTH, function(value) config.championDescriptorMode = value end, PREVIEW_EFFECT_MODE.CHAMPION, "Controls whether champion labels show no descriptor, a thematic label, or the game enum.")
end
