local CNH = require("scripts.core.context")
local _ENV = CNH

-- Aba Info do Mod Config Menu.

local function addInfoPreviewText(mcmName, textGetter)
    -- Info is a passive page: hovering the Info subcategory should run the
    -- showcase, but the text rows themselves should not become clickable options.
    MCM.AddSetting(mcmName, "Info", {
        Type = getMCMOptionType("TEXT", 1),
        NoCursorHere = true,
        Display = function(cursorIsAtThisOption, configMenuInOptions)
            if cursorIsAtThisOption == true or configMenuInOptions == false then
                activatePreview(PREVIEW_OWNER.BOTH, PREVIEW_EFFECT_MODE.INFO_SHOWCASE)
            end

            return textGetter()
        end
    })
end

function registerMCMInfoPage(mcmName)
    addInfoPreviewText(mcmName, function()
        return MOD_NAME
    end)

    addInfoPreviewText(mcmName, function()
        return "Version " .. VERSION
    end)

    addInfoPreviewText(mcmName, function()
        return "By Daft Fox"
    end)
    MCM.AddSpace(mcmName, "Info")
end
