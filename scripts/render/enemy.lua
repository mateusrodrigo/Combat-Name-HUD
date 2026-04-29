local CNH = require("scripts.core.context")
local _ENV = CNH

-- Render do inimigo destacado. O dano e lifetime ficam em entities/enemy_tracker.lua;
-- aqui ficam o desenho real, preview e ordem com death labels.

-- =========================================================
-- RENDER ENEMY
-- =========================================================

function renderEnemyPreview()
    -- MCM enemy preview mirrors real enemy labels, including active/death effects and
    -- visibility.
    if not config.showEnemyName then return end

    if state.enemyPreviewName == nil then
        state.enemyPreviewName = getRandomPreviewName(state.enemyPreviewNames, "Fly")
    end

    local hitUntilFrame = nil
    local shakeUntilFrame = 0

    if state.previewEffectMode == PREVIEW_EFFECT_MODE.HIT then
        hitUntilFrame = getLoopedHitPreviewUntilFrame()
    elseif state.previewEffectMode == PREVIEW_EFFECT_MODE.HP_COLOR then
        hitUntilFrame = getLoopedHitPreviewUntilFrame()
    elseif state.previewEffectMode == PREVIEW_EFFECT_MODE.SHAKE then
        local frame = game:GetFrameCount()
        shakeUntilFrame = frame + math.max(config.enemyShakeFrames, 1)
    end

    local label = createRenderableLabel(LABEL_OWNER.ENEMY, nil, state.enemyPreviewName, shakeUntilFrame, true, hitUntilFrame)

    if label == nil then return end

    if state.previewEffectMode == PREVIEW_EFFECT_MODE.DEATH then
        renderLoopedDeathEffectPreview(label)
    else
        drawRenderableLabel(label)
    end
end

function renderEnemyName(bossBoxes)
    -- The enemy label uses bossBoxes to avoid colliding with active boss labels.
    local isPreview = resolveModConfigMenu()
        and MCM.IsVisible
        and (
            state.previewOwner == PREVIEW_OWNER.ENEMY
            or state.previewOwner == PREVIEW_OWNER.BOTH
        )

    if isPreview then
        renderEnemyPreview()
        return
    end

    if not config.showEnemyName then return end
    if state.enemyEntity == nil then return end
    if state.enemyName == nil or state.enemyName == "" then return end

    local label = createRenderableLabel(
        LABEL_OWNER.ENEMY,
        state.enemyEntity,
        state.enemyName,
        state.enemyShakeUntilFrame,
        false,
        state.enemyHitUntilFrame
    )

    if label == nil then return end

    label.x, label.y = pushBoxAwayFromBoxes(label.text, label.x, label.y, label.scale, bossBoxes)
    drawRenderableLabel(label)
end

function renderPreviewReferenceOnce()
    -- The centered player reference is rendered once even when both boss and
    -- enemy previews are active.
    if not resolveModConfigMenu() or not MCM.IsVisible then return end
    if not config.showPreviewReferenceGeneral then return end

    local shouldDrawBossReference =
        config.showPreviewReferenceBoss
        and (state.previewOwner == PREVIEW_OWNER.BOSS or state.previewOwner == PREVIEW_OWNER.BOTH)
        and state.previewEffectMode ~= PREVIEW_EFFECT_MODE.BOSS_STACK
        and shouldDrawPreviewReference(config.bossPositionMode)

    local shouldDrawEnemyReference =
        config.showPreviewReferenceEnemy
        and (state.previewOwner == PREVIEW_OWNER.ENEMY or state.previewOwner == PREVIEW_OWNER.BOTH)
        and shouldDrawPreviewReference(config.enemyPositionMode)

    if shouldDrawBossReference or shouldDrawEnemyReference then
        drawPreviewEntityReference()
    end
end

function renderNames()
    -- The render order is reference -> active labels -> lingering death effects.
    if resolveModConfigMenu()
        and MCM.IsVisible
        and state.previewEffectMode == PREVIEW_EFFECT_MODE.INFO_SHOWCASE
        and state.previewOwner ~= PREVIEW_OWNER.NONE
    then
        renderInfoShowcasePreview()
        return
    end

    renderPreviewReferenceOnce()

    if resolveModConfigMenu()
        and MCM.IsVisible
        and state.previewEffectMode == PREVIEW_EFFECT_MODE.CHAMPION
        and state.previewOwner ~= PREVIEW_OWNER.NONE
    then
        renderChampionStylingPreview()
        renderDeathLabels()
        return
    end

    local bossBoxes = renderBossNames()
    renderEnemyName(bossBoxes)
    renderDeathLabels()
end

