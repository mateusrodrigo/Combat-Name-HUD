local CNH = require("scripts.core.context")
local _ENV = CNH

-- Tracking do inimigo comum atualmente destacado: cria, atualiza e limpa o label
-- temporario disparado quando o jogador causa dano em um inimigo nao-boss.
clearEnemyName = function(spawnDeathEffect)
    -- Clearing an enemy usually just removes the temporary label. Death effects
    -- are reserved for real deaths, not timeouts, target switches, or labels
    -- naturally leaving the HUD.
    if spawnDeathEffect and state.enemyName ~= nil and state.enemyName ~= "" then
        local label = createRenderableLabel(LABEL_OWNER.ENEMY, state.enemyEntity, state.enemyName, state.enemyShakeUntilFrame, false)
        applyChampionStyleToLabel(label, state.enemyChampionStyle)

        if label == nil then
            label = createRenderableLabelAtWorldPosition(
                LABEL_OWNER.ENEMY,
                state.enemyName,
                state.enemyLastWorldPosition,
                state.enemyShakeUntilFrame,
                state.enemyChampionDescriptorStyle
            )
            applyChampionStyleToLabel(label, state.enemyChampionStyle)
        end

        spawnDeathLabelFromRenderable(label)
    end

    state.enemyEntity = nil
    state.enemyName = nil
    state.enemyChampionStyle = nil
    state.enemyChampionDescriptorStyle = nil
    state.enemyLastWorldPosition = nil
    state.enemyDisplayUntilFrame = 0
    state.enemyShakeUntilFrame = 0
    state.enemyHitUntilFrame = 0
end

function trackEnemyLabel(npc)
    if npc == nil then return false end
    if not config.showEnemyName then return false end

    local enemyName = getEntityName(npc)

    if enemyName == nil or enemyName == "" then return false end

    local championDescriptorStyle = getChampionStyle(npc)
    removeDeathLabelsForEnemy(npc, formatLabelText(LABEL_OWNER.ENEMY, enemyName, championDescriptorStyle))

    if config.enemyPositionMode == POSITION_MODE.FIXED_POSITION
        and (
            state.enemyEntity == nil
            or state.enemyEntity.InitSeed ~= npc.InitSeed
        )
    then
        local remaining = {}

        for _, deathLabel in ipairs(state.deathLabels) do
            if deathLabel.owner ~= LABEL_OWNER.ENEMY then
                table.insert(remaining, deathLabel)
            end
        end

        state.deathLabels = remaining
    end

    state.enemyEntity = npc
    state.enemyName = enemyName
    state.enemyChampionStyle = getChampionLabelStyle(npc)
    state.enemyChampionDescriptorStyle = championDescriptorStyle
    state.enemyLastWorldPosition = getEntityWorldPosition(npc) or state.enemyLastWorldPosition
    state.enemyDisplayUntilFrame = game:GetFrameCount() + config.enemyDisplayFrames
    state.enemyHitUntilFrame = game:GetFrameCount() + config.hitEffectFrames

    return true
end

function updateEnemyState()
    -- The common enemy label is intentionally temporary and self-clearing.
    if state.enemyEntity == nil then return end

    state.enemyLastWorldPosition = getEntityWorldPosition(state.enemyEntity) or state.enemyLastWorldPosition

    if isEntityActuallyDead(state.enemyEntity) then
        clearEnemyName(true)
        return
    end

    local shouldHide = game:GetRoom():IsClear()
        or not config.showEnemyName
        or not safeExists(state.enemyEntity)
        or game:GetFrameCount() > state.enemyDisplayUntilFrame

    if shouldHide then
        clearEnemyName(false)
    end
end
