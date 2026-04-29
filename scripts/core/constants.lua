local CNH = require("scripts.core.context")
local _ENV = CNH

-- Constantes e enums compartilhados pelo mod. Tambem carrega tabelas de efeitos
-- usadas como IDs salvos na config e aplicadas pelo render.
MOD_NAME = "Combat Name HUD"
VERSION = "1.0.0"

-- =========================================================
-- ENUMS
-- =========================================================

-- Label owners are intentionally strings because they are also saved in transient
-- render data. The owner decides which config group and prefix a label uses.
LABEL_OWNER = {
    BOSS = "boss",
    ENEMY = "enemy"
}

-- Position modes are exposed directly in Mod Config Menu as numeric options.
-- Fixed is screen-space; above/below can follow real entities or MCM previews.
POSITION_MODE = {
    FIXED_POSITION = 1,
    ABOVE_ENTITY = 2,
    BELOW_ENTITY = 3
}

ActiveEffects = require("scripts.effects.active_effects")
ACTIVE_LABEL_EFFECT = ActiveEffects.ID

-- Text color modes are separate from active effects. This lets players combine a
-- static/custom/rainbow font color with motion effects like bob or wave.
TEXT_COLOR_MODE = {
    DEFAULT = 1,
    CUSTOM_RGB = 2,
    WHITE = 3,
    RED = 4,
    GREEN = 5,
    BLUE = 6,
    YELLOW = 7,
    CYAN = 8,
    MAGENTA = 9,
    RAINBOW = 10
}

CHAMPION_DESCRIPTOR_MODE = {
    DISABLED = 1,
    LABEL = 2,
    ENUM = 3
}

DeathEffects = require("scripts.effects.death_effects")
DEATH_LABEL_EFFECT = DeathEffects.ID

IntroEffects = require("scripts.effects.intro_effects")
BOSS_INTRO_EFFECT = IntroEffects.ID

local championStylesLoaded, championStylesModule = pcall(require, "scripts.effects.champion_label_styles")
CHAMPION_LABEL_STYLE = {}

if championStylesLoaded
    and type(championStylesModule) == "table"
    and type(championStylesModule.create) == "function"
then
    local stylesCreated, styles = pcall(function()
        return championStylesModule.create(ACTIVE_LABEL_EFFECT, DEATH_LABEL_EFFECT)
    end)

    if stylesCreated and type(styles) == "table" then
        CHAMPION_LABEL_STYLE = styles
    end
end

if CHAMPION_LABEL_STYLE[0] == nil then
    CHAMPION_LABEL_STYLE[0] = {
        id = 0,
        enum = "RED",
        label = "Champion",
        color = KColor(0.898, 0.039, 0.043, 1),
        colorMode = "override",
        activeEffect = ACTIVE_LABEL_EFFECT.PULSE,
        deathEffect = DEATH_LABEL_EFFECT.RING_BURST
    }
end

-- MCM preview routing. Display callbacks activate one of these owners only for
-- the currently highlighted option, then updatePreviewState expires it.
PREVIEW_OWNER = {
    NONE = 0,
    BOSS = 1,
    ENEMY = 2,
    BOTH = 3
}

-- A highlighted option can preview the normal active label or one focused
-- visual state such as death, champion, hit, or shake feedback.
PREVIEW_EFFECT_MODE = {
    ACTIVE = 1,
    DEATH = 2,
    CHAMPION = 3,
    HIT = 4,
    SHAKE = 5,
    HP_COLOR = 6,
    BOSS_INTRO = 7,
    BOSS_STACK = 8,
    BOSS_COLLAPSE = 9,
    INFO_SHOWCASE = 10
}

FIXED_BOSS_VISIBLE_COUNT = {
    ONE = 1,
    TWO = 2,
    THREE = 3,
    ALL = 4
}
