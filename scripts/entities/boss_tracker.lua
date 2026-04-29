local CNH = require("scripts.core.context")
local _ENV = CNH

-- Tracking de bosses: agrupa bosses repetidos, atualiza ordem de prioridade,
-- detecta mortes e dispara death labels de boss.
function getBossGroupKey(entity, name)
    if name ~= nil and name ~= "" then
        return "name:" .. name
    end

    return "entity:" .. tostring(entity.Type) .. "-" .. tostring(entity.Variant) .. "-" .. tostring(entity.SubType)
end

function getFallbackBossSeedForGroup(groupKey, excludedSeed)
    for _, seed in ipairs(state.bossOrder) do
        local bossData = state.bosses[seed]

        if bossData
            and seed ~= excludedSeed
            and bossData.groupKey == groupKey
            and bossData.entity
            and safeExists(bossData.entity)
            and not safeIsDead(bossData.entity)
            and bossData.entity.HitPoints
            and bossData.entity.HitPoints > 0
        then
            return seed
        end
    end

    return nil
end

function moveBossSeedToFront(seed)
    if seed == nil then return end

    for index, bossSeed in ipairs(state.bossOrder) do
        if bossSeed == seed then
            table.remove(state.bossOrder, index)
            break
        end
    end

    table.insert(state.bossOrder, 1, seed)
end

function replaceBossSeedInOrder(seed, replacementSeed)
    -- When a collapsed multi-part boss swaps representative, keep the group in
    -- the same ordering slot instead of making the replacement enter as a new
    -- boss label.
    local nextOrder = {}
    local insertedReplacement = false

    for _, bossSeed in ipairs(state.bossOrder) do
        if bossSeed == seed then
            if replacementSeed ~= nil and not insertedReplacement then
                table.insert(nextOrder, replacementSeed)
                insertedReplacement = true
            end
        elseif bossSeed ~= replacementSeed then
            table.insert(nextOrder, bossSeed)
        end
    end

    state.bossOrder = nextOrder
end

function setActiveBossForGroup(seed)
    local bossData = state.bosses[seed]
    if bossData == nil or bossData.groupKey == nil then return end

    state.bossActiveByGroup[bossData.groupKey] = seed
end

-- =========================================================
-- BOSS TRACKING
-- =========================================================

function playerCanAct()
    -- Boss labels wait until the player can act to avoid showing names too early
    -- during doors, transitions, intros, or other forced-control moments.
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)

        if player.ControlsCooldown <= 0 then
            return true
        end
    end

    return false
end

function isBossDisplayReady(bossData)
    if bossData == nil or bossData.entity == nil then return false end
    if not state.fightStarted then return false end
    if not safeExists(bossData.entity) then return false end
    if safeIsDead(bossData.entity) or isEntityActuallyDead(bossData.entity) then return false end

    -- Fixed labels are HUD state, not entity-position labels. Once the boss fight
    -- has started, keep them visible through burrow/invisible/intangible phases
    -- so bosses like Pin do not make the fixed stack blink every time they hide.
    if config.bossPositionMode == POSITION_MODE.FIXED_POSITION then
        return true
    end

    return safeIsVulnerableEnemy(bossData.entity)
end

function prepareBossForLabelDisplay(bossData)
    if not isBossDisplayReady(bossData) then
        if bossData ~= nil then
            bossData.wasDisplayReady = false
            bossData.lastFixedLabel = nil
        end

        return false
    end

    if not bossData.wasDisplayReady then
        if not bossData.hasPlayedIntro then
            bossData.introStartFrame = game:GetFrameCount()
            bossData.hasPlayedIntro = true
        end
    end

    bossData.wasDisplayReady = true
    return true
end

function markBossLabelDisplayed(bossData)
    if bossData == nil then return end

    bossData.hasDisplayedLabel = true
end

function removeBossBySeed(seed, spawnDeathEffect)
    local bossData = state.bosses[seed]
    local fallbackSeed = nil
    local isActiveBossForGroup = bossData ~= nil
        and bossData.groupKey ~= nil
        and state.bossActiveByGroup[bossData.groupKey] == seed

    if isActiveBossForGroup then
        fallbackSeed = getFallbackBossSeedForGroup(bossData.groupKey, seed)
    end

    local wasHiddenByCollapse = bossData ~= nil
        and isBossCollapseEnabled()
        and bossData.groupKey ~= nil
        and state.bossActiveByGroup[bossData.groupKey] ~= nil
        and state.bossActiveByGroup[bossData.groupKey] ~= seed
    local hasCollapsedReplacement = isBossCollapseEnabled()
        and isActiveBossForGroup
        and fallbackSeed ~= nil

    if spawnDeathEffect
        and not wasHiddenByCollapse
        and not hasCollapsedReplacement
        and bossData ~= nil
        and not bossData.deathEffectSpawned
        and bossData.hasDisplayedLabel
        and bossData.name ~= nil
        and bossData.name ~= ""
    then
        bossData.deathEffectSpawned = true

        local label = createRenderableLabel(
            LABEL_OWNER.BOSS,
            bossData.entity,
            bossData.name,
            bossData.shakeUntilFrame,
            false
        )

        applyChampionStyleToLabel(label, bossData.championStyle)

        if label == nil then
            label = createRenderableLabelAtWorldPosition(
                LABEL_OWNER.BOSS,
                bossData.name,
                bossData.lastWorldPosition,
                bossData.shakeUntilFrame,
                bossData.championDescriptorStyle
            )
            applyChampionStyleToLabel(label, bossData.championStyle)
        end

        if label ~= nil
            and config.bossPositionMode == POSITION_MODE.FIXED_POSITION
            and bossData.lastFixedLabel ~= nil
            and bossData.lastFixedLabel.renderedFrame ~= nil
            and game:GetFrameCount() - bossData.lastFixedLabel.renderedFrame <= 2
        then
            label.x = bossData.lastFixedLabel.x
            label.y = bossData.lastFixedLabel.y
            label.scale = bossData.lastFixedLabel.scale
            label.fixedStackSlot = bossData.lastFixedLabel.fixedStackSlot
        end

        if config.bossPositionMode ~= POSITION_MODE.FIXED_POSITION
            or (
                bossData.lastFixedLabel ~= nil
                and bossData.lastFixedLabel.renderedFrame ~= nil
                and game:GetFrameCount() - bossData.lastFixedLabel.renderedFrame <= 2
            )
        then
            spawnDeathLabelFromRenderable(label)
        end
    end

    if bossData ~= nil and bossData.groupKey ~= nil then
        if state.bossActiveByGroup[bossData.groupKey] == seed then
            state.bossActiveByGroup[bossData.groupKey] = fallbackSeed
        end
    end

    state.bosses[seed] = nil
    replaceBossSeedInOrder(seed, hasCollapsedReplacement and fallbackSeed or nil)
end

function updateBossTracking()
    local removedSeeds = {}

    for seed, bossData in pairs(state.bosses) do
        local boss = bossData.entity

        if not safeExists(boss) or isEntityActuallyDead(boss) then
            table.insert(removedSeeds, seed)
        end
    end

    for _, seed in ipairs(removedSeeds) do
        removeBossBySeed(seed, true)
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local npc = getNPC(entity)

        if npc
            and safeIsBoss(npc)
            and safeIsActiveEnemy(npc)
            and not safeIsDead(npc)
            and not isEntityActuallyDead(npc)
        then
            local seed = npc.InitSeed
            local bossName = getEntityName(npc)
            local groupKey = getBossGroupKey(npc, bossName)

            if state.bosses[seed] == nil then
                state.bosses[seed] = {
                    entity = npc,
                    name = bossName,
                    groupKey = groupKey,
                    shakeUntilFrame = 0,
                    hitUntilFrame = 0,
                    lastWorldPosition = getEntityWorldPosition(npc),
                    lastFixedLabel = nil,
                    championStyle = getChampionLabelStyle(npc),
                    championDescriptorStyle = getChampionStyle(npc),
                    introStartFrame = nil,
                    wasDisplayReady = false,
                    hasDisplayedLabel = false,
                    hasPlayedIntro = false,
                    deathEffectSpawned = false
                }

                table.insert(state.bossOrder, seed)

                if state.bossActiveByGroup[groupKey] == nil then
                    state.bossActiveByGroup[groupKey] = seed
                end
            else
                state.bosses[seed].entity = npc
                state.bosses[seed].name = bossName
                state.bosses[seed].groupKey = groupKey
                state.bosses[seed].lastWorldPosition = getEntityWorldPosition(npc) or state.bosses[seed].lastWorldPosition
                state.bosses[seed].championStyle = getChampionLabelStyle(npc)
                state.bosses[seed].championDescriptorStyle = getChampionStyle(npc)

                if state.bossActiveByGroup[groupKey] == nil then
                    state.bossActiveByGroup[groupKey] = seed
                end
            end
        end
    end

    if not state.fightStarted then
        for _, bossData in pairs(state.bosses) do
            if playerCanAct() and safeIsVulnerableEnemy(bossData.entity) then
                state.fightStarted = true
                break
            end
        end
    end

    if #state.bossOrder == 0 then
        state.fightStarted = false
    end
end

function markBossHit(entity)
    if entity == nil then return end

    local seed = entity.InitSeed
    local bossData = state.bosses[seed]

    if bossData ~= nil then
        moveBossSeedToFront(seed)
        bossData.hitUntilFrame = game:GetFrameCount() + config.hitEffectFrames
        setActiveBossForGroup(seed)
    end
end
