-- Definicoes dos boss intro effects. Este modulo calcula alpha, offset e escala
-- usados apenas enquanto um label de boss acaba de aparecer.
local IntroEffects = {}

IntroEffects.ID = {
    DISABLED = 1,
    FADE_SLIDE = 2,
    FADE_IN = 3,
    POP_IN = 4,
    DROP_IN = 5,
    RISE_IN = 6,
    GLITCH_IN = 7,
    STOMP_IN = 8
}

IntroEffects.MAX_ID = 8

local LABELS = {
    [IntroEffects.ID.DISABLED]   = "Disabled",
    [IntroEffects.ID.FADE_SLIDE] = "Fade + slide",
    [IntroEffects.ID.FADE_IN]    = "Fade in",
    [IntroEffects.ID.POP_IN]     = "Pop in",
    [IntroEffects.ID.DROP_IN]    = "Drop in",
    [IntroEffects.ID.RISE_IN]    = "Rise in",
    [IntroEffects.ID.GLITCH_IN]  = "Glitch in",
    [IntroEffects.ID.STOMP_IN]   = "Stomp in"
}

local function clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function easeOutCubic(progress)
    local inverse = 1 - progress
    return 1 - (inverse * inverse * inverse)
end

local function easeOutBack(progress)
    local c1 = 1.70158
    local c3 = c1 + 1

    return 1 + (c3 * ((progress - 1) ^ 3)) + (c1 * ((progress - 1) ^ 2))
end

function IntroEffects.getLabel(effectMode)
    return LABELS[effectMode] or LABELS[IntroEffects.ID.DISABLED]
end

function IntroEffects.getValues(effectMode, elapsed, duration, variationSeed)
    if effectMode == IntroEffects.ID.DISABLED then
        return 1, 0, 0, 1
    end

    duration = math.max(duration or 1, 1)
    elapsed = elapsed or duration

    if elapsed < 0 or elapsed >= duration then
        return 1, 0, 0, 1
    end

    local progress = clamp(elapsed / duration, 0, 1)
    local eased = easeOutCubic(progress)
    local remaining = 1 - eased
    local alpha = progress
    local offsetX = 0
    local offsetY = 0
    local scale = 1

    if effectMode == IntroEffects.ID.FADE_SLIDE then
        offsetX = -32 * remaining
    elseif effectMode == IntroEffects.ID.FADE_IN then
        -- Alpha already does the full effect.
    elseif effectMode == IntroEffects.ID.POP_IN then
        scale = 0.55 + (0.45 * easeOutBack(progress))
    elseif effectMode == IntroEffects.ID.DROP_IN then
        offsetY = -28 * remaining
        scale = 1 + (math.sin(progress * math.pi) * 0.08)
    elseif effectMode == IntroEffects.ID.RISE_IN then
        offsetY = 20 * remaining
    elseif effectMode == IntroEffects.ID.GLITCH_IN then
        local seed = variationSeed or 0
        local jitter = 1 - progress

        offsetX = math.sin((elapsed + seed) * 1.7) * 7 * jitter
        offsetY = math.cos((elapsed + seed) * 1.35) * 3 * jitter
        scale = 1 + (math.sin((elapsed + seed) * 0.9) * 0.06 * jitter)
    elseif effectMode == IntroEffects.ID.STOMP_IN then
        offsetY = -18 * remaining
        scale = 1 + (0.35 * (1 - progress)) - (math.sin(progress * math.pi) * 0.12)
    end

    return alpha, offsetX, offsetY, scale
end

return IntroEffects
