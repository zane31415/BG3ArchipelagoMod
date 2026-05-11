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
-- Feature flags default to off; OnSessionLoaded flips them on when the
-- corresponding option is explicitly set in ap_options.json. Defaulting on
-- meant a missing or partial options file (stale seed, version skew, missing
-- key) silently left features enabled, which is the opposite of the
-- Archipelago-wide convention (sc2, pokemon_emerald, wargroove, etc. all
-- default missing slot_data keys to the safe/off value).
syncOnAny = false
logKills = false
logQuests = false
deathlink = false
logContainers = false
pendingReceiveDeathlink = false
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

deathlinkTriggers = {["S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c"] = true,
    ["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = true,
    ["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = true,
    ["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = true,
    ["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = true,
    ["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = true,
    ["S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255"] = true,
    ["S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12"] = true,
    ["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = true,
    ["S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679"] = true}

deathlinkNames = {["S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c"] = "Karlach",
    ["S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba"] = "Minsc",
    ["S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"] = "Minthara",
    ["S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"] = "Halsin",
    ["S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = "Jaheira",
    ["S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"] = "Gale",
    ["S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255"] = "Astarion",
    ["S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12"] = "Laezel",
    ["S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d"] = "Wyll",
    ["S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679"] = "Shadowheart"}

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

-- Read a boolean-ish option out of the parsed ap_options.json table. Missing
-- keys are treated as off (matches Archipelago slot_data conventions); both
-- numeric (0/1) and boolean encodings are accepted so the mod is robust to
-- apworld version skew and to the option file being partial or stale.
local function read_option(data, key)
    if data == nil then return false end
    local v = data[key]
    if v == nil then return false end
    if type(v) == "boolean" then return v end
    if type(v) == "number" then return v ~= 0 end
    return false
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
        syncOnAny = read_option(data, "sync_method")
        logKills = read_option(data, "killsanity")
        logQuests = read_option(data, "questsanity")
        deathlink = read_option(data, "death_link")
        -- containersanity is an in-development apworld feature; preserve the
        -- original semantics (only the "yes really" value 2+ enables logging)
        -- so this change does not silently alter the deferred feature.
        if (data.containersanity ~= nil and data.containersanity ~= 0 and data.containersanity ~= 1) then
            logContainers = true
        end
    end
end

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

Ext.Osiris.RegisterListener("Died", 1, "after", function(died)
    print("Died: " .. tostring(died))
    if (deathlinkTriggers[died]) then
        if (pendingReceiveDeathlink) then
            -- This death was caused by a deathlink we just received from the
            -- server; consume the suppression flag instead of echoing the
            -- death back upstream. Resetting here (rather than after sending)
            -- ensures subsequent local deaths can send again.
            pendingReceiveDeathlink = false
        elseif (deathlink) then
            Ext.IO.SaveFile("deathLinkSend.json", '["' .. deathlinkNames[died] .. '"]')
        end
    end
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

-- Ext.Osiris.RegisterListener("EnteredLevel", 3, "after", ???

Ext.Osiris.RegisterListener("Opened", 1, "after", function(object)
    print("Opened: " .. object)
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
            if (v == topLevelQuestID .. "-" .. stateID) then
                needsToAdd = false
                break
            end
        end
        if (needsToAdd) then
            table.insert(data, object)
            Ext.IO.SaveFile("debug.json", Ext.Json.Stringify(data))
        end
    end
end)

Ext.Osiris.RegisterListener("CharacterCreationFinished", 0, "after", function()
    print("CharCreationDone")
    if (Osi.GetRegion(GetHostCharacter()) == "SYS_CC_I") then
        print("Resetting AP files")
        Ext.IO.SaveFile("ap_out.json", "[]")
        Ext.IO.SaveFile("ap_in.json", "[]")
        Ext.IO.SaveFile("deathLinkSend.json", "[]")
        Ext.IO.SaveFile("deathLinkReceive.json", "[]")
        Ext.IO.SaveFile("debug.json", "[]")
        
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