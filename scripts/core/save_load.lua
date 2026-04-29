local CNH = require("scripts.core.context")
local _ENV = CNH

-- Persistencia da config. So opcoes do jogador sao salvas; estado de combate e
-- previews continuam runtime-only.
-- =========================================================
-- SAVE / LOAD
-- =========================================================


function saveConfig()
    -- Only config is serialized. Combat labels, preview state, and caches are
    -- intentionally runtime-only.
    CombatNameHUD:SaveData(json.encode(config))
end

function loadConfig()
    if not CombatNameHUD:HasData() then return end

    local ok, savedConfig = pcall(function()
        return json.decode(CombatNameHUD:LoadData())
    end)

    if not ok or not savedConfig then return end

    -- Copy only valid saved keys into the active config.
    for key, value in pairs(savedConfig) do
        if config[key] ~= nil then
            config[key] = value
        end
    end

    clearRuntimeLabels()
end
