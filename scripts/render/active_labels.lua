local CNH = require("scripts.core.context")
local _ENV = CNH

-- Labels ativos/renderizaveis. Normaliza entidade/nome/config em um objeto de
-- render e aplica o caminho comum de desenho para boss, enemy e previews.
function createRenderableLabel(owner, entity, name, shakeUntilFrame, isPreview, hitUntilFrame, introStartFrame)
    -- Renderable labels are normalized objects. All later drawing code only needs
    -- text, position, scale, owner, and color.
    local settings = getOwnerSettings(owner)
    local championDescriptorStyle = getChampionStyle(entity)
    local championStyle = config.showChampionStyling and championDescriptorStyle or nil
    local text = formatLabelText(owner, name, championDescriptorStyle)
    local activeEffectMode = settings.activeEffectMode
    local textColorMode = settings.textColorMode
    local variationSeed = getTextVariationSeed(text) + (entity and entity.InitSeed or 0)

    if championStyle ~= nil then
        activeEffectMode = championStyle.activeEffect or activeEffectMode
        if championStyle.rainbow then
            textColorMode = TEXT_COLOR_MODE.RAINBOW
        elseif championStyle.colorMode ~= "preserve" then
            textColorMode = TEXT_COLOR_MODE.DEFAULT
        end
    end

    local scale, activeOffsetX, activeOffsetY = applyActiveEffect(settings.textScale, activeEffectMode, championStyle, variationSeed, settings.activeEffectFrames)
    local shakeX, shakeY = getShakeOffset(settings.shakeOnDamage, shakeUntilFrame or 0, settings.shakeStrength)
    local hitProgress = getHitProgress(hitUntilFrame)
    local introAlpha, introOffsetX, introOffsetY, introScale = getBossIntroValues(owner, introStartFrame, variationSeed)

    if config.showHitPunch and hitProgress > 0 then
        scale = scale * (1 + (0.25 * hitProgress))
    end

    scale = scale * (introScale or 1)

    local x, y = getLabelPositionFromSettings(
        entity,
        text,
        settings,
        scale,
        isPreview,
        shakeX + activeOffsetX + introOffsetX,
        shakeY + activeOffsetY + introOffsetY
    )

    if x == nil or y == nil then return nil end

    local baseColor = getContextualLabelColor(owner, entity, hitProgress, settings, isPreview) or KColor(1, 1, 1, 1)
    local labelColor = KColor(
        baseColor.R or baseColor.Red or 1,
        baseColor.G or baseColor.Green or 1,
        baseColor.B or baseColor.Blue or 1,
        math.min(baseColor.A or baseColor.Alpha or 1, introAlpha)
    )

    local label = {
        owner = owner,
        entity = entity,
        entitySeed = entity and entity.InitSeed or nil,
        name = name,
        text = text,
        x = x,
        y = y,
        scale = scale,
        variationSeed = variationSeed,
        activeEffectMode = activeEffectMode,
        activeEffectFrames = settings.activeEffectFrames,
        deathEffectMode = championStyle and championStyle.deathEffect or nil,
        textColorMode = textColorMode,
        color = labelColor,
        rainbowTintColor = textColorMode == TEXT_COLOR_MODE.RAINBOW and KColor(1, 0.25, 0.2, 1) or nil,
        rainbowTintProgress = (textColorMode == TEXT_COLOR_MODE.RAINBOW and config.showHitFlash and hitProgress > 0) and hitProgress or 0,
        championScaleApplied = championStyle ~= nil,
        championStyleApplied = championStyle ~= nil
    }

    attachWorldAnchorToLabel(label, entity, isPreview, settings)

    return label
end

function drawRenderableLabel(label, color)
    -- Thin wrapper so preview code can override color without duplicating label
    -- rendering rules.
    local drawColor = color or label.color

    if label.activeEffectMode == ACTIVE_LABEL_EFFECT.LETTER_WAVE then
        local colorForCharacter = nil

        if color == nil and label.textColorMode == TEXT_COLOR_MODE.RAINBOW then
            colorForCharacter = function(index, alpha)
                return getRainbowCharacterColor(index, alpha or getColorAlpha(drawColor), label.rainbowTintColor, label.rainbowTintProgress)
            end
        end

        drawWaveText(label.text, label.x, label.y, label.scale, drawColor, label.variationSeed, label.activeEffectFrames, colorForCharacter)
        return
    end

    if color == nil and label.textColorMode == TEXT_COLOR_MODE.RAINBOW then
        drawRainbowText(label.text, label.x, label.y, label.scale, drawColor, label.rainbowTintColor, label.rainbowTintProgress)
        return
    end

    drawText(label.text, label.x, label.y, label.scale, drawColor)
end

function createRenderableLabelAtWorldPosition(owner, name, worldPosition, shakeUntilFrame, championDescriptorStyle)
    if worldPosition == nil then return nil end

    local settings = getOwnerSettings(owner)
    local text = formatLabelText(owner, name, championDescriptorStyle)
    local variationSeed = getTextVariationSeed(text)
    local scale, activeOffsetX, activeOffsetY = applyActiveEffect(settings.textScale, settings.activeEffectMode, nil, variationSeed, settings.activeEffectFrames)
    local shakeX, shakeY = getShakeOffset(settings.shakeOnDamage, shakeUntilFrame or 0, settings.shakeStrength)
    local extraX = activeOffsetX + shakeX
    local extraY = activeOffsetY + shakeY
    local x, y

    if settings.positionMode == POSITION_MODE.FIXED_POSITION then
        x, y = getCenteredTextPosition(text, settings.fixedXOffset + extraX, settings.fixedYOffset + extraY, scale)
    else
        local screenPos = Isaac.WorldToScreen(worldPosition)
        local textWidth = getTextWidth(text, scale)
        local xOffset = extraX
        local yOffset = extraY

        if settings.positionMode == POSITION_MODE.ABOVE_ENTITY then
            xOffset = xOffset + settings.aboveXOffset
            yOffset = yOffset - math.abs(settings.aboveYOffset)
        else
            xOffset = xOffset + settings.belowXOffset
            yOffset = yOffset + math.abs(settings.belowYOffset)
        end

        x = screenPos.X - (textWidth / 2) + xOffset
        y = screenPos.Y + yOffset
    end

    local label = {
        owner = owner,
        entity = nil,
        entitySeed = nil,
        name = name,
        text = text,
        x = x,
        y = y,
        scale = scale,
        variationSeed = variationSeed,
        activeEffectMode = settings.activeEffectMode,
        activeEffectFrames = settings.activeEffectFrames,
        textColorMode = settings.textColorMode,
        color = getContextualLabelColor(owner, nil, 0, settings),
        rainbowTintColor = settings.textColorMode == TEXT_COLOR_MODE.RAINBOW and KColor(1, 0.25, 0.2, 1) or nil,
        rainbowTintProgress = 0,
        championStyleApplied = false
    }

    if settings.positionMode ~= POSITION_MODE.FIXED_POSITION then
        local screenPos = Isaac.WorldToScreen(worldPosition)
        label.worldPosition = worldPosition
        label.screenOffsetX = x - screenPos.X
        label.screenOffsetY = y - screenPos.Y
    end

    return label
end
