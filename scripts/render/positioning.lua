local CNH = require("scripts.core.context")
local _ENV = CNH

-- Helpers de posicao. Convertem fixed HUD, world position e anchors de preview
-- para coordenadas de tela, alem de caixas simples para evitar sobreposicao.

-- =========================================================
-- POSICIONAMENTO
-- =========================================================

function getScreenCenter()
    return Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() / 2)
end

function getPreviewPlayer()
    -- Prefer the first living player so the centered preview mirrors the current
    -- character/costume state. If every pcall fails, fall back to player 0.
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player ~= nil then
            local ok, isDead = pcall(function()
                return player:IsDead()
            end)

            if not ok or not isDead then
                return player
            end
        end
    end

    if game:GetNumPlayers() > 0 then
        return Isaac.GetPlayer(0)
    end

    return nil
end

function getPreviewAnchorPosition()
    -- The MCM preview is a UI preview, not a room overlay. It should always use
    -- the screen center as its reference point.
    return getScreenCenter()
end

function getTextWidth(text, scale)
    return font:GetStringWidth(text) * scale
end

function getTextHeight(scale)
    return 12 * scale
end

function getCenteredTextPosition(text, xOffset, yOffset, scale)
    -- Fixed-position labels are anchored to the top-center combat HUD area.
    local center = getScreenCenter()
    local textWidth = getTextWidth(text, scale)

    return center.X - (textWidth / 2) + xOffset, 40 + yOffset
end

function getWorldTextPosition(entity, text, xOffset, yOffset, scale)
    -- Entity-position labels follow the entity's world position converted to
    -- screen space.
    if entity == nil or not safeExists(entity) then return nil, nil end

    local screenPos = Isaac.WorldToScreen(entity.Position)
    local textWidth = getTextWidth(text, scale)

    return screenPos.X - (textWidth / 2) + xOffset, screenPos.Y + yOffset
end

function getEntityWorldPosition(entity)
    if entity == nil or not safeExists(entity) then return nil end

    local ok, position = pcall(function()
        return entity.Position
    end)

    if ok and position ~= nil then
        return Vector(position.X, position.Y)
    end

    return nil
end

function attachWorldAnchorToLabel(label, entity, isPreview, settings)
    -- Screen coordinates are not enough for death effects in scrolling rooms:
    -- they would stay glued to the camera. Entity-position labels also store the
    -- last world position and their screen offset from that world anchor.
    if label == nil or isPreview then return end
    if settings.positionMode == POSITION_MODE.FIXED_POSITION then return end

    local worldPosition = getEntityWorldPosition(entity)
    if worldPosition == nil then return end

    local screenPos = Isaac.WorldToScreen(worldPosition)
    label.worldPosition = worldPosition
    label.screenOffsetX = label.x - screenPos.X
    label.screenOffsetY = label.y - screenPos.Y
end

function getPreviewEntityTextPosition(text, xOffset, yOffset, scale)
    -- Above/below preview labels use the centered player reference instead of an
    -- actual enemy or boss entity.
    local center = getPreviewAnchorPosition()
    local textWidth = getTextWidth(text, scale)

    return center.X - (textWidth / 2) + xOffset, center.Y + yOffset
end

function getLabelPositionFromSettings(entity, text, settings, scale, isPreview, extraX, extraY)
    -- One position function handles boss, enemy, real entities, and MCM previews.
    -- extraX/extraY carry active-effect and shake offsets.
    local fixedX = settings.fixedXOffset + extraX
    local fixedY = settings.fixedYOffset + extraY
    local aboveX = settings.aboveXOffset + extraX
    local aboveY = settings.aboveYOffset + extraY
    local belowX = settings.belowXOffset + extraX
    local belowY = settings.belowYOffset + extraY

    if settings.positionMode == POSITION_MODE.FIXED_POSITION then
        return getCenteredTextPosition(text, fixedX, fixedY, scale)
    end

    if settings.positionMode == POSITION_MODE.ABOVE_ENTITY then
        if isPreview then
            return getPreviewEntityTextPosition(text, aboveX, -math.abs(aboveY), scale)
        end

        return getWorldTextPosition(entity, text, aboveX, -math.abs(aboveY), scale)
    end

    if settings.positionMode == POSITION_MODE.BELOW_ENTITY then
        if isPreview then
            return getPreviewEntityTextPosition(text, belowX, math.abs(belowY), scale)
        end

        return getWorldTextPosition(entity, text, belowX, math.abs(belowY), scale)
    end

    return nil, nil
end

function getTextBox(text, x, y, scale)
    local width = getTextWidth(text, scale)
    local height = getTextHeight(scale)

    return {
        left = x,
        right = x + width,
        top = y,
        bottom = y + height,
        height = height
    }
end

function boxesOverlap(a, b)
    return a.left < b.right
        and a.right > b.left
        and a.top < b.bottom
        and a.bottom > b.top
end

function pushBoxAwayFromBoxes(text, x, y, scale, boxes)
    if boxes == nil or #boxes == 0 then
        return x, y
    end

    -- Multi-boss labels and enemy labels can overlap. This gently pushes the new
    -- label away from boxes already drawn this frame.
    local height = getTextHeight(scale)
    local box = getTextBox(text, x, y, scale)

    for _, otherBox in ipairs(boxes) do
        if boxesOverlap(box, otherBox) then
            local screenCenterY = Isaac.GetScreenHeight() / 2

            if otherBox.top < screenCenterY then
                y = otherBox.bottom + config.bossLineSpacing
            else
                y = otherBox.top - height - config.bossLineSpacing
            end

            y = clamp(y, 5, Isaac.GetScreenHeight() - height - 5)
            box = getTextBox(text, x, y, scale)
        end
    end

    return x, y
end

