local CNH = require("scripts.core.context")
local _ENV = CNH

-- Desenho especial por letra. Usado por efeitos que precisam controlar cada
-- caractere separadamente em vez de passar pelo drawText comum.

function getRainbowCharacterColor(index, alpha, tintColor, tintAmount)
    local phase = (game:GetFrameCount() * 0.08) + ((index or 1) * 0.42)
    local color = KColor(
        0.62 + (math.sin(phase) * 0.38),
        0.62 + (math.sin(phase + 2.09) * 0.38),
        0.62 + (math.sin(phase + 4.18) * 0.38),
        alpha or 1
    )

    tintAmount = clamp(tintAmount or 0, 0, 1)

    if tintColor ~= nil and tintAmount > 0 then
        return KColor(
            ((color.R or color.Red or 1) * (1 - tintAmount)) + ((tintColor.R or tintColor.Red or 1) * tintAmount),
            ((color.G or color.Green or 1) * (1 - tintAmount)) + ((tintColor.G or tintColor.Green or 1) * tintAmount),
            ((color.B or color.Blue or 1) * (1 - tintAmount)) + ((tintColor.B or tintColor.Blue or 1) * tintAmount),
            alpha or 1
        )
    end

    return color
end

function drawRainbowCharacter(char, x, y, scale, color, index)
    drawText(char, x, y, scale, getRainbowCharacterColor(index, getColorAlpha(color)))
end

function drawRainbowTextFromIndex(text, x, y, scale, color, startIndex, tintColor, tintAmount)
    local cursorX = x
    local alpha = getColorAlpha(color)
    local firstIndex = startIndex or 1

    -- Draw one outline around the full string first. Drawing outlined letters one
    -- by one makes the internal borders overlap and look much thicker.
    drawTextOutline(text, x, y, scale, alpha)

    -- Rainbow uses per-character color cycling for the fill only.
    for index = 1, string.len(text) do
        local char = string.sub(text, index, index)
        local charColor = getRainbowCharacterColor(firstIndex + index - 1, alpha, tintColor, tintAmount)

        drawTextWithoutOutline(char, cursorX, y, scale, charColor)
        cursorX = cursorX + getTextWidth(char, scale)
    end
end

drawRainbowText = function(text, x, y, scale, color, tintColor, tintAmount)
    drawRainbowTextFromIndex(text, x, y, scale, color, 1, tintColor, tintAmount)
end

drawWaveText = function(text, x, y, scale, color, variationSeed, effectFrames, colorForCharacter)
    local frameScale = 60 / math.max(effectFrames or 60, 1)
    local frame = game:GetFrameCount() * frameScale
    local cursorX = x
    local alpha = getColorAlpha(color)
    local phase = seededRange((variationSeed or 0) + 5, 0, math.pi * 2)
    local speed = seededRange((variationSeed or 0) + 7, 0.15, 0.22)
    local spacing = seededRange((variationSeed or 0) + 11, 0.45, 0.72)
    local amplitude = seededRange((variationSeed or 0) + 13, 2.0, 3.2)

    for index = 1, string.len(text) do
        local char = string.sub(text, index, index)
        local charPhase = phase + (index * spacing) + seededRange((variationSeed or 0) + index * 17, -0.18, 0.18)
        local charY = y + (math.sin((frame * speed) + charPhase) * amplitude)

        drawText(char, cursorX, charY, scale, colorForCharacter and colorForCharacter(index, alpha) or color)
        cursorX = cursorX + getTextWidth(char, scale)
    end
end

drawDissolveText = function(text, x, y, scale, color, progress, variationSeed, colorForCharacter)
    local cursorX = x
    local alpha = getColorAlpha(color)

    for index = 1, string.len(text) do
        local char = string.sub(text, index, index)
        local threshold = seededUnit((variationSeed or 0) + index * 37)

        if progress < threshold then
            local driftX = seededRange((variationSeed or 0) + index * 43, -3, 3) * progress
            local driftY = seededRange((variationSeed or 0) + index * 47, -2, 4) * progress
            local charY = y - (progress * seededRange((variationSeed or 0) + index * 53, 5, 11)) + (math.sin(index * 2.1) * progress * 4) + driftY
            drawText(char, cursorX + driftX, charY, scale, colorForCharacter and colorForCharacter(index, alpha) or color)
        end

        cursorX = cursorX + getTextWidth(char, scale)
    end
end

drawSlashCutText = function(text, x, y, scale, color, progress, variationSeed, colorForCharacter)
    local half = math.floor(string.len(text) / 2)
    local leftText = string.sub(text, 1, half)
    local rightText = string.sub(text, half + 1)
    local spread = progress * seededRange((variationSeed or 0) + 13, 14, 24)
    local leftLift = seededRange((variationSeed or 0) + 19, -7, 0) * progress
    local rightDrop = seededRange((variationSeed or 0) + 23, 0, 7) * progress

    if colorForCharacter then
        local cursorX = x - spread
        for index = 1, string.len(leftText) do
            local char = string.sub(leftText, index, index)
            drawText(char, cursorX, y + leftLift, scale, colorForCharacter(index, getColorAlpha(color)))
            cursorX = cursorX + getTextWidth(char, scale)
        end

        cursorX = x + getTextWidth(leftText, scale) + spread
        for index = 1, string.len(rightText) do
            local charIndex = half + index
            local char = string.sub(rightText, index, index)
            drawText(char, cursorX, y + rightDrop, scale, colorForCharacter(charIndex, getColorAlpha(color)))
            cursorX = cursorX + getTextWidth(char, scale)
        end

        return
    end

    drawText(leftText, x - spread, y + leftLift, scale, color)
    drawText(rightText, x + getTextWidth(leftText, scale) + spread, y + rightDrop, scale, color)
end
