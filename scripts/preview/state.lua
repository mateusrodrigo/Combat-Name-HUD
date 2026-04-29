local CNH = require("scripts.core.context")
local _ENV = CNH

-- Estado transiente dos previews do MCM. Remove nomes/efeitos de preview quando
-- o menu fecha ou quando nenhuma opcao atualizou o preview no frame recente.
function updatePreviewState()
    if not resolveModConfigMenu() then return end

    -- Closing MCM should immediately remove preview-only names and restore normal
    -- combat rendering.
    if not MCM.IsVisible then
        state.previewOwner = PREVIEW_OWNER.NONE
        state.previewEffectMode = PREVIEW_EFFECT_MODE.ACTIVE
        state.previewEffectStartFrame = -1
        state.previewTouchedFrame = -1
        state.previewNameSessionActive = false
        state.championPreviewStartFrame = -1
        state.championPreviewIndex = 0
        state.infoShowcaseStartFrame = -1
        state.infoShowcaseSlots = {}
        state.bossPreviewName = nil
        state.enemyPreviewName = nil
        state.bossCollapsePreviewNames = {}
        return
    end

    if not isCombatNameHUDMCMCategoryActive() then
        state.previewOwner = PREVIEW_OWNER.NONE
        state.previewEffectMode = PREVIEW_EFFECT_MODE.ACTIVE
        state.previewEffectStartFrame = -1
        state.previewTouchedFrame = -1
        state.previewNameSessionActive = false
        state.championPreviewStartFrame = -1
        state.championPreviewIndex = 0
        state.infoShowcaseStartFrame = -1
        state.infoShowcaseSlots = {}
        state.bossPreviewName = nil
        state.enemyPreviewName = nil
        state.bossCollapsePreviewNames = {}
        return
    end

    -- The Info page has no real configurable row, so its showcase cannot rely on
    -- a highlighted setting. Keep it alive while that subcategory is selected.
    if isCombatNameHUDMCMInfoActive() then
        activatePreview(PREVIEW_OWNER.BOTH, PREVIEW_EFFECT_MODE.INFO_SHOWCASE)
        return
    end

    -- If no highlighted MCM option refreshed the preview last frame, expire it.
    -- Keep preview names stable while the player is still inside our MCM page:
    -- MCM cursor wrap can briefly skip a preview refresh, and clearing names here
    -- would look like the randomize row fired by itself.
    if state.previewTouchedFrame < game:GetFrameCount() - 1 then
        state.previewOwner = PREVIEW_OWNER.NONE
        state.previewEffectMode = PREVIEW_EFFECT_MODE.ACTIVE
        state.previewEffectStartFrame = -1
        state.championPreviewStartFrame = -1
        state.championPreviewIndex = 0
        state.infoShowcaseStartFrame = -1
        state.infoShowcaseSlots = {}
    end
end
