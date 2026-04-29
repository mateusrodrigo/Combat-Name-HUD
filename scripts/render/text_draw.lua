local CNH = require("scripts.core.context")
local _ENV = CNH

-- Primitivas de desenho de texto: outline preto opcional, desenho normal,
-- desenho esticado e efeitos por letra usados por death effects.
function drawBlackTextOutline(text, x, y, scaleX, scaleY, alpha)
    if not config.showTextOutline then return end

    local outline = KColor(0, 0, 0, alpha or 1)

    font:DrawStringScaled(text, x + 1, y, scaleX, scaleY, outline, 0, false)
    font:DrawStringScaled(text, x - 1, y, scaleX, scaleY, outline, 0, false)
    font:DrawStringScaled(text, x, y + 1, scaleX, scaleY, outline, 0, false)
    font:DrawStringScaled(text, x, y - 1, scaleX, scaleY, outline, 0, false)
end

function drawText(text, x, y, scale, color)
    local textColor = color or KColor(1, 1, 1, 1)

    drawBlackTextOutline(text, x, y, scale, scale, getColorAlpha(textColor))
    font:DrawStringScaled(text, x, y, scale, scale, textColor, 0, false)
end

function drawTextOutline(text, x, y, scale, alpha)
    drawBlackTextOutline(text, x, y, scale, scale, alpha)
end

function drawTextWithoutOutline(text, x, y, scale, color)
    font:DrawStringScaled(text, x, y, scale, scale, color or KColor(1, 1, 1, 1), 0, false)
end

function drawStretchedText(text, x, y, scaleX, scaleY, color)
    local textColor = color or KColor(1, 1, 1, 1)

    drawBlackTextOutline(text, x, y, scaleX, scaleY, getColorAlpha(textColor))
    font:DrawStringScaled(text, x, y, scaleX, scaleY, textColor, 0, false)
end

function getTextVariationSeed(text)
    local seed = string.len(text or "") * 17

    for index = 1, string.len(text or "") do
        seed = seed + (string.byte(text, index) or 0) * index
    end

    return seed
end

function seededUnit(seed)
    local value = math.sin((seed or 0) * 12.9898) * 43758.5453
    return value - math.floor(value)
end

function seededRange(seed, minimum, maximum)
    return minimum + ((maximum - minimum) * seededUnit(seed))
end

function getLabelVariationSeed(label, salt)
    return ((label and label.variationSeed) or getTextVariationSeed(label and label.text or ""))
        + ((label and label.startFrame) or 0)
        + ((label and label.entitySeed) or 0)
        + (salt or 0)
end

function drawExplodedText(text, x, y, scale, color, explodeDistance, variationSeed, colorForCharacter)
    -- The explode effect separates characters from the center while preserving
    -- the configured font and outline path.
    local length = string.len(text)
    local alpha = getColorAlpha(color)

    if length <= 1 then
        drawText(text, x, y, scale, colorForCharacter and colorForCharacter(1, alpha) or color)
        return
    end

    local cursorX = x
    local centerIndex = (length + 1) / 2

    for index = 1, length do
        local char = string.sub(text, index, index)
        local direction = index < centerIndex and -1 or 1
        local distanceFactor = math.abs(index - centerIndex) / centerIndex
        local randomDistance = seededRange((variationSeed or 0) + index * 31, 0.75, 1.28)
        local randomLift = seededRange((variationSeed or 0) + index * 47, -0.45, 0.45)
        local charX = cursorX + (direction * explodeDistance * distanceFactor * randomDistance)
        local charY = y + ((math.sin(index * 1.7) + randomLift) * explodeDistance * 0.25)

        drawText(char, charX, charY, scale, colorForCharacter and colorForCharacter(index, alpha) or color)
        cursorX = cursorX + getTextWidth(char, scale)
    end
end

function drawCoinFlipText(text, x, y, scale, color, progress, variationSeed, colorForCharacter)
    local cursorX = x
    local alpha = getColorAlpha(color)

    for index = 1, string.len(text) do
        local char = string.sub(text, index, index)
        local charWidth = getTextWidth(char, scale)
        local delay = seededRange((variationSeed or 0) + index * 19, 0, 0.28)
        local localProgress = clamp((progress - delay) / math.max(1 - delay, 0.01), 0, 1)

        if localProgress < 1 then
            local flipPhase = (localProgress * math.pi * 7) + seededRange((variationSeed or 0) + index * 23, 0, math.pi)
            local flipWidth = 0.18 + (math.abs(math.cos(flipPhase)) * 0.82)
            local lift = -18 * localProgress * seededRange((variationSeed or 0) + index * 29, 0.7, 1.25)
            local drift = seededRange((variationSeed or 0) + index * 41, -7, 7) * localProgress
            local coinAlpha = alpha * (1 - localProgress)
            local coinColor = colorForCharacter and colorForCharacter(index, coinAlpha) or copyColorWithAlpha(color, coinAlpha)
            local scaleX = scale * flipWidth
            local scaledWidth = font:GetStringWidth(char) * scaleX
            local charX = cursorX + ((charWidth - scaledWidth) / 2) + drift

            drawStretchedText(char, charX, y + lift, scaleX, scale, coinColor)
        end

        cursorX = cursorX + charWidth
    end
end
