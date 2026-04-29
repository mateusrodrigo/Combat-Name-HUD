local CNH = require("scripts.core.context")
local _ENV = CNH

-- Vitrine exclusiva da aba Info. Ela nao usa entidades reais nem altera config:
-- apenas desenha uma trilha fixed com nomes falsos alternando active/death effects.

local SHOWCASE_SLOT_COUNT = 4
local SHOWCASE_ACTIVE_FRAMES = 78
local SHOWCASE_DEATH_FRAMES = 52
local SHOWCASE_PAUSE_FRAMES = 16
local SHOWCASE_CYCLE_FRAMES = SHOWCASE_ACTIVE_FRAMES + SHOWCASE_DEATH_FRAMES + SHOWCASE_PAUSE_FRAMES
local SHOWCASE_SLOT_DELAY = 34
local SHOWCASE_LINE_SPACING = 18

local SHOWCASE_ACTIVE_EFFECTS = {
    ACTIVE_LABEL_EFFECT.PULSE,
    ACTIVE_LABEL_EFFECT.BOB,
    ACTIVE_LABEL_EFFECT.PULSE_BOB,
    ACTIVE_LABEL_EFFECT.WIGGLE,
    ACTIVE_LABEL_EFFECT.NERVOUS,
    ACTIVE_LABEL_EFFECT.DRIFT,
    ACTIVE_LABEL_EFFECT.BREATHING,
    ACTIVE_LABEL_EFFECT.WAVE,
    ACTIVE_LABEL_EFFECT.FLICKER,
    ACTIVE_LABEL_EFFECT.MAGNET,
    ACTIVE_LABEL_EFFECT.GLITCH,
    ACTIVE_LABEL_EFFECT.ORBIT,
    ACTIVE_LABEL_EFFECT.TOXIC,
    ACTIVE_LABEL_EFFECT.LETTER_WAVE
}

local SHOWCASE_DEATH_EFFECTS = {
    DEATH_LABEL_EFFECT.FADE_OUT,
    DEATH_LABEL_EFFECT.FLOAT_UP,
    DEATH_LABEL_EFFECT.SHRINK,
    DEATH_LABEL_EFFECT.EXPLODE,
    DEATH_LABEL_EFFECT.SLIDE_LEFT,
    DEATH_LABEL_EFFECT.POP,
    DEATH_LABEL_EFFECT.DROP_DOWN,
    DEATH_LABEL_EFFECT.DISSOLVE,
    DEATH_LABEL_EFFECT.SLASH_CUT,
    DEATH_LABEL_EFFECT.RING_BURST,
    DEATH_LABEL_EFFECT.PHASE_OUT,
    DEATH_LABEL_EFFECT.SPLIT_GHOST,
    DEATH_LABEL_EFFECT.IMPLODE,
    DEATH_LABEL_EFFECT.COIN_SPARK,
    DEATH_LABEL_EFFECT.NECRO_FADE,
    DEATH_LABEL_EFFECT.COIN_FLIP
}

local SHOWCASE_TEXT_COLOR_MODES = {
    TEXT_COLOR_MODE.WHITE,
    TEXT_COLOR_MODE.RED,
    TEXT_COLOR_MODE.GREEN,
    TEXT_COLOR_MODE.BLUE,
    TEXT_COLOR_MODE.YELLOW,
    TEXT_COLOR_MODE.CYAN,
    TEXT_COLOR_MODE.MAGENTA,
    TEXT_COLOR_MODE.RAINBOW
}

local function chooseRandom(list)
    return list[math.random(#list)]
end

local function chooseShowcaseOwner(slotIndex, cycleIndex)
    if ((slotIndex + cycleIndex) % 2) == 0 then
        return LABEL_OWNER.BOSS
    end

    return LABEL_OWNER.ENEMY
end

local function chooseShowcaseName(owner, currentName)
    PrepareCombatNameHUDPreviewNamePoolsForRandomize()

    if owner == LABEL_OWNER.BOSS then
        return getRandomPreviewName(state.bossPreviewNames, "Mom's Heart", currentName)
    end

    return getRandomPreviewName(state.enemyPreviewNames, "Fly", currentName)
end

local function createInfoShowcaseSlot(slotIndex, cycleIndex)
    local previous = state.infoShowcaseSlots[slotIndex]
    local owner = chooseShowcaseOwner(slotIndex, cycleIndex)
    local previousName = previous and previous.name or nil

    return {
        cycleIndex = cycleIndex,
        owner = owner,
        name = chooseShowcaseName(owner, previousName),
        scale = owner == LABEL_OWNER.BOSS and 1.0 or 0.84,
        textColorMode = chooseRandom(SHOWCASE_TEXT_COLOR_MODES),
        activeEffectMode = chooseRandom(SHOWCASE_ACTIVE_EFFECTS),
        activeEffectFrames = math.random(36, 92),
        deathEffectMode = chooseRandom(SHOWCASE_DEATH_EFFECTS)
    }
end

local function ensureInfoShowcaseSlot(slotIndex, cycleIndex)
    state.infoShowcaseSlots = state.infoShowcaseSlots or {}

    local slot = state.infoShowcaseSlots[slotIndex]

    if slot == nil or slot.cycleIndex ~= cycleIndex then
        slot = createInfoShowcaseSlot(slotIndex, cycleIndex)
        state.infoShowcaseSlots[slotIndex] = slot
    end

    return slot
end

local function getInfoShowcaseBaseY(slotIndex)
    local center = getScreenCenter()
    local showcaseHeight = ((SHOWCASE_SLOT_COUNT - 1) * SHOWCASE_LINE_SPACING) + getTextHeight(1)
    local firstY = center.Y - (showcaseHeight / 2)

    return firstY + ((slotIndex - 1) * SHOWCASE_LINE_SPACING)
end

local function createInfoShowcaseLabel(slot, slotIndex, useActiveMotion)
    local text = slot.name
    local variationSeed = getTextVariationSeed(text) + (slotIndex * 997) + ((slot.cycleIndex or 0) * 131)
    local scale = slot.scale
    local offsetX = 0
    local offsetY = 0

    if useActiveMotion then
        scale, offsetX, offsetY = applyActiveEffect(
            slot.scale,
            slot.activeEffectMode,
            nil,
            variationSeed,
            slot.activeEffectFrames
        )
    end

    local settings = {
        textColorMode = slot.textColorMode,
        textAlpha = 100
    }
    local color = getConfiguredTextColor(settings)
    local x = (Isaac.GetScreenWidth() / 2) - (getTextWidth(text, scale) / 2) + offsetX
    local y = getInfoShowcaseBaseY(slotIndex) + offsetY

    return {
        owner = slot.owner,
        entity = nil,
        entitySeed = nil,
        name = text,
        text = text,
        x = x,
        y = y,
        scale = scale,
        variationSeed = variationSeed,
        activeEffectMode = slot.activeEffectMode,
        activeEffectFrames = slot.activeEffectFrames,
        textColorMode = slot.textColorMode,
        color = color,
        rainbowTintColor = slot.textColorMode == TEXT_COLOR_MODE.RAINBOW and KColor(1, 0.25, 0.2, 1) or nil,
        rainbowTintProgress = 0,
        championStyleApplied = false
    }
end

local function renderInfoShowcaseActive(slot, slotIndex)
    drawRenderableLabel(createInfoShowcaseLabel(slot, slotIndex, true))
end

local function renderInfoShowcaseDeath(slot, slotIndex, deathFrame)
    local label = createInfoShowcaseLabel(slot, slotIndex, false)
    local deathLabel = {
        text = label.text,
        x = label.x,
        y = label.y,
        scale = label.scale,
        owner = label.owner,
        activeEffectMode = label.activeEffectMode,
        activeEffectFrames = label.activeEffectFrames,
        textColorMode = label.textColorMode,
        color = label.color,
        rainbowTintColor = label.rainbowTintColor,
        rainbowTintProgress = label.rainbowTintProgress,
        variationSeed = label.variationSeed,
        championStyleApplied = false,
        effectMode = slot.deathEffectMode,
        duration = SHOWCASE_DEATH_FRAMES,
        startFrame = game:GetFrameCount() - deathFrame
    }

    local alpha, scale, offsetX, offsetY, explodeDistance = getDeathEffectValues(deathLabel)
    if alpha <= 0 then return end

    local progress = clamp(deathFrame / SHOWCASE_DEATH_FRAMES, 0, 1)
    local color = getLabelColorWithAlpha(deathLabel, alpha)

    drawDeathEffectText(deathLabel, label.x + offsetX, label.y + offsetY, scale, color, progress, explodeDistance)
end

function renderInfoShowcasePreview()
    local frame = game:GetFrameCount()

    if state.infoShowcaseStartFrame < 0 then
        state.infoShowcaseStartFrame = frame
        state.infoShowcaseSlots = {}
    end

    local elapsed = frame - state.infoShowcaseStartFrame

    for slotIndex = 1, SHOWCASE_SLOT_COUNT do
        local localElapsed = elapsed + ((slotIndex - 1) * SHOWCASE_SLOT_DELAY)
        local cycleIndex = math.floor(localElapsed / SHOWCASE_CYCLE_FRAMES)
        local cycleFrame = localElapsed % SHOWCASE_CYCLE_FRAMES
        local slot = ensureInfoShowcaseSlot(slotIndex, cycleIndex)

        if cycleFrame < SHOWCASE_ACTIVE_FRAMES then
            renderInfoShowcaseActive(slot, slotIndex)
        elseif cycleFrame < SHOWCASE_ACTIVE_FRAMES + SHOWCASE_DEATH_FRAMES then
            renderInfoShowcaseDeath(slot, slotIndex, cycleFrame - SHOWCASE_ACTIVE_FRAMES)
        end
    end
end
