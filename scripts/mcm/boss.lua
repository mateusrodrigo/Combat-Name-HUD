local CNH = require("scripts.core.context")
local _ENV = CNH

-- Aba Boss: visibilidade, cores, posicao, animacoes e feedback reativo de boss.

function registerMCMBossPage(mcmName)
    MCM.AddText(mcmName, "Boss", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.BOSS, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Quick actions"
    end)
    MCM.AddSpace(mcmName, "Boss")

    addActionButton(
        mcmName,
        "Boss",
        function()
            if state.previewBuildDone then
                return "Randomize boss preview name"
            end

            return "Randomize boss preview name (loading list)"
        end,
        PREVIEW_OWNER.BOSS,
        RandomizeCombatNameHUDBossPreviewName,
        nil,
        "Randomizes the boss name used by boss previews, including stack and collapse examples."
    )

    addResetButton(mcmName, "Boss", "Reset Boss Settings", PREVIEW_OWNER.BOSS, resetBossConfig, "Restores only Boss settings to their defaults.")
    MCM.AddSpace(mcmName, "Boss")

    MCM.AddText(mcmName, "Boss", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.BOSS, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Visibility"
    end)

    addBooleanSetting(mcmName, "Boss", "showBossName", "Boss names", PREVIEW_OWNER.BOSS, nil, nil, "Shows boss names during active boss fights.")
    addBooleanSetting(mcmName, "Boss", "showBossPrefix", "'Boss:' prefix", PREVIEW_OWNER.BOSS, clearRuntimeLabels, nil, "Adds the 'Boss:' prefix before boss names.")
    MCM.AddSpace(mcmName, "Boss")

    MCM.AddText(mcmName, "Boss", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.BOSS, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Position"
    end)

    addNumberSetting(mcmName, "Boss", function() return "Boss position: " .. getPositionModeLabel(config.bossPositionMode) end, function() return config.bossPositionMode end, 1, 3, PREVIEW_OWNER.BOSS, function(value) config.bossPositionMode = value end, nil, "Chooses whether boss labels use a fixed screen position or follow the boss entity.")
    addBossCollapseSetting(mcmName, "Boss")
    addBossLineSpacingSetting(mcmName, "Boss")
    addPreviewReferenceSetting(mcmName, "Boss", "showPreviewReferenceBoss", "Player reference", PREVIEW_OWNER.BOSS, function() return config.bossPositionMode end)
    addNumberSetting(mcmName, "Boss", function() return getActiveOffsetLabel(config.bossPositionMode, "Boss") .. " X offset: " .. getBossActiveXOffset() end, getBossActiveXOffset, -240, 240, PREVIEW_OWNER.BOSS, setBossActiveXOffset, nil, "Moves the boss label horizontally for the currently selected position mode.")
    addNumberSetting(mcmName, "Boss", function() return getActiveOffsetLabel(config.bossPositionMode, "Boss") .. " Y offset: " .. getBossActiveYOffset() end, getBossActiveYOffset, function() return getActiveYOffsetMinimum(config.bossPositionMode) end, 160, PREVIEW_OWNER.BOSS, setBossActiveYOffset, nil, "Moves the boss label vertically for the currently selected position mode.")
    addNumberSetting(mcmName, "Boss", function() return "Boss scale: " .. string.format("%.1f", config.bossTextScale) end, function() return config.bossTextScale * 10 end, 1, 30, PREVIEW_OWNER.BOSS, function(value) config.bossTextScale = value / 10 end, nil, "Controls boss label size.")
    MCM.AddSpace(mcmName, "Boss")

    MCM.AddText(mcmName, "Boss", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.BOSS, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Text color"
    end)

    addNumberSetting(mcmName, "Boss", function() return "Boss color: " .. getTextColorModeLabel(config.bossTextColorMode) end, function() return config.bossTextColorMode end, 1, 10, PREVIEW_OWNER.BOSS, function(value) config.bossTextColorMode = value end, nil, "Selects the boss label color mode. Default uses contextual colors such as HP and champion styling.")
    addHpColorSetting(mcmName, "Boss", "showBossHpColor", "HP color", PREVIEW_OWNER.BOSS, function() return config.bossTextColorMode end)
    addCustomColorChannelSetting(mcmName, "Boss", "bossCustomRed", "Custom red", PREVIEW_OWNER.BOSS, function() return config.bossTextColorMode end)
    addCustomColorChannelSetting(mcmName, "Boss", "bossCustomGreen", "Custom green", PREVIEW_OWNER.BOSS, function() return config.bossTextColorMode end)
    addCustomColorChannelSetting(mcmName, "Boss", "bossCustomBlue", "Custom blue", PREVIEW_OWNER.BOSS, function() return config.bossTextColorMode end)
    addNumberSetting(mcmName, "Boss", function() return "Boss alpha: " .. config.bossTextAlpha .. "%" end, function() return config.bossTextAlpha end, 0, 100, PREVIEW_OWNER.BOSS, function(value) config.bossTextAlpha = value end, nil, "Controls boss label transparency.")
    MCM.AddSpace(mcmName, "Boss")

    MCM.AddText(mcmName, "Boss", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.BOSS, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Animations"
    end)
    
    addNumberSetting(mcmName, "Boss", function() return "Intro effect: " .. getBossIntroEffectModeLabel(config.bossIntroEffectMode) end, function() return config.bossIntroEffectMode end, 1, IntroEffects.MAX_ID, PREVIEW_OWNER.BOSS, function(value) config.bossIntroEffectMode = value end, PREVIEW_EFFECT_MODE.BOSS_INTRO, "Selects the animation used when a boss label first appears.")
    addNumberSetting(mcmName, "Boss", function() return "Intro frames: " .. config.bossIntroEffectFrames end, function() return config.bossIntroEffectFrames end, 1, 120, PREVIEW_OWNER.BOSS, function(value) config.bossIntroEffectFrames = value end, PREVIEW_EFFECT_MODE.BOSS_INTRO, "Controls how long the boss intro effect lasts.")
    addNumberSetting(mcmName, "Boss", function() return "Active effect: " .. getActiveEffectModeLabel(config.bossActiveEffectMode) end, function() return config.bossActiveEffectMode end, 1, ActiveEffects.MAX_ID, PREVIEW_OWNER.BOSS, function(value) config.bossActiveEffectMode = value end, PREVIEW_EFFECT_MODE.ACTIVE, "Selects the animation used while the boss label is visible.")
    addNumberSetting(mcmName, "Boss", function() return "Active frames: " .. config.bossActiveEffectFrames end, function() return config.bossActiveEffectFrames end, 1, 120, PREVIEW_OWNER.BOSS, function(value) config.bossActiveEffectFrames = value end, PREVIEW_EFFECT_MODE.ACTIVE, "Controls the active effect loop speed. Lower values animate faster; higher values animate slower.")
    addNumberSetting(mcmName, "Boss", function() return "Death effect: " .. getDeathEffectModeLabel(config.bossDeathEffectMode) end, function() return config.bossDeathEffectMode end, 1, DeathEffects.MAX_ID, PREVIEW_OWNER.BOSS, function(value) config.bossDeathEffectMode = value end, PREVIEW_EFFECT_MODE.DEATH, "Selects the animation played when a tracked boss dies.")
    addNumberSetting(mcmName, "Boss", function() return "Death frames: " .. config.bossDeathEffectFrames end, function() return config.bossDeathEffectFrames end, 1, 120, PREVIEW_OWNER.BOSS, function(value) config.bossDeathEffectFrames = value end, PREVIEW_EFFECT_MODE.DEATH, "Controls how long the boss death effect lasts.")
    MCM.AddSpace(mcmName, "Boss")

    MCM.AddText(mcmName, "Boss", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.BOSS, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Reactive feedback"
    end)

    addBooleanSetting(mcmName, "Boss", "bossShakeOnDamage", "Shake when damaging player", PREVIEW_OWNER.BOSS, nil, PREVIEW_EFFECT_MODE.SHAKE, "Makes the boss label shake when that boss damages the player.")
    addNumberSetting(mcmName, "Boss", function() return "Shake frames: " .. config.bossShakeFrames end, function() return config.bossShakeFrames end, 1, 90, PREVIEW_OWNER.BOSS, function(value) config.bossShakeFrames = value end, PREVIEW_EFFECT_MODE.SHAKE, "Controls how long the boss damage shake lasts.")
    addNumberSetting(mcmName, "Boss", function() return "Shake strength: " .. config.bossShakeStrength end, function() return config.bossShakeStrength end, 0, 12, PREVIEW_OWNER.BOSS, function(value) config.bossShakeStrength = value end, PREVIEW_EFFECT_MODE.SHAKE, "Controls how intense the boss damage shake is.")
end
