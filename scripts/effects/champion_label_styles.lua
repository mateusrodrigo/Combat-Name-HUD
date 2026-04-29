-- Champion label styling data. Kept outside main.lua so the render/update code
-- can focus on behavior while this file owns champion identity tuning.
local ChampionLabelStyles = {}

function ChampionLabelStyles.create(ACTIVE_LABEL_EFFECT, DEATH_LABEL_EFFECT)
    return {
        [0]  = { id = 0,  enum = "RED",           label = "Brute",       color = KColor(0.898, 0.039, 0.043, 1),  colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.PULSE,     deathEffect = DEATH_LABEL_EFFECT.RING_BURST },
        [1]  = { id = 1,  enum = "YELLOW",        label = "Swift",       color = KColor(0.537, 0.475, 0.004, 1),  colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.NERVOUS,   deathEffect = DEATH_LABEL_EFFECT.PHASE_OUT },
        [2]  = { id = 2,  enum = "GREEN",         label = "Toxic",       color = KColor(0.055, 0.624, 0.133, 1),  colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.LETTER_WAVE, deathEffect = DEATH_LABEL_EFFECT.DISSOLVE },
        [3]  = { id = 3,  enum = "ORANGE",        label = "Greed",       color = KColor(0.898, 0.471, 0.137, 1),  colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.PULSE_BOB, deathEffect = DEATH_LABEL_EFFECT.COIN_FLIP },
        [4]  = { id = 4,  enum = "BLUE",          label = "Slowed",      color = KColor(0.275, 0.255, 0.95, 1),   colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.BREATHING, deathEffect = DEATH_LABEL_EFFECT.IMPLODE },
        [5]  = { id = 5,  enum = "BLACK",         label = "Volatile",    color = KColor(0.18, 0.32, 0.30, 1),     colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.PULSE,     deathEffect = DEATH_LABEL_EFFECT.EXPLODE },
        [6]  = { id = 6,  enum = "WHITE",         label = "Untouchable", color = KColor(1, 0.996, 0.996, 1),      colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.ORBIT,     deathEffect = DEATH_LABEL_EFFECT.SPLIT_GHOST },
        [7]  = { id = 7,  enum = "GREY",          label = "Weakened",    color = KColor(0.447, 0.384, 0.388, 1),  colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.BREATHING, deathEffect = DEATH_LABEL_EFFECT.SHRINK },
        [8]  = { id = 8,  enum = "TRANSPARENT",   label = "Phantom",     color = KColor(1, 1, 1, 0.5),            colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.FLICKER,   deathEffect = DEATH_LABEL_EFFECT.PHASE_OUT },
        [9]  = { id = 9,  enum = "FLICKER",       label = "Flicker",     color = KColor(0.28, 0.28, 0.28, 1),     colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.FLICKER,   deathEffect = DEATH_LABEL_EFFECT.PHASE_OUT },
        [10] = { id = 10, enum = "PINK",          label = "Spitter",     color = KColor(0.898, 0.004, 0.776, 1),  colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.WIGGLE,    deathEffect = DEATH_LABEL_EFFECT.RING_BURST },
        [11] = { id = 11, enum = "PURPLE",        label = "Gravitic",    color = KColor(0.675, 0, 0.776, 1),      colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.MAGNET,    deathEffect = DEATH_LABEL_EFFECT.IMPLODE },
        [12] = { id = 12, enum = "DARK_RED",      label = "Undying",     color = KColor(0.62, 0.08, 0.08, 1),     colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.PULSE,     deathEffect = DEATH_LABEL_EFFECT.RING_BURST },
        [13] = { id = 13, enum = "LIGHT_BLUE",    label = "Bursting",    color = KColor(0.447, 0.388, 0.776, 1),  colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.PULSE_BOB, deathEffect = DEATH_LABEL_EFFECT.RING_BURST },
        [14] = { id = 14, enum = "CAMO",          label = "Hidden",      color = KColor(0.32, 0.36, 0.28, 0.7),   colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.FLICKER,   deathEffect = DEATH_LABEL_EFFECT.PHASE_OUT },
        [15] = { id = 15, enum = "PULSE_GREEN",   label = "Splitter",    color = KColor(0.055, 0.624, 0.133, 1),  colorMode = "pulse_tint", activeEffect = ACTIVE_LABEL_EFFECT.PULSE,     deathEffect = DEATH_LABEL_EFFECT.SPLIT_GHOST, tintStrength = 0.85 },
        [16] = { id = 16, enum = "PULSE_GREY",    label = "Reflective",  color = KColor(0.447, 0.384, 0.388, 1),  colorMode = "pulse_tint", activeEffect = ACTIVE_LABEL_EFFECT.PULSE_BOB, deathEffect = DEATH_LABEL_EFFECT.SPLIT_GHOST, tintStrength = 0.8 },
        [17] = { id = 17, enum = "FLY_PROTECTED", label = "Swarmed",     colorMode = "preserve", activeEffect = ACTIVE_LABEL_EFFECT.ORBIT,   deathEffect = DEATH_LABEL_EFFECT.PHASE_OUT },
        [18] = { id = 18, enum = "TINY",          label = "Tiny",        colorMode = "preserve", activeEffect = ACTIVE_LABEL_EFFECT.NERVOUS, deathEffect = DEATH_LABEL_EFFECT.SHRINK, scaleMultiplier = 0.72 },
        [19] = { id = 19, enum = "GIANT",         label = "Colossus",    colorMode = "preserve", activeEffect = ACTIVE_LABEL_EFFECT.HEAVY,   deathEffect = DEATH_LABEL_EFFECT.DROP_SQUASH, scaleMultiplier = 1.28 },
        [20] = { id = 20, enum = "PULSE_RED",     label = "Healer",      color = KColor(0.898, 0.039, 0.043, 1),  colorMode = "pulse_tint", activeEffect = ACTIVE_LABEL_EFFECT.PULSE,     deathEffect = DEATH_LABEL_EFFECT.RING_BURST, tintStrength = 0.85 },
        [21] = { id = 21, enum = "SIZE_PULSE",    label = "Infested",    colorMode = "preserve", activeEffect = ACTIVE_LABEL_EFFECT.PULSE_BOB, deathEffect = DEATH_LABEL_EFFECT.RING_BURST, scalePulseAmount = 0.16, scalePulseSpeed = 0.1 },
        [22] = { id = 22, enum = "KING",          label = "King",        color = KColor(1, 0.85, 0.2, 1),         colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.ORBIT,     deathEffect = DEATH_LABEL_EFFECT.COIN_SPARK },
        [23] = { id = 23, enum = "DEATH",         label = "Doom",        color = KColor(0.38, 0.38, 0.38, 1),     colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.GLITCH,    deathEffect = DEATH_LABEL_EFFECT.NECRO_FADE },
        [24] = { id = 24, enum = "BROWN",         label = "Filthy",      color = KColor(0.42, 0.22, 0.18, 1),     colorMode = "override",   activeEffect = ACTIVE_LABEL_EFFECT.DRIFT,     deathEffect = DEATH_LABEL_EFFECT.DROP_DOWN },
        [25] = { id = 25, enum = "RAINBOW",       label = "Chaos",       colorMode = "rainbow",  activeEffect = ACTIVE_LABEL_EFFECT.WAVE,      deathEffect = DEATH_LABEL_EFFECT.RING_BURST, rainbow = true }
    }
end

return ChampionLabelStyles
