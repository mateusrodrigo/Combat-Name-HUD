local CNH = require("scripts.core.context")
local _ENV = CNH

-- Stack fixed de bosses: calcula layout vertical, cria o overflow "..." e
-- sincroniza slots visiveis com os death labels que ainda estao animando.
function getFixedBossStackLayout(labels)
    local maxLabelHeight = getTextHeight(config.bossTextScale)

    for _, label in ipairs(labels) do
        maxLabelHeight = math.max(maxLabelHeight, getTextHeight(label.scale))
    end

    local baseY = 40 + config.bossFixedYOffset
    local stackDirection = baseY > Isaac.GetScreenHeight() / 2 and -1 or 1

    return maxLabelHeight + config.bossLineSpacing, baseY, stackDirection
end

function applyFixedBossStackPosition(label, stackSlot, lineHeight, baseY, stackDirection)
    local originalX = label.x
    local originalY = label.y
    local centerX = (Isaac.GetScreenWidth() / 2) - (getTextWidth(label.text, label.scale) / 2)
    local effectOffsetX = originalX - centerX - config.bossFixedXOffset
    local effectOffsetY = originalY - (40 + config.bossFixedYOffset)

    label.x = centerX + config.bossFixedXOffset + effectOffsetX
    label.y = baseY + (((stackSlot - 1) * lineHeight) * stackDirection) + effectOffsetY
    label.fixedStackSlot = stackSlot
end

function createBossOverflowLabel()
    local settings = getOwnerSettings(LABEL_OWNER.BOSS)
    local text = "..."
    local scale = settings.textScale
    local x, y = getCenteredTextPosition(text, settings.fixedXOffset, settings.fixedYOffset, scale)

    return {
        owner = LABEL_OWNER.BOSS,
        entity = nil,
        entitySeed = nil,
        name = text,
        text = text,
        x = x,
        y = y,
        scale = scale,
        variationSeed = getTextVariationSeed(text),
        activeEffectMode = ACTIVE_LABEL_EFFECT.DISABLED,
        activeEffectFrames = settings.activeEffectFrames,
        textColorMode = settings.textColorMode,
        color = getContextualLabelColor(LABEL_OWNER.BOSS, nil, 0, settings, false),
        rainbowTintColor = settings.textColorMode == TEXT_COLOR_MODE.RAINBOW and KColor(1, 0.25, 0.2, 1) or nil,
        rainbowTintProgress = 0,
        championStyleApplied = false,
        isOverflowLabel = true
    }
end

function getFixedBossDisplayLabels(labels)
    local visibleLimit = getFixedBossVisibleLimit()

    if visibleLimit == nil or #labels <= visibleLimit then return labels end

    local displayLabels = {}

    for index = 1, visibleLimit do
        table.insert(displayLabels, labels[index])
    end

    table.insert(displayLabels, createBossOverflowLabel())
    return displayLabels
end

function clearHiddenFixedBossSlots(allLabels, displayLabels)
    local visibleSeeds = {}

    for _, label in ipairs(displayLabels) do
        if label.entitySeed ~= nil then
            visibleSeeds[label.entitySeed] = true
        end
    end

    for _, label in ipairs(allLabels) do
        if label.entitySeed ~= nil and not visibleSeeds[label.entitySeed] then
            local bossData = state.bosses[label.entitySeed]
            if bossData ~= nil then
                bossData.lastFixedLabel = nil
            end
        end
    end
end
