local CNH = require("scripts.core.context")
local _ENV = CNH

-- Previews de boss no MCM: label simples, stack spacing e collapse repeated
-- bosses. O render real fica em render/boss.lua.
function createFixedBossStackPreviewLabel(name, hitUntilFrame)
    local settings = getOwnerSettings(LABEL_OWNER.BOSS)
    local text = formatLabelText(LABEL_OWNER.BOSS, name, nil)
    local scale = settings.textScale
    local hitProgress = getHitProgress(hitUntilFrame)

    if config.showHitPunch and hitProgress > 0 then
        scale = scale * (1 + (0.25 * hitProgress))
    end

    local x, y = getCenteredTextPosition(text, settings.fixedXOffset, settings.fixedYOffset, scale)

    return {
        owner = LABEL_OWNER.BOSS,
        entity = nil,
        entitySeed = nil,
        name = name,
        text = text,
        x = x,
        y = y,
        scale = scale,
        variationSeed = getTextVariationSeed(text),
        activeEffectMode = ACTIVE_LABEL_EFFECT.DISABLED,
        activeEffectFrames = settings.activeEffectFrames,
        textColorMode = settings.textColorMode,
        color = getContextualLabelColor(LABEL_OWNER.BOSS, nil, hitProgress, settings, true),
        rainbowTintColor = settings.textColorMode == TEXT_COLOR_MODE.RAINBOW and KColor(1, 0.25, 0.2, 1) or nil,
        rainbowTintProgress = (settings.textColorMode == TEXT_COLOR_MODE.RAINBOW and config.showHitFlash and hitProgress > 0) and hitProgress or 0,
        championStyleApplied = false
    }
end

function drawFixedBossStackPreviewLabels(labels)
    if not config.showBossName then return end

    local lineHeight, baseY, stackDirection = getFixedBossStackLayout(labels)

    for index, label in ipairs(labels) do
        applyFixedBossStackPosition(label, index, lineHeight, baseY, stackDirection)
        drawRenderableLabel(label)
    end
end

function renderBossStackPreview()
    if state.bossPreviewName == nil then
        state.bossPreviewName = getRandomPreviewName(state.bossPreviewNames, "Mom's Heart")
    end

    local labels = getFixedBossDisplayLabels({
        createFixedBossStackPreviewLabel(state.bossPreviewName),
        createFixedBossStackPreviewLabel("Mega Maw"),
        createFixedBossStackPreviewLabel("The Duke of Flies"),
        createFixedBossStackPreviewLabel("Gurdy")
    })

    drawFixedBossStackPreviewLabels(labels)
end

function renderBossCollapsePreview()
    EnsureCombatNameHUDBossCollapsePreviewNames()

    local firstName = state.bossCollapsePreviewNames[1] or state.bossPreviewName or "Mom's Heart"
    local secondName = state.bossCollapsePreviewNames[2] or "Mega Maw"
    local thirdName = state.bossCollapsePreviewNames[3] or "The Duke of Flies"
    local fourthName = state.bossCollapsePreviewNames[4] or "Gurdy"
    local hitUntilFrame = getLoopedHitPreviewUntilFrame()
    local labels

    if config.bossPositionMode == POSITION_MODE.FIXED_POSITION then
        labels = getFixedBossDisplayLabels({
            createFixedBossStackPreviewLabel(firstName, hitUntilFrame),
            createFixedBossStackPreviewLabel(secondName),
            createFixedBossStackPreviewLabel(thirdName),
            createFixedBossStackPreviewLabel(fourthName)
        })
    elseif isBossCollapseEnabled() then
        labels = {
            createFixedBossStackPreviewLabel(firstName, hitUntilFrame),
            createFixedBossStackPreviewLabel(secondName)
        }
    else
        labels = {
            createFixedBossStackPreviewLabel(firstName, hitUntilFrame),
            createFixedBossStackPreviewLabel(firstName),
            createFixedBossStackPreviewLabel(firstName)
        }
    end

    drawFixedBossStackPreviewLabels(labels)
end

function renderBossPreview()
    -- MCM boss preview uses a random boss name but the same render pipeline as a
    -- real boss label.
    if state.previewEffectMode == PREVIEW_EFFECT_MODE.BOSS_COLLAPSE then
        renderBossCollapsePreview()
        return
    end

    if state.previewEffectMode == PREVIEW_EFFECT_MODE.BOSS_STACK then
        renderBossStackPreview()
        return
    end

    if state.bossPreviewName == nil then
        state.bossPreviewName = getRandomPreviewName(state.bossPreviewNames, "Mom's Heart")
    end

    local hitUntilFrame = nil
    local shakeUntilFrame = 0
    local introStartFrame = nil

    if state.previewEffectMode == PREVIEW_EFFECT_MODE.HIT then
        hitUntilFrame = getLoopedHitPreviewUntilFrame()
    elseif state.previewEffectMode == PREVIEW_EFFECT_MODE.HP_COLOR then
        hitUntilFrame = getLoopedHitPreviewUntilFrame()
    elseif state.previewEffectMode == PREVIEW_EFFECT_MODE.SHAKE then
        local frame = game:GetFrameCount()
        shakeUntilFrame = frame + math.max(config.bossShakeFrames, 1)
    elseif state.previewEffectMode == PREVIEW_EFFECT_MODE.BOSS_INTRO then
        introStartFrame = getLoopedBossIntroPreviewStartFrame()
    end

    local label = createRenderableLabel(LABEL_OWNER.BOSS, nil, state.bossPreviewName, shakeUntilFrame, true, hitUntilFrame, introStartFrame)

    if label == nil or not config.showBossName then return end

    if state.previewEffectMode == PREVIEW_EFFECT_MODE.DEATH then
        renderLoopedDeathEffectPreview(label)
    else
        drawRenderableLabel(label)
    end
end
