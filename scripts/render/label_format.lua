local CNH = require("scripts.core.context")
local _ENV = CNH

-- Formatacao final do texto do label: descriptor de champion e prefixos Boss:/Enemy:.
function getChampionDescriptor(championStyle)
    if championStyle == nil then return nil end

    if config.championDescriptorMode == CHAMPION_DESCRIPTOR_MODE.LABEL then
        return "(" .. tostring(championStyle.label or "Label") .. ")"
    end

    if config.championDescriptorMode == CHAMPION_DESCRIPTOR_MODE.ENUM then
        return "(" .. tostring(championStyle.enum or "Enum") .. ")"
    end

    return ""
end

function formatChampionName(name, championStyle)
    local descriptor = getChampionDescriptor(championStyle)
    if descriptor == nil or descriptor == "" then return name end

    return name .. " " .. descriptor
end

function formatLabelText(owner, name, championStyle)
    local settings = getOwnerSettings(owner)
    local displayName = formatChampionName(name, championStyle)

    -- Prefixes are owner-specific so "Boss:" and "Enemy:" can be toggled
    -- independently.
    if settings.showPrefix then
        return settings.prefix .. displayName
    end

    return displayName
end
