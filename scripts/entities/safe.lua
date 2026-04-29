local CNH = require("scripts.core.context")
local _ENV = CNH

-- Leituras seguras de entidades do Isaac. Essas funcoes isolam pcall e filtros
-- para manter tracking/render legiveis mesmo com userdata invalido entre frames.
function safeExists(entity)
    if entity == nil then return false end

    -- Isaac entity userdata can become invalid between frames. All safe* helpers
    -- isolate pcall checks so tracking code can stay readable.
    local ok, result = pcall(function()
        return entity:Exists()
    end)

    return ok and result
end

function safeIsBoss(entity)
    if entity == nil then return false end

    local ok, result = pcall(function()
        return entity:IsBoss()
    end)

    return ok and result
end

function safeIsActiveEnemy(entity)
    if entity == nil then return false end

    local ok, result = pcall(function()
        return entity:IsActiveEnemy(false)
    end)

    return ok and result
end

function safeIsDead(entity)
    if entity == nil then return true end

    local ok, result = pcall(function()
        return entity:IsDead()
    end)

    return ok and result
end

function getEntityHitPoints(entity)
    if entity == nil then return nil end

    local ok, hitPoints = pcall(function()
        return entity.HitPoints
    end)

    if ok then return hitPoints end

    return nil
end

function isEntityActuallyDead(entity)
    if entity == nil then return true end
    if not safeExists(entity) then return false end
    if safeIsDead(entity) then return true end

    local hitPoints = getEntityHitPoints(entity)
    if hitPoints ~= nil and hitPoints <= 0 then return true end

    return false
end

function safeIsFriendly(entity)
    if entity == nil then return false end

    local ok, result = pcall(function()
        return entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
    end)

    return ok and result
end

function safeIsVulnerableEnemy(entity)
    if entity == nil then return false end

    local ok, result = pcall(function()
        return entity:IsVulnerableEnemy()
    end)

    return ok and result
end

function isIgnoredEntityType(entityType)
    -- Only NPC-like enemies should be named. Projectiles, lasers, effects, etc.
    -- may be damage sources but are not useful HUD label targets.
    return entityType == EntityType.ENTITY_PROJECTILE
        or entityType == EntityType.ENTITY_TEAR
        or entityType == EntityType.ENTITY_LASER
        or entityType == EntityType.ENTITY_KNIFE
        or entityType == EntityType.ENTITY_BOMBDROP
        or entityType == EntityType.ENTITY_EFFECT
end

function getNPC(entity)
    -- A small gatekeeper for anything that might be passed by damage callbacks or
    -- room entity scans.
    if entity == nil then return nil end
    if entity.Type == nil then return nil end
    if isIgnoredEntityType(entity.Type) then return nil end

    local ok, npc = pcall(function()
        return entity:ToNPC()
    end)

    if ok and npc ~= nil then
        return npc
    end

    return entity
end
