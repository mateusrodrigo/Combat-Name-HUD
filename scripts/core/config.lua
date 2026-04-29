local CNH = require("scripts.core.context")
local _ENV = CNH

-- Config padrao e operacoes de reset. Este arquivo nao rastreia entidades; ele
-- so define valores persistentes e helpers derivados da config.
-- =========================================================
-- DEFAULT CONFIG
-- =========================================================

-- DEFAULT_CONFIG is the only source of truth for new saves and reset buttons.
-- loadConfig only copies valid saved keys into the active config.
DEFAULT_CONFIG = {
    showBossName = true,
    showEnemyName = true,

    showBossPrefix = false,
    showEnemyPrefix = false,
    showTextOutline = false,

    fixedBossVisibleCount = FIXED_BOSS_VISIBLE_COUNT.TWO,
    simplifyRepeatedBossNames = true,

    showPreviewReferenceGeneral = true,
    showPreviewReferenceBoss = true,
    showPreviewReferenceEnemy = true,
    showHitFlash = true,
    showHitPunch = true,
    showBossHpColor = true,
    showEnemyHpColor = true,
    showChampionStyling = true,
    championDescriptorMode = CHAMPION_DESCRIPTOR_MODE.DISABLED,
    hitEffectFrames = 10,

    bossIntroEffectMode = BOSS_INTRO_EFFECT.FADE_SLIDE,
    bossIntroEffectFrames = 28,

    bossActiveEffectMode = ACTIVE_LABEL_EFFECT.DISABLED,
    enemyActiveEffectMode = ACTIVE_LABEL_EFFECT.DISABLED,
    bossActiveEffectFrames = 60,
    enemyActiveEffectFrames = 60,

    bossTextColorMode = TEXT_COLOR_MODE.DEFAULT,
    bossCustomRed = 255,
    bossCustomGreen = 255,
    bossCustomBlue = 255,
    bossTextAlpha = 100,

    enemyTextColorMode = TEXT_COLOR_MODE.DEFAULT,
    enemyCustomRed = 255,
    enemyCustomGreen = 255,
    enemyCustomBlue = 255,
    enemyTextAlpha = 100,

    bossDeathEffectMode = DEATH_LABEL_EFFECT.FADE_OUT,
    enemyDeathEffectMode = DEATH_LABEL_EFFECT.FADE_OUT,

    bossDeathEffectFrames = 45,
    enemyDeathEffectFrames = 45,

    bossShakeOnDamage = true,
    bossShakeFrames = 18,
    bossShakeStrength = 3,

    enemyShakeOnDamage = true,
    enemyShakeFrames = 18,
    enemyShakeStrength = 3,

    bossPositionMode = POSITION_MODE.FIXED_POSITION,
    bossFixedXOffset = 0,
    bossFixedYOffset = -40,
    bossAboveXOffset = 0,
    bossAboveYOffset = 55,
    bossBelowXOffset = 0,
    bossBelowYOffset = 20,
    bossTextScale = 1.0,
    bossLineSpacing = 4,

    enemyPositionMode = POSITION_MODE.FIXED_POSITION,
    enemyFixedXOffset = 0,
    enemyFixedYOffset = -25,
    enemyAboveXOffset = 0,
    enemyAboveYOffset = 45,
    enemyBelowXOffset = 0,
    enemyBelowYOffset = 15,
    enemyTextScale = 0.8,
    enemyDisplayFrames = 90
}

function copyTable(source)
    local result = {}

    for key, value in pairs(source) do
        result[key] = value
    end

    return result
end

config = copyTable(DEFAULT_CONFIG)

function isBossCollapseAvailable()
    return true
end

function isBossCollapseEnabled()
    if config.bossPositionMode == POSITION_MODE.FIXED_POSITION then
        return true
    end

    return config.simplifyRepeatedBossNames
end

function clampFixedBossVisibleCount(value)
    value = math.floor(tonumber(value) or FIXED_BOSS_VISIBLE_COUNT.TWO)

    if value < FIXED_BOSS_VISIBLE_COUNT.ONE then
        return FIXED_BOSS_VISIBLE_COUNT.ONE
    end

    if value > FIXED_BOSS_VISIBLE_COUNT.ALL then
        return FIXED_BOSS_VISIBLE_COUNT.ALL
    end

    return value
end

function getFixedBossVisibleCount()
    config.fixedBossVisibleCount = clampFixedBossVisibleCount(config.fixedBossVisibleCount)
    return config.fixedBossVisibleCount
end

function getFixedBossVisibleCountLabel(value)
    value = clampFixedBossVisibleCount(value)

    if value == FIXED_BOSS_VISIBLE_COUNT.ALL then
        return "All"
    end

    return tostring(value)
end

function getFixedBossVisibleLimit()
    local value = getFixedBossVisibleCount()

    if value == FIXED_BOSS_VISIBLE_COUNT.ALL then
        return nil
    end

    return value
end

function getBossCollapseSettingValue()
    if config.bossPositionMode == POSITION_MODE.FIXED_POSITION then
        return getFixedBossVisibleCount()
    end

    return config.simplifyRepeatedBossNames and 2 or 1
end

function getBossCollapseSettingLabel()
    if config.bossPositionMode == POSITION_MODE.FIXED_POSITION then
        return "Fixed boss limit: " .. getFixedBossVisibleCountLabel(config.fixedBossVisibleCount)
    end

    return "Merge repeated bosses: " .. (config.simplifyRepeatedBossNames and "True" or "False")
end

function setBossCollapseSettingValue(value)
    if config.bossPositionMode == POSITION_MODE.FIXED_POSITION then
        config.fixedBossVisibleCount = clampFixedBossVisibleCount(value)
        return
    end

    -- The MCM row is registered as a number so it can also expose 1/2/3/All in
    -- fixed mode. In above/below modes, every press simply toggles the boolean.
    config.simplifyRepeatedBossNames = not config.simplifyRepeatedBossNames
end

-- =========================================================
-- RESET CONFIG
-- =========================================================


function resetGeneralConfig()
    -- General reset avoids touching boss/enemy tuning values.
    config.showTextOutline = DEFAULT_CONFIG.showTextOutline
    config.showPreviewReferenceGeneral = DEFAULT_CONFIG.showPreviewReferenceGeneral
    config.showHitFlash = DEFAULT_CONFIG.showHitFlash
    config.showHitPunch = DEFAULT_CONFIG.showHitPunch
    config.showChampionStyling = DEFAULT_CONFIG.showChampionStyling
    config.championDescriptorMode = DEFAULT_CONFIG.championDescriptorMode
    config.hitEffectFrames = DEFAULT_CONFIG.hitEffectFrames
    if clearRuntimeLabels then clearRuntimeLabels() end
end

function resetBossConfig()
    -- Boss reset restores all boss-only visual, position, and shake settings.
    config.showBossName = DEFAULT_CONFIG.showBossName
    config.showBossPrefix = DEFAULT_CONFIG.showBossPrefix
    config.showPreviewReferenceBoss = DEFAULT_CONFIG.showPreviewReferenceBoss
    config.showBossHpColor = DEFAULT_CONFIG.showBossHpColor
    config.bossIntroEffectMode = DEFAULT_CONFIG.bossIntroEffectMode
    config.bossIntroEffectFrames = DEFAULT_CONFIG.bossIntroEffectFrames
    config.fixedBossVisibleCount = DEFAULT_CONFIG.fixedBossVisibleCount
    config.simplifyRepeatedBossNames = DEFAULT_CONFIG.simplifyRepeatedBossNames

    config.bossTextColorMode = DEFAULT_CONFIG.bossTextColorMode
    config.bossCustomRed = DEFAULT_CONFIG.bossCustomRed
    config.bossCustomGreen = DEFAULT_CONFIG.bossCustomGreen
    config.bossCustomBlue = DEFAULT_CONFIG.bossCustomBlue
    config.bossTextAlpha = DEFAULT_CONFIG.bossTextAlpha

    config.bossActiveEffectMode = DEFAULT_CONFIG.bossActiveEffectMode
    config.bossActiveEffectFrames = DEFAULT_CONFIG.bossActiveEffectFrames
    config.bossDeathEffectMode = DEFAULT_CONFIG.bossDeathEffectMode
    config.bossDeathEffectFrames = DEFAULT_CONFIG.bossDeathEffectFrames

    config.bossShakeOnDamage = DEFAULT_CONFIG.bossShakeOnDamage
    config.bossShakeFrames = DEFAULT_CONFIG.bossShakeFrames
    config.bossShakeStrength = DEFAULT_CONFIG.bossShakeStrength

    config.bossPositionMode = DEFAULT_CONFIG.bossPositionMode
    config.bossFixedXOffset = DEFAULT_CONFIG.bossFixedXOffset
    config.bossFixedYOffset = DEFAULT_CONFIG.bossFixedYOffset
    config.bossAboveXOffset = DEFAULT_CONFIG.bossAboveXOffset
    config.bossAboveYOffset = DEFAULT_CONFIG.bossAboveYOffset
    config.bossBelowXOffset = DEFAULT_CONFIG.bossBelowXOffset
    config.bossBelowYOffset = DEFAULT_CONFIG.bossBelowYOffset
    config.bossTextScale = DEFAULT_CONFIG.bossTextScale
    config.bossLineSpacing = DEFAULT_CONFIG.bossLineSpacing
    if clearRuntimeLabels then clearRuntimeLabels() end
end

function resetEnemyConfig()
    -- Enemy reset restores all enemy-only visual, position, and display settings.
    config.showEnemyName = DEFAULT_CONFIG.showEnemyName
    config.showEnemyPrefix = DEFAULT_CONFIG.showEnemyPrefix
    config.showPreviewReferenceEnemy = DEFAULT_CONFIG.showPreviewReferenceEnemy
    config.showEnemyHpColor = DEFAULT_CONFIG.showEnemyHpColor

    config.enemyTextColorMode = DEFAULT_CONFIG.enemyTextColorMode
    config.enemyCustomRed = DEFAULT_CONFIG.enemyCustomRed
    config.enemyCustomGreen = DEFAULT_CONFIG.enemyCustomGreen
    config.enemyCustomBlue = DEFAULT_CONFIG.enemyCustomBlue
    config.enemyTextAlpha = DEFAULT_CONFIG.enemyTextAlpha

    config.enemyActiveEffectMode = DEFAULT_CONFIG.enemyActiveEffectMode
    config.enemyActiveEffectFrames = DEFAULT_CONFIG.enemyActiveEffectFrames
    config.enemyDeathEffectMode = DEFAULT_CONFIG.enemyDeathEffectMode
    config.enemyDeathEffectFrames = DEFAULT_CONFIG.enemyDeathEffectFrames

    config.enemyShakeOnDamage = DEFAULT_CONFIG.enemyShakeOnDamage
    config.enemyShakeFrames = DEFAULT_CONFIG.enemyShakeFrames
    config.enemyShakeStrength = DEFAULT_CONFIG.enemyShakeStrength

    config.enemyPositionMode = DEFAULT_CONFIG.enemyPositionMode
    config.enemyFixedXOffset = DEFAULT_CONFIG.enemyFixedXOffset
    config.enemyFixedYOffset = DEFAULT_CONFIG.enemyFixedYOffset
    config.enemyAboveXOffset = DEFAULT_CONFIG.enemyAboveXOffset
    config.enemyAboveYOffset = DEFAULT_CONFIG.enemyAboveYOffset
    config.enemyBelowXOffset = DEFAULT_CONFIG.enemyBelowXOffset
    config.enemyBelowYOffset = DEFAULT_CONFIG.enemyBelowYOffset
    config.enemyTextScale = DEFAULT_CONFIG.enemyTextScale
    config.enemyDisplayFrames = DEFAULT_CONFIG.enemyDisplayFrames
    if clearRuntimeLabels then clearRuntimeLabels() end
end

function resetAllConfig()
    -- Full reset replaces the config table with a fresh shallow copy.
    config = copyTable(DEFAULT_CONFIG)
    if clearRuntimeLabels then clearRuntimeLabels() end
end

