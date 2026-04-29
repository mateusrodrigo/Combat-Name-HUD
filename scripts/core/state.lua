local CNH = require("scripts.core.context")
local _ENV = CNH

-- Estado runtime nao salvo. Guarda preview, sala atual, bosses, inimigo ativo,
-- caches e labels de morte que sobrevivem ao frame em que a entidade morreu.
-- =========================================================
-- ESTADO INTERNO
-- =========================================================

-- Runtime-only state. None of this is saved; it is rebuilt from the room, MCM,
-- and entity callbacks. Keeping this separate from config avoids old combat data
-- surviving a save/load cycle.
state = {
    -- Preview is deliberately temporary. MCM Display callbacks refresh it only
    -- while the cursor is on a setting that should show a preview.
    previewOwner = PREVIEW_OWNER.NONE,
    previewEffectMode = PREVIEW_EFFECT_MODE.ACTIVE,
    previewEffectStartFrame = -1,
    previewTouchedFrame = -1,
    previewNameSessionActive = false,
    championPreviewStartFrame = -1,
    championPreviewIndex = 0,
    infoShowcaseStartFrame = -1,
    infoShowcaseSlots = {},

    -- Bosses are stored by InitSeed and ordered separately so multi-boss rooms
    -- render consistently.
    fightStarted = false,

    bosses = {},
    bossOrder = {},
    bossActiveByGroup = {},

    -- Common enemy labels are temporary: they appear when the player damages an
    -- enemy and clear on timeout, death, room clear, or config changes.
    enemyEntity = nil,
    enemyName = nil,
    enemyChampionStyle = nil,
    enemyChampionDescriptorStyle = nil,
    enemyLastWorldPosition = nil,
    enemyDisplayUntilFrame = 0,
    enemyShakeUntilFrame = 0,
    enemyHitUntilFrame = 0,

    -- Preview name pools are built incrementally so opening the game does not do
    -- a large EntityConfig scan in one frame.
    bossPreviewName = nil,
    enemyPreviewName = nil,
    bossCollapsePreviewNames = {},
    previewRandomSeed = nil,
    previewRandomCounter = 0,

    bossPreviewNames = {},
    enemyPreviewNames = {},
    bossPreviewNameSet = {},
    enemyPreviewNameSet = {},

    previewBuildDone = false,
    previewBuildType = 1,
    previewBuildVariant = 0,
    previewBuildMaxType = 1000,
    previewBuildMaxVariant = 50,

    -- nameCache avoids repeated EntityConfig lookups during combat. deathLabels are
    -- detached render copies used for fade/float/shrink/explode/etc.
    nameCache = {},
    deathLabels = {}
}

clearRuntimeLabels = function()
    -- Config changes can make existing detached labels stale, especially when
    -- prefixes, colors, position modes, or champion styling change mid-room.
    state.deathLabels = {}
    state.previewOwner = PREVIEW_OWNER.NONE
    state.previewEffectMode = PREVIEW_EFFECT_MODE.ACTIVE
    state.previewEffectStartFrame = -1
    state.previewTouchedFrame = -1
    state.championPreviewStartFrame = -1
    state.championPreviewIndex = 0
    state.infoShowcaseStartFrame = -1
    state.infoShowcaseSlots = {}

    if clearEnemyName then
        clearEnemyName(false)
    else
        state.enemyEntity = nil
        state.enemyName = nil
        state.enemyChampionStyle = nil
        state.enemyChampionDescriptorStyle = nil
        state.enemyLastWorldPosition = nil
        state.enemyDisplayUntilFrame = 0
        state.enemyShakeUntilFrame = 0
        state.enemyHitUntilFrame = 0
    end
end
