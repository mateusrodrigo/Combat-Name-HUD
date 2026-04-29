local CNH = require("scripts.core.context")
local _ENV = CNH

-- Aba Enemy: visibilidade, cores, posicao, animacoes e lifetime do inimigo rastreado.

function registerMCMEnemyPage(mcmName)
    MCM.AddText(mcmName, "Enemy", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.ENEMY, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Quick actions"
    end)
    MCM.AddSpace(mcmName, "Enemy")

    addActionButton(
        mcmName,
        "Enemy",
        function()
            if state.previewBuildDone then
                return "Randomize enemy preview name"
            end

            return "Randomize enemy preview name (loading list)"
        end,
        PREVIEW_OWNER.ENEMY,
        RandomizeCombatNameHUDEnemyPreviewName,
        nil,
        "Randomizes the enemy name used by enemy and champion previews."
    )

    addResetButton(mcmName, "Enemy", "Reset Enemy Settings", PREVIEW_OWNER.ENEMY, resetEnemyConfig, "Restores only Enemy settings to their defaults.")
    MCM.AddSpace(mcmName, "Enemy")

    MCM.AddText(mcmName, "Enemy", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.ENEMY, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Visibility"
    end)

    addBooleanSetting(mcmName, "Enemy", "showEnemyName", "Enemy names", PREVIEW_OWNER.ENEMY, function(value)
        if not value then clearEnemyName(false) end
    end, nil, "Shows the name of the last enemy damaged by the player.")
    addBooleanSetting(mcmName, "Enemy", "showEnemyPrefix", "'Enemy:' prefix", PREVIEW_OWNER.ENEMY, clearRuntimeLabels, nil, "Adds the 'Enemy:' prefix before enemy names.")
    addNumberSetting(mcmName, "Enemy", function() return "Display frames: " .. config.enemyDisplayFrames end, function() return config.enemyDisplayFrames end, 15, 300, PREVIEW_OWNER.ENEMY, function(value) config.enemyDisplayFrames = value end, nil, "Controls how long an enemy name stays visible after the player hits it.")
    MCM.AddSpace(mcmName, "Enemy")

    MCM.AddText(mcmName, "Enemy", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.ENEMY, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Position"
    end)

    addNumberSetting(mcmName, "Enemy", function() return "Enemy position: " .. getPositionModeLabel(config.enemyPositionMode) end, function() return config.enemyPositionMode end, 1, 3, PREVIEW_OWNER.ENEMY, function(value) config.enemyPositionMode = value end, nil, "Chooses whether enemy labels use a fixed screen position or follow the enemy entity.")
    addPreviewReferenceSetting(mcmName, "Enemy", "showPreviewReferenceEnemy", "Player reference", PREVIEW_OWNER.ENEMY, function() return config.enemyPositionMode end)
    addNumberSetting(mcmName, "Enemy", function() return getActiveOffsetLabel(config.enemyPositionMode, "Enemy") .. " X offset: " .. getEnemyActiveXOffset() end, getEnemyActiveXOffset, -240, 240, PREVIEW_OWNER.ENEMY, setEnemyActiveXOffset, nil, "Moves the enemy label horizontally for the currently selected position mode.")
    addNumberSetting(mcmName, "Enemy", function() return getActiveOffsetLabel(config.enemyPositionMode, "Enemy") .. " Y offset: " .. getEnemyActiveYOffset() end, getEnemyActiveYOffset, function() return getActiveYOffsetMinimum(config.enemyPositionMode) end, 160, PREVIEW_OWNER.ENEMY, setEnemyActiveYOffset, nil, "Moves the enemy label vertically for the currently selected position mode.")
    addNumberSetting(mcmName, "Enemy", function() return "Enemy scale: " .. string.format("%.1f", config.enemyTextScale) end, function() return config.enemyTextScale * 10 end, 1, 30, PREVIEW_OWNER.ENEMY, function(value) config.enemyTextScale = value / 10 end, nil, "Controls enemy label size.")
    MCM.AddSpace(mcmName, "Enemy")

    MCM.AddText(mcmName, "Enemy", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.ENEMY, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Text color"
    end)

    addNumberSetting(mcmName, "Enemy", function() return "Enemy color: " .. getTextColorModeLabel(config.enemyTextColorMode) end, function() return config.enemyTextColorMode end, 1, 10, PREVIEW_OWNER.ENEMY, function(value) config.enemyTextColorMode = value end, nil, "Selects the enemy label color mode. Default uses contextual colors such as HP and champion styling.")
    addHpColorSetting(mcmName, "Enemy", "showEnemyHpColor", "HP color", PREVIEW_OWNER.ENEMY, function() return config.enemyTextColorMode end)
    addCustomColorChannelSetting(mcmName, "Enemy", "enemyCustomRed", "Custom red", PREVIEW_OWNER.ENEMY, function() return config.enemyTextColorMode end)
    addCustomColorChannelSetting(mcmName, "Enemy", "enemyCustomGreen", "Custom green", PREVIEW_OWNER.ENEMY, function() return config.enemyTextColorMode end)
    addCustomColorChannelSetting(mcmName, "Enemy", "enemyCustomBlue", "Custom blue", PREVIEW_OWNER.ENEMY, function() return config.enemyTextColorMode end)
    addNumberSetting(mcmName, "Enemy", function() return "Enemy alpha: " .. config.enemyTextAlpha .. "%" end, function() return config.enemyTextAlpha end, 0, 100, PREVIEW_OWNER.ENEMY, function(value) config.enemyTextAlpha = value end, nil, "Controls enemy label transparency.")
    MCM.AddSpace(mcmName, "Enemy")

    MCM.AddText(mcmName, "Enemy", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.ENEMY, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Animations"
    end)

    addNumberSetting(mcmName, "Enemy", function() return "Active effect: " .. getActiveEffectModeLabel(config.enemyActiveEffectMode) end, function() return config.enemyActiveEffectMode end, 1, ActiveEffects.MAX_ID, PREVIEW_OWNER.ENEMY, function(value) config.enemyActiveEffectMode = value end, PREVIEW_EFFECT_MODE.ACTIVE, "Selects the animation used while the enemy label is visible.")
    addNumberSetting(mcmName, "Enemy", function() return "Active frames: " .. config.enemyActiveEffectFrames end, function() return config.enemyActiveEffectFrames end, 1, 120, PREVIEW_OWNER.ENEMY, function(value) config.enemyActiveEffectFrames = value end, PREVIEW_EFFECT_MODE.ACTIVE, "Controls the active effect loop speed. Lower values animate faster; higher values animate slower.")
    addNumberSetting(mcmName, "Enemy", function() return "Death effect: " .. getDeathEffectModeLabel(config.enemyDeathEffectMode) end, function() return config.enemyDeathEffectMode end, 1, DeathEffects.MAX_ID, PREVIEW_OWNER.ENEMY, function(value) config.enemyDeathEffectMode = value end, PREVIEW_EFFECT_MODE.DEATH, "Selects the animation played when the tracked enemy dies.")
    addNumberSetting(mcmName, "Enemy", function() return "Death frames: " .. config.enemyDeathEffectFrames end, function() return config.enemyDeathEffectFrames end, 1, 120, PREVIEW_OWNER.ENEMY, function(value) config.enemyDeathEffectFrames = value end, PREVIEW_EFFECT_MODE.DEATH, "Controls how long the enemy death effect lasts.")
    MCM.AddSpace(mcmName, "Enemy")

    MCM.AddText(mcmName, "Enemy", function(cursorIsAtThisOption)
        setPreview(PREVIEW_OWNER.ENEMY, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
        return "Reactive feedback"
    end)

    addBooleanSetting(mcmName, "Enemy", "enemyShakeOnDamage", "Shake when damaging player", PREVIEW_OWNER.ENEMY, nil, PREVIEW_EFFECT_MODE.SHAKE, "Makes the enemy label shake when the currently tracked enemy damages the player.")
    addNumberSetting(mcmName, "Enemy", function() return "Shake frames: " .. config.enemyShakeFrames end, function() return config.enemyShakeFrames end, 1, 90, PREVIEW_OWNER.ENEMY, function(value) config.enemyShakeFrames = value end, PREVIEW_EFFECT_MODE.SHAKE, "Controls how long the enemy damage shake lasts.")
    addNumberSetting(mcmName, "Enemy", function() return "Shake strength: " .. config.enemyShakeStrength end, function() return config.enemyShakeStrength end, 0, 12, PREVIEW_OWNER.ENEMY, function(value) config.enemyShakeStrength = value end, PREVIEW_EFFECT_MODE.SHAKE, "Controls how intense the enemy damage shake is.")
end
