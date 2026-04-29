local CNH = require("scripts.core.context")
local _ENV = CNH

-- Geracao dos nomes usados nos previews do MCM. A lista vanilla curada garante
-- variedade sem REPENTOGON; EntityConfig/XMLData so complementam quando existem.

-- =========================================================
-- PREVIEW DE NOMES
-- =========================================================

local DEFAULT_BOSS_PREVIEW_NAMES = {
    "Monstro",
    "Gemini",
    "Steven",
    "Dingle",
    "Gurglings",
    "Larry Jr",
    "The Duke Of Flies",
    "Widow",
    "Blighted Ovum",
    "The Haunt",
    "Pin",
    "Famine",
    "Fistula",
    "Chub",
    "C.H.A.D.",
    "Gurdy",
    "Mega Fatty",
    "Mega Maw",
    "Gurdy Jr",
    "Peep",
    "The Husk",
    "The Hollow",
    "Carrion Queen",
    "Dark One",
    "Polycephalus",
    "The Wretched",
    "Pestilence",
    "Monstro II",
    "Gish",
    "The Cage",
    "The Gate",
    "Loki",
    "The Adversary",
    "The Bloat",
    "Mask Of Infamy",
    "War",
    "Blastocyst",
    "Mama Gurdy",
    "Scolex",
    "Mr. Fred",
    "Lokii",
    "Daddy Long Legs",
    "Triachnid",
    "Teratoma",
    "Death",
    "Conquest",
    "Headless Horseman",
    "The Fallen",
    "Dangle",
    "Turdlings",
    "Little Horn",
    "Rag Man",
    "The Stain",
    "The Forsaken",
    "The Frail",
    "Brownie",
    "Big Horn",
    "Rag Mega",
    "Sisters Vis",
    "The Matriarch",
    "Baby Plum",
    "Bumbino",
    "Reap Creep",
    "The Pile",
    "The Rainmaker",
    "Min-Min",
    "Lil Blub",
    "Wormwood",
    "Clog",
    "Colostomia",
    "Turdlet",
    "Tuff Twins",
    "Hornfel",
    "Great Gideon",
    "Singe",
    "The Shell",
    "Clutch",
    "The Siren",
    "The Heretic",
    "The Visage",
    "The Horny Boys",
    "Chimera",
    "The Scourge",
    "Rotgut",
    "Ultra Famine",
    "Ultra Pestilence",
    "Ultra War",
    "Ultra Death",
    "Mom",
    "Mom's Heart",
    "It Lives",
    "Satan",
    "Isaac",
    "The Lamb",
    "???",
    "Mega Satan",
    "Hush",
    "Delirium",
    "Mother",
    "Dogma",
    "The Beast",
    "Ultra Greed",
    "Ultra Greedier",

    -- Seven Deadly Sins
    "Envy",
    "Gluttony",
    "Wrath",
    "Pride",
    "Lust",
    "Greed",
    "Sloth",

    -- Super Deadly Sins
    "Super Envy",
    "Super Gluttony",
    "Super Wrath",
    "Super Pride",
    "Super Lust",
    "Super Greed",
    "Super Sloth",

    -- Extras
    "Ultra Pride",
    "Krampus",

    -- Angels
    "Uriel",
    "Gabriel",

    -- Fallen Angels
    "Fallen Uriel",
    "Fallen Gabriel",

    -- Repentance especiais
    "Mother's Shadow",
    "Dark Esau"
}

local DEFAULT_ENEMY_PREVIEW_NAMES = {
    "Frowning Gaper",
    "Gaper",
    "Flaming Gaper",
    "Rotten Gaper",
    "Gurgle",
    "Crackle",
    "Nulls",
    "Cyclopia",
    "Blue Gaper",
    "Greed Gaper",
    "Wraith",
    "Deep Gaper",
    "Blurb",
    "Level 2 Gaper",
    "Level 2 Horf",
    "Level 2 Gusher",
    "Twitchy",
    "Dead Isaac",
    "Faceless",
    "Tainted Faceless",
    "Exorcist",
    "Fanatic",
    "Candler",
    "Dump",
    "Dump Head",
    "Gusher",
    "Pacer",
    "Splasher",
    "Black Globin's Body",
    "Horf",
    "Psychic Horf",
    "Sub Horf",
    "Tainted Sub Horf",
    "Necro",
    "Fly",
    "Attack Fly",
    "Moter",
    "Eternal Fly",
    "Ring Fly",
    "Dart Fly",
    "Swarm",
    "Hush Fly",
    "Willo",
    "Army Fly",
    "Ultra Famine Fly",
    "Ultra Pestilence Fly",
    "Fly Bomb",
    "Eternal Fly Bomb",
    "Sucker",
    "Spit",
    "Ink",
    "Soul Sucker",
    "Mama Fly",
    "Bulb",
    "Bloodfly",
    "Tainted Sucker",
    "Pooter",
    "Super Pooter",
    "Tainted Pooter",
    "Clotty",
    "Clot",
    "I.Blob",
    "Grilled Clotty",
    "Cloggy",
    "Mulligan",
    "Mulligoon",
    "Mulliboom",
    "Hive",
    "Drowned Hive",
    "Holy Mulligan",
    "Tainted Mulligan",
    "Nest",
    "Leper",
    "Leper Flesh",
    "Prey",
    "Mullighoul",
    "Bouncer",
    "Gas Dwarf",
    "Danny",
    "Coal Boy",
    "Blaster",
    "Maggot",
    "Charger",
    "My Shadow",
    "Drowned Charger",
    "Dank Charger",
    "Carrion Princess",
    "Small Leech",
    "Small Maggot",
    "Level 2 Charger",
    "Elleech",
    "Blood Puppy",
    "Spitty",
    "Tainted Spitty",
    "Conjoined Spitty",
    "Globin",
    "Gazing Globin",
    "Dank Globin",
    "Cursed Globin",
    "Black Globin",
    "Clickety Clack",
    "Gasbag",
    "Cohort",
    "Boom Fly",
    "Red Boom Fly",
    "Drowned Boom Fly",
    "Dragon Fly",
    "Dragon Fly X",
    "Bone Fly",
    "Sick Boom Fly",
    "Tainted Boom Fly",
    "Maw",
    "Red Maw",
    "Psychic Maw",
    "Host",
    "Red Host",
    "Hard Host",
    "Mobile Host",
    "Flesh Mobile Host",
    "Floast",
    "Mushroom",
    "Hopper",
    "Eggy",
    "Tainted Hopper",
    "Leaper",
    "Sticky Leaper",
    "Flaming Hopper",
    "Trite",
    "Ragling",
    "Rag Man's Ragling",
    "Blister",
    "Boil",
    "Gut",
    "Sack",
    "Blue Boil",
    "Gush",
    "Pustule",
    "Walking Boil",
    "Walking Gut",
    "Walking Sack",
    "Brain",
    "Black Globin's Head",
    "Festering Guts",
    "Poison Mind",
    "Pon",
    "Gyro",
    "Grilled Gyro",
    "Mr. Maw",
    "Mr. Red Maw",
    "Swinger",
    "Mr. Mine",
    "Baby",
    "Angelic Baby",
    "Angelic Baby (small)",
    "Wrinkly Baby",
    "Imp",
    "Unborn",
    "Baby Begotten",
    "Vis",
    "Double Vis",
    "Chubber",
    "Scarred Double Vis",
    "Vis Versa",
    "Evis",
    "Guts",
    "Scarred Guts",
    "Slog",
    "Cyst",
    "Knight",
    "Selfless Knight",
    "Loose Knight",
    "Brainless Knight",
    "Black Knight",
    "Floating Knight",
    "Bone Knight",
    "Whipper",
    "Snapper",
    "Flagellant",
    "Dople",
    "Evil Twin",
    "Leech",
    "Kamikaze Leech",
    "Holy Leech",
    "Adult Leech",
    "Lump",
    "Tar Boy",
    "MemBrain",
    "Mama Guts",
    "Dead Meat",
    "Dinga",
    "Mega Clotty",
    "Para-Bite",
    "Scarred Para-Bite",
    "Fred",
    "Eye",
    "Bloodshot Eye",
    "Holy Eye",
    "Embryo",
    "Spider",
    "Big Spider",
    "Strider",
    "Rock Spider",
    "Tinted Rock Spider",
    "Coal Spider",
    "Swarm Spider",
    "Keeper",
    "Buttlicker",
    "Butt Slicker",
    "Hanger",
    "Swarmer",
    "Mask + Heart",
    "Mask II + 1/2 Heart",
    "Baby Long Legs",
    "Small Baby Long Legs",
    "Crazy Long Legs",
    "Small Crazy Long Legs",
    "Fatty",
    "Pale Fatty",
    "Flaming Fatty",
    "Fat Sack",
    "Blubber",
    "Half Sack",
    "Conjoined Fatty",
    "Blue Conjoined Fatty",
    "Stoney",
    "Cross Stoney",
    "Bubbles",
    "Quakey",
    "Big Bony",
    "Gutted Fatty",
    "Gutted Fatty Eye",
    "Peeping Fatty",
    "Peeping Fatty Eye",
    "Bloaty",
    "Vis Fatty",
    "Fetal Demon",
    "Shady",
    "Death's Head",
    "Dank Death's Head",
    "Cursed Death's Head",
    "Brimstone Death's Head",
    "Redskull",
    "Flesh Death's Head",
    "Dusty Death's Head",
    "Ultra Death Head",
    "Mom's Hand",
    "Mom's Dead Hand",
    "Level 2 Fly",
    "Full Fly",
    "Level 2 Willo",
    "Level 2 Spider",
    "Ticking Spider",
    "Migraine",
    "Dip",
    "Corn",
    "Brownie Corn",
    "Big Corn",
    "Drip",
    "Wizoob",
    "Red Ghost",
    "Squirt",
    "Dank Squirt",
    "Hardy",
    "Splurt",
    "Cod Worm",
    "Oob",
    "Black Maw",
    "Skinny",
    "Rotty",
    "Crispy",
    "Bony",
    "Holy Bony",
    "Black Bony",
    "Revenant",
    "Quad Revenant",
    "Maze Roamer",
    "Homunculus",
    "Begotten",
    "Tumor",
    "Planetoid",
    "Camillo Jr.",
    "Psy Tumor",
    "Poofer",
    "Nerve Ending",
    "Nerve Ending 2",
    "Bishop",
    "One Tooth",
    "Fat Bat",
    "Gurgling",
    "Goat",
    "Black Goat",
    "Cultist",
    "Blood Cultist",
    "Grub",
    "Wall Creep",
    "Soy Creep",
    "Tainted Soy Creep",
    "Rage Creep",
    "Blind Creep",
    "The Thing",
    "Round Worm",
    "Tube Worm",
    "Tainted Round Worm",
    "Tainted Tube Worm",
    "Night Crawler",
    "Roundy",
    "Ulcer",
    "Fire Worm",
    "Mole",
    "Tainted Mole",
    "Lil' Haunt",
    "Polty",
    "Kineti",
    "Dust",
    "Dukie",
    "Meatball",
    "Ministro",
    "Fistuloid",
    "Fly Trap",
    "Poot Mine",
    "Bombgagger",
    "Flesh Maiden",
    "Morningstar",
    "Needle",
    "Pasty",
    "Fissure",
    "Portal",
    "Lil Portal",
    "Henry",
    "Stone Grimace",
    "Vomit Grimace",
    "Triple Grimace",
    "Stone Eye",
    "Constant Stone Shooter",
    "Cross Stone Shooter",
    "Brimstone Head",
    "Gaping Maw",
    "Broken Gaping Maw",
    "Quake Grimace",
    "Bomb Grimace",
    "Peep Eye",
    "Bloat Eye",
    "Mockulus",
    "Poky",
    "Slide",
    "Wall Hugger",
    "Grudge",
    "Ball and Chain",
    "Spikeball",
    "Singe's Ball",
    "Pitfall",
    "Suction Pitfall",
    "Teleport Pitfall",
    "Death Scythe",
    "Ultra Death Scythe",
    "Corn Mine",
    "Siren Minion",
    "Siren Helper",
    "Dark Ball",
    "Purple Ball",
    "Visage Plasma",
    "Ultra Pestilence Fly Ball",
    "Ultra Greed Coin (Spinner)",
    "Ultra Greed Coin (Key)",
    "Ultra Greed Coin (Bomb)",
    "Ultra Greed Coin (Heart)",
    "Dummy"
}

local function getPreviewRandomIndex(size)
    if size <= 1 then return 1 end

    state.previewRandomCounter = (state.previewRandomCounter or 0) + 1

    local frame = 0
    if game and game.GetFrameCount then
        frame = game:GetFrameCount()
    end

    local timeSeed = 0
    if os and os.time then
        timeSeed = os.time()
    end

    local seed = state.previewRandomSeed
    if seed == nil then
        seed = timeSeed + (frame * 97) + (state.previewRandomCounter * 7919)
    end

    seed = ((seed * 1103515245) + 12345 + (frame * 101) + (state.previewRandomCounter * 2654435761)) % 2147483647
    state.previewRandomSeed = seed

    return math.floor(seed % size) + 1
end

local function addUniquePreviewName(targetPool, name, targetSet)
    if name == nil or name == "" then return end

    if targetSet ~= nil then
        if targetSet[name] then return end

        targetSet[name] = true
        table.insert(targetPool, name)
        return
    end

    for _, existingName in ipairs(targetPool) do
        if existingName == name then return end
    end

    table.insert(targetPool, name)
end

local function addPreviewNames(targetPool, names, targetSet)
    for _, name in ipairs(names) do
        addUniquePreviewName(targetPool, name, targetSet)
    end
end

local function seedDefaultPreviewNamePools()
    -- This is the real preview fallback without REPENTOGON: a curated vanilla
    -- list with combat-relevant names only. EntityConfig can add modded names on
    -- top later, but previews never need to depend on it.
    addPreviewNames(
        state.bossPreviewNames,
        DEFAULT_BOSS_PREVIEW_NAMES,
        state.bossPreviewNameSet
    )

    addPreviewNames(
        state.enemyPreviewNames,
        DEFAULT_ENEMY_PREVIEW_NAMES,
        state.enemyPreviewNameSet
    )
end

function resetPreviewBuild()
    -- Called on game start so preview names are rebuilt against the current
    -- loaded entity config set.
    state.bossPreviewNames = {}
    state.enemyPreviewNames = {}
    state.bossPreviewNameSet = {}
    state.enemyPreviewNameSet = {}

    state.previewBuildDone = false
    state.previewBuildType = 1
    state.previewBuildVariant = 0

    state.bossPreviewName = nil
    state.enemyPreviewName = nil
    state.bossCollapsePreviewNames = {}
    state.previewNameSessionActive = false

    seedDefaultPreviewNamePools()
end

function addPreviewEntityName(entityType, variant)
    -- Preview pools do not need exact subtype coverage. Variant + subtype 0 gives
    -- a broad, cheap set of recognizable names for random preview labels.
    local ok, entityConfig = pcall(function()
        return EntityConfig.GetEntity(entityType, variant, 0)
    end)

    if not ok or entityConfig == nil then return end

    local name = getExternalEntityName(entityType, variant, 0) or getEntityConfigName(entityConfig)
    if name == nil or name == "" then return end

    local okIsBoss, isBoss = pcall(function()
        return entityConfig:IsBoss()
    end)

    if okIsBoss and isBoss then
        addUniquePreviewName(state.bossPreviewNames, name, state.bossPreviewNameSet)
    else
        addUniquePreviewName(state.enemyPreviewNames, name, state.enemyPreviewNameSet)
    end
end

function buildPreviewNamePoolsStep(maxChecks)
    if state.previewBuildDone then return end

    -- Spread the EntityConfig scan across updates. This keeps menu setup smooth
    -- even with many modded entities installed.
    local checks = 0

    while checks < maxChecks and not state.previewBuildDone do
        addPreviewEntityName(state.previewBuildType, state.previewBuildVariant)

        checks = checks + 1
        state.previewBuildVariant = state.previewBuildVariant + 1

        if state.previewBuildVariant > state.previewBuildMaxVariant then
            state.previewBuildVariant = 0
            state.previewBuildType = state.previewBuildType + 1
        end

        if state.previewBuildType > state.previewBuildMaxType then
            state.previewBuildDone = true
            seedDefaultPreviewNamePools()
        end
    end
end

function getDefaultPreviewNamePool(defaultName)
    if defaultName == "Fly" then
        return DEFAULT_ENEMY_PREVIEW_NAMES
    end

    return DEFAULT_BOSS_PREVIEW_NAMES
end

local function buildPreviewNameCandidates(sourcePool, currentName, secondBlockedName, thirdBlockedName)
    local candidates = {}
    local seen = {}

    for _, name in ipairs(sourcePool or {}) do
        if name ~= nil
            and name ~= ""
            and name ~= currentName
            and name ~= secondBlockedName
            and name ~= thirdBlockedName
            and not seen[name]
        then
            seen[name] = true
            table.insert(candidates, name)
        end
    end

    return candidates
end

function getRandomPreviewName(pool, defaultName, currentName, secondBlockedName, thirdBlockedName)
    local sourcePool = pool
    local defaultPool = getDefaultPreviewNamePool(defaultName)

    if sourcePool == nil or #sourcePool == 0 then
        sourcePool = defaultPool
    end

    local candidates = buildPreviewNameCandidates(sourcePool, currentName, secondBlockedName, thirdBlockedName)

    if #candidates == 0 and sourcePool ~= defaultPool then
        candidates = buildPreviewNameCandidates(defaultPool, currentName, secondBlockedName, thirdBlockedName)
    end

    if #candidates == 0 then
        candidates = buildPreviewNameCandidates(sourcePool)
    end

    if #candidates == 0 then
        candidates = buildPreviewNameCandidates(defaultPool)
    end

    if #candidates == 0 then return defaultName end

    return candidates[getPreviewRandomIndex(#candidates)]
end

function PrepareCombatNameHUDPreviewNamePoolsForRandomize()
    -- If EntityConfig is still loading, take one more chunk before choosing.
    -- The default preview lists already guarantee useful vanilla names.
    if not state.previewBuildDone then
        buildPreviewNamePoolsStep(700)
    end
end

function RandomizeCombatNameHUDBossPreviewName()
    PrepareCombatNameHUDPreviewNamePoolsForRandomize()
    state.bossPreviewName = getRandomPreviewName(state.bossPreviewNames, "Mom's Heart", state.bossPreviewName)
    RandomizeCombatNameHUDBossCollapsePreviewNames()
    state.previewNameSessionActive = true
end

function RandomizeCombatNameHUDEnemyPreviewName()
    PrepareCombatNameHUDPreviewNamePoolsForRandomize()
    state.enemyPreviewName = getRandomPreviewName(state.enemyPreviewNames, "Fly", state.enemyPreviewName)
    state.previewNameSessionActive = true
end

function RandomizeCombatNameHUDPreviewNames()
    RandomizeCombatNameHUDBossPreviewName()
    RandomizeCombatNameHUDEnemyPreviewName()
    state.previewNameSessionActive = true
end

function RandomizeCombatNameHUDBossCollapsePreviewNames()
    PrepareCombatNameHUDPreviewNamePoolsForRandomize()

    if state.bossPreviewName == nil then
        state.bossPreviewName = getRandomPreviewName(state.bossPreviewNames, "Mom's Heart")
    end

    local firstName = state.bossPreviewName
    local secondName = getRandomPreviewName(state.bossPreviewNames, "Mega Maw", firstName)
    local thirdName = getRandomPreviewName(state.bossPreviewNames, "The Duke of Flies", firstName, secondName)
    local fourthName = getRandomPreviewName(state.bossPreviewNames, "Gurdy", firstName, secondName, thirdName)

    state.bossCollapsePreviewNames = {
        firstName,
        secondName,
        thirdName,
        fourthName
    }
end

function EnsureCombatNameHUDBossCollapsePreviewNames()
    if state.bossCollapsePreviewNames == nil then
        state.bossCollapsePreviewNames = {}
    end

    if state.bossPreviewName == nil or #state.bossCollapsePreviewNames < 4 then
        RandomizeCombatNameHUDBossCollapsePreviewNames()
        return
    end

    state.bossCollapsePreviewNames[1] = state.bossPreviewName
end
