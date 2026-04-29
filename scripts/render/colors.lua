local CNH = require("scripts.core.context")
local _ENV = CNH

-- Sistema de cores dos labels: alpha, blend, cores configuradas, HP color,
-- champion tint e hit flash sobre a cor final.
function withAlpha(color, alphaPercent)
    local alpha = clamp((alphaPercent or 100) / 100, 0, 1)

    return KColor(
        color.R or color.Red or 1,
        color.G or color.Green or 1,
        color.B or color.Blue or 1,
        alpha
    )
end

function blendColor(fromColor, toColor, amount, alphaPercent)
    amount = clamp(amount or 0, 0, 1)

    local from = fromColor or KColor(1, 1, 1, 1)
    local to = toColor or KColor(1, 1, 1, 1)
    local alpha = clamp((alphaPercent or 100) / 100, 0, 1)
    local targetAlpha = to.A or to.Alpha or 1

    return KColor(
        ((from.R or from.Red or 1) * (1 - amount)) + ((to.R or to.Red or 1) * amount),
        ((from.G or from.Green or 1) * (1 - amount)) + ((to.G or to.Green or 1) * amount),
        ((from.B or from.Blue or 1) * (1 - amount)) + ((to.B or to.Blue or 1) * amount),
        math.min(alpha, targetAlpha)
    )
end

function getColorAlpha(color)
    if color == nil then return 1 end
    if color.A ~= nil then return color.A end
    if color.Alpha ~= nil then return color.Alpha end
    if color.a ~= nil then return color.a end
    if color.alpha ~= nil then return color.alpha end
    return 1
end

function copyColorWithAlpha(color, alpha)
    local source = color or KColor(1, 1, 1, 1)

    return KColor(
        source.R or source.Red or 1,
        source.G or source.Green or 1,
        source.B or source.Blue or 1,
        alpha
    )
end

function colorWithAlphaMultiplier(color, multiplier)
    return copyColorWithAlpha(color, getColorAlpha(color) * (multiplier or 1))
end

function hasExplicitTextColor(settings)
    return settings.textColorMode ~= nil
        and settings.textColorMode ~= TEXT_COLOR_MODE.DEFAULT
end

function getConfiguredTextColor(settings)
    if settings.textColorMode == TEXT_COLOR_MODE.WHITE then return KColor(1, 1, 1, 1) end
    if settings.textColorMode == TEXT_COLOR_MODE.RED then return KColor(1, 0.2, 0.2, 1) end
    if settings.textColorMode == TEXT_COLOR_MODE.GREEN then return KColor(0.35, 1, 0.35, 1) end
    if settings.textColorMode == TEXT_COLOR_MODE.BLUE then return KColor(0.35, 0.55, 1, 1) end
    if settings.textColorMode == TEXT_COLOR_MODE.YELLOW then return KColor(1, 0.9, 0.25, 1) end
    if settings.textColorMode == TEXT_COLOR_MODE.CYAN then return KColor(0.35, 1, 1, 1) end
    if settings.textColorMode == TEXT_COLOR_MODE.MAGENTA then return KColor(1, 0.35, 1, 1) end

    if settings.textColorMode == TEXT_COLOR_MODE.CUSTOM_RGB then
        return KColor(
            clamp(settings.customRed or 255, 0, 255) / 255,
            clamp(settings.customGreen or 255, 0, 255) / 255,
            clamp(settings.customBlue or 255, 0, 255) / 255,
            1
        )
    end

    return KColor(1, 1, 1, 1)
end

function getHpColor(entity, enabled)
    if not enabled or entity == nil then return nil end
    if entity.HitPoints == nil or entity.MaxHitPoints == nil or entity.MaxHitPoints <= 0 then return nil end

    local ratio = clamp(entity.HitPoints / entity.MaxHitPoints, 0, 1)

    if ratio <= 0.25 then
        return KColor(1, 0.25, 0.2, 1)
    end

    if ratio <= 0.5 then
        return KColor(1, 0.85, 0.25, 1)
    end

    return KColor(0.65, 1, 0.45, 1)
end

function getBossHpColor(entity)
    return getHpColor(entity, config.showBossHpColor)
end

function getEnemyHpColor(entity)
    return getHpColor(entity, config.showEnemyHpColor)
end

function getContextualLabelColor(owner, entity, hitProgress, settings, isPreview)
    -- Hit flash is immediate combat feedback and stays above every color mode.
    -- Champion styling can override color, preserve the player's color, or pulse
    -- from the player's base color toward a champion tint.
    local baseColor = nil
    if hasExplicitTextColor(settings) then
        baseColor = getConfiguredTextColor(settings)
    end

    if baseColor == nil
        and isPreview
        and state.previewEffectMode == PREVIEW_EFFECT_MODE.HP_COLOR
        and (
            (owner == LABEL_OWNER.BOSS and config.showBossHpColor)
            or (owner == LABEL_OWNER.ENEMY and config.showEnemyHpColor)
        )
    then
        baseColor = getLoopedHpPreviewColor()
    end

    if baseColor == nil and owner == LABEL_OWNER.BOSS then
        local hpColor = getBossHpColor(entity)
        if hpColor ~= nil then baseColor = hpColor end
    end

    if baseColor == nil and owner == LABEL_OWNER.ENEMY then
        local hpColor = getEnemyHpColor(entity)
        if hpColor ~= nil then baseColor = hpColor end
    end

    baseColor = baseColor or getConfiguredTextColor(settings)

    local championStyle = getChampionLabelStyle(entity)
    if championStyle ~= nil then
        if championStyle.colorMode == "override" and championStyle.color ~= nil then
            baseColor = withAlpha(championStyle.color, settings.textAlpha)
        elseif championStyle.colorMode == "pulse_tint" and championStyle.color ~= nil then
            local pulse = 0.5 + (math.sin(game:GetFrameCount() * 0.12) * 0.5)
            baseColor = blendColor(baseColor, championStyle.color, pulse * (championStyle.tintStrength or 0.85), settings.textAlpha)
        end
    end

    if config.showHitFlash and hitProgress > 0 then
        return blendColor(baseColor, KColor(1, 0.25, 0.2, 1), hitProgress, settings.textAlpha)
    end

    return withAlpha(baseColor, settings.textAlpha)
end
