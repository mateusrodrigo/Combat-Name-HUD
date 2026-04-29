local CNH = require("scripts.core.context")
local _ENV = CNH

-- Entrada dos callbacks de dano. Decide se o dano veio do jogador, se deve
-- marcar boss atingido, mostrar inimigo ou aplicar shake reativo.
function getSourceEntity(source)
    -- Damage callbacks pass EntityRef. This helper extracts the entity while
    -- protecting against unusual/null sources.
    if source == nil then return nil end

    local ok, sourceEntity = pcall(function()
        return source.Entity
    end)

    if ok and sourceEntity then
        return sourceEntity
    end

    return nil
end

function entityMatchesSource(targetEntity, sourceEntity)
    -- Damage can originate from the entity directly or from a child/projectile
    -- linked through Parent/SpawnerEntity.
    if targetEntity == nil or sourceEntity == nil then return false end

    if sourceEntity.InitSeed == targetEntity.InitSeed then
        return true
    end

    if sourceEntity.SpawnerEntity ~= nil
        and sourceEntity.SpawnerEntity.InitSeed == targetEntity.InitSeed
    then
        return true
    end

    if sourceEntity.Parent ~= nil
        and sourceEntity.Parent.InitSeed == targetEntity.InitSeed
    then
        return true
    end

    return false
end

function isPlayerDamageSource(source)
    -- Enemy names only appear when the player or a player-owned object hits them.
    local sourceEntity = getSourceEntity(source)

    if sourceEntity == nil then
        return true
    end

    if sourceEntity.Type == EntityType.ENTITY_PLAYER
        or sourceEntity.Type == EntityType.ENTITY_TEAR
        or sourceEntity.Type == EntityType.ENTITY_LASER
        or sourceEntity.Type == EntityType.ENTITY_KNIFE
        or sourceEntity.Type == EntityType.ENTITY_BOMBDROP
        or sourceEntity.Type == EntityType.ENTITY_FAMILIAR
    then
        return true
    end

    if sourceEntity.SpawnerEntity ~= nil then
        return sourceEntity.SpawnerEntity.Type == EntityType.ENTITY_PLAYER
            or sourceEntity.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR
    end

    return false
end

function shakeBossThatDamagedPlayer(source)
    -- When the player is hit, find which tracked boss was responsible and start
    -- that boss label's shake window.
    if not config.bossShakeOnDamage then return end

    local sourceEntity = getSourceEntity(source)
    if sourceEntity == nil then return end

    for _, seed in ipairs(state.bossOrder) do
        local bossData = state.bosses[seed]

        if bossData ~= nil
            and bossData.entity ~= nil
            and entityMatchesSource(bossData.entity, sourceEntity)
        then
            bossData.shakeUntilFrame = game:GetFrameCount() + config.bossShakeFrames
            return
        end
    end
end

function isTrackedEnemyDamageSource(source)
    -- Common enemy shake only applies to the currently displayed enemy label.
    if state.enemyEntity == nil or not safeExists(state.enemyEntity) then return false end

    local sourceEntity = getSourceEntity(source)
    if sourceEntity == nil then return false end

    return entityMatchesSource(state.enemyEntity, sourceEntity)
end

function onEntityTakeDamage(entity, amount, flags, source, countdown)
    -- One damage callback drives two features:
    -- 1. Player hit by tracked enemy/boss -> reactive shake.
    -- 2. Player damages common enemy -> temporary enemy name.
    if entity == nil then return end

    if entity.Type == EntityType.ENTITY_PLAYER then
        shakeBossThatDamagedPlayer(source)

        if config.enemyShakeOnDamage and isTrackedEnemyDamageSource(source) then
            state.enemyShakeUntilFrame = game:GetFrameCount() + config.enemyShakeFrames
        end

        return
    end

    if not isPlayerDamageSource(source) then return end

    local npc = getNPC(entity)
    if npc == nil then return end

    if safeIsBoss(npc) then
        markBossHit(npc)
        clearEnemyName(false)
        return
    end

    if not config.showEnemyName then return end
    if not safeIsActiveEnemy(npc) then return end
    if safeIsFriendly(npc) then return end

    trackEnemyLabel(npc)
end
