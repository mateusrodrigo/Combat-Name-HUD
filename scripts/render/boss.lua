local CNH = require("scripts.core.context")
local _ENV = CNH

-- Render real de bosses. Converte o tracking em labels, aplica collapse por
-- grupo quando disponivel, e desenha fixed stack ou labels acima/abaixo.
function buildBossLabels()
    local labels = {}
    local renderedGroups = {}

    for _, seed in ipairs(state.bossOrder) do
        local bossData = state.bosses[seed]

        if bossData
            and bossData.entity
            and bossData.name
            and bossData.name ~= ""
        then
            local shouldRender = true

            if isBossCollapseEnabled() and bossData.groupKey ~= nil then
                local activeSeed = state.bossActiveByGroup[bossData.groupKey]

                if activeSeed ~= nil and activeSeed ~= seed then
                    shouldRender = false
                end

                if renderedGroups[bossData.groupKey] then
                    shouldRender = false
                end
            end

            if shouldRender then
                shouldRender = prepareBossForLabelDisplay(bossData)
            else
                bossData.wasDisplayReady = false
                bossData.lastFixedLabel = nil
            end

            if shouldRender then
                local label = createRenderableLabel(
                    LABEL_OWNER.BOSS,
                    bossData.entity,
                    bossData.name,
                    bossData.shakeUntilFrame,
                    false,
                    bossData.hitUntilFrame,
                    bossData.introStartFrame
                )

                if label ~= nil then
                    markBossLabelDisplayed(bossData)
                    table.insert(labels, label)

                    if bossData.groupKey ~= nil then
                        renderedGroups[bossData.groupKey] = true
                    end
                end
            end
        end
    end

    return labels
end

function renderBossNames()
    -- Boss rendering first gives MCM preview priority, then normal combat labels.
    local bossBoxes = {}

    local isPreview = resolveModConfigMenu()
        and MCM.IsVisible
        and (
            state.previewOwner == PREVIEW_OWNER.BOSS
            or state.previewOwner == PREVIEW_OWNER.BOTH
        )

    if isPreview then
        renderBossPreview()
        return bossBoxes
    end

    if not config.showBossName then return bossBoxes end
    if not state.fightStarted then return bossBoxes end

    local labels = buildBossLabels()
    if #labels == 0 then return bossBoxes end

    if config.bossPositionMode == POSITION_MODE.FIXED_POSITION then
        local displayLabels = getFixedBossDisplayLabels(labels)
        local lineHeight, baseY, stackDirection = getFixedBossStackLayout(displayLabels)
        local reservedSlots = {}
        local nextSlot = 1

        clearHiddenFixedBossSlots(labels, displayLabels)

        for _, deathLabel in ipairs(state.deathLabels) do
            local elapsed = game:GetFrameCount() - (deathLabel.startFrame or 0)

            if deathLabel.owner == LABEL_OWNER.BOSS
                and deathLabel.fixedStackSlot ~= nil
                and elapsed <= (deathLabel.duration or 0)
            then
                reservedSlots[deathLabel.fixedStackSlot] = true
            end
        end

        for _, label in ipairs(displayLabels) do
            while reservedSlots[nextSlot] do
                nextSlot = nextSlot + 1
            end

            local stackSlot = nextSlot

            applyFixedBossStackPosition(label, stackSlot, lineHeight, baseY, stackDirection)

            drawRenderableLabel(label)
            table.insert(bossBoxes, getTextBox(label.text, label.x, label.y, label.scale))

            local bossData = label.entitySeed and state.bosses[label.entitySeed] or nil
            if bossData ~= nil then
                bossData.lastFixedLabel = {
                    x = label.x,
                    y = label.y,
                    scale = label.scale,
                    fixedStackSlot = stackSlot,
                    renderedFrame = game:GetFrameCount()
                }
            end

            nextSlot = nextSlot + 1
        end

        return bossBoxes
    end

    for _, label in ipairs(labels) do
        label.x, label.y = pushBoxAwayFromBoxes(label.text, label.x, label.y, label.scale, bossBoxes)

        drawRenderableLabel(label)
        table.insert(bossBoxes, getTextBox(label.text, label.x, label.y, label.scale))
    end

    return bossBoxes
end
