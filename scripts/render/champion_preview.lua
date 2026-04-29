local CNH = require("scripts.core.context")
local _ENV = CNH

-- Preview rotativo de champion styling no MCM: mostra o label ativo, toca o
-- death effect tematico e avanca para o proximo champion.
function getChampionPreviewFrameData()
    -- Champion styling preview intentionally cycles by time instead of user input:
    -- Active label for about two seconds, themed death effect, then next champion.
    local frame = game:GetFrameCount()
    local activeFrames = 60
    local deathFrames = config.enemyDeathEffectFrames
    local pauseFrames = 10
    local cycleFrames = activeFrames + deathFrames + pauseFrames

    if state.championPreviewStartFrame < 0 then
        state.championPreviewStartFrame = frame
        state.championPreviewIndex = 0
    end

    local elapsed = frame - state.championPreviewStartFrame
    local cycleIndex = math.floor(elapsed / cycleFrames)
    local cycleProgress = elapsed % cycleFrames
    local championId = cycleIndex % 26

    state.championPreviewIndex = championId

    return championId, cycleProgress, activeFrames, deathFrames
end

function createChampionPreviewLabel(championId)
    local style = CHAMPION_LABEL_STYLE[championId] or CHAMPION_LABEL_STYLE[0]
    local visualStyle = config.showChampionStyling and style or nil
    local settings = getOwnerSettings(LABEL_OWNER.ENEMY)
    if state.enemyPreviewName == nil then
        state.enemyPreviewName = getRandomPreviewName(state.enemyPreviewNames, "Fly")
    end

    local baseName = state.enemyPreviewName
    local text = formatLabelText(LABEL_OWNER.ENEMY, baseName, style)
    local activeEffectMode = visualStyle and visualStyle.activeEffect or ACTIVE_LABEL_EFFECT.DISABLED
    local textColorMode = settings.textColorMode

    if visualStyle and visualStyle.rainbow then
        textColorMode = TEXT_COLOR_MODE.RAINBOW
    elseif visualStyle and visualStyle.colorMode ~= "preserve" then
        textColorMode = TEXT_COLOR_MODE.DEFAULT
    end

    local variationSeed = getTextVariationSeed(text) + (championId * 97)
    local scale, activeOffsetX, activeOffsetY = applyActiveEffect(settings.textScale, activeEffectMode, visualStyle, variationSeed, settings.activeEffectFrames)
    local x, y = getLabelPositionFromSettings(
        nil,
        text,
        settings,
        scale,
        true,
        activeOffsetX,
        activeOffsetY
    )

    if x == nil or y == nil then return nil end

    local label = {
        owner = LABEL_OWNER.ENEMY,
        entity = nil,
        name = baseName,
        text = text,
        x = x,
        y = y,
        scale = scale,
        variationSeed = variationSeed,
        activeEffectMode = activeEffectMode,
        activeEffectFrames = settings.activeEffectFrames,
        deathEffectMode = visualStyle and visualStyle.deathEffect or settings.deathEffectMode,
        textColorMode = textColorMode,
        color = getContextualLabelColor(LABEL_OWNER.ENEMY, nil, 0, settings),
        rainbowTintColor = textColorMode == TEXT_COLOR_MODE.RAINBOW and KColor(1, 0.25, 0.2, 1) or nil,
        rainbowTintProgress = 0,
        championScaleApplied = visualStyle ~= nil
    }

    applyChampionStyleToLabel(label, visualStyle)
    return label
end

function renderChampionStylingPreview()
    local championId, cycleProgress, activeFrames, deathFrames = getChampionPreviewFrameData()
    local label = createChampionPreviewLabel(championId)

    if label == nil then return end

    if not config.showChampionStyling then
        drawRenderableLabel(label)
        return
    end

    if cycleProgress < activeFrames then
        drawRenderableLabel(label)
        return
    end

    if cycleProgress < activeFrames + deathFrames then
        local deathLabel = {
            owner = label.owner,
            text = label.text,
            x = label.x,
            y = label.y,
            scale = label.scale,
            color = label.color,
            textColorMode = label.textColorMode,
            rainbowTintColor = label.rainbowTintColor,
            rainbowTintProgress = label.rainbowTintProgress,
            activeEffectMode = label.activeEffectMode,
            activeEffectFrames = label.activeEffectFrames,
            variationSeed = label.variationSeed,
            championStyleApplied = label.championStyleApplied,
            effectMode = label.deathEffectMode or DEATH_LABEL_EFFECT.FADE_OUT,
            duration = deathFrames,
            startFrame = game:GetFrameCount() - (cycleProgress - activeFrames),
            fixed = true,
            screenOffsetX = nil,
            screenOffsetY = nil
        }

        local alpha, scale, offsetX, offsetY, explodeDistance = getDeathEffectValues(deathLabel)
        local progress = clamp((cycleProgress - activeFrames) / math.max(deathFrames, 1), 0, 1)
        local color = getLabelColorWithAlpha(deathLabel, alpha)

        drawDeathEffectText(deathLabel, label.x + offsetX, label.y + offsetY, scale, color, progress, explodeDistance)
    end
end
