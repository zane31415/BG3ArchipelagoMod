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
importantKillSet = {
    ["S_HAG_Hag_c457d064-83fb-4ec6-b74d-1f30dfafd12d"] = true, -- Auntie Ethel
    ["S_FOR_Bottomless_SpiderQueen_e6b2f3ba-2d02-4507-8680-6047322e1a4b"] = true, -- Spider Queen
    ["S_UND_PetrifiedDrow_Spectator_39ff8241-fadd-4fbe-ab89-fc5a8b7638a0"] = true, -- Spectator
    ["S_UND_Bulette_307934b5-6fb5-4fdc-a7ff-433a7ba175b3"] = true, -- Bulette
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

importantQuestSet = {
    ["DEN_Conflict-HalsinLeft_KilledLeaders"] = true,
    ["DEN_Conflict-HalsinReturned_Known"] = true,
    ["GLO_Tadpole-HalsinReturned_Known"] = true,
    ["GLO_Tadpole-ReportHalsin_LeadersDefeated"] = true,
    ["SCL_LiftingTheCurse-TalkToThaniel"] = true, -- Thaniel
}

function contains(tbl, value)
    for i = 1, #tbl do  -- Iterate from index 1 to the length of the table
        if tbl[i] == value then
            return true -- Value found
        end
    end
    return false -- Value not found after checking all elements
end

function OnSessionLoaded()
    -- Persistent variables are only available after SessionLoaded is triggered!
--    _P(PersistentVars['APSent'])
    local unparsed = Ext.IO.LoadFile("ap_options.json")
    if (unparsed) then
        data = Ext.Json.Parse(unparsed)
        if (data == nil) then
            print("Failed to parse JSON")
            return
        end
        if (data.sync_method == 0) then
            syncOnAny = false
        end
        if (data.killsanity == 0) then
            logKills = false
        end
        if (data.questsanity == 0) then
            logQuests = false
        end
    end
end

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

Ext.Osiris.RegisterListener("Died", 1, "after", function(died)
    print("Died: " .. died)
end)

Ext.Osiris.RegisterListener("KilledBy", 4, "after", function(defender, attackOwner, attacker, storyActionID)
    if (logKills or importantKillSet[defender]) then
        local unparsed = Ext.IO.LoadFile("ap_out.json")
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
            Ext.IO.SaveFile("ap_out.json", Ext.Json.Stringify(data))
        end
    end
end)

Ext.Osiris.RegisterListener("EnteredLevel", 3, "after", function(object, objectRootTemplate, level)
    --print("EnteredLevel: " .. tostring(object) .. " - " .. tostring(level))
    if (object == GetHostCharacter()) then
        print("EnteredLevel: " .. level)
    end
end)

Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", function(objectTemplate, object2, inventoryHolder, addType)
--    if (inventoryHolder == GetHostCharacter()) then
--        print("TemplateAddedTo: " .. objectTemplate .. " - " .. object2 .. " - " .. inventoryHolder .. " - " .. addType)
--        local unparsed = Ext.IO.LoadFile("items_to_remove.json")
--        local data = {}
--        
--        if (unparsed) then
--            data = Ext.Json.Parse(unparsed)
--            if (data == nil) then
--                print("Failed to parse JSON")
--                return
--            end
--        end
--        local APSent = PersistentVars['APSent']
--        if (contains(data, objectTemplate) and not APSent[objectTemplate]) then
--            print("Shouldn't have that.")
            
--        end
--    end
end)

Ext.Osiris.RegisterListener("CharacterCreationFinished", 0, "after", function()
    print("CharCreationDone")
    if (Osi.GetRegion(GetHostCharacter()) == "SYS_CC_I") then
        print("Resetting AP files")
        Ext.IO.SaveFile("ap_out.json", "[]")
        Ext.IO.SaveFile("ap_in.json", "[]")
        
        PersistentVars['APSent'] = {}
    else
        print("Not in starting area, not resetting AP files: " .. Osi.GetRegion(GetHostCharacter()))
    end
end)

Ext.Osiris.RegisterListener("QuestUpdateUnlocked", 3, "after", function(character, topLevelQuestID, stateID)
    print("QuestUpdateUnlocked " .. character .. " " .. topLevelQuestID .. " " .. tostring(stateID))
    if (logQuests or importantQuestSet[topLevelQuestID .. "-" .. stateID] ) then
        local unparsed = Ext.IO.LoadFile("ap_out.json")
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
            Ext.IO.SaveFile("ap_out.json", Ext.Json.Stringify(data))
        end
    end
end)

Ext.Osiris.RegisterListener("CastedSpell", 5, "after", function(caster, spell, spellType, spellElement, storyActionID)
    targetChar = GetHostCharacter()
    if (spell == "Shout_AP_Sync" or syncOnAny) then
        local unparsed_in = Ext.IO.LoadFile("ap_in.json")
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
                            Osi.SetFaction(mon, "AP_TRAP_FACTION")
                            Osi.SetHostileAndEnterCombat(Osi.GetFaction(mon), Osi.GetFaction(targetChar), mon, targetChar)
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