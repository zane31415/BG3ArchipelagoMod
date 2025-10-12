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
    ["S_CRE_Templar_378ac93e-03a0-40b4-904c-f37989ac7a8c"] = true
}

importantQuestSet = {
    ["DEN_Conflict-HalsinLeft_KilledLeaders"] = true,
    ["DEN_Conflict-HalsinReturned_Known"] = true,
    ["GLO_Tadpole-HalsinReturned_Known"] = true,
    ["GLO_Tadpole-ReportHalsin_LeadersDefeated"] = true
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
    if (logKills) then
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