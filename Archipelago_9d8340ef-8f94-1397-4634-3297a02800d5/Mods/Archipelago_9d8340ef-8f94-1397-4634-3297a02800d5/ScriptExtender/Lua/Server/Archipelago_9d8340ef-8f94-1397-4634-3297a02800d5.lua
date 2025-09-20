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

Ext.Osiris.RegisterListener("KilledBy", 4, "after", function(defender, attackOwner, attacker, storyActionID)
    local unparsed_kills = Ext.IO.LoadFile("killed_log.json")
    if (unparsed_kills) then
        local parsed_kills = Ext.Json.Parse(unparsed_kills)
        table.insert(parsed_kills, defender)
        Ext.IO.SaveFile("killed_log.json", Ext.Json.Stringify(parsed_kills))
    end
end)

Ext.Osiris.RegisterListener("CharacterCreationFinished", 0, "after", function()
    print("CharCreationDone")
    Ext.IO.SaveFile("ap_out.json", "[]")
    Ext.IO.SaveFile("ap_in.json", "[]")
    --Ext.IO.SaveFile("killed_log.json", "[]")
end)

Ext.Osiris.RegisterListener("QuestUpdateUnlocked", 3, "after", function(character, topLevelQuestID, stateID)
    print("QuestUpdateUnlocked " .. character .. " " .. topLevelQuestID .. " " .. tostring(stateID))

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
end)

Ext.Osiris.RegisterListener("CastedSpell", 5, "after", function(caster, spell, spellType, spellElement, storyActionID)
    if (spell == "Shout_AP_Sync") then
        local unparsed_in = Ext.IO.LoadFile("ap_in.json")
        if (unparsed_in) then
            local APModVars = Ext.Vars.GetModVariables(ModuleUUID)
            if not APModVars.Sent then
                APModVars.Sent = {}
            end
            local data_in = Ext.Json.Parse(unparsed_in)
            if (data_in == nil) then
                print("Failed to parse JSON")
                return
            end
            for k, v in ipairs(data_in) do
                local isAlreadySent = false
                if (APModVars.Sent[v] == true) then
                    isAlreadySent = true
                end
                if (not isAlreadySent) then
                    if (string.sub(v, 1, 5) == "Gold-") then
                        local amount = tonumber(string.sub(v, 6, 11)) --Gold-100000-
                        print("Granting gold: " .. tostring(amount))
                        if (amount) then
                            AddGold(GetHostCharacter(), amount)
                        end
                        APModVars.Sent[v] = true
                    elseif (string.sub(v, 1, 7) == "LevelUp") then
                        print("Granting exp")
                        local charTable = Osi.DB_Players:Get(nil)
                        for char in pairs(charTable) do
                            Osi.AddExplorationExperience(charTable[char][1], 1000000)
                        end
                        APModVars.Sent[v] = true
                    else
                        -- Assume item
                        print("Granting item: " .. v)
                        TemplateAddTo(v, GetHostCharacter(), 1)
                        APModVars.Sent[v] = true
                    end
                end
            end
        end
    end
end)
print("Archipelago Client Script Loaded v4")