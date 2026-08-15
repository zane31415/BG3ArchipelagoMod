-- BackgroundGoalFailed
-- BackgroundGoalRewarded
-- Activated
-- CastSpell
-- CastedSpell
-- QuestAccepted
-- QuestUpdateUnlocked
-- UsingSpell

-- EnteredChasm
-- EnteredLevel
-- GainedControl
-- GameModeStarted
-- LeftLevel
-- TimerFinished

-- SubQuestUpdateUnlocked ?
PersistentVars = {}

syncOnAny = true
logKills = true
logQuests = true
deathlink = true
devDebugOnly = false
logContainers = false
pendingReceiveDeathlink = false
-- Defaults to false so a mod install without any AP setup (no ap_options.json
-- ever written) does not lock the world's doors with zero messaging. The real
-- value is applied whenever ap_options.json is read.
blockEntrances = false
-- When true, any story attempt to lock a waypoint is immediately reversed so the
-- player never loses fast-travel access to a region they've already unlocked
-- (grove lockdown, creche destroyed, Wyrmrock foundry, act transitions, ...).
-- These all funnel through the base Osiris LockWaypoint call, so a single
-- "after" listener neutralizes every one of them. See LockWaypoint listener.
keepWaypointsUnlocked = true
-- When true, keep the Act 2 "point of no return" global flag cleared. It is set
-- (via a compound flag) on entering Nightsong's prison at the climax of the
-- Trials of Shar. That flag is the linchpin for two things we don't want:
--   * QRY_SCL_General_CanReturnToAct1 == NOT flag, so while it's set, waypoint
--     travel back to Act 1 is refused; clearing it restores return travel.
--   * ~18 Act 1 / Underdark quests are bound to failure states through it
--     (DB_QuestDef_State(Act2_PointOfNoReturnReached, quest, failstate)).
-- We clear it on session load and on every level entry (it can be re-derived
-- from its compound source, so a one-shot clear won't hold). We deliberately do
-- NOT touch DB_SCL_Teleporters_Blocked: the physical elevator/mountain
-- teleporters can stay blocked since waypoints cover return travel. The base
-- game already clears this exact flag on a debug path, so the engine tolerates
-- it. NOTE: quests already failed at the instant the flag first set are not
-- un-failed by this - that's what reopenClosedActQuests below is for.
killPointOfNoReturn = true
POINT_OF_NO_RETURN_FLAG = "Act2_PointOfNoReturnReached_a3155f30-b8f3-4db5-ac21-d3036f4426e3"
NULL_GUID = "NULL_00000000-0000-0000-0000-000000000000"
-- EXPERIMENTAL / needs in-game verification. The base game force-closes Act 1
-- quests to failure states when the Wilderness (WLD_Main_A) unloads - e.g.
-- DEN_HarpyMeal -> "DoneNoInvestigation" / "DoneLeftKid", which map to NO AP
-- location (bg3_locations.py), so the check is lost. QuestUpdate has no
-- documented inverse and a closed quest may reject further updates, so this
-- listener (re-issuing an earlier open state) is a "see what actually happens"
-- probe, not a known-good fix. Tune the target state per quest during testing.
reopenClosedActQuests = true
importantKillSet = {
    ["S_HAG_Hag_c457d064-83fb-4ec6-b74d-1f30dfafd12d"] = true, -- Auntie Ethel
    ["S_FOR_Bottomless_SpiderQueen_e6b2f3ba-2d02-4507-8680-6047322e1a4b"] = true, -- Spider Queen
    ["S_UND_PetrifiedDrow_Spectator_39ff8241-fadd-4fbe-ab89-fc5a8b7638a0"] = true, -- Spectator
    ["S_UND_Bulette_307934b5-6fb5-4fdc-a7ff-433a7ba175b3"] = true, -- Bulette
    ["S_UND_Myconid_BroodingSovereign_82af0858-d739-4c9d-84c8-5e6760e22e46"] = true, -- Glut
    ["S_UND_MyconidSovereign_ea0f222f-eaad-4d83-bbcd-cbae51ccf265"] = true, -- Spaw
    ["S_UND_TheDrowNere_06bf05c5-216b-4eaf-91f5-8f1dd3d57f30"] = true, -- Nere
    ["S_UND_KethericCity_AdamantineGolem_2a5997fc-5f2a-4a13-b309-bed16da3b255"] = true, -- Grym
    ["S_CRE_Templar_378ac93e-03a0-40b4-904c-f37989ac7a8c"] = true, --Ch'r'ai W'wargaz
    ["S_SCL_BlightCombat2_Mound_01_1b294fe0-f1a1-4e81-9d4c-8d86bbda7d2b"] = true, -- Shambling Mound
    ["S_SCL_FishermansHut_CursedKuoToa_Champion_03524330-c6ca-4078-8fbf-12ec4ffa389a"] = true, -- Cursed Kuo-Toa Chief
    ["S_TWN_Hospital_Surgeon_e58b8b34-038b-4858-b817-c2a8096a9381"] = true, -- Malus Thorm
    ["S_TWN_Tollhouse_TollhouseMaster_3b460226-8ca2-4bbc-9bd7-8bb947aa2c06"] = true, -- Gerringothe Thorm
    ["S_TWN_Distillery_Brewer_4d9e3db3-9a78-4f4b-8101-1dd73c0f3be5"] = true, -- Thisobald Thorm
    ["S_TWN_VlaakithAttack_Caster_000_e4141a02-f5e7-4a0c-a7af-d3dda6610c1b"] = true, -- Ch'r'ai Tska'an
    ["S_GLO_Orthon_1dc8091d-2af6-4d33-9268-998ef266d19c"] = true, -- Orthon
    ["S_SHA_Necromancer_53651a9f-7ea8-444f-ba2d-224390b72f7d"] = true, -- Balthazar
    ["S_MOO_Ketheric_e9918f3e-5b87-40a3-a9bd-61545151573f"] = true -- Myrkul
}
GATE_BLOCK = {
    DISABLE_USE = 1,    -- SetDisableUse only
    CAN_INTERACT = 2,   -- SetCanInteract only
    BOTH = 3,           -- SetDisableUse and SetCanInteract
}

locationsToGates = {
    ["Gate-ExitNautiloid"] = {{"S_TUT_Helm_ControlPanel_bcbba417-6403-40a6-aef6-6785d585df2a", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-WithersCrypt"] = {
        {"S_CHA_OUTSIDE_Entrance_Door_000_2647dac6-234b-4e6f-8321-f88e95359fc4", GATE_BLOCK.CAN_INTERACT},
        {"S_CHA_OUTSIDE_CryptHatch_76d53fd7-dc26-4dde-822a-485e0f19937a", GATE_BLOCK.CAN_INTERACT},
        {"S_CHA_OUTSIDE_Crypt_Door_d06d5638-c69a-4fcc-b996-c305acbb7ebf", GATE_BLOCK.CAN_INTERACT},
        {"S_CHA_OUTSIDE_Fissure_GrapplingVines_001_c64eb1e0-cb5a-46a6-af3f-7bf2b2505e84", GATE_BLOCK.CAN_INTERACT},
        {"S_CHA_OUTSIDE_Fissure_Boulder_29a94ca5-cede-4932-88c5-3942334e4990", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-RuinedVillageWell"] = {
        {"BLD_GEN_Platform_SpiderWeb_A_4D_H0n5_4W_A_Dynamic_000_5b9b61f7-82ca-86a0-3dce-4d0142cdc382", GATE_BLOCK.CAN_INTERACT},
        {"S_FOR_VillageWell_21be1469-8f1c-4934-9235-112364aa3df9", GATE_BLOCK.CAN_INTERACT},
        {"S_FOR_MasterworkOutsideDoor_c899d16c-60b1-4339-b09f-8eb00e157be8", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-GoblinCamp"] = {
        {"S_GOB_ThroneRoom_Door_Entrance_bf8a7b29-383d-4344-bbe6-b72f10c1ba50", GATE_BLOCK.CAN_INTERACT},
        {"S_GOB_Festivities_SecretEntrance_Door_ddbb3184-e682-47b7-ac0f-94d631b3f3ed", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-Underdark"] = {
        {"BLD_GEN_Platform_SpiderWeb_A_4D_H0n5_4W_A_Dynamic_000_5b9b61f7-82ca-86a0-3dce-4d0142cdc382", GATE_BLOCK.CAN_INTERACT},
        {"S_FOR_VillageWell_21be1469-8f1c-4934-9235-112364aa3df9", GATE_BLOCK.CAN_INTERACT},
        {"S_FOR_MasterworkOutsideDoor_c899d16c-60b1-4339-b09f-8eb00e157be8", GATE_BLOCK.CAN_INTERACT},
        {"TOOL_Goblins_Ladder_10n5H_A_c3cd979a-21e8-4f70-adb8-1e81a6250e2e", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-HagsFireplace"] = {{"S_HAG_HagLair_PortalToLair_b9e148b4-7b9b-45e5-bef4-f0673fffc93e", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-ZhentarimBasement"] = {{"S_PLA_EscapingZhentarim_Hatch_6f4de170-be4f-4bbb-bb37-69f2a5ddd929", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-Grymforge"] = {{"S_UND_EbonLake_RaftAtCave_FullRaft_a24aa852-9f72-48bc-8d94-7a92da7ca4c1", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-MountainPass"] = {
        {"S_PLA_TeleporterToCrecheFromPlains_016525f4-0ddd-4cf1-85ab-3feaa6f6292a", GATE_BLOCK.CAN_INTERACT},
        {"S_GOB_TeleporterToCrecheFromGoblinCamp_a81232d7-af15-4c77-b0e1-d7e791fd463b", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-Creche"] = {{"S_TELEPORT_CrecheDungonEntrance_f1e59d69-7dfd-42aa-b0eb-45e2db3129bc", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-Act2"] = {{"S_UND_Elevator_Fort_ToShadowlands_e48a9110-dabc-4471-bcae-3cc8aa57b8c5", GATE_BLOCK.CAN_INTERACT},
        {"S_CRE_TeleporterToSCL02_45ddbbd7-9316-477a-8e37-1d11256b40f6", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-LastLightBasement"] = {{"S_Door_HavenCellarEntry_0ab0a1e5-9a71-4038-94f9-6ad3f990a534", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-ReithwinsMasonsGuild"] = {{"S_TWN_MasonsGuild_HatchToBasement_ccb81739-f582-406d-ae54-a4a46aab7030", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-SharTrials"] = {{"S_TELEPORTDOOR_Invisible_A_MausoleumEntry_2716d53b-ec00-4e80-a638-6475576eb5c1", GATE_BLOCK.CAN_INTERACT},
        {"S_SHA_NightsongPrison_ShadowfellEntranceHelper_1fc893ad-277f-4bb3-914c-9bdef4ff0385", GATE_BLOCK.CAN_INTERACT}, -- shadowfell
       -- {"S_SHA_NightsongPrison_ExitPortal_3e872c6c-95d1-47ef-85b5-bfa835ebb525", GATE_BLOCK.CAN_INTERACT} -- exit
    }, 
    ["Gate-ProgressiveMoonlightTowers-0"] = {
        {"S_MOO_MainTowerEntrance_c9007d4d-8dfe-4b1a-a8cd-7b489710d29e", GATE_BLOCK.CAN_INTERACT}, -- front door (1)
        {"DOOR_Single_Dungeon_Abbey_B_028_1518702f-a47c-4032-abdf-f58738f68426", GATE_BLOCK.CAN_INTERACT}, -- side door (1)
        {"DOOR_Single_Dungeon_Abbey_B_027_74c3eec5-df87-4cc5-b8fc-11f3c446de35", GATE_BLOCK.CAN_INTERACT}, -- back side door A(1)
        {"DOOR_Single_Dungeon_Abbey_B_019_521bb9c1-1de1-4e3d-9bd3-fe2fa2ad5c9f", GATE_BLOCK.CAN_INTERACT}, -- back side door B(1)
        {"DOOR_Single_Dungeon_Abbey_B_029_e815e895-45dc-47cd-a011-4172c258e799", GATE_BLOCK.CAN_INTERACT}}, -- back side door C(1)
    ["Gate-ProgressiveMoonlightTowers-1"] = {
        {"S_MOO_DockDoor_ada141ae-e0a8-4915-a9c7-355093370992", GATE_BLOCK.CAN_INTERACT}, --prison (2)
        {"S_MOO_StairsToPrison_78b1cd2c-0edb-441d-a389-6163ba7dba48", GATE_BLOCK.CAN_INTERACT}}, -- prison (2)
    ["Gate-ProgressiveMoonlightTowers-2"] = {
        {"S_MOO_RoofAccessDoor_0eca4cd0-6fa5-421f-80e9-446c2b758606", GATE_BLOCK.CAN_INTERACT}}, -- roof (3)
    ["Gate-ProgressiveMoonlightTowers-3"] = {
        {"S_MOO_TentaclelessTeleporter_c29cec63-82da-4579-b11d-75a5a08bbe1b", GATE_BLOCK.CAN_INTERACT}}, -- colony (4)
    ["Gate-ProgressiveMoonlightTowers-4"] = {
        {"S_COL_Elevator_Controller_38c76a3f-beaf-417b-be7e-62773c705c8f", GATE_BLOCK.CAN_INTERACT}, -- Myrkul elevator (5)
        {"S_COL_KethericShowdown_Door_378bd363-b818-4326-9883-d5a9cd5a1fcc", GATE_BLOCK.CAN_INTERACT} -- Myrkul door (5)
    },
    ["Gate-Act3"] = {{"S_TWN_ActExit_4df293a7-c9b7-4be4-b4a9-42400ddbe209", GATE_BLOCK.CAN_INTERACT}}
}

function isDeathLinkTrigger(character)
    return PersistentVars['DeathLinkTriggers'][character] == true
end

function getDeathLinkName(character)
    if PersistentVars['DeathLinkNames'][character] ~= nil then
        return PersistentVars['DeathLinkNames'][character]
    end
    return "Somebody"
end

importantQuestSet = {
    ["DEN_Conflict-HalsinLeft_KilledLeaders"] = true,
    ["DEN_Conflict-HalsinReturned_Known"] = true,
    ["GLO_Tadpole-HalsinReturned_Known"] = true,
    ["GLO_Tadpole-ReportHalsin_LeadersDefeated"] = true,
    ["SCL_LiftingTheCurse-TalkToThaniel"] = true, -- Thaniel
}

locationOutFile = "ap_out.json"
itemsInFile = "ap_in.json"
-- Fast file bus (client -> game): the client bumps this tiny counter file after
-- every payload write; the tick only re-parses the payload when it changes.
genInFile = "gen_in.txt"
-- Wire-string -> display-name map, rewritten by the client next to ap_in.json.
namesFile = "ap_names.json"

-- Timer/presence protocol constants (docs/se-ap-ipc-design.md section 13)
local TICK_MS = 250
local HEARTBEAT_TICKS = 20     -- write our heartbeat every 20 ticks (~5 s)
local CLIENT_CHECK_TICKS = 4   -- read the client heartbeat every 4 ticks (~1 s)
local FALLBACK_TICKS = 12      -- no gen file (old client): process every ~3 s
local STALE_MS = 15000         -- 3x the 5 s heartbeat cadence

PRESENCE_MESSAGES = {
    NO_CLIENT = "Archipelago BG3 Client not detected - items will not be delivered. Launch 'Baldur's Gate 3 Client' from the Archipelago Launcher. (The Text Client is not enough.)",
    NO_SERVER = "AP client lost the server. Your checks are saved and will send when it reconnects.",
    SEED_MISMATCH = "The connected Archipelago room does not match this savegame.",
    OK = "Archipelago connection restored.",
}

-- State shared with the in-game window (client Lua) over the AP_State channel.
apState = {
    presence = "STARTING",  -- STARTING | OK | NO_CLIENT | NO_SERVER | SEED_MISMATCH
    seed = nil,
    slot = nil,
    items_granted = 0,
    checks_logged = 0,
    deathlink = false,
    recent = {},            -- newest first: { name = ..., t = "HH:MM:SS" }
    log = {},               -- newest first, plain strings
    gates = {},             -- { name = "Gate-...", unlocked = bool }, filled at publish
}
local stateDirty = false
local stateChannel = nil
local commandChannel = nil

local RECENT_MAX = 15
local LOG_MAX = 30

-- Last observed generation-counter content; nil forces the next tick to
-- (re)process the items file.
local lastGen = nil

function contains(tbl, value)
    for i = 1, #tbl do  -- Iterate from index 1 to the length of the table
        if tbl[i] == value then
            return true -- Value found
        end
    end
    return false -- Value not found after checking all elements
end

local function clock_time()
    local ok, t = pcall(function() return Ext.Timer.ClockTime() end)
    if ok and type(t) == "string" then return t end
    return ""
end

local function monotonic_now()
    local ok, t = pcall(function() return Ext.Timer.MonotonicTime() end)
    if ok and type(t) == "number" then return t end
    return nil
end

-- print + mirror into the window's log pane
local function ap_log(text)
    print(text)
    local stamp = clock_time()
    if stamp ~= "" then text = stamp .. "  " .. text end
    table.insert(apState.log, 1, text)
    while #apState.log > LOG_MAX do table.remove(apState.log) end
    stateDirty = true
end

local function reset_ap_state()
    Ext.IO.SaveFile(locationOutFile, "[]")
    -- Only the legacy UNPREFIXED in-file gets wiped (it may hold another
    -- seed's items). The seed-prefixed in-file is client-owned and may have
    -- been written for THIS seed moments ago - wiping it here used to eat
    -- the first item batch until the server happened to resend.
    Ext.IO.SaveFile("ap_in.json", "[]")
    Ext.IO.SaveFile("deathLinkSend.json", "[]")
    Ext.IO.SaveFile("deathLinkReceive.json", "[]")
    Ext.IO.SaveFile("debug.json", "[]")
    PersistentVars['APSent'] = {}
    PersistentVars['APGrantFailures'] = {}
    PersistentVars['ContainersOpened'] = {}
    apState.recent = {}
    apState.checks_logged = 0
    lastGen = nil
    stateDirty = true
end

local function read_option(data, key)
    if data == nil then return false end
    local v = data[key]
    if v == nil then return false end
    if type(v) == "boolean" then return v end
    if type(v) == "number" then return v ~= 0 end
    return false
end

local function print_to_file(filename, text)
    local unparsed = Ext.IO.LoadFile(filename)
    local data = {}

    if (unparsed) then
        data = Ext.Json.Parse(unparsed)
        if (data == nil) then
            print("Failed to parse JSON")
            return
        end
    end
    table.insert(data, text)
    Ext.IO.SaveFile(filename, Ext.Json.Stringify(data))
end

local function recount_checks()
    local raw = Ext.IO.LoadFile(locationOutFile)
    local data = raw and Ext.Json.Parse(raw) or nil
    if type(data) == "table" then
        apState.checks_logged = #data
    else
        apState.checks_logged = 0
    end
    stateDirty = true
end

function initDeathLink()
    if (PersistentVars['DeathLinkTriggers'] == nil) then
        PersistentVars['DeathLinkTriggers'] = {}
    end
    if (PersistentVars['DeathLinkNames'] == nil) then
        PersistentVars['DeathLinkNames'] = {}
    end

    local defaultNames = {
        ["S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c"] = "Karlach",
        ["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = "Minsc",
        ["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = "Minthara",
        ["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = "Halsin",
        ["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = "Jaheira",
        ["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = "Gale",
        ["S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255"] = "Astarion",
        ["S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12"] = "Laezel",
        ["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = "Wyll",
        ["S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679"] = "Shadowheart"
    }

    for uuid, name in pairs(defaultNames) do
        if (PersistentVars['DeathLinkTriggers'][uuid] == nil) then
            PersistentVars['DeathLinkTriggers'][uuid] = true
        end
        if (PersistentVars['DeathLinkNames'][uuid] == nil) then
            PersistentVars['DeathLinkNames'][uuid] = name
        end
    end
end

-- Cached wire-string -> display-name table; invalidated on every sync so it
-- tracks the client's rewrites.
local displayNames = nil

local function get_display_name(v)
    if displayNames == nil then
        local raw = Ext.IO.LoadFile(namesFile)
        local parsed = raw and Ext.Json.Parse(raw) or nil
        if type(parsed) == "table" then displayNames = parsed else displayNames = {} end
    end
    local name = displayNames[v]
    if type(name) == "string" and name ~= "" then return name end
    return v
end

local function add_recent(v)
    table.insert(apState.recent, 1, { name = get_display_name(v), t = clock_time() })
    while #apState.recent > RECENT_MAX do table.remove(apState.recent) end
    stateDirty = true
end

-- Options loading. Called at session load AND at the top of every sync
-- (cheaply): the client writes ap_options.json on Connected, which can happen
-- after the save is already loaded - the old read-once-at-session-load
-- behavior left the game on unprefixed files and default options with no error
-- anywhere (the "first-run desync").
function load_options()
    local unparsed = Ext.IO.LoadFile("ap_options.json")
    if (not unparsed) then
        return false
    end
    local data = Ext.Json.Parse(unparsed)
    if (data == nil) then
        print("Failed to parse JSON (ap_options.json)")
        return false
    end
    syncOnAny = read_option(data, "sync_method")
    logKills = read_option(data, "killsanity")
    logQuests = read_option(data, "questsanity")
    deathlink = read_option(data, "death_link")
    devDebugOnly = read_option(data, "dev_debug_on")
    logContainers = false
    blockEntrances = read_option(data, "block_entrances")
    if (data.containersanity ~= nil and data.containersanity ~= 0 and data.containersanity ~= 1) then
        logContainers = true
    end
    local new_seed = data.seed_name
    if (type(new_seed) == "string" and new_seed ~= "") then
        local stored_seed = PersistentVars['SeedName']
        local prefix_changed = (itemsInFile ~= new_seed .. "ap_in.json")
        locationOutFile = new_seed .. "ap_out.json"
        itemsInFile = new_seed .. "ap_in.json"
        genInFile = new_seed .. "gen_in.txt"
        namesFile = new_seed .. "ap_names.json"
        apState.seed = new_seed
        if (stored_seed ~= new_seed) then
            ap_log("AP seed_name changed (was " .. tostring(stored_seed) .. ", now " .. new_seed .. "); resetting AP state")
            PersistentVars['SeedName'] = new_seed
            reset_ap_state()
        end
        if (prefix_changed) then
            -- Mid-session pickup of the real filenames (first-run fix):
            -- re-anchor everything derived from them.
            displayNames = nil
            lastGen = nil
            recount_checks()
        end
    end
    return true
end

-- Clear the Act 2 point-of-no-return flag if it's set (idempotent - clearing an
-- already-clear flag is harmless). Global flags target the null GUID.
function clearPointOfNoReturn()
    if (not killPointOfNoReturn) then
        return
    end
    if (Osi.GetFlag(POINT_OF_NO_RETURN_FLAG, NULL_GUID) == 1) then
        Osi.ClearFlag(POINT_OF_NO_RETURN_FLAG, NULL_GUID)
        if (devDebugOnly) then
            print_to_file("debug.json", "Cleared Act2_PointOfNoReturnReached")
        end
    end
end

function OnSessionLoaded()
    initDeathLink()
    -- A deathlink received while the game was closed must not fire hours later
    -- on the next load.
    Ext.IO.SaveFile("deathLinkReceive.json", "[]")
    load_options()
    recount_checks()
    clearPointOfNoReturn()
    start_ap_tick()
end

Ext.Osiris.RegisterListener("GameModeStarted", 3, "after", function(gameMode, isMainThread, something)
    setBlockedEntrances()
end)

function applyGateBlock(uuid, mode, blocked)
    if mode == GATE_BLOCK.DISABLE_USE or mode == GATE_BLOCK.BOTH then
        Osi.SetDisableUse(uuid, blocked and 1 or 0)
    end
    if mode == GATE_BLOCK.CAN_INTERACT or mode == GATE_BLOCK.BOTH then
        Osi.SetCanInteract(uuid, blocked and 0 or 1)
    end
end

function setBlockedEntrances()
    local APSent = PersistentVars['APSent'] or {}
    for location, gates in pairs(locationsToGates) do
        for _, gate in pairs(gates) do
            local uuid, mode = gate[1], gate[2]
            if (APSent[location] == true or not blockEntrances) then
                -- Don't block gates we've sent the unlock for
                if (not blockEntrances) then
                    print("Not blocking entrance to " .. location .. " via gate " .. uuid .. " because blockEntrances is false")
                else
                    print("Not blocking entrance to " .. location .. " via gate " .. uuid .. " because we've sent an unlock for it")
                end
                applyGateBlock(uuid, mode, false)
            else
                if ((location == "Gate-RuinedVillageWell" and APSent["Gate-Underdark"] == true) or (location == "Gate-Underdark" and APSent["Gate-RuinedVillageWell"] == true)) then
                    -- Don't block the Ruined Village Well if we've unlocked the Underdark, and vice versa
                    print("Not blocking entrance to " .. location .. " via gate " .. uuid .. " because we've sent an unlock for the other gate")
                    applyGateBlock(uuid, mode, false)
                else
                    print("Blocking entrance to " .. location .. " via gate " .. uuid)
                    applyGateBlock(uuid, mode, true)
                end
            end
        end
    end
end

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

Ext.Osiris.RegisterListener("Died", 1, "after", function(died)
    if (isDeathLinkTrigger(died)) then
        if (pendingReceiveDeathlink) then
            -- This death was caused by a deathlink we just received from the
            -- server; consume the suppression flag instead of echoing the
            -- death back upstream. Resetting here (rather than after sending)
            -- ensures subsequent local deaths can send again.
            pendingReceiveDeathlink = false
        elseif (deathlink) then
            local name = getDeathLinkName(died)
            if (name ~= nil) then
                -- Append rather than overwrite: two quick deaths must not
                -- lose the first one while the client is between polls.
                local unparsed = Ext.IO.LoadFile("deathLinkSend.json")
                local data = unparsed and Ext.Json.Parse(unparsed) or nil
                if (type(data) ~= "table") then data = {} end
                table.insert(data, name)
                Ext.IO.SaveFile("deathLinkSend.json", Ext.Json.Stringify(data))
            end
        end
    end
end)

Ext.Osiris.RegisterListener("KilledBy", 4, "after", function(defender, attackOwner, attacker, storyActionID)
    if (logKills or importantKillSet[defender]) then
        local unparsed = Ext.IO.LoadFile(locationOutFile)
        local data = {}
        print("Logging kill: " .. "Kill-" .. defender)

        if (unparsed) then
            data = Ext.Json.Parse(unparsed)
            if (data == nil) then
                print("Failed to parse JSON")
                return
            end
        end
        local needsToAdd = true
        for k, v in ipairs(data) do
            if (v == "Kill-" .. defender) then
                needsToAdd = false
                break
            end
        end
        if (needsToAdd) then
            table.insert(data, "Kill-" .. defender)
            Ext.IO.SaveFile(locationOutFile, Ext.Json.Stringify(data))
            apState.checks_logged = apState.checks_logged + 1
            stateDirty = true
        end
    end
end)

--Ext.Osiris.RegisterListener("UseStarted", 2, "after", function(character, object)
--    print_to_file("debug.json", "UseStarted: " .. character .. " " .. object )
--end)

Ext.Osiris.RegisterListener("TemplateUseStarted", 3, "after", function(character, itemTemplate, item)
    if(devDebugOnly) then
        print_to_file("debug.json", "TemplateUseStarted: " .. character .. " " .. itemTemplate .. " " .. item)
    end
end)

Ext.Osiris.RegisterListener("EnteredTrigger", 2, "after", function(character, trigger)
    if (devDebugOnly and isDeathLinkTrigger(character)) then
        print_to_file("debug.json", "EnteredTrigger: " .. character .. " " .. trigger )
    end
end)

Ext.Osiris.RegisterListener("EnteredLevel", 3, "after", function(character, region, isFirstTime)
    if (devDebugOnly and isDeathLinkTrigger(character)) then
        print_to_file("debug.json", "EnteredLevel: " .. character .. " " .. region .. " " .. tostring(isFirstTime))
    end
    if (isDeathLinkTrigger(character) and blockEntrances) then
        setBlockedEntrances()
    end
    -- Re-clear the point-of-no-return flag on any region change. Entering
    -- Nightsong's prison re-derives it from a compound flag, so clearing once at
    -- session load isn't enough; every subsequent level entry heals it again.
    clearPointOfNoReturn()
end)

-- Keep already-unlocked waypoints usable. The base game locks waypoints on a
-- number of one-way story beats (grove lockdown, creche exploded, Wyrmrock, act
-- transitions). Every path goes through the Osiris LockWaypoint(WaypointID,
-- Player) call, so we listen "after" and immediately re-unlock. UnlockWaypoint
-- does not fire LockWaypoint, so there is no feedback loop. Temporary combat
-- fast-travel blocks use a separate mechanism and are unaffected.
Ext.Osiris.RegisterListener("LockWaypoint", 2, "after", function(waypointID, player)
    if (not keepWaypointsUnlocked) then
        return
    end
    if (devDebugOnly) then
        print_to_file("debug.json", "LockWaypoint reverted: " .. tostring(waypointID) .. " " .. tostring(player))
    end
    Osi.UnlockWaypoint(waypointID, player)
end)

-- =====================================================================
-- DRAFT / DISABLED: selective NPC re-staging on advancement.
-- =====================================================================
-- Goal: when the base game takes an NPC off-stage as part of a location
-- advancing (e.g. the grove refugees leaving via
-- PROC_DEN_TieflingRefugees_MakeNPCLeave -> SetOnStage(_NPC, 0)), put the
-- NPC back IF it's still needed for an AP location we haven't sent yet.
-- Accepts a "weirdly sparse" world: only the still-needed NPCs come back.
--
-- Worked example - Mirkon, the charmed tiefling child in the harpy scene:
--   NPC:     S_DEN_CharmedKid_3b92c689-6024-4446-a6c9-584e9e8d77ca
--   He is listed in Story DB_DEN_AttackOnDen_LeaveNPCs, so he leaves the
--   grove through the SetOnStage(_NPC, 0) path above. The 4 harpies
--   (S_DEN_Harpy_000..003) are NOT in that leave-list, so they generally
--   persist; re-staging Mirkon is the operative piece. The scene's AP
--   location resolves via the DEN_HarpyMeal quest / all-harpies-dead.
--
-- CAVEATS to sort out during a test run (why this is left disabled):
--   1. GUID form: confirm SetOnStage passes the S_-prefixed form that
--      matches the keys below (importantKillSet is keyed the same way, so
--      it probably does - but verify).
--   2. MakeNPCLeave also does SetHasDialog(_NPC, 0) / fires "DEN_NPC_LeftDen".
--      Re-staging may need SetHasDialog(_NPC, 1) (and repositioning) before
--      the harpy dialog will re-trigger. Re-staging alone may leave a mute
--      Mirkon standing there.
--   3. LOCATION STRINGS below are PLACEHOLDERS. The real AP location name
--      for the harpy scene is defined apworld-side; fill it in. Format in
--      ap_out.json is a flat array of "Kill-<guid>" / "<quest>-<state>".
--   4. Perf: SetOnStage fires very often. Keep the hot path to a single
--      table lookup (protectedNpcs[npc]); only touch the file for a match.
--
-- respawnRequiredNpcs = false
--
-- -- NPC GUID -> AP location string that "consumes" this NPC. While that
-- -- location is NOT present in ap_out.json (not yet sent), re-stage the NPC.
-- protectedNpcs = {
--     -- Mirkon. PLACEHOLDER location string - replace with the real one.
--     ["S_DEN_CharmedKid_3b92c689-6024-4446-a6c9-584e9e8d77ca"] = "DEN_HarpyMeal-<state>",
-- }
--
-- -- True once the given AP location string has been written to ap_out.json.
-- local function apLocationSent(checkString)
--     local raw = Ext.IO.LoadFile(locationOutFile)
--     if (not raw) then return false end
--     local data = Ext.Json.Parse(raw)
--     if (type(data) ~= "table") then return false end
--     for _, v in ipairs(data) do
--         if (v == checkString) then return true end
--     end
--     return false
-- end
--
-- Ext.Osiris.RegisterListener("SetOnStage", 2, "after", function(object, onStage)
--     if (not respawnRequiredNpcs) then return end
--     -- Only interested in despawns (onStage == 0). Cheap guard first.
--     if (onStage == 1) then return end
--     local location = protectedNpcs[object]
--     if (not location) then return end
--     -- Still needed? If the location hasn't been sent, keep the NPC around.
--     if (not apLocationSent(location)) then
--         if (devDebugOnly) then
--             print_to_file("debug.json", "Re-staged protected NPC: " .. tostring(object))
--         end
--         Osi.SetOnStage(object, 1)
--     end
-- end)

--Ext.Osiris.RegisterListener("DestroyedBy", 4, "after", function(item, destroyer, destroyerOwner, storyActionId)
    -- Object is the specific GUID string of the entity being destroyed
    -- Template is the root template ID (the item type)
--    print("Destroyed Object UUID: " .. item)
--    if (devDebugOnly) then
--        print_to_file("debug.json", "Object destroyed: " .. item)
--    end
--end)

-- Osiris hands us "<Name>_<uuid>" (CONT_Goblins_Chest_A_000_295ffe0f-...); the
-- apworld keys containers on the bare instance uuid, which is the last 36 chars.
local function container_uuid(object)
    if (type(object) ~= "string" or #object < 36) then return nil end
    local uuid = string.sub(object, -36)
    if (string.match(uuid, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$")) then
        return uuid
    end
    return nil
end

Ext.Osiris.RegisterListener("Opened", 1, "after", function(object)
    if (not logContainers) then return end
    if (devDebugOnly) then
        print_to_file("debug.json", "Opened: " .. tostring(object))
    end

    local uuid = container_uuid(object)
    if (uuid == nil) then return end
    local location = "Container-" .. uuid

    -- Opening a container fires every time the player pokes it, and the
    -- out-file can hold thousands of container checks by Act 3, so keep the
    -- already-sent set in PersistentVars and only touch the file on a new one.
    local opened = PersistentVars['ContainersOpened']
    if (opened == nil) then
        opened = {}
        PersistentVars['ContainersOpened'] = opened
    end
    if (opened[uuid] == true) then return end

    local unparsed = Ext.IO.LoadFile(locationOutFile)
    local data = {}

    if (unparsed) then
        data = Ext.Json.Parse(unparsed)
        if (data == nil) then
            print("Failed to parse JSON")
            return
        end
    end
    local needsToAdd = true
    for k, v in ipairs(data) do
        if (v == location) then
            needsToAdd = false
            break
        end
    end
    if (needsToAdd) then
        table.insert(data, location)
        Ext.IO.SaveFile(locationOutFile, Ext.Json.Stringify(data))
        apState.checks_logged = apState.checks_logged + 1
        stateDirty = true
    end
    opened[uuid] = true
end)

Ext.Osiris.RegisterListener("CharacterCreationFinished", 0, "after", function()
    print("CharCreationDone")
    -- Pick up the seed prefix before resetting, so a client connected during
    -- character creation doesn't get the wrong (unprefixed) files wiped.
    load_options()
    if (Osi.GetRegion(GetHostCharacter()) == "SYS_CC_I") then
        print("Resetting AP files")
        reset_ap_state()
        local character = Ext.Entity.Get(Osi.GetHostCharacter())
        local charname = character.ServerCharacter.Template.Name .. "_" .. GetHostCharacter()
        PersistentVars['DeathLinkTriggers'][charname] = true
        PersistentVars['DeathLinkNames'][charname] = "Tav"
    else
        print("Not in starting area, not resetting AP files: " .. Osi.GetRegion(GetHostCharacter()))
    end
end)

Ext.Osiris.RegisterListener("QuestUpdateUnlocked", 3, "after", function(character, topLevelQuestID, stateID)
    print("QuestUpdateUnlocked " .. character .. " " .. topLevelQuestID .. " " .. tostring(stateID))
    if (logQuests or importantQuestSet[topLevelQuestID .. "-" .. stateID] ) then
        local unparsed = Ext.IO.LoadFile(locationOutFile)
        local data = {}

        if (unparsed) then
            data = Ext.Json.Parse(unparsed)
            if (data == nil) then
                print("Failed to parse JSON")
                return
            end
        end
        local needsToAdd = true
        for k, v in ipairs(data) do
            if (v == topLevelQuestID .. "-" .. stateID) then
                needsToAdd = false
                break
            end
        end
        if (needsToAdd) then
            table.insert(data, topLevelQuestID .. "-" .. stateID)
            Ext.IO.SaveFile(locationOutFile, Ext.Json.Stringify(data))
            apState.checks_logged = apState.checks_logged + 1
            stateDirty = true
        end
    end
end)

-- EXPERIMENTAL: when the base game force-closes an Act 1 quest to a dead-end
-- failure state on region unload, try to reopen it by re-issuing an earlier
-- still-playable state, so the player (having returned via restored waypoints)
-- can still complete it and earn the AP check.
--
-- "<quest>-<failstate>" -> "<open state to re-issue>".
-- The target states below are GUESSES to tune in-game - "the original base
-- event." Re-issuing an open state to a *closed* quest may simply be rejected
-- (that's the thing we're testing). Re-issuing the target does not re-enter this
-- table (target isn't a failstate key), so there's no listener loop; but if the
-- region unloads again it will re-close and re-fire, which is acceptable.
reopenQuestTargets = {
    ["DEN_HarpyMeal-DoneNoInvestigation"] = "HeardBeachSong", -- heard the song; go find the kid
    ["DEN_HarpyMeal-DoneLeftKid"]         = "FoundKid",       -- found the charmed kid on the beach
}

Ext.Osiris.RegisterListener("QuestUpdateUnlocked", 3, "after", function(character, topLevelQuestID, stateID)
    if (not reopenClosedActQuests) then return end
    local target = reopenQuestTargets[topLevelQuestID .. "-" .. stateID]
    if (not target) then return end
    if (devDebugOnly) then
        print_to_file("debug.json", "Reopen attempt: " .. topLevelQuestID .. " " .. stateID .. " -> " .. target)
    end
    Osi.QuestUpdate(character, topLevelQuestID, target)
end)

-- ---------------------------------------------------------------------------
-- Item granting
-- ---------------------------------------------------------------------------

local function process_deathlink_receive(targetChar)
    if (not deathlink) then return end
    local unparsed_deathlink = Ext.IO.LoadFile("deathLinkReceive.json")
    if unparsed_deathlink and unparsed_deathlink ~= "" then
        local death_in = Ext.Json.Parse(unparsed_deathlink)
        if (death_in == nil) then
            print("Failed to parse JSON (deathLinkReceive.json)")
            return
        end
        for k, v in ipairs(death_in) do
            if(v == "DeathLink") then
                pendingReceiveDeathlink = true
                Osi.Die(targetChar)
                Ext.IO.SaveFile("deathLinkReceive.json", "[]")
            end
        end
    end
end

-- Grants a single wire-string entry. Runs under pcall from process_incoming:
-- raising here means "not granted, retry next sync".
local function grant_item(v, targetChar)
    if (string.sub(v, 1, 5) == "Gold-") then
        -- Wire format is Gold-DDDDDD-n (6 zero-padded digits), but accept any
        -- digit count so a future Gold-1500 item doesn't silently grant zero.
        local amount = tonumber(string.match(v, "^Gold%-(%d+)"))
        if (amount) then
            AddGold(targetChar, amount)
        else
            ap_log("Malformed gold entry '" .. v .. "'; granted nothing")
        end
    elseif (string.sub(v, 1, 7) == "LevelUp") then
        local charTable = Osi.DB_Players:Get(nil)
        for char in pairs(charTable) do
            Osi.AddExplorationExperience(charTable[char][1], 1000000)
        end
    elseif (string.sub(v, 1, 5) == "Trap-") then
        if (string.sub(v, 6, 13) == "Monster-") then
            local monstername = string.sub(v, 14, 49)
            local mon = Osi.CreateAtObject(monstername,targetChar,0,0,"",1)
            Osi.SetFaction(mon, "ACT0a_TUT_HelmDevil_0314cde4-8572-4d70-a117-dba88e20e70d")
            Osi.SetHostileAndEnterCombat("ACT0a_TUT_HelmDevil_0314cde4-8572-4d70-a117-dba88e20e70d", Osi.GetFaction(targetChar), mon, targetChar)
        elseif (string.sub(v, 6, 13) == "Bleeding") then
            ApplyStatus(targetChar, "BLEEDING", 10)
        elseif (string.sub(v, 6, 9) == "Stun") then
            ApplyStatus(targetChar, "STUNNED", 5)
        else
            -- Generation strips unimplemented traps, so reaching this means
            -- version skew. Say so instead of silently eating the item.
            ap_log("Trap '" .. v .. "' is not implemented in this mod version; nothing applied")
        end
    elseif (string.sub(v, 1, 5) == "Dupe-") then
        print("Granting dupe item: " .. v)
        TemplateAddTo(string.sub(v, 11), targetChar, 1)
    elseif (string.sub(v, 1, 5) == "Gate-") then
        print("Unlocking location: " .. v)
        if (locationsToGates[v] == nil) then
            ap_log("No gates found for " .. v .. ", skipping")
        else
            for _, gate in pairs(locationsToGates[v]) do
                local uuid, mode = gate[1], gate[2]
                print("Unlocking gate " .. uuid .. " for location " .. v)
                applyGateBlock(uuid, mode, false)
            end
        end
    else
        -- Assume item
        print("Granting item: " .. v)
        TemplateAddTo(v, targetChar, 1)
    end
end

-- The body of the old CastedSpell handler: reads deathlink + ap_in and grants
-- anything not yet granted. Called from the spell listener AND the 250 ms tick.
function process_incoming()
    local targetChar = GetHostCharacter()
    load_options()
    displayNames = nil
    process_deathlink_receive(targetChar)
    local unparsed_in = Ext.IO.LoadFile(itemsInFile)
    if (not unparsed_in) then
        return
    end
    local APSent = PersistentVars['APSent']
    if not APSent then
        APSent = {}
    end
    local failCounts = PersistentVars['APGrantFailures']
    if not failCounts then
        failCounts = {}
    end
    local data_in = Ext.Json.Parse(unparsed_in)
    if (data_in == nil) then
        print("Failed to parse JSON")
        return
    end
    for k, v in ipairs(data_in) do
        if (type(v) ~= "string") then
            ap_log("Ignoring non-string entry #" .. k .. " in " .. itemsInFile)
        elseif (APSent[v] ~= true) then
            -- One bad entry must not block every item after it, forever.
            local ok, err = pcall(grant_item, v, targetChar)
            if (ok) then
                APSent[v] = true
                add_recent(v)
            else
                local n = (failCounts[v] or 0) + 1
                failCounts[v] = n
                if (n <= 5) then
                    ap_log("Failed to grant '" .. v .. "' (attempt " .. n .. "): " .. tostring(err))
                elseif (n == 6) then
                    ap_log("Still failing to grant '" .. v .. "'; will keep retrying quietly")
                end
            end
        end
    end
    PersistentVars['APSent'] = APSent
    PersistentVars['APGrantFailures'] = failCounts
end

Ext.Osiris.RegisterListener("CastedSpell", 5, "after", function(caster, spell, spellType, spellElement, storyActionID)
    if (spell == "Shout_AP_Sync" or syncOnAny) then
        process_incoming()
    end
    if (spell == "Shout_AP_Sync") then
        setBlockedEntrances()
    end
end)

-- ---------------------------------------------------------------------------
-- Presence protocol + repeating tick (design doc section 13)
-- ---------------------------------------------------------------------------

local heartbeatCounter = 0
local lastBeatRaw = nil
local lastBeatAt = nil          -- MonotonicTime ms of last content change
local lastBeatParsed = nil
local sessionLoadedAt = nil
local tickCount = 0
local tickStarted = false

local function write_game_heartbeat()
    heartbeatCounter = heartbeatCounter + 1
    local seed = PersistentVars['SeedName'] or ""
    -- Plain overwrite on purpose: a torn read is harmless (change detection
    -- just retries), and skipping temp+rename halves the metadata churn.
    Ext.IO.SaveFile("heartbeat_game.json", '{"n":' .. heartbeatCounter .. ',"seed":"' .. seed .. '"}')
end

local function check_client_heartbeat()
    local raw = Ext.IO.LoadFile("heartbeat_client.json")
    if (raw ~= nil and raw ~= lastBeatRaw) then
        lastBeatRaw = raw
        lastBeatAt = monotonic_now()
        local parsed = Ext.Json.Parse(raw)
        if (parsed ~= nil) then
            lastBeatParsed = parsed
            if (type(parsed.slot) == "string" and parsed.slot ~= "") then
                apState.slot = parsed.slot
            end
        end
    end
end

local function compute_presence()
    local now = monotonic_now()
    if (now == nil) then return apState.presence end
    if (lastBeatAt == nil) then
        -- Give the client a grace period after load before declaring it gone.
        if (sessionLoadedAt ~= nil and now - sessionLoadedAt < STALE_MS) then
            return "STARTING"
        end
        return "NO_CLIENT"
    end
    if (now - lastBeatAt > STALE_MS) then
        return "NO_CLIENT"
    end
    local p = lastBeatParsed
    if (p ~= nil) then
        if (p.server_connected == false) then
            return "NO_SERVER"
        end
        local seed = PersistentVars['SeedName']
        if (type(p.seed) == "string" and p.seed ~= "" and seed ~= nil and p.seed ~= seed) then
            return "SEED_MISMATCH"
        end
    end
    return "OK"
end

local function in_character_creation()
    local ok, region = pcall(function() return Osi.GetRegion(GetHostCharacter()) end)
    return ok and region == "SYS_CC_I"
end

-- Least-intrusive in-game messaging we could verify: toast for everything,
-- modal only for NO_CLIENT (the one state where the player must act).
local function notify_player(msg, modal)
    pcall(function()
        local host = Osi.GetHostCharacter()
        if (modal and Osi.OpenMessageBox ~= nil) then
            Osi.OpenMessageBox(host, msg)
        elseif (Osi.ShowNotification ~= nil) then
            Osi.ShowNotification(host, msg)
        end
    end)
end

local function update_presence()
    local newState = compute_presence()
    if (newState == apState.presence) then return end
    local old = apState.presence
    apState.presence = newState
    stateDirty = true
    ap_log("AP presence: " .. tostring(old) .. " -> " .. newState)
    if (newState == "STARTING" or in_character_creation()) then return end
    if (newState == "OK") then
        -- Recovery toast only if we previously told the player something was wrong.
        if (old ~= "STARTING") then
            notify_player(PRESENCE_MESSAGES.OK, false)
        end
    elseif (PRESENCE_MESSAGES[newState] ~= nil) then
        notify_player(PRESENCE_MESSAGES[newState], newState == "NO_CLIENT")
    end
end

local function publish_state()
    stateDirty = false
    if (stateChannel == nil) then return end
    local n = 0
    for _ in pairs(PersistentVars['APSent'] or {}) do n = n + 1 end
    apState.items_granted = n
    apState.deathlink = deathlink
    apState.seed = PersistentVars['SeedName']
    local APSent = PersistentVars['APSent'] or {}
    local gates = {}
    for location, _ in pairs(locationsToGates) do
        table.insert(gates, { name = location, unlocked = (APSent[location] == true) or (not blockEntrances) })
    end
    table.sort(gates, function(a, b) return a.name < b.name end)
    apState.gates = gates
    pcall(function() stateChannel:Broadcast(apState) end)
end

local function ap_tick()
    tickCount = tickCount + 1
    if (tickCount % CLIENT_CHECK_TICKS == 0) then
        check_client_heartbeat()
        update_presence()
    end
    local gen = Ext.IO.LoadFile(genInFile)
    if (gen ~= nil) then
        if (gen ~= lastGen) then
            lastGen = gen
            process_incoming()
        end
    elseif (tickCount % FALLBACK_TICKS == 0) then
        -- Old client (or pre-connect): no gen file to short-circuit on, so
        -- fall back to processing every ~3 s instead of never.
        process_incoming()
    end
    if (tickCount % HEARTBEAT_TICKS == 0) then
        write_game_heartbeat()
    end
    if (stateDirty) then
        publish_state()
    end
end

local function schedule_tick()
    Ext.Timer.WaitForRealtime(TICK_MS, function()
        pcall(ap_tick)
        schedule_tick()
    end)
end

function start_ap_tick()
    if (tickStarted) then return end
    if (Ext.Timer == nil or Ext.Timer.WaitForRealtime == nil) then
        print("AP: Ext.Timer unavailable; item delivery falls back to spell-cast sync only")
        return
    end
    sessionLoadedAt = monotonic_now()
    tickStarted = true
    schedule_tick()
end

-- Exposed for test harnesses that drive the tick manually instead of through
-- Ext.Timer (FakeBG3).
function ap_tick_once()
    ap_tick()
end

-- ---------------------------------------------------------------------------
-- In-game window plumbing (HARD blueprint): the server owns all file IPC and
-- publishes compact state to the client context; the window sends commands
-- back. APNet is the tiny wrapper in Shared/APNet.lua (loaded by the
-- bootstraps); when it's absent the mod runs headless exactly as before.
-- ---------------------------------------------------------------------------

local function handle_gui_command(data)
    if (type(data) ~= "table") then return end
    if (data.command == "resync") then
        local seq = (PersistentVars['APCmdSeq'] or 0) + 1
        PersistentVars['APCmdSeq'] = seq
        Ext.IO.SaveFile("ap_command.json", Ext.Json.Stringify({ seq = seq, command = "resync" }))
        ap_log("Resync requested from the in-game window")
    elseif (data.command == "refresh_state") then
        stateDirty = true
    end
end

if (APNet ~= nil) then
    stateChannel = APNet.Channel("AP_State")
    commandChannel = APNet.Channel("AP_Command")
    if (commandChannel ~= nil) then
        commandChannel:SetHandler(function(data, user)
            handle_gui_command(data)
        end)
    end
end

print("Archipelago Client Script Loaded v6")
