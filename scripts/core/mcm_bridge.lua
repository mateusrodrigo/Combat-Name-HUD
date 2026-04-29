local CNH = require("scripts.core.context")
local _ENV = CNH

-- Ponte opcional com Mod Config Menu. Mantem a resolucao tolerante a ordem de
-- carregamento e encapsula diferencas entre versoes do MCM.
function isModConfigMenuReady(menu)
    return type(menu) == "table"
        and type(menu.AddSetting) == "function"
        and type(menu.AddText) == "function"
        and type(menu.AddSpace) == "function"
        and type(menu.RemoveCategory) == "function"
end

-- Mod Config Menu is optional. Mods like MiniMAPI load it with pcall(require),
-- so we do the same, then fall back to the global table that MCM publishes.
local mcmRequireOk, requiredMCM = pcall(require, "scripts.modconfig")
MCM = isModConfigMenuReady(requiredMCM) and requiredMCM or nil
mcmSetupDone = false
mcmSetupAttempted = false


function resolveModConfigMenu()
    if isModConfigMenuReady(MCM) then
        return MCM
    end

    -- MCM may either be returned by require or exposed globally as ModConfigMenu.
    -- Wait until the registration API exists before adding our category.
    local globalMCM = rawget(_G, "ModConfigMenu") or rawget(_G, "MCM")
    if isModConfigMenuReady(globalMCM) then
        MCM = globalMCM
        return MCM
    end

    -- If the first require happened before MCM was available, retry safely.
    if not mcmRequireOk then
        mcmRequireOk, requiredMCM = pcall(require, "scripts.modconfig")
        if isModConfigMenuReady(requiredMCM) then
            MCM = requiredMCM
            return MCM
        end

        globalMCM = rawget(_G, "ModConfigMenu") or rawget(_G, "MCM")
        if isModConfigMenuReady(globalMCM) then
            MCM = globalMCM
            return MCM
        end
    end

    return nil
end

function getMCMOptionType(optionName, fallback)
    local menu = resolveModConfigMenu()
    if menu and menu.OptionType and menu.OptionType[optionName] ~= nil then
        return menu.OptionType[optionName]
    end

    return fallback
end
