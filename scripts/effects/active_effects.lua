-- Definicoes dos efeitos ativos. Recebe escala/base/frame/seed e devolve pequenas
-- variacoes visuais usadas enquanto o label ainda esta ativo.
local ActiveEffects = {}

ActiveEffects.ID = {
    DISABLED = 1,
    PULSE = 2,
    BOB = 3,
    PULSE_BOB = 4,
    WIGGLE = 5,
    NERVOUS = 6,
    DRIFT = 7,
    BREATHING = 8,
    WAVE = 9,
    FLICKER = 10,
    MAGNET = 11,
    GLITCH = 12,
    HEAVY = 13,
    ORBIT = 14,
    TOXIC = 15,
    LETTER_WAVE = 16
}

ActiveEffects.MAX_ID = 16

local LABELS = {
    [ActiveEffects.ID.DISABLED]  = "Disabled",
    [ActiveEffects.ID.PULSE]     = "Pulse",
    [ActiveEffects.ID.BOB]       = "Bob",
    [ActiveEffects.ID.PULSE_BOB] = "Pulse + Bob",
    [ActiveEffects.ID.WIGGLE]    = "Wiggle",
    [ActiveEffects.ID.NERVOUS]   = "Nervous",
    [ActiveEffects.ID.DRIFT]     = "Drift",
    [ActiveEffects.ID.BREATHING] = "Breathing",
    [ActiveEffects.ID.WAVE]      = "Wave",
    [ActiveEffects.ID.FLICKER]   = "Flicker",
    [ActiveEffects.ID.MAGNET]    = "Magnet pull",
    [ActiveEffects.ID.GLITCH]    = "Glitch",
    [ActiveEffects.ID.HEAVY]     = "Heavy",
    [ActiveEffects.ID.ORBIT]     = "Orbit",
    [ActiveEffects.ID.TOXIC]     = "Toxic drift",
    [ActiveEffects.ID.LETTER_WAVE] = "Letter wave"
}

function ActiveEffects.getLabel(effectMode)
    return LABELS[effectMode] or LABELS[ActiveEffects.ID.DISABLED]
end

local function seededUnit(seed)
    local value = math.sin((seed or 0) * 12.9898) * 43758.5453
    return value - math.floor(value)
end

local function seededRange(seed, minimum, maximum)
    return minimum + ((maximum - minimum) * seededUnit(seed))
end

function ActiveEffects.apply(baseScale, effectMode, championStyle, frame, variationSeed, effectFrames)
    frame = frame or 0
    variationSeed = variationSeed or 0
    effectFrames = math.max(effectFrames or 60, 1)
    frame = frame * (60 / effectFrames)

    if championStyle ~= nil and championStyle.scaleMultiplier ~= nil then
        baseScale = baseScale * championStyle.scaleMultiplier
    end

    local scale = baseScale
    local offsetX = 0
    local offsetY = 0
    local phase = seededRange(variationSeed + 1, 0, math.pi * 2)
    local speedFactor = seededRange(variationSeed + 2, 0.86, 1.14)
    local amountFactor = seededRange(variationSeed + 3, 0.82, 1.22)

    if effectMode == ActiveEffects.ID.PULSE or effectMode == ActiveEffects.ID.PULSE_BOB then
        scale = baseScale * (1 + (math.sin((frame * 0.12 * speedFactor) + phase) * 0.06 * amountFactor))
    end

    if effectMode == ActiveEffects.ID.BOB or effectMode == ActiveEffects.ID.PULSE_BOB then
        offsetY = math.sin((frame * 0.12 * speedFactor) + phase) * 1.5 * amountFactor
    end

    if effectMode == ActiveEffects.ID.WIGGLE then
        offsetX = math.sin((frame * 0.24 * speedFactor) + phase) * 2 * amountFactor
    elseif effectMode == ActiveEffects.ID.NERVOUS then
        offsetX = math.sin((frame * 1.7 * speedFactor) + phase) * 1.3 * amountFactor
        offsetY = math.cos((frame * 1.35 * speedFactor) + phase) * 1.1 * seededRange(variationSeed + 4, 0.85, 1.2)
        scale = baseScale * (1 + (math.sin((frame * 0.35 * speedFactor) + phase) * 0.025 * amountFactor))
    elseif effectMode == ActiveEffects.ID.DRIFT then
        offsetX = math.cos((frame * 0.07 * speedFactor) + phase) * 1.6 * amountFactor
        offsetY = math.sin((frame * 0.09 * seededRange(variationSeed + 5, 0.82, 1.18)) + phase) * 3 * seededRange(variationSeed + 6, 0.8, 1.25)
    elseif effectMode == ActiveEffects.ID.BREATHING then
        scale = baseScale * (1 + (math.sin((frame * 0.06 * speedFactor) + phase) * 0.035 * amountFactor))
    elseif effectMode == ActiveEffects.ID.WAVE then
        offsetY = math.sin((frame * 0.08 * speedFactor) + phase) * 1.2 * amountFactor
        offsetX = math.cos((frame * 0.055 * speedFactor) + phase) * 0.6 * seededRange(variationSeed + 7, 0.5, 1.2)
    elseif effectMode == ActiveEffects.ID.FLICKER then
        local flickerWindow = math.floor(seededRange(variationSeed + 8, 14, 23))
        scale = baseScale * (0.98 + (((frame + math.floor(phase * 10)) % flickerWindow) < (flickerWindow * 0.58) and 0.03 or -0.015))
        offsetX = math.sin((frame * 0.42 * speedFactor) + phase) * 0.7 * amountFactor
    elseif effectMode == ActiveEffects.ID.MAGNET then
        scale = baseScale * (1 + (math.sin((frame * 0.1 * speedFactor) + phase) * 0.025 * amountFactor))
        offsetX = math.sin((frame * 0.16 * speedFactor) + phase) * 2.4 * amountFactor
        offsetY = math.cos((frame * 0.16 * speedFactor) + phase) * 0.9 * seededRange(variationSeed + 9, 0.75, 1.3)
    elseif effectMode == ActiveEffects.ID.GLITCH then
        offsetX = (((frame + math.floor(variationSeed)) % 8) < 4) and (2 * amountFactor) or (-2 * amountFactor)
        offsetY = (((frame + math.floor(variationSeed * 0.5)) % 6) < 3) and seededRange(variationSeed + 10, 0.6, 1.4) or -seededRange(variationSeed + 11, 0.6, 1.4)
    elseif effectMode == ActiveEffects.ID.HEAVY then
        scale = baseScale * (1.03 + (math.sin((frame * 0.045 * speedFactor) + phase) * 0.025 * amountFactor))
        offsetY = math.abs(math.sin((frame * 0.055 * speedFactor) + phase)) * 1.4 * amountFactor
    elseif effectMode == ActiveEffects.ID.ORBIT then
        offsetX = math.cos((frame * 0.11 * speedFactor) + phase) * 2.2 * amountFactor
        offsetY = math.sin((frame * 0.11 * speedFactor) + phase) * 1.6 * seededRange(variationSeed + 12, 0.78, 1.28)
    elseif effectMode == ActiveEffects.ID.TOXIC then
        offsetX = math.sin((frame * 0.13 * speedFactor) + phase) * 1.2 * amountFactor
        offsetY = math.sin((frame * 0.19 * seededRange(variationSeed + 13, 0.8, 1.2)) + phase) * 2.1 * seededRange(variationSeed + 14, 0.75, 1.3)
        scale = baseScale * (1 + (math.sin((frame * 0.09 * speedFactor) + phase) * 0.02 * amountFactor))
    end

    if championStyle ~= nil and championStyle.scalePulseAmount ~= nil then
        local speed = (championStyle.scalePulseSpeed or 0.1) * speedFactor
        scale = scale * (1 + (math.sin((frame * speed) + phase) * championStyle.scalePulseAmount * amountFactor))
    end

    return scale, offsetX, offsetY
end

return ActiveEffects
