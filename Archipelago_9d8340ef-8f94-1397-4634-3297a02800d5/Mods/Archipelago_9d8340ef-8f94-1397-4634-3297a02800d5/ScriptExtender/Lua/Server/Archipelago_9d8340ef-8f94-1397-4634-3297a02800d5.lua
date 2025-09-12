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

Ext.Osiris.RegisterListener("CharacterCreationFinished", 0, "after", function()
    print("CharCreationDone")
    Ext.IO.SaveFile("ap_out.json", "[]")
    Ext.IO.SaveFile("ap_in.json", "[]")
    Ext.IO.SaveFile("sent.json", "[]")
end)

Ext.Osiris.RegisterListener("QuestUpdateUnlocked", 3, "after", function(character, topLevelQuestID, stateID)
    print("QuestUpdateUnlocked " .. character .. " " .. topLevelQuestID .. " " .. tostring(stateID))
    --local avatars = Ext.Entity.GetAllEntitiesWithComponent("UserAvatar")
    --for i, avatar in ipairs(avatars) do
        --print("Avatar: " .. tostring(avatar))
        --if (avatar.UserAvatarComponent.Character == character) then
        --    print("Found avatar for " .. character)
        --    break
        --end
    --end

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
        print("Adding quest state to ap_out.json: " .. topLevelQuestID .. "-" .. stateID)
        table.insert(data, topLevelQuestID .. "-" .. stateID)
        Ext.IO.SaveFile("ap_out.json", Ext.Json.Stringify(data))
    end
end)

Ext.Osiris.RegisterListener("CastedSpell", 5, "after", function(caster, spell, spellType, spellElement, storyActionID)
    if (spell == "Shout_AP_Sync") then
        local unparsed_in = Ext.IO.LoadFile("ap_in.json")
        local unparsed_sent = Ext.IO.LoadFile("sent.json")
        local parsed_sent = {}
        if (unparsed_sent) then
            parsed_sent = Ext.Json.Parse(unparsed_sent)
            if (parsed_sent == nil) then
                print("Failed to parse sent.json")
            end
        end
        if (unparsed_in) then
            local data_in = Ext.Json.Parse(unparsed_in)
            if (data_in == nil) then
                print("Failed to parse JSON")
                return
            end
            for k, v in ipairs(data_in) do
                local isAlreadySent = false
                for _, sentItem in ipairs(parsed_sent) do
                    if (v == sentItem) then
                        isAlreadySent = true
                        break
                    end
                end
                if (not isAlreadySent) then
                    if (string.sub(v, 1, 5) == "Gold-") then
                        local amount = tonumber(v:sub(6))
                        print("Granting gold: " .. tostring(amount))
                        if (amount) then
                            AddGold(GetHostCharacter(), amount)
                        end
                    elseif (string.sub(v, 1, 7) == "LevelUp") then
                        print("Granting exp")
                        Osi.AddExplorationExperience(GetHostCharacter(), 1000000)
                    else
                        -- Assume item
                        print("Granting item: " .. v)
                        TemplateAddTo(v, GetHostCharacter(), 1)
                    end
                    table.insert(parsed_sent, v)
                end
            end
        end
        Ext.IO.SaveFile("sent.json", Ext.Json.Stringify(parsed_sent))
    end
end)
print("Archipelago Client Script Loaded v2")