local CNH = require("scripts.core.context")
local _ENV = CNH

-- Funcoes de apoio para registrar opcoes no Mod Config Menu com preview,
-- validacao, estado disabled e saveConfig consistentes.

-- =========================================================
-- MCM HELPERS
-- =========================================================

local MCM_FOCUS_GRACE_FRAMES = 3

local function getMCMSelectionName(selection)
    if type(selection) == "table" then
        return selection.Name or selection.name
    end

    if type(selection) == "string" then
        return selection
    end

    return nil
end

function wasCombatNameHUDPreviewTouchedRecently()
    local touchedFrame = state.previewTouchedFrame or -1
    if touchedFrame < 0 then return false end

    return game:GetFrameCount() - touchedFrame <= MCM_FOCUS_GRACE_FRAMES
end

function isCombatNameHUDMCMCategoryActive()
    if not resolveModConfigMenu() or not MCM.IsVisible then return false end

    local categoryName = getMCMSelectionName(MCM.CurrentCategory)
    if categoryName ~= nil then
        return categoryName == MOD_NAME
    end

    -- The original Mod Config Menu keeps its current category/subcategory in
    -- locals instead of exposing CurrentCategory. In that case, the only reliable
    -- signal is our own highlighted Display callback touching preview state.
    return wasCombatNameHUDPreviewTouchedRecently()
end

function isCombatNameHUDMCMInfoActive()
    if not isCombatNameHUDMCMCategoryActive() then return false end

    local subcategoryName = getMCMSelectionName(MCM.CurrentSubcategory)
    if subcategoryName ~= nil then
        return subcategoryName == "Info"
    end

    return false
end

function ensurePreviewNamesForCurrentMCMSession()
    -- Preview names should change when the player enters this mod's MCM page, or
    -- when they press a randomize row. Cursor wrap inside the page must not reset
    -- these names, otherwise moving from last -> first looks like auto-randomize.
    if state.previewNameSessionActive then return end

    RandomizeCombatNameHUDPreviewNames()
    state.previewNameSessionActive = true
end

function activatePreview(owner, effectMode)
    ensurePreviewNamesForCurrentMCMSession()

    local nextEffectMode = effectMode or PREVIEW_EFFECT_MODE.ACTIVE

    if state.previewOwner ~= owner or state.previewEffectMode ~= nextEffectMode then
        state.championPreviewStartFrame = -1
        state.championPreviewIndex = 0
        state.infoShowcaseStartFrame = -1
        state.infoShowcaseSlots = {}
        state.previewEffectStartFrame = game:GetFrameCount()
    end

    state.previewOwner = owner
    state.previewEffectMode = nextEffectMode
    state.previewTouchedFrame = game:GetFrameCount()
end

function setPreview(owner, effectMode, cursorIsAtThisOption)
    -- MCM calls Display for multiple visible options. The first argument tells us
    -- whether this specific row has the cursor, so only highlighted rows activate
    -- preview state.
    if cursorIsAtThisOption ~= true then return end

    activatePreview(owner, effectMode)
end

local function playMCMActionSound()
    pcall(function()
        SFXManager():Play(SoundEffect.SOUND_PLOP, 1, 0, false, 1)
    end)
end

function addActionButton(category, subcategory, labelGetter, previewOwner, callback, previewEffectMode, info)
    -- MCM supports OnSelect even for text rows. That gives us a real action row:
    -- cursor wrap/hover only changes preview, while SELECT/RIGHT runs callback.
    MCM.AddSetting(category, subcategory, {
        Type = getMCMOptionType("TEXT", 1),
        Display = function(cursorIsAtThisOption)
            setPreview(previewOwner, previewEffectMode, cursorIsAtThisOption)
            local label = labelGetter

            if type(labelGetter) == "function" then
                label = labelGetter()
            end

            return tostring(label) .. ": Press"
        end,
        OnSelect = function()
            playMCMActionSound()
            callback()
            setPreview(previewOwner, previewEffectMode, true)
            saveConfig()
        end,
        Info = info and { info } or { "Runs this action immediately." }
    })
end

function addResetButton(category, subcategory, label, previewOwner, callback, info)
    addActionButton(
        category,
        subcategory,
        label,
        previewOwner,
        callback,
        PREVIEW_EFFECT_MODE.ACTIVE,
        info or "Restores this group of settings to its default values."
    )
end

function addBooleanSetting(category, subcategory, key, label, previewOwner, onAfterChange, previewEffectMode, info)
    -- Shared boolean helper keeps preview activation and save behavior consistent
    -- across General/Boss/Enemy menus.
    MCM.AddSetting(category, subcategory, {
        Type = getMCMOptionType("BOOLEAN", 4),
        CurrentSetting = function()
            return config[key]
        end,
        Display = function(cursorIsAtThisOption)
            setPreview(previewOwner, previewEffectMode, cursorIsAtThisOption)
            return label .. ": " .. (config[key] and "True" or "False")
        end,
        OnChange = function(value)
            config[key] = value

            if onAfterChange then
                onAfterChange(value)
            end

            saveConfig()
        end,
        Info = info and { info } or nil
    })
end

function addBossCollapseSetting(category, subcategory)
    MCM.AddSetting(category, subcategory, {
        Type = getMCMOptionType("NUMBER", 5),
        CurrentSetting = function()
            return getBossCollapseSettingValue()
        end,
        Minimum = FIXED_BOSS_VISIBLE_COUNT.ONE,
        Maximum = FIXED_BOSS_VISIBLE_COUNT.ALL,
        ModifyBy = 1,
        Display = function(cursorIsAtThisOption)
            setPreview(PREVIEW_OWNER.BOSS, PREVIEW_EFFECT_MODE.BOSS_COLLAPSE, cursorIsAtThisOption)
            return getBossCollapseSettingLabel()
        end,
        OnChange = function(value)
            setBossCollapseSettingValue(value)
            saveConfig()
        end,
        Info = {
            "Fixed: limits unique boss labels before ... .",
            "Above/below: merges repeated boss parts."
        }
    })
end

function addBossLineSpacingSetting(category, subcategory)
    MCM.AddSetting(category, subcategory, {
        Type = getMCMOptionType("NUMBER", 5),
        CurrentSetting = function()
            return config.bossLineSpacing
        end,
        Minimum = 0,
        Maximum = 20,
        Display = function(cursorIsAtThisOption)
            if config.bossPositionMode ~= POSITION_MODE.FIXED_POSITION then
                if cursorIsAtThisOption == true then
                    state.previewOwner = PREVIEW_OWNER.NONE
                    state.previewEffectMode = PREVIEW_EFFECT_MODE.ACTIVE
                    state.previewEffectStartFrame = -1
                    state.previewTouchedFrame = game:GetFrameCount()
                end

                return "Line spacing: Fixed only"
            end

            setPreview(PREVIEW_OWNER.BOSS, PREVIEW_EFFECT_MODE.BOSS_STACK, cursorIsAtThisOption)
            return "Line spacing: " .. config.bossLineSpacing
        end,
        OnChange = function(value)
            if config.bossPositionMode ~= POSITION_MODE.FIXED_POSITION then return end

            config.bossLineSpacing = value
            saveConfig()
        end,
        Info = {
            "Only active when Boss position is Fixed."
        }
    })
end

function addPreviewReferenceSetting(category, subcategory, key, label, previewOwner, positionModeGetter, onAfterChange)
    MCM.AddSetting(category, subcategory, {
        Type = getMCMOptionType("BOOLEAN", 4),
        CurrentSetting = function()
            if not shouldDrawPreviewReference(positionModeGetter()) then
                return false
            end

            return config[key]
        end,
        Display = function(cursorIsAtThisOption)
            if not shouldDrawPreviewReference(positionModeGetter()) then
                if cursorIsAtThisOption == true then
                    state.previewOwner = PREVIEW_OWNER.NONE
                    state.previewEffectMode = PREVIEW_EFFECT_MODE.ACTIVE
                    state.previewTouchedFrame = game:GetFrameCount()
                end

                return label .. ": Above/below only"
            end

            setPreview(previewOwner, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
            return label .. ": " .. (config[key] and "True" or "False")
        end,
        OnChange = function(value)
            if not shouldDrawPreviewReference(positionModeGetter()) then return end

            config[key] = value

            if onAfterChange then
                onAfterChange(value)
            end

            saveConfig()
        end,
        Info = {
            "Shows the player reference used by above/below previews."
        }
    })
end

function getPreviewReferenceGeneralAvailability()
    local bossAvailable = shouldDrawPreviewReference(config.bossPositionMode)
    local enemyAvailable = shouldDrawPreviewReference(config.enemyPositionMode)

    if bossAvailable and enemyAvailable then
        return true, PREVIEW_OWNER.BOTH, "Boss + Enemy"
    end

    if bossAvailable then
        return true, PREVIEW_OWNER.BOSS, "Boss only"
    end

    if enemyAvailable then
        return true, PREVIEW_OWNER.ENEMY, "Enemy only"
    end

    return false, PREVIEW_OWNER.NONE, "Above/below only"
end

function addGeneralPreviewReferenceSetting(category, subcategory)
    MCM.AddSetting(category, subcategory, {
        Type = getMCMOptionType("BOOLEAN", 4),
        CurrentSetting = function()
            local isAvailable = getPreviewReferenceGeneralAvailability()
            if not isAvailable then return false end

            return config.showPreviewReferenceGeneral
        end,
        Display = function(cursorIsAtThisOption)
            local isAvailable, previewOwner, scopeLabel = getPreviewReferenceGeneralAvailability()

            if not isAvailable then
                if cursorIsAtThisOption == true then
                    state.previewOwner = PREVIEW_OWNER.NONE
                    state.previewEffectMode = PREVIEW_EFFECT_MODE.ACTIVE
                    state.previewEffectStartFrame = -1
                    state.previewTouchedFrame = game:GetFrameCount()
                end

                return "Player reference: Above/below only"
            end

            setPreview(previewOwner, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)
            return "Player reference: "
                .. (config.showPreviewReferenceGeneral and "True" or "False")
                .. " ("
                .. scopeLabel
                .. ")"
        end,
        OnChange = function(value)
            local isAvailable = getPreviewReferenceGeneralAvailability()
            if not isAvailable then return end

            config.showPreviewReferenceGeneral = value
            saveConfig()
        end,
        Info = {
            "Global player reference for above/below previews."
        }
    })
end

function addHpColorSetting(category, subcategory, key, label, previewOwner, textColorModeGetter)
    MCM.AddSetting(category, subcategory, {
        Type = getMCMOptionType("BOOLEAN", 4),
        CurrentSetting = function()
            if textColorModeGetter() ~= TEXT_COLOR_MODE.DEFAULT then
                return false
            end

            return config[key]
        end,
        Display = function(cursorIsAtThisOption)
            if textColorModeGetter() ~= TEXT_COLOR_MODE.DEFAULT then
                if cursorIsAtThisOption == true then
                    state.previewOwner = PREVIEW_OWNER.NONE
                    state.previewEffectMode = PREVIEW_EFFECT_MODE.ACTIVE
                    state.previewEffectStartFrame = -1
                    state.previewTouchedFrame = game:GetFrameCount()
                end

                return label .. ": Default color only"
            end

            setPreview(previewOwner, PREVIEW_EFFECT_MODE.HP_COLOR, cursorIsAtThisOption)
            return label .. ": " .. (config[key] and "True" or "False")
        end,
        OnChange = function(value)
            if textColorModeGetter() ~= TEXT_COLOR_MODE.DEFAULT then return end

            config[key] = value
            saveConfig()
        end,
        Info = {
            "Only active when text color is Default. Shows green, yellow, and red HP color examples in the preview, including hit flash or hit punch if enabled."
        }
    })
end

function addNumberSetting(category, subcategory, labelGetter, currentGetter, minimum, maximum, previewOwner, onChange, previewEffectMode, info)
    -- Shared numeric helper is used for sliders/cyclers exposed by MCM.
    MCM.AddSetting(category, subcategory, {
        Type = getMCMOptionType("NUMBER", 5),
        CurrentSetting = function()
            local value = currentGetter()

            if type(minimum) == "function" then
                return math.max(value, minimum())
            end

            return value
        end,
        Minimum = type(minimum) == "function" and -160 or minimum,
        Maximum = maximum,
        Display = function(cursorIsAtThisOption)
            setPreview(previewOwner, previewEffectMode, cursorIsAtThisOption)
            return labelGetter()
        end,
        OnChange = function(value)
            if type(minimum) == "function" then
                value = math.max(value, minimum())
            end

            onChange(value)
            saveConfig()
        end,
        Info = info and { info } or nil
    })
end

function addHitEffectFramesSetting(category, subcategory)
    MCM.AddSetting(category, subcategory, {
        Type = getMCMOptionType("NUMBER", 5),
        CurrentSetting = function()
            return config.hitEffectFrames
        end,
        Minimum = 1,
        Maximum = 30,
        Display = function(cursorIsAtThisOption)
            if not isHitFeedbackEnabled() then
                if cursorIsAtThisOption == true then
                    state.previewOwner = PREVIEW_OWNER.NONE
                    state.previewEffectMode = PREVIEW_EFFECT_MODE.ACTIVE
                    state.previewEffectStartFrame = -1
                    state.previewTouchedFrame = game:GetFrameCount()
                end

                return "Hit effect frames: Hit feedback only"
            end

            setPreview(PREVIEW_OWNER.BOTH, PREVIEW_EFFECT_MODE.HIT, cursorIsAtThisOption)
            return "Hit effect frames: " .. config.hitEffectFrames
        end,
        OnChange = function(value)
            if not isHitFeedbackEnabled() then return end

            config.hitEffectFrames = value
            saveConfig()
        end,
        Info = {
            "Only available when Hit flash or Hit scale punch is enabled. Controls how long the hit feedback lasts."
        }
    })
end

function addCustomColorChannelSetting(category, subcategory, key, label, previewOwner, colorModeGetter)
    -- RGB sliders are only meaningful when the owner is using Custom RGB. Preset
    -- colors and Rainbow own the final color, so the sliders become read-only.
    MCM.AddSetting(category, subcategory, {
        Type = getMCMOptionType("NUMBER", 5),
        CurrentSetting = function()
            return config[key]
        end,
        Minimum = 0,
        Maximum = 255,
        Display = function(cursorIsAtThisOption)
            setPreview(previewOwner, PREVIEW_EFFECT_MODE.ACTIVE, cursorIsAtThisOption)

            if colorModeGetter() ~= TEXT_COLOR_MODE.CUSTOM_RGB then
                return label .. ": Custom RGB only"
            end

            return label .. ": " .. config[key]
        end,
        OnChange = function(value)
            if colorModeGetter() ~= TEXT_COLOR_MODE.CUSTOM_RGB then return end

            config[key] = value
            saveConfig()
        end,
        Info = {
            "Only active when this label's Text color is Custom RGB."
        }
    })
end

