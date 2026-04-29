local CNH = require("scripts.core.context")
local _ENV = CNH

-- Traduz um owner generico (boss/enemy) para a config concreta usada pelo render.
function getOwnerSettings(owner)
    -- This is the core deduplication layer: render/update code can ask for a
    -- generic "owner" and receive the right boss or enemy config without branching
    -- everywhere else.
    if owner == LABEL_OWNER.BOSS then
        return {
            owner = LABEL_OWNER.BOSS,
            showName = config.showBossName,
            showPrefix = config.showBossPrefix,
            prefix = "Boss: ",
            positionMode = config.bossPositionMode,
            fixedXOffset = config.bossFixedXOffset,
            fixedYOffset = config.bossFixedYOffset,
            aboveXOffset = config.bossAboveXOffset,
            aboveYOffset = math.max(0, config.bossAboveYOffset),
            belowXOffset = config.bossBelowXOffset,
            belowYOffset = math.max(0, config.bossBelowYOffset),
            textScale = config.bossTextScale,
            textColorMode = config.bossTextColorMode,
            customRed = config.bossCustomRed,
            customGreen = config.bossCustomGreen,
            customBlue = config.bossCustomBlue,
            textAlpha = config.bossTextAlpha,
            activeEffectMode = config.bossActiveEffectMode,
            activeEffectFrames = config.bossActiveEffectFrames,
            deathEffectMode = config.bossDeathEffectMode,
            deathEffectFrames = config.bossDeathEffectFrames,
            shakeOnDamage = config.bossShakeOnDamage,
            shakeStrength = config.bossShakeStrength
        }
    end

    return {
        owner = LABEL_OWNER.ENEMY,
        showName = config.showEnemyName,
        showPrefix = config.showEnemyPrefix,
        prefix = "Enemy: ",
        positionMode = config.enemyPositionMode,
        fixedXOffset = config.enemyFixedXOffset,
        fixedYOffset = config.enemyFixedYOffset,
        aboveXOffset = config.enemyAboveXOffset,
        aboveYOffset = math.max(0, config.enemyAboveYOffset),
        belowXOffset = config.enemyBelowXOffset,
        belowYOffset = math.max(0, config.enemyBelowYOffset),
        textScale = config.enemyTextScale,
        textColorMode = config.enemyTextColorMode,
        customRed = config.enemyCustomRed,
        customGreen = config.enemyCustomGreen,
        customBlue = config.enemyCustomBlue,
        textAlpha = config.enemyTextAlpha,
        activeEffectMode = config.enemyActiveEffectMode,
        activeEffectFrames = config.enemyActiveEffectFrames,
        deathEffectMode = config.enemyDeathEffectMode,
        deathEffectFrames = config.enemyDeathEffectFrames,
        shakeOnDamage = config.enemyShakeOnDamage,
        shakeStrength = config.enemyShakeStrength
    }
end
