local CNH = require("scripts.core.context")
local _ENV = CNH

-- Death labels. Guarda copias renderizaveis quando um boss/inimigo morre,
-- desenha a animacao de morte e compacta a lista a cada frame.
function getLabelColorWithAlpha(label, alpha)
    local source = label.color or KColor(1, 1, 1, 1)

    return KColor(
        source.R or source.Red or 1,
        source.G or source.Green or 1,
        source.B or source.Blue or 1,
        alpha
    )
end

local function getDeathColorForCharacter(label, color)
    if label.textColorMode ~= TEXT_COLOR_MODE.RAINBOW then return nil end

    return function(index, alpha)
        return getRainbowCharacterColor(index, alpha or getColorAlpha(color), label.rainbowTintColor, label.rainbowTintProgress)
    end
end

local function drawDeathText(label, text, x, y, scale, color, startIndex)
    if label.textColorMode == TEXT_COLOR_MODE.RAINBOW then
        drawRainbowTextFromIndex(text, x, y, scale, color, startIndex or 1, label.rainbowTintColor, label.rainbowTintProgress)
        return
    end

    drawText(text, x, y, scale, color)
end

function drawDeathEffectText(label, x, y, scale, color, progress, explodeDistance)
    local variationSeed = getLabelVariationSeed(label, 900)
    local colorForCharacter = getDeathColorForCharacter(label, color)

    if label.effectMode == DEATH_LABEL_EFFECT.EXPLODE then
        drawExplodedText(label.text, x, y, scale, color, explodeDistance, variationSeed, colorForCharacter)
    elseif label.effectMode == DEATH_LABEL_EFFECT.RING_BURST then
        local leftY = y + seededRange(variationSeed + 11, -3, 3) * progress
        local rightY = y + seededRange(variationSeed + 17, -3, 3) * progress
        drawDeathText(label, label.text, x - (explodeDistance * seededRange(variationSeed + 23, 0.36, 0.56)), leftY, scale, color)
        drawDeathText(label, label.text, x + (explodeDistance * seededRange(variationSeed + 29, 0.36, 0.56)), rightY, scale, color)
        drawDeathText(label, label.text, x + seededRange(variationSeed + 31, -2, 2) * progress, y - (explodeDistance * seededRange(variationSeed + 37, 0.22, 0.42)), scale * seededRange(variationSeed + 41, 0.86, 0.98), color)
    elseif label.effectMode == DEATH_LABEL_EFFECT.DISSOLVE then
        drawDissolveText(label.text, x, y, scale, color, progress, variationSeed, colorForCharacter)
    elseif label.effectMode == DEATH_LABEL_EFFECT.SLASH_CUT then
        drawSlashCutText(label.text, x, y, scale, color, progress, variationSeed, colorForCharacter)
    elseif label.effectMode == DEATH_LABEL_EFFECT.SPLIT_GHOST then
        drawDeathText(label, label.text, x - explodeDistance, y + seededRange(variationSeed + 43, -4, 2) * progress, scale, color)
        drawDeathText(label, label.text, x + explodeDistance, y + seededRange(variationSeed + 47, -2, 4) * progress, scale, color)
    elseif label.effectMode == DEATH_LABEL_EFFECT.PHASE_OUT then
        local phaseSpread = seededRange(variationSeed + 53, 1.5, 3.5)
        drawDeathText(label, label.text, x - phaseSpread, y + seededRange(variationSeed + 59, -1.5, 1.5), scale, colorWithAlphaMultiplier(color, 0.55))
        drawDeathText(label, label.text, x + phaseSpread, y, scale, color)
    elseif label.effectMode == DEATH_LABEL_EFFECT.TOXIC_FADE then
        drawDissolveText(label.text, x + seededRange(variationSeed + 61, -2, 2) * progress, y, scale, color, progress, variationSeed, colorForCharacter)
    elseif label.effectMode == DEATH_LABEL_EFFECT.COIN_SPARK then
        drawDeathText(label, label.text, x + seededRange(variationSeed + 67, -2, 2) * progress, y, scale * seededRange(variationSeed + 71, 0.96, 1.08), color)
    elseif label.effectMode == DEATH_LABEL_EFFECT.COIN_FLIP then
        drawCoinFlipText(label.text, x, y, scale, color, progress, variationSeed, colorForCharacter)
    elseif label.effectMode == DEATH_LABEL_EFFECT.NECRO_FADE then
        local ghostOffset = seededRange(variationSeed + 73, 0.8, 2.4)
        drawDeathText(label, label.text, x - ghostOffset, y + seededRange(variationSeed + 79, -1.5, 1.5), scale, colorWithAlphaMultiplier(color, 0.65))
        drawDeathText(label, label.text, x + ghostOffset, y, scale, color)
    elseif label.activeEffectMode == ACTIVE_LABEL_EFFECT.LETTER_WAVE then
        drawWaveText(label.text, x, y, scale, color, variationSeed, label.activeEffectFrames, colorForCharacter)
    elseif label.textColorMode == TEXT_COLOR_MODE.RAINBOW then
        drawRainbowText(label.text, x, y, scale, color, label.rainbowTintColor, label.rainbowTintProgress)
    else
        drawText(label.text, x, y, scale, color)
    end
end

function getDeathLabelBasePosition(label)
    if label.worldPosition == nil then
        return label.x, label.y
    end

    local screenPos = Isaac.WorldToScreen(label.worldPosition)
    return screenPos.X + (label.screenOffsetX or 0), screenPos.Y + (label.screenOffsetY or 0)
end

function spawnDeathLabelFromRenderable(label)
    if label == nil then return end

    -- death effects must keep rendering after the active label is gone, so
    -- copy only the render values needed to animate the exit.
    local settings = getOwnerSettings(label.owner)
    local effectMode = label.deathEffectMode or settings.deathEffectMode
    if effectMode == DEATH_LABEL_EFFECT.DISABLED then return end

    -- Fixed enemy labels all share the same screen anchor. Keeping old fixed
    -- enemy death animations while a new target appears makes the HUD unreadable,
    -- so only the latest fixed enemy death label is allowed to linger.
    if label.owner == LABEL_OWNER.ENEMY and config.enemyPositionMode == POSITION_MODE.FIXED_POSITION then
        local remaining = {}

        for _, deathLabel in ipairs(state.deathLabels) do
            if deathLabel.owner ~= LABEL_OWNER.ENEMY then
                table.insert(remaining, deathLabel)
            end
        end

        state.deathLabels = remaining
    end

    table.insert(state.deathLabels, {
        text = label.text,
        x = label.x,
        y = label.y,
        scale = label.scale,
        owner = label.owner,
        entitySeed = label.entitySeed,
        activeEffectMode = label.activeEffectMode,
        activeEffectFrames = label.activeEffectFrames,
        textColorMode = label.textColorMode,
        color = label.color,
        rainbowTintColor = label.rainbowTintColor,
        rainbowTintProgress = label.rainbowTintProgress,
        variationSeed = label.variationSeed,
        championStyleApplied = label.championStyleApplied,
        worldPosition = label.worldPosition,
        screenOffsetX = label.screenOffsetX,
        screenOffsetY = label.screenOffsetY,
        fixedStackSlot = label.fixedStackSlot,
        effectMode = effectMode,
        duration = settings.deathEffectFrames,
        startFrame = game:GetFrameCount()
    })
end

function isDeathLabelForEnemy(deathLabel, enemyEntity, enemyText)
    if deathLabel == nil or deathLabel.owner ~= LABEL_OWNER.ENEMY then return false end

    if enemyEntity ~= nil and deathLabel.entitySeed ~= nil and deathLabel.entitySeed == enemyEntity.InitSeed then
        return true
    end

    return enemyText ~= nil and enemyText ~= "" and deathLabel.text == enemyText
end

function removeDeathLabelsForEnemy(enemyEntity, enemyText)
    local remaining = {}

    for _, deathLabel in ipairs(state.deathLabels) do
        if not isDeathLabelForEnemy(deathLabel, enemyEntity, enemyText) then
            table.insert(remaining, deathLabel)
        end
    end

    state.deathLabels = remaining
end

function renderLoopedDeathEffectPreview(label)
    if label == nil then return end

    -- MCM previews loop death effects forever by pretending the effect started
    -- loopFrame frames ago.
    local settings = getOwnerSettings(label.owner)

    if settings.deathEffectMode == DEATH_LABEL_EFFECT.DISABLED then
        drawRenderableLabel(label)
        return
    end

    local duration = math.max(settings.deathEffectFrames, 1)
    local loopFrame = game:GetFrameCount() % duration

    local previewLabel = {
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
        championStyleApplied = label.championStyleApplied,
        worldPosition = label.worldPosition,
        screenOffsetX = label.screenOffsetX,
        screenOffsetY = label.screenOffsetY,
        effectMode = settings.deathEffectMode,
        duration = duration,
        startFrame = game:GetFrameCount() - loopFrame
    }

    local alpha, scale, offsetX, offsetY, explodeDistance = getDeathEffectValues(previewLabel)
    local color = getLabelColorWithAlpha(label, alpha)
    local progress = clamp(loopFrame / duration, 0, 1)

    if alpha <= 0 then return end

    local baseX, baseY = getDeathLabelBasePosition(previewLabel)
    drawDeathEffectText(previewLabel, baseX + offsetX, baseY + offsetY, scale, color, progress, explodeDistance)
end

function renderDeathLabels()
    -- Render and compact the death-label list each frame.
    local remaining = {}

    for _, label in ipairs(state.deathLabels) do
        local elapsed = game:GetFrameCount() - label.startFrame
        local activeEnemyText = nil

        if state.enemyName ~= nil and state.enemyName ~= "" then
            activeEnemyText = formatLabelText(LABEL_OWNER.ENEMY, state.enemyName, state.enemyChampionDescriptorStyle)
        end

        if isDeathLabelForEnemy(label, state.enemyEntity, activeEnemyText) then
            -- An active enemy/champion label owns the screen. Drop any older exit
            -- animation for the same target so it cannot look like a duplicate.
        elseif elapsed <= label.duration then
            local alpha, scale, offsetX, offsetY, explodeDistance = getDeathEffectValues(label)
            local color = getLabelColorWithAlpha(label, alpha)

            if alpha > 0 then
                local progress = clamp(elapsed / label.duration, 0, 1)
                local baseX, baseY = getDeathLabelBasePosition(label)

                drawDeathEffectText(label, baseX + offsetX, baseY + offsetY, scale, color, progress, explodeDistance)
            end

            table.insert(remaining, label)
        end
    end

    state.deathLabels = remaining
end
