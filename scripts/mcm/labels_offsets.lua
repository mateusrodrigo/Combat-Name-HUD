local CNH = require("scripts.core.context")
local _ENV = CNH

-- Labels auxiliares do MCM e getters/setters de offset. Centraliza a diferenca
-- entre fixed, above e below para boss/enemy.

-- =========================================================
-- LABELS DO MCM
-- =========================================================

function getPositionModeLabel(positionMode)
    if positionMode == POSITION_MODE.ABOVE_ENTITY then return "Above entity" end
    if positionMode == POSITION_MODE.BELOW_ENTITY then return "Below entity" end
    return "Fixed position"
end

function getActiveEffectModeLabel(effectMode)
    return ActiveEffects.getLabel(effectMode)
end

function getBossIntroEffectModeLabel(effectMode)
    return IntroEffects.getLabel(effectMode)
end

function getTextColorModeLabel(colorMode)
    if colorMode == TEXT_COLOR_MODE.WHITE then return "White" end
    if colorMode == TEXT_COLOR_MODE.RED then return "Red" end
    if colorMode == TEXT_COLOR_MODE.GREEN then return "Green" end
    if colorMode == TEXT_COLOR_MODE.BLUE then return "Blue" end
    if colorMode == TEXT_COLOR_MODE.YELLOW then return "Yellow" end
    if colorMode == TEXT_COLOR_MODE.CYAN then return "Cyan" end
    if colorMode == TEXT_COLOR_MODE.MAGENTA then return "Magenta" end
    if colorMode == TEXT_COLOR_MODE.RAINBOW then return "Rainbow" end
    if colorMode == TEXT_COLOR_MODE.CUSTOM_RGB then return "Custom RGB" end
    return "Default"
end

function getChampionDescriptorModeLabel(descriptorMode)
    if descriptorMode == CHAMPION_DESCRIPTOR_MODE.LABEL then return "Label" end
    if descriptorMode == CHAMPION_DESCRIPTOR_MODE.ENUM then return "Enum" end
    return "Off"
end

function getDeathEffectModeLabel(effectMode)
    return DeathEffects.getLabel(effectMode)
end

function getActiveOffsetLabel(positionMode, owner)
    if positionMode == POSITION_MODE.ABOVE_ENTITY then return owner .. " above" end
    if positionMode == POSITION_MODE.BELOW_ENTITY then return owner .. " below" end
    return owner .. " fixed"
end

function getActiveYOffsetMinimum(positionMode)
    if positionMode == POSITION_MODE.ABOVE_ENTITY or positionMode == POSITION_MODE.BELOW_ENTITY then
        return 0
    end

    return -160
end

-- =========================================================
-- OFFSETS ATIVOS
-- =========================================================

function getBossActiveXOffset()
    if config.bossPositionMode == POSITION_MODE.ABOVE_ENTITY then return config.bossAboveXOffset end
    if config.bossPositionMode == POSITION_MODE.BELOW_ENTITY then return config.bossBelowXOffset end
    return config.bossFixedXOffset
end

function getBossActiveYOffset()
    if config.bossPositionMode == POSITION_MODE.ABOVE_ENTITY then return math.max(0, config.bossAboveYOffset) end
    if config.bossPositionMode == POSITION_MODE.BELOW_ENTITY then return math.max(0, config.bossBelowYOffset) end
    return config.bossFixedYOffset
end

function setBossActiveXOffset(value)
    if config.bossPositionMode == POSITION_MODE.ABOVE_ENTITY then
        config.bossAboveXOffset = value
        return
    end

    if config.bossPositionMode == POSITION_MODE.BELOW_ENTITY then
        config.bossBelowXOffset = value
        return
    end

    config.bossFixedXOffset = value
end

function setBossActiveYOffset(value)
    value = math.max(value, getActiveYOffsetMinimum(config.bossPositionMode))

    if config.bossPositionMode == POSITION_MODE.ABOVE_ENTITY then
        config.bossAboveYOffset = value
        return
    end

    if config.bossPositionMode == POSITION_MODE.BELOW_ENTITY then
        config.bossBelowYOffset = value
        return
    end

    config.bossFixedYOffset = value
end

function getEnemyActiveXOffset()
    if config.enemyPositionMode == POSITION_MODE.ABOVE_ENTITY then return config.enemyAboveXOffset end
    if config.enemyPositionMode == POSITION_MODE.BELOW_ENTITY then return config.enemyBelowXOffset end
    return config.enemyFixedXOffset
end

function getEnemyActiveYOffset()
    if config.enemyPositionMode == POSITION_MODE.ABOVE_ENTITY then return math.max(0, config.enemyAboveYOffset) end
    if config.enemyPositionMode == POSITION_MODE.BELOW_ENTITY then return math.max(0, config.enemyBelowYOffset) end
    return config.enemyFixedYOffset
end

function setEnemyActiveXOffset(value)
    if config.enemyPositionMode == POSITION_MODE.ABOVE_ENTITY then
        config.enemyAboveXOffset = value
        return
    end

    if config.enemyPositionMode == POSITION_MODE.BELOW_ENTITY then
        config.enemyBelowXOffset = value
        return
    end

    config.enemyFixedXOffset = value
end

function setEnemyActiveYOffset(value)
    value = math.max(value, getActiveYOffsetMinimum(config.enemyPositionMode))

    if config.enemyPositionMode == POSITION_MODE.ABOVE_ENTITY then
        config.enemyAboveYOffset = value
        return
    end

    if config.enemyPositionMode == POSITION_MODE.BELOW_ENTITY then
        config.enemyBelowYOffset = value
        return
    end

    config.enemyFixedYOffset = value
end

