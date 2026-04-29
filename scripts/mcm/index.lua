local CNH = require("scripts.core.context")
local _ENV = CNH

-- Orquestrador do Mod Config Menu. Cada aba registra seu proprio grupo de
-- opcoes; este arquivo so atualiza a categoria, chama as abas e faz fallback.

function registerModConfigMenuOptions()
    local mcmName = MOD_NAME

    if MCM.UpdateCategory then
        pcall(function()
            MCM.UpdateCategory(mcmName, {
                Info = {
                    "Displays enemy and boss names with customizable visuals."
                }
            })
        end)
    end

    registerMCMInfoPage(mcmName)
    registerMCMGeneralPage(mcmName)
    registerMCMBossPage(mcmName)
    registerMCMEnemyPage(mcmName)
end
function registerFallbackModConfigMenu(errorMessage)
    local mcmName = MOD_NAME

    pcall(function()
        MCM.RemoveCategory(mcmName)
    end)

    pcall(function()
        if MCM.UpdateCategory then
            MCM.UpdateCategory(mcmName, {
                Info = {
                    "Combat Name HUD loaded, but the full settings menu failed to register."
                }
            })
        end

        MCM.AddText(mcmName, "Info", function()
            return MOD_NAME
        end)

        MCM.AddText(mcmName, "Info", function()
            return "Version " .. VERSION
        end)

        MCM.AddText(mcmName, "Info", function()
            return "MCM setup failed. Check log.txt."
        end)

        MCM.AddText(mcmName, "Info", function()
            return tostring(errorMessage)
        end)
    end)
end

function setupModConfigMenu()
    if mcmSetupDone then return true end
    if not resolveModConfigMenu() then return false end

    -- Remove the old category only once, right before the first full registration
    -- attempt. Repeated RemoveCategory calls can erase a partial/fallback menu if
    -- a later setting errors every frame.
    if not mcmSetupAttempted then
        pcall(function()
            MCM.RemoveCategory(MOD_NAME)
        end)
        mcmSetupAttempted = true
    end

    local ok, err = pcall(registerModConfigMenuOptions)
    if not ok then
        Isaac.DebugString("[Combat Name HUD] Mod Config Menu setup failed: " .. tostring(err))
        registerFallbackModConfigMenu(err)
        mcmSetupDone = true
        return false
    end

    mcmSetupDone = true
    return true
end
