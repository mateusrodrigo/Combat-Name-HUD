-- Definicoes dos death effects. Este modulo so calcula valores de animacao;
-- quem desenha o texto final fica em render/death_labels.lua e render/draw_effects.lua.
local DeathEffects = {}

DeathEffects.ID = {
    DISABLED = 1,
    FADE_OUT = 2,
    FLOAT_UP = 3,
    SHRINK = 4,
    EXPLODE = 5,
    SLIDE_LEFT = 6,
    POP = 7,
    DROP_DOWN = 8,
    DISSOLVE = 9,
    SLASH_CUT = 10,
    DROP_SQUASH = 11,
    RING_BURST = 12,
    PHASE_OUT = 13,
    SPLIT_GHOST = 14,
    IMPLODE = 15,
    TOXIC_FADE = 16,
    COIN_SPARK = 17,
    NECRO_FADE = 18,
    COIN_FLIP = 19
}

DeathEffects.MAX_ID = 19

local LABELS = {
    [DeathEffects.ID.DISABLED]    = "Disabled",
    [DeathEffects.ID.FADE_OUT]    = "Fade out",
    [DeathEffects.ID.FLOAT_UP]    = "Float up",
    [DeathEffects.ID.SHRINK]      = "Shrink",
    [DeathEffects.ID.EXPLODE]     = "Explode",
    [DeathEffects.ID.SLIDE_LEFT]  = "Slide left",
    [DeathEffects.ID.POP]         = "Pop",
    [DeathEffects.ID.DROP_DOWN]   = "Drop down",
    [DeathEffects.ID.DISSOLVE]    = "Dissolve",
    [DeathEffects.ID.SLASH_CUT]   = "Slash cut",
    [DeathEffects.ID.DROP_SQUASH] = "Drop + squash",
    [DeathEffects.ID.RING_BURST]  = "Ring burst",
    [DeathEffects.ID.PHASE_OUT]   = "Phase out",
    [DeathEffects.ID.SPLIT_GHOST] = "Split ghost",
    [DeathEffects.ID.IMPLODE]     = "Implode",
    [DeathEffects.ID.TOXIC_FADE]  = "Toxic fade",
    [DeathEffects.ID.COIN_SPARK]  = "Coin spark",
    [DeathEffects.ID.NECRO_FADE]  = "Necro fade",
    [DeathEffects.ID.COIN_FLIP]   = "Coin flip"
}

local function clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

function DeathEffects.getLabel(effectMode)
    return LABELS[effectMode] or LABELS[DeathEffects.ID.DISABLED]
end

function DeathEffects.getValues(label, frame)
    frame = frame or 0

    local duration = math.max(label.duration or 1, 1)
    local elapsed = frame - (label.startFrame or frame)
    local progress = clamp(elapsed / duration, 0, 1)
    local baseScale = label.scale or 1

    local alpha = 1
    local scale = baseScale
    local offsetX = 0
    local offsetY = 0
    local explodeDistance = 0

    if label.effectMode == DeathEffects.ID.DISABLED then
        alpha = 0
    elseif label.effectMode == DeathEffects.ID.FADE_OUT then
        alpha = 1 - progress
    elseif label.effectMode == DeathEffects.ID.FLOAT_UP then
        alpha = 1 - progress
        offsetY = -20 * progress
    elseif label.effectMode == DeathEffects.ID.SHRINK then
        alpha = 1 - progress
        scale = baseScale * (1 - (0.8 * progress))
    elseif label.effectMode == DeathEffects.ID.EXPLODE then
        alpha = 1 - progress
        scale = baseScale * (1 + (0.45 * progress))
        explodeDistance = 28 * progress
    elseif label.effectMode == DeathEffects.ID.SLIDE_LEFT then
        alpha = 1 - progress
        offsetX = -30 * progress
    elseif label.effectMode == DeathEffects.ID.POP then
        alpha = 1 - progress
        scale = baseScale * (1 + (math.sin(progress * math.pi) * 0.55))
        offsetY = -8 * math.sin(progress * math.pi)
    elseif label.effectMode == DeathEffects.ID.DROP_DOWN then
        alpha = 1 - progress
        offsetY = 22 * progress
        scale = baseScale * (1 - (0.35 * progress))
    elseif label.effectMode == DeathEffects.ID.DISSOLVE then
        alpha = 1 - progress
        offsetY = -8 * progress
    elseif label.effectMode == DeathEffects.ID.SLASH_CUT then
        alpha = 1 - progress
        offsetX = 18 * progress
    elseif label.effectMode == DeathEffects.ID.DROP_SQUASH then
        alpha = 1 - progress
        offsetY = 18 * progress
        scale = baseScale * (1 + (math.sin(progress * math.pi) * 0.18))
    elseif label.effectMode == DeathEffects.ID.RING_BURST then
        alpha = 1 - progress
        scale = baseScale * (1 + (math.sin(progress * math.pi) * 0.45))
        explodeDistance = 16 * progress
    elseif label.effectMode == DeathEffects.ID.PHASE_OUT then
        alpha = 1 - progress
        offsetX = math.sin(progress * math.pi * 6) * 4
        scale = baseScale * (1 + (progress * 0.08))
    elseif label.effectMode == DeathEffects.ID.SPLIT_GHOST then
        alpha = 1 - progress
        offsetY = -10 * progress
        explodeDistance = 14 * progress
    elseif label.effectMode == DeathEffects.ID.IMPLODE then
        alpha = 1 - progress
        scale = baseScale * (1 - (0.65 * progress))
    elseif label.effectMode == DeathEffects.ID.TOXIC_FADE then
        alpha = 1 - progress
        offsetY = -12 * progress
        offsetX = math.sin(progress * math.pi * 4) * 5
    elseif label.effectMode == DeathEffects.ID.COIN_SPARK then
        alpha = 1 - progress
        offsetY = -16 * progress
        scale = baseScale * (1 + (math.sin(progress * math.pi * 3) * 0.18))
    elseif label.effectMode == DeathEffects.ID.NECRO_FADE then
        alpha = 1 - progress
        scale = baseScale * (1 + (progress * 0.25))
        offsetY = -6 * progress
    elseif label.effectMode == DeathEffects.ID.COIN_FLIP then
        alpha = 1 - progress
        offsetY = -14 * progress
        scale = baseScale * (1 + (math.sin(progress * math.pi) * 0.12))
    end

    return alpha, scale, offsetX, offsetY, explodeDistance, progress
end

return DeathEffects
