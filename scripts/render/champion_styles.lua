local CNH = require("scripts.core.context")
local _ENV = CNH

-- Logica visual de champions: identifica champion, escolhe estilo tematico e
-- aplica escala/cor/efeito ativo/death effect ao label renderizavel.
getChampionColorIndex = function(entity)
    if entity == nil then return nil end

    local npc = entity
    local okNpc, convertedNpc = pcall(function()
        return entity:ToNPC()
    end)

    if okNpc and convertedNpc ~= nil then
        npc = convertedNpc
    end

    -- REPENTOGON/Repentance documents GetChampionColorIdx as returning -1 for
    -- non-champions. That makes it the most reliable source, including red
    -- champions whose valid ID is 0.
    local okColorIndex, colorIndex = pcall(function()
        return npc:GetChampionColorIdx()
    end)

    if okColorIndex and colorIndex ~= nil and colorIndex >= 0 then
        return colorIndex
    end

    local okIsChampion, isChampion = pcall(function()
        return npc:IsChampion()
    end)

    if okIsChampion and isChampion then
        return 0
    end

    okIsChampion, isChampion = pcall(function()
        return entity:IsChampion()
    end)

    if okIsChampion and isChampion then
        return 0
    end

    return nil
end

function getChampionStyle(entity)
    local championId = getChampionColorIndex(entity)
    if championId == nil then return nil end

    return CHAMPION_LABEL_STYLE[championId] or CHAMPION_LABEL_STYLE[0]
end

function getChampionLabelStyle(entity)
    if not config.showChampionStyling then return nil end
    return getChampionStyle(entity)
end

function applyChampionStyleToLabel(label, championStyle)
    if label == nil or championStyle == nil then return end
    if label.championStyleApplied then return end

    local settings = getOwnerSettings(label.owner)

    label.activeEffectMode = championStyle.activeEffect or label.activeEffectMode
    label.deathEffectMode = championStyle.deathEffect or label.deathEffectMode

    if championStyle.scaleMultiplier ~= nil and not label.championScaleApplied then
        label.scale = label.scale * championStyle.scaleMultiplier
        label.championScaleApplied = true
    end

    if championStyle.colorMode == "override" and championStyle.color ~= nil then
        label.color = withAlpha(championStyle.color, settings.textAlpha)
    elseif championStyle.colorMode == "pulse_tint" and championStyle.color ~= nil then
        local pulse = 0.5 + (math.sin(game:GetFrameCount() * 0.12) * 0.5)
        label.color = blendColor(label.color, championStyle.color, pulse * (championStyle.tintStrength or 0.85), settings.textAlpha)
    end

    if championStyle.rainbow then
        label.textColorMode = TEXT_COLOR_MODE.RAINBOW
        label.rainbowTintColor = label.rainbowTintColor or KColor(1, 0.25, 0.2, 1)
        label.rainbowTintProgress = label.rainbowTintProgress or 0
    elseif championStyle.colorMode ~= "preserve" then
        label.textColorMode = TEXT_COLOR_MODE.DEFAULT
        label.rainbowTintProgress = 0
    end

    label.championStyleApplied = true
end
