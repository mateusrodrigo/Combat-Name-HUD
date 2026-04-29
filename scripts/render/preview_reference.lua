local CNH = require("scripts.core.context")
local _ENV = CNH

-- Referencia visual do player nos previews above/below do MCM.
function drawPreviewPlayerReference()
    if game:GetNumPlayers() <= 0 then return end

    local player = getPreviewPlayer()
    if player == nil then return end

    local center = getScreenCenter()
    local positionOffset = player.PositionOffset or Vector.Zero
    local spriteOffset = player.SpriteOffset or Vector.Zero
    local currentScreenPos = Isaac.WorldToScreen(player.Position + positionOffset) + spriteOffset
    local renderOffset = center - currentScreenPos

    local rendered = pcall(function()
        player:Render(renderOffset)
    end)

    if rendered then return end

    local sprite = player:GetSprite()
    if sprite == nil then return end

    sprite:Render(center, Vector.Zero, Vector.Zero)
end

function drawPreviewEntityReference()
    drawPreviewPlayerReference()
end

function shouldDrawPreviewReference(positionMode)
    -- The player reference is only useful for above/below modes. Fixed mode is
    -- anchored to the top HUD position and does not need a character marker.
    return positionMode == POSITION_MODE.ABOVE_ENTITY
        or positionMode == POSITION_MODE.BELOW_ENTITY
end
