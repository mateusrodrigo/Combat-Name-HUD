local CNH = require("scripts.core.context")
local _ENV = CNH

-- Resolucao de nomes de entidades. Tenta XMLData/REPENTOGON, tabela local,
-- EID e EntityConfig, ignorando tokens/numeros que nao sao bons labels.
function cleanEntityName(name)
    if type(name) ~= "string" or name == "" then return nil end

    -- Without REPENTOGON, some EntityConfig name calls can return numeric string
    -- IDs instead of localized names. Those IDs are implementation details, not
    -- useful labels, so reject them and let the fallback name sources run.
    if string.match(name, "^%s*%-?%d+%s*$") then return nil end

    -- EntityConfig names can come as "#NAME_KEY" or with underscores. The HUD
    -- wants a readable combat label, not the raw config token.
    name = string.gsub(name, "^#", "")
    name = string.gsub(name, "_", " ")
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")

    if name == "" then return nil end
    return name
end

function getExternalEntityName(entityType, variant, subtype)
    -- REPENTOGON exposes XMLData, which is the best source for vanilla and modded
    -- entity names. Vanilla Isaac does not, so this falls back to a bundled XML
    -- name table, then to EID's table if that mod is present.
    local xmlData = rawget(_G, "XMLData")
    if xmlData and type(xmlData.GetEntityByTypeVarSub) == "function" then
        local ok, xmlEntry = pcall(function()
            return xmlData.GetEntityByTypeVarSub(entityType, variant, subtype)
        end)

        if ok and xmlEntry then
            local xmlName = cleanEntityName(xmlEntry.name)
            if xmlName ~= nil then return xmlName end
        end
    end

    local exactKey = tostring(entityType) .. "." .. tostring(variant) .. "." .. tostring(subtype)
    local variantKey = tostring(entityType) .. "." .. tostring(variant)

    local builtInName = cleanEntityName(builtInEntityNames[exactKey])
        or cleanEntityName(builtInEntityNames[variantKey])
    if builtInName ~= nil then return builtInName end

    local eid = rawget(_G, "EID")
    local xmlNames = eid and eid.XMLEntityNames
    if type(xmlNames) == "table" then
        return cleanEntityName(xmlNames[exactKey]) or cleanEntityName(xmlNames[variantKey])
    end

    return nil
end

function getEntityConfigName(entityConfig)
    if entityConfig == nil then return nil end

    local okName, rawName = pcall(function()
        if entityConfig.GetName then
            return entityConfig:GetName()
        end

        return nil
    end)

    if okName then
        local name = cleanEntityName(rawName)
        if name ~= nil then return name end
    end

    return cleanEntityName(entityConfig.Name)
        or cleanEntityName(entityConfig.name)
        or cleanEntityName(entityConfig.NameKey)
        or cleanEntityName(entityConfig.nameKey)
end

function getEntityName(entity)
    if entity == nil then return nil end
    if entity.Type == nil or entity.Variant == nil or entity.SubType == nil then return nil end

    -- Type/variant/subtype normally identifies the display name in EntityConfig.
    -- Champion subtypes and vanilla non-REPENTOGON APIs can return numeric name IDs,
    -- so name resolution intentionally tries multiple readable sources.
    local key = tostring(entity.Type) .. "-" .. tostring(entity.Variant) .. "-" .. tostring(entity.SubType)

    if state.nameCache[key] ~= nil then
        return state.nameCache[key]
    end

    local subtypeCandidates = { entity.SubType, 0, 1 }
    local entityConfig = nil
    local name = nil
    local resolvedReadableName = false

    for _, subtype in ipairs(subtypeCandidates) do
        name = getExternalEntityName(entity.Type, entity.Variant, subtype)
        if name ~= nil then
            resolvedReadableName = true
            break
        end

        local ok, result = pcall(function()
            return EntityConfig.GetEntity(entity.Type, entity.Variant, subtype)
        end)

        if ok and result ~= nil then
            entityConfig = result
            name = getEntityConfigName(entityConfig)
            if name ~= nil then
                resolvedReadableName = true
                break
            end
        end
    end

    if name == nil then
        if entityConfig ~= nil then
            local okBoss, isBoss = pcall(function()
                return entityConfig:IsBoss()
            end)

            name = okBoss and isBoss and "Boss" or "Enemy"
        else
            name = safeIsBoss(entity) and "Boss" or "Enemy"
        end
    end

    if resolvedReadableName then
        state.nameCache[key] = name
    end

    return name
end
