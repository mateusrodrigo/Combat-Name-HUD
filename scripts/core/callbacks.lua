local CNH = require("scripts.core.context")
local _ENV = CNH

-- Callbacks do Isaac. Este arquivo deve ficar fino: ele so conecta eventos do
-- jogo com funcoes ja definidas nos modulos de estado, tracking e render.

-- =========================================================
-- CALLBACKS
-- =========================================================

CombatNameHUD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    -- New runs can happen without reloading Lua. Re-arm MCM registration so a
    -- restart/rerun cannot leave the category removed while mcmSetupDone is true.
    math.randomseed(os.time())
    mcmSetupDone = false
    mcmSetupAttempted = false

    loadConfig()
    resetPreviewBuild()
    setupModConfigMenu()
end)

CombatNameHUD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    -- Room-local combat state should not leak between rooms.
    resetRoomState()
end)

CombatNameHUD:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    -- Update handles data gathering and state expiry. Rendering is kept separate
    -- in MC_POST_RENDER.
    buildPreviewNamePoolsStep(700)

    if not mcmSetupDone then
        setupModConfigMenu()
    end

    updatePreviewState()
    updateBossTracking()
    updateEnemyState()
end)

CombatNameHUD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    -- All visible text and preview reference drawing happens here.
    renderNames()
end)

CombatNameHUD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, countdown)
    -- Damage events are used as signals for enemy reveal and reactive shake.
    onEntityTakeDamage(entity, amount, flags, source, countdown)
end)

CombatNameHUD:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
    -- Persist settings. Do not remove the MCM category here: restart/rerun can
    -- fire this without reloading Lua, which would make the menu disappear until
    -- the whole mod is reloaded.
    saveConfig()
end)
