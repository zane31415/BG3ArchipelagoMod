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
blockEntrances = true
importantKillSet = {
    ["S_HAG_Hag_c457d064-83fb-4ec6-b74d-1f30dfafd12d"] = true, -- Auntie Ethel
    ["S_FOR_Bottomless_SpiderQueen_e6b2f3ba-2d02-4507-8680-6047322e1a4b"] = true, -- Spider Queen
    ["S_UND_PetrifiedDrow_Spectator_39ff8241-fadd-4fbe-ab89-fc5a8b7638a0"] = true, -- Spectator
    ["S_UND_Bulette_307934b5-6fb5-4fdc-a7ff-433a7ba175b3"] = true, -- Bulette
    ["S_UND_Myconid_BroodingSovereign_82af0858-d739-4c9d-84c8-5e6760e22e46"] = true, -- Glut
    ["Kill-S_UND_MyconidSovereign_ea0f222f-eaad-4d83-bbcd-cbae51ccf265"] = true, -- Spaw
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
    ["Gate-Act2"] = {},
    ["Gate-LastLightBasement"] = {},
    ["Gate-ReithwinsMasonsGuild"] = {},
    ["Gate-SharTrials"] = {},
    ["Gate-ProgressiveMoonlightTowers"] = {}
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

function contains(tbl, value)
    for i = 1, #tbl do  -- Iterate from index 1 to the length of the table
        if tbl[i] == value then
            return true -- Value found
        end
    end
    return false -- Value not found after checking all elements
end

local function reset_ap_state()
    Ext.IO.SaveFile(locationOutFile, "[]")
    Ext.IO.SaveFile(itemsInFile, "[]")
    Ext.IO.SaveFile("deathLinkSend.json", "[]")
    Ext.IO.SaveFile("deathLinkReceive.json", "[]")
    Ext.IO.SaveFile("debug.json", "[]")
    PersistentVars['APSent'] = {}
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

function OnSessionLoaded()
    if (PersistentVars['DeathLinkTriggers'] == nil) then 
        PersistentVars['DeathLinkTriggers'] = {["S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c"] = true,
            ["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = true,
            ["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = true,
            ["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = true,
            ["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = true,
            ["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = true,
            ["S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255"] = true,
            ["S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12"] = true,
            ["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = true,
            ["S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679"] = true}
    end
    if (PersistentVars['DeathLinkNames'] == nil) then
        PersistentVars['DeathLinkNames'] = {["S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c"] = "Karlach",
            ["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = "Minsc",
            ["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = "Minthara",
            ["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = "Halsin",
            ["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = "Jaheira",
            ["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = "Gale",
            ["S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255"] = "Astarion",
            ["S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12"] = "Laezel",
            ["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = "Wyll",
            ["S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679"] = "Shadowheart"}
    end


    local unparsed = Ext.IO.LoadFile("ap_options.json")
    if (unparsed) then
        data = Ext.Json.Parse(unparsed)
        if (data == nil) then
            print("Failed to parse JSON")
            return
        end
        syncOnAny = read_option(data, "sync_method")
        logKills = read_option(data, "killsanity")
        logQuests = read_option(data, "questsanity")
        deathlink = read_option(data, "death_link")
        logContainers = false
        blockEntrances = read_option(data, "block_entrances")
        if (data.containersanity ~= nil and data.containersanity ~= 0 and data.containersanity ~= 1) then
            logContainers = true
        end
        local new_seed = data.seed_name
        if (type(new_seed) == "string" and new_seed ~= "") then
            local stored_seed = PersistentVars['SeedName']            
            locationOutFile = new_seed .. "ap_out.json"
            itemsInFile = new_seed .. "ap_in.json"
            if (stored_seed ~= new_seed) then
                print("AP seed_name changed (was " .. tostring(stored_seed) .. ", now " .. new_seed .. "); resetting AP state")
                PersistentVars['SeedName'] = new_seed
                reset_ap_state()
            end
        end
    end
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
                print("Blocking entrance to " .. location .. " via gate " .. uuid)
                applyGateBlock(uuid, mode, true)
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
                Ext.IO.SaveFile("deathLinkSend.json", '["' .. name .. '"]')
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
end)

--Ext.Osiris.RegisterListener("DestroyedBy", 4, "after", function(item, destroyer, destroyerOwner, storyActionId)
    -- Object is the specific GUID string of the entity being destroyed
    -- Template is the root template ID (the item type)
--    print("Destroyed Object UUID: " .. item)
--    if (devDebugOnly) then
--        print_to_file("debug.json", "Object destroyed: " .. item)
--    end
--end)

Ext.Osiris.RegisterListener("Opened", 1, "after", function(object)
    --print("Opened: " .. object)
    if (logContainers) then
        local unparsed = Ext.IO.LoadFile("debug.json")
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
            if (v == object) then
                needsToAdd = false
                break
            end
        end
        if (needsToAdd) then
            table.insert(data, "Opened: " .. object)
            Ext.IO.SaveFile("debug.json", Ext.Json.Stringify(data))
        end
    end
end)

Ext.Osiris.RegisterListener("CharacterCreationFinished", 0, "after", function()
    print("CharCreationDone")
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
        end
    end
end)

Ext.Osiris.RegisterListener("CastedSpell", 5, "after", function(caster, spell, spellType, spellElement, storyActionID)
    targetChar = GetHostCharacter()
    if (spell == "Shout_AP_Sync" or syncOnAny) then
        if (deathlink) then
            local unparsed_deathlink = Ext.IO.LoadFile("deathLinkReceive.json")
            if unparsed_deathlink and unparsed_deathlink ~= "" then
                local death_in = Ext.Json.Parse(unparsed_deathlink)
                if (death_in == nil) then
                    print("Failed to parse JSON")
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
        local unparsed_in = Ext.IO.LoadFile(itemsInFile)
        if (unparsed_in) then
            local APSent = PersistentVars['APSent']
            if not APSent then
                APSent = {}
            end
            local data_in = Ext.Json.Parse(unparsed_in)
            if (data_in == nil) then
                print("Failed to parse JSON")
                return
            end
            for k, v in ipairs(data_in) do
                local isAlreadySent = false
                if (APSent[v] == true) then
                    isAlreadySent = true
                end
                if (not isAlreadySent) then
                    if (string.sub(v, 1, 5) == "Gold-") then
                        local amount = tonumber(string.sub(v, 6, 11)) --Gold-100000-
                        if (amount) then
                            AddGold(targetChar, amount)
                        end
                        APSent[v] = true
                    elseif (string.sub(v, 1, 7) == "LevelUp") then
                        local charTable = Osi.DB_Players:Get(nil)
                        for char in pairs(charTable) do
                            Osi.AddExplorationExperience(charTable[char][1], 1000000)
                        end
                        APSent[v] = true
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
                        end
                        APSent[v] = true
                    elseif (string.sub(v, 1, 5) == "Dupe-") then
                        print("Granting dupe item: " .. v)
                        TemplateAddTo(string.sub(v, 11), targetChar, 1)
                        APSent[v] = true
                    elseif (string.sub(v, 1, 5) == "Gate-") then
                        print("Unlocking location: " .. v)
                        for _, gate in pairs(locationsToGates[v]) do
                            local uuid, mode = gate[1], gate[2]
                            print("Unlocking gate " .. uuid .. " for location " .. v)
                            applyGateBlock(uuid, mode, false)
                        end
                        APSent[v] = true
                    else
                        -- Assume item
                        print("Granting item: " .. v)
                        TemplateAddTo(v, targetChar, 1)
                        APSent[v] = true
                    end
                end
            end
            PersistentVars['APSent'] = APSent
        end
    end
end)
print("Archipelago Client Script Loaded v5")