local CNH = require("scripts.core.context")
local _ENV = CNH

-- Estado de sala. Limpa rastreamento de combate quando uma nova sala comeca.
function resetRoomState()
    -- Room changes wipe combat tracking. Death labels are room-local too, because a
    -- floating death label from the previous room would feel wrong.
    state.fightStarted = false
    state.bosses = {}
    state.bossOrder = {}
    state.bossActiveByGroup = {}
    state.deathLabels = {}

    clearEnemyName(false)
end
