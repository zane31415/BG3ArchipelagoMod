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

-- Build version of THIS file. Client/APGui.lua carries its own copy of the
-- same literal and compares the two: the version deliberately is not in a
-- shared file, because the failure this catches is one script being stale
-- while the other is current (a loose .lua under Data\Mods overriding the
-- pak's copy, or a second install). A shared constant would agree with
-- itself and catch nothing. Bump both files together.
AP_SCRIPT_VERSION = "0.8.0"

syncOnAny = true
logKills = true
logQuests = true
deathlink = true
surviveOnDeathlink = true
killsanityStrictness = 1
devDebugOnly = false
logContainers = false
-- ap_options.json "container_highlight": glow every unopened container near the
-- party. Independent of containersanity. See the "Container highlight" section.
containerHighlight = false
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
    ["S_MOO_Ketheric_e9918f3e-5b87-40a3-a9bd-61545151573f"] = true, -- Myrkul
    -- Act 3 bosses to be added here
    ["S_WYR_SkeletalDragon_67770922-5e0a-40c5-b3f0-67e8eb50493a"] = true, -- Ansur
    ["S_LOW_FatherCarrion_b003409c-364f-4065-94bf-7436001d890e"] = true, -- Mystic Carrion
    ["S_LOW_CountingHouse_JaheiraClone_4da802f5-3237-40b8-afff-d728016e3047"] = true, -- 'Jaheira'
    ["S_LOW_Elfsong_GithyankiShield_Paladin_54467aa9-33dd-41c4-bd77-87a71ed22c16"] = true, -- Ch'r'ai Har'rak
    ["S_LOW_Lorroakan_a9d4b71d-b0ef-429e-8210-6dc8be986ee9"] = true, -- Lorroakan
    ["S_GLO_Monitor_f65becd6-5cd7-4c88-b85e-6dd06b60f7b8"] = true, -- Raphael
    ["S_LOW_MurderTribunal_Sarevok_ae9f784a-ea64-4297-95a7-8377e85231b6"] = true, -- Sarevok
    ["S_GLO_Cazador_2f1880e6-1297-4ca3-a79c-9fabc7f179d3"] = true, -- Cazador
    ["S_LOW_SteelWatcher_Prototype_51db791d-4378-448a-86ba-3e3ae2748db6"] = true, -- Steel Watcher Titan
    ["S_LOW_Viconia_b1ea974d-96fb-47ca-b6d9-9c85fcb69313"] = true, -- Viconia
    ["S_GLO_Orin_bf24e0ec-a3a6-4905-bd2d-45dc8edf8101"] = true, -- Orin
    ["S_GLO_Gortash_b878a854-f790-4999-95c4-3f20f00f65ac"] = true, -- Gortash
    ["S_END_MindBrain_f8bb04a3-22e5-41b0-aed7-5dcf852343d1"] = true, -- Netherbrain
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
        {"DOOR_Single_Dungeon_Abbey_B_029_e815e895-45dc-47cd-a011-4172c258e799", GATE_BLOCK.CAN_INTERACT}, -- back side door C(1)
        {"S_MOO_DockDoor_ada141ae-e0a8-4915-a9c7-355093370992", GATE_BLOCK.CAN_INTERACT}, --prison (2)
        {"S_MOO_StairsToPrison_78b1cd2c-0edb-441d-a389-6163ba7dba48", GATE_BLOCK.CAN_INTERACT}}, -- prison (2)
    ["Gate-ProgressiveMoonlightTowers-1"] = {
        {"S_MOO_RoofAccessDoor_0eca4cd0-6fa5-421f-80e9-446c2b758606", GATE_BLOCK.CAN_INTERACT}}, -- roof (3)
    ["Gate-ProgressiveMoonlightTowers-2"] = {
        {"S_MOO_TentaclelessTeleporter_c29cec63-82da-4579-b11d-75a5a08bbe1b", GATE_BLOCK.CAN_INTERACT}, -- colony (4)
        {"S_COL_Elevator_Controller_38c76a3f-beaf-417b-be7e-62773c705c8f", GATE_BLOCK.CAN_INTERACT}, -- Myrkul elevator (5)
        {"S_COL_KethericShowdown_Door_378bd363-b818-4326-9883-d5a9cd5a1fcc", GATE_BLOCK.CAN_INTERACT} -- Myrkul door (5)
    },
    ["Gate-Act3"] = {{"S_TWN_ActExit_4df293a7-c9b7-4be4-b4a9-42400ddbe209", GATE_BLOCK.CAN_INTERACT}},
    ["Gate-LowerCityEast"] = {
        {"S_WYR_LevelSwapTeleporter_Heapside_e10905f8-7b12-491f-aedb-bb9300cf721c", GATE_BLOCK.CAN_INTERACT}  -- Wyrm's Rock north transition to the Lower City
    },
    ["Gate-LowerCitySewers"] = {
        {"S_Teleport_DEC_GEN_Manhole_B_001_2088da19-8d27-4331-9602-11bdf78f7769", GATE_BLOCK.CAN_INTERACT}, -- manhole, Lower City East
        {"S_Door_Teleport_Guildhall_Exit_de4a18e0-4cfa-413e-bee6-978e459421a6", GATE_BLOCK.CAN_INTERACT}, -- Guildhall entrance, Lower City East
        {"S_LOW_DevilsFee_HatchToBasement_6fb8cf28-dfe1-4259-8ccb-59ce7f805f28", GATE_BLOCK.CAN_INTERACT}, -- Devil's Fee hatch
        {"S_LOW_KurwinCoffin_TeleportMound_8712c8d1-c013-4b6c-b626-0dcd66c85830", GATE_BLOCK.CAN_INTERACT}, -- graveyard mound
        {"S_Teleport_DEC_GEN_Manhole_B_000_9be87997-ac69-48ca-b78b-7f2ca4525a87", GATE_BLOCK.CAN_INTERACT}, -- manhole, Lower City Central
        {"S_Teleport_DEC_GEN_Manhole_A_000_b08b830a-a6f0-4b68-9cf3-09af8f6cabe0", GATE_BLOCK.CAN_INTERACT}, -- manhole by Heapside prison
        {"S_DOOR_Invisible_Prison_ToiletEscape_93f71101-6b75-42d6-be2d-2b579e619e8e", GATE_BLOCK.CAN_INTERACT}, -- Heapside prison toilet escape
        {"S_DOOR_Hatch_Dungeon_Abbey_A_000_71d4d617-de81-4582-9428-9ce94af0d4b6", GATE_BLOCK.CAN_INTERACT}, -- gardener's store room hatch, Lower City West
        {"S_DOOR_Invisible_WarehouseDocksBasement_to_Sewer_956e5881-43b4-4283-939b-d773829a73ef", GATE_BLOCK.CAN_INTERACT}, -- Flymm Cargo basement (iron_throne) to sewers
        {"S_Teleport_HatchElfsongBasement_965b224a-50aa-4b5a-a330-a20e0281381c", GATE_BLOCK.CAN_INTERACT}, -- Knights of the Shield hideout (elfsong_basement) to sewers
        {"S_DOOR_Invisible_A_CazadorSecret_toSewer_fab6923e-6e2f-4ae3-8427-e0a2d1a4a471", GATE_BLOCK.CAN_INTERACT}  -- Cazador's dungeon to sewers
    },
    ["Gate-ElfsongBasement"] = {
        {"S_HatchtoElfsongbasement_5755d423-07b6-4dd1-845c-23eff0bdf854", GATE_BLOCK.CAN_INTERACT}, -- Elfsong Tavern hatch
        {"S_Teleport_Ladder_SewerKoS_0cde8901-1428-4522-98eb-97351ee4a31a", GATE_BLOCK.CAN_INTERACT}  -- sewers ladder into the Knights of the Shield hideout
    },
    ["Gate-SorcerousSundries"] = {
        {"S_LOW_PortalToRamazith_74a258c4-774f-49d2-a673-1389bca439b5", GATE_BLOCK.CAN_INTERACT}, -- shop floor to Ramazith's Tower
        {"S_SorcSundries_BasementTeleport_001_e3a08981-e43d-4a41-94dc-7af1aa378ece", GATE_BLOCK.CAN_INTERACT}, -- Sorcerous Sundries shop basement to the ruins
    },
    ["Gate-HouseOfHope"] = {
        {"S_LOW_DevilsFee_PortalToHouseOfHope_839e5ee7-1793-4a43-9e91-6da575e188ac", GATE_BLOCK.CAN_INTERACT}  -- Devil's Fee portal
    },
    ["Gate-MurderTribunal"] = {
        {"S_LOW_MurderTribunal_CellarDoor_1aa896d7-f2ad-4430-ab90-2dd00c876145", GATE_BLOCK.CAN_INTERACT}, -- Cundahollow house cellar door
        {"S_LOW_MurderTribunal_Bookcase_Button_2e18ba69-b6b1-486e-8acf-c24e32dac5b6", GATE_BLOCK.CAN_INTERACT}  -- bookcase button that opens it
    },
    ["Gate-BlushingMermaid"] = {
        {"S_LOW_BlushingMermaid_CellarDoor_Upstairs_25633b00-cb37-43a6-97cc-707c1f9f4b83", GATE_BLOCK.CAN_INTERACT}, -- tavern to cellar
        {"S_LOW_BlushingMermaid_CellarDoor_Upstairs_2_3d43d839-e612-468a-8c9b-c186febce1cf", GATE_BLOCK.CAN_INTERACT}, -- tavern to cellar
        {"S_BlushingMermaidCellar_SideDoor_105c39e8-cd7d-4916-bd05-72d8356005cd", GATE_BLOCK.CAN_INTERACT}, -- cellar side door
        {"S_DOOR_BlushingMermaidCellar_Slider_169715a2-b2ee-4551-a110-d8caf1a11d04", GATE_BLOCK.CAN_INTERACT}  -- cellar sliding door
    },
    ["Gate-CazadorPalace"] = {
        {"S_LOW_CazadorsPalace_BackHallDoor_5021c572-3a48-4fc4-ad7e-40e48fc3f8ed", GATE_BLOCK.CAN_INTERACT}, -- Central to the palace
        {"S_DOOR_Invisible_A_CazadorSecret_toDungeon_61cebd40-b770-4f29-9090-fa0b6777b1e4", GATE_BLOCK.CAN_INTERACT}, -- sewers to Cazador's dungeon
        {"S_Ladder_Metal_10n5H_A_CazPayload_8f8aa7ee-09fa-48a8-b666-44e5d1862207", GATE_BLOCK.CAN_INTERACT}, -- Baldur's Mouth basement to the palace
        {"S_CazadorHatchFirst_eca68075-da13-41bc-8567-1cab78d6739e", GATE_BLOCK.CAN_INTERACT}  -- attic crawlspace to the palace
    },
    ["Gate-CountingHouse"] = {
        {"S_DOORTELEPORT_Vault_000_38d32292-889b-4f3d-9841-ca318376ee06", GATE_BLOCK.CAN_INTERACT}  -- Counting House lobby to the vaults
    },
    ["Gate-SteelWatchFoundry"] = {
        {"S_LOW_DoorToDriverPrep_f50c202f-70c4-4b4e-8951-400de6b1a2bb", GATE_BLOCK.CAN_INTERACT}, -- foundry ground floor into the works
        {"S_LOW_ElevatorToInstallRoom_a637edb4-a14c-47f8-a4b8-e900ea1af5a2", GATE_BLOCK.CAN_INTERACT}, -- elevator into the works
        {"S_LOW_FoundryFrontDoor_98556121-7aba-4b50-9336-e183b9906650", GATE_BLOCK.CAN_INTERACT}, -- front door (to the security office floor)
        {"S_LOW_FoundryFenceGateSide_4fe3e877-380c-4878-a112-bfa53c83fe09", GATE_BLOCK.CAN_INTERACT}, -- side fence gate
        {"S_LOW_FoundryVent_Outside_f96e5a1c-d778-4eeb-a5a5-b2a02f471cca", GATE_BLOCK.CAN_INTERACT}  -- vent
    },
    ["Gate-HouseOfGrief"] = {
        {"S_LOW_GriefEntrance_af780377-dc6e-4350-be13-3cdeeb93f20f", GATE_BLOCK.CAN_INTERACT}, -- front entrance
        {"S_LOW_GriefDoor_1aa5ac36-b156-4efe-8214-2056381e5f0a", GATE_BLOCK.CAN_INTERACT}, -- door
        {"S_DOOR_Invisible_A_ToGrotto_fb614206-fede-4849-969c-a2f71ab33c6a", GATE_BLOCK.CAN_INTERACT}  -- house to the Sharran grotto
    },
    ["Gate-UndercityRuins"] = {
        {"S_TELEPORT_Ladder_AncientLairExit_2cd95e02-7524-4705-a789-5632922a1a7a", GATE_BLOCK.CAN_INTERACT}  -- Ancient Lair exit ladder
    },
    ["Gate-AncientLair"] = {
        {"S_DOOR_Invisible_AncientLair_000_c1e919e0-997c-4848-b2a8-bd59a382a892", GATE_BLOCK.CAN_INTERACT}, -- sewers to the lair
        {"DOOR_CTY_AncientLairEscape_001_d90256b6-5ec5-427f-a819-b0a9a74deb35", GATE_BLOCK.CAN_INTERACT}, -- Undercity Ruins to the lair
        {"S_LOW_AncientLairEntranceDoor_13b8694c-dd66-486d-8487-3e7561e0ba21", GATE_BLOCK.CAN_INTERACT}  -- lair entrance door
    },
    ["Gate-Endgame"] = {
        {"S_END_ToMorphicPoolBoat_82964763-8581-4980-86b1-1ceeb287f43f", GATE_BLOCK.CAN_INTERACT}  -- the boat
    },
}

shouldSpawnMonster = false

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
    ["ORI_Avatar_ShadowHeart-SharPath_DefeatedViconia"] = true,
    ["ORI_Avatar_ShadowHeart-EnemyOfShar_DefeatedViconia"] = true,

}

requireKill = {
    ["S_CHA_FL0_DeadSkeleton_Caster_04_cb4c2c8f-b6db-4c53-b7e3-395aef311a39"] = true,
    ["S_CHA_FL0_DeadSkeleton_Caster_03_462f0982-35c4-4a34-a3bf-399f37e686ee"] = true,
    ["S_CHA_FL0_DeadSkeleton_Caster_02_1535feb9-7ff9-4132-be09-191ba3f8c2e1"] = true,
    ["S_CHA_FL0_DeadSkeleton_Caster_01_7af3fa6c-7f7a-4920-acaf-f091e7c62373"] = true,
    ["S_CHA_FL0_DeadSkeleton_Melee_01_ebf854f1-7971-4f81-a2b7-e4b79b550b85"] = true,
    ["S_LOW_AncientLairMummy_005_331ffe6e-00c9-4f79-94d4-c6d65b4a9093"] = true,
    ["S_LOW_AncientLairMummy_001_65b33bdc-3126-4962-a712-4175007d9e54"] = true,
    ["S_LOW_AncientLairMummy_003_6d04276b-aefd-43a2-a2f0-eb586bcfc881"] = true,
    ["S_LOW_AncientLairMummy_002_6f71be30-7cab-43a7-999d-12b9adde5a0e"] = true,
    ["S_LOW_AncientLairMummy_004_d526d72a-599c-464e-b7fe-84128d496b3c"] = true,
    ["S_LOW_AncientLair_CrawlingClaw_006_2928d81e-4ceb-466f-95a4-a774b35a4c83"] = true,
    ["S_LOW_AncientLair_CrawlingClaw_005_387ea8f7-eed3-46b0-81bc-a2ecc280550c"] = true,
    ["S_LOW_AncientLair_CrawlingClaw_004_461234ed-2457-417b-b850-7dffb9d57498"] = true,
    ["S_LOW_AncientLair_CrawlingClaw_000_7f5d8047-66dd-4cec-a992-98d7fe7d9263"] = true,
    ["S_LOW_AncientLair_CrawlingClaw_002_8aa6c119-d8f2-4c47-877b-425645df061c"] = true,
    ["S_LOW_AncientLair_CrawlingClaw_001_b174f4f8-7a3e-49d9-90c4-a254bbee9c41"] = true,
    ["S_LOW_AncientLair_CrawlingClaw_008_bfaacde1-8b90-4846-b474-5d8f8f81c4f6"] = true,
    ["S_LOW_AncientLair_CrawlingClaw_003_dfb5ea37-aebf-45c5-a658-d69534414132"] = true,
    ["S_LOW_AncientLair_CrawlingClaw_007_fdc82f15-f593-4f03-a9da-26505e66e8e1"] = true,
    ["S_LOW_AncientLair_GreaterZombie_001_64b89b9c-657a-40d3-8232-3931e6c72aaf"] = true,
    ["S_LOW_AncientLair_GreaterZombie_002_ba701b3d-20ec-4225-8a69-3a8be31b4c4f"] = true,
    ["S_LOW_AncientLair_GreaterZombie_000_bd8ab705-e59e-44b1-89fa-df0dc41cd563"] = true,
}

cinematicKill = {
    ["S_GLO_Cazador_2f1880e6-1297-4ca3-a79c-9fabc7f179d3"] = true,
    ["S_LOW_Viconia_b1ea974d-96fb-47ca-b6d9-9c85fcb69313"] = true,
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
-- Push state to the in-game window on this many heartbeats after a load, changed
-- or not. The window's own request at session load can arrive before this
-- script is listening, and with nothing changing afterwards the window sat on
-- "server script not responding" until the player pressed Resync.
local STARTUP_STATE_PUSHES = 6
local startupStatePushes = STARTUP_STATE_PUSHES

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
    surviveOnDeathlink = true,
    script_version = AP_SCRIPT_VERSION,
    net_mode = nil,         -- filled at publish; window flags a mismatch
    recent = {},            -- newest first: { name = ..., t = "HH:MM:SS" }
    log = {},               -- newest first, plain strings
    gates = {},             -- { name = "Gate-...", unlocked = bool }, filled at publish
}
local stateDirty = false
local stateChannel = nil
local commandChannel = nil

-- print_to_file logs (debug.json). Ext.IO has no append, and re-reading and
-- re-parsing the whole file for every line hitched the server once the file
-- reached ~1 MB, so lines are kept in memory and the file is rewritten from
-- ap_tick on the heartbeat cadence, only when something was logged.
local logBuffers = {}          -- filename -> { lines = {...}, dirty = bool } or { broken = true }
local logFlushOnTick = false   -- false until the tick runs: write through immediately

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
    logBuffers["debug.json"] = { lines = {}, dirty = false }
    PersistentVars['APSent'] = {}
    PersistentVars['APGrantFailures'] = {}
    PersistentVars['ContainersOpened'] = {}
    PersistentVars['HighlightOpened'] = {}
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

local function log_buffer(filename)
    local buf = logBuffers[filename]
    if (buf ~= nil) then return buf end
    -- First line since this Lua state was created: pick up what earlier
    -- sessions wrote, once, so the file keeps accumulating across sessions.
    buf = { lines = {}, dirty = false }
    local unparsed = Ext.IO.LoadFile(filename)
    if (unparsed) then
        local ok, data = pcall(Ext.Json.Parse, unparsed)
        if (ok and type(data) == "table") then
            buf.lines = data
        else
            -- Leave an unreadable file alone rather than overwrite it.
            print("Failed to parse JSON")
            buf = { broken = true }
        end
    end
    logBuffers[filename] = buf
    return buf
end

local function flush_log_buffers()
    for filename, buf in pairs(logBuffers) do
        if (buf.dirty) then
            buf.dirty = false
            Ext.IO.SaveFile(filename, Ext.Json.Stringify(buf.lines))
        end
    end
end

local function print_to_file(filename, text)
    local buf = log_buffer(filename)
    if (buf.broken) then return end
    table.insert(buf.lines, text)
    buf.dirty = true
    if (not logFlushOnTick) then flush_log_buffers() end
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
    surviveOnDeathlink = read_option(data, "death_link_consequence")
    devDebugOnly = read_option(data, "dev_debug_on")
    killsanityStrictness = data.killsanity_strictness
    if (killsanityStrictness == nil) then
        killsanityStrictness = 1
    end
    logContainers = false
    blockEntrances = read_option(data, "block_entrances")
    containerHighlight = read_option(data, "container_highlight")
    if (type(data.companion_shuffle) == "table") then
        companionShuffle = data.companion_shuffle
    else
        companionShuffle = nil
    end
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
    -- A companion-shuffle outfit whose equip timer was cut off by a save/quit
    -- gets another go (see apply_pending_outfits).
    for _, st in pairs(PersistentVars['CompanionShuffle'] or {}) do
        if (st.outfit == "applying") then st.outfit = "pending" end
    end
    load_options()
    recount_checks()
    start_ap_tick()
end

Ext.Osiris.RegisterListener("GameModeStarted", 3, "after", function(gameMode, isMainThread, something)
    setBlockedEntrances()
    -- Not SessionLoaded: that fires before the Osiris story is running, and the
    -- Osi.GetFlag inside threw "Attempted to call Osiris function in restricted
    -- context", which aborted the rest of OnSessionLoaded - including
    -- start_ap_tick, so the heartbeat and the fast bus never started.
    -- TODO: this only clears the flag once per session. If the story can set
    -- Act2_PointOfNoReturnReached mid-play, a FlagSet listener is also needed.
    -- Not handling that now; see docs/story-lockout-map.md.
    clearPointOfNoReturn()
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

local summonNoiseFilter = { "Cat_MinorIllusion", "SpiderFamiliar", "CrabFamiliar", "CatFamiliar", "FrogFamiliar", "RatFamiliar" }
local function is_summon_noise(character)
    for _, prefix in ipairs(summonNoiseFilter) do
        if (string.sub(character, 1, #prefix) == prefix) then
            return true
        end
    end
    return false
end

Ext.Osiris.RegisterListener("Died", 1, "after", function(died)
    if(is_summon_noise(died)) then
        -- Don't log familiar kills, they're just noise
        return
    end
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
    if ((logKills or importantKillSet[died]) and ((killsanityStrictness == 2 and requireKill[died] ~= true) or cinematicKill[died] == true)) then
        local unparsed = Ext.IO.LoadFile(locationOutFile)
        local data = {}
        print("Logging kill: " .. "Kill-" .. died)

        if (unparsed) then
            data = Ext.Json.Parse(unparsed)
            if (data == nil) then
                print("Failed to parse JSON")
                return
            end
        end
        local needsToAdd = true
        for k, v in ipairs(data) do
            if (v == "Kill-" .. died) then
                needsToAdd = false
                break
            end
        end
        if (needsToAdd) then
            table.insert(data, "Kill-" .. died)
            Ext.IO.SaveFile(locationOutFile, Ext.Json.Stringify(data))
            apState.checks_logged = apState.checks_logged + 1
            stateDirty = true
        end
    end
end)

Ext.Osiris.RegisterListener("KilledBy", 4, "after", function(defender, attackOwner, attacker, storyActionID)
    if(is_summon_noise(defender)) then
        -- Don't log familiar kills, they're just noise
        return
    end
    if ((logKills or importantKillSet[defender]) and (killsanityStrictness ~= 2 or requireKill[defender] == true)) then
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
    -- UnlockWaypoint is (name, teleport trigger, character) - unlike LockWaypoint
    -- it wants the trigger, which the story keeps in
    -- DB_WaypointInfo(group, waypointID, item, trigger).
    local ok, rows = pcall(function() return Osi.DB_WaypointInfo:Get(nil, waypointID, nil, nil) end)
    if ((not ok) or type(rows) ~= "table" or rows[1] == nil) then
        print("LockWaypoint revert: no DB_WaypointInfo row for " .. tostring(waypointID))
        return
    end
    Osi.UnlockWaypoint(waypointID, rows[1][4], player)
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

-- Does this object own an inventory? That is the only honest definition of
-- "container" we have: a chest, a sack, a bookshelf and a wardrobe all own one,
-- while a door, a ladder, a chair and a potion do not. Osi.IsContainer was tried
-- first and errors on a nil value, so this goes at the entity instead.
--
-- Three-state on purpose - true / false / nil for "this build cannot tell me" -
-- because the two callers want to fail in opposite directions. Component names
-- have moved between Script Extender versions, so unknown names are probed
-- rather than assumed, and anything that throws lands on nil.
local INVENTORY_COMPONENTS = { "InventoryOwner", "InventoryContainer" }

-- A read that comes back nil is ambiguous: this entity has no inventory, OR
-- this build renamed the component and every read will be nil forever. Telling
-- those apart is the difference between filtering doors and silently dropping
-- every container in the game, so "no" is only ever returned once the build has
-- proved it can say "yes" at least once. Until then the answer is "unknown" and
-- each caller falls back the way it prefers. One real container flips the latch.
local inventoryProbeProven = false

local function has_inventory(object)
    if (type(object) ~= "string") then return nil end
    if (Ext == nil or Ext.Entity == nil or Ext.Entity.Get == nil) then return nil end

    local ok, entity = pcall(Ext.Entity.Get, object)
    if ((not ok) or entity == nil) then return nil end

    for _, name in ipairs(INVENTORY_COMPONENTS) do
        local got, component = pcall(function() return entity[name] end)
        if (got and component ~= nil) then
            inventoryProbeProven = true
            return true
        end
    end

    if (not inventoryProbeProven) then return nil end
    return false
end

-- Osiris fires "Opened" for doors too, and a door is never an AP location: in
-- one player's out-file 306 of 544 "Container-" entries were objects the
-- apworld has never heard of, mostly doors. Filter them here so the out-file
-- stays the size of the actual check list. Fail OPEN when has_inventory cannot
-- tell - reporting a door costs nothing (the client drops uuids it does not
-- know), dropping every container would be silent and total.
local function is_container(object)
    local inventory = has_inventory(object)
    if (inventory == nil) then return true end
    return inventory
end

-- Shared by the Opened and TemplateUseStarted listeners: both mean "the player
-- got this container's inventory", they just fire for different object kinds.
local function record_container(uuid, object)
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
end

Ext.Osiris.RegisterListener("Opened", 1, "after", function(object)
    if (not logContainers) then return end
    if (devDebugOnly) then
        print_to_file("debug.json", "Opened: " .. tostring(object))
    end

    local uuid = container_uuid(object)
    if (uuid == nil) then return end
    if (not is_container(object)) then
        if (devDebugOnly) then
            print_to_file("debug.json", "Not a container, ignoring: " .. tostring(object))
        end
        return
    end
    record_container(uuid, object)
end)

-- A smashed container can never be opened, so without this the check is simply
-- lost: Mouldering Caskets in particular tend to break rather than open, and an
-- AoE through a room takes every barrel and crate with it.
--
-- The inventory gate is the same fail-open one "Opened" uses, and it matters
-- more here: DestroyedBy fires for EVERY destroyed item - potions, weapons,
-- chairs, doors - not just containers. Whether has_inventory() can still answer
-- at this point is unverified: Osiris fires this "after" the destruction, so the
-- entity may already be gone, in which case the probe returns nil, the gate fails
-- open and junk uuids reach ap_out.json. That is harmless (the client drops uuids
-- it cannot resolve) but it is noise, so the outcome is logged under dev_debug_on:
-- if the log shows "gate=nil" for a chest that visibly held loot, the probe is
-- useless here and this wants a different discriminator.
Ext.Osiris.RegisterListener("DestroyedBy", 4, "after", function(item, destroyer, destroyerOwner, storyActionID)
    if (not logContainers) then return end

    local uuid = container_uuid(item)
    if (uuid == nil) then return end

    local inventory = has_inventory(item)
    if (devDebugOnly) then
        local gate = "nil"
        if (inventory == true) then gate = "true" elseif (inventory == false) then gate = "false" end
        print_to_file("debug.json", "Destroyed: " .. tostring(item) .. "  gate=" .. gate)
    end
    if (inventory == false) then return end

    record_container(uuid, item)
end)

-- Bookrows, shelves, racks and vases hand the player an inventory but never
-- raise Osiris "Opened" - only Use/TemplateUse. Without this listener the
-- OBJ_Bookrow / OBJ_PotionShelf / OBJ_Vase families (3280 of the 10712 rows in
-- containers.py, 66 of the 68 objects in the Dank Crypt alone) can never be
-- checked. TemplateUseStarted fires for *using* anything though - potions,
-- scrolls, ladders, chairs - so the object has to be qualified before anything
-- is written, and here the failure direction is the opposite of "Opened": an
-- unqualified use-event is a ladder far more often than it is a container.
--
-- has_inventory() is the gate. The prefix list below is now only the fallback
-- for a Script Extender build that cannot answer, and it is why the list was
-- never enough on its own: a 2026-09-15 Act 1 run opened 474 catalogued
-- containers and *used* 104 more that this handler dropped, because a template
-- allowlist can only ever cover the families someone already thought of.
-- Open Crate (302 rows in containers.py), Backpack (140), Fish Barrel (67),
-- Wardrobe (45), Barbed Bulrush (23), Rotting Bag (20), Broken Cabinet (15) and
-- Equipment Chest (3) were all unreachable that way - 615 locations that could
-- hold an item nobody could ever collect.
local USE_CONTAINER_PREFIXES = {
    "BOOK",                       -- BOOK_GEN_Books_Row/Stack/Pile, Gale's tome quest
    "LAB",                        -- LAB_GEN_Bottle_Rack
    "FUR_GEN_Bookshelf",
    "CONT_HUM",                   -- CONT_HUM_Vase_*
    "CONT_GEN_Vase",
    "CONT_GEN_Alcohol",
    "CONT_Hospital",              -- bloodbank racks
    "CONT_Jergal",                -- urns
    "CONT_Emerald_Enclave_Vase",
    "DEC_GEN_Kitchen",            -- cupboards
}

local function is_use_container_template(template)
    if (type(template) ~= "string") then return false end
    for _, prefix in ipairs(USE_CONTAINER_PREFIXES) do
        if (string.sub(template, 1, #prefix) == prefix) then
            return true
        end
    end
    return false
end

Ext.Osiris.RegisterListener("TemplateUseStarted", 3, "after", function(character, itemTemplate, item)
    if (not logContainers) then return end

    local uuid = container_uuid(item)
    if (uuid == nil) then return end

    local inventory = has_inventory(item)
    local qualified, why
    if (inventory == nil) then
        -- No entity answer from this build: fall back to the old allowlist.
        qualified = is_use_container_template(itemTemplate)
        why = "template fallback"
    else
        qualified = inventory
        why = "inventory component"
    end

    if (not qualified) then
        if (devDebugOnly and inventory == nil) then
            -- Only worth logging in fallback mode - with the entity check live
            -- this fires for every ladder and chair in the game. If a container
            -- you looted shows up here, add its prefix to USE_CONTAINER_PREFIXES.
            print_to_file("debug.json", "TemplateUseStarted, not a known container template: " .. tostring(itemTemplate))
        end
        return
    end
    if (devDebugOnly) then
        print_to_file("debug.json", "TemplateUseStarted container (" .. why .. "): " .. tostring(item))
    end
    record_container(uuid, item)
end)

-- ---------------------------------------------------------------------------
-- Container highlight (ap_options.json "container_highlight")
--
-- Ported from the AP Assist testing mod. While the option is on, each avatar
-- carries the AP_ContainerHighlight toggle passive. Its toggle applies the
-- AP_HIGHLIGHT_ENABLED marker, and while an avatar has the marker the
-- currently controlled character (and only that one, so the party does not
-- scan four times over) carries
-- AP_HIGHLIGHT_AURA, a 20m aura that tags every item in range with
-- AP_HIGHLIGHT_SCAN. Each tagged item is judged once per session here: a world
-- item that owns an inventory and has not been opened yet gets
-- AP_HIGHLIGHT_GLOW, which comes off on the same three events a container check
-- is recorded on. The glow only knows "could be a location": it does not read
-- the apworld's table, so things that are not locations glow too.
--
-- It works with containersanity off as well, which is why it keeps its own
-- opened-set (HighlightOpened) next to ContainersOpened.
-- ---------------------------------------------------------------------------

local HL_PASSIVE = "AP_ContainerHighlight"
local HL_ENABLED = "AP_HIGHLIGHT_ENABLED"
local HL_AURA = "AP_HIGHLIGHT_AURA"
local HL_SCAN = "AP_HIGHLIGHT_SCAN"
local HL_GLOW = "AP_HIGHLIGHT_GLOW"

-- Every Osi call here goes through hl_q by NAME. A query on an entity that is
-- not loaded throws, and Osi functions cannot be handled as values in Script
-- Extender, so the call is always made inside a closure.
local function hl_q(name, ...)
    local args = table.pack(...)
    local ok, a, b, c = pcall(function()
        return Osi[name](table.unpack(args, 1, args.n))
    end)
    if (not ok) then return nil end
    return a, b, c
end

local function hl_vars()
    if (PersistentVars['HighlightOpened'] == nil) then PersistentVars['HighlightOpened'] = {} end
    if (PersistentVars['HighlightGlowing'] == nil) then PersistentVars['HighlightGlowing'] = {} end
    if (PersistentVars['HighlightGranted'] == nil) then PersistentVars['HighlightGranted'] = {} end
    return PersistentVars
end

local function hl_column(read)
    local out = {}
    local ok, rows = pcall(read)
    if (ok and type(rows) == "table") then
        for _, row in ipairs(rows) do
            if (row[1] ~= nil) then table.insert(out, row[1]) end
        end
    end
    return out
end

-- The passive goes on the avatar(s) only, so there is one toggle per player.
local function hl_avatars()
    local list = hl_column(function() return Osi.DB_Avatars:Get(nil) end)
    if (#list == 0) then
        local host = hl_q("GetHostCharacter")
        if (host ~= nil) then list = { host } end
    end
    return list
end

local function hl_party()
    return hl_column(function() return Osi.DB_Players:Get(nil) end)
end

-- True while the option is on AND some avatar has the marker, i.e. the
-- player has not switched the toggle off.
local function hl_active()
    if (not containerHighlight) then return false end
    for _, avatar in ipairs(hl_avatars()) do
        if (hl_q("HasActiveStatus", avatar, HL_ENABLED) == 1) then return true end
    end
    return false
end

-- Container checks already in the out-file, so a container opened in another
-- save of the same seed does not glow. Re-read on level load and on enable.
local hlOutChecked = {}

local function hl_read_out_file()
    hlOutChecked = {}
    local unparsed = Ext.IO.LoadFile(locationOutFile)
    if (not unparsed) then return end
    local ok, data = pcall(Ext.Json.Parse, unparsed)
    if ((not ok) or type(data) ~= "table") then return end
    for _, entry in ipairs(data) do
        if (type(entry) == "string" and string.sub(entry, 1, 10) == "Container-") then
            hlOutChecked[string.sub(entry, 11)] = true
        end
    end
end

local function hl_already_opened(uuid)
    if (hl_vars()['HighlightOpened'][uuid] == true) then return true end
    if (hlOutChecked[uuid] == true) then return true end
    local opened = PersistentVars['ContainersOpened']
    return opened ~= nil and opened[uuid] == true
end

-- A world item (not inside anyone's inventory) that owns an inventory.
-- Osi.IsContainer is the second signal, for a container whose inventory
-- component only exists after the first open.
local function hl_is_world_container(object)
    if (hl_q("IsItem", object) ~= 1) then return false end
    if (hl_q("GetInventoryOwner", object) ~= nil) then return false end
    if (has_inventory(object) == true) then return true end
    return hl_q("IsContainer", object) == 1
end

-- Session cache of aura verdicts. The aura re-applies AP_HIGHLIGHT_SCAN each
-- time an item comes back into range.
local hlEvaluated = {}

local function hl_glow(uuid)
    local glowing = hl_vars()['HighlightGlowing']
    if (glowing[uuid] ~= nil) then return end
    hl_q("ApplyStatus", uuid, HL_GLOW, -1, 1)
    glowing[uuid] = true
end

-- Returns false when the item is in a level that is not loaded. The entry
-- stays and the next level load retries it.
local function hl_unglow(uuid)
    local glowing = hl_vars()['HighlightGlowing']
    if (glowing[uuid] == nil) then return true end
    local ok, entity = pcall(Ext.Entity.Get, uuid)
    if ((not ok) or entity == nil) then return false end
    hl_q("RemoveStatus", uuid, HL_GLOW)
    glowing[uuid] = nil
    return true
end

-- Drop glows that no longer belong: highlight off, or opened since.
local function hl_reconcile()
    local on = hl_active()
    local stale = {}
    for uuid in pairs(hl_vars()['HighlightGlowing']) do
        if ((not on) or hl_already_opened(uuid)) then table.insert(stale, uuid) end
    end
    for _, uuid in ipairs(stale) do hl_unglow(uuid) end
end

-- Keep the aura on whoever is being controlled, and off everyone else.
local function hl_place()
    local on = hl_active()
    local party = hl_party()
    local controlled = {}
    local any = false
    for _, char in ipairs(party) do
        if (hl_q("IsControlled", char) == 1) then
            controlled[char] = true
            any = true
        end
    end
    -- Nobody controlled (cutscene, mid-switch): leave the aura where it is.
    if (on and not any) then return end
    for _, char in ipairs(party) do
        local want = on and controlled[char] == true
        local has = hl_q("HasActiveStatus", char, HL_AURA) == 1
        if (want and not has) then
            hl_q("ApplyStatus", char, HL_AURA, -1, 1)
        elseif (has and not want) then
            hl_q("RemoveStatus", char, HL_AURA)
        end
    end
end

local function hl_mark_opened(object)
    local uuid = container_uuid(object)
    if (uuid == nil) then return end
    local v = hl_vars()
    if (v['HighlightGlowing'][uuid] == nil and hlEvaluated[uuid] ~= true
        and not hl_is_world_container(object)) then
        return
    end
    v['HighlightOpened'][uuid] = true
    hl_unglow(uuid)
end

Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(object, status, causee, storyActionID)
    if (status == HL_SCAN) then
        if (not containerHighlight) then return end
        local uuid = container_uuid(object)
        if (uuid == nil or hlEvaluated[uuid] ~= nil) then return end
        local verdict = hl_is_world_container(object)
        hlEvaluated[uuid] = verdict
        if (verdict and (not hl_already_opened(uuid)) and hl_active()) then hl_glow(uuid) end
    elseif (status == HL_AURA) then
        -- Toggled on, or moved to another character: judge everything afresh.
        hlEvaluated = {}
        hl_read_out_file()
    elseif (status == HL_ENABLED) then
        hl_place()
    end
end)

Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(object, status, causee, storyActionID)
    if (status == HL_ENABLED) then
        hl_place()
        hl_reconcile()
    end
end)

-- These three run whether or not containersanity is on.
Ext.Osiris.RegisterListener("Opened", 1, "after", function(item)
    if (not containerHighlight) then return end
    hl_mark_opened(item)
end)

Ext.Osiris.RegisterListener("TemplateUseStarted", 3, "after", function(character, itemTemplate, item)
    if (not containerHighlight) then return end
    hl_mark_opened(item)
end)

Ext.Osiris.RegisterListener("DestroyedBy", 4, "after", function(item, destroyer, destroyerOwner, storyActionID)
    if (not containerHighlight) then return end
    local uuid = container_uuid(item)
    if (uuid == nil) then return end
    local v = hl_vars()
    if (v['HighlightGlowing'][uuid] ~= nil) then
        v['HighlightOpened'][uuid] = true
        v['HighlightGlowing'][uuid] = nil
    end
end)

-- Bring the avatars in line with the option. nil = not applied this session.
-- Called from the tick, because load_options can run before Osiris is callable
-- and the option can arrive mid-session when the client connects.
local hlApplied = nil

local function highlight_sync()
    if (hlApplied == containerHighlight) then return end
    local avatars = hl_avatars()
    if (#avatars == 0) then return end     -- no avatar yet (character creation)
    local v = hl_vars()
    if (containerHighlight) then
        hl_read_out_file()
        for _, char in ipairs(avatars) do
            if (hl_q("HasPassive", char, HL_PASSIVE) ~= 1) then hl_q("AddPassive", char, HL_PASSIVE) end
            if (not v['HighlightGranted'][char]) then
                v['HighlightGranted'][char] = true
                -- ToggledDefaultOn shows the toggle as on. Make the marker agree in
                -- case AddPassive did not run the ToggleOnFunctors.
                Ext.Timer.WaitFor(1000, function()
                    if (containerHighlight and hl_q("HasActiveStatus", char, HL_ENABLED) ~= 1) then
                        hl_q("ApplyStatus", char, HL_ENABLED, -1, 1)
                    end
                end)
            elseif (v['HighlightMarker'] ~= true and hl_q("HasActiveStatus", char, HL_AURA) == 1) then
                -- Save from before the marker existed: the toggle put the aura
                -- straight on the avatar. Aura present = toggle was on.
                hl_q("ApplyStatus", char, HL_ENABLED, -1, 1)
            end
        end
        v['HighlightMarker'] = true
        hl_place()
    else
        -- Everyone who might hold the aura, not just the avatars.
        local chars = {}
        for _, char in ipairs(avatars) do chars[char] = true end
        for _, char in ipairs(hl_party()) do chars[char] = true end
        for char in pairs(chars) do
            if (hl_q("HasPassive", char, HL_PASSIVE) == 1) then hl_q("RemovePassive", char, HL_PASSIVE) end
            if (hl_q("HasActiveStatus", char, HL_ENABLED) == 1) then hl_q("RemoveStatus", char, HL_ENABLED) end
            if (hl_q("HasActiveStatus", char, HL_AURA) == 1) then hl_q("RemoveStatus", char, HL_AURA) end
        end
        -- A later re-enable grants the toggle afresh, switched on.
        v['HighlightGranted'] = {}
        hlEvaluated = {}
        hl_reconcile()
    end
    hlApplied = containerHighlight
end

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(character)
    if (not containerHighlight) then return end
    hl_place()
end)

Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(character)
    if (not containerHighlight) then return end
    hl_place()
end)

-- hl_place only walks the party, so take the aura off on the way out.
Ext.Osiris.RegisterListener("CharacterLeftParty", 1, "after", function(character)
    if (hl_q("HasActiveStatus", character, HL_AURA) == 1) then hl_q("RemoveStatus", character, HL_AURA) end
end)

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, isEditorMode)
    if (level == "SYS_CC_I") then return end
    -- Re-apply on every level: a new avatar may exist, and glows left in a
    -- level that was unloaded when they should have come off get retried.
    hlApplied = nil
    pcall(highlight_sync)
    if (containerHighlight) then hl_read_out_file() end
    pcall(hl_reconcile)
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
-- Companion shuffle (slot_data "companion_shuffle", rolled in
-- worlds/bg3/companions.py). On a companion's FIRST recruit:
--   * class: point their Origin record at the rolled class/subclass just
--     before the game's own RequestInitialLevel runs (it is called from
--     _GLO_Shared_PartyMembers on PROC_CheckFirstTimeRecruited), so the engine
--     builds level 1 itself and fills the choices from the generic per-class
--     DefaultValues - the same defaults hirelings get.
--   * outfit: give them a fresh copy of another companion's camp body/shoes/
--     underwear, equip it, and delete their own (now unequipped) set.
-- Each half is optional (YAML randomize_companion_classes/_clothes): the apworld
-- leaves "class_uuid" or "outfit" out of a companion's entry when it is off.
-- EXPERIMENTAL / unverified in the live engine: the Ext.StaticData Origin
-- field names, whether RequestInitialLevel reads the Origin at call time, and
-- whether Equip on a freshly TemplateAddTo'd item needs the delay below.
-- Everything is pcall'd and logged, so a failure costs the shuffle, not the run.
-- ---------------------------------------------------------------------------

companionShuffle = nil  -- slot_data table, set by load_options

-- character GUID -> { key used in slot_data, Origin UUID }
COMPANION_CHARACTERS = {
    ["3ed74f06-3c60-42dc-83f6-f034cb47c679"] = { "Shadowheart", "2bb39cf2-4649-4238-8d0c-44f62b5a3dfd" },
    ["58a69333-40bf-8358-1d17-fff240d7fb12"] = { "Laezel", "fb3bc4c3-49eb-4944-b714-d0cb357bb635" },
    ["c7c13742-bacd-460a-8f65-f864fe41f255"] = { "Astarion", "3780c689-d903-41c2-bf64-1e6ec6a8e1e5" },
    ["ad9af97d-75da-406a-ae13-7071c563f604"] = { "Gale", "35c3caad-5543-4593-be75-e7deba30f062" },
    ["c774d764-4a17-48dc-b470-32ace9ce447d"] = { "Wyll", "efc9d114-0296-4a30-b701-365fc07d44fb" },
    ["2c76687d-93a2-477b-8b18-8a14b549304c"] = { "Karlach", "b8b4a974-b045-45f6-9516-b457b8773abd" },
    ["25721313-0c15-4935-8176-9f134385451b"] = { "Minthara", "eae09670-869d-4b70-b605-33af4ee80b34" },
    ["7628bc0e-52b8-42a7-856a-13a6fd413323"] = { "Halsin", "a36281c5-adcd-4d6e-8e5a-b5650b8f17eb" },
    ["91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = { "Jaheira", "c1f137c7-a17c-47b0-826a-12e44a8ec45c" },
    ["0de603c5-42e2-4811-9dad-f652de080eba"] = { "Minsc", "e1b629bc-7340-4fe6-81a4-834a838ff5c5" },
}

-- Camp body, camp shoes, underwear root templates: the set each companion's
-- starting Equipment stats entry gives them. (Lae'zel really does start in
-- ARM_Camp_Shoes_Wyll.)
CAMP_OUTFITS = {
    Shadowheart = { "7062410b-439c-4f2f-bc48-1c16ab1ace20", "e92e4dad-8e96-4f27-aacb-cc430df0bc75", "b460bd0c-58fe-4a56-831c-af92fd4ba7e2" },
    Laezel      = { "54de4a07-c57c-421e-912c-7e8bd93ca0c4", "b307af36-a2da-4c01-aac3-a31771edd407", "185ab1be-e93d-4518-b053-d6d4d7168d68" },
    Astarion    = { "b7392453-6569-4c24-9a1b-cbaea7cebac8", "4700fad1-769e-4831-9b3f-4ead08c49cfa", "4b30a649-fd88-4f64-a57b-1149d7b9ac41" },
    Gale        = { "c56bbf29-2315-415e-a488-fada851828ea", "cb28ea7d-2838-43e7-a807-11277c44facb", "5cdc0fe0-dbda-4f31-89f8-9e16782daef1" },
    Wyll        = { "bd2ac836-5584-41e5-b4ff-01782c0dec6d", "b307af36-a2da-4c01-aac3-a31771edd407", "1930ceec-4a50-43d9-8589-94593c449be4" },
    Karlach     = { "5c79e518-2c59-41c5-84a7-d43a58e76d09", "b8f42945-a42e-46cb-a424-3a0a5e97157a", "e865db4c-4df3-48e9-8cf3-5abad75510ba" },
    Minthara    = { "29a31736-6f9d-46ef-880d-ac3157187202", "f107cc6a-3a6e-4a58-be16-fbe73b3f7ae8", "73874ef8-a3c4-4a68-8d2a-ed3d580dfb52" },
    Halsin      = { "dc74db6c-14b2-44fa-8415-0dd1194e90e2", "42de5102-7a39-44d2-b1d8-645ec4d8b0ce", "9ebb9117-a0ae-46f2-a243-8d67650e9586" },
    Jaheira     = { "0d0d9c0f-e9aa-4ba4-a0a9-1a0b7b7069ca", "556de2bd-99a6-4d62-b78c-d4681ce5bdfa", "91259e65-dd71-4312-ba3c-c55757978788" },
    Minsc       = { "42ff9d36-849d-4777-968c-8cf9ca7d8027", "836e13ab-78a6-4ca3-ba8e-adc4c25205f1", "48a3ffbe-f14e-4cfe-b45e-ebadb3af0fd4" },
}

-- PersistentVars['CompanionShuffle'][name] = { class = "done"|"missed"|"failed"|"off",
--   outfit = "done"|"pending"|"applying"|"failed"|"off", char = <character string> }
local function shuffle_state()
    local s = PersistentVars['CompanionShuffle']
    if (s == nil) then
        s = {}
        PersistentVars['CompanionShuffle'] = s
    end
    return s
end

local function guid_of(s)
    if (type(s) ~= "string" or #s < 36) then return nil end
    return string.sub(s, -36)
end

-- An origin the player picked as their avatar is not shuffled.
local function is_avatar(char)
    local g = guid_of(char)
    local ok, rows = pcall(function() return Osi.DB_Avatars:Get(nil) end)
    if (not ok or rows == nil) then return false end
    for _, row in pairs(rows) do
        if (guid_of(row[1]) == g) then return true end
    end
    return false
end

-- The proc can run again for a companion already recruited (Wyll's dialog
-- path, the debug camp teleport, a save from before this feature). The game
-- marks the real first time with this DB fact right after our "before" hook.
local function already_recruited(char)
    local g = guid_of(char)
    local ok, rows = pcall(function() return Osi.DB_OnlyOncePerPlayer:Get(nil, "Recruitment_Respec") end)
    if (not ok or rows == nil) then return false end
    for _, row in pairs(rows) do
        if (guid_of(row[1]) == g) then return true end
    end
    return false
end

local function set_origin_class(originUuid, roll)
    return pcall(function()
        local origin = Ext.StaticData.Get(originUuid, "Origin")
        if (origin == nil) then error("no Origin " .. originUuid) end
        origin.ClassUUID = roll.class_uuid
        origin.SubClassUUID = roll.subclass_uuid
    end)
end

local function apply_outfit(char, name, donor)
    local templates = CAMP_OUTFITS[donor]
    if (templates == nil) then
        ap_log("Companion shuffle: no outfit table for '" .. tostring(donor) .. "'")
        shuffle_state()[name].outfit = "failed"
        return
    end
    for _, tpl in ipairs(templates) do
        Osi.TemplateAddTo(tpl, char, 1, 0)
    end
    -- Give the new items a moment to land in the inventory before equipping.
    Ext.Timer.WaitFor(1000, function()
        local ok, err = pcall(function()
            for _, tpl in ipairs(templates) do
                local item = Osi.GetItemByTemplateInInventory(tpl, char)
                if (item == nil) then error("template " .. tpl .. " not in inventory") end
                Osi.Equip(char, item)
            end
        end)
        if (not ok) then
            shuffle_state()[name].outfit = "failed"
            ap_log("Companion shuffle: outfit for " .. name .. " failed: " .. tostring(err))
            return
        end
        shuffle_state()[name].outfit = "done"
        ap_log("Companion shuffle: " .. name .. " is wearing " .. donor .. "'s camp clothes")
        -- Drop their own set, which the equips just pushed back into the
        -- inventory. A template the donor set shares (Lae'zel and Wyll wear the
        -- same shoes) is the item we just equipped, so it is left alone.
        local okDel, errDel = pcall(function()
            local keep = {}
            for _, tpl in ipairs(templates) do keep[tpl] = true end
            for _, tpl in ipairs(CAMP_OUTFITS[name] or {}) do
                if (not keep[tpl]) then
                    local old = Osi.GetItemByTemplateInInventory(tpl, char)
                    if (old ~= nil) then Osi.RequestDelete(old) end
                end
            end
        end)
        if (not okDel) then
            ap_log("Companion shuffle: removing " .. name .. "'s own camp clothes failed: " .. tostring(errDel))
        end
    end)
end

-- Outfits for companions recruited before ap_options.json existed (Nautiloid
-- recruits on a first run). Class can't be caught up: level 1 is already built.
local function apply_pending_outfits()
    if (type(companionShuffle) ~= "table") then return end
    for name, st in pairs(shuffle_state()) do
        local roll = companionShuffle[name]
        if (st.outfit == "pending" and type(roll) == "table" and st.char ~= nil) then
            if (roll.outfit == nil) then
                st.outfit = "off"
            else
                st.outfit = "applying"
                apply_outfit(st.char, name, roll.outfit)
            end
        end
    end
end

Ext.Osiris.RegisterListener("PROC_CheckFirstTimeRecruited", 1, "before", function(char)
    local entry = COMPANION_CHARACTERS[guid_of(char) or ""]
    if (entry == nil) then return end
    local name, originUuid = entry[1], entry[2]
    local state = shuffle_state()
    if (state[name] ~= nil) then return end
    if (already_recruited(char)) then
        state[name] = { class = "preexisting", outfit = "preexisting", char = char }
        return
    end
    if (is_avatar(char)) then
        state[name] = { class = "avatar", outfit = "avatar", char = char }
        return
    end
    state[name] = { char = char }
    local roll = (type(companionShuffle) == "table") and companionShuffle[name] or nil
    if (type(roll) ~= "table") then
        -- No options yet (or a seed without the shuffle).
        state[name].class = "missed"
        state[name].outfit = "pending"
        ap_log("Companion shuffle: " .. name .. " recruited before ap_options.json had a shuffle; class left as-is")
        return
    end

    if (roll.class_uuid == nil) then
        state[name].class = "off"
    else
        local ok, err = set_origin_class(originUuid, roll)
        if (ok) then
            state[name].class = "done"
            ap_log("Companion shuffle: " .. name .. " starts as " .. tostring(roll.class) .. " (" .. tostring(roll.subclass) .. ")")
        else
            state[name].class = "failed"
            ap_log("Companion shuffle: class for " .. name .. " failed: " .. tostring(err))
        end
    end

    if (roll.outfit == nil) then
        state[name].outfit = "off"
    else
        state[name].outfit = "applying"
        local ok2, err2 = pcall(apply_outfit, char, name, roll.outfit)
        if (not ok2) then
            state[name].outfit = "failed"
            ap_log("Companion shuffle: outfit for " .. name .. " failed: " .. tostring(err2))
        end
    end
end)

-- ---------------------------------------------------------------------------
-- Item granting
-- ---------------------------------------------------------------------------

local function process_deathlink_receive(targetChar)
    -- Not under pcall, unlike grant_item: an Osi.Die(nil) here would throw out
    -- of process_incoming before the item loop ever ran.
    if (targetChar == nil) then return end
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
                if (surviveOnDeathlink) then
                    Osi.SetHitPoints(targetChar, 0)
                else
                    pendingReceiveDeathlink = true
                    Osi.Die(targetChar)
                end
                Ext.IO.SaveFile("deathLinkReceive.json", "[]")
            end
        end
    end
end

local function spawn_monster(targetChar)
    local monsterUuids = {
        [1] = "2e51b930-c9fd-41f2-8013-02c92e990de2", -- Lesser hellboar
        [2] = "2e51b930-c9fd-41f2-8013-02c92e990de2",
        [3] = "5620024c-5d1b-477d-ace8-43e2275f6158", -- Int Dev
        [4] = "5620024c-5d1b-477d-ace8-43e2275f6158",
        [5] = "4b3c6cdc-95da-476d-8ac7-c8d012ccf3b2", -- Ochre Jelly
        [6] = "4b3c6cdc-95da-476d-8ac7-c8d012ccf3b2",
        [7] = "bfe9ad10-c5f7-4a08-a2af-acefb296ffcc", -- Hook horror
        [8] = "bfe9ad10-c5f7-4a08-a2af-acefb296ffcc",
        [9] = "cc1b177d-5053-4472-b1e2-8c3e42fc17da", -- Meenlock
        [10] = "cc1b177d-5053-4472-b1e2-8c3e42fc17da",
        [11] = "319efbbe-f9f3-4584-804e-3e17d47d1136", -- Spectator
        [12] = "319efbbe-f9f3-4584-804e-3e17d47d1136",
    }
    local currentLevel = Osi.GetLevel(targetChar) or 1
    if (currentLevel < 1) then
        currentLevel = 1
    end
    if (currentLevel > 12) then
        currentLevel = 12
    end
    local monstername = monsterUuids[currentLevel]
    local mon = Osi.CreateAtObject(monstername,targetChar,0,0,"",1)
    Osi.SetFaction(mon, "ACT0a_TUT_HelmDevil_0314cde4-8572-4d70-a117-dba88e20e70d")
    Osi.SetHostileAndEnterCombat("ACT0a_TUT_HelmDevil_0314cde4-8572-4d70-a117-dba88e20e70d", Osi.GetFaction(targetChar), mon, targetChar)
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
        if (string.sub(v, 6, 12) == "Monster") then
            shouldSpawnMonster = true
        elseif (string.sub(v, 6, 13) == "Bleeding") then
            ApplyStatus(targetChar, "BLEEDING", 10)
        elseif (string.sub(v, 6, 9) == "Stun") then
            ApplyStatus(targetChar, "STUNNED", 5)
        elseif (string.sub(v, 6, 14) == "Confusion") then
            ApplyStatus(targetChar, "MADNESS", 10)
        elseif (string.sub(v, 6, 12) == "Blinded") then
            ApplyStatus(targetChar, "BLINDED", 10)
        elseif (string.sub(v, 6, 11) == "Sussur") then
            ApplyStatus(targetChar, "UND_ANCIENTSUSSURTREEANTIMAGIC_AURA", 10)
        elseif (string.sub(v, 6, 10) == "Clown") then
            ApplyStatus(targetChar, "WYR_FACEPAINT_CLOWN", 120)
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
    -- The 250 ms tick starts running before the party exists, and back then
    -- process_incoming only ran from CastedSpell, which cannot fire that early.
    -- GetHostCharacter() is nil until then, and passing that to TemplateAddTo
    -- fails every grant in the batch for no reason. load_options above still
    -- runs, so the first-run seed-prefix pickup is not delayed by this.
    if (targetChar == nil) then return end
    local okPending, errPending = pcall(apply_pending_outfits)
    if (not okPending) then ap_log("Companion shuffle: pending outfits failed: " .. tostring(errPending)) end
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
    if (shouldSpawnMonster) then
        local ok, err = pcall(spawn_monster, targetChar)
        if (not ok) then ap_log("Monster trap failed: " .. tostring(err)) end
        shouldSpawnMonster = false
    end
    PersistentVars['APSent'] = APSent
    PersistentVars['APGrantFailures'] = failCounts
end

Ext.Osiris.RegisterListener("CastedSpell", 5, "after", function(caster, spell, spellType, spellElement, storyActionID)
    if (spell == "Shout_AP_Sync") then
        setBlockedEntrances()
    end
    if (spell == "Shout_AP_Sync" or syncOnAny) then
        process_incoming()
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
    apState.surviveOnDeathlink = surviveOnDeathlink
    apState.script_version = AP_SCRIPT_VERSION
    apState.net_mode = ((APNet ~= nil and APNet.Describe ~= nil) and APNet.Describe() or "none")
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
    -- First, and in its own pcall, so an error further down the tick can't
    -- hold back the debug log.
    if (tickCount % HEARTBEAT_TICKS == 0) then
        pcall(flush_log_buffers)
    end
    if (tickCount % CLIENT_CHECK_TICKS == 0) then
        check_client_heartbeat()
        update_presence()
        pcall(highlight_sync)
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
        if (startupStatePushes > 0) then
            startupStatePushes = startupStatePushes - 1
            stateDirty = true
        end
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
    logFlushOnTick = true
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
    else
        print("AP: AP_Command channel unavailable; the window's buttons will do nothing")
    end
    if (stateChannel == nil) then
        print("AP: AP_State channel unavailable; the in-game window will stay blank")
    end
else
    print("AP: Shared/APNet.lua did not load; running headless, no in-game window")
end

-- Greppable build banner. When a player reports missing items, this line and
-- the matching one from Client/APGui.lua are the first thing to ask for: two
-- different builds mean two copies of the mod are installed and the stale one
-- is winning. (The old wording here was "Archipelago Client Script Loaded v6",
-- printed by the SERVER script, which made exactly that diagnosis harder.)
print("Archipelago SERVER script loaded: build " .. AP_SCRIPT_VERSION
    .. ", net " .. ((APNet ~= nil and APNet.Describe ~= nil) and APNet.Describe() or "none"))
