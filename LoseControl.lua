--	local name, _, _, stacks, duration, expirationTime = AuraUtil.FindAuraByName(value.dotname, "target", "PLAYER|HARMFUL" );

--Anchor to Gladius and Stealth/Alpha w/Gloss Option  Added
--Player LOCBliz Add All New CC  Added
----Add CC/Silence/Disarm/Root/Interrupt/Other Added
----Add Snare from string check “Movement”  Added
--Selected Priorities Show Newest Duration Remaining Aura Added
--Selected Priorities Show Highest Duration Remaining Aura Added
--Target/Focus/ToT/ToF Will Obey/Show Icons for Arena 123 Priorities if Arena 123 Added
--Arena Priorities vs Player, Party Priorities  Added
--Interupts Penance or Channel Casts Addedd
--Stealth Module  Added
--Mass Invis (Hack) Added
--Add stealth check and aura filters
--[[Duel (2 icons Red Layered Hue) test
Ours White w/Different Prio for Us and EnemyArenaTeam  Added
Enemy Red w/Different Prio for Us and EnemyArenaTeam  Added]]
--[[SmokeBomb (2 icons Red Layered Hue)
Ours White w/Different Prio for Us and EnemyArenaTeam  Added
Enemy Red w/Different Prio for Us and EnemyArenaTeam  Added]]
--cleu SpellCastSucess Timer (treated as buff in options for categoriesEnabled)
--2 Aura check Root Beam test
--Prio Change on Same SpellId per Spec : Ret/Holy Avenging Wrath test
--Stacks Only Icon: Tiger Eye Brew Inevitable Demise

local addonName, L = ...
L.OptionsFunctions = {}; -- adds LoseControl table to addon namespace

local OptionsFunctions = L.OptionsFunctions;
local UIParent = UIParent -- it's faster to keep local references to frequently used global vars
local UnitAura = UnitAura
local UnitBuff = UnitBuff
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitIsEnemy = UnitIsEnemy
local UnitHealth = UnitHealth
local UnitName = UnitName
local UnitGUID = UnitGUID
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local IsInInstance = IsInInstance
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetInspectSpecialization = GetInspectSpecialization
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local GetName = GetName
local GetNumGroupMembers = GetNumGroupMembers
local GetNumArenaOpponents = GetNumArenaOpponents
local GetInstanceInfo = GetInstanceInfo
local GetZoneText = GetZoneText
local SetPortraitToTexture = SetPortraitToTexture
local ipairs = ipairs
local pairs = pairs
local next = next
local type = type
local select = select
local strsplit = strsplit
local strfind = string.find
local strmatch = string.match
local tblinsert = table.insert
local tblremove= table.remove
local mathfloor = math.floor
local mathabs = math.abs
local bit_band = bit.band
local tblsort = table.sort
local Ctimer = C_Timer.After
local substring = string.sub
local strformat = string.format
local CLocData = C_LossOfControl.GetActiveLossOfControlData
local unpack = unpack
local SetScript = SetScript
local SetUnitDebuff = SetUnitDebuff
local SetOwner = SetOwner
local CreateFrame = CreateFrame
local SetTexture = SetTexture
local SetNormalTexture = SetNormalTexture
local SetSwipeTexture = SetSwipeTexture
local SetCooldown = SetCooldown
local ClearAllPoints = ClearAllPoints
local GetParent = GetParent
local GetFrameLevel = GetFrameLevel
local GetDrawSwipe = GetDrawSwipe
local GetDrawLayer = GetDrawLayer
local GetAlpha = GetAlpha
local Hide = Hide
local Show = Show
local IsShown = IsShown
local IsVisible = IsVisible
local playerGUID
--local debug = false -- type "/lc debug on" if you want to see UnitAura info logged to the console
local LCframes = {}
local LCframeplayer2
local LCframeplayer3

local InterruptAuras = { }
local SmokeBombAuras = { }
local Earthen = { }
local Grounding = { }
local WarBanner = { }
local SanctifiedGrounds = { }
local Barrier = { }
local SGrounds = { }
local BeamAura = { }
local DuelAura = { }
local Arenastealth = { }

local spellIds = { }
local spellIdsArena = { }
local interruptsIds = { }
local cleuPrioCastedSpells = { }

local SecondaryIconData = { }

local string = { }
local colorTypes = {
  Magic 	= {0.20,0.60,1.00},
  Curse 	= {0.60,0.00,1.00},
  Disease = {0.60,0.40,0},
  Poison 	= {0.00,0.60,0},
  none 	= {0.80,0,   0},
  Buff 	= {0.00,1.00,0},
  CLEU 	= {0.60,0.60,0.60},
}

-------------------------------------------------------------------------------
-- Thanks to all the people on the Curse.com and WoWInterface forums who help keep this list up to date :)
local cleuSpells = { -- nil = Do Not Show
--Spell Summon Sucess
		
	{1122, 45, nil,  "Ranged_Major_OffenisiveCDs", "Infernals", "Infernals", "WARLOCK"}, --Warlock Infernals

	{51533, 45, nil,  "Small_Offenisive_CDs", "Feral Spirit", "Feral Spirit", "SHAMAN"}, --Disc Pet Summmon --Enemy_Smoke_Bomb
	{8143, 8.5, "CC_Reduction",  "Special_Low", "Tremor".."\n".."Totem", "Tremor", "SHAMAN"}, --Shaman Tremor Totem ***ONLY WORKS FOR THE CASTER (Totemic Focus: Makes it 13)  **HAS TEXT ADD IN LOOP**
	{16190, 18, nil,  "Special_Low", "Mana".."\n".."Tide", "Mana", "SHAMAN"}, --Mana Tide

	{34433, 15, nil,  "Small_Offenisive_CDs", "Shadowfiend", "Shadowfiend", "PREIST"}, --Disc Pet Summmon --Enemy_Smoke_Bomb

	--{32168, 30, "PvE",  "Special_Low", "Mirror".."\n".."Image", "Mirror Image", "MAGE"}, --Mirror Images
	--{31687, 45, "PvE",  "Special_Low", "Water".."\n".."Elemental", "Water".."\n".."Elemental", "MAGE"}, -- Water Elemental

	{33831, 30, "PvE",  "Small_Offenisive_CDs", "Trees", "Trees", "DRUID"}, --Druid Trees

	{49206,  30, nil,  "Small_Offenisive_CDs", "Ebon".."\n".."Gargoyle", "Ebon Gargoyle", "DEATHKNIGHT"}, --Ebon Gargoyle

--Spell Cast Sucess

	{14185,  2, nil,  "Special_High", "Cold Snap", "Cold Snap", "ROGUE"}, --Preparation

	{11958, 2, nil,  "Special_High", "Cold Snap", "Cold Snap", "MAGE"}, --Cold Snap

	{23989, 2, nil,  "Special_High", "Readiness", "Readiness", "HUNTER"}, --Readiness
	
	{47568 , 3, nil,  "Melee_Major_OffenisiveCDs", "Empower Rune Weapon", "Empower Rune Weapon", "DEATHKNIGHT"}, --Empower Rune Wep

	{19236, 2, nil,  "Small_Defensive_CDs", "Desperate Prayer", "Desperate Prayer", "PRIEST"}, --Empower Rune Wep

 --{spellId, duration. prio, prioArena, name, nameArena} --must have both names

}

local interrupts = {

	{6552   , 4, "WARRIOR"},	-- Pummel (Warrior)
	{19647  , 6, "WARLOCK"},	-- Spell Lock (felhunter) (Warlock)
	{57994  , 2, "SHMAMAN"},		-- Wind Shear (Shaman)
	{1766   , 5, "ROGUE"},		-- Kick (Rogue)
	{51680  , 3, "ROGUE"},		-- Throwing Specialization (Rogue)
	{96231 , 4, "PALADIN"},		--Rebuke
	{2139   , 7, "MAGE"},		-- Counterspell (Mage)
	{26090 , 2, "HUNTER"},		-- Pummel (gorilla) (Hunter)
	{34490 , 3, "HUNTER"},		--Silence Intterupt
	{80965, 4, "DRUID"},	-- Skull Bash (Druid)(Feral)
	{80964, 4, "DRUID"},	-- Skull Bash (Druid)(Bear)
	{93985, 4, "DRUID"},	-- Skull Bash (Druid)(Bear)
	{97547, 5, "DRUID"},    --SolarBeam
	--{78675 , 1, "DRUID"},		-- Solar Beam (Druid)
	{47528  , 4, "DEATHKNIGHT"},		-- Mind Freeze (Death Knight)
	{91807 , 2, "DEATHKNIGHT"},		-- Leap (Death Knight Ghoul)
	{91802 , 2, "DEATHKNIGHT"},		-- Leap (Death Knight Ghoul)


}

local StealthTable = {
	[5215] = true, --prowl
	[5384] = true, --feign death
	[80325] = true, --Camouflage
	--[51753] = true, --Camouflage
	--[51755] = true, --Camouflage 
	--[80325] = true, --Camouflage Perma Buff
	[66] = true, --Invisibility
	[32612] = true, --Invisibility
	[11327] = true, --Vanish
	[1856] = true, --Vanish
	[27617] = true, --Vanish
	--[115191] = true, --Stealth
	[1784] = true, --Stealth
	[58984] = true, -- Shadowmeld
}

local spellsArenaTable = {

	----------------
	-- Death Knight
	----------------
	{48707 , "Immune_Arena", "DEATHKNIGHT"}, --Anti-Magic Shell
	{49203 , "CC_Arena", "DEATHKNIGHT"}, --Hungering Cold (talent)
	{47481 , "CC_Arena", "DEATHKNIGHT"}, --Gnaw
	{91800 , "CC_Arena", "DEATHKNIGHT"}, --Gnaw
	{91797 , "CC_Arena", "DEATHKNIGHT"}, --Monstrous Blow
	{47476 , "Silence_Arena", "DEATHKNIGHT"}, --Strangulate
	--{47568 , "Melee_Major_OffenisiveCDs", "DEATHKNIGHT"}, --Empower Rune Weapon (NO AURA)
	{96294 , "Roots_90_Snares", "DEATHKNIGHT"}, 	-- CHains of Ice Root
	{96293 , "Roots_90_Snares", "DEATHKNIGHT"}, 	-- CHains of Ice Root
	{49016 , "Melee_Major_OffenisiveCDs", "DEATHKNIGHT"}, --Unholy Frenzy
	{51271 , "Melee_Major_OffenisiveCDs", "DEATHKNIGHT"}, --Pillar of Frost
	{81256 , "Melee_Major_OffenisiveCDs", "DEATHKNIGHT"}, --Dancing Rune Weapon
	{48792 , "Big_Defensive_CDs", "DEATHKNIGHT"}, --Icebound Fortitude
	{49039 , "Big_Defensive_CDs", "DEATHKNIGHT"}, --Lichborne
	{50461 , "Big_Defensive_CDs", "DEATHKNIGHT"}, --Anti-Magic Zone
	{42650 , "Big_Defensive_CDs", "DEATHKNIGHT"}, --Army of the Dead (not immune, the Death Knight takes less damage equal to his Dodge plus Parry chance)
	{55233 , "Big_Defensive_CDs", "DEATHKNIGHT"}, --Vampiric Blood
	--{45529 , "Small_Defensive_CDs", "DEATHKNIGHT"}, --Blood Tap
	{49222 , "Small_Defensive_CDs", "DEATHKNIGHT"}, --Bone Shield
	{48263, "Special_Low", "DEATHKNIGHT"}, --Blood Presence
	--{GetSpellInfo(48263) or 48263, "Special_Low", "DEATHKNIGHT"}, --Frost Presence
	{45524 , "Snares_Ranged_Spamable", "DEATHKNIGHT"}, --Chains of Ice

	----------------
	-- Druid
	----------------
	{17116 , "Drink_Purge", "DRUID"}, --Nature's Swfitness

	{33786 , "CC_Arena", "DRUID"}, 	--Cyclone
	{5211 , "CC_Arena", "DRUID"},	-- Bash
	{9005 , "CC_Arena", "DRUID"},	-- Pounce
	{22570 , "CC_Arena", "DRUID"},	-- Maim
	{2637 , "CC_Arena", "DRUID"},	-- Hibernate

	{81261 , "Silence_Arena", "DRUID"}, --Solar Beam

	{5215 , "Special_High", "DRUID"},	--Prowl 

	{50334, "Ranged_Major_OffenisiveCDs", "DRUID"}, --Berserk (talent)
	--{93622, "Ranged_Major_OffenisiveCDs", "DRUID"}, --Berserk (talent)(Bear)(Mangle Proc)
	{48505, "Ranged_Major_OffenisiveCDs", "DRUID"},	-- Starfall (talent) 

	{339 , "Roots_90_Snares", "DRUID"}, 	-- Entangling Roots 
	{19975 , "Roots_90_Snares", "DRUID"},	-- Entangling Roots (Nature's Grasp spell)

	{16979 , "Roots_90_Snares", "DRUID"},	-- Feral Charge Effect (Feral Charge talent)
	{GetSpellInfo(16979) or 16979 , "Roots_90_Snares", "DRUID"},	-- Feral Charge Effect (Feral Charge talent)
	{45334 , "Roots_90_Snares", "DRUID"},	-- Feral Charge Effect (Feral Charge talent)

	{22812 , "Big_Defensive_CDs", "DRUID"}, --Barkskin
	{29166 , "Big_Defensive_CDs", "DRUID"}, --Innervate
	{33891 , "Big_Defensive_CDs", "DRUID"}, --Incarnation: Tree of Life
	{61336 , "Big_Defensive_CDs", "DRUID"}, --Survival Instincts
	
	{5217, "Small_Offenisive_CDs", "DRUID"}, --Tiger's Fury

	{22842 , "Small_Defensive_CDs", "DRUID"}, --Frenzied Regenerationw+  
	{5229, "Small_Defensive_CDs", "DRUID"},	-- Enrage
	{16689 , "Small_Defensive_CDs", "DRUID"},	-- Nature's Grasp
	{1850, "Freedoms_Speed", "DRUID"}, --Dash
	{77764 ,  "Freedoms_Speed", "DRUID"}, --Stampeding Roar (Feral)
	{77761,  "Freedoms_Speed", "DRUID"}, --Stampeding Roar (Bear)
	{467 , "Special_Low", "DRUID"}, --Thorns
	{16857, "Special_Low", "DRUID"}, --Faerie Fire (Feral)
	{GetSpellInfo(16857) or 16857, "Special_Low", "DRUID"}, --Faerie Fire (Feral)
	{770, "Special_Low", "DRUID"}, --Faerie Fire
	{GetSpellInfo(770) or 770, "Special_Low", "DRUID"}, --Faerie Fire
	{768 , "Special_Low", "DRUID"}, --Cat Form
	{GetSpellInfo(768) or 768, "Special_Low", "DRUID"}, --Cat Form
	{5487 , "Special_Low", "DRUID"}, --Bear Form
	{GetSpellInfo(5487) or 5487, "Special_Low", "DRUID"}, --Bear Form
	{783 , "Special_Low", "DRUID"}, --Travel Form
	{GetSpellInfo(783) or 783, "Special_Low", "DRUID"}, --Travel Form
	{24858 , "Special_Low", "DRUID"}, --Moonkin Form
	{GetSpellInfo(24858) or 24858 , "Special_Low", "DRUID"}, --Moonkin Form

	----------------
	-- Hunter
	----------------
	{19263 , "Immune_Arena", "HUNTER"}, --Deterrence (not immune, parry chance increased by 100% and grants a 100% chance to deflect spells)
	{1513, "CC_Arena", "HUNTER"},			-- Scare Beast 
	{3355, "CC_Arena", "HUNTER"},			-- Freezing Trap 
	{19386, "CC_Arena", "HUNTER"},			-- Wyvern Sting (talent) (rank 1)
	{19503, "CC_Arena", "HUNTER"},			-- Scatter Shot (talent)
	{GetSpellInfo(34490) , "Silence_Arena", "HUNTER"}, --Silencing Shot

	{80325, "Special_High", "HUNTER"}, --Camouflage
	--{80325 , "Special_High", "HUNTER"}, --Camouflage (Perma Buff)

	{5384 , "Special_High", "HUNTER"}, --Fiegn Death
	{53476 , "Special_High", "HUNTER"}, --Intervene (Pet)
	{34471 , "Special_High", "HUNTER"}, --The Beast Within (PvP)
	{19574, "Ranged_Major_OffenisiveCDs", "HUNTER"}, --Bestial Wrath
	{3045 , "Ranged_Major_OffenisiveCDs", "HUNTER"}, --Rapid Fire
	{19306, "Roots_90_Snares", "HUNTER"},			-- Counterattack (talent) 
	{19185, "Roots_90_Snares", "HUNTER"},			-- Entrapment (talent) (rank 1)
	{64803, "Roots_90_Snares", "HUNTER"},			-- Entrapment (talent) (rank 1)
	{53480 , "Big_Defensive_CDs", "HUNTER"}, --Roar of Sacrifice
	{63087, "Small_Defensive_CDs", "HUNTER"},	-- Enrage
	{54216 , "Freedoms_Speed", "HUNTER"}, --Master's Call
	{5118 , "Freedoms_Speed", "HUNTER"}, --Aspect of the Cheetah
	{13159 , "Freedoms_Speed", "HUNTER"}, --Aspect of the Pack (Raid)
	{83559, "Freedoms_Speed", "HUNTER"}, --Posthaste
	{51753 , "Special_Low", "HUNTER"}, --Camouflage
	{51755 , "Special_Low", "HUNTER"}, --Camouflage
	{35101 , "Snares_WithCDs", "HUNTER"}, --Concussive Barrage Proc
	{5116 , "Snares_WithCDs", "HUNTER"}, --Concussive Shot
	{2974 , "Snares_Casted_Melee", "HUNTER"}, --Wing Clip

	----------------
	-- Hunter Pets
	----------------
	{90337, "CC_Arena", "HUNTER"},				-- Bad Manner (Monkey)
	{24394, "CC_Arena", "HUNTER"},				-- Intimidation (talent)
	{50519, "CC_Arena", "HUNTER"},				-- Sonic Blast 
	{4167, "Roots_90_Snares", "HUNTER"},				-- Web (Spider)
	{54706, "Roots_90_Snares", "HUNTER"},				-- Venom Web Spray (Silithid)
	{50245, "Roots_90_Snares", "HUNTER"},			-- 	Pin (Crab)
	{53148, "Roots_90_Snares", "HUNTER"},				-- Charge (Bear and Carrion Bird)
	{25999, "Roots_90_Snares", "HUNTER"},			-- Boar Charge (Boar)
	{54404, "Disarms", "HUNTER"},			-- Dust Cloud (chance to hit reduced by 100%) (Tallstrider)
	{50541, "Disarms", "HUNTER"},			-- Snatch (Bird of Prey)


	----------------
	-- Mage
	----------------
	{45438 , "Immune_Arena", "MAGE"}, --Ice Block
	{"Polymorph" , "CC_Arena", "MAGE"},
	{118,   "CC_Arena", "MAGE"},				-- Polymorph 
	{28271, "CC_Arena", "MAGE"},				-- Polymorph: Turtle
	{28272, "CC_Arena", "MAGE"},				-- Polymorph: Pig
	{61305, "CC_Arena", "MAGE"},				-- Polymorph: Black Cat
	{61721, "CC_Arena", "MAGE"},				-- Polymorph: Rabbit
	{61780, "CC_Arena", "MAGE"},				-- Polymorph: Turkey
	{71319, "CC_Arena", "MAGE"},				-- Polymorph: Turkey
	{61025, "CC_Arena", "MAGE"},				-- Polymorph: Serpent
	{59634, "CC_Arena", "MAGE"},				-- Polymorph - Penguin (Glyph)
	{82691, "CC_Arena", "MAGE"},				-- Ring of Frost
	{12355, "CC_Arena", "MAGE"},				-- Impact (talent)
	{83047, "CC_Arena", "MAGE"},				-- Improved Polymorph (talent)
	{31661, "CC_Arena", "MAGE"},				-- Dragon's Breath 
	{44572, "CC_Arena", "MAGE"},				-- Deep Freeze (talent)
	{18469, "Silence_Arena"	, "MAGE"},		-- Counterspell - Silenced (rank 1) (Improved Counterspell talent)
	{55021, "Silence_Arena"	, "MAGE"},				-- Counterspell - Silenced (rank 2) (Improved Counterspell talent)
	{66 , "Special_High", "MAGE"}, --Invisibility
	{32612 , "Special_High", "MAGE"}, --Invisibility
	{12051 , "Special_High", "MAGE"}, --Evocation
	--{64346, "Disarms", "MAGE"},			-- Fiery Payback (talent)
	{12042, "Ranged_Major_OffenisiveCDs", "MAGE"}, --Arcane Power
	{12043 , "Ranged_Major_OffenisiveCDs", "MAGE"}, --Presence of Mind
	{12472, "Ranged_Major_OffenisiveCDs", "MAGE"}, --Icy Veins
	{122, "Roots_90_Snares", "MAGE"},			-- Frost Nova 
	{83302, "Roots_90_Snares", "MAGE"},					-- Imp CoC
	{55080, "Roots_90_Snares", "MAGE"},					-- Shattered Barrier (talent)
	{83073, "Roots_90_Snares", "MAGE"},					-- Shattered Barrier (talent)
	{33395, "Roots_90_Snares", "MAGE"},					-- Freeze
	--{110909  , "Big_Defensive_CDs", "MAGE"}, --Alter Time
	--{342246 , "Big_Defensive_CDs", "MAGE"}, --Alter Time
	--{198111 , "Big_Defensive_CDs", "MAGE"}, --Temporal Shield
	{87023 , "Big_Defensive_CDs", "MAGE"}, --Cauterilze
	--{108839 , "Small_Offenisive_CDs", "MAGE"}, --Ice Floes
	--{198065 , "Small_Defensive_CDs", "MAGE"}, --Prismatic Cloak
	{83853 , "Player_Party_OffensiveCDs", "MAGE"}, --Combustion
	{44544, "Small_Offenisive_CDs", "MAGE"}, --FOF
    {48108, "Small_Offenisive_CDs", "MAGE"}, --Hot STreak
	{46989, "Freedoms_Speed", "MAGE"}, --Improved Blink
	{31643, "Freedoms_Speed", "MAGE"}, --Blazing Speed
	{GetSpellInfo(31643) or 31643, "Freedoms_Speed", "MAGE"}, --Blazing Speed
	{44614 , "Snares_WithCDs", "MAGE"}, --FFb Snare
	{120 , "Snares_WithCDs", "MAGE"}, --Cone of Cold
	{GetSpellInfo(120) or 120 , "Snares_WithCDs", "MAGE"}, --Cone of Cold
	{11426 , "Special_Low", "MAGE"}, --Ice Barrier
	{GetSpellInfo(11426) or 11426 , "Special_Low", "MAGE"}, --Ice Barrier
	{41425 , "Special_Low", "MAGE"}, --Hypothermia
	{31589 , "Snares_Ranged_Spamable", "MAGE"}, --Slow

	----------------
	-- Paladin
	----------------
	{642 , "Immune_Arena", "PALADIN"}, -- Divine Shield
	{853, "CC_Arena", "PALADIN"},	-- Hammer of Justice 
	{2812, "CC_Arena", "PALADIN"},				-- Holy Wrath
	{10326, "CC_Arena", "PALADIN"},				-- Turn Evil
	{20066, "CC_Arena", "PALADIN"},				-- Repentance (talent)
	{31935, "Silence_Arena", "PALADIN"},		-- Silenced - Shield of the Templar (talent)
	{31821 , "Special_High", "PALADIN"},			-- Aura Mastery
	{31884, "Melee_Major_OffenisiveCDs", "PALADIN"}, --Avenging Wrath
	{85696, "Melee_Major_OffenisiveCDs", "PALADIN"}, --Zealotry
	{86698, "Melee_Major_OffenisiveCDs", "PALADIN"}, --Guardian of Ancinets Kings (Prot)
	{1022, "Big_Defensive_CDs", "PALADIN"}, --Hand of Protection 
	{6940 , "Big_Defensive_CDs", "PALADIN"}, --Hand of Sacrifice
	{70940, "Big_Defensive_CDs", "PALADIN"}, --Divine Guardian (Prot)
	{498 , "Big_Defensive_CDs", "PALADIN"}, --Divine Protection
	{86659, "Big_Defensive_CDs", "PALADIN"}, --Guardian of Ancinets Kings (Prot)
	{31850 , "Big_Defensive_CDs", "PALADIN"}, --Ardent Defender (Prot)
	{54428, "Big_Defensive_CDs", "PALADIN"}, -- Divine Plea
	{31842 , "Small_Defensive_CDs", "PALADIN"}, --Divine Favor (Holy)(Crite/Haste)
	{86669, "Small_Defensive_CDs", "PALADIN"}, --Guardian of Ancinets Kings (Holy)
	{1038 , "Small_Defensive_CDs", "PALADIN"}, --Hand of Salvation
	{96263 , "Small_Defensive_CDs", "PALADIN"}, --Sacred Shield
	{1044 , "Freedoms_Speed", "PALADIN"}, --Hand of Freedom
	{25771 , "Special_Low", "PALADIN"}, --Forbearance

	----------------
	-- Priest
	----------------
	{47585 , "Immune_Arena", "PRIEST"}, --Dispersion
	{27827 , "Immune_Arena", "PRIEST"}, --Spirit of Redemption

	{8122, "CC_Arena", "PRIEST"},					-- Psychic Scream 
	{64044, "CC_Arena", "PRIEST"},					-- Psychic Horror (talent)
	{88625, "CC_Arena", "PRIEST"},					-- Chastise
	{605, "CC_Arena", "PRIEST"},					-- Mind Control
	{87204, "CC_Arena", "PRIEST"},					-- Sin and Punshment


	{15487,"Silence_Arena",	"PRIEST"},			-- Silence (talent)

	{96267 , "Special_High", "PRIEST"}, 	--Inner Focus

	{87153, "Ranged_Major_OffenisiveCDs", "PRIEST"}, --Dark Arch Angel

	{87194, "Roots_90_Snares", "PRIEST"},			--Paralysis
	{9484, "Roots_90_Snares", "PRIEST"},			--Shackle Undead

	{64058, "Disarms", "PRIEST"},			-- Psychic Horror (talent)

	{33206 , "Big_Defensive_CDs", "PRIEST"}, --Pain Suprresion
	{81782 , "Big_Defensive_CDs", "PRIEST"}, --Barrier
	{47788 , "Big_Defensive_CDs", "PRIEST"}, --Guardian Spirit
	{10060, "Big_Defensive_CDs", "PRIEST"}, --Power Infusion
	--{14751 , "Small_Defensive_CDs", "PRIEST"}, --Chakra
	{6346 , "Small_Defensive_CDs", "PRIEST"}, --Fear Ward
	{81700 , "Small_Defensive_CDs", "PRIEST"}, --Archangel
	{89485 , "Small_Defensive_CDs", "PRIEST"}, --Inner Focus
	{96219, "Freedoms_Speed", "PRIEST"}, --Holy Walk

	----------------
	-- Rogue
	----------------
	{45182 , "Immune_Arena", "ROGUE"}, --Cheating Death
	{2094, "CC_Arena", "ROGUE"},			-- Blind
	{408, "CC_Arena", "ROGUE"},			-- Kidney Shot

	{1833, "CC_Arena", "ROGUE"},				-- Cheap Shot
	{6770, "CC_Arena", "ROGUE"},				-- Sap 

	{1776, "CC_Arena", "ROGUE"},				-- Gouge
	{1330 , "Silence_Arena", "ROGUE"}, --Garrote - Silence_Arena
	{18425 , "Silence_Arena", "ROGUE"}, --Kick - Silenced (talent)
	{86759 , "Silence_Arena", "ROGUE"}, --Kick - Silenced (talent)
	{88611 , "Special_High", "ROGUE"}, --Smoke Bomb
	{11327 , "Special_High", "ROGUE"}, --Vanish
	{1856 , "Special_High", "ROGUE"}, --Vanish
	{27617 , "Special_High", "ROGUE"}, --Vanish
	--{115191 , "Special_High", "ROGUE"}, --Stealth
	{1784 , "Special_High", "ROGUE"}, --Stealth

	{51722 , "Disarms", "ROGUE"}, --Dismantle
	{79126  , "Disarms", "ROGUE"},	-- Groggy 70%

	{13750 , "Melee_Major_OffenisiveCDs", "ROGUE"}, --Adrenaline Rush
	{51690 , "Melee_Major_OffenisiveCDs", "ROGUE"}, --Killing Spree (talent)
	{51713 , "Melee_Major_OffenisiveCDs", "ROGUE"}, --Shadow Dance
	{14177 , "Melee_Major_OffenisiveCDs", "ROGUE"}, --Cold Blood

	{31224 , "Big_Defensive_CDs", "ROGUE"}, --Cloak of Shadows
	{5277, "Big_Defensive_CDs", "ROGUE"}, --Evasion
	{74001, "Big_Defensive_CDs", "ROGUE"}, --Combat Readiness
	{74002, "Big_Defensive_CDs", "ROGUE"}, --Combat Readiness Insight
	{13877, "Small_Offenisive_CDs", "ROGUE"}, --Blade Flurry
	{396936, "Small_Offenisive_CDs", "ROGUE"}, --Tricks of the Trade 15% DMG
	{396937, "Small_Offenisive_CDs", "ROGUE"}, --Tricks of the Trade 15% DMG
	{57933,	"Small_Offenisive_CDs", "ROGUE"}, --Tricks of the Trade 15% DMG
	{57934 , "Small_Offenisive_CDs", "ROGUE"}, --Tricks of the Trade (From Rogue)
	--{59628, "Small_Offenisive_CDs", "ROGUE"}, --Tricks of the Trade (Threat Only)
	{79140 , "Player_Party_OffensiveCDs", "ROGUE"}, --Vendetta
	{79124 , "Player_Party_OffensiveCDs", "ROGUE"}, --Groggy 30%
	{2983 , "Freedoms_Speed", "ROGUE"}, --Sprinte
	{36554 , "Freedoms_Speed", "ROGUE"}, --Shadowstep
	{GetSpellInfo(5760) or 5760 , "Special_Low", "ROGUE"}, --Mind-numbing Poison
	{26679 , "Snares_Ranged_Spamable", "ROGUE"}, --Deadly Throw
	{25809 , "Snares_Casted_Melee", "ROGUE"}, --Crippling Poison
	{3409 , "Snares_Casted_Melee", "ROGUE"}, --Crippling Poison

	----------------
	-- Shaman
	----------------
	{16188 , "Drink_Purge", "SHAMAN"}, --Nature's Swfitness
	{8178 ,  "Immune_Arena", "SHAMAN"}, --Grounding Totem Effect

	{"Hex" , "CC_Arena", "SHAMAN"},
	{51514 , "CC_Arena", "SHAMAN"},	--Hex
	{77505 , "CC_Arena", "SHAMAN"}, --Earthquake
	{58861 , "CC_Arena", "SHAMAN"}, --Bash (Spirit Wolf)
	{76780 , "CC_Arena", "SHAMAN"}, --Bind Elemental
	{39796, "CC_Arena", "SHAMAN"},  --Stoneclaw Stun (Stoneclaw Totem)

	{16166 , "Ranged_Major_OffenisiveCDs", "SHAMAN"}, --Elemental Mastery (talent)
	{64701 , "Ranged_Major_OffenisiveCDs", "SHAMAN"}, --Elemental Mastery (talent)
	--{2825  , "Ranged_Major_OffenisiveCDs", "SHAMAN"}, --Bloodlust
	--{32182, "Ranged_Major_OffenisiveCDs", "SHAMAN"}, --Heroism

	{64695 , "Roots_90_Snares", "SHAMAN"}, --Earthgrab
	{63685, "Roots_90_Snares", "SHAMAN"}, --Freeze (Frozen Power talent)

	{98007 , "Big_Defensive_CDs", "SHAMAN"}, --Spirit Link Totem
	{30823 , "Big_Defensive_CDs", "SHAMAN"}, --Shamanistic Rage (talent) (damage taken reduced by 30%)

	{79206,	"Small_Offenisive_CDs", "SHAMAN"}, --Spiritwalkers Grace

	{58875 , "Freedoms_Speed", "SHAMAN"}, --Spirit Walk
	{2645 , "Freedoms_Speed", "SHAMAN"}, --Ghost Wolf

	{16191, "Special_Low", "SHAMAN"}, --Mana Tide
	{55277, "Special_Low", "SHAMAN"}, --Stoneclaw


	{8056 , "Snares_Ranged_Spamable", "SHAMAN"},			-- Frost Shock 



	----------------
	-- Warlock
	----------------
--	{18708 , "Drink_Purge", "WARLOCK"}, 				--Fel Domination

	{5782 ,"CC_Arena", "WARLOCK"},						-- Fear
	{5484 ,"CC_Arena", "WARLOCK"},						-- Howl of Terror
	{6789 ,"CC_Arena", "WARLOCK"},						-- Death Coil
	{710 ,"CC_Arena", "WARLOCK"},						-- Banish 
	{93986 ,"CC_Arena", "WARLOCK"},						-- Aura of Foreboding
	{6358 ,"CC_Arena", "WARLOCK"},						-- Seduction (Succubus)
	{89766 ,"CC_Arena", "WARLOCK"},						-- Axe Toss (Felguard)
	{30283 ,"CC_Arena", "WARLOCK"},						-- Shadowfury (talent)
	{85387 ,"CC_Arena", "WARLOCK"},						-- Aftermath
	{54786 ,"CC_Arena", "WARLOCK"},						-- Demon Leap (metamorphosis talent)


	{22703 ,"CC_Arena", "WARLOCK"},						-- Inferno Effect
	{60995 ,"CC_Arena", "WARLOCK"},						-- Demon Charge (metamorphosis talent)
	{30153 ,"CC_Arena", "WARLOCK"},					-- Intercept Stun  (Felguard)
	{19482 ,"CC_Arena", "WARLOCK"},					-- War Stomp (Doomguard)
	{32752 ,"CC_Arena", "WARLOCK"},					-- Summoning Disorientation

	{31117 , "Silence_Arena", "WARLOCK"}, --Unstable Affliction
	{24259 , "Silence_Arena", "WARLOCK"}, --Spell Lock (Felhunter)

	{47241, "Ranged_Major_OffenisiveCDs", "WARLOCK"}, --Metamorphosis
	{79463, "Ranged_Major_OffenisiveCDs", "WARLOCK"}, --Demon Soul Incubus Both
	{79460, "Ranged_Major_OffenisiveCDs", "WARLOCK"}, --Demon Soul Fel Hunter
	{79464, "Ranged_Major_OffenisiveCDs", "WARLOCK"}, --Demon Soul Void walker
	{79459, "Ranged_Major_OffenisiveCDs", "WARLOCK"}, --Demon Soul Imp
	{79462, "Ranged_Major_OffenisiveCDs", "WARLOCK"}, --Demon Soul Imp

	{93987, "Roots_90_Snares", "WARLOCK"},			--Aura of Foreboding

	{79268, "Big_Defensive_CDs", "WARLOCK"}, --Soul Harvest

	{86211, "Small_Offenisive_CDs", "WARLOCK"}, --Soulswap
	{79437 , "Small_Defensive_CDs", "WARLOCK"}, -- Soulburn: Healthstone
	{7812 , "Small_Defensive_CDs", "WARLOCK"}, -- Sacrfice
	{GetSpellInfo(7812) or 7812 , "Small_Defensive_CDs", "WARLOCK"}, -- Sacrfice

	{63311 , "Snares_WithCDs", "WARLOCK"}, -- Glyph of Shadowflame

	{79438 , "Freedoms_Speed", "WARLOCK"}, --Soulburn: Demonic Cirlce

	{1714 , "Special_Low", "WARLOCK"}, --Curse of Tongues
	{91711 , "Special_Low", "WARLOCK"}, --Nether Ward


	{18223 , "Snares_Ranged_Spamable", "WARLOCK"}, --Curse of Exhaustion

	{702 , "Snares_Casted_Melee", "WARLOCK"}, --Curse of Weakness



	----------------
	-- Warrior
	----------------
	{46924  , "Immune_Arena", "WARRIOR"}, -- Bladestorm (not immune to dmg}, only to LoC)

	{7922 ,"CC_Arena", "WARRIOR"},					-- Charge (rank 1/2/3)
	{96273 ,"CC_Arena", "WARRIOR"},					-- Charge (rank 1/2/3)
	{20253 ,"CC_Arena", "WARRIOR"},				-- Intercept
	{85388 ,"CC_Arena", "WARRIOR"},			-- -- Throwdown
	{5246 ,"CC_Arena", "WARRIOR"},				-- Intimidating Shout
	{20511 ,"CC_Arena", "WARRIOR"},				-- Intimidating Shout
	{12809 ,"CC_Arena", "WARRIOR"},			-- Concussion Blow (talent)
	{46968 ,"CC_Arena", "WARRIOR"},			-- Shockwave (talent)

	{18498 , "Silence_Arena", "WARRIOR"},		-- Silenced - Gag Order (Improved Shield Bash talent)

	{23920 , "Special_High", "WARRIOR"}, -- Spell Reflection
	{59725 , "Special_High", "WARRIOR"}, -- Spell Reflection
	{3411 , "Special_High", "WARRIOR"}, -- Intervene

	{23694 , "Roots_90_Snares", "WARRIOR"}, --Improved Hwamstring (talent)

	{676 , "Disarms", "WARRIOR"}, --Disarm

	{12292 , "Melee_Major_OffenisiveCDs", "WARRIOR"}, -- Death Wish
	{1719 , "Melee_Major_OffenisiveCDs", "WARRIOR"}, -- Recklessness

	{18499 , "Big_Defensive_CDs", "WARRIOR"}, -- Berserker Rage
	{55694 , "Big_Defensive_CDs", "WARRIOR"}, -- Enraged Regeneration
	{871 , "Big_Defensive_CDs", "WARRIOR"}, -- Shield Wall
	{20230 , "Big_Defensive_CDs", "WARRIOR"}, -- Retaliation

	{85730 , "Small_Offenisive_CDs", "WARRIOR"}, -- Deadly Calm
	{12328 , "Small_Offenisive_CDs", "WARRIOR"}, -- Sweeping Strikes

	{2565 , "Small_Defensive_CDs", "WARRIOR"}, -- Shield Block
	{12976 , "Small_Defensive_CDs", "WARRIOR"}, -- Last Stand
	{97463 , "Small_Defensive_CDs", "WARRIOR"}, -- Rally

	{12323 , "Snares_WithCDs", "WARRIOR"}, -- Piercing Howl

	{1715, "Snares_Casted_Melee", "WARRIOR"}, -- Hamstring


	----------------
	-- Misc.
	----------------

	{"Drink" , "Drink_Purge", "PvP"},
	{"Refreshment" , "Drink_Purge", "PvP"},

	{20549 , "CC_Arena", "Racials"}, --War Stomp
	{46026 , "CC_Arena", "Racials"}, --War Stomp

	{25046 , "Silence_Arena", "Racials"},				-- Arcane Torrent (blood elf racial)
	{28730 , "Silence_Arena", "Racials"},				-- Arcane Torrent (blood elf racial)
	{50613 , "Silence_Arena", "Racials"},				-- Arcane Torrent (blood elf racial)

	{58984, "Special_High", "Racials"}, -- Shadowmeld


	{28880, "Small_Defensive_CDs", "Racials"},-- Gift of the Naaru
	{GetSpellInfo(28880) or 28880, "Small_Defensive_CDs", "Racials"},-- Gift of the Naaru
	{65116, "Small_Defensive_CDs", "Racials"}, -- Stoneform
	{GetSpellInfo(65116) or 65116, "Small_Defensive_CDs", "Racials"},-- Stoneform
	{GetSpellInfo(71635) or 71635, "Small_Defensive_CDs", "PvP"},-- Aegis of Dalaran

	{"Gladiator's Emblem", "Small_Defensive_CDs", "PvP"}, -- Gladiator's Emblem
	{"Tremendous Fortitude", "Small_Defensive_CDs", "PvP"}, -- Gladiator's Emblem

	{34709, "Special_Low", "PvP"}, --Shadow Sight

	}

	local spellsTable = {

	{"PVP", --TAB

	
	{49203 , "CC", nil,  "DEATHKNIGHT"}, --Hungering Cold (talent)
	{47481 , "CC", nil,  "DEATHKNIGHT"}, --Gnaw
	{91800 , "CC", nil, "DEATHKNIGHT"}, --Gnaw
	{91797 , "CC", nil, "DEATHKNIGHT"}, --Monstrous Blow

	{33786 , "CC", nil, "DRUID"}, 	--Cyclone
	{5211 , "CC", nil, "DRUID"},	-- Bash
	{9005 , "CC", nil, "DRUID"},	-- Pounce
	{22570 , "CC", nil, "DRUID"},	-- Maim
	{2637 , "CC", nil, "DRUID"},	-- Hibernate (rank 1)


	{1513, "CC", nil, "HUNTER"},			-- Scare Beast 
	{3355, "CC", nil, "HUNTER"},			-- Freezing Trap 
	{19386, "CC", nil, "HUNTER"},			-- Wyvern Sting (talent) 
	{19503, "CC", nil, "HUNTER"},			-- Scatter Shot (talent)

	{90337, "CC", nil, "HUNTER"},				-- Bad Manner
	{24394, "CC", nil, "HUNTER"},				-- Intimidation (talent)
	{50519, "CC", nil, "HUNTER"},				-- Sonic Blast (Bat)


	{"Polymorph" , "CC", nil, "MAGE"},
	{118,   "CC", nil, "MAGE"},				-- Polymorph (rank 1)
	{28271, "CC", nil, "MAGE"},				-- Polymorph: Turtle
	{28272, "CC", nil, "MAGE"},				-- Polymorph: Pig
	{61305, "CC", nil, "MAGE"},				-- Polymorph: Black Cat
	{61721, "CC", nil, "MAGE"},				-- Polymorph: Rabbit
	{61780, "CC", nil, "MAGE"},				-- Polymorph: Turkey
	{71319, "CC", nil, "MAGE"},				-- Polymorph: Turkey
	{61025, "CC", nil, "MAGE"},				-- Polymorph: Serpent
	{59634, "CC", nil, "MAGE"},				-- Polymorph - Penguin (Glyph)
	{82691, "CC", nil, "MAGE"},				-- Ring of Frost
	{83047, "CC", nil, "MAGE"},				-- Improved Polymorph (talent)
	{12355, "CC", nil, "MAGE"},				-- Impact (talent)
	{31661, "CC", nil, "MAGE"},				-- Dragon's Breath (talent)
	{44572, "CC", nil, "MAGE"},				-- Deep Freeze (talent)

	{853, "CC", nil, "PALADIN"},				-- Hammer of Justice
	{2812, "CC", nil, "PALADIN"},				-- Holy Wrath
	{10326, "CC", nil, "PALADIN"},				-- Turn Evil
	{20066, "CC", nil, "PALADIN"},				-- Repentance (talent)

	{8122, "CC", nil, "PRIEST"},				-- Psychic Scream 
	{605, "CC", nil, "PRIEST"},					-- Mind Control
	{88625, "CC", nil, "PRIEST"},				-- Chastise
	{87204, "CC", nil, "PRIEST"},				-- Sin and Punishment
	{64044, "CC", nil, "PRIEST"},				-- Psychic Horror (talent)

	{2094, "CC", nil, "ROGUE"},				-- Blind
	{408, "CC", nil, "ROGUE"},				-- Kidney Shot 
	{1833, "CC", nil, "ROGUE"},				-- Cheap Shot
	{6770, "CC", nil, "ROGUE"},				-- Sap 
	{1776, "CC", nil, "ROGUE"},				-- Gouge


	{"Hex" , "CC", nil, "SHAMAN"},
	{51514 , "CC", nil, "SHAMAN"},		-- Hex
	{58861 , "CC", nil, "SHAMAN"}, 		--Bash (Spirit Wolf)
	{39796, "CC", nil, "SHAMAN"},  		--Stoneclaw Stun (Stoneclaw Totem)
	{77505 , "CC", nil, "SHAMAN"}, 		--Earthquake
	{76780 , "CC", nil, "SHAMAN"}, 		--Bind Elemental

	{5782 ,"CC", nil, "WARLOCK"},						-- Fear
	{5484 ,"CC", nil, "WARLOCK"},						-- Howl of Terror
	{6789 ,"CC", nil, "WARLOCK"},						-- Death Coil
	{710 ,"CC", nil, "WARLOCK"},						-- Banish 
	{93986 ,"CC", nil, "WARLOCK"},						-- Aura of Foreboding
	{6358 ,"CC", nil, "WARLOCK"},						-- Seduction (Succubus)
	{89766 ,"CC", nil, "WARLOCK"},						-- Axe Toss (Felguard)
	{30283 ,"CC", nil, "WARLOCK"},						-- Shadowfury (talent)
	{54786 ,"CC", nil, "WARLOCK"},						-- Demon Leap (metamorphosis talent)
	{85387 ,"CC", nil, "WARLOCK"},						-- Aftermath


	{22703 ,"CC", nil, "WARLOCK"},						-- Inferno Effect
	{60995 ,"CC", nil, "WARLOCK"},						-- Demon Charge (metamorphosis talent)
	{30153 ,"CC", nil, "WARLOCK"},					-- Intercept Stun (rank 1) (Felguard)
	{19482 ,"CC", nil, "WARLOCK"},					-- War Stomp (Doomguard)
	{32752 ,"CC", nil, "WARLOCK"},					-- Summoning Disorientation

	{7922 ,"CC",  nil, "WARRIOR"},					-- Charge (rank 1/2/3)
	{96273 ,"CC",  nil, "WARRIOR"},					-- Charge (rank 1/2/3)
	{20253 ,"CC",  nil, "WARRIOR"},				-- Intercept
	{5246 ,"CC",  nil, "WARRIOR"},				-- Intimidating Shout
	{20511 ,"CC",  nil, "WARRIOR"},				-- Intimidating Shout
	{85388 ,"CC",  nil, "WARRIOR"},			-- Throwdown
	{12809 ,"CC",  nil, "WARRIOR"},			-- Concussion Blow (talent)
	{46968 ,"CC",  nil, "WARRIOR"},			-- Shockwave (talent)

	{20549  , "CC", nil, "Racials"},				-- War Stomp (tauren racial)


	{47476  , "Silence", nil,  "DEATHKNIGHT"}, -- Strangulate
	{81261  , "Silence", nil,  "DRUID"}, -- Strangulate
	{GetSpellInfo(34490) , "Silence", nil,  "HUNTER"}, --Silencing Shot
	{18469, "Silence", nil,  "MAGE"},		-- Counterspell - Silenced (rank 1) (Improved Counterspell talent)
	{55021, "Silence", nil,  "MAGE"},				-- Counterspell - Silenced (rank 2) (Improved Counterspell talent)
	{31935, "Silence", nil, "PALADIN"},		-- Silenced - Avenger's Shield
	{15487, "Silence", nil,	"PRIEST"},			-- Silence (talent)
	{1330 , "Silence", nil, "ROGUE"}, 		--Garrote - Silence_Arena
	{18425 , "Silence", nil, "ROGUE"}, 		--Kick - Silenced (talent)
	{86759 , "Silence", nil, "ROGUE"}, 		--Kick - Silenced (talent)
	{31117 , "Silence", nil, "WARLOCK"}, 		--Unstable Affliction
	{24259 ,  "Silence", nil, "WARLOCK"}, 		--Spell Lock (Felhunter)
	{18498 , "Silence", nil, "WARRIOR"},		-- Silenced - Gag Order (Improved Shield Bash talent
	{25046 , "Silence", nil, "Racials"},				-- Arcane Torrent (blood elf racial)
	{28730 , "Silence", nil, "Racials"},				-- Arcane Torrent (blood elf racial)
	{50613 , "Silence", nil, "Racials"},				-- Arcane Torrent (blood elf racial)


	--{212638 , "RootPhyiscal_Special"},				-- Tracker's Net (pvp honor talent) -- Also -80% hit chance melee & range physical (CC and Root category)
	{96294 , "Root", nil, "DEATHKNIGHT"}, 	-- CHains of Ice Root
	{96293 , "Root", nil, "DEATHKNIGHT"}, 	-- CHains of Ice Root
	{339 , "Root", nil, "DRUID"}, 	-- Entangling Roots
	{19975 , "Root", nil, "DRUID"},	-- Entangling Roots (Nature's Grasp spell)
	{GetSpellInfo(16979) or 16979 , "Root", nil, "DRUID"},	-- Feral Charge Effect (Feral Charge talent)
	{45334 , "Root", nil, "DRUID"},			-- Feral Charge Effect (Feral Charge talent)
	{19306, "Root", nil, "HUNTER"},			-- Counterattack (talent)
	{19185, "Root", nil, "HUNTER"},			-- Entrapment (talent)
	{64803, "Root", nil, "HUNTER"},			-- Entrapment (talent)
	{4167, "Root", nil, "HUNTER"},			-- Web (Spider)
	{54706, "Root", nil, "HUNTER"},			-- Venom Web Spray (Silithid)
	{50245, "Root", nil, "HUNTER"},			-- Pin (Crab)
	{53148, "Root", nil, "HUNTER"},			-- Charge (Bear and Carrion Bird)
	{25999, "Root", nil, "HUNTER"},			-- Boar Charge (Boar)
	{122, "Root", nil, "MAGE"},				-- Frost Nova 
	{83302, "Root", nil, "MAGE"},			-- Imp Cone of Cold
	{55080, "Root", nil, "MAGE"},			-- Shattered Barrier (talent)
	{83073, "Root", nil, "MAGE"},			-- Shattered Barrier (talent)
	{33395, "Root", nil, "MAGE"},			-- Freeze
	{87194, "Root", nil, "PRIEST"},			-- Paralysis
	{9484, "Root", nil, "PRIEST"},			-- Shackle Undead
	{64695 , "Root", nil, "SHAMAN"}, 		-- Earthgrab
	{63685, "Root", nil, "SHAMAN"}, 		-- Freeze (Frozen Power talent)
	{93987, "Root", nil, "WARLOCK"},			--Aura of Foreboding
	{23694 , "Root", nil, "WARRIOR"}, 		-- Imp Hamstring


	{45438  , "ImmunePlayer", "Ice".."\n".."Block", "MAGE"},			-- Ice Block 
	{642    , "ImmunePlayer", "Divine".."\n".."Shield", "PALADIN"},			-- Divine Shield
	{47585  , "ImmunePlayer", "Dispersion", "PRIEST"},			-- Dispersion
	{27827  , "ImmunePlayer", "Spirit of".."\n".."Redemption", "PRIEST"},			-- Spirit of Redemption


	{77606  , "Disarm_Warning", "Dark".."\n".."Simulacrum", "DEATHKNIGHT"},   -- Dark Simulacrum
	--{322442 , "Disarm_Warning"}, --Thoughtstolen

	--{117405 , "CC_Warning", "Binding Shot".."\n".."WARNING!!"},	    -- Binding Shot
	--{191241 , "CC_Warning", "Sticky".."\n".."Bomb"},	    -- Sticky Bomb
	{61882 , "CC_Warning", "Earthquake", "SHAMAN"}, --Earthquake

	{5215   , "Stealth", "Prowl", "DRUID"},  -- Prowl

	{66     , "Stealth", "Invisibility", "MAGE"},   -- Invis
	{32612  , "Stealth", "Invisibility", "MAGE"}, 	-- Invis
	{58984  , "Stealth", nil, "Racials"},     -- Meld


	{1022   , "Immune", "Hand of".."\n".."Protection", "PALADIN"},	    	-- Hand of Protection


	--  "ImmuneSpell",
	--	"ImmunePhysical",

	{31821 , "AuraMastery_Cast_Auras", "Aura".."\n".."Mastery", "PALADIN"},			-- Aura Mastery
	{96267 , "AuraMastery_Cast_Auras", "Inner".."\n".."Focus", "PRIEST"},			-- Inner Focus Strength & Soul
	--{289655 , "AuraMastery_Cast_Auras", "Holy Word".."\n".."Concentration"},-- Holy Word: Concentration

	--{127797 , "ROP_Vortex", "Ursol's".."\n".."Vortex"},				-- Ursol's Vortex
	--{102793 , "ROP_Vortex", "Ursol's".."\n".."Vortex"},				-- Ursol's Vortex
	--{383005 , "ROP_Vortex", "Chrono".."\n".."Loop"}, 				-- Chrono Loop
	--{383870 , "ROP_Vortex", "Swoop".."\n".."Up"}, 				-- Chrono Loop
	--{353293 , "ROP_Vortex", "Shadow".."\n".."Rift"}, 				-- Shadow Rift


	{54404, "Disarm", nil, "HUNTER"},			-- Dust Cloud (chance to hit reduced by 100%) (Tallstrider)
	{50541, "Disarm", nil, "HUNTER"},			-- Snatch (Bird of Prey)
	--{64346, "Disarm", nil,  "MAGE"},			-- Fiery Payback (talent)
	{64058, "Disarm", nil, "PRIEST"},			-- Psychic Horror (talent)
	{51722 , "Disarm", nil, "ROGUE"},			-- Dismantle
	--{79126  , "Disarm", nil, "ROGUE"},			-- Groggy
	{676 , "Disarm", nil, "WARRIOR"},			-- Disarm


	{1714   , "Haste_Reduction", "Curse of".."\n".."Tongues", "WARLOCK"},			-- Curse of Tongues
	{GetSpellInfo(1714) or 1714 , "Haste_Reduction", "Curse of".."\n".."Tongues", "WARLOCK"},			-- Curse of Tongues


	{702    , "Dmg_Hit_Reduction", "Curse of".."\n".."Weakness", "WARLOCK"},   -- Curse of Weakness
	{GetSpellInfo(702) or 702  , "Dmg_Hit_Reduction", "Curse of".."\n".."Weakness", "WARLOCK"},   -- Curse of Weakness

	--Interrupt

	--{57934 , "AOE_DMG_Modifiers", "Tricks"},				-- Tricks of the Trade
	{396936 , "AOE_DMG_Modifiers", "Tricks", "ROGUE"},				-- Tricks of the Trade
	{396937 , "AOE_DMG_Modifiers", "Tricks", "ROGUE"},				-- Tricks of the Trade
	{57933 , "AOE_DMG_Modifiers", "Tricks", "ROGUE"},				-- Tricks of the Trade

	{88611 , "Friendly_Smoke_Bomb", "Smoke".."\n".."Bomb"},			-- Smoke Bomb

	{8178   , "AOE_Spell_Refections", "Grounding".."\n".."Totem", "SHAMAN"},		-- Grounding Totem Effect (Grounding Totem)


	{31643, "Speed_Freedoms", "Blazing".."\n".."Speed",  "MAGE"}, --Blazing Speed
	{GetSpellInfo(31643) or 31643, "Speed_Freedoms", "Blazing".."\n".."Speed", "MAGE"}, --Blazing Speed

	{77764 ,  "Freedoms", "Stampeding".."\n".."Roar", "DRUID"}, --Stampeding Roar (Feral)
	{77761,  "Freedoms", "Stampeding".."\n".."Roar", "DRUID"}, --Stampeding Roar (Bear)
	{1850 ,  "Freedoms", "Dash", "DRUID"}, --Dash

	{54216 , "Freedoms", "Master's".."\n".."Call", "HUNTER"},		-- Master's Call
	{"Master's Call" , "Freedoms", "Master's".."\n".."Call", "HUNTER"},		-- Master's Call
	{1044 , "Freedoms", "Hand of".."\n".."Freedom", "PALADIN"},	 --Blessing of Freedom (Not Purgeable)
	{96219, "Freedoms", "Holy".."\n".."Walk",  "PRIEST"}, --Holy Walk -- 4 Set
	{36554 , "Freedoms", nil, "ROGUE"},		-- Shadowstep
	{2983 , "Freedoms", nil, "ROGUE"},			-- Sprint
	{58875 , "Freedoms", nil, "SHAMAN"},		-- Spirit Walk
	{79438 , "Freedoms", nil, "WARLOCK"}, 	--Soulburn: Demonic Cirlce
	{54861 , "Freedoms", "Nitro".."\n".."Boots"},		-- Nitro Boots


	{53476 , "Friendly_Defensives", "Intervene", "HUNTER"}, --Intervene (Pet)
	{87023 , "Friendly_Defensives", "Cauterize", "MAGE"}, --Cauterize
	{6940 , "Friendly_Defensives", "Hand of".."\n".."Sacrifice", "PALADIN"},			-- Blessing of Sacrifice
	{3411 , "Friendly_Defensives", "Intervene", "WARRIOR"},		-- Intervene

	--{201633 , "Friendly_Defensives"},		-- Earthen
	--{81782 , "Friendly_Defensives"},		-- Barrier


	{49016, "CC_Reduction", "Unholy".."\n".."Frenzy", "DEATHKNIGHT"},		-- Unholy Frenzy
	{6346, "CC_Reduction", "Fear".."\n".."Ward", "PRIEST"},		-- Fear Ward


	--{GetSpellInfo(11129) or 11129, "Personal_Offensives", "Combustion", "MAGE"}, --Combustion
	{12042, "Personal_Offensives",  "Arcane".."\n".."Power", "MAGE"}, --Arcane Power
	{12043 , "Personal_Offensives",  "Presence".."\n".."of Mind", "MAGE"}, --Presence of Mind
	{12472, "Personal_Offensives",  "Icy".."\n".."Veins", "MAGE"}, --Icy Veins
	{33891, "Personal_Offensives", "Tree of".."\n".."Life", "DRUID"},	-- Tree of Life
	{89485, "Personal_Offensives", "Inner".."\n".."Focus", "PRIEST"},	-- Inner Focus
	{87153, "Personal_Offensives", "Dark".."\n".."Archangel", "PRIEST"},	-- Dark Archangel


	{22842, "Peronsal_Defensives", "Frenzied".."\n".."Regeneration", "DRUID"},		-- Frenzied Regeneration
	--{22812, "Peronsal_Defensives", "Barkskin", "DRUID"},		-- Barkskin

	
	{10060,  "Movable_Cast_Auras", "Power".."\n".."Infusion", "PRIEST"},		-- Power Infusion
	--{2825, "Movable_Cast_Auras", "Bloodlust", "SHAMAN"},	-- Bloodlust (Shamanism pvp talent)
	--{32182, "Movable_Cast_Auras", "Heroism", "SHAMAN"},	-- Heroism (Shamanism pvp talent


	{29166, "Mana_Regen", "Innervate", "DRUID"},		-- Innervate
	{64901, "Mana_Regen", "Hymn".."\n".."of Hope", "PRIEST"},		-- Symbol of Hope
	--"Other", --
	--"PvE", --PVE only

	--{45524, "SnareSpecial", "Chains".."\n".."of Ice", "DEATHKNIGHT"}, 		-- Chains of Ice


	{45524, "SnarePhysical70", "Chains".."\n".."of Ice", "DEATHKNIGHT"}, 		-- Chains of Ice
	{15571, "SnarePhysical70", nil, "HUNTER"},			-- Dazed From Aspect of the Cheetah/Pact
	{3409, "SnarePhysical70",  nil, "ROGUE"},			-- Crippling Poison (Poison)
	{31125, "SnarePhysical70", nil, "ROGUE"},			-- Dazed (Blade Twisting) (rank 1) (talent)
	{51585, "SnarePhysical70", nil, "ROGUE"},			-- Dazed (Blade Twisting) (rank 2) (talent)
	--{26679, "SnarePhysical70",  nil, "ROGUE"},			-- Deadly Throw  w/Glyph
	{63311, "SnarePhysical70", nil, "WARLOCK"},			-- Shadowflame


	{61394, "SnareMagic70",	nil, "HUNTER"},				-- Glyph of Freezing Trap
	{11113, "SnareMagic70",	nil, "MAGE"},				-- Blast Wave (talent) (rank 1)
	{44614, "SnareMagic70",	nil, "MAGE"},				-- Frostfire Bolt 
	{31589, "SnareMagic70",	nil, "MAGE"},				-- Slow
	{18118, "SnareMagic70", nil, "WARLOCK"},			--  Aftermath


	{58617, "SnarePhysical50", nil, "DEATHKNIGHT"}, 	-- Glyph of Heart Strike
	{68766, "SnarePhysical50", nil, "DEATHKNIGHT"}, 	-- Desecration (talent)
	{414266,"SnarePhysical50", nil, "DEATHKNIGHT"}, 	-- Desecration (talent)
	{414268,"SnarePhysical50", nil, "DEATHKNIGHT"}, 	-- Desecration (talent) Rank 2
	{50435, "SnarePhysical50", nil, "DEATHKNIGHT"},		-- Chillblains Rank 2
	{50259, "SnarePhysical50", nil, "DRUID"},			-- Dazed
	{61391, "SnarePhysical50", nil, "DRUID"},			-- Typhoon (talent) 
	{5116, "SnarePhysical50", nil, "HUNTER"},			-- Concussive Shot
	{2974, "SnarePhysical50", nil, "HUNTER"},			-- FWing Clip
	{13809, "SnarePhysical50", nil, "HUNTER"},			-- Frost Trap
	{13810, "SnarePhysical50", nil, "HUNTER"},			-- Frost Trap Aura
	{35101, "SnarePhysical50", nil, "HUNTER"},			-- Concussive Barrage (talent)
	{50271, "SnarePhysical50", nil, "HUNTER"},			-- Tendon Rip (Hyena)
	{54644, "SnarePhysical50", nil, "HUNTER"},			-- Froststorm Breath (Chimaera)
	{26679, "SnarePhysical50",  nil, "ROGUE"},			-- Deadly Throw (rank 1)
	{12485, "SnarePhysical50",	nil, "MAGE"},			-- Chilled (rank 2) (Improved Blizzard talent)
	{84721, "SnarePhysical50",	nil, "MAGE"},			-- Frozen Orb
	{15407, "SnarePhysical50",  nil, "PRIEST"},			-- Mind Flay (talent) 
	{51693, "SnarePhysical50",  nil, "ROGUE"},			-- Waylay (talent)
	{8034, "SnarePhysical50",  nil, "SHAMAN"},			-- Frostbrand Attack (rank 1)
	{1715, "SnarePhysical50",  nil, "WARRIOR"},			-- Hamstring
	{12323, "SnarePhysical50",  nil, "WARRIOR"},		-- Piercing Howl (talent)


	{58180, "SnarePosion50", nil, "DRUID"},			-- Infected Wounds Rank 2
	{25809, "SnarePosion50",  nil, "ROGUE"},			-- Crippling Poison (Poison)


	{120, "SnareMagic50",	nil, "MAGE"},			-- Cone of Cold 
	{"Frostbolt", "SnareMagic50", nil, "MAGE"},		-- Frostbolt
	{116, "SnareMagic50",	nil, "MAGE"},			-- Frostbolt 
	{59638, "SnareMagic50",	nil, "MAGE"},			-- Frostbolt (Mirror Images)
	{63529, "SnareMagic50",	nil, "PALADIN"},		-- Avenger's Shield 
	{8056, "SnareMagic50", nil, "SHAMAN"},			-- Frost Shock
	{3600, "SnareMagic50", nil, "SHAMAN"},			-- Earthbind
	{100955, "SnareMagic50", nil, "SHAMAN"},			-- Thunderstorm


	{414206, "SnarePhysical30", nil, "DEATHKNIGHT"},	-- Desecration (talent) Rank 1
	{414207, "SnarePhysical30", nil, "DEATHKNIGHT"},	-- Desecration (talent) Rank 1
	{50434, "SnarePhysical30", nil, "DEATHKNIGHT"},		-- Chillblains Rank 1
	{12484, "SnarePhysical30",	nil, "MAGE"},		-- Chilled (rank 1) (Improved Blizzard talent)

	{58179,  "SnareMagic30", nil, "DRUID"}, 		-- Infected Wounds Rank 1
	{6136, "SnareMagic30", nil, "MAGE"},			-- Chilled (Frost Armor)
	{7321, "SnareMagic30", nil, "MAGE"},			-- Chilled (Ice Armor)
	{18223, "SnareMagic30", nil, "WARLOCK"},			-- Curse of Exhaustion
	{60947, "SnareMagic30", nil, "WARLOCK"},			-- Nightmare


	{89,  "Snare", nil, "WARLOCK"}, 		-- Cripple
	{20170,  "Snare", nil, "PALADIN"}, 		-- Seal of Justice





	----------------
	-- Death Knight
	----------------

	{48707, "Other", nil, "DEATHKNIGHT"}, 				-- Anti-Magic Shell
	{50461, "Other", nil, "DEATHKNIGHT"}, 				-- Anti-Magic Zone (talent)
	{42650, "Other", nil, "DEATHKNIGHT"}, 				-- Army of the Dead (not immune, the Death Knight takes less damage equal to his Dodge plus Parry chance)
	{48792, "Other", nil, "DEATHKNIGHT"}, 				-- Icebound Fortitude
	{51271, "Other", nil, "DEATHKNIGHT"}, 				-- Unbreakable Armor (talent)
	{49039, "Other", nil, "DEATHKNIGHT"}, 				-- Lichborne (talent)
	{47484, "Other", nil, "DEATHKNIGHT"}, 				-- Huddle (not immune, damage taken reduced 50%) (Turtle)

	----------------
	-- Druid
	----------------

	{50334 , "Other", nil, "DRUID"},		-- Berserk (talent)
	{17116 , "Other", nil, "DRUID"},		-- Nature's Swiftness (talent)
	{16689 , "Other", nil, "DRUID"},		-- Nature's Grasp
	{22812 , "Other", nil, "DRUID"},		-- Barkskin
	--{29166 , "Other", nil, "DRUID"},		-- Innervate
	{48505 , "Other", nil, "DRUID"},		-- Starfall (talent)
	{69369 , "Other", nil, "DRUID"},		-- Predator's Swiftness (talent)


	----------------
	-- Hunter
	----------------


	{19263 , "Other", nil, "HUNTER"}, --Deterrence (not immune, parry chance increased by 100% and grants a 100% chance to deflect spells)
	{5384 , "Other", nil, "HUNTER"}, --Fiegn Death
	{34471 , "Other", nil, "HUNTER"}, --The Beast Within (PvP)
	{19574, "Other", nil, "HUNTER"}, --Bestial Wrath
	{3045 , "Other", nil, "HUNTER"}, --Rapid Fire

	  ----------------
	  -- Hunter Pets
	  ----------------

	  {1742 , "Other", nil, "HUNTER"},		-- Cower (not immune, damage taken reduced 40%)
	  {26064 , "Other", nil, "HUNTER"},		-- Shell Shield (not immune, damage taken reduced 50%) (Turtle)

	----------------
	-- Mage
	----------------

	{83853 , "Other", nil, "MAGE"},	--Combustion

	----------------
	-- Paladin
	----------------

	{31884, "Other", nil, "PALADIN"}, --Avenging Wrath
	{86659 , "Other", nil, "PALADIN"}, --GoAK
	{86669 , "Other", nil, "PALADIN"}, --GoAK
	{86698, "Other", nil, "PALADIN"}, --GoAK
	{64205, "Other", nil, "PALADIN"}, --Divine Sacrifice
	{498 , "Other", nil, "PALADIN"}, --Divine Protection
	{54428, "Other", nil, "PALADIN"}, -- Divine Plea
	{31842, "Other", nil, "PALADIN"}, -- Divine Illumination (talent)
	{31850, "Other", nil, "PALADIN"}, --Ardent Defender
	{1038 , "Other", nil, "PALADIN"}, --Hand of Salvation
	{25771 , "Other", nil, "PALADIN"}, --Forbearance

	----------------
	-- Priest
	----------------

	{47788  , "Other", nil, "PRIEST"},			-- Guardian Spirit (prevent the target from dying)
	{33206  , "Other", nil, "PRIEST"},			-- Pain Suppression

	----------------
	-- Rogue
	----------------

	{31224  , "Other", nil, "ROGUE"},	     	-- Cloak of Shadows
	{51690  , "Other", nil, "ROGUE"},			-- Killing Spree
	{13750  , "Other", nil, "ROGUE"},			-- Adrenaline Rush
	{51713  , "Other", nil, "ROGUE"},			-- Shadow Dance
	{45182  , "Other", nil, "ROGUE"},			-- Cheating Death (-85% damage taken)
	{5277   , "Other", nil, "ROGUE"},	      	-- Evasion (dodge chance increased by 100%)
	{74001  , "Other", nil, "ROGUE"},	     	-- Combat Readiness
	{74002  , "Other", nil, "ROGUE"},	     	-- Combat Readiness Insight
	{79140  , "Other", nil, "ROGUE"},	     	-- Vendetta

	----------------
	-- Shaman
	----------------

	{16188 , "Other", nil, "SHAMAN"}, --Nature's Swfitness
	{16166 , "Other", nil, "SHAMAN"}, --Elemental Mastery (talent)
	{64701 , "Other", nil, "SHAMAN"}, --Elemental Mastery (talent)
	{30823 , "Other", nil, "SHAMAN"}, --Shamanistic Rage (talent) (damage taken reduced by 30%)
	--{58875 , "Other", nil, "SHAMAN"}, --Spirit Walk
	{2645 , "Other", nil, "SHAMAN"}, --Ghost Wolf
	{98007 , "Other", nil, "SHAMAN"}, --Spirit Link
	{79206 , "Other", nil, "SHAMAN"}, --Spiritwalkers Grace


	----------------
	-- Warlock
	----------------

	{47241, "Other", nil, "WARLOCK"}, --Metamorphosis
	{79463, "Other", nil, "WARLOCK"}, --Demon Soul Incubus Both
	{79460, "Other", nil, "WARLOCK"}, --Demon Soul Fel Hunter
	{79464, "Other", nil, "WARLOCK"}, --Demon Soul Void walker
	{79459, "Other", nil, "WARLOCK"}, --Demon Soul Imp


	----------------
	-- Warrior
	----------------
	{46924 ,  "Other", nil,  "WARRIOR"}, --  Bladestorm (talent) (not immune to dmg, only to LoC)
	{23920 ,  "Other", nil,  "WARRIOR"}, --  Spell Reflection
	{59725 ,  "Other", nil,  "WARRIOR"}, --  Spell Reflection	(Improved Spell Reflection talent)
	{12292 ,  "Other", nil,  "WARRIOR"}, -- Death Wish
	{1719 ,  "Other", nil,  "WARRIOR"}, -- Recklessness
	{18499 ,  "Other", nil,  "WARRIOR"}, -- Berserker Rage
	{55694 ,  "Other", nil,  "WARRIOR"}, -- Enraged Regeneration
	{871 ,  "Other", nil,  "WARRIOR"}, -- Shield Wall
	{20230 ,  "Other", nil,  "WARRIOR"}, -- Retaliation
	{12976 ,  "Other", nil, "WARRIOR"}, -- Last Stand
	{12328 ,  "Other", nil,  "WARRIOR"}, -- Sweeping Strikes
	{2565 ,  "Other", nil,  "WARRIOR"}, -- Shield Block



},

	----------------
	-- Other
	----------------
{"Other", --TAB
	
{56 , "CC"},				-- Stun (some weapons proc)
{835 , "CC"},				-- Tidal Charm (trinket)
{4159 , "CC"},				-- Tight Pinch
{8312 , "Root"},				-- Trap (Hunting Net trinket)
{17308 , "CC"},				-- Stun (Hurd Smasher fist weapon)
{23454 , "CC"},				-- Stun (The Unstoppable Force weapon)
{9179 , "CC"},				-- Stun (Tigule and Foror's Strawberry Ice Cream item)
{26297 , "Other"},				-- Berserking (troll racial)
{13327 , "CC"},				-- Reckless Charge (Goblin Rocket Helmet)
{13181 , "CC"},				-- Gnomish Mind Control Cap (Gnomish Mind Control Cap helmet)
{26740 , "CC"},				-- Gnomish Mind Control Cap (Gnomish Mind Control Cap helmet)
{8345 , "CC"},				-- Control Machine (Gnomish Universal Remote trinket)
{13235 , "CC"},				-- Forcefield Collapse (Gnomish Harm Prevention belt)
{13158 , "CC"},				-- Rocket Boots Malfunction (Engineering Rocket Boots)
{8893 , "CC"},				-- Rocket Boots Malfunction (Engineering Rocket Boots)
{13466 , "CC"},				-- Goblin Dragon Gun (engineering trinket malfunction)
{8224 , "CC"},				-- Cowardice (Savory Deviate Delight effect)
{8225 , "CC"},				-- Run Away! (Savory Deviate Delight effect)
{23131 , "ImmuneSpell"},		-- Frost Reflector (Gyrofreeze Ice Reflector trinket) (only reflect frost spells)
{23097 , "ImmuneSpell"},		-- Fire Reflector (Hyper-Radiant Flame Reflector trinket) (only reflect fire spells)
{23132 , "ImmuneSpell"},		-- Shadow Reflector (Ultra-Flash Shadow Reflector trinket) (only reflect shadow spells)
{30003 , "ImmuneSpell"},		-- Sheen of Zanza
{23444 , "CC"},				-- Transporter Malfunction
{23447 , "CC"},				-- Transporter Malfunction
{23456 , "CC"},				-- Transporter Malfunction
{23457 , "CC"},				-- Transporter Malfunction
{8510 , "CC"},				-- Large Seaforium Backfire
{8511 , "CC"},				-- Small Seaforium Backfire
{7144 , "ImmunePhysical"},	-- Stone Slumber
{12843 , "Immune"},			-- Mordresh's Shield
{27619 , "Immune"},			-- Ice Block
{21892 , "Immune"},			-- Arcane Protection
{13237 , "CC"},				-- Goblin Mortar
{13238 , "CC"},				-- Goblin Mortar
{5134 , "CC"},				-- Flash Bomb
{4064 , "CC"},				-- Rough Copper Bomb
{4065 , "CC"},				-- Large Copper Bomb
{4066 , "CC"},				-- Small Bronze Bomb
{4067 , "CC"},				-- Big Bronze Bomb
{4068 , "CC"},				-- Iron Grenade
{4069 , "CC"},				-- Big Iron Bomb
{12543 , "CC"},				-- Hi-Explosive Bomb
{12562 , "CC"},				-- The Big One
{12421 , "CC"},				-- Mithril Frag Bomb
{19784 , "CC"},				-- Dark Iron Bomb
{19769 , "CC"},				-- Thorium Grenade
{13808 , "CC"},				-- M73 Frag Grenade
{21188 , "CC"},				-- Stun Bomb Attack
{9159 , "CC"},				-- Sleep (Green Whelp Armor chest)
{19821 , "Silence"},			-- Arcane Bomb
--{9774 , "Other"},				-- Immune Root (spider belt)
{18278 , "Silence"},			-- Silence (Silent Fang sword)
{8346 , "Root"},				-- Mobility Malfunction (trinket)
{13099 , "Root"},				-- Net-o-Matic (trinket)
{13119 , "Root"},				-- Net-o-Matic (trinket)
{13138 , "Root"},				-- Net-o-Matic (trinket)
{16566 , "Root"},				-- Net-o-Matic (trinket)
{15752 , "Disarm"},			-- Linken's Boomerang (trinket)
{15753 , "CC"},				-- Linken's Boomerang (trinket)
{15535 , "CC"},				-- Enveloping Winds (Six Demon Bag trinket)
{23103 , "CC"},				-- Enveloping Winds (Six Demon Bag trinket)
{15534 , "CC"},				-- Polymorph (Six Demon Bag trinket)
{16470 , "CC"},				-- Gift of Stone
{700 , "CC"},				-- Sleep (Slumber Sand item)
{1090 , "CC"},				-- Sleep
{12098 , "CC"},				-- Sleep
{20663 , "CC"},				-- Sleep
{20669 , "CC"},				-- Sleep
{8064 , "CC"},				-- Sleepy
{17446 , "CC"},				-- The Black Sleep
{29124 , "CC"},				-- Polymorph
{14621 , "CC"},				-- Polymorph
{27760 , "CC"},				-- Polymorph
{28406 , "CC"},				-- Polymorph Backfire
{851 , "CC"},				-- Polymorph: Sheep
{16707 , "CC"},				-- Hex
{16708 , "CC"},				-- Hex
{16709 , "CC"},				-- Hex
{18503 , "CC"},				-- Hex
{20683 , "CC"},				-- Highlord's Justice
{17286 , "CC"},				-- Crusader's Hammer
{17820 , "Other"},				-- Veil of Shadow
{12096 , "CC"},				-- Fear
{27641 , "CC"},				-- Fear
{29168 , "CC"},				-- Fear
{30002 , "CC"},				-- Fear
{15398 , "CC"},				-- Psychic Scream
{26042 , "CC"},				-- Psychic Scream
{27610 , "CC"},				-- Psychic Scream
{10794 , "CC"},				-- Spirit Shock
{9915 , "Root"},				-- Frost Nova
{14907 , "Root"},				-- Frost Nova
{15091 , "Snare"},				-- Blast Wave
{17277 , "Snare"},				-- Blast Wave
{23039 , "Snare"},				-- Blast Wave
{23115 , "Snare"},				-- Frost Shock
{19133 , "Snare"},				-- Frost Shock
{21030 , "Snare"},				-- Frost Shock
{11538 , "Snare"},				-- Frostbolt
{21369 , "Snare"},				-- Frostbolt
{20297 , "Snare"},				-- Frostbolt
{20806 , "Snare"},				-- Frostbolt
{20819 , "Snare"},				-- Frostbolt
{20792 , "Snare"},				-- Frostbolt
{23412 , "Snare"},				-- Frostbolt
{24942 , "Snare"},				-- Frostbolt
{23102 , "Snare"},				-- Frostbolt
{20717 , "Snare"},				-- Sand Breath
{16568 , "Snare"},				-- Mind Flay
{16094 , "Snare"},				-- Frost Breath
{16340 , "Snare"},				-- Frost Breath
{17174 , "Snare"},				-- Concussive Shot
{27634 , "Snare"},				-- Concussive Shot
{20654 , "Root"},				-- Entangling Roots
{22800 , "Root"},				-- Entangling Roots
{20699 , "Root"},				-- Entangling Roots
{18546 , "Root"},				-- Overdrive
{22935 , "Root"},				-- Planted
{12520 , "Root"},				-- Teleport from Azshara Tower
{12521 , "Root"},				-- Teleport from Azshara Tower
{12509 , "Root"},				-- Teleport from Azshara Tower
{12023 , "Root"},				-- Web
{13608 , "Root"},				-- Hooked Net
{10017 , "Root"},				-- Frost Hold
{23279 , "Root"},				-- Crippling Clip
{3542 , "Root"},				-- Naraxis Web
{5567 , "Root"},				-- Miring Mud
{5424 , "Root"},				-- Claw Grasp
{5219 , "Root"},				-- Draw of Thistlenettle
{9576 , "Root"},				-- Lock Down
{7950 , "Root"},				-- Pause
{7761 , "Root"},				-- Shared Bondage
{6714 , "Root"},				-- Test of Faith
{6716 , "Root"},				-- Test of Faith
{4932 , "ImmuneSpell"},		-- Ward of Myzrael
{7383 , "ImmunePhysical"},	-- Water Bubble
{25 , "CC"},				-- Stun
{101 , "CC"},				-- Trip
{2880 , "CC"},				-- Stun
{5648 , "CC"},				-- Stunning Blast
{5649 , "CC"},				-- Stunning Blast
{5726 , "CC"},				-- Stunning Blow
{5727 , "CC"},				-- Stunning Blow
{5703 , "CC"},				-- Stunning Strike
{5918 , "CC"},				-- Shadowstalker Stab
{3446 , "CC"},				-- Ravage
{3109 , "CC"},				-- Presence of Death
{3143 , "CC"},				-- Glacial Roar
{5403 , "Root"},				-- Crash of Waves
{3260 , "CC"},				-- Violent Shield Effect
{3263 , "CC"},				-- Touch of Ravenclaw
{3271 , "CC"},				-- Fatigued
{5106 , "CC"},				-- Crystal Flash
{6266 , "CC"},				-- Kodo Stomp
{6730 , "CC"},				-- Head Butt
{6982 , "CC"},				-- Gust of Wind
{6749 , "CC"},				-- Wide Swipe
{6754 , "CC"},				-- Slap!
{6927 , "CC"},				-- Shadowstalker Slash
{7961 , "CC"},				-- Azrethoc's Stomp
{8151 , "CC"},				-- Surprise Attack
{3635 , "CC"},				-- Crystal Gaze
{9992 , "CC"},				-- Dizzy
{6614 , "CC"},				-- Cowardly Flight
{5543 , "CC"},				-- Fade Out
{6664 , "CC"},				-- Survival Instinct
{6669 , "CC"},				-- Survival Instinct
{5951 , "CC"},				-- Knockdown
{4538 , "CC"},				-- Extract Essence
{6580 , "CC"},				-- Pierce Ankle
{6894 , "CC"},				-- Death Bed
{7184 , "CC"},				-- Lost Control
{8901 , "CC"},				-- Gas Bomb
{8902 , "CC"},				-- Gas Bomb
{9454 , "CC"},				-- Freeze
{7082 , "CC"},				-- Barrel Explode
{6537 , "CC"},				-- Call of the Forest
{8672 , "CC"},				-- Challenger is Dazed
{6409 , "CC"},				-- Cheap Shot
{14902 , "CC"},				-- Cheap Shot
{8338 , "CC"},				-- Defibrillated!
{23055 , "CC"},				-- Defibrillated!
{8646 , "CC"},				-- Snap Kick
{27620 , "Silence"},			-- Snap Kick
{27814 , "Silence"},			-- Kick
{11650 , "CC"},				-- Head Butt
{21990 , "CC"},				-- Tornado
{19725 , "CC"},				-- Turn Undead
{19469 , "CC"},				-- Poison Mind
{10134 , "CC"},				-- Sand Storm
{12613 , "CC"},				-- Dark Iron Taskmaster Death
{13488 , "CC"},				-- Firegut Fear Storm
{17738 , "CC"},				-- Curse of the Plague Rat
{20019 , "CC"},				-- Engulfing Flames
{19136 , "CC"},				-- Stormbolt
{20685 , "CC"},				-- Storm Bolt
{16803 , "CC"},				-- Flash Freeze
{14100 , "CC"},				-- Terrifying Roar
{17276 , "CC"},				-- Scald
{13360 , "CC"},				-- Knockdown
{11430 , "CC"},				-- Slam
{16451 , "CC"},				-- Judge's Gavel
{25260 , "CC"},				-- Wings of Despair
{23275 , "CC"},				-- Dreadful Fright
{24919 , "CC"},				-- Nauseous
{21167 , "CC"},				-- Snowball
{26641 , "CC"},				-- Aura of Fear
{28315 , "CC"},				-- Aura of Fear
{21898 , "CC"},				-- Warlock Terror
{20672 , "CC"},				-- Fade
{31365 , "CC"},				-- Self Fear
{25815 , "CC"},				-- Frightening Shriek
{12134 , "CC"},				-- Atal'ai Corpse Eat
{16096 , "CC"},				-- Cowering Roar
{27177 , "CC"},				-- Defile
{18395 , "CC"},				-- Dismounting Shot
{28323 , "CC"},				-- Flameshocker's Revenge
{28314 , "CC"},				-- Flameshocker's Touch
{28127 , "CC"},				-- Flash
{17011 , "CC"},				-- Freezing Claw
{14102 , "CC"},				-- Head Smash
{15652 , "CC"},				-- Head Smash
{23269 , "CC"},				-- Holy Blast
{22357 , "CC"},				-- Icebolt
{10451 , "CC"},				-- Implosion
{15252 , "CC"},				-- Keg Trap
{27615 , "CC"},				-- Kidney Shot
{24213 , "CC"},				-- Ravage
{21936 , "CC"},				-- Reindeer
{11444 , "CC"},				-- Shackle Undead
{14871 , "CC"},				-- Shadow Bolt Misfire
{25056 , "CC"},				-- Stomp
{24647 , "CC"},				-- Stun
{17691 , "CC"},				-- Time Out
{11481 , "CC"},				-- TWEEP
{20310 , "CC"},				-- Stun
{23775 , "CC"},				-- Stun Forever
{23676 , "CC"},				-- Minigun (chance to hit reduced by 50%)
{11983 , "CC"},				-- Steam Jet (chance to hit reduced by 30%)
{9612 , "CC"},				-- Ink Spray (chance to hit reduced by 50%)
{4150 , "CC"},				-- Eye Peck (chance to hit reduced by 47%)
{6530 , "CC"},				-- Sling Dirt (chance to hit reduced by 40%)
{5101 , "CC"},				-- Dazed
{4320 , "Silence"},			-- Trelane's Freezing Touch
{4243 , "Silence"},			-- Pester Effect
{6942 , "Silence"},			-- Overwhelming Stench
{9552 , "Silence"},			-- Searing Flames
{10576 , "Silence"},			-- Piercing Howl
{12943 , "Silence"},			-- Fell Curse Effect
{23417 , "Silence"},			-- Smother
{10851 , "Disarm"},			-- Grab Weapon
{25057 , "Disarm"},			-- Dropped Weapon
{25655 , "Disarm"},			-- Dropped Weapon
{14180 , "Disarm"},			-- Sticky Tar
{5376 , "Disarm"},			-- Hand Snap
{6576 , "CC"},				-- Intimidating Growl
{7093 , "CC"},				-- Intimidation
{8715 , "CC"},				-- Terrifying Howl
{8817 , "CC"},				-- Smoke Bomb
{9458 , "CC"},				-- Smoke Cloud
{3442 , "CC"},				-- Enslave
{3389 , "ImmuneSpell"},		-- Ward of the Eye
{3651 , "ImmuneSpell"},		-- Shield of Reflection
{20223 , "ImmuneSpell"},		-- Magic Reflection
{27546 , "ImmuneSpell"},		-- Faerie Dragon Form (not immune, 50% magical damage reduction)
{17177 , "ImmunePhysical"},	-- Seal of Protection
{25772 , "CC"},				-- Mental Domination
{16053 , "CC"},				-- Dominion of Soul (Orb of Draconic Energy)
{15859 , "CC"},				-- Dominate Mind
{20740 , "CC"},				-- Dominate Mind
{11446 , "CC"},				-- Mind Control
{20668 , "CC"},				-- Sleepwalk
{21330 , "CC"},				-- Corrupted Fear (Deathmist Raiment set)
{27868 , "Root"},				-- Freeze (Magister's and Sorcerer's Regalia sets)
{17333 , "Root"},				-- Spider's Kiss (Spider's Kiss set)
{26108 , "CC"},				-- Glimpse of Madness (Dark Edge of Insanity axe)
{1604 , "Snare"},				-- Dazed
{9462 , "Snare"},				-- Mirefin Fungus
{19137 , "Snare"},				-- Slow
{24753 , "CC"},				-- Trick
{21847 , "CC"},				-- Snowman
{21848 , "CC"},				-- Snowman
{21980 , "CC"},				-- Snowman
{27880 , "CC"},				-- Stun
{23010 , "CC"},				-- Tendrils of Air
{6724 , "Immune"},			-- Light of Elune
{13007 , "Immune"},			-- Divine Protection
{24360 , "CC"},				-- Greater Dreamless Sleep Potion
{15822 , "CC"},				-- Dreamless Sleep Potion
{15283 , "CC"},				-- Stunning Blow (Dark Iron Pulverizer weapon)
{21152 , "CC"},				-- Earthshaker (Earthshaker weapon)
{16600 , "CC"},				-- Might of Shahram (Blackblade of Shahram sword)
{16597 , "Snare"},				-- Curse of Shahram (Blackblade of Shahram sword)
{13496 , "Snare"},				-- Dazed (Mug O' Hurt mace)
{3238 , "Other"},				-- Nimble Reflexes
{5990 , "Other"},				-- Nimble Reflexes
{6615 , "Other"},				-- Free Action Potion
{11359 , "Other"},				-- Restorative Potion
{24364 , "Other"},				-- Living Free Action Potion
{23505 , "Other"},				-- Berserking
{24378 , "Other"},				-- Berserking
{19135 , "Other"},				-- Avatar
{12738 , "Other"},				-- Amplify Damage
{26198 , "CC"},				-- Whisperings of C'Thun
{26195 , "CC"},				-- Whisperings of C'Thun
{26197 , "CC"},				-- Whisperings of C'Thun
{26258 , "CC"},				-- Whisperings of C'Thun
{26259 , "CC"},				-- Whisperings of C'Thun
{17624 , "Immune"},			-- Flask of Petrification (not immune, absorbs damage up to 6000, cannot attack, move or use spells)
{13534 , "Disarm"},			-- Disarm (The Shatterer weapon)
{11879 , "Disarm"},			-- Disarm (Shoni's Disarming Tool weapon)
{13439 , "Snare"},				-- Frostbolt (some weapons)
{16621 , "ImmunePhysical"},	-- Self Invulnerability (Invulnerable Mail)
{27559 , "Silence"},			-- Silence (Jagged Obsidian Shield)
{13907 , "CC"},				-- Smite Demon (Enchant Weapon - Demonslaying)
{18798 , "CC"},				-- Freeze (Freezing Band)
{17500 , "CC"},				-- Malown's Slam (Malown's Slam weapon)
{34510 , "CC"},				-- Stun (Stormherald and Deep Thunder weapons)
{46567 , "CC"},				-- Rocket Launch (Goblin Rocket Launcher trinket)
{30501 , "Silence"},			-- Poultryized! (Gnomish Poultryizer trinket)
{30504 , "Silence"},			-- Poultryized! (Gnomish Poultryizer trinket)
{30506 , "Silence"},			-- Poultryized! (Gnomish Poultryizer trinket)
{35474 , "CC"},				-- Drums of Panic (Drums of Panic item)
{351357 , "CC"},				-- Greater Drums of Panic (Greater Drums of Panic item)
{28504 , "CC"},				-- Major Dreamless Sleep (Major Dreamless Sleep Potion)
{30216 , "CC"},				-- Fel Iron Bomb
{30217 , "CC"},				-- Adamantite Grenade
{30461 , "CC"},				-- The Bigger One
{31367 , "Root"},				-- Netherweave Net (tailoring item)
{31368 , "Root"},				-- Heavy Netherweave Net (tailoring item)
{39965 , "Root"},				-- Frost Grenade
{36940 , "CC"},				-- Transporter Malfunction
{51581 , "CC"},				-- Rocket Boots Malfunction
{12565 , "CC"},				-- Wyatt Test
{35182 , "CC"},				-- Banish
{40307 , "CC"},				-- Stasis Field
{40282 , "Immune"},			-- Possess Spirit Immune
{45838 , "Immune"},			-- Possess Drake Immune
{35236 , "CC"},				-- Heat Wave (chance to hit reduced by 35%)
{29117 , "CC"},				-- Feather Burst (chance to hit reduced by 50%)
{34088 , "CC"},				-- Feeble Weapons (chance to hit reduced by 75%)
{45078 , "Other"},				-- Berserk (damage increased by 500%)
{32378 , "Other"},				-- Filet (healing effects reduced by 50%)
{32736 , "Other"},				-- Mortal Strike (healing effects reduced by 50%)
{39595 , "Other"},				-- Mortal Cleave (healing effects reduced by 50%)
{40220 , "Other"},				-- Mortal Strike (healing effects reduced by 50%)
{44268 , "Other"},				-- Mortal Strike (healing effects reduced by 50%)
{34625 , "Other"},				-- Demolish (healing effects reduced by 75%)
{38031 , "Other"},				-- Shield Block (chance to block increased by 75%)
{31905 , "Other"},				-- Shield Stance (chance to block increased by 100%)
{37683 , "Other"},				-- Evasion (chance to dodge increased by 50%)
{38541 , "Other"},				-- Evasion (chance to dodge increased by 50%)
{36513 , "ImmunePhysical"},	-- Intangible Presence (not immune, physical damage taken reduced by 40%)
{45954 , "Immune"},			-- Ahune's Shield (not immune, damage taken reduced by 75%)
{46416 , "Immune"},			-- Ahune Self Stun
{50279 , "Immune"},			-- Copy of Elemental Shield (not immune, damage taken reduced by 75%)
{29476 , "Immune"},			-- Astral Armor (not immune, damage taken reduced by 90%)
{30858 , "Immune"},			-- Demon Blood Shell
{42206 , "Immune"},			-- Protection
{33581 , "Immune"},			-- Divine Shield
{40733 , "Immune"},			-- Divine Shield
{30972 , "Immune"},			-- Evocation
{31797 , "Immune"},			-- Banish Self
{34973 , "Immune"},			-- Ravandwyr's Ice Block
{36527 , "Immune"},			-- Stasis
{36816 , "Immune"},			-- Water Shield
{36860 , "Immune"},			-- Cannon Charging (self)
{36911 , "Immune"},			-- Ice Block
{37546 , "Immune"},			-- Banish
{37905 , "Immune"},			-- Metamorphosis
{37205 , "Immune"},			-- Channel Air Shield
{38099 , "Immune"},			-- Channel Air Shield
{38100 , "Immune"},			-- Channel Air Shield
{37204 , "Immune"},			-- Channel Earth Shield
{38101 , "Immune"},			-- Channel Earth Shield
{38102 , "Immune"},			-- Channel Earth Shield
{37206 , "Immune"},			-- Channel Fire Shield
{38103 , "Immune"},			-- Channel Fire Shield
{38104 , "Immune"},			-- Channel Fire Shield
{36817 , "Immune"},			-- Channel Water Shield
{38105 , "Immune"},			-- Channel Water Shield
{38106 , "Immune"},			-- Channel Water Shield
{38456 , "Immune"},			-- Banish Self
{38916 , "Immune"},			-- Diplomatic Immunity
{40357 , "Immune"},			-- Legion Ring - Character Invis and Immune
{41130 , "Immune"},			-- Toranaku - Character Invis and Immune
{40671 , "Immune"},			-- Health Funnel
{41590 , "Immune"},			-- Ice Block
{42354 , "Immune"},			-- Banish Self
{46604 , "Immune"},			-- Ice Block
{11412 , "ImmunePhysical"},	-- Nether Shell
{34518 , "ImmunePhysical"},	-- Nether Protection (Embrace of the Twisting Nether & Twisting Nether Chain Shirt items)
{38026 , "ImmunePhysical"},	-- Viscous Shield
{36576 , "ImmuneSpell"},		-- Shaleskin (not immune, magic damage taken reduced by 50%)
{39804 , "ImmuneSpell"},		-- Damage Immunity: Magic
{39811 , "ImmuneSpell"},		-- Damage Immunity: Fire, Frost, Shadow, Nature, Arcane
{37538 , "ImmuneSpell"},		-- Anti-Magic Shield
{32904 , "CC"},				-- Pacifying Dust
{38177 , "CC"},				-- Blackwhelp Net
{39810 , "CC"},				-- Sparrowhawk Net
{41621 , "CC"},				-- Wolpertinger Net
{43906 , "CC"},				-- Feeling Froggy
{32913 , "CC"},				-- Dazzling Dust
{33810 , "CC"},				-- Rock Shell
{37450 , "CC"},				-- Dimensius Feeding
{38318 , "CC"},				-- Transformation - Blackwhelp
{35892 , "Silence"},			-- Suppression
{34087 , "Silence"},			-- Chilling Words
{35334 , "Silence"},			-- Nether Shock
{38913 , "Silence"},			-- Silence
{38915 , "CC"},				-- Mental Interference
{41128 , "CC"},				-- Through the Eyes of Toranaku
{22901 , "CC"},				-- Body Switch
{31988 , "CC"},				-- Enslave Humanoid
{37323 , "CC"},				-- Crystal Control
{37221 , "CC"},				-- Crystal Control
{38774 , "CC"},				-- Incite Rage
{33384 , "CC"},				-- Mass Charm
{36145 , "CC"},				-- Chains of Naberius
{42185 , "CC"},				-- Brewfest Control Piece
{44881 , "CC"},				-- Charm Ravager
{37216 , "CC"},				-- Crystal Control
{29909 , "CC"},				-- Elven Manacles
{31533 , "ImmuneSpell"},		-- Spell Reflection (50% chance to reflect a spell)
{33719 , "ImmuneSpell"},		-- Perfect Spell Reflection
{34783 , "ImmuneSpell"},		-- Spell Reflection
{37885 , "ImmuneSpell"},		-- Spell Reflection
{38331 , "ImmuneSpell"},		-- Spell Reflection
{28516 , "Silence"},			-- Sunwell Torrent (Sunwell Blade & Sunwell Orb items)
{33913 , "Silence"},			-- Soul Burn
{37031 , "Silence"},			-- Chaotic Temperament
{39052 , "Silence"},			-- Sonic Burst
{41247 , "Silence"},			-- Shared Suffering
{44957 , "Silence"},			-- Nether Shock
{31955 , "Disarm"},			-- Disarm
{34097 , "Disarm"},			-- Riposte
{34099 , "Disarm"},			-- Riposte
{36208 , "Disarm"},			-- Steal Weapon
{36510 , "Disarm"},			-- Enchanted Weapons
{39489 , "Disarm"},			-- Enchanted Weapons
{41053 , "Disarm"},			-- Whirling Blade
{47310 , "Disarm"},			-- Direbrew's Disarm
{30298 , "CC"},				-- Tree Disguise
{49750 , "CC"},				-- Honey Touched
{42380 , "CC"},				-- Conflagration
{42408 , "CC"},				-- Headless Horseman Climax - Head Stun
{42695 , "CC"},				-- Holiday - Brewfest - Dark Iron Knock-down Power-up
{42435 , "CC"},				-- Brewfest - Stun
{47718 , "CC"},				-- Direbrew Charge
{47442 , "CC"},				-- Barreled!
{51413 , "CC"},				-- Barreled!
{47340 , "CC"},				-- Dark Brewmaiden's Stun
{50093 , "CC"},				-- Chilled
{29044 , "CC"},				-- Hex
{30838 , "CC"},				-- Polymorph
{35840 , "CC"},				-- Conflagration
{39293 , "CC"},				-- Conflagration
{40400 , "CC"},				-- Hex
{42805 , "CC"},				-- Dirty Trick
{45665 , "CC"},				-- Encapsulate
{26661 , "CC"},				-- Fear
{31358 , "CC"},				-- Fear
{31404 , "CC"},				-- Shrill Cry
{32040 , "CC"},				-- Scare Daggerfen
{32241 , "CC"},				-- Fear
{32709 , "CC"},				-- Death Coil
{33829 , "CC"},				-- Fleeing in Terror
{33924 , "CC"},				-- Fear
{34259 , "CC"},				-- Fear
{35198 , "CC"},				-- Terrify
{35954 , "CC"},				-- Death Coil
{36629 , "CC"},				-- Terrifying Roar
{36950 , "CC"},				-- Blinding Light
{37939 , "CC"},				-- Terrifying Roar
{38065 , "CC"},				-- Death Coil
{38154 , "CC"},				-- Fear
{39048 , "CC"},				-- Howl of Terror
{39119 , "CC"},				-- Fear
{39176 , "CC"},				-- Fear
{39210 , "CC"},				-- Fear
{39661 , "CC"},				-- Death Coil
{39914 , "CC"},				-- Scare Soulgrinder Ghost
{40221 , "CC"},				-- Terrifying Roar
{40259 , "CC"},				-- Boar Charge
{40636 , "CC"},				-- Bellowing Roar
{40669 , "CC"},				-- Egbert
{41436 , "CC"},				-- Panic
{42690 , "CC"},				-- Terrifying Roar
{42869 , "CC"},				-- Conflagration
{44142 , "CC"},				-- Death Coil
{50368 , "CC"},				-- Ethereal Liqueur Mutation
{27983 , "CC"},				-- Lightning Strike
{29516 , "CC"},				-- Dance Trance
{29903 , "CC"},				-- Dive
{30657 , "CC"},				-- Quake
{30688 , "CC"},				-- Shield Slam
{30790 , "CC"},				-- Arcane Domination
{30832 , "CC"},				-- Kidney Shot
{30850 , "CC"},				-- Seduction
{30857 , "CC"},				-- Wield Axes
{31274 , "CC"},				-- Knockdown
{31292 , "CC"},				-- Sleep
{31390 , "CC"},				-- Knockdown
{31539 , "CC"},				-- Self Stun Forever
{31541 , "CC"},				-- Sleep
{31548 , "CC"},				-- Sleep
{31733 , "CC"},				-- Charge
{31819 , "CC"},				-- Cheap Shot
{31843 , "CC"},				-- Cheap Shot
{31864 , "CC"},				-- Shield Charge Stun
{31964 , "CC"},				-- Thundershock
{31994 , "CC"},				-- Shoulder Charge
{32015 , "CC"},				-- Knockdown
{32021 , "CC"},				-- Rushing Charge
{32023 , "CC"},				-- Hoof Stomp
{32104 , "CC"},				-- Backhand
{32105 , "CC"},				-- Kick
{32150 , "CC"},				-- Infernal
{32416 , "CC"},				-- Hammer of Justice
{32779 , "CC"},				-- Repentance
{32905 , "CC"},				-- Glare
{33128 , "CC"},				-- Stone Gaze
{33241 , "CC"},				-- Infernal
{33422 , "CC"},				-- Phase In
{33463 , "CC"},				-- Icebolt
{33487 , "CC"},				-- Addle Humanoid
{33542 , "CC"},				-- Staff Strike
{33637 , "CC"},				-- Infernal
{33781 , "CC"},				-- Ravage
{33792 , "CC"},				-- Exploding Shot
{33965 , "CC"},				-- Look Around
{33937 , "CC"},				-- Stun Phase 2 Units
{34016 , "CC"},				-- Stun Phase 3 Units
{34023 , "CC"},				-- Stun Phase 4 Units
{34024 , "CC"},				-- Stun Phase 5 Units
{34108 , "CC"},				-- Spine Break
{34243 , "CC"},				-- Cheap Shot
{34357 , "CC"},				-- Vial of Petrification
{34620 , "CC"},				-- Slam
{34815 , "CC"},				-- Teleport Effect
{34885 , "CC"},				-- Petrify
{35202 , "CC"},				-- Paralysis
{35313 , "CC"},				-- Hypnotic Gaze
{35382 , "CC"},				-- Rushing Charge
{35424 , "CC"},				-- Soul Shadows
{35492 , "CC"},				-- Exhaustion
{35614 , "CC"},				-- Kaylan's Wrath
{35856 , "CC"},				-- Stun
{35957 , "CC"},				-- Mana Bomb Explosion
{36073 , "CC"},				-- Spellbreaker (damage from Magical spells and effects reduced by 75%)
{36138 , "CC"},				-- Hammer Stun
{36254 , "CC"},				-- Judgement of the Flame
{36402 , "CC"},				-- Sleep
{36449 , "CC"},				-- Debris
{36474 , "CC"},				-- Flayer Flu
{36509 , "CC"},				-- Charge
{36575 , "CC"},				-- T'chali the Head Freeze State
{36642 , "CC"},				-- Banished from Shattrath City
{36671 , "CC"},				-- Banished from Shattrath City
{36732 , "CC"},				-- Scatter Shot
{36809 , "CC"},				-- Overpowering Sickness
{36824 , "CC"},				-- Overwhelming Odor
{36877 , "CC"},				-- Stun Forever
{37012 , "CC"},				-- Swoop
{37073 , "CC"},				-- Drink Eye Potion
{37103 , "CC"},				-- Smash
{37417 , "CC"},				-- Warp Charge
{37493 , "CC"},				-- Feign Death
{37592 , "CC"},				-- Knockdown
{37768 , "CC"},				-- Metamorphosis
{37833 , "CC"},				-- Banish
{37919 , "CC"},				-- Arcano-dismantle
{38006 , "CC"},				-- World Breaker
{38009 , "CC"},				-- Banish
{38021 , "CC"},				-- Terrifying Screech (damage dealt reduced by 50%)
{38169 , "CC"},				-- Subservience
{38240 , "CC"},				-- Chilling Touch (damage with magical spells and effects reduced by 75%)
{38357 , "CC"},				-- Tidal Surge
{38510 , "CC"},				-- Sablemane's Sleeping Powder
{38554 , "CC"},				-- Absorb Eye of Grillok
{38757 , "CC"},				-- Fel Reaver Freeze
{38863 , "CC"},				-- Gouge
{39229 , "CC"},				-- Talon of Justice
{39568 , "CC"},				-- Stun
{39594 , "CC"},				-- Cyclone
{39622 , "CC"},				-- Banish
{39668 , "CC"},				-- Ambush
{40135 , "CC"},				-- Shackle Undead
{40262 , "CC"},				-- Super Jump
{40358 , "CC"},				-- Death Hammer
{40370 , "CC"},				-- Banish
{40380 , "CC"},				-- Legion Ring - Shield Defense Beam
{40511 , "CC"},				-- Demon Transform 1
{40398 , "CC"},				-- Demon Transform 2
{40510 , "CC"},				-- Demon Transform 3
{40409 , "CC"},				-- Maiev Down
{40447 , "CC"},				-- Akama Soul Channel
{40490 , "CC"},				-- Resonant Feedback
{40497 , "CC"},				-- Chaos Charge
{40503 , "CC"},				-- Possession Transfer
{40563 , "CC"},				-- Throw Axe
{40578 , "CC"},				-- Cyclone
{40774 , "CC"},				-- Stun Pulse
{40835 , "CC"},				-- Stasis Field
{40846 , "CC"},				-- Crystal Prison
{40858 , "CC"},				-- Ethereal Ring, Cannon Visual
{40951 , "CC"},				-- Stasis Field
{41182 , "CC"},				-- Concussive Throw
{41358 , "CC"},				-- Rizzle's Blackjack
{41421 , "CC"},				-- Brief Stun
{41528 , "CC"},				-- Mark of Stormrage
{41534 , "CC"},				-- War Stomp
{41592 , "CC"},				-- Spirit Channelling
{41962 , "CC"},				-- Possession Transfer
{42386 , "CC"},				-- Sleeping Sleep
{42621 , "CC"},				-- Fire Bomb
{42648 , "CC"},				-- Sleeping Sleep
{43528 , "CC"},				-- Cyclone
{44031 , "CC"},				-- Tackled!
{44138 , "CC"},				-- Rocket Launch
{44415 , "CC"},				-- Blackout
{44432 , "CC"},				-- Cube Ground State
{44836 , "CC"},				-- Banish
{44994 , "CC"},				-- Self Repair
{45574 , "CC"},				-- Water Tomb
{45676 , "CC"},				-- Juggle Torch (Quest, Missed)
{45889 , "CC"},				-- Scorchling Blast
{45947 , "CC"},				-- Slip
{46188 , "CC"},				-- Rocket Launch
{46590 , "CC"},				-- Ninja Grenade {PH]
{48342 , "CC"},				-- Stun Self
{50876 , "CC"},				-- Mounted Charge
{47407 , "Root"},				-- Direbrew's Disarm (precast)
{47411 , "Root"},				-- Direbrew's Disarm (spin)
{43207 , "Root"},				-- Headless Horseman Climax - Head's Breath
{43049 , "Root"},				-- Upset Tummy
{31287 , "Root"},				-- Entangling Roots
{31290 , "Root"},				-- Net
{31409 , "Root"},				-- Wild Roots
{33356 , "Root"},				-- Self Root Forever
{33844 , "Root"},				-- Entangling Roots
{34080 , "Root"},				-- Riposte Stance
{34569 , "Root"},				-- Chilled Earth
{35234 , "Root"},				-- Strangling Roots
{35247 , "Root"},				-- Choking Wound
{35327 , "Root"},				-- Jackhammer
{39194 , "Root"},				-- Jackhammer
{36252 , "Root"},				-- Felforge Flames
{36734 , "Root"},				-- Test Whelp Net
{37823 , "Root"},				-- Entangling Roots
{38033 , "Root"},				-- Frost Nova
{38035 , "Root"},				-- Freeze
{38051 , "Root"},				-- Fel Shackles
{38338 , "Root"},				-- Net
{38505 , "Root"},				-- Shackle
{39268 , "Root"},				-- Chains of Ice
{40363 , "Root"},				-- Entangling Roots
{40525 , "Root"},				-- Rizzle's Frost Grenade
{40590 , "Root"},				-- Rizzle's Frost Grenade (Self
{40727 , "Root"},				-- Icy Leap
{41981 , "Root"},				-- Dust Field
{42716 , "Root"},				-- Self Root Forever (No Visual)
{43130 , "Root"},				-- Creeping Vines
{43585 , "Root"},				-- Entangle
{45255 , "Root"},				-- Rocket Chicken
{45905 , "Root"},				-- Frost Nova
{29158 , "Snare"},				-- Inhale
{29957 , "Snare"},				-- Frostbolt Volley
{30600 , "Snare"},				-- Blast Wave
{30942 , "Snare"},				-- Frostbolt
{31296 , "Snare"},				-- Frostbolt
{32334 , "Snare"},				-- Cyclone
{32417 , "Snare"},				-- Mind Flay
{32774 , "Snare"},				-- Avenger's Shield
{32984 , "Snare"},				-- Frostbolt
{33047 , "Snare"},				-- Void Bolt
{34214 , "Snare"},				-- Frost Touch
{34347 , "Snare"},				-- Frostbolt
{35252 , "Snare"},				-- Unstable Cloud
{35263 , "Snare"},				-- Frost Attack
{35316 , "Snare"},				-- Frostbolt
{35351 , "Snare"},				-- Sand Breath
{35955 , "Snare"},				-- Dazed
{36148 , "Snare"},				-- Chill Nova
{36278 , "Snare"},				-- Blast Wave
{36464 , "Snare"},				-- The Den Mother's Mark
{36518 , "Snare"},				-- Shadowsurge
{36839 , "Snare"},				-- Impairing Poison
{36843 , "Snare"},				-- Slow
{37330 , "Snare"},				-- Mind Flay
{37359 , "Snare"},				-- Rush
{37554 , "Snare"},				-- Avenger's Shield
{37591 , "Snare"},				-- Drunken Haze
{37786 , "Snare"},				-- Bloodmaul Rage
{37830 , "Snare"},				-- Repolarized Magneto Sphere
{38032 , "Snare"},				-- Stormbolt
{38256 , "Snare"},				-- Piercing Howl
{38534 , "Snare"},				-- Frostbolt
{38536 , "Snare"},				-- Blast Wave
{38663 , "Snare"},				-- Slow
{38767 , "Snare"},				-- Daze
{38771 , "Snare"},				-- Burning Rage
{38952 , "Snare"},				-- Frost Arrow
{39001 , "Snare"},				-- Blast Wave
{39038 , "Snare"},				-- Blast Wave
{40417 , "Snare"},				-- Rage
{40429 , "Snare"},				-- Frostbolt
{40430 , "Snare"},				-- Frostbolt
{40653 , "Snare"},				-- Whirlwind
{40976 , "Snare"},				-- Slimy Spittle
{41281 , "Snare"},				-- Cripple
{41439 , "Snare"},				-- Mangle
{41486 , "Snare"},				-- Frostbolt
{42396 , "Snare"},				-- Mind Flay
{42803 , "Snare"},				-- Frostbolt
{43945 , "Snare"},				-- You're a ...! (Effects1)
{43963 , "Snare"},				-- Retch!
{44289 , "Snare"},				-- Crippling Poison
{44937 , "Snare"},				-- Fel Siphon
{46984 , "Snare"},				-- Cone of Cold
{46987 , "Snare"},				-- Frostbolt
{47106 , "Snare"},				-- Soul Flay
{16922 , "CC"},				-- Starfire Stun
{28445 , "CC"},				-- Improved Concussive Shot (talent)
{1777 , "CC"},				-- Gouge
{8629 , "CC"},				-- Gouge
{11285 , "CC"},				-- Gouge
{11286 , "CC"},				-- Gouge
{38764 , "CC"},				-- Gouge
{20614 , "CC"},				-- Intercept
{25273 , "CC"},				-- Intercept
{25274 , "CC"},				-- Intercept
{12798 , "CC"},				-- Revenge Stun
{12705 , "Snare"},				-- Long Daze (Improved Pummel)
{7372 , "Snare"},				-- Hamstring
{7373 , "Snare"},				-- Hamstring
{25212 , "Snare"},				-- Hamstring
{48680 , "CC"},				-- Strangulate
{49913 , "Silence"},			-- Strangulate
{49914 , "Silence"},			-- Strangulate
{49915 , "Silence"},			-- Strangulate
{49916 , "Silence"},			-- Strangulate
{65860 , "Immune"},			-- Barkskin (not immune, damage taken decreased by 40%)
{50411 , "Snare"},				-- Dazed
{57546 , "CC"},				-- Greater Turn Evil
{53570 , "CC"},				-- Hungering Cold
{61058 , "CC"},				-- Hungering Cold
{67769 , "CC"},				-- Cobalt Frag Bomb
{67890 , "CC"},				-- Cobalt Frag Bomb (engineering belt enchant)
{54735 , "CC"},				-- Electromagnetic Pulse (engineering enchant)
{67810 , "CC"},				-- Mental Battle (engineering enchant)
{52207 , "CC"},				-- Devour Humanoid
{60074 , "CC"},				-- Time Stop
{60077 , "CC"},				-- Stop Time
{54132 , "CC"},				-- Concussion Blow
{61819 , "CC"},				-- Manabonked!
{61834 , "CC"},				-- Manabonked!
{65122 , "CC"},				-- Polymorph (TEST)
{48288 , "CC"},				-- Mace Smash
{49735 , "CC"},				-- Terrifying Countenance
{43348 , "CC"},				-- Head Crush
{58974 , "CC"},				-- Crushing Leap
{56747 , "CC"},				-- Stomp
{49675 , "CC"},				-- Stone Stomp
{51756 , "CC"},				-- Charge
{51752 , "CC"},				-- Stampy's Stompy-Stomp
{59705 , "CC"},				-- War Stomp
{60960 , "CC"},				-- War Stomp
{70199 , "CC"},				-- Blinding Retreat
{71750 , "CC"},				-- Blind!
{50283 , "CC"},				-- Blinding Swarm (chance to hit reduced by 75%)
{52856 , "CC"},				-- Charge
{54460 , "CC"},				-- Charge
{52577 , "CC"},				-- Charge
{55982 , "CC"},				-- Mammoth Charge
{46315 , "CC"},				-- Mammoth Charge
{52601 , "CC"},				-- Rushing Charge
{52169 , "CC"},				-- Magnataur Charge
{52061 , "CC"},				-- Lightning Fear
{68326 , "CC"},				-- Fear Self
{62628 , "CC"},				-- Fear Self
{59669 , "CC"},				-- Fear
{47534 , "CC"},				-- Cower in Fear
{54196 , "CC"},				-- Cower in Fear
{75343 , "CC"},				-- Shockwave
{55918 , "CC"},				-- Shockwave
{57741 , "CC"},				-- Shockwave
{48376 , "CC"},				-- Hammer Blow
{61662 , "CC"},				-- Cyclone
{69699 , "CC"},				-- Cyclone
{53103 , "CC"},				-- Charm Blightblood Troll
{52488 , "CC"},				-- Charm Bloated Abomination
{52390 , "CC"},				-- Charm Drakuru Servant
{52244 , "CC"},				-- Charm Geist
{42790 , "CC"},				-- Charm Plaguehound
{53070 , "CC"},				-- Worgen's Command
{48558 , "CC"},				-- Backfire
{44424 , "CC"},				-- Escape
{42320 , "CC"},				-- Head Butt
{53439 , "CC"},				-- Hex
{49935 , "CC"},				-- Hex of the Murloc
{50396 , "CC"},				-- Psychosis
{53325 , "CC"},				-- SelfSheep
{58283 , "CC"},				-- Throw Rock
{54683 , "CC"},				-- Ablaze
{60983 , "CC"},				-- Bright Flare
{62951 , "CC"},				-- Dodge
{74472 , "CC"},				-- Guard Fear
{50577 , "CC"},				-- Howl of Terror
{53438 , "CC"},				-- Incite Horror
{48696 , "CC"},				-- Intimidating Roar
{51467 , "CC"},				-- Intimidating Roar
{62585 , "CC"},				-- Mulgore Hatchling
{58958 , "CC"},				-- Presence of the Master
{51343 , "CC"},				-- Razorpine's Fear Effect
{51846 , "CC"},				-- Scared Chicken
{50979 , "CC"},				-- Scared Softknuckle
{50497 , "CC"},				-- Scream of Chaos
{56404 , "CC"},				-- Startling Flare
{62000 , "CC"},				-- Stinker Periodic
{52716 , "CC"},				-- Terrified
{46316 , "CC"},				-- Thundering Roar
{68506 , "CC"},				-- Crushing Leap
{58203 , "CC"},				-- Iron Chain
{63726 , "CC"},				-- Pacify Self
{59880 , "CC"},				-- Suppression Charge
{62026 , "CC"},				-- Test of Strength Building
{58891 , "CC"},				-- Wild Magic
{58893 , "CC"},				-- Wild Magic
{52151 , "CC"},				-- Bat Net
{71103 , "CC"},				-- Combobulating Spray
{67691 , "CC"},				-- Feign Death
{43489 , "CC"},				-- Grasp of the Lich King
{51788 , "CC"},				-- Lost Soul
{66490 , "CC"},				-- P3Wx2 Laser Barrage
--{60778 , "CC"},				-- Serenity
{44848 , "CC"},				-- Tumbling
{49946 , "CC"},				-- Chaff
{51899 , "CC"},				-- Banshee Curse (chance to hit reduced by 40%)
{54224 , "CC"},				-- Death
{58269 , "CC"},				-- Iceskin Stoneform
{52182 , "CC"},				-- Tomb of the Heartless
{51897 , "CC"},				-- Banshee Screech
{57490 , "CC"},				-- Librarian's Shush
{51316 , "CC"},				-- Lobotomize
{43415 , "CC"},				-- Freezing Trap
{43612 , "CC"},				-- Bash
{48620 , "CC"},				-- Wing Buffet
{49342 , "CC"},				-- Frost Breath
{49842 , "CC"},				-- Perturbed Mind
{51663 , "CC"},				-- Slap in the Face
{52174 , "CC"},				-- Heroic Leap
{52271 , "CC"},				-- Violent Crash
{52402 , "CC"},				-- Stunning Force
{52457 , "CC"},				-- Drak'aguul's Soldiers
{52584 , "CC"},				-- Influence of the Old God
{52939 , "CC"},				-- Pungent Slime Vomit
{54477 , "CC"},				-- Exhausted
{54506 , "CC"},				-- Heroic Leap
{54888 , "CC"},				-- Elemental Spawn Effect
{55929 , "CC"},				-- Impale
{57488 , "CC"},				-- Squall
{57794 , "CC"},				-- Heroic Leap
{57854 , "CC"},				-- Raging Shadows
{58154 , "CC"},				-- Hammer of Injustice
{58628 , "CC"},				-- Glyph of Death Grip
{59689 , "CC"},				-- Heroic Leap
{60109 , "CC"},				-- Heroic Leap
{61065 , "CC"},				-- War Stomp
{61143 , "CC"},				-- Crazed Chop
{61557 , "CC"},				-- Plant Spawn Effect
{61881 , "CC"},				-- Ice Shriek
{62891 , "CC"},				-- Vulnerable!
{62999 , "CC"},				-- Scourge Stun
{64141 , "CC"},				-- Flash Freeze
{64345 , "CC"},				-- Food
{67806 , "CC"},				-- Mental Combat
{68980 , "CC"},				-- Harvest Soul
{69222 , "CC"},				-- Throw Shield
{71960 , "CC"},				-- Heroic Leap
{74785 , "CC"},				-- Wrench Throw
{42166 , "CC"},				-- Plagued Blood Explosion
{42167 , "CC"},				-- Plagued Blood Explosion
{43416 , "CC"},				-- Throw Shield
{44532 , "CC"},				-- Knockdown
{44542 , "CC"},				-- Eagle Swoop
{45108 , "CC"},				-- CK's Fireball
{45419 , "CC"},				-- Nerub'ar Web Wrap
{45587 , "CC"},				-- Web Bolt
{45876 , "CC"},				-- Stampede
{45922 , "CC"},				-- Shadow Prison
{45995 , "CC"},				-- Bloodspore Ruination
{46010 , "CC"},				-- Bloodspore Ruination
{46383 , "CC"},				-- Cenarion Stun
{46441 , "CC"},				-- Stun
{46895 , "CC"},				-- Boulder Impact
{47007 , "CC"},				-- Boulder Impact
{47035 , "CC"},				-- Out Cold
{47415 , "CC"},				-- Freezing Breath
{47591 , "CC"},				-- Frozen Solid
{47923 , "CC"},				-- Stunned
{48323 , "CC"},				-- Indisposed
{48596 , "CC"},				-- Spirit Dies
{48628 , "CC"},				-- Lock Jaw
{49025 , "CC"},				-- Self Destruct
{49215 , "CC"},				-- Self-Destruct
{49333 , "CC"},				-- Ice Prison
{49481 , "CC"},				-- Glaive Throw
{49616 , "CC"},				-- Kidney Shot
{50100 , "CC"},				-- Stormbolt
{50597 , "CC"},				-- Ice Stalagmite
{50839 , "CC"},				-- Stun Self
{51020 , "CC"},				-- Time Lapse
{51319 , "CC"},				-- Sandfern Disguise
{51329 , "CC"},				-- Feign Death
{52287 , "CC"},				-- Quetz'lun's Hex of Frost
{52318 , "CC"},				-- Lumberjack Slam
{52459 , "CC"},				-- End of Round
{52497 , "CC"},				-- Flatulate
{52593 , "CC"},				-- Bloated Abomination Feign Death
{52640 , "CC"},				-- Forge Force
{52743 , "CC"},				-- Head Smack
{52781 , "CC"},				-- Persuasive Strike
{52908 , "CC"},				-- Backhand
{52989 , "CC"},				-- Akali's Stun
{53017 , "CC"},				-- Indisposed
{53211 , "CC"},				-- Post-Apocalypse
{53437 , "CC"},				-- Backbreaker
{53625 , "CC"},				-- Heroic Leap
{54028 , "CC"},				-- Trespasser!
{54029 , "CC"},				-- Trespasser!
{54426 , "CC"},				-- Decimate
{54526 , "CC"},				-- Torment
{55224 , "CC"},				-- Archivist's Scan
{55240 , "CC"},				-- Towering Chains
{55467 , "CC"},				-- Arcane Explosion
{55891 , "CC"},				-- Flame Sphere Spawn Effect
{55947 , "CC"},				-- Flame Sphere Death Effect
{55958 , "CC"},				-- Storm Bolt
{56448 , "CC"},				-- Storm Hammer
{56485 , "CC"},				-- The Storm's Fury
{56756 , "CC"},				-- Fall Asleep Standing
{57395 , "CC"},				-- Desperate Blow
{57515 , "CC"},				-- Waking from a Fitful Dream
{57626 , "CC"},				-- Feign Death
{57685 , "CC"},				-- Permanent Feign Death
{57886 , "CC"},				-- Defense System Spawn Effect
{58119 , "CC"},				-- Geist Control End
{58351 , "CC"},				-- Teach: Death Gate
{58540 , "CC"},				-- Eidolon Prison
{58563 , "CC"},				-- Assassinate Restless Lookout
{58664 , "CC"},				-- Shade Control End
{58672 , "CC"},				-- Impale
{59047 , "CC"},				-- Backhand
{59564 , "CC"},				-- Flatulate
{60511 , "CC"},				-- Deep Freeze
{60642 , "CC"},				-- Annihilate
{61224 , "CC"},				-- Deep Freeze
{61628 , "CC"},				-- Storm Bolt
{62091 , "CC"},				-- Stun Forever AoE
{62487 , "CC"},				-- Throw Grenade
{62973 , "CC"},				-- Foam Sword Attack
{63124 , "CC"},				-- Incapacitate Maloric
{63228 , "CC"},				-- Talon Strike
{63846 , "CC"},				-- Arm of Law
{63986 , "CC"},				-- Trespasser!
{63987 , "CC"},				-- Trespasser!
{64755 , "CC"},				-- Clayton's Test Spell
{65400 , "CC"},				-- Food Coma
{65578 , "CC"},				-- Right in the eye!
{66514 , "CC"},				-- Frost Breath
{66533 , "CC"},				-- Fel Shock
{67366 , "CC"},				-- C-14 Gauss Rifle
{67575 , "CC"},				-- Frost Breath
{67576 , "CC"},				-- Spirit Drain
{67780 , "CC"},				-- Transporter Arrival
{67791 , "CC"},				-- Transporter Arrival
{68485 , "CC"},				-- Clayton's Test Spell 2
{69006 , "CC"},				-- Onyxian Whelpling
{69681 , "CC"},				-- Lil' Frost Blast
{70296 , "CC"},				-- Caught!
{70525 , "CC"},				-- Jaina's Call
{70540 , "CC"},				-- Icy Prison
{70583 , "CC"},				-- Lich King Stun
{70592 , "CC"},				-- Permanent Feign Death
{70628 , "CC"},				-- Permanent Feign Death
{70630 , "CC"},				-- Frozen Aftermath - Feign Death
{71988 , "CC"},				-- Vile Fumes (Vile Fumigator's Mask item)
{73536 , "CC"},				-- Trespasser!
{74412 , "CC"},				-- Emergency Recall
{74490 , "CC"},				-- Permanent Feign Death
{74735 , "CC"},				-- Gnomerconfidance
{74808 , "CC"},				-- Twilight Phasing
{75448 , "CC"},				-- Bwonsamdi's Boot
{75496 , "CC"},				-- Zalazane's Fool
{75510 , "CC"},				-- Emergency Recall
{53261 , "CC"},				-- Saronite Grenade
{71590 , "CC"},				-- Rocket Launch
{71755 , "CC"},				-- Crafty Bomb
{71715 , "CC"},				-- Snivel's Rocket
{71786 , "CC"},				-- Rocket Launch
{385807 , "CC"},				-- Knockdown
{59124 , "CC"},				-- Crystalline Bonds
{49981 , "CC"},				-- Machine Gun (chance to hit reduced by 50%)
{50188 , "CC"},				-- Wildly Flailing (chance to hit reduced by 50%)
{50701 , "CC"},				-- Sling Mortar (chance to hit reduced by 50%)
{51356 , "CC"},				-- Vile Vomit (chance to hit reduced by 50%)
{54770 , "CC"},				-- Bone Saw (chance to hit reduced by 50%)
{60906 , "CC"},				-- Machine Gun (chance to hit reduced by 50%)
{53645 , "CC"},				-- The Light of Dawn (damage done reduced by 1500%)
{70339 , "CC"},				-- Friendly Boss Damage Mod (damage done reduced by 95%)
{43952 , "CC"},				-- Bonegrinder (physical damage done reduced by 75%)
{51705 , "CC"},				-- Wrongfully Accused (damage done reduced by 50%)
{51707 , "CC"},				-- Wrongfully Accused (damage done reduced by 50%)
{64850 , "CC"},				-- Unrelenting Assault (damage done reduced by 50%)
{65925 , "CC"},				-- Unrelenting Assault (damage done reduced by 50%)
{68780 , "CC"},				-- Frozen Visage (damage done reduced by 50%)
{72341 , "CC"},				-- Hallucinatory Creature (damage done reduced by 50%)
{414277 , "CC"},				-- Chaired
{413991 , "CC"},				-- Banana Slip
{412544 , "CC"},				-- Web Wrap
{58976 , "Disarm"},			-- Assaulter Slam, Throw Axe Disarm
{48883 , "Disarm"},			-- Disarm
{58138 , "Disarm"},			-- Disarm Test
{54159 , "Disarm"},			-- Ritual of the Sword
{54059 , "Disarm"},			-- You're a ...! (Effects4)
{57590 , "Disarm"},			-- Steal Ranged (only disarm ranged weapon)
{65802 , "Immune"},			-- Ice Block
{52982 , "Immune"},			-- Akali's Immunity
{64505 , "Immune"},			-- Dark Shield
{52972 , "Immune"},			-- Dispersal
{54322 , "Immune"},			-- Divine Shield
{47922 , "Immune"},			-- Furyhammer's Immunity
{54166 , "Immune"},			-- Maker's Sanctuary
{53052 , "Immune"},			-- Phase Out
{74458 , "Immune"},			-- Power Shield XL-1
{50161 , "Immune"},			-- Protection Sphere
{50494 , "Immune"},			-- Shroud of Lightning
{54434 , "Immune"},			-- Sparksocket AA: Periodic Aura
{58729 , "Immune"},			-- Spiritual Immunity
{52185 , "Immune"},			-- Bindings of Submission
{62336 , "Immune"},			-- Hookshot Aura
{48695 , "Immune"},			-- Imbue Power Shield State
{48325 , "Immune"},			-- Rune Shield
{62371 , "Immune"},			-- Spirit of Redemption
{75099 , "Immune"},			-- Zalazane's Shield
{75223 , "Immune"},			-- Zalazane's Shield
{66776 , "Immune"},			-- Rage (not immune, damage taken decreased by 95%)
{62733 , "Immune"},			-- Hardened (not immune, damage taken decreased by 90%)
{57057 , "Immune"},			-- Torvald's Deterrence (not immune, damage taken decreased by 60%)
{63214 , "Immune"},			-- Scourge Damage Reduction (not immune, damage taken decreased by 60%)
{53058 , "Immune"},			-- Crystalline Essence (not immune, damage taken decreased by 50%)
{53355 , "Immune"},			-- Strength of the Frenzyheart (not immune, damage taken decreased by 50%)
{53371 , "Immune"},			-- Power of the Great Ones (not immune, damage taken decreased by 50%)
{58130 , "Immune"},			-- Icebound Fortitude (not immune, damage taken decreased by 50%)
{61088 , "Immune"},			-- Zombie Horde (not immune, damage taken decreased by 50%)
{61099 , "Immune"},			-- Zombie Horde (not immune, damage taken decreased by 50%)
{61144 , "Immune"},			-- Fire Shield (not immune, damage taken decreased by 50%)
{54467 , "Immune"},			-- Bone Armor (not immune, damage taken decreased by 40%)
{71822 , "Immune"},			-- Shadow Resonance (not immune, damage taken decreased by 35%)
{413172 , "Immune"},			-- Diminish Power (not immune, damage taken decreased by 99%)
{62712 , "ImmunePhysical"},	-- Grab
{54386 , "ImmunePhysical"},	-- Darmuk's Vigilance (chance to dodge increased by 75%)
{51946 , "ImmunePhysical"},	-- Evasive Maneuver (chance to dodge increased by 75%)
{52894 , "ImmuneSpell"},		-- Anti-Magic Zone (blocks 85% of incoming spell damage)
{53636 , "ImmuneSpell"},		-- Anti-Magic Zone (blocks 85% of incoming spell damage)
{53637 , "ImmuneSpell"},		-- Anti-Magic Zone (blocks 85% of incoming spell damage)
{57643 , "ImmuneSpell"},		-- Spell Reflection
{63089 , "ImmuneSpell"},		-- Spell Deflection
{55976 , "ImmuneSpell"},		-- Spell Deflection
{51131 , "Silence"},			-- Strangulate
{51609 , "Silence"},			-- Arcane Lightning
{62826 , "Silence"},			-- Energy Orb
{61734 , "Silence"},			-- Noblegarden Bunny
{61716 , "Silence"},			-- Rabbit Costume
{42671 , "Silence"},			-- Silencing Shot
{64140 , "Silence"},			-- Sonic Burst
{68922 , "Silence"},			-- Unstable Air Nova
{53095 , "Silence"},			-- Worgen's Call
{55536 , "Root"},				-- Frostweave Net
{54453 , "Root"},				-- Web Wrap
{57668 , "Root"},				-- Frost Nova
{61376 , "Root"},				-- Frost Nova
{62597 , "Root"},				-- Frost Nova
{65792 , "Root"},				-- Frost Nova
{69571 , "Root"},				-- Frost Nova
{71929 , "Root"},				-- Frost Nova
{47021 , "Root"},				-- Net
{62312 , "Root"},				-- Net
{51959 , "Root"},				-- Chicken Net
{52761 , "Root"},				-- Barbed Net
{49453 , "Root"},				-- Wolvar Net
{54997 , "Root"},				-- Cast Net
{66474 , "Root"},				-- Throw Net
{50635 , "Root"},				-- Frozen
{51440 , "Root"},				-- Frozen
{52973 , "Root"},				-- Frost Breath
{53019 , "Root"},				-- Earth's Grasp
{53077 , "Root"},				-- Ensnaring Trap
{53218 , "Root"},				-- Frozen Grip
{53534 , "Root"},				-- Chains of Ice
{58464 , "Root"},				-- Chains of Ice
{59679 , "Root"},				-- Copy of Frostbite
{61385 , "Root"},				-- Bear Trap
{62573 , "Root"},				-- Locked Lance
{68821 , "Root"},				-- Chain Reaction
{48416 , "Root"},				-- Rune Detonation
{48601 , "Root"},				-- Rune of Binding
{49978 , "Root"},				-- Claw Grasp
{52713 , "Root"},				-- Rune Weaving
{53442 , "Root"},				-- Claw Grasp
{54047 , "Root"},				-- Light Lamp
{55030 , "Root"},				-- Rune Detonation
{55284 , "Root"},				-- Siege Ram
{56425 , "Root"},				-- Earth's Grasp
{58447 , "Root"},				-- Drakefire Chile Ale
{61043 , "Root"},				-- The Raising of Sindragosa
{62187 , "Root"},				-- Touchdown!
{63861 , "Root"},				-- Chains of Law
{65444 , "Root"},				-- Aura Beam Test
{71713 , "Root"},				-- Searching the Bank
{71745 , "Root"},				-- Searching the Auction House
{71752 , "Root"},				-- Searching the Barber Shop
{71758 , "Root"},				-- Searching the Barber Shop
{71759 , "Root"},				-- Searching the Bank
{71760 , "Root"},				-- Searching the Auction House
{73395 , "Root"},				-- Elemental Credit
{75215 , "Root"},				-- Root
{50822 , "Other"},				-- Fervor
{54615 , "Other"},				-- Aimed Shot (healing effects reduced by 50%)
{54657 , "Other"},				-- Incorporeal (chance to dodge increased by 50%)
{60617 , "Other"},				-- Parry (chance to parry increased by 100%)
{31965 , "Other"},				-- Spell Debuffs 2 (80) (healing effects reduced by 50%)
{60084 , "Other"},				-- The Veil of Shadows (healing effects reduced by 50%)
{61042 , "Other"},				-- Mortal Smash (healing effects reduced by 50%)
{68881 , "Other"},				-- Unstable Water Nova (healing effects reduced by 50%)
{51372 , "Snare"},				-- Dazed
{43512 , "Snare"},				-- Mind Flay
{60472 , "Snare"},				-- Mind Flay
{57665 , "Snare"},				-- Frostbolt
{65023 , "Snare"},				-- Cone of Cold
{59258 , "Snare"},				-- Cone of Cold
{48783 , "Snare"},				-- Trample
{51878 , "Snare"},				-- Ice Slash
{53113 , "Snare"},				-- Thunderclap
{61359 , "Snare"},				-- Thunderclap
{54996 , "Snare"},				-- Ice Slick
{54540 , "Snare"},				-- Test Frostbolt Weapon
{61087 , "Snare"},				-- Frostbolt
{42719 , "Snare"},				-- Frostbolt
{54791 , "Snare"},				-- Frostbolt
{61730 , "Snare"},				-- Frostbolt
{69274 , "Snare"},				-- Frostbolt
{70327 , "Snare"},				-- Frostbolt
{62583 , "Snare"},				-- Frostbolt
{58970 , "Snare"},				-- Blast Wave
{60290 , "Snare"},				-- Blast Wave
{47805 , "Snare"},				-- Chains of Ice
{52436 , "Snare"},				-- Scarlet Cannon Assault
{57383 , "Snare"},				-- Argent Cannon Assault
{44622 , "Snare"},				-- Tendon Rip
{51315 , "Snare"},				-- Leprous Touch
{68902 , "Snare"},				-- Unstable Earth Nova
{69769 , "Snare"},				-- Ice Prison
{50304 , "Snare"},				-- Outbreak
{58606 , "Snare"},				-- Self Snare
{65262 , "Snare"},				-- Arcane Blurst
{70866 , "Snare"},				-- Shadow Blast
{61578 , "Snare"},				-- Incapacitating Shout
{43562 , "Snare"},				-- Frost Breath
{43568 , "Snare"},				-- Frost Strike
{43569 , "Snare"},				-- Frost
{47425 , "Snare"},				-- Frost Breath
{49316 , "Snare"},				-- Ice Cannon
{51676 , "Snare"},				-- Wavering Will
{51681 , "Snare"},				-- Rearing Stomp
{51938 , "Snare"},				-- Wing Beat
{52292 , "Snare"},				-- Pestilience Test
{52744 , "Snare"},				-- Piercing Howl
{52807 , "Snare"},				-- Avenger's Shield
{52889 , "Snare"},				-- Envenomed Shot
{54193 , "Snare"},				-- Earth's Fury
{54340 , "Snare"},				-- Vile Vomit
{54399 , "Snare"},				-- Water Bubble
{54451 , "Snare"},				-- Withered Touch
{54632 , "Snare"},				-- Claws of Ice
{54687 , "Snare"},				-- Cold Feet
{56138 , "Snare"},				-- Sprained Ankle
{56143 , "Snare"},				-- Acidic Retch
{56147 , "Snare"},				-- Aching Bones
{57477 , "Snare"},				-- Freezing Breath
{60667 , "Snare"},				-- Frost Breath
{60814 , "Snare"},				-- Frost Blast
{61166 , "Snare"},				-- Frostbite Weapon
{61572 , "Snare"},				-- Frostbite
{61577 , "Snare"},				-- Molten Blast
{63004 , "Snare"},				-- {DND] NPC Slow
{67035 , "Snare"},				-- Frost Trap
{68551 , "Snare"},				-- Dan's Avenger's Shield
{71361 , "Snare"},				-- Frost Blast
{74802 , "Snare"},				-- Consumption
{47298 , "Snare"},				-- Test Frozen Tomb Effect
{47307 , "Snare"},				-- Test Frozen Tomb
{50522 , "Snare"},				-- Gorloc Stomp
{69984 , "Snare"},				-- Frostfire Bolt
{414011 , "Snare"},				-- Frost Trap

},



------------------------
---- PVE WOTLK
------------------------
{"Vault of Archavon Raid",
	-- -- Archavon the Stone Watcher
	{58965    , "CC"},				-- Choking Cloud (chance to hit with melee and ranged attacks reduced by 50%)
	{61672    , "CC"},				-- Choking Cloud (chance to hit with melee and ranged attacks reduced by 50%)
	{58663    , "CC"},				-- Stomp
	{60880    , "CC"},				-- Stomp
	-- -- Emalon the Storm Watcher
	{63080    , "CC"},				-- Stoned (!)
	-- -- Toravon the Ice Watcher
	{72090    , "Root"},				-- Freezing Ground
},
------------------------
{"Naxxramas (WotLK) Raid",
-- -- Trash
{56427    , "CC"},				-- War Stomp
{55314    , "Silence"},			-- Strangulate
{55334    , "Silence"},			-- Strangulate
{54722    , "Immune"},			-- Stoneskin (not immune, big health regeneration)
{53803    , "Other"},				-- Veil of Shadow
{55315    , "Other"},				-- Bone Armor
{55336    , "Other"},				-- Bone Armor
{55848    , "Other"},				-- Invisibility
{54769    , "Snare"},				-- Slime Burst
{54339    , "Snare"},				-- Mind Flay
{29407    , "Snare"},				-- Mind Flay
{54805    , "Snare"},				-- Mind Flay
-- -- Anub'Rekhan
{54022    , "CC"},				-- Locust Swarm
-- -- Grand Widow Faerlina
{54093    , "Silence"},			-- Silence
-- -- Maexxna
{54125    , "CC"},				-- Web Spray
{54121    , "Other"},				-- Necrotic Poison (healing taken reduced by 75%)
-- -- Noth the Plaguebringer
{54814    , "Snare"},				-- Cripple
-- -- Heigan the Unclean
{29310    , "Other"},				-- Spell Disruption (casting speed decreased by 300%)
-- -- Loatheb
{55593    , "Other"},				-- Necrotic Aura (healing taken reduced by 100%)
-- -- Sapphiron
{55699    , "Snare"},				-- Chill
-- -- Kel'Thuzad
{55802    , "Snare"},				-- Frostbolt
{55807    , "Snare"},				-- Frostbolt
------------------------
-- The Obsidian Sanctum Raid
-- -- Trash
{57835    , "Immune"},			-- Gift of Twilight
{39647    , "Other"},				-- Curse of Mending (20% chance to heal enemy target on spell or melee hit)
{58948    , "Other"},				-- Curse of Mending (20% chance to heal enemy target on spell or melee hit)
{57728    , "CC"},				-- Shockwave
{58947    , "CC"},				-- Shockwave
-- -- Sartharion
{56910    , "CC"},				-- Tail Lash
{58957    , "CC"},				-- Tail Lash
{58766    , "Immune"},			-- Gift of Twilight
{61632    , "Other"},				-- Berserk
{57491    , "Snare"},				-- Flame Tsunami
------------------------
-- The Eye of Eternity Raid
-- -- Malygos
{57108    , "Immune"},			-- Flame Shield (not immune, damage taken decreased by 80%)
{55853    , "Root"},				-- Vortex
{56263    , "Root"},				-- Vortex
{56264    , "Root"},				-- Vortex
{56265    , "Root"},				-- Vortex
{56266    , "Root"},				-- Vortex
{61071    , "Root"},				-- Vortex
{61072    , "Root"},				-- Vortex
{61073    , "Root"},				-- Vortex
{61074    , "Root"},				-- Vortex
{61075    , "Root"},				-- Vortex
{56438    , "Other"},				-- Arcane Overload (reduces magic damage taken by 50%)
{55849    , "Other"},				-- Power Spark
{56152    , "Other"},				-- Power Spark
{57060    , "Other"},				-- Haste
{47008    , "Other"},				-- Berserk
},

------------------------
{"Ulduar Raid",
-- -- Trash
{64010    , "CC"},				-- Nondescript
{64013    , "CC"},				-- Nondescript
{64781    , "CC"},				-- Charged Leap
{64819    , "CC"},				-- Devastating Leap
{64942    , "CC"},				-- Devastating Leap
{64649    , "CC"},				-- Freezing Breath
{62310    , "CC"},				-- Impale
{62928    , "CC"},				-- Impale
{63713    , "CC"},				-- Dominate Mind
{64918    , "CC"},				-- Electro Shock
{64971    , "CC"},				-- Electro Shock
{64647    , "CC"},				-- Snow Blindness
{64654    , "CC"},				-- Snow Blindness
{65078    , "CC"},				-- Compacted
{65105    , "CC"},				-- Compacted
{64697    , "Silence"},			-- Earthquake
{64663    , "Silence"},			-- Arcane Burst
{63710    , "Immune"},			-- Void Barrier
{63784    , "Immune"},			-- Bladestorm (not immune to dmg, only to LoC)
{63006    , "Immune"},			-- Aggregation Pheromones (not immune, damage taken reduced by 90%)
{65070    , "Immune"},			-- Defense Matrix (not immune, damage taken reduced by 90%)
{64903    , "Root"},				-- Fuse Lightning
{64970    , "Root"},				-- Fuse Lightning
{64877    , "Root"},				-- Harden Fists
{63912    , "Root"},				-- Frost Nova
{63272    , "Other"},				-- Hurricane (slow attacks and spells by 67%)
{63557    , "Other"},				-- Hurricane (slow attacks and spells by 67%)
{64644    , "Other"},				-- Shield of the Winter Revenant (damage taken from AoE attacks reduced by 90%)
{63136    , "Other"},				-- Winter's Embrace
{63564    , "Other"},				-- Winter's Embrace
{63539    , "Other"},				-- Separation Anxiety
{63630    , "Other"},				-- Vengeful Surge
{62845    , "Snare"},				-- Hamstring
{63913    , "Snare"},				-- Frostbolt
{64645    , "Snare"},				-- Cone of Cold
{64655    , "Snare"},				-- Cone of Cold
{62287    , "Snare"},				-- Tar
-- -- Flame Leviathan
{62297    , "CC"},				-- Hodir's Fury
{62475    , "CC"},				-- Systems Shutdown
-- -- Ignis the Furnace Master
{62717    , "CC"},				-- Slag Pot
{65722    , "CC"},				-- Slag Pot
{63477    , "CC"},				-- Slag Pot
{65720    , "CC"},				-- Slag Pot
{65723    , "CC"},				-- Slag Pot
{62382    , "CC"},				-- Brittle
-- -- Razorscale
{62794    , "CC"},				-- Stun Self
{64774    , "CC"},				-- Fused Armor
-- -- XT-002 Deconstructor
{63849    , "Other"},				-- Exposed Heart
{62775    , "Snare"},				-- Tympanic Tantrum
-- -- Assembly of Iron
{61878    , "CC"},				-- Overload
{63480    , "CC"},				-- Overload
--{64320    , "Other"},				-- Rune of Power
{63489    , "Other"},				-- Shield of Runes
{62274    , "Other"},				-- Shield of Runes
{63967    , "Other"},				-- Shield of Runes
{62277    , "Other"},				-- Shield of Runes
{61888    , "Other"},				-- Overwhelming Power
{64637    , "Other"},				-- Overwhelming Power
-- -- Kologarn
{64238    , "Other"},				-- Berserk
{62056    , "CC"},				-- Stone Grip
{63985    , "CC"},				-- Stone Grip
{64290    , "CC"},				-- Stone Grip
{64292    , "CC"},				-- Stone Grip
-- -- Auriaya
{64386    , "CC"},				-- Terrifying Screech
{64478    , "CC"},				-- Feral Pounce
{64669    , "CC"},				-- Feral Pounce
-- -- Freya
{62532    , "CC"},				-- Conservator's Grip
{62467    , "CC"},				-- Drained of Power
{62283    , "Root"},				-- Iron Roots
{62438    , "Root"},				-- Iron Roots
{62861    , "Root"},				-- Iron Roots
{62930    , "Root"},				-- Iron Roots
-- -- Hodir
{61968    , "CC"},				-- Flash Freeze
{61969    , "CC"},				-- Flash Freeze
{61170    , "CC"},				-- Flash Freeze
{61990    , "CC"},				-- Flash Freeze
{62469    , "Root"},				-- Freeze
-- -- Mimiron
{64436    , "CC"},				-- Magnetic Core
{64616    , "Silence"},			-- Deafening Siren
{64668    , "Root"},				-- Magnetic Field
{64570    , "Other"},				-- Flame Suppressant (casting speed slowed by 50%)
{65192    , "Other"},				-- Flame Suppressant (casting speed slowed by 50%)
-- -- Thorim
{62241    , "CC"},				-- Paralytic Field
{63540    , "CC"},				-- Paralytic Field
{62042    , "CC"},				-- Stormhammer
{62332    , "CC"},				-- Shield Smash
{62420    , "CC"},				-- Shield Smash
{64151    , "CC"},				-- Whirling Trip
{62316    , "CC"},				-- Sweep
{62417    , "CC"},				-- Sweep
{62276    , "Immune"},			-- Sheath of Lightning (not immune, damage taken reduced by 99%)
{62338    , "Immune"},			-- Runic Barrier (not immune, damage taken reduced by 50%)
{62321    , "Immune"},			-- Runic Shield (not immune, physical damage taken reduced by 50% and absorbing magical damage)
{62529    , "Immune"},			-- Runic Shield (not immune, physical damage taken reduced by 50% and absorbing magical damage)
{62470    , "Other"},				-- Deafening Thunder (spell casting times increased by 75%)
{62555    , "Other"},				-- Berserk
{62560    , "Other"},				-- Berserk
{62526    , "Root"},				-- Rune Detonation
{62605    , "Root"},				-- Frost Nova
{62576    , "Snare"},				-- Blizzard
{62602    , "Snare"},				-- Blizzard
{62601    , "Snare"},				-- Frostbolt
{62580    , "Snare"},				-- Frostbolt Volley
{62604    , "Snare"},				-- Frostbolt Volley
-- -- General Vezax
{63364    , "Immune"},			-- Saronite Barrier (not immune, damage taken reduced by 99%)
{63276    , "Other"},				-- Mark of the Faceless
{62662    , "Snare"},				-- Surge of Darkness
-- -- Yogg-Saron
{64189    , "CC"},				-- Deafening Roar
{64173    , "CC"},				-- Shattered Illusion
{64155    , "CC"},				-- Black Plague
{63830    , "CC"},				-- Malady of the Mind
{63881    , "CC"},				-- Malady of the Mind
{63042    , "CC"},				-- Dominate Mind
{63120    , "CC"},				-- Insane
{63894    , "Immune"},			-- Shadowy Barrier
{64775    , "Immune"},			-- Shadowy Barrier
{64175    , "Immune"},			-- Flash Freeze
{64156    , "Snare"},				-- Apathy
},
------------------------
{"Trial of the Crusader Raid",
-- -- Northrend Beasts
{66407    , "CC"},				-- Head Crack
{66689    , "CC"},				-- Arctic Breath
{72848    , "CC"},				-- Arctic Breath
{66770    , "CC"},				-- Ferocious Butt
{66683    , "CC"},				-- Massive Crash
{66758    , "CC"},				-- Staggered Daze
{66830    , "CC"},				-- Paralysis
{66759    , "Other"},				-- Frothing Rage
{66823    , "Snare"},				-- Paralytic Toxin
-- -- Lord Jaraxxus
{66237    , "CC"},				-- Incinerate Flesh (reduces damage dealt by 50%)
{66283    , "CC"},				-- Spinning Pain Spike (!)
{66334    , "Other"},				-- Mistress' Kiss
{66336    , "Other"},				-- Mistress' Kiss
-- -- Faction Champions
{65930    , "CC"},				-- Intimidating Shout
{65931    , "CC"},				-- Intimidating Shout
{65929    , "CC"},				-- Charge Stun
{65809    , "CC"},				-- Fear
{65820    , "CC"},				-- Death Coil
{66054    , "CC"},				-- Hex
{65960    , "CC"},				-- Blind
{65545    , "CC"},				-- Psychic Horror
{65543    , "CC"},				-- Psychic Scream
{66008    , "CC"},				-- Repentance
{66007    , "CC"},				-- Hammer of Justice
{66613    , "CC"},				-- Hammer of Justice
{65801    , "CC"},				-- Polymorph
{65877    , "CC"},				-- Wyvern Sting
{65859    , "CC"},				-- Cyclone
{65935    , "Disarm"},			-- Disarm
{65542    , "Silence"},			-- Silence
{65813    , "Silence"},			-- Unstable Affliction
{66018    , "Silence"},			-- Strangulate
{65857    , "Root"},				-- Entangling Roots
{66070    , "Root"},				-- Entangling Roots (Nature's Grasp)
{66010    , "Immune"},			-- Divine Shield
{65871    , "Immune"},			-- Deterrence
{66023    , "Immune"},			-- Icebound Fortitude (not immune, damage taken reduced by 45%)
{65544    , "Immune"},			-- Dispersion (not immune, damage taken reduced by 90%)
{65947    , "Immune"},			-- Bladestorm (not immune to dmg, only to LoC)
{66009    , "Immune"},	-- Hand of Protection
{65961    , "Immune"},		-- Cloak of Shadows
{66071    , "Other"},				-- Nature's Grasp
{65883    , "Other"},				-- Aimed Shot (healing effects reduced by 50%)
{65926    , "Other"},				-- Mortal Strike (healing effects reduced by 50%)
{65962    , "Other"},				-- Wound Poison (healing effects reduced by 50%)
{66011    , "Other"},				-- Avenging Wrath
{65932    , "Other"},				-- Retaliation
--{65983    , "Other"},				-- Heroism
--{65980    , "Other"},				-- Bloodlust
{66020    , "Snare"},				-- Chains of Ice
{66207    , "Snare"},				-- Wing Clip
{65488    , "Snare"},				-- Mind Flay
{65815    , "Snare"},				-- Curse of Exhaustion
{65807    , "Snare"},				-- Frostbolt
-- -- Twin Val'kyr
{65724    , "Other"},				-- Empowered Darkness
{65748    , "Other"},				-- Empowered Light
{65874    , "Other"},				-- Shield of Darkness
{65858    , "Other"},				-- Shield of Lights
-- -- Anub'arak
{66012    , "CC"},				-- Freezing Slash
{66193    , "Snare"},				-- Permafrost
},
------------------------
{"Icecrown Citadel Raid",
-- -- Trash
{71784    , "CC"},				-- Hammer of Betrayal
{71785    , "CC"},				-- Conflagration
{71592    , "CC"},				-- Fel Iron Bomb
{71787    , "CC"},				-- Fel Iron Bomb
{70410    , "CC"},				-- Polymorph: Spider
{70645    , "CC"},				-- Chains of Shadow
{70432    , "CC"},				-- Blood Sap
{71010    , "CC"},				-- Web Wrap
{71330    , "CC"},				-- Ice Tomb
{69903    , "CC"},				-- Shield Slam
{71123    , "CC"},				-- Decimate
{71163    , "CC"},				-- Devour Humanoid
{71298    , "CC"},				-- Banish
{71443    , "CC"},				-- Impaling Spear
{71847    , "CC"},				-- Critter-Killer Attack
{71955    , "CC"},				-- Focused Attacks
{70781    , "CC"},				-- Light's Hammer Teleport
{70856    , "CC"},				-- Oratory of the Damned Teleport
{70857    , "CC"},				-- Rampart of Skulls Teleport
{70858    , "CC"},				-- Deathbringer's Rise Teleport
{70859    , "CC"},				-- Upper Spire Teleport
{70861    , "CC"},				-- Sindragosa's Lair Teleport
{70860    , "CC"},				-- Frozen Throne Teleport
{72106    , "Disarm"},			-- Polymorph: Spider
{71325    , "Disarm"},			-- Frostblade
{70714    , "Immune"},			-- Icebound Armor
{71550    , "Immune"},			-- Divine Shield
{71463    , "Immune"},			-- Aether Shield
{69910    , "Immune"},			-- Pain Suppression (not immune, damage taken reduced by 40%)
{69634    , "Immune"},			-- Taste of Blood (not immune, damage taken reduced by 50%)
{72065    , "Immune"},	-- Shroud of Protection
{72066    , "Immune"},		-- Shroud of Spell Warding
{69901    , "Immune"},		-- Spell Reflect
{70299    , "Root"},				-- Siphon Essence
{70431    , "Root"},				-- Shadowstep
{71320    , "Root"},				-- Frost Nova
{70980    , "Root"},				-- Web Wrap
{71327    , "Root"},				-- Web
{71647    , "Root"},				-- Ice Trap
{69483    , "Other"},				-- Dark Reckoning
{71552    , "Other"},				-- Mortal Strike (healing effects reduced by 50%)
{70711    , "Other"},				-- Empowered Blood
{69871    , "Other"},				-- Plague Stream
{70407    , "Snare"},				-- Blast Wave
{69405    , "Snare"},				-- Consuming Shadows
{71318    , "Snare"},				-- Frostbolt
{61747    , "Snare"},				-- Frostbolt
{69869    , "Snare"},				-- Frostfire Bolt
{69927    , "Snare"},				-- Avenger's Shield
{70536    , "Snare"},				-- Spirit Alarm
{70545    , "Snare"},				-- Spirit Alarm
{70546    , "Snare"},				-- Spirit Alarm
{70547    , "Snare"},				-- Spirit Alarm
{70739    , "Snare"},				-- Geist Alarm
{70740    , "Snare"},				-- Geist Alarm
-- -- Lord Marrowgar
{69065    , "CC"},				-- Impaled
-- -- Lady Deathwhisper
{71289    , "CC"},				-- Dominate Mind
{70768    , "Immune"},		-- Shroud of the Occult (reflects harmful spells)
{71234    , "Immune"},		-- Adherent's Determination (not immune, magic damage taken reduced by 99%)
{71235    , "Immune"},	-- Adherent's Determination (not immune, physical damage taken reduced by 99%)
{71237    , "Other"},				-- Curse of Torpor (ability cooldowns increased by 15 seconds)
{70674    , "Other"},				-- Vampiric Might
{71420    , "Snare"},				-- Frostbolt
-- -- Gunship Battle
{69705    , "CC"},				-- Below Zero
{69651    , "Other"},				-- Wounding Strike (healing effects reduced by 40%)
-- -- Deathbringer Saurfang
{70572    , "CC"},				-- Grip of Agony
{72771    , "Other"},				-- Scent of Blood (physical damage done increased by 300%)
{72769    , "Snare"},				-- Scent of Blood
-- -- Festergut
{72297    , "CC"},				-- Malleable Goo (casting and attack speed reduced by 250%)
{69240    , "CC"},				-- Vile Gas
{69248    , "CC"},				-- Vile Gas
-- -- Rotface
{72272    , "CC"},				-- Vile Gas	(!)
{72274    , "CC"},				-- Vile Gas
{69244    , "Root"},				-- Vile Gas
{72276    , "Root"},				-- Vile Gas
{69674    , "Other"},				-- Mutated Infection (healing received reduced by 75%/-50%)
{69778    , "Snare"},				-- Sticky Ooze
{69789    , "Snare"},				-- Ooze Flood
-- -- Professor Putricide
{70853    , "CC"},				-- Malleable Goo (casting and attack speed reduced by 250%)
{71615    , "CC"},				-- Tear Gas
{71618    , "CC"},				-- Tear Gas
{71278    , "CC"},				-- Choking Gas (reduces chance to hit by 75%/100%)
{71279    , "CC"},				-- Choking Gas Explosion (reduces chance to hit by 75%/100%)
{70447    , "Root"},				-- Volatile Ooze Adhesive
{70539    , "Snare"},				-- Regurgitated Ooze
-- -- Blood Prince Council
{71807    , "Snare"},				-- Glittering Sparks
-- -- Blood-Queen Lana'thel
{70923    , "CC"},				-- Uncontrollable Frenzy
{73070    , "CC"},				-- Incite Terror
-- -- Valithria Dreamwalker
--{70904    , "CC"},				-- Corruption
{70588    , "Other"},				-- Suppression (healing taken reduced)
{70759    , "Snare"},				-- Frostbolt Volley
-- -- Sindragosa
{70157    , "CC"},				-- Ice Tomb
-- -- The Lich King
{71614    , "CC"},				-- Ice Lock
{73654    , "CC"},				-- Harvest Souls
{69242    , "Silence"},			-- Soul Shriek
{72143    , "Other"},				-- Enrage
{72679    , "Other"},				-- Harvested Soul (increases all damage dealt by 200%/500%)
{73028    , "Other"},				-- Harvested Soul (increases all damage dealt by 200%/500%)
},
------------------------
{"The Ruby Sanctum Raid",
-- -- Trash
{74509    , "CC"},				-- Repelling Wave
{74384    , "CC"},				-- Intimidating Roar
{75417    , "CC"},				-- Shockwave
{74456    , "CC"},				-- Conflagration
{78722    , "Other"},				-- Enrage
{75413    , "Snare"},				-- Flame Wave
-- -- Halion
{74531    , "CC"},				-- Tail Lash
{74834    , "Immune"},			-- Corporeality (not immune, damage taken reduced by 50%, damage dealt reduced by 30%)
{74835    , "Immune"},			-- Corporeality (not immune, damage taken reduced by 80%, damage dealt reduced by 50%)
{74836    , "Immune"},			-- Corporeality (damage taken reduced by 100%, damage dealt reduced by 70%)
{74830    , "Other"},				-- Corporeality (damage taken increased by 200%, damage dealt increased by 100%)
{74831    , "Other"},				-- Corporeality (damage taken increased by 400%, damage dealt increased by 200%)
},
------------------------
-- WotLK Dungeons
{"The Culling of Stratholme",
{52696    , "CC"},				-- Constricting Chains
{58823    , "CC"},				-- Constricting Chains
{52711    , "CC"},				-- Steal Flesh (damage dealt decreased by 75%)
{58848    , "CC"},				-- Time Stop
{52721    , "CC"},				-- Sleep
{58849    , "CC"},				-- Sleep
{60451    , "CC"},				-- Corruption of Time
{52634    , "Immune"},			-- Void Shield (not immune, reduces damage taken by 50%)
{58813    , "Immune"},			-- Void Shield (not immune, reduces damage taken by 75%)
{52317    , "Immune"},	-- Defend (not immune, reduces physical damage taken by 50%)
{52491    , "Root"},				-- Web Explosion
{52766    , "Snare"},				-- Time Warp
{52657    , "Snare"},				-- Temporal Vortex
{58816    , "Snare"},				-- Temporal Vortex
{52498    , "Snare"},				-- Cripple
{20828    , "Snare"},				-- Cone of Cold
},
{"The Violet Hold",
{52719    , "CC"},				-- Concussion Blow
{58526    , "CC"},				-- Azure Bindings
{58537    , "CC"},				-- Polymorph
{58534    , "CC"},				-- Deep Freeze
{59820    , "Immune"},			-- Drained
{54306    , "Immune"},			-- Protective Bubble (not immune, reduces damage taken by 99%)
{60158    , "Immune"},		-- Magic Reflection
{58458    , "Root"},				-- Frost Nova
{59253    , "Root"},				-- Frost Nova
{54462    , "Snare"},				-- Howling Screech
{58693    , "Snare"},				-- Blizzard
{59369    , "Snare"},				-- Blizzard
{58463    , "Snare"},				-- Cone of Cold
{58532    , "Snare"},				-- Frostbolt Volley
{61594    , "Snare"},				-- Frostbolt Volley
{58457    , "Snare"},				-- Frostbolt
{58535    , "Snare"},				-- Frostbolt
{59251    , "Snare"},				-- Frostbolt
{61590    , "Snare"},				-- Frostbolt
{20822    , "Snare"},				-- Frostbolt
},
{"Azjol-Nerub",
{52087    , "CC"},				-- Web Wrap
{52524    , "CC"},				-- Blinding Webs
{59365    , "CC"},				-- Blinding Webs
{53472    , "CC"},				-- Pound
{59433    , "CC"},				-- Pound
{52086    , "Root"},				-- Web Wrap
{53322    , "Root"},				-- Crushing Webs
{59347    , "Root"},				-- Crushing Webs
{52586    , "Snare"},				-- Mind Flay
{59367    , "Snare"},				-- Mind Flay
{52592    , "Snare"},				-- Curse of Fatigue
{59368    , "Snare"},				-- Curse of Fatigue
},
{"Ahn'kahet: The Old Kingdom",
{55959    , "CC"},				-- Embrace of the Vampyr
{59513    , "CC"},				-- Embrace of the Vampyr
{57055    , "CC"},				-- Mini (damage dealt reduced by 75%)
{61491    , "CC"},				-- Intercept
{56153    , "Immune"},			-- Guardian Aura
{55964    , "Immune"},			-- Vanish
{57095    , "Root"},				-- Entangling Roots
{56632    , "Root"},				-- Tangled Webs
{56219    , "Other"},				-- Gift of the Herald (damage dealt increased by 200%)
{57789    , "Other"},				-- Mortal Strike (healing effects reduced by 50%)
{59995    , "Root"},				-- Frost Nova
{61462    , "Root"},				-- Frost Nova
{57629    , "Root"},				-- Frost Nova
{57941    , "Snare"},				-- Mind Flay
{59974    , "Snare"},				-- Mind Flay
{57799    , "Snare"},				-- Avenger's Shield
{59999    , "Snare"},				-- Avenger's Shield
{57825    , "Snare"},				-- Frostbolt
{61461    , "Snare"},				-- Frostbolt
{57779    , "Snare"},				-- Mind Flay
{60006    , "Snare"},				-- Mind Flay
},
{"Utgarde Keep",
{42672    , "CC"},				-- Frost Tomb
{48400    , "CC"},				-- Frost Tomb
{43651    , "CC"},				-- Charge
{35570    , "CC"},				-- Charge
{59611    , "CC"},				-- Charge
{42723    , "CC"},				-- Dark Smash
{59709    , "CC"},				-- Dark Smash
{43936    , "CC"},				-- Knockdown Spin
{42972    , "CC"},				-- Blind
{37578    , "CC"},				-- Debilitating Strike (physical damage done reduced by 75%)
{42740    , "Immune"},			-- Njord's Rune of Protection (not immune, big absorb)
{59616    , "Immune"},			-- Njord's Rune of Protection (not immune, big absorb)
{43650    , "Other"},				-- Debilitate
{59577    , "Other"},				-- Debilitate
},
{"Utgarde Pinnacle",
{48267    , "CC"},				-- Ritual Preparation
{48278    , "CC"},				-- Paralyze
{50234    , "CC"},				-- Crush
{59330    , "CC"},				-- Crush
{51750    , "CC"},				-- Screams of the Dead
{48131    , "CC"},				-- Stomp
{48144    , "CC"},				-- Terrifying Roar
{49106    , "CC"},				-- Terrify
{49170    , "CC"},				-- Lycanthropy
{49172    , "Other"},				-- Wolf Spirit
{49173    , "Other"},				-- Wolf Spirit
{48703    , "CC"},				-- Fervor
{48702    , "Other"},				-- Fervor
{48871    , "Other"},				-- Aimed Shot (decreases healing received by 50%)
{59243    , "Other"},				-- Aimed Shot (decreases healing received by 50%)
{49092    , "Root"},				-- Net
{48639    , "Snare"},				-- Hamstring
},
{"The Nexus",
{47736    , "CC"},				-- Time Stop
{47731    , "CC"},				-- Critter
{47772    , "CC"},				-- Ice Nova
{56935    , "CC"},				-- Ice Nova
{60067    , "CC"},				-- Charge
{47700    , "CC"},				-- Crystal Freeze
{55041    , "CC"},				-- Freezing Trap Effect
{47781    , "CC"},				-- Spellbreaker (damage from magical spells and effects reduced by 75%)
{47854    , "CC"},				-- Frozen Prison
{47543    , "CC"},				-- Frozen Prison
{47779    , "Silence"},			-- Arcane Torrent
{56777    , "Silence"},			-- Silence
{47748    , "Immune"},			-- Rift Shield
{48082    , "Immune"},			-- Seed Pod
{47981    , "Immune"},		-- Spell Reflection
{47698    , "Root"},				-- Crystal Chains
{50997    , "Root"},				-- Crystal Chains
{57050    , "Root"},				-- Crystal Chains
{48179    , "Root"},				-- Crystallize
{61556    , "Root"},				-- Tangle
{48053    , "Snare"},				-- Ensnare
{56775    , "Snare"},				-- Frostbolt
{56837    , "Snare"},				-- Frostbolt
{12737    , "Snare"},				-- Frostbolt
},
{"The Oculus",
{49838    , "CC"},				-- Stop Time
{50731    , "CC"},				-- Mace Smash
{50053    , "Immune"},			-- Centrifuge Shield
{53813    , "Immune"},			-- Arcane Shield
{50240    , "Immune"},			-- Evasive Maneuvers
{51162    , "Immune"},		-- Planar Shift
{50690    , "Root"},				-- Immobilizing Field
{59260    , "Root"},				-- Hooked Net
{51170    , "Other"},				-- Enraged Assault
{50253    , "Other"},				-- Martyr (harmful spells redirected to you)
{59370    , "Snare"},				-- Thundering Stomp
{49549    , "Snare"},				-- Ice Beam
{59211    , "Snare"},				-- Ice Beam
{59217    , "Snare"},				-- Thunderclap
{59261    , "Snare"},				-- Water Tomb
{50721    , "Snare"},				-- Frostbolt
{59280    , "Snare"},				-- Frostbolt
},
{"Drak Tharon Keep",
{49356    , "CC"},				-- Decay Flesh
{53463    , "CC"},				-- Return Flesh
{51240    , "CC"},				-- Fear
{49704    , "Root"},				-- Encasing Webs
{49711    , "Root"},				-- Hooked Net
{49721    , "Silence"},			-- Deafening Roar
{59010    , "Silence"},			-- Deafening Roar
{47346    , "Snare"},				-- Arcane Field
{49037    , "Snare"},				-- Frostbolt
{50378    , "Snare"},				-- Frostbolt
{59017    , "Snare"},				-- Frostbolt
{59855    , "Snare"},				-- Frostbolt
{50379    , "Snare"},				-- Cripple
},
{"Gundrak",
{55142    , "CC"},				-- Ground Tremor
{55101    , "CC"},				-- Quake
{55636    , "CC"},				-- Shockwave
{58977    , "CC"},				-- Shockwave
{55099    , "CC"},				-- Snake Wrap
{61475    , "CC"},				-- Snake Wrap
{55126    , "CC"},				-- Snake Wrap
{61476    , "CC"},				-- Snake Wrap
{54956    , "CC"},				-- Impaling Charge
{59827    , "CC"},				-- Impaling Charge
{55663    , "Silence"},			-- Deafening Roar
{58992    , "Silence"},			-- Deafening Roar
{55633    , "Root"},				-- Body of Stone
{54716    , "Other"},				-- Mortal Strikes (healing effects reduced by 50%)
{59455    , "Other"},				-- Mortal Strikes (healing effects reduced by 75%)
{55816    , "Other"},				-- Eck Berserk
{40546    , "Other"},				-- Retaliation
{61362    , "Snare"},				-- Blast Wave
{55250    , "Snare"},				-- Whirling Slash
{59824    , "Snare"},				-- Whirling Slash
{58975    , "Snare"},				-- Thunderclap
},
{"Halls of Stone",
{50812    , "CC"},				-- Stoned
{50760    , "CC"},				-- Shock of Sorrow
{59726    , "CC"},				-- Shock of Sorrow
{59865    , "CC"},				-- Ground Smash
{51503    , "CC"},				-- Domination
{51842    , "CC"},				-- Charge
{59040    , "CC"},				-- Charge
{51491    , "CC"},				-- Unrelenting Strike
{59039    , "CC"},				-- Unrelenting Strike
{59868    , "Snare"},				-- Dark Matter
{50836    , "Snare"},				-- Petrifying Grip
},
{"Halls of Lightning",
{53045    , "CC"},				-- Sleep
{59165    , "CC"},				-- Sleep
{59142    , "CC"},				-- Shield Slam
{60236    , "CC"},				-- Cyclone
{36096    , "Immune"},		-- Spell Reflection
{53069    , "Root"},				-- Runic Focus
{59153    , "Root"},				-- Runic Focus
{61579    , "Root"},				-- Runic Focus
{61596    , "Root"},				-- Runic Focus
{52883    , "Root"},				-- Counterattack
{59181    , "Other"},				-- Deflection (parry chance increased by 40%)
{52773    , "Snare"},				-- Hammer Blow
{23600    , "Snare"},				-- Piercing Howl
{23113    , "Snare"},				-- Blast Wave
},
{"Trial of the Champion",
{67745    , "CC"},				-- Death's Respite
{66940    , "CC"},				-- Hammer of Justice
{66862    , "CC"},				-- Radiance
{66547    , "CC"},				-- Confess
{66546    , "CC"},				-- Holy Nova
{65918    , "CC"},				-- Stunned
{67867    , "CC"},				-- Trampled
{67868    , "CC"},				-- Trampled
{67255    , "CC"},				-- Final Meditation (movement, attack, and casting speeds reduced by 70%)
{67229    , "CC"},				-- Mind Control
{66043    , "CC"},				-- Polymorph
{66619    , "CC"},				-- Shadows of the Past (attack and casting speeds reduced by 90%)
{66552    , "CC"},				-- Waking Nightmare
{67541    , "Immune"},			-- Bladestorm (not immune to dmg, only to LoC)
{66515    , "Immune"},			-- Reflective Shield
{67251    , "Immune"},			-- Divine Shield
{67534    , "Other"},				-- Hex of Mending (direct heals received will heal all nearby enemies)
{67542    , "Other"},				-- Mortal Strike (healing effects reduced by 50%)
{66045    , "Other"},				-- Haste
{67781    , "Snare"},				-- Desecration
{66044    , "Snare"},				-- Blast Wave
},
{"The Forge of Souls",
{68950    , "CC"},				-- Fear
{68848    , "CC"},				-- Knockdown Stun
{69133    , "CC"},				-- Lethargy
{69056    , "Immune"},		-- Shroud of Runes
{69060    , "Root"},				-- Frost Nova
{68839    , "Other"},				-- Corrupt Soul
{69131    , "Other"},				-- Soul Sickness
{69633    , "Other"},				-- Veil of Shadow
{68921    , "Snare"},				-- Soulstorm
},
{"Pit of Saron",
{68771    , "CC"},				-- Thundering Stomp
{70380    , "CC"},				-- Deep Freeze
{69245    , "CC"},				-- Hoarfrost
{69503    , "CC"},				-- Devour Humanoid
{70302    , "CC"},				-- Blinding Dirt
{69572    , "CC"},				-- Shovelled!
{70639    , "CC"},				-- Call of Sylvanas
{70291    , "Disarm"},			-- Frostblade
{69575    , "Immune"},			-- Stoneform (not immune, damage taken reduced by 90%)
{70130    , "Root"},				-- Empowered Blizzard
{69580    , "Other"},				-- Shield Block (chance to block increased by 100%)
{69029    , "Other"},				-- Pursuit Confusion
{69167    , "Other"},				-- Unholy Power
{69172    , "Other"},				-- Overlord's Brand
{70381    , "Snare"},				-- Deep Freeze
{69238    , "Snare"},				-- Icy Blast
{71380    , "Snare"},				-- Icy Blast
{69573    , "Snare"},				-- Frostbolt
{69413    , "Silence"},			-- Strangulating
{70569    , "Silence"},			-- Strangulating
{70616    , "Snare"},				-- Frostfire Bolt
{51779    , "Snare"},				-- Frostfire Bolt
{34779    , "Root"},				-- Freezing Circle
{22645    , "Root"},				-- Frost Nova
{22746    , "Snare"},				-- Cone of Cold
},
{"Halls of Reflection",
{72435    , "CC"},				-- Defiling Horror
{72428    , "CC"},				-- Despair Stricken
{72321    , "CC"},				-- Cower in Fear
{70194    , "CC"},				-- Dark Binding
{69708    , "CC"},				-- Ice Prison
{72343    , "CC"},				-- Hallucination
{72335    , "CC"},				-- Kidney Shot
{72268    , "CC"},				-- Ice Shot
{69866    , "CC"},				-- Harvest Soul
{72171    , "Root"},				-- Chains of Ice
{69787    , "Immune"},			-- Ice Barrier (not immune, absorbs a lot of damage)
{70188    , "Immune"},			-- Cloak of Darkness
{69780    , "Snare"},				-- Remorseless Winter
{72166    , "Snare"},				-- Frostbolt
},
  ------------------------
  ---- PVE TBC
  ------------------------
{"Karazhan Raid",
  -- -- Trash
  {18812  , "CC"},				-- Knockdown
  {29684  , "CC"},				-- Shield Slam
  {29679  , "CC"},				-- Bad Poetry
  {29676  , "CC"},				-- Rolling Pin
  {29490  , "CC"},				-- Seduction
  {29300  , "CC"},				-- Sonic Blast
  {29321  , "CC"},				-- Fear
  {29546  , "CC"},				-- Oath of Fealty
  {29670  , "CC"},				-- Ice Tomb
  {29690  , "CC"},				-- Drunken Skull Crack
  {37498  , "CC"},				-- Stomp (physical damage done reduced by 50%)
  {41580  , "Root"},				-- Net
  {29505  , "Silence"},			-- Banshee Shriek
  {30013  , "Disarm"},			-- Disarm
  --{30019  , "CC"},				-- Control Piece
  --{39331  , "Silence"},			-- Game In Session

  -- -- Servant Quarters
  {29896  , "CC"},				-- Hyakiss' Web
  {29904  , "Silence"},			-- Sonic Burst
  -- -- Attumen the Huntsman
  {29711  , "CC"},				-- Knockdown
  {29833  , "CC"},				-- Intangible Presence (chance to hit with spells and melee attacks reduced by 50%)
  -- -- Moroes
  {29425  , "CC"},				-- Gouge
  {34694  , "CC"},				-- Blind
  -- -- Maiden of Virtue
  {29511  , "CC"},				-- Repentance
  {29512  , "Silence"},			-- Holy Ground
  -- -- Opera Event
  {31046  , "CC"},				-- Brain Bash
  {30889  , "CC"},				-- Powerful Attraction
  {30761  , "CC"},				-- Wide Swipe
  {31013  , "CC"},				-- Frightened Scream
  {30752  , "CC"},				-- Terrifying Howl
  {31075  , "CC"},				-- Burning Straw
  {30753  , "CC"},				-- Red Riding Hood
  {30756  , "CC"},				-- Little Red Riding Hood
  {31015  , "CC"},				-- Annoying Yipping
  {31069  , "Silence"},			-- Brain Wipe
  -- -- The Curator
  {30254  , "CC"},				-- Evocation
  -- -- Terestian Illhoof
  {30115  , "CC"},				-- Sacrifice
  -- -- Shade of Aran
  {29964  , "CC"},				-- Dragon's Breath
  {29963  , "CC"},				-- Mass Polymorph
  {29991  , "Root"},				-- Chains of Ice

  -- -- Nightbane
  {36922  , "CC"},				-- Bellowing Roar
  {30130  , "CC"},				-- Distracting Ash (chance to hit with attacks}, spells and abilities reduced by 30%)
  -- -- Prince Malchezaar
},
  ------------------------
{"Gruul's Lair Raid",
  -- -- Trash
  {33709  , "CC"},				-- Charge
  -- -- High King Maulgar & Council
  {33173  , "CC"},				-- Greater Polymorph
  {33130  , "CC"},				-- Death Coil
  {33175  , "Disarm"},			-- Arcane Shock
  -- -- Gruul the Dragonkiller
  {33652  , "CC"},				-- Stoned
  {36297  , "Silence"},			-- Reverberation
  ------------------------
  -- -- Magtheridon’s Lair Raid
  -- -- Trash
  {34437  , "CC"},				-- Death Coil
  --{31117  , "Silence"},			-- Unstable Affliction
  -- -- Magtheridon
  {30530  , "CC"},				-- Fear
  {30168  , "CC"},				-- Shadow Cage
  {30205  , "CC"},				-- Shadow Cage
},
  ------------------------
{"Serpentshrine Cavern Raid",
  -- -- Trash
  {38945  , "CC"},				-- Frightening Shout
  {38946  , "CC"},				-- Frightening Shout
  {38626  , "CC"},				-- Domination
  {39002  , "CC"},				-- Spore Quake Knockdown
  {38661  , "Root"},				-- Net
  {39035  , "Root"},				-- Frost Nova
  {39063  , "Root"},				-- Frost Nova
  {38634  , "Silence"},			-- Arcane Lightning
  {38491  , "Silence"},			-- Silence

  -- -- Hydross the Unstable
  {38246  , "CC"},				-- Vile Sludge (damage and healing dealt is reduced by 50%)
  -- -- Leotheras the Blind
  {37749  , "CC"},				-- Consuming Madness
  -- -- Fathom-Lord Karathress
  {38441  , "CC"},				-- Cataclysmic Bolt
  -- -- Morogrim Tidewalker
  {37871  , "CC"},				-- Freeze
  {37850  , "CC"},				-- Watery Grave
  {38023  , "CC"},				-- Watery Grave
  {38024  , "CC"},				-- Watery Grave
  {38025  , "CC"},				-- Watery Grave
  {38049  , "CC"},				-- Watery Grave
  -- -- Lady Vashj
  {38509  , "CC"},				-- Shock Blast
  {38511  , "CC"},				-- Persuasion
  {38258  , "CC"},				-- Panic
  {38316  , "Root"},				-- Entangle
  {38132  , "Root"},				-- Paralyze (Tainted Core item)
},
  ------------------------
{"The Eye (Tempest Keep) Raid",
  -- -- Trash
  {34937  , "CC"},				-- Powered Down
  {37122  , "CC"},				-- Domination
  {37135  , "CC"},				-- Domination
  {37118  , "CC"},				-- Shell Shock
  {39077  , "CC"},				-- Hammer of Justice
  {37160  , "Silence"},			-- Silence

  -- -- Void Reaver
  {34190  , "Silence"},			-- Arcane Orb
  -- -- Kael'thas
  {36834  , "CC"},				-- Arcane Disruption
  {37018  , "CC"},				-- Conflagration
  {44863  , "CC"},				-- Bellowing Roar
  {36797  , "CC"},				-- Mind Control
  {37029  , "CC"},				-- Remote Toy
  {36989  , "Root"},				-- Frost Nova

},
  ------------------------
{"Black Temple Raid",
  -- -- Trash
  {41345  , "CC"},				-- Infatuation
  {39645  , "CC"},				-- Shadow Inferno
  {41150  , "CC"},				-- Fear
  {39574  , "CC"},				-- Charge
  {39674  , "CC"},				-- Banish
  {40936  , "CC"},				-- War Stomp
  {41197  , "CC"},				-- Shield Bash
  {41272  , "CC"},				-- Behemoth Charge
  {41274  , "CC"},				-- Fel Stomp
  {41338  , "CC"},				-- Love Tap
  {41396  , "CC"},				-- Sleep
  {41356  , "CC"},				-- Chest Pains
  {41213  , "CC"},				-- Throw Shield
  {40864  , "CC"},				-- Throbbing Stun
  {41334  , "CC"},				-- Polymorph
  {40099  , "CC"},				-- Vile Slime (damage and healing dealt reduced by 50%)
  {40079  , "CC"},				-- Debilitating Spray (damage and healing dealt reduced by 50%)
  {39584  , "Root"},				-- Sweeping Wing Clip
  {40082  , "Root"},				-- Hooked Net
  {41086  , "Root"},				-- Ice Trap

  {41062  , "Disarm"},			-- Disarm
  {36139  , "Disarm"},			-- Disarm
  {41084  , "Silence"},			-- Silencing Shot
  {41168  , "Silence"},			-- Sonic Strike
  -- -- High Warlord Naj'entus
  {39837  , "CC"},				-- Impaling Spine
  -- -- Supremus
  -- -- Shade of Akama
  {41179  , "CC"},				-- Debilitating Strike (physical damage done reduced by 75%)
  -- -- Teron Gorefiend
  {40175  , "CC"},				-- Spirit Chains
  -- -- Gurtogg Bloodboil
  {40597  , "CC"},				-- Eject
  {40491  , "CC"},				-- Bewildering Strike
  {40569  , "Root"},				-- Fel Geyser
  {40591  , "CC"},				-- Fel Geyser
  -- -- Reliquary of the Lost
  {41426  , "CC"},				-- Spirit Shock
  -- -- Mother Shahraz
  {40823  , "Silence"},			-- Silencing Shriek
  -- -- The Illidari Council
  {41468  , "CC"},				-- Hammer of Justice
  {41479  , "CC"},				-- Vanish
  -- -- Illidan
  {40647  , "CC"},				-- Shadow Prison
  {41083  , "CC"},				-- Paralyze
  {40620  , "CC"},				-- Eyebeam
  {40695  , "CC"},				-- Caged
  {40760  , "CC"},				-- Cage Trap
  {41218  , "CC"},				-- Death
  {41220  , "CC"},				-- Death
  {41221  , "CC"},				-- Teleport Maiev
},
  ------------------------
{"Hyjal Summit Raid",
  -- -- Trash
  {31755  , "CC"},				-- War Stomp
  {31610  , "CC"},				-- Knockdown
  {31537  , "CC"},				-- Cannibalize
  {31302  , "CC"},				-- Inferno Effect
  {31651  , "CC"},				-- Banshee Curse (chance to hit reduced by 66%)
  {42201  , "Silence"},			-- Eternal Silence
  {42205  , "Silence"},			-- Residue of Eternity

  -- -- Rage Winterchill
  {31249  , "CC"},				-- Icebolt
  {31250  , "Root"},				-- Frost Nova
  -- -- Anetheron
  {31298  , "CC"},				-- Sleep
  -- -- Kaz'rogal
  {31480  , "CC"},				-- War Stomp
  -- -- Azgalor
  {31344  , "Silence"},			-- Howl of Azgalor
  -- -- Archimonde
  {31970  , "CC"},				-- Fear
  {32053  , "Silence"},			-- Soul Charge
  },
  ------------------------
  {"Zul'Aman Raid",
  -- -- Trash
  {43356  , "CC"},				-- Pounce
  {43361  , "CC"},				-- Domesticate
  {42220  , "CC"},				-- Conflagration
  {35011  , "CC"},				-- Knockdown
  {43362  , "Root"},				-- Electrified Net

  -- -- Akil'zon
  {43648  , "CC"},				-- Electrical Storm
  -- -- Nalorakk
  {42398  , "Silence"},			-- Deafening Roar
  -- -- Hex Lord Malacrass
  {43590  , "CC"},				-- Psychic Wail
  -- -- Daakara
  {43437  , "CC"},				-- Paralyzed
  },
  ------------------------
{"Sunwell Plateau Raid",
  -- -- Trash
  {46762  , "CC"},				-- Shield Slam
  {46288  , "CC"},				-- Petrify
  {46239  , "CC"},				-- Bear Down
  {46561  , "CC"},				-- Fear
  {46427  , "CC"},				-- Domination
  {46280  , "CC"},				-- Polymorph
  {46295  , "CC"},				-- Hex
  {46681  , "CC"},				-- Scatter Shot
  {45029  , "CC"},				-- Corrupting Strike
  {44872  , "CC"},				-- Frost Blast
  {45201  , "CC"},				-- Frost Blast
  {45203  , "CC"},				-- Frost Blast
  {46555  , "Root"},				-- Frost Nova

  -- -- Kalecgos & Sathrovarr
  {45066  , "CC"},				-- Self Stun
  {45002  , "CC"},				-- Wild Magic (chance to hit with melee and ranged attacks reduced by 50%)
  {45122  , "CC"},				-- Tail Lash
  -- -- Felmyst
  {46411  , "CC"},				-- Fog of Corruption
  {45717  , "CC"},				-- Fog of Corruption
  -- -- Grand Warlock Alythess & Lady Sacrolash
  {45256  , "CC"},				-- Confounding Blow
  {45342  , "CC"},				-- Conflagration
  -- -- M'uru
  {46102  , "Root"},				-- Spell Fury

  -- -- Kil'jaeden
  {37369  , "CC"},				-- Hammer of Justice
},
  ------------------------
  ------------------------
  -- TBC Dungeons
{"Hellfire Ramparts",
  {39427  , "CC"},				-- Bellowing Roar
  {30615  , "CC"},				-- Fear
  {30621  , "CC"},				-- Kidney Shot

  },
{"The Blood Furnace",
  {30923  , "CC"},				-- Domination
  {31865  , "CC"},				-- Seduction

  },
{"The Shattered Halls",
  {30500  , "CC"},				-- Death Coil
  {30741  , "CC"},				-- Death Coil
  {30584  , "CC"},				-- Fear
  {37511  , "CC"},				-- Charge
  {23601  , "CC"},				-- Scatter Shot
  {30980  , "CC"},				-- Sap
  {30986  , "CC"},				-- Cheap Shot
  },
{"The Slave Pens",
  {34984  , "CC"},				-- Psychic Horror
  {32173  , "Root"},				-- Entangling Roots
  {31983  , "Root"},				-- Earthgrab
  {32192  , "Root"},				-- Frost Nova
  },
{"The Underbog",
  {31428  , "CC"},				-- Sneeze
  {31932  , "CC"},				-- Freezing Trap Effect
  {35229  , "CC"},				-- Sporeskin (chance to hit with attacks}, spells and abilities reduced by 35%)
  {31673  , "Root"},				-- Foul Spores
  },
{"The Steamvault",
  {31718  , "CC"},				-- Enveloping Winds
  {38660  , "CC"},				-- Fear
  {35107  , "Root"},				-- Electrified Net
  },
{"Mana-Tombs",
  {32361  , "CC"},				-- Crystal Prison
  {34322  , "CC"},				-- Psychic Scream
  {33919  , "CC"},				-- Earthquake
  {34940  , "CC"},				-- Gouge
  {32365  , "Root"},				-- Frost Nova
  {34922  , "Silence"},			-- Shadows Embrace
  },
{"Auchenai Crypts",
  {32421  , "CC"},				-- Soul Scream
  {32830  , "CC"},				-- Possess
  {32859  , "Root"},				-- Falter
  {33401  , "Root"},				-- Possess
  {32346  , "CC"},				-- Stolen Soul (damage and healing done reduced by 50%)
  },
{"Sethekk Halls",
  {40305  , "CC"},				-- Power Burn
  {40184  , "CC"},				-- Paralyzing Screech
  {43309  , "CC"},				-- Polymorph
  {38245  , "CC"},				-- Polymorph
  {40321  , "CC"},				-- Cyclone of Feathers
  {35120  , "CC"},				-- Charm
  {32654  , "CC"},				-- Talon of Justice
  {32690  , "Silence"},			-- Arcane Lightning
  {38146  , "Silence"},			-- Arcane Lightning
  },
{"Shadow Labyrinth",
  {33547  , "CC"},				-- Fear
  {38791  , "CC"},				-- Banish
  {33563  , "CC"},				-- Draw Shadows
  {33684  , "CC"},				-- Incite Chaos
  {33502  , "CC"},				-- Brain Wash
  {33332  , "CC"},				-- Suppression Blast
  {33686  , "Silence"},			-- Shockwave
  {33499  , "Silence"},			-- Shape of the Beast
  },
{"Old Hillsbrad Foothills",
  {33789  , "CC"},				-- Frightening Shout
  {50733  , "CC"},				-- Scatter Shot
  {32890  , "CC"},				-- Knockout
  {32864  , "CC"},				-- Kidney Shot
  {41389  , "CC"},				-- Kidney Shot
  {50762  , "Root"},				-- Net
  {12024  , "Root"},				-- Net
  },
{"The Black Morass",
  {31422  , "CC"},				-- Time Stop
  },
{"The Mechanar",
  {35250  , "CC"},				-- Dragon's Breath
  {35326  , "CC"},				-- Hammer Punch
  {35280  , "CC"},				-- Domination
  {35049  , "CC"},				-- Pound
  {35783  , "CC"},				-- Knockdown
  {36333  , "CC"},				-- Anesthetic
  {35268  , "CC"},				-- Inferno
  {36022  , "Silence"},			-- Arcane Torrent
  {35055  , "Disarm"},			-- The Claw
  },
{"The Arcatraz",
  {36924  , "CC"},				-- Mind Rend
  {39017  , "CC"},				-- Mind Rend
  {39415  , "CC"},				-- Fear
  {37162  , "CC"},				-- Domination
  {36866  , "CC"},				-- Domination
  {39019  , "CC"},				-- Complete Domination
  {38850  , "CC"},				-- Deafening Roar
  {36887  , "CC"},				-- Deafening Roar
  {36700  , "CC"},				-- Hex
  {36840  , "CC"},				-- Polymorph
  {38896  , "CC"},				-- Polymorph
  {36634  , "CC"},				-- Emergence
  {36719  , "CC"},				-- Explode
  {38830  , "CC"},				-- Explode
  {36835  , "CC"},				-- War Stomp
  {38911  , "CC"},				-- War Stomp
  {36862  , "CC"},				-- Gouge
  {36778  , "CC"},				-- Soul Steal (physical damage done reduced by 45%)
  {35963  , "Root"},				-- Improved Wing Clip
  {36512  , "Root"},				-- Knock Away
  {36827  , "Root"},				-- Hooked Net
  {38912  , "Root"},				-- Hooked Net
  {37480  , "Root"},				-- Bind
  {38900  , "Root"},				-- Bind
  },
{"The Botanica",
  {34716  , "CC"},				-- Stomp
  {34661  , "CC"},				-- Sacrifice
  {32323  , "CC"},				-- Charge
  {34639  , "CC"},				-- Polymorph
  {34752  , "CC"},				-- Freezing Touch
  {34770  , "CC"},				-- Plant Spawn Effect
  {34801  , "CC"},				-- Sleep
  {22127  , "Root"},				-- Entangling Roots
  },
{"Magisters' Terrace",
  {47109  , "CC"},				-- Power Feedback
  {44233  , "CC"},				-- Power Feedback
  {46183  , "CC"},				-- Knockdown
  {46026  , "CC"},				-- War Stomp
  {46024  , "CC"},				-- Fel Iron Bomb
  {46184  , "CC"},				-- Fel Iron Bomb
  {44352  , "CC"},				-- Overload
  {38595  , "CC"},				-- Fear
  {44320  , "CC"},				-- Mana Rage
  {44547  , "CC"},				-- Deadly Embrace
  {44765  , "CC"},				-- Banish
  {44177  , "Root"},				-- Frost Nova
  {47168  , "Root"},				-- Improved Wing Clip
  {46182  , "Silence"},			-- Snap Kick
  },

  ------------------------
  ---- PVE CLASSIC
  ------------------------
{"Molten Core Raid",
  -- -- Trash
  {19364  , "CC"},				-- Ground Stomp
  {19369  , "CC"},				-- Ancient Despair
  {19641  , "CC"},				-- Pyroclast Barrage
  {20276  , "CC"},				-- Knockdown
  {19393  , "Silence"},			-- Soul Burn
  {19636  , "Root"},				-- Fire Blossom
  -- -- Lucifron
  {20604  , "CC"},				-- Dominate Mind
  -- -- Magmadar
  {19408  , "CC"},				-- Panic
  -- -- Gehennas
  {20277  , "CC"},				-- Fist of Ragnaros
  -- -- Garr
  -- -- Shazzrah
  -- -- Baron Geddon
  {19695  , "CC"},				-- Inferno
  {20478  , "CC"},				-- Armageddon
  -- -- Golemagg the Incinerator
  -- -- Sulfuron Harbinger
  {19780  , "CC"},				-- Hand of Ragnaros
  -- -- Majordomo Executus
  },
  ------------------------
{"Onyxia's Lair Raid",
  -- -- Onyxia
  {18431  , "CC"},				-- Bellowing Roar
  ------------------------
  -- Blackwing Lair Raid
  -- -- Trash
  {24375  , "CC"},				-- War Stomp
  {22289  , "CC"},				-- Brood Power: Green
  {22291  , "CC"},				-- Brood Power: Bronze
  {22561  , "CC"},				-- Brood Power: Green
  -- -- Razorgore the Untamed
  {19872  , "CC"},				-- Calm Dragonkin
  {23023  , "CC"},				-- Conflagration
  {15593  , "CC"},				-- War Stomp
  {16740  , "CC"},				-- War Stomp
  {28725  , "CC"},				-- War Stomp
  {14515  , "CC"},				-- Dominate Mind
  {22274  , "CC"},				-- Greater Polymorph
  -- -- Broodlord Lashlayer
  -- -- Chromaggus
  {23310  , "CC"},				-- Time Lapse
  {23312  , "CC"},				-- Time Lapse
  {23174  , "CC"},				-- Chromatic Mutation
  {23171  , "CC"},				-- Time Stop (Brood Affliction: Bronze)
  -- -- Nefarian
  {22666  , "Silence"},			-- Silence
  {22667  , "CC"},				-- Shadow Command
  {22686  , "CC"},				-- Bellowing Roar
  {22678  , "CC"},				-- Fear
  {23603  , "CC"},				-- Wild Polymorph
  {23364  , "CC"},				-- Tail Lash
  {23365  , "Disarm"},			-- Dropped Weapon
  {23414  , "Root"},				-- Paralyze
  },
  ------------------------
{"Zul'Gurub Raid",
  -- -- Trash
  {24619  , "Silence"},			-- Soul Tap
  {24048  , "CC"},				-- Whirling Trip
  {24600  , "CC"},				-- Web Spin
  {24335  , "CC"},				-- Wyvern Sting
  {24020  , "CC"},				-- Axe Flurry
  {24671  , "CC"},				-- Snap Kick
  {24333  , "CC"},				-- Ravage
  {6869   , "CC"},				-- Fall down
  {24053  , "CC"},				-- Hex
  -- -- High Priestess Jeklik
  {23918  , "Silence"},			-- Sonic Burst
  {22884  , "CC"},				-- Psychic Scream
  {22911  , "CC"},				-- Charge
  {23919  , "CC"},				-- Swoop
  {26044  , "CC"},				-- Mind Flay
  -- -- High Priestess Mar'li
  {24110  , "Silence"},			-- Enveloping Webs
  -- -- High Priest Thekal
  {21060  , "CC"},				-- Blind
  {12540  , "CC"},				-- Gouge
  {24193  , "CC"},				-- Charge
  -- -- Bloodlord Mandokir & Ohgan
  {24408  , "CC"},				-- Charge
  -- -- Gahz'ranka
  -- -- Jin'do the Hexxer
  {17172  , "CC"},				-- Hex
  {24261  , "CC"},				-- Brain Wash
  -- -- Edge of Madness: Gri'lek}, Hazza'rah}, Renataki}, Wushoolay
  {24648  , "Root"},				-- Entangling Roots
  {24664  , "CC"},				-- Sleep
  -- -- Hakkar
  {24687  , "Silence"},			-- Aspect of Jeklik
  {24686  , "CC"},				-- Aspect of Mar'li
  {24690  , "CC"},				-- Aspect of Arlokk
  {24327  , "CC"},				-- Cause Insanity
  {24178  , "CC"},				-- Will of Hakkar
  {24322  , "CC"},				-- Blood Siphon
  {24323  , "CC"},				-- Blood Siphon
  {24324  , "CC"},				-- Blood Siphon
  },
  ------------------------
{"Ruins of Ahn'Qiraj Raid",
  -- -- Trash
  {25371  , "CC"},				-- Consume
  {26196  , "CC"},				-- Consume
  {25654  , "CC"},				-- Tail Lash
  {25515  , "CC"},				-- Bash
  {25756  , "CC"},				-- Purge
  -- -- Kurinnaxx
  {25656  , "CC"},				-- Sand Trap
  -- -- General Rajaxx
  {19134  , "CC"},				-- Frightening Shout
  {29544  , "CC"},				-- Frightening Shout
  {25425  , "CC"},				-- Shockwave
  -- -- Moam
  {25685  , "CC"},				-- Energize
  {28450  , "CC"},				-- Arcane Explosion
  -- -- Ayamiss the Hunter
  {25852  , "CC"},				-- Lash
  {6608   , "Disarm"},			-- Dropped Weapon
  {25725  , "CC"},				-- Paralyze
  -- -- Ossirian the Unscarred
  {25189  , "CC"},				-- Enveloping Winds
  },
  ------------------------
{"Temple of Ahn'Qiraj Raid",
  -- -- Trash
  {7670   , "CC"},				-- Explode
  {18327  , "Silence"},			-- Silence
  {26069  , "Silence"},			-- Silence
  {26070  , "CC"},				-- Fear
  {26072  , "CC"},				-- Dust Cloud
  {25698  , "CC"},				-- Explode
  {26079  , "CC"},				-- Cause Insanity
  {26049  , "CC"},				-- Mana Burn
  {26552  , "CC"},				-- Nullify
  {26071  , "Root"},				-- Entangling Roots
  -- -- The Prophet Skeram
  {785    , "CC"},				-- True Fulfillment
  -- -- Bug Trio: Yauj}, Vem}, Kri
  {3242   , "CC"},				-- Ravage
  {26580  , "CC"},				-- Fear
  {19128  , "CC"},				-- Knockdown
  -- -- Fankriss the Unyielding
  {720    , "CC"},				-- Entangle
  {731    , "CC"},				-- Entangle
  {1121   , "CC"},				-- Entangle
  -- -- Viscidus
  {25937  , "CC"},				-- Viscidus Freeze
  -- -- Princess Huhuran
  {26180  , "CC"},				-- Wyvern Sting
  {26053  , "Silence"},			-- Noxious Poison
  -- -- Twin Emperors: Vek'lor & Vek'nilash
  {800    , "CC"},				-- Twin Teleport
  {804    , "Root"},				-- Explode Bug
  {12241  , "Root"},				-- Twin Colossals Teleport
  {12242  , "Root"},				-- Twin Colossals Teleport
  -- -- Ouro
  {26102  , "CC"},				-- Sand Blast
  -- -- C'Thun
  },
  ------------------------
{"Naxxramas (Classic) Raid",
  -- -- Trash
  {6605   , "CC"},				-- Terrifying Screech
  {27758  , "CC"},				-- War Stomp
  {27990  , "CC"},				-- Fear
  {28412  , "CC"},				-- Death Coil
  {29848  , "CC"},				-- Polymorph
  {29849  , "Root"},				-- Frost Nova
  {30094  , "Root"},				-- Frost Nova
  -- -- Anub'Rekhan
  {28786  , "CC"},				-- Locust Swarm
  {25821  , "CC"},				-- Charge
  {28991  , "Root"},				-- Web
  -- -- Grand Widow Faerlina
  {30225  , "Silence"},			-- Silence
  -- -- Maexxna
  {28622  , "CC"},				-- Web Wrap
  {29484  , "CC"},				-- Web Spray
  -- -- Noth the Plaguebringer
  -- -- Heigan the Unclean
  {30112  , "CC"},				-- Frenzied Dive
  -- -- Instructor Razuvious
  -- -- Gothik the Harvester
  {11428  , "CC"},				-- Knockdown
  -- -- Gluth
  {29685  , "CC"},				-- Terrifying Roar
  -- -- Sapphiron
  {28522  , "CC"},				-- Icebolt
  -- -- Kel'Thuzad
  {28410  , "CC"},				-- Chains of Kel'Thuzad
  {27808  , "CC"},				-- Frost Blast
  },
  ------------------------
{"Classic World Bosses",
  -- -- Azuregos
  {23186  , "CC"},				-- Aura of Frost
  {21099  , "CC"},				-- Frost Breath
  -- -- Doom Lord Kazzak & Highlord Kruul
  -- -- Dragons of Nightmare
  {25043  , "CC"},				-- Aura of Nature
  {24778  , "CC"},				-- Sleep (Dream Fog)
  {24811  , "CC"},				-- Draw Spirit
  {25806  , "CC"},				-- Creature of Nightmare
  {12528  , "Silence"},			-- Silence
  {23207  , "Silence"},			-- Silence
  {29943  , "Silence"},			-- Silence
  },
  ------------------------
  -- Classic Dungeons
{"Ragefire Chasm",
  {8242   , "CC"},				-- Shield Slam
  },
{"The Deadmines",
  {6304   , "CC"},				-- Rhahk'Zor Slam
  {6713   , "Disarm"},			-- Disarm
  {7399   , "CC"},				-- Terrify
  {6435   , "CC"},				-- Smite Slam
  {6432   , "CC"},				-- Smite Stomp
  {113    , "Root"},				-- Chains of Ice
  {512    , "Root"},				-- Chains of Ice
  {228    , "CC"},				-- Polymorph: Chicken
  {6466   , "CC"},				-- Axe Toss
  },
{"Wailing Caverns",
  {8040   , "CC"},				-- Druid's Slumber
  {8142   , "Root"},				-- Grasping Vines
  {5164   , "CC"},				-- Knockdown
  {7967   , "CC"},				-- Naralex's Nightmare
  {6271   , "CC"},				-- Naralex's Awakening
  {8150   , "CC"},				-- Thundercrack
  },
{"Shadowfang Keep",
  {7295   , "Root"},				-- Soul Drain
  {7587   , "Root"},				-- Shadow Port
  {7136   , "Root"},				-- Shadow Port
  {7586   , "Root"},				-- Shadow Port
  {7139   , "CC"},				-- Fel Stomp
  {13005  , "CC"},				-- Hammer of Justice
  {7621   , "CC"},				-- Arugal's Curse
  {7803   , "CC"},				-- Thundershock
  {7074   , "Silence"},			-- Screams of the Past
  },
{"Blackfathom Deeps",
  {15531  , "Root"},				-- Frost Nova
  {6533   , "Root"},				-- Net
  {8399   , "CC"},				-- Sleep
  {8379   , "Disarm"},			-- Disarm
  {8391   , "CC"},				-- Ravage
  {7645   , "CC"},				-- Dominate Mind
  },
{"The Stockade",
  {7964   , "CC"},				-- Smoke Bomb
  {6253   , "CC"},				-- Backhand
  },
{"Gnomeregan",
  {10737  , "CC"},				-- Hail Storm
  {15878  , "CC"},				-- Ice Blast
  {10856  , "CC"},				-- Link Dead
  {11820  , "Root"},				-- Electrified Net
  {10852  , "Root"},				-- Battle Net
  {11264  , "Root"},				-- Ice Blast
  {10730  , "CC"},				-- Pacify
  },
{"Razorfen Kraul",
  {8281   , "Silence"},			-- Sonic Burst
  {8359   , "CC"},				-- Left for Dead
  {8285   , "CC"},				-- Rampage
  {8377   , "Root"},				-- Earthgrab
  {6728   , "CC"},				-- Enveloping Winds
  {6524   , "CC"},				-- Ground Tremor
  },
{"Scarlet Monastery",
  {13323  , "CC"},				-- Polymorph
  {8988   , "Silence"},			-- Silence
  {9256   , "CC"},				-- Deep Sleep
  },
{"Razorfen Downs",
  {12252  , "Root"},				-- Web Spray
  {12946  , "Silence"},			-- Putrid Stench
  {745    , "Root"},				-- Web
  {12748  , "Root"},				-- Frost Nova
  },
{"Uldaman",
  {11876  , "CC"},				-- War Stomp
  {3636   , "CC"},				-- Crystalline Slumber
  --{6726   , "Silence"},			-- Silence
  {10093  , "Silence"},			-- Harsh Winds
  {25161  , "Silence"},			-- Harsh Winds
  },
{"Maraudon",
  {12747  , "Root"},				-- Entangling Roots
  {21331  , "Root"},				-- Entangling Roots
  {21909  , "Root"},				-- Dust Field
  {21808  , "CC"},				-- Summon Shardlings
  {29419  , "CC"},				-- Flash Bomb
  {22592  , "CC"},				-- Knockdown
  {21869  , "CC"},				-- Repulsive Gaze
  {16790  , "CC"},				-- Knockdown
  {21748  , "CC"},				-- Thorn Volley
  {21749  , "CC"},				-- Thorn Volley
  {11922  , "Root"},				-- Entangling Roots
  },
{"Zul'Farrak",
  {11020  , "CC"},				-- Petrify
  {22692  , "CC"},				-- Petrify
  {13704  , "CC"},				-- Psychic Scream
  {11836  , "CC"},				-- Freeze Solid
  {11641  , "CC"},				-- Hex
  },
{"The Temple of Atal'Hakkar (Sunken Temple)",
  {12888  , "CC"},				-- Cause Insanity
  {12480  , "CC"},				-- Hex of Jammal'an
  {12890  , "CC"},				-- Deep Slumber
  {6607   , "CC"},				-- Lash
  {33126  , "Disarm"},			-- Dropped Weapon
  {25774  , "CC"},				-- Mind Shatter
  },
{"Blackrock Depths",
  {8994   , "CC"},				-- Banish
  {12674  , "Root"},				-- Frost Nova
  {15471  , "Silence"},			-- Enveloping Web
  {3609   , "CC"},				-- Paralyzing Poison
  {15474  , "Root"},				-- Web Explosion
  {17492  , "CC"},				-- Hand of Thaurissan
  {14030  , "Root"},				-- Hooked Net
  {14870  , "CC"},				-- Drunken Stupor
  {13902  , "CC"},				-- Fist of Ragnaros
  {15063  , "Root"},				-- Frost Nova
  {6945   , "CC"},				-- Chest Pains
  {3551   , "CC"},				-- Skull Crack
  {15621  , "CC"},				-- Skull Crack
  {11831  , "Root"},				-- Frost Nova
  },
{"Blackrock Spire",
  {16097  , "CC"},				-- Hex
  {22566  , "CC"},				-- Hex
  {15618  , "CC"},				-- Snap Kick
  {16075  , "CC"},				-- Throw Axe
  {16045  , "CC"},				-- Encage
  {16104  , "CC"},				-- Crystallize
  {16508  , "CC"},				-- Intimidating Roar
  {15609  , "Root"},				-- Hooked Net
  {16497  , "CC"},				-- Stun Bomb
  {5276   , "CC"},				-- Freeze
  {18763  , "CC"},				-- Freeze
  {16805  , "CC"},				-- Conflagration
  {13579  , "CC"},				-- Gouge
  {24698  , "CC"},				-- Gouge
  {28456  , "CC"},				-- Gouge
  {16469  , "Root"},				-- Web Explosion
  {15532  , "Root"},				-- Frost Nova
  },
{"Stratholme",
  {17398  , "CC"},				-- Balnazzar Transform Stun
  {17405  , "CC"},				-- Domination
  {17246  , "CC"},				-- Possessed
  {19832  , "CC"},				-- Possess
  {15655  , "CC"},				-- Shield Slam
  {16798  , "CC"},				-- Enchanting Lullaby
  {12542  , "CC"},				-- Fear
  {12734  , "CC"},				-- Ground Smash
  {17293  , "CC"},				-- Burning Winds
  {4962   , "Root"},				-- Encasing Webs
  {16869  , "CC"},				-- Ice Tomb
  {17244  , "CC"},				-- Possess
  {17307  , "CC"},				-- Knockout
  {15970  , "CC"},				-- Sleep
  {3589   , "Silence"},			-- Deafening Screech
  },
{"Dire Maul",
  {27553  , "CC"},				-- Maul
  {22651  , "CC"},				-- Sacrifice
  {22419  , "Disarm"},			-- Riptide
  {22691  , "Disarm"},			-- Disarm
  {22833  , "CC"},				-- Booze Spit (chance to hit reduced by 75%)
  {22856  , "CC"},				-- Ice Lock
  {16727  , "CC"},				-- War Stomp
  {22994  , "Root"},				-- Entangle
  {22924  , "Root"},				-- Grasping Vines
  {22915  , "CC"},				-- Improved Concussive Shot
  {28858  , "Root"},				-- Entangling Roots
  {22415  , "Root"},				-- Entangling Roots
  {22744  , "Root"},				-- Chains of Ice
  {16838  , "Silence"},			-- Banshee Shriek
  {22519  , "CC"},				-- Ice Nova
  },
{"Scholomance",
  {5708   , "CC"},				-- Swoop
  {18144  , "CC"},				-- Swoop
  {18103  , "CC"},				-- Backhand
  {8208   , "CC"},				-- Backhand
  {12461  , "CC"},				-- Backhand
  {27565  , "CC"},				-- Banish
  {16350  , "CC"},				-- Freeze

  --{139 , "CC", "Renew"},

},


{"Discovered LC Spells"
},
}


L.spellsTable = spellsTable
L.spellsArenaTable = spellsArenaTable

local tabs = {
	"CC",
	"Silence",
	"RootPhyiscal_Special",
	"RootMagic_Special",
	"Root",
	"ImmunePlayer",
	"Disarm_Warning",
	"CC_Warning",
	--"Enemy_Smoke_Bomb",
	"Stealth",
	"Immune",
	"ImmuneSpell",
	"ImmunePhysical",
	"AuraMastery_Cast_Auras",
	"ROP_Vortex",
	"Disarm",
	"Haste_Reduction",
	"Dmg_Hit_Reduction",
	"Interrupt",
	"AOE_DMG_Modifiers",
	"Friendly_Smoke_Bomb",
	"AOE_Spell_Refections",
	"Trees",
	"Speed_Freedoms",
	"Freedoms",
	"Friendly_Defensives",
	"CC_Reduction",
	"Personal_Offensives",
	"Peronsal_Defensives",
	"Mana_Regen",
	"Movable_Cast_Auras",

	"Other", --PVE only
	"PvE", --PVE only

	"SnareSpecial",
	"SnarePhysical70",
	"SnareMagic70",
	"SnarePhysical50",
	"SnarePosion50",
	"SnareMagic50",
	"SnarePhysical30",
	"SnareMagic30",
	"Snare",
}

local defaultString = { --changes the font under LC for pLayer
	["CC"] = "CC",
	["Silence"] = "Silenced",
	["RootPhyiscal_Special"] = "Rooted",
	["RootMagic_Special"] = "Rooted",
	["Root"] = "Rooted",
	["ImmunePlayer"] = "Immune",
	["Disarm_Warning"] = "Disarm Warning",
	["CC_Warning"] = "Warning",
	--["Enemy_Smoke_Bomb"] = "SmokeBomb",
	["Stealth"] = "Stealth",
	["Immune"] = "Immune",
	["ImmuneSpell"] = "Immune",
	["ImmunePhysical"] = "Immune",
	["AuraMastery_Cast_Auras"] = "Aura Mastery",
	["ROP_Vortex"] = "Vortexed",
	["Disarm"] = "Disarmed",
	["Haste_Reduction"] = "Tongues",
	["Dmg_Hit_Reduction"] = "Hit Loss",
	["Interrupt"] = "Locked Out",
	["AOE_DMG_Modifiers"] = "Damage Amp",
	["Friendly_Smoke_Bomb"] = "SmokeBomb",
	["AOE_Spell_Refections"] = "Reflect",
	["Trees"] = "Tanking",
	["Speed_Freedoms"] = "Speed",
	["Freedoms"] = "Freedom",
	["Friendly_Defensives"] = "Defense",
	["Mana_Regen"] = "Mana Regen",
	["CC_Reduction"] = "CC Help",
	["Personal_Offensives"] = "Offense",
	["Peronsal_Defensives"] = "Defense",
	["Movable_Cast_Auras"] = "PowerUp",

	["Other"] = "Other", --PVE only
	["PvE"] = "PvE", --PVE only

	["SnareSpecial"] = "Snared",
	["SnarePhysical70"] = "Snared",
	["SnareMagic70"] = "Snared",
	["SnarePhysical50"] = "Snared",
	["SnarePosion50"] = "Snared",
	["SnareMagic50"] = "Snared",
	["SnarePhysical30"] = "Snared",
	["SnareMagic30"] = "Snared",
	["Snare"] = "Snared",
}


local tabsArena = {
	"Drink_Purge",
	"Immune_Arena",
	"CC_Arena",
	"Silence_Arena",
	"Interrupt", -- Needs to be same
	"Special_High",
	"Ranged_Major_OffenisiveCDs",
	"Roots_90_Snares",
	"Disarms",
	"Melee_Major_OffenisiveCDs",
	"Big_Defensive_CDs",
	"Player_Party_OffensiveCDs",
	"Small_Offenisive_CDs",
	"Small_Defensive_CDs",
	"Freedoms_Speed",
	"Snares_WithCDs",
	"Special_Low",
	"Snares_Ranged_Spamable",
	"Snares_Casted_Melee",
}

local tabsIndex = {}
for i = 1, #tabs do
	tabsIndex[tabs[i]] = i
end
local tabsArenaIndex = {}
for i = 1, #tabsArena do
	tabsArenaIndex[tabsArena[i]] = i
end


-------------------------------------------------------------------------------
-- Global references for attaching icons to various unit frames
local anchors = {
	None = {
	}, -- empty but necessary
	BambiUI = {
		player = "PartyPlayer", --Chris
		party1 = "PartyAnchor1", --Chris
		party2 = "PartyAnchor2", --Chris
		party3 = "PartyAnchor3", --Chris
		party4 = "PartyAnchor4",
	},
	Gladius = {
		arena1      = GladiusClassIconFramearena1 or nil,
		arena2      = GladiusClassIconFramearena2 or nil,
		arena3      = GladiusClassIconFramearena3 or nil,
		arena4      = GladiusClassIconFramearena4 or nil,
		arena5      = GladiusClassIconFramearena5 or nil,
	},
  Gladdy = {
  arena1       = GladdyButtonFrame1 and GladdyButtonFrame1.classIcon or nil,
  arena2       = GladdyButtonFrame2 and GladdyButtonFrame2.classIcon or nil,
  arena3       = GladdyButtonFrame3 and GladdyButtonFrame3.classIcon or nil,
  arena4       = GladdyButtonFrame4 and GladdyButtonFrame4.classIcon or nil,
  arena5       = GladdyButtonFrame5 and GladdyButtonFrame5.classIcon or nil,
  },
	Blizzard = {
		player       = "PlayerPortrait",
		player2      = "PlayerPortrait",
		pet          = "PetPortrait",
		target       = "TargetFramePortrait",
		targettarget = "TargetFrameToTPortrait",
		focus        = "FocusFramePortrait",
		focustarget  = "FocusFrameToTPortrait",
		party1       = "PartyMemberFrame1Portrait",
		party2       = "PartyMemberFrame2Portrait",
		party3       = "PartyMemberFrame3Portrait",
		party4       = "PartyMemberFrame4Portrait",
		--party1pet    = "PartyMemberFrame1PetFramePortrait",
		--party2pet    = "PartyMemberFrame2PetFramePortrait",
		--party3pet    = "PartyMemberFrame3PetFramePortrait",
		--party4pet    = "PartyMemberFrame4PetFramePortrait",
		arena1       = "ArenaEnemyFrame1ClassPortrait",
		arena2       = "ArenaEnemyFrame2ClassPortrait",
		arena3       = "ArenaEnemyFrame3ClassPortrait",
		arena4       = "ArenaEnemyFrame4ClassPortrait",
		arena5       = "ArenaEnemyFrame5ClassPortrait"
	},
	Perl = {
		player       = "Perl_Player_PortraitFrame",
		pet          = "Perl_Player_Pet_PortraitFrame",
		target       = "Perl_Target_PortraitFrame",
		targettarget = "Perl_Target_Target_PortraitFrame",
		focus        = "Perl_Focus_PortraitFrame",
		focustarget  = "Perl_Focus_Target_PortraitFrame",
		party1       = "Perl_Party_MemberFrame1_PortraitFrame",
		party2       = "Perl_Party_MemberFrame2_PortraitFrame",
		party3       = "Perl_Party_MemberFrame3_PortraitFrame",
		party4       = "Perl_Party_MemberFrame4_PortraitFrame",
	},
	XPerl = {
		player       = "XPerl_PlayerportraitFrameportrait",
		pet          = "XPerl_Player_PetportraitFrameportrait",
		target       = "XPerl_TargetportraitFrameportrait",
		targettarget = "XPerl_TargettargetportraitFrameportrait",
		focus        = "XPerl_FocusportraitFrameportrait",
		focustarget = "XPerl_FocustargetportraitFrameportrait",
		party1       = "XPerl_party1portraitFrameportrait",
		party2       = "XPerl_party2portraitFrameportrait",
		party3       = "XPerl_party3portraitFrameportrait",
		party4       = "XPerl_party4portraitFrameportrait",
	},
	LUI = {
		player       = "oUF_LUI_player",
		pet          = "oUF_LUI_pet",
		target       = "oUF_LUI_target",
		targettarget = "oUF_LUI_targettarget",
		focus        = "oUF_LUI_focus",
		focustarget  = "oUF_LUI_focustarget",
		party1       = "oUF_LUI_partyUnitButton1",
		party2       = "oUF_LUI_partyUnitButton2",
		party3       = "oUF_LUI_partyUnitButton3",
		party4       = "oUF_LUI_partyUnitButton4",
	},
	SyncFrames = {
		arena1 = "SyncFrame1Class",
		arena2 = "SyncFrame2Class",
		arena3 = "SyncFrame3Class",
		arena4 = "SyncFrame4Class",
		arena5 = "SyncFrame5Class",
	},
	SUF = {
		player       = SUFUnitplayer and SUFUnitplayer.portrait or nil,
		pet          = SUFUnitpet and SUFUnitpet.portrait or nil,
		target       = SUFUnittarget and SUFUnittarget.portrait or nil,
		targettarget = SUFUnittargettarget and SUFUnittargettarget.portrait or nil,
		focus        = SUFUnitfocus and SUFUnitfocus.portrait or nil,
		focustarget  = SUFUnitfocustarget and SUFUnitfocustarget.portrait or nil,
		party1       = SUFHeaderpartyUnitButton1 and SUFHeaderpartyUnitButton1.portrait or nil,
		party2       = SUFHeaderpartyUnitButton2 and SUFHeaderpartyUnitButton2.portrait or nil,
		party3       = SUFHeaderpartyUnitButton3 and SUFHeaderpartyUnitButton3.portrait or nil,
		party4       = SUFHeaderpartyUnitButton4 and SUFHeaderpartyUnitButton4.portrait or nil,
		arena1       = SUFHeaderarenaUnitButton1 and SUFHeaderarenaUnitButton1.portrait or nil,
		arena2       = SUFHeaderarenaUnitButton2 and SUFHeaderarenaUnitButton2.portrait or nil,
		arena3       = SUFHeaderarenaUnitButton3 and SUFHeaderarenaUnitButton3.portrait or nil,
		arena4       = SUFHeaderarenaUnitButton4 and SUFHeaderarenaUnitButton4.portrait or nil,
		arena5       = SUFHeaderarenaUnitButton5 and SUFHeaderarenaUnitButton5.portrait or nil,
	},
	-- more to come here?
}

-------------------------------------------------------------------------------
-- Default settings
local DBdefaults = {
	EnableGladiusGloss = true, --Add option Check Box for This
	InterruptIcons = false,
	InterruptOverlay = false,
	RedSmokeBomb = true,
	lossOfControl = true,
	lossOfControlInterrupt = 1,
	lossOfControlFull  = 0,
	lossOfControlSilence = 0,
	lossOfControlDisarm = 0,
	lossOfControlRoot = 0,
	DrawSwipeSetting = 0,
	DiscoveredSpells = { },
  	customString = { },

	spellEnabled = { },
	spellEnabledArena = { },

	customSpellIds = { },
	customSpellIdsArena = { },

	version = 9.14, -- This is the settings version, not necessarily the same as the LoseControl version
	noCooldownCount = false,
	noBlizzardCooldownCount = true,
	noLossOfControlCooldown = false, --Chris Need to Test what is better
	disablePartyInBG = true,
	disableArenaInBG = true,
	disablePartyInRaid = true,
	disablePlayerTargetTarget = true,
	disableTargetTargetTarget = true,
	disablePlayerTargetPlayerTargetTarget = true,
	disableTargetDeadTargetTarget = true,
	disablePlayerFocusTarget = true,
	disableFocusFocusTarget = true,
	disablePlayerFocusPlayerFocusTarget = true,
	disableFocusDeadFocusTarget = true,
	showNPCInterruptsTarget = true,
	showNPCInterruptsFocus = true,
	showNPCInterruptsTargetTarget = true,
	showNPCInterruptsFocusTarget = true,
	duplicatePlayerPortrait = true,
	PlayerText = true,
	ArenaPlayerText = false,
	displayTypeDot = true,
	SilenceIcon = true,
	SecondaryIcon = true,
	CountTextplayer = true,
	CountTextparty = true,
	CountTextarena = true,
	priority = {		-- higher numbers have more priority; 0 = disabled
			CC = 100,
			Silence = 95,
			RootPhyiscal_Special = 90,
			RootMagic_Special = 85,
			Root = 80,
			ImmunePlayer = 75,
			Disarm_Warning = 70,
			CC_Warning = 65,
			Enemy_Smoke_Bomb = 60,
			Stealth = 55,
			Immune = 50,
			ImmuneSpell = 45,
			ImmunePhysical = 45,
			AuraMastery_Cast_Auras = 44,
			ROP_Vortex = 42,
			Disarm = 40,
			Haste_Reduction = 38,
			Dmg_Hit_Reduction = 38,
			Interrupt = 36,
			AOE_DMG_Modifiers = 34,
			Friendly_Smoke_Bomb = 32,
			AOE_Spell_Refections = 30,
			Trees = 28,
			Speed_Freedoms = 26,
			Freedoms = 24,
			Friendly_Defensives = 22,
			CC_Reduction = 18,
			Personal_Offensives = 16,
			Peronsal_Defensives = 14,
      		Mana_Regen = 10,
			Movable_Cast_Auras = 10,

			Other = 10, --PVE only
			PvE = 10, --PVE only

			SnareSpecial = 9,
			SnarePhysical70 = 8,
			SnareMagic70 = 7,
			SnarePhysical50 = 6,
			SnarePosion50 = 5,
			SnareMagic50 = 4,
			SnarePhysical30 = 3,
			SnareMagic30 = 2,
			Snare = 1,
	},
	durationType = {		-- higher numbers have more priority; 0 = disabled
			CC = false,
			Silence = false,
			RootPhyiscal_Special = false,
			RootMagic_Special = false,
			Root = true,
			ImmunePlayer = false,
			Disarm_Warning = false,
			CC_Warning = false,
			Enemy_Smoke_Bomb = false,
			Stealth = false,
			Immune = false,
			ImmuneSpell = false,
			ImmunePhysical = false,
			AuraMastery_Cast_Auras = false,
			ROP_Vortex = false,
			Disarm = false,
			Haste_Reduction = false,
			Dmg_Hit_Reduction = false,
			Interrupt = false,
			AOE_DMG_Modifiers = false,
			Friendly_Smoke_Bomb = false,
			AOE_Spell_Refections = false,
			Trees = false,
			Speed_Freedoms = false,
			Freedoms = false,
			Friendly_Defensives = false,
			Mana_Regen = false,
			CC_Reduction = false,
			Personal_Offensives = false,
			Peronsal_Defensives = false,
			Movable_Cast_Auras = false,

			Other = false,
			PvE = false,

			SnareSpecial = false,
			SnarePhysical70 = false,
			SnareMagic70 = false,
			SnarePhysical50 = true,
			SnarePosion50 = true,
			SnareMagic50 = true,
			SnarePhysical30 = true,
			SnareMagic30 = true,
			Snare = true,
	},
	priorityArena = {		-- higher numbers have more priority; 0 = disabled
			Drink_Purge = 100,
			Immune_Arena = 100,
			CC_Arena = 85,
			Silence_Arena = 80,
			Interrupt = 75, -- Needs to be same
			Special_High = 65,
			Ranged_Major_OffenisiveCDs = 60,
			Roots_90_Snares = 55,
			Disarms = 50,
			Melee_Major_OffenisiveCDs = 35,
			Big_Defensive_CDs = 35,
			Player_Party_OffensiveCDs = 25,
			Small_Offenisive_CDs = 25,
			Small_Defensive_CDs = 25,
			Freedoms_Speed = 25,
			Snares_WithCDs = 20,
			Special_Low = 15,
			Snares_Ranged_Spamable = 10,
			Snares_Casted_Melee = 5,
	},
	durationTypeArena ={
			Drink_Purge = false,
			Immune_Arena = false,
			CC_Arena = false,
			Silence_Arena = false,
			Interrupt = false, -- Needs to be same
			Special_High = false,
			Ranged_Major_OffenisiveCDs = false,
			Roots_90_Snares = false,
			Disarms = false,
			Melee_Major_OffenisiveCDs = false,
			Big_Defensive_CDs = false,
			Player_Party_OffensiveCDs = false,
			Small_Offenisive_CDs = false,
			Small_Defensive_CDs = false,
			Freedoms_Speed = false,
			Snares_WithCDs = false,
			Special_Low = false,
			Snares_Ranged_Spamable = false,
			Snares_Casted_Melee = false,
	},
	frames = {
		player = {
			enabled = true,
			size = 48, --CHRIS
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
					  	ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = false,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
					  	SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = false,
					 }
				},
				debuff ={
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
					  	ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = false,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
					  SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = false,
					 }
			},
				interrupt = {
					friendly = false
				}
			}
		},
		player2 = {
			enabled = true,
			size = 62,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
						ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = true,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
						SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = true,
					 }
				},
				debuff = {
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = true,
						Disarm_Warning = true,
						CC_Warning = true,
						Enemy_Smoke_Bomb = true,
						Stealth = true, Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = true,
						ROP_Vortex = true ,
						Disarm = true,
						Haste_Reduction = true,
						Dmg_Hit_Reduction = true,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = true,
						Mana_Regen = true,
						CC_Reduction = true,
						Personal_Offensives = true,
						Peronsal_Defensives = true,
						Movable_Cast_Auras = true,
						SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = true,
					 }
			},
				interrupt = {
					friendly = true
				}
			}
		},
		player3 = {
			enabled = true,
			size = 62,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = {
						CC = false,
						Silence = false,
						RootPhyiscal_Special = false,
						RootMagic_Special = false,
						Root = false,
						ImmunePlayer = false,
						Disarm_Warning = false,
						CC_Warning = false,
						Enemy_Smoke_Bomb = false,
						Stealth = false, Immune = false,
						ImmuneSpell = false,
						ImmunePhysical = false,
						AuraMastery_Cast_Auras = false,
						ROP_Vortex = false ,
						Disarm = false,
						Haste_Reduction = false,
						Dmg_Hit_Reduction = false,
						AOE_DMG_Modifiers = false,
						Friendly_Smoke_Bomb = false,
						AOE_Spell_Refections = false,
						Trees = false,
						Speed_Freedoms = false,
						Freedoms = false,
						Friendly_Defensives = false,
						Mana_Regen = false,
						CC_Reduction = true,
						Personal_Offensives = false,
						Peronsal_Defensives = false,
						Movable_Cast_Auras = false,
						SnareSpecial = false, SnarePhysical70 = false, SnareMagic70 = false, SnarePhysical50 = false, SnarePosion50 = false, SnareMagic50 = false, SnarePhysical30 = false, SnareMagic30  = false, Snare = false,
						PvE = false,
						Other = false,
					 }
				},
				debuff = {
					friendly = {
						CC = false,
						Silence = false,
						RootPhyiscal_Special = false,
						RootMagic_Special = false,
						Root = false,
						ImmunePlayer = false,
						Disarm_Warning = false,
						CC_Warning = false,
						Enemy_Smoke_Bomb = false,
						Stealth = false, Immune = false,
						ImmuneSpell = false,
						ImmunePhysical = false,
						AuraMastery_Cast_Auras = false,
						ROP_Vortex = false ,
						Disarm = false,
						Haste_Reduction = false,
						Dmg_Hit_Reduction = false,
						AOE_DMG_Modifiers = false,
						Friendly_Smoke_Bomb = false,
						AOE_Spell_Refections = false,
						Trees = false,
						Speed_Freedoms = false,
						Freedoms = false,
						Friendly_Defensives = false,
						Mana_Regen = false,
						CC_Reduction = true,
						Personal_Offensives = false,
						Peronsal_Defensives = false,
						Movable_Cast_Auras = false,
						SnareSpecial = false, SnarePhysical70 = false, SnareMagic70 = false, SnarePhysical50 = false, SnarePosion50 = false, SnareMagic50 = false, SnarePhysical30 = false, SnareMagic30  = false, Snare = false,
						PvE = false,
						Other = false,
					 }
			},
				interrupt = {
					friendly = false
				}
			}
		},
		pet = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,
				 }
				},
				debuff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,
				}
				},
				interrupt = {
					friendly = true
				}
			}
		},
		target = {
			enabled = true,
			size = 58,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				debuff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		targettarget = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		focus = {
			enabled = true,
			size = 58,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 },
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				debuff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		focustarget = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
			categoriesEnabled = {
				buff = {
					friendly = {CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				debuff = {
					friendly = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = { CC = true,
					Silence = true,
					RootPhyiscal_Special = true,
					RootMagic_Special = true,
					Root = true,
					ImmunePlayer = true,
					Disarm_Warning = true,
					CC_Warning = true,
					Enemy_Smoke_Bomb = true,
					Stealth = true, Immune = true,
					ImmuneSpell = true,
					ImmunePhysical = true,
					AuraMastery_Cast_Auras = true,
					ROP_Vortex = true ,
					Disarm = true,
					Haste_Reduction = true,
					Dmg_Hit_Reduction = true,
					AOE_DMG_Modifiers = true,
					Friendly_Smoke_Bomb = true,
					AOE_Spell_Refections = true,
					Trees = true,
					Speed_Freedoms = true,
					Freedoms = true,
					Friendly_Defensives = true,
					Mana_Regen = true,
					CC_Reduction = true,
					Personal_Offensives = true,
					Peronsal_Defensives = true,
					Movable_Cast_Auras = true,
					SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
					PvE = true,
					Other = true,

					Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
					Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				 }
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		party1 = {
			enabled = true,
			size = 65,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
							Haste_Reduction = false,
							Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = false,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
              				Haste_Reduction = false,
 						  	Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = false,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
			},
				interrupt = {
					friendly = true
				}
			}
		},
		party2 = {
			enabled = true,
			size = 65,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
							Haste_Reduction = false,
							Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = false,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
              				Haste_Reduction = false,
			        		Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = false,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
			},
				interrupt = {
					friendly = true
				}
			}
		},
		party3 = {
			enabled = true,
			size = 65,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						CC = true,
						Silence = true,
						RootPhyiscal_Special = true,
						RootMagic_Special = true,
						Root = true,
						ImmunePlayer = false,
						Disarm_Warning = false,
						CC_Warning = false,
						Enemy_Smoke_Bomb = true,
						Stealth = false,
						Immune = true,
						ImmuneSpell = true,
						ImmunePhysical = true,
						AuraMastery_Cast_Auras = false,
						ROP_Vortex = true,
						Disarm = true,
						Haste_Reduction = false,
						Dmg_Hit_Reduction = false,
						AOE_DMG_Modifiers = true,
						Friendly_Smoke_Bomb = true,
						AOE_Spell_Refections = true,
						Trees = true,
						Speed_Freedoms = true,
						Freedoms = true,
						Friendly_Defensives = false,
						Mana_Regen = false,
						CC_Reduction = false,
						Personal_Offensives = false,
						Peronsal_Defensives = false,
						Movable_Cast_Auras = true,
						SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
						PvE = true,
						Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
             				Haste_Reduction = false,
 					    	Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = false,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
				},
				interrupt = {
					friendly = true
				}
			}
		},
		party4 = {
			enabled = true,
			size = 65,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
							Haste_Reduction = false,
							Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = false,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
					 }
				},
					debuff ={
						friendly = {
							CC = true,
							Silence = true,
							RootPhyiscal_Special = true,
							RootMagic_Special = true,
							Root = true,
							ImmunePlayer = false,
							Disarm_Warning = false,
							CC_Warning = false,
							Enemy_Smoke_Bomb = true,
							Stealth = false,
							Immune = true,
							ImmuneSpell = true,
							ImmunePhysical = true,
							AuraMastery_Cast_Auras = false,
							ROP_Vortex = true,
							Disarm = true,
              				Haste_Reduction = false,
 						 	Dmg_Hit_Reduction = false,
							AOE_DMG_Modifiers = true,
							Friendly_Smoke_Bomb = true,
							AOE_Spell_Refections = true,
							Trees = true,
							Speed_Freedoms = true,
							Freedoms = true,
							Friendly_Defensives = false,
							Mana_Regen = false,
							CC_Reduction = false,
							Personal_Offensives = false,
							Peronsal_Defensives = false,
							Movable_Cast_Auras = true,
							SnareSpecial = true, SnarePhysical70 = true, SnareMagic70 = true, SnarePhysical50 = true, SnarePosion50 = true, SnareMagic50 = true, SnarePhysical30 = true, SnareMagic30  = true, Snare = true,
							PvE = true,
							Other = false,
						}
				},
				interrupt = {
					friendly = true
				}
			}
		},
		arena1 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true, 	Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena2 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena3 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena4 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
		arena5 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "None",
			categoriesEnabled = {
				buff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				debuff = {
					friendly = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				},
					enemy    = {
						Drink_Purge = true,	Immune_Arena = true, CC_Arena = true,	Silence_Arena = true,		Special_High = true, Ranged_Major_OffenisiveCDs = true, Roots_90_Snares = true,	Disarms = true,	Melee_Major_OffenisiveCDs = true,	Big_Defensive_CDs = true,	Player_Party_OffensiveCDs = true,
						Small_Offenisive_CDs = true,	Small_Defensive_CDs = true,	Freedoms_Speed = true,	Snares_WithCDs = true,	Special_Low = true,	Snares_Ranged_Spamable = true,	Snares_Casted_Melee = true
				}
				},
				interrupt = {
					friendly = true,
					enemy    = true
				}
			}
		},
	},
}
local LoseControlDB -- local reference to the addon settings. this gets initialized when the ADDON_LOADED event fires
------------------------------------------------------------------------------------
--[[
-------------------------------------------
-These functions filter to show newest buffs
-------------------------------------------]]
local function cmp_col1(lhs, rhs)
 	return lhs.col1 > rhs.col1
end

local function cmp_col1_col2(lhs, rhs)
	if lhs.col1 > rhs.col1 then return true end
	if lhs.col1 < rhs.col1 then return false end
	return lhs.col2 > rhs.col2
end

local locBliz = CreateFrame("Frame")
locBliz:RegisterEvent("LOSS_OF_CONTROL_ADDED")
locBliz:SetScript("OnEvent", function(self, event, ...)
	if (event == "LOSS_OF_CONTROL_ADDED") then
		for i = 1, 40 do
			local data = CLocData(i);
			if not data then break end

			local customString = LoseControlDB.customString

			local locType = data.locType;
			local spellID = data.spellID;
			local text = data.displayText;
			local iconTexture = data.iconTexture;
			local startTime = data.startTime;
			local timeRemaining = data.timeRemaining;
			local duration = data.duration;
			local lockoutSchool = data.lockoutSchool;
			local priority = data.priority;
			local displayType = data.displayType;
			local name, instanceType, _, _, _, _, _, instanceID, _, _ = GetInstanceInfo()
			local ZoneName = GetZoneText()
			local Type

			if locType == "SCHOOL_INTERRUPT" then text = strformat("%s Locked", GetSchoolString(lockoutSchool)) end

			string[spellID] = customString[spellID] or text

			if not spellIds[spellID] and  (lockoutSchool == 0 or nil or false) then
				if (locType == "STUN_MECHANIC") or (locType =="PACIFY") or (locType =="STUN") or (locType =="FEAR") or (locType =="CHARM") or (locType =="CONFUSE") or (locType =="POSSESS") or (locType =="FEAR_MECHANIC") or (locType =="FEAR") then
					print("Found New CC",locType,"", spellID)
					Type = "CC"
				elseif locType == "DISARM" then
					print("Found New Disarm",locType,"", spellID)
					Type = "Disarm"
				elseif (locType == "PACIFYSILENCE") or (locType =="SILENCE") then
					print("Found New Silence",locType,"", spellID)
					Type = "Silence"
				elseif locType == "ROOT" then
					print("Found New Root",locType,"", spellID)
					Type = "Root"
				else
					print("Found New Other",locType,"", spellID)
					Type = "Other"
				end
				spellIds[spellID] = Type
				LoseControlDB.spellEnabled[spellID]= true
				tblinsert(LoseControlDB.customSpellIds, {spellID, Type, instanceType, name.."\n"..ZoneName, nil, "Discovered", #L.spells})
				tblinsert(L.spells[#L.spells][tabsIndex[Type]], {spellID, Type, instanceType, name.."\n"..ZoneName, nil, "Discovered", #L.spells})
				L.SpellsPVEConfig:UpdateTab(#L.spells-1)
			elseif (not interruptsIds[spellID]) and lockoutSchool > 0 then
				print("Found New Interrupt",locType,"", spellID)
				interruptsIds[spellID] = duration
				LoseControlDB.spellEnabled[spellID]= true
				tblinsert(LoseControlDB.customSpellIds, {spellID, "Interrupt", instanceType, name.."\n"..ZoneName, duration, "Discovered", #L.spells})
				tblinsert(L.spells[#L.spells][tabsIndex["Interrupt"]], {spellID, "Interrupt", instanceType, name.."\n"..ZoneName, duration, "Discovered", #L.spells})
				L.SpellsPVEConfig:UpdateTab(#L.spells-1)
			else
			end
		end
	end
end)


local tooltip = CreateFrame("GameTooltip", "DebuffTextDebuffScanTooltip", UIParent, "GameTooltipTemplate")
local function GetDebuffText(unitId, debuffNum)
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	tooltip:SetUnitDebuff(unitId, debuffNum)
	local snarestring = DebuffTextDebuffScanTooltipTextLeft2:GetText()
	tooltip:Hide()
	if snarestring then
		if strmatch(snarestring, "Movement") or strmatch(snarestring, "movement") then
			return true
		else
			return false
		end
	end
end


-------------------------------------------------------------------------------
-- Create the main class
local LoseControl = CreateFrame("Cooldown", nil, UIParent, "CooldownFrameTemplate") -- Exposes the SetCooldown method

function LoseControl:OnEvent(event, ...) -- functions created in "object:method"-style have an implicit first parameter of "self", which points to object
	self[event](self, ...) -- route event parameters to LoseControl:event methods
end
LoseControl:SetScript("OnEvent", LoseControl.OnEvent)

-- Utility function to handle registering for unit events
function LoseControl:RegisterUnitEvents(enabled)
	local unitId = self.unitId
	if debug then print("RegisterUnitEvents", unitId, enabled) end
	if enabled then
		if unitId == "target" then
			self:RegisterUnitEvent("UNIT_AURA", unitId)
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
		elseif unitId == "targettarget" then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
			self:RegisterUnitEvent("UNIT_TARGET", "target")
			self:RegisterEvent("UNIT_AURA")
			RegisterUnitWatch(self, true)
			if (not TARGETTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK) then
				-- Update unit frecuently when exists
				self.UpdateStateFuncCache = function() self:UpdateState(true) end
				function self:UpdateState(autoCall)
					if not autoCall and self.timerActive then return end
					if (self.frame.enabled and not self.unlockMode and UnitExists(self.unitId)) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, updatedAuras, 300)
						self.timerActive = true
						Ctimer(2.5, self.UpdateStateFuncCache)
					else
						self.timerActive = false
					end
				end
				-- Attribute state-unitexists from RegisterUnitWatch
				self:SetScript("OnAttributeChanged", function(self, name, value)
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, updatedAuras, 200)
					end
					if value then
						self:UpdateState()
					end
				end)
				-- TargetTarget Blizzard Frame Show
				TargetFrameToT:HookScript("OnShow", function()
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						if self.frame.anchor == "Blizzard" then
							self:UNIT_AURA(self.unitId, updatedAuras, -30)
						else
							self:UNIT_AURA(self.unitId, updatedAuras, 30)
						end
					end
				end)
				-- TargetTarget Blizzard Debuff Show/Hide
				for i = 1, 4 do
					local TframeToTDebuff = _G["TargetFrameToTDebuff"..i]
					if (TframeToTDebuff ~= nil) then
						TframeToTDebuff:HookScript("OnShow", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, updatedAuras, 40)
									end
								end)
							end
						end)
						TframeToTDebuff:HookScript("OnHide", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, updatedAuras, 43)
									end
								end)
							end
						end)
					end
				end
				TARGETTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK = true
			end
		elseif unitId == "focus" then
			self:RegisterUnitEvent("UNIT_AURA", unitId)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED")
		elseif unitId == "focustarget" then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:RegisterEvent("PLAYER_FOCUS_CHANGED")
			self:RegisterUnitEvent("UNIT_TARGET", "focus")
			self:RegisterEvent("UNIT_AURA")
			RegisterUnitWatch(self, true)
			if (not FOCUSTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK) then
				-- Update unit frecuently when exists
				self.UpdateStateFuncCache = function() self:UpdateState(true) end
				function self:UpdateState(autoCall)
					if not autoCall and self.timerActive then return end
					if (self.frame.enabled and not self.unlockMode and UnitExists(self.unitId)) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, updatedAuras, 300)
						self.timerActive = true
						Ctimer(2.5, self.UpdateStateFuncCache)
					else
						self.timerActive = false
					end
				end
				-- Attribute state-unitexists from RegisterUnitWatch
				self:SetScript("OnAttributeChanged", function(self, name, value)
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						self:UNIT_AURA(self.unitId, updatedAuras, 200)
					end
					if value then
						self:UpdateState()
					end
				end)
				-- FocusTarget Blizzard Frame Show
				FocusFrameToT:HookScript("OnShow", function()
					if (self.frame.enabled and not self.unlockMode) then
						self.unitGUID = UnitGUID(self.unitId)
						if self.frame.anchor == "Blizzard" then
							self:UNIT_AURA(self.unitId, updatedAuras, -30)
						else
							self:UNIT_AURA(self.unitId, updatedAuras, 30)
						end
					end
				end)
				-- FocusTarget Blizzard Debuff Show/Hide
				for i = 1, 4 do
					local FframeToTDebuff = _G["FocusFrameToTDebuff"..i]
					if (FframeToTDebuff ~= nil) then
						FframeToTDebuff:HookScript("OnShow", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, updatedAuras, 30)
									end
								end)
							end
						end)
						FframeToTDebuff:HookScript("OnHide", function()
							if (self.frame.enabled) then
								local timeCombatLogAuraEvent = GetTime()
								Ctimer(0.01, function()	-- execute in some close next frame to depriorize this event
									if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < timeCombatLogAuraEvent)) then
										self.unitGUID = UnitGUID(self.unitId)
										self:UNIT_AURA(self.unitId, updatedAuras, 31)
									end
								end)
							end
						end)
					end
				end
				FOCUSTOTARGET_ANCHORTRIGGER_UNIT_AURA_HOOK = true
			end
		elseif unitId == "pet" then
			self:RegisterUnitEvent("UNIT_AURA", unitId)
			self:RegisterUnitEvent("UNIT_PET", "player")
		else
			self:RegisterUnitEvent("UNIT_AURA", unitId)
		end
	else
		if unitId == "target" then
			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		elseif unitId == "targettarget" then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
			self:UnregisterEvent("UNIT_TARGET")
			self:UnregisterEvent("UNIT_AURA")
			UnregisterUnitWatch(self)
		elseif unitId == "focus" then
			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
		elseif unitId == "focustarget" then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
			self:UnregisterEvent("UNIT_TARGET")
			self:UnregisterEvent("UNIT_AURA")
			UnregisterUnitWatch(self)
		elseif unitId == "pet" then
			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("UNIT_PET")
		else
			self:UnregisterEvent("UNIT_AURA")
		end
		if not self.unlockMode then
			self:Hide()
			self:GetParent():Hide()
		end
	end
	local someFrameEnabled = false
	for _, v in pairs(LCframes) do
		if v.frame and v.frame.enabled then
			someFrameEnabled = true
			break
		end
	end
	if someFrameEnabled then
		LCframes["target"]:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		LCframes["target"]:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

local function SetInterruptIconsSize(iconFrame, iconSize)
	local interruptIconSize = (iconSize * 0.88) / 3
	local interruptIconOffset = (iconSize * 0.06)
	if iconFrame.frame.anchor == "Blizzard" then
		iconFrame.interruptIconOrderPos = {
			[1] = {-interruptIconOffset-interruptIconSize, interruptIconOffset},
			[2] = {-interruptIconOffset, interruptIconOffset+interruptIconSize},
			[3] = {-interruptIconOffset-interruptIconSize, interruptIconOffset+interruptIconSize},
			[4] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset+interruptIconSize},
			[5] = {-interruptIconOffset, interruptIconOffset+interruptIconSize*2},
			[6] = {-interruptIconOffset-interruptIconSize, interruptIconOffset+interruptIconSize*2},
			[7] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset+interruptIconSize*2}
		}
	else
		iconFrame.interruptIconOrderPos = {
			[1] = {-interruptIconOffset, interruptIconOffset},
			[2] = {-interruptIconOffset-interruptIconSize, interruptIconOffset},
			[3] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset},
			[4] = {-interruptIconOffset, interruptIconOffset+interruptIconSize},
			[5] = {-interruptIconOffset-interruptIconSize, interruptIconOffset+interruptIconSize},
			[6] = {-interruptIconOffset-interruptIconSize*2, interruptIconOffset+interruptIconSize},
			[7] = {-interruptIconOffset, interruptIconOffset+interruptIconSize*2}
		}
	end
	iconFrame.iconInterruptBackground:SetWidth(iconSize)
	iconFrame.iconInterruptBackground:SetHeight(iconSize)
	for _, v in pairs(iconFrame.iconInterruptList) do
		v:SetWidth(interruptIconSize)
		v:SetHeight(interruptIconSize)
		v:SetPoint("BOTTOMRIGHT", iconFrame.interruptIconOrderPos[v.interruptIconOrder or 1][1], iconFrame.interruptIconOrderPos[v.interruptIconOrder or 1][2])
	end
end

-- Function to disable Cooldown on player bars for CC effects
function LoseControl:DisableLossOfControlUI()
	if (not DISABLELOSSOFCONTROLUI_HOOKED) then
		hooksecurefunc('CooldownFrame_Set', function(self)
			if self.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL then
				self:SetDrawBling(false)
				self:SetCooldown(0, 0)
			else
				if not self:GetDrawBling() then
					self:SetDrawBling(true)
				end
			end
		end)
		hooksecurefunc('ActionButton_UpdateCooldown', function(self)
			if ( self.cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL ) then
				local start, duration, enable, charges, maxCharges, chargeStart, chargeDuration;
				local modRate = 1.0;
				local chargeModRate = 1.0;
				if ( self.spellID ) then
					start, duration, enable, modRate = GetSpellCooldown(self.spellID);
					charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetSpellCharges(self.spellID);
				else
					start, duration, enable, modRate = GetActionCooldown(self.action);
					charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetActionCharges(self.action);
				end
				self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge");
				self.cooldown:SetSwipeColor(0, 0, 0);
				self.cooldown:SetHideCountdownNumbers(false);
				if ( charges and maxCharges and maxCharges > 1 and charges < maxCharges ) then
					if chargeStart == 0 then
						ClearChargeCooldown(self);
					else
						if self.chargeCooldown then
							CooldownFrame_Set(self.chargeCooldown, chargeStart, chargeDuration, true, true, chargeModRate);
						end
					end
				else
					ClearChargeCooldown(self);
				end
				CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate);
			end
		end)
		DISABLELOSSOFCONTROLUI_HOOKED = true
	end
end


function LoseControl:CompileArenaSpells()

	spellIdsArena = {}

	local spellsArena = {}
	local spellsArenaLua = {}
	local hash = {}
	local customSpells = {}
	local toremove = {}
	--Build Custom Table for Check
	for k, v in ipairs(_G.LoseControlDB.customSpellIdsArena) do
		local spellID, prio, _, _, _, _, tabId  = unpack(v)
		customSpells[spellID] = {spellID, prio, k}
	end
	--Build the Spells Table
	for i = 1, (#tabsArena) do
		if spellsArena[i] == nil then
			spellsArena[i] = {}
		end
	end
	--Sort the spells
	for k, v in ipairs(spellsArenaTable) do
		local spellID, prio = unpack(v)
		tblinsert(spellsArena[tabsArenaIndex[prio]], ({spellID, prio }))
		spellsArenaLua[spellID] = true
	end

	L.spellsArenaLua = spellsArenaLua
	--Clean up Spell List, Remove all Duplicates and Custom Spells (Will ReADD Custom Spells Later)
	for i = 1, (#spellsArena) do
		local removed = 0
		for l = 1, (#spellsArena[i]) do
			local spellID, prio = unpack(spellsArena[i][l])
			if (not hash[spellID]) and (not customSpells[spellID]) then
				hash[spellID] = {spellID, prio}
			else
				if customSpells[spellID] then
					local CspellID, Cprio, Ck = unpack(customSpells[spellID])
					if CspellID == spellID and Cprio == prio then
						tblremove(_G.LoseControlDB.customSpellIdsArena, Ck)
						print("|cff00ccffLoseControl|r : "..spellID.." : "..prio.." |cff009900Restored Arena Spell to Orginal Value|r")
					else
						if type(spellID) == "number" then
							if GetSpellInfo(spellID) then
								local name = GetSpellInfo(spellID)
								--print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." ("..name..") Modified Arena Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
							end
						else
							--print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." (not spellId) Modified Arena Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
						end
						tblinsert(toremove, {i , l, removed, spellID})
						removed = removed + 1
					end
				else
					local HspellID, Hprio = unpack(hash[spellID])
					if type(spellID) == "number" then
						local name = GetSpellInfo(spellID)
						--print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." ("..name..") ".."|cffff0000Duplicate Arena Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
					else
						--print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." (not spellId) ".."|cff009900Duplicate Arena Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
					end
					tblinsert(toremove, {i , l, removed, spellID})
					removed = removed + 1
				end
			end
		end
	end
	--Now Remove all the Duplicates and Custom Spells
	for k, v in ipairs(toremove) do
		local i, l, r, s = unpack(v)
		tblremove(spellsArena[i], l - r)
	end
	--ReAdd all dbCustom Spells to spells
	for k,v in ipairs(_G.LoseControlDB.customSpellIdsArena) do
		local spellID, prio, instanceType, zone, duration, customname, _, cleuEvent  = unpack(v)
		if prio ~= "Delete" then
			tblinsert(spellsArena[tabsArenaIndex[prio]], 1, v) --v[7]: Category to enter spell / v[8]: Tab to update / v[9]: Table
		end
	end

		--Make spellIds from Spells for AuraFilter
	for i = 1, #spellsArena do
		for l = 1, #spellsArena[i] do
			spellIdsArena[spellsArena[i][l][1]] = spellsArena[i][l][2]
		end
	end

	for k, v in ipairs(interrupts) do
		local spellID, duration = unpack(v)
		tblinsert(spellsArena[tabsArenaIndex["Interrupt"]], 1, {spellID , "Interrupt", nil, nil, duration})
	end

	for k, v in ipairs(cleuSpells) do
		local spellID, duration, _, prioArena, _, customnameArena = unpack(v)
		if prioArena then
			tblinsert(spellsArena[tabsArenaIndex[prioArena]], 1, {spellID , prioArena, nil, nil, duration, customnameArena, nil, "cleuEventArena"})
		end
	end

	L.spellsArena = spellsArena
	L.spellIdsArena = spellIdsArena

--ARENAENABLED-------------------------------------------------------------------------------------------
	for k in pairs(spellIdsArena) do
		if _G.LoseControlDB.spellEnabledArena[k] == nil then
			_G.LoseControlDB.spellEnabledArena[k]= true
		end
	end
	for k in pairs(interruptsIds) do
		if _G.LoseControlDB.spellEnabledArena[k] == nil then
			_G.LoseControlDB.spellEnabledArena[k]= true
		end
	end
	for k in pairs(cleuPrioCastedSpells) do --cleuPrioCastedSpells is just the one list
		if _G.LoseControlDB.spellEnabledArena[cleuPrioCastedSpells[k].nameArena] == nil then
			_G.LoseControlDB.spellEnabledArena[cleuPrioCastedSpells[k].nameArena]= true
		end
	end

end

function LoseControl:CompileSpells(typeUpdate)

	spellIds = {}
	interruptsIds = {}
	cleuPrioCastedSpells = {}
	classIds = {}

	local spells = {}
	local spellsLua = {}
	local hash = {}
	local customSpells = {}
	local toremove = {}
	--Build Custom Table for Check
	for k, v in ipairs(_G.LoseControlDB.customSpellIds) do
		local spellID, prio, _, _, _, _, tabId  = unpack(v)
		customSpells[spellID] = {spellID, prio, tabId, k}
	end
	--Build the Spells Table
	for i = 1, (#spellsTable) do
		if spells[i] == nil then
			spells[i] = {}
		end
		for l = 1, (#tabs) do
			if spells[i][l] == nil then
				spells[i][l] = {}
			end
		end
	end
	--Sort the spells
	for i = 1, (#spellsTable) do
		for l = 2, #spellsTable[i] do
			local spellID, prio = unpack(spellsTable[i][l])
			tblinsert(spells[i][tabsIndex[prio]], ({spellID, prio}))
			if spellID then 
				spellsLua[spellID] = true
			end
		end
	end

    for i = 1, (#spellsTable) do
		for l = 2, #spellsTable[i] do
			local spellID, prio, string = unpack(spellsTable[i][l])
			if string then
				if spellID then 
					_G.LoseControlDB.customString[spellID] = string
				end
			end
		end
    end

	for i = 1, #cleuSpells do 	
		local spellID, duration, prio, arena, string = unpack(cleuSpells[i])
		if string then
			if spellID then
				_G.LoseControlDB.customString[spellID] = string
			end
		end
	end



	for i = 1, #cleuSpells do 
		local spellID, _,_,_,_,_, class = unpack(cleuSpells[i])
		if class then 
			classIds[spellID] = class
			local name = GetSpellInfo(spellID)
			if name and not classIds[name] then
				classIds[name] = class
			end
		end
	end
	for i = 1, #interrupts do 
		local spellID, _, class = unpack(interrupts[i])
		if class then 
			classIds[spellID] = class
			local name = GetSpellInfo(spellID)
			if name and not classIds[name] then
				classIds[name] = class
			end
		end
	end
	for i = 2, #spellsTable[1] do 
		local spellID, prio, string, class = unpack(spellsTable[1][i])
		if class and spellID then 
			classIds[spellID] = class
			local name = GetSpellInfo(spellID)
			if name and not classIds[name] then
				classIds[name] = class
			end
		end
	end
	for i = 1, #spellsArenaTable do 
		local spellID, prio, class = unpack(spellsArenaTable[i])
		if class and spellID then
			classIds[spellID] = class
			local name = GetSpellInfo(spellID)
			if name and not classIds[name] then
				classIds[name] = class
			end
		end
	end

	
	L.classIds = classIds

	L.spellsLua = spellsLua
	--Clean up Spell List, Remove all Duplicates and Custom Spells (Will ReADD Custom Spells Later)
	for i = 1, (#spells) do
		for l = 1, (#spells[i]) do
			local removed = 0
			for x = 1, (#spells[i][l]) do
				local spellID, prio = unpack(spells[i][l][x])
				if (not hash[spellID]) and (not customSpells[spellID]) and spellID then
					hash[spellID] = {spellID, prio}
				else
					if customSpells[spellID] then
						local CspellID, Cprio, CtabId, Ck = unpack(customSpells[spellID])
						if CspellID == spellID and Cprio == prio and CtabId == i then
							tblremove(_G.LoseControlDB.customSpellIds, Ck)
							print("|cff00ccffLoseControl|r : "..spellID.." : "..prio.." |cff009900Restored to Orginal Value|r")
						elseif CspellID == spellID and CtabId == #spells then
							tblremove(_G.LoseControlDB.customSpellIds, Ck)
							print("|cff00ccffLoseControl|r : "..spellID.." : "..prio.." |cff009900Added from Discovered Spells to LC Database (Reconfigure if Needed)|r")
						else
							if type(spellID) == "number" then
								if GetSpellInfo(spellID) then
									local name = GetSpellInfo(spellID)
									if name then 
										print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." ("..spellID..") Modified Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
									else
										print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." ("..name..") Modified Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
									end
								end
							else
								print("|cff00ccffLoseControl|r : "..CspellID.." : "..Cprio.." (not spellId) Modified Spell ".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
							end
							tblinsert(toremove, {i , l, x, removed, spellID})
							removed = removed + 1
						end
					else
						if spellID then
							local HspellID, Hprio = unpack(hash[spellID])
							if type(spellID) == "number" then
								local name = GetSpellInfo(spellID)
								if name then 
									print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." ("..name..") ".."|cffff0000Duplicate Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
								else
									print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." ("..spellID..") ".."|cffff0000Duplicate Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
								end
							else
								print("|cff00ccffLoseControl|r : "..HspellID.." : "..Hprio.." (not spellId) ".."|cff009900Duplicate Spell in Lua |r".."|cff009900Removed |r"  ..spellID.." |cff009900: |r"..prio)
							end
							tblinsert(toremove, {i , l, x, removed, spellID})
							removed = removed + 1
						end
					end
				end
			end
		end
	end
	--Now Remove all the Duplicates and Custom Spells
	for k, v in ipairs(toremove) do
		local i, l, x, r, s = unpack(v)
		tblremove(spells[i][l], x - r)
	end
	--ReAdd all dbCustom Spells to spells
	for k,v in ipairs(_G.LoseControlDB.customSpellIds) do
		local spellID, prio, instanceType, zone, duration, customname, row, cleuEvent, position  = unpack(v)
		if prio ~= "Delete" then
			if duration then
					interruptsIds[spellID] = duration
			end
			if customname == "Discovered" then row = #spells end
			if position then
				tblinsert(spells[row][position], 1, v)
			else
				tblinsert(spells[row][tabsIndex[prio]], 1, v) --v[7]: Category to enter spell / v[8]: Tab to update / v[9]: Table
			end
		end
	end
	--Make spellIds from Spells for AuraFilter
	for i = 1, #spells do
		for l = 1, #spells[i] do
			for x = 1, #spells[i][l] do
				if spells[i][l][x][1] then
					spellIds[spells[i][l][x][1]] = spells[i][l][x][2]
				end
			end
		end
	end
	--Make interruptIds for cleu -- only need to compile 1x for arena and players
	for k, v in ipairs(interrupts) do
	local spellID, duration = unpack(v)
	interruptsIds[spellID] = duration
	end
	--Make cleuPrioCastedSpells for cleu -- only need to compile 1x for arena and players
	for _, v in ipairs(cleuSpells) do
		local spellID, duration, prio, prioArena, cleuEvent, cleuEventArena = unpack(v)
		cleuPrioCastedSpells[spellID] = {["duration"] = duration, ["priority"] = prio, ["priorityArena"] = prioArena,  ["name"] = cleuEvent,  ["nameArena"] = cleuEventArena}
	end
	--Add interrupts to Spells for Table
	for k, v in ipairs(interrupts) do
		local spellID, duration = unpack(v)
		tblinsert(spells[1][tabsIndex["Interrupt"]], 1, {spellID , "Interrupt", nil, nil, duration})
	end
	--Add cleuPrioCastedSpells  to Spells for Table
	for k, v in ipairs(cleuSpells) do
		local spellID, duration, prio, _, customname = unpack(v)
		if prio then
			tblinsert(spells[1][tabsIndex[prio]], 1, {spellID , prio, nil, nil, duration, customname, nil, "cleuEvent"})			--body...
		end
	end

	L.spells = spells
	L.spellIds = spellIds
	--check for any 1st time spells being added and set to On
	for k in pairs(spellIds) do --spellIds is the combined PVE list, Spell List and the Discovered & Custom lists from tblinsert above
		if _G.LoseControlDB.spellEnabled[k] == nil then
			_G.LoseControlDB.spellEnabled[k]= true
		end
	end
	for k in pairs(interruptsIds) do --interruptsIds is the list and the Discovered list from tblinsert above
		if _G.LoseControlDB.spellEnabled[k] == nil then
			_G.LoseControlDB.spellEnabled[k]= true
		end
	end
	for k in pairs(cleuPrioCastedSpells) do --cleuPrioCastedSpells is just the one list
		if _G.LoseControlDB.spellEnabled[cleuPrioCastedSpells[k].name] == nil then
			_G.LoseControlDB.spellEnabled[cleuPrioCastedSpells[k].name]= true
		end
	end
end


-- Handle default settings
function LoseControl:ADDON_LOADED(arg1)
	if arg1 == addonName then
			if (_G.LoseControlDB == nil) or (_G.LoseControlDB.version == nil) then
			_G.LoseControlDB = CopyTable(DBdefaults)
			print(L["LoseControl reset."])
		end
		if _G.LoseControlDB.version < DBdefaults.version then
			for j, u in pairs(DBdefaults) do
				if (_G.LoseControlDB[j] == nil) then
					_G.LoseControlDB[j] = u
				elseif (type(u) == "table") then
					for k, v in pairs(u) do
						if (_G.LoseControlDB[j][k] == nil) then
							_G.LoseControlDB[j][k] = v
						elseif (type(v) == "table") then
							for l, w in pairs(v) do
								if (_G.LoseControlDB[j][k][l] == nil) then
									_G.LoseControlDB[j][k][l] = w
								elseif (type(w) == "table") then
									for m, x in pairs(w) do
										if (_G.LoseControlDB[j][k][l][m] == nil) then
											_G.LoseControlDB[j][k][l][m] = x
										elseif (type(x) == "table") then
											for n, y in pairs(x) do
												if (_G.LoseControlDB[j][k][l][m][n] == nil) then
													_G.LoseControlDB[j][k][l][m][n] = y
												elseif (type(y) == "table") then
													for o, z in pairs(y) do
														if (_G.LoseControlDB[j][k][l][m][n][o] == nil) then
															_G.LoseControlDB[j][k][l][m][n][o] = z
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
			_G.LoseControlDB.version = DBdefaults.version
		end
		LoseControlDB = _G.LoseControlDB
		self.VERSION = "9.0"
		self.noCooldownCount = LoseControlDB.noCooldownCount
		self.noBlizzardCooldownCount = LoseControlDB.noBlizzardCooldownCount
		self.noLossOfControlCooldown = LoseControlDB.noLossOfControlCooldown
		if LoseControlDB.noLossOfControlCooldown then
			LoseControl:DisableLossOfControlUI()
		end
		if (LoseControlDB.duplicatePlayerPortrait and LoseControlDB.frames.player.anchor == "Blizzard") then
			LoseControlDB.duplicatePlayerPortrait = false
		end
		LoseControlDB.frames.player2.enabled = LoseControlDB.duplicatePlayerPortrait and LoseControlDB.frames.player.enabled
		if LoseControlDB.noCooldownCount then
			self:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
			for _, v in pairs(LCframes) do
				v:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
			end
			LCframeplayer2:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
			--LCframeplayer3:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
		else
			self:SetHideCountdownNumbers(true)
			for _, v in pairs(LCframes) do
				v:SetHideCountdownNumbers(true)
			end
			LCframeplayer2:SetHideCountdownNumbers(true)
			--LCframeplayer3:SetHideCountdownNumbers(true)
		end
		playerGUID = UnitGUID("player")
		self:CompileSpells(1)
		self:CompileArenaSpells(1)
	 --L.SpellsPVEConfig:Addon_Load()
	 --L.SpellsConfig:Addon_Load()
   --L.SpellsArenaConfig:Addon_Load()
	end
end

LoseControl:RegisterEvent("ADDON_LOADED")


function LoseControl:CheckSUFUnitsAnchors(updateFrame)
	if not(ShadowUF and (SUFUnitplayer or SUFUnitpet or SUFUnittarget or SUFUnittargettarget or SUFHeaderpartyUnitButton1 or SUFHeaderpartyUnitButton2 or SUFHeaderpartyUnitButton3 or SUFHeaderpartyUnitButton4)) then return false end
	local frames = { self.unitId }
	if strfind(self.unitId, "party") then
		frames = { "party1", "party2", "party3", "party4" }
	elseif strfind(self.unitId, "arena") then
		frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
	end
	for _, unitId in ipairs(frames) do
		if anchors.SUF.player == nil then anchors.SUF.player = SUFUnitplayer and SUFUnitplayer.portrait or nil end
		if anchors.SUF.pet == nil then anchors.SUF.pet    = SUFUnitpet and SUFUnitpet.portrait or nil end
		if anchors.SUF.target == nil then anchors.SUF.target = SUFUnittarget and SUFUnittarget.portrait or nil end
		if anchors.SUF.targettarget == nil then anchors.SUF.targettarget = SUFUnittargettarget and SUFUnittargettarget.portrait or nil end
		if anchors.SUF.focus == nil then anchors.SUF.focus = SUFUnitfocus and SUFUnitfocus.portrait or nil end
		if anchors.SUF.focustarget == nil then anchors.SUF.focustarget = SUFUnitfocustarget and SUFUnitfocustarget.portrait or nil end
		if anchors.SUF.party1 == nil then anchors.SUF.party1 = SUFHeaderpartyUnitButton1 and SUFHeaderpartyUnitButton1.portrait or nil end
		if anchors.SUF.party2 == nil then anchors.SUF.party2 = SUFHeaderpartyUnitButton2 and SUFHeaderpartyUnitButton2.portrait or nil end
		if anchors.SUF.party3 == nil then anchors.SUF.party3 = SUFHeaderpartyUnitButton3 and SUFHeaderpartyUnitButton3.portrait or nil end
		if anchors.SUF.party4 == nil then anchors.SUF.party4 = SUFHeaderpartyUnitButton4 and SUFHeaderpartyUnitButton4.portrait or nil end
		if anchors.SUF.arena1 == nil then anchors.SUF.arena1 = SUFHeaderarenaUnitButton1 and SUFHeaderarenaUnitButton1.portrait or nil end
		if anchors.SUF.arena2 == nil then anchors.SUF.arena2 = SUFHeaderarenaUnitButton2 and SUFHeaderarenaUnitButton2.portrait or nil end
		if anchors.SUF.arena3 == nil then anchors.SUF.arena3 = SUFHeaderarenaUnitButton3 and SUFHeaderarenaUnitButton3.portrait or nil end
		if anchors.SUF.arena4 == nil then anchors.SUF.arena4 = SUFHeaderarenaUnitButton4 and SUFHeaderarenaUnitButton4.portrait or nil end
		if anchors.SUF.arena5 == nil then anchors.SUF.arena5 = SUFHeaderarenaUnitButton5 and SUFHeaderarenaUnitButton5.portrait or nil end
		if updateFrame and anchors.SUF[unitId] ~= nil then
			local frame = LoseControlDB.frames[self.fakeUnitId or unitId]
			local icon = LCframes[unitId]
			if self.fakeUnitId == "player2" then
				icon = LCframeplayer2
			end
			local newAnchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
			if newAnchor ~= nil and icon.anchor ~= newAnchor then
				icon.anchor = newAnchor
				icon:SetPoint(
					frame.point or "CENTER",
					icon.anchor,
					frame.relativePoint or "CENTER",
					frame.x or 0,
					frame.y or 0
				)
				icon:GetParent():SetPoint(
					frame.point or "CENTER",
					icon.anchor,
					frame.relativePoint or "CENTER",
					frame.x or 0,
					frame.y or 0
				)
				if icon.anchor:GetParent() then
					icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
				end
			end
		end
	end
	if self.fakeUnitId ~= "player2" and self.unitId == "player" then
		LCframeplayer2:CheckSUFUnitsAnchors(updateFrame)
	end
	return true
end

function LoseControl:CheckGladiusUnitsAnchors(updateFrame)

  	if (strfind(self.unitId, "arena")) and LoseControlDB.frames[self.unitId].anchor == "Gladius" then
		local inInstance, instanceType = IsInInstance();  local gladiusFrame;  local frames = {}
		if Gladius and (not anchors.Gladius[self.unitId]) then
			if not GladiusClassIconFramearena1 then
				gladiusFrame = "on"
				frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				if DEFAULT_CHAT_FRAME.editBox:IsVisible() then
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				else
					DEFAULT_CHAT_FRAME.editBox:Show()
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
					DEFAULT_CHAT_FRAME.editBox:Hide()
				end
			end
			if _G["GladiusClassIconFramearena1"] then frames[1] = "arena1" end
			if _G["GladiusClassIconFramearena2"] then frames[2] = "arena2" end
			if _G["GladiusClassIconFramearena3"] then frames[3] = "arena3" end
			if _G["GladiusClassIconFramearena4"] then frames[4] = "arena4" end
			if _G["GladiusClassIconFramearena5"] then frames[5] = "arena5" end
			local counter = 1
  			for _, unitId in pairs(frames) do
  				if (unitId == "arena1") and anchors.Gladius.arena1 == nil then anchors.Gladius.arena1 = _G["GladiusClassIconFramearena1"] or nil end
  				if (unitId == "arena2") and anchors.Gladius.arena2 == nil then anchors.Gladius.arena2 = _G["GladiusClassIconFramearena2"] or nil end
  				if (unitId == "arena3") and anchors.Gladius.arena3 == nil then anchors.Gladius.arena3 = _G["GladiusClassIconFramearena3"] or nil end
  				if (unitId == "arena4") and anchors.Gladius.arena4 == nil then anchors.Gladius.arena4 = _G["GladiusClassIconFramearena4"] or nil end
  				if (unitId == "arena5") and anchors.Gladius.arena5 == nil then anchors.Gladius.arena5 = _G["GladiusClassIconFramearena5"] or nil end
  				if updateFrame and anchors.Gladius[unitId] ~= nil then
					local frame = LoseControlDB.frames[self.fakeUnitId or unitId]
					local icon = LCframes[unitId]
					local exit = _G["GladiusClassIconFramearena"..counter]
					local newAnchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or exit)
					if newAnchor ~= nil and icon.anchor ~= newAnchor then
						icon.anchor = newAnchor
						icon.parent:SetParent(icon.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
						icon:ClearAllPoints() -- if we don't do this then the frame won't always move
						icon:GetParent():ClearAllPoints()
						icon:SetWidth(frame.size)
						icon:SetHeight(frame.size)
						icon:GetParent():SetWidth(frame.size)
						icon:SetPoint(
							frame.point or "CENTER",
							icon.anchor,
							frame.relativePoint or "CENTER",
							frame.x or 0,
							frame.y or 0
						)
						icon:GetParent():SetPoint(
							frame.point or "CENTER",
							icon.anchor,
							frame.relativePoint or "CENTER",
							frame.x or 0,
							frame.y or 0
						)
						if icon.anchor:GetParent() then
							icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
						end
						if #frames < 5 then
						print("|cff00ccffLoseControl|r : Successfully Anchored "..unitId.." frame to Gladius")
					  end
					end
				end
			end
			if #frames == 5 then
			print("|cff00ccffLoseControl|r : Successfully Anchored All Arena Frames")
			end
			if gladiusFrame == "on" then
				if DEFAULT_CHAT_FRAME.editBox:IsVisible() then
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				else
					DEFAULT_CHAT_FRAME.editBox:Show()
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
					DEFAULT_CHAT_FRAME.editBox:Hide()
				end
			end
		end
	end
end

function LoseControl:CheckGladdyUnitsAnchors(updateFrame)
  if (strfind(self.unitId, "arena")) and LoseControlDB.frames[self.unitId].anchor == "Gladdy" then
    local inInstance, instanceType = IsInInstance();  local gladdyFrame;  local frames = {}
  	if IsAddOnLoaded("Gladdy") and (not anchors.Gladdy[self.unitId]) then
  		if not GladdyButtonFrame1 and instanceType ~= "arena" then
  			gladdyFrame = "on"
  			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
  			if DEFAULT_CHAT_FRAME.editBox:IsVisible() then
  				DEFAULT_CHAT_FRAME.editBox:SetText("/gladdy test5")
  				ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  			else
  				DEFAULT_CHAT_FRAME.editBox:Show()
  				DEFAULT_CHAT_FRAME.editBox:SetText("/gladdy test5")
  				ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  				DEFAULT_CHAT_FRAME.editBox:Hide()
  			end
    	end
  		if GladdyButtonFrame1 then frames[1] = "arena1" end
    	if GladdyButtonFrame2 then frames[2] = "arena2" end
  		if GladdyButtonFrame3 then frames[3] = "arena3" end
  		if GladdyButtonFrame4 then frames[4] = "arena4" end
  		if GladdyButtonFrame5 then frames[5] = "arena5" end
  			for _, unitId in pairs(frames) do
  				if (unitId == "arena1") and anchors.Gladdy.arena1 == nil then anchors.Gladdy.arena1 = GladdyButtonFrame1.classIcon or nil end
  				if (unitId == "arena2") and anchors.Gladdy.arena2 == nil then anchors.Gladdy.arena2 = GladdyButtonFrame2.classIcon or nil end
  				if (unitId == "arena3") and anchors.Gladdy.arena3 == nil then anchors.Gladdy.arena3 = GladdyButtonFrame3.classIcon or nil end
  				if (unitId == "arena4") and anchors.Gladdy.arena4 == nil then anchors.Gladdy.arena4 = GladdyButtonFrame4.classIcon or nil end
  				if (unitId == "arena5") and anchors.Gladdy.arena5 == nil then anchors.Gladdy.arena5 = GladdyButtonFrame5.classIcon or nil end
  				if updateFrame and anchors.Gladdy[unitId] ~= nil then
					local frame = LoseControlDB.frames[self.fakeUnitId or unitId]
					local icon = LCframes[unitId]
					local newAnchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
					if newAnchor ~= nil and icon.anchor ~= newAnchor then
						icon.anchor = newAnchor
						icon.parent:SetParent(icon.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
						icon:ClearAllPoints() -- if we don't do this then the frame won't always move
						icon:GetParent():ClearAllPoints()
						icon:SetWidth(frame.size)
						icon:SetHeight(frame.size)
						icon:GetParent():SetWidth(frame.size)
						icon:SetPoint(
							frame.point or "CENTER",
							icon.anchor,
							frame.relativePoint or "CENTER",
							frame.x or 0,
							frame.y or 0
						)
						icon:GetParent():SetPoint(
							frame.point or "CENTER",
							icon.anchor,
							frame.relativePoint or "CENTER",
							frame.x or 0,
							frame.y or 0
						)
						if icon.anchor:GetParent() then
							icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
						end
						if #frames < 5 then
						print("|cff00ccffLoseControl|r : Successfully Anchored "..unitId.." frame to Gladdy")
					  end
					end
				end
			end
			if #frames == 5 then
			print("|cff00ccffLoseControl|r : Successfully Anchored All Arena Frames")
			end
			if gladdyFrame == "on" then
				if DEFAULT_CHAT_FRAME.editBox:IsVisible() then
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladdy hide")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				else
					DEFAULT_CHAT_FRAME.editBox:Show()
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladdy hide")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
					DEFAULT_CHAT_FRAME.editBox:Hide()
				end
			end
		end
	end
end

-- Initialize a frame's position and register for events
function LoseControl:PLAYER_ENTERING_WORLD() -- this correctly anchors enemy arena frames that aren't created until you zone into an arena
	local unitId = self.unitId
	self.frame = LoseControlDB.frames[self.fakeUnitId or unitId] -- store a local reference to the frame's settings
	local frame = self.frame
	local inInstance, instanceType = IsInInstance()
  	if (instanceType=="arena" or instanceType=="pvp") then LoseControlDB.priority["PvE"] = 0 else LoseControlDB.priority["PvE"] = 10 end --Disables PVE in Arena
	local enabled = frame.enabled and not (
		inInstance and instanceType == "pvp" and (
			( LoseControlDB.disablePartyInBG and strfind(unitId, "party") ) or
			( LoseControlDB.disableArenaInBG and strfind(unitId, "arena") )
		)
	) and not (
		IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp" or instanceType=="party"))
	)
	if (ShadowUF ~= nil) and not(self:CheckSUFUnitsAnchors(false)) and (self.SUFDelayedSearch == nil) then
		self.SUFDelayedSearch = GetTime()
		Ctimer(8, function()	-- delay checking to make sure all variables of the other addons are loaded
			self:CheckSUFUnitsAnchors(true)
		end)
	end
	if strfind(unitId, "arena") then
		if (Gladius ~= nil) and (self.GladiusDelayedSearch == nil) then
			self.GladiusDelayedSearch = GetTime()
			Ctimer(3, function()	-- delay checking to make sure all variables of the other addons are loaded
				self:CheckGladiusUnitsAnchors(true)
			end)
		end
		if IsAddOnLoaded("Gladdy") and (self.GladdyDelayedSearch == nil) then
			self.GladdyDelayedSearch = GetTime()
			Ctimer(3, function()	-- delay checking to make sure all variables of the other addons are loaded
			self:CheckGladdyUnitsAnchors(true)
			end)
		end
	end
	self.anchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
	self.unitGUID = UnitGUID(self.unitId)
	self.parent:SetParent(self.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
	self:ClearAllPoints() -- if we don't do this then the frame won't always move
	self:GetParent():ClearAllPoints()
	self:SetWidth(frame.size)
	self:SetHeight(frame.size)
	self:GetParent():SetWidth(frame.size)
	self:GetParent():SetHeight(frame.size)
	self:RegisterUnitEvents(enabled)
	self:SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	self:GetParent():SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	if self.anchor:GetParent() then
		self:SetFrameLevel(self.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
	end

	SetInterruptIconsSize(self, frame.size)

	--self:SetAlpha(frame.alpha) -- doesn't seem to work; must manually set alpha after the cooldown is displayed, otherwise it doesn't apply.
	self:Hide()
	self:GetParent():Hide()

	if enabled and not self.unlockMode then
		self:UNIT_AURA(self.unitId, updatedAuras, 0)
	end
end

function LoseControl:GROUP_ROSTER_UPDATE()
	local unitId = self.unitId
	local frame = self.frame
	if (frame == nil) or (unitId == nil) or not(strfind(unitId, "party")) then
		return
	end
	local inInstance, instanceType = IsInInstance()
	local enabled = frame.enabled and not (
		inInstance and instanceType == "pvp" and LoseControlDB.disablePartyInBG
	) and not (
		IsInRaid() and LoseControlDB.disablePartyInRaid and not (inInstance and (instanceType=="arena" or instanceType=="pvp" or instanceType=="party"))
	)
	self:RegisterUnitEvents(enabled)
	self.unitGUID = UnitGUID(unitId)
	self:CheckSUFUnitsAnchors(true)
	if (frame == nil) or (unitId == nil) and (strfind(unitId, "arena")) then
		self:CheckGladiusUnitsAnchors(true)
  		self:CheckGladdyUnitsAnchors(true)
	end
	if enabled and not self.unlockMode then
		self:UNIT_AURA(unitId, updatedAuras, 0)
	end
end

function LoseControl:GROUP_JOINED()
	self:GROUP_ROSTER_UPDATE()
end

function LoseControl:GROUP_LEFT()
	self:GROUP_ROSTER_UPDATE()
end

local function UpdateUnitAuraByUnitGUID(unitGUID, typeUpdate)
	local inInstance, instanceType = IsInInstance()
	for k, v in pairs(LCframes) do
		local enabled = v.frame.enabled and not (
			inInstance and instanceType == "pvp" and (
				( LoseControlDB.disablePartyInBG and strfind(v.unitId, "party") ) or
				( LoseControlDB.disableArenaInBG and strfind(v.unitId, "arena") )
			)
		) and not (
			IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(v.unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp" or instanceType=="party"))
		)
		if enabled and not v.unlockMode then
			if v.unitGUID == unitGUID then
				if k == "player3" then k = "player" end
				v:UNIT_AURA(k, updatedAuras, typeUpdate)	
				if (k == "player") and LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(k, updatedAuras, typeUpdate)
				end
			end
		end
	end
end


function LoseControl:ARENA_OPPONENT_UPDATE(...)
	local unit, arg2 = ...;
	local unitId = self.unitId
	local frame = self.frame
	if (frame == nil) or (unitId == nil) or not(strfind(unitId, "arena")) then
		return
	end
	print(unitId.." "..unit.." "..arg2)
	local inInstance, instanceType = IsInInstance()
	self:RegisterUnitEvents(
		frame.enabled and not (
			inInstance and instanceType == "pvp" and LoseControlDB.disableArenaInBG
		)
	)
	self.unitGUID = UnitGUID(self.unitId)
	--self:CheckSUFUnitsAnchors(true)
	self:CheckGladiusUnitsAnchors(true)
  	--self:CheckGladdyUnitsAnchors(true)


	if enabled and not self.unlockMode then
		--self:UNIT_AURA(unitId, updatedAuras, 0)
	end
end

--[[function LoseControl:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
	self:CheckGladiusUnitsAnchors(true)
 	self:CheckGladdyUnitsAnchors(true)
	self:ARENA_OPPONENT_UPDATE()
end]]


local ArenaSeen = CreateFrame("Frame")
ArenaSeen:RegisterEvent("ARENA_OPPONENT_UPDATE")
ArenaSeen:SetScript("OnEvent", function(self, event, ...)
	local unit, arg2 = ...;
	if (event == "ARENA_OPPONENT_UPDATE") then
		if (unit =="arena1") or (unit =="arena2") or (unit =="arena3") or (unit =="arena4") or (unit =="arena5") then
			if arg2 == "seen" then
				if UnitExists(unit) then
					if (unit =="arena1") and (GladiusClassIconFramearena1 or GladdyButtonFrame1) then
						if GladiusClassIconFramearena1 then GladiusClassIconFramearena1:SetAlpha(1) end
						if GladdyButtonFrame1 then GladdyButtonFrame1:SetAlpha(1) end
						local guid = UnitGUID(unit)
						UpdateUnitAuraByUnitGUID(guid, -250)
					end
					if (unit =="arena2") and (GladiusClassIconFramearena2 or GladdyButtonFrame2) then
						if GladiusClassIconFramearena2 then GladiusClassIconFramearena2:SetAlpha(1) end
						if GladdyButtonFrame2 then GladdyButtonFrame2:SetAlpha(1) end
						local guid = UnitGUID(unit)
						UpdateUnitAuraByUnitGUID(guid, -250)
					end
					if (unit =="arena3") and (GladiusClassIconFramearena3 or GladdyButtonFrame3) then
						if GladiusClassIconFramearena3 then GladiusClassIconFramearena3:SetAlpha(1) end
						if GladdyButtonFrame3 then GladdyButtonFrame3:SetAlpha(1) end
						local guid = UnitGUID(unit)
						UpdateUnitAuraByUnitGUID(guid, -250)
					end
					if (unit =="arena4") and (GladiusClassIconFramearena4 or GladdyButtonFrame4) then
						if GladiusClassIconFramearena4 then GladiusClassIconFramearena4:SetAlpha(1) end
						if GladdyButtonFrame4 then GladdyButtonFrame4:SetAlpha(1) end
						local guid = UnitGUID(unit)
						UpdateUnitAuraByUnitGUID(guid, -250)
					end
					if (unit =="arena5") and (GladiusClassIconFramearena5 or GladdyButtonFrame5) then
						if GladiusClassIconFramearena5 then GladiusClassIconFramearena5:SetAlpha(1) end
						if GladdyButtonFrame5 then GladdyButtonFrame5:SetAlpha(1) end
						local guid = UnitGUID(unit)
						UpdateUnitAuraByUnitGUID(guid, -250)
					end
					Arenastealth[unit] = nil
				end
			elseif arg2 == "unseen" then
				local guid = UnitGUID(unit)
				UpdateUnitAuraByUnitGUID(guid, -200)
			elseif arg2 == "destroyed" then
				Arenastealth[unit] = nil
				local guid = UnitGUID(unit)
				UpdateUnitAuraByUnitGUID(guid, -200)
			elseif arg2 == "cleared" then
				Arenastealth[unit] = nil
				local guid = UnitGUID(unit)
				UpdateUnitAuraByUnitGUID(guid, -200)
			end
		end
	end
end)

--[[
local function ObjectDNE(guid) --Used for Infrnals and Ele
	local tooltipData =  C_TooltipInfo.GetHyperlink('unit:' .. guid or '')
	TooltipUtil.SurfaceArgs(tooltipData)

	for _, line in ipairs(tooltipData.lines) do
		TooltipUtil.SurfaceArgs(line)
	end

	if #tooltipData.lines == 1 then -- Fel Obelisk
		return "Despawned"
	end

	for i = 1, #tooltipData.lines do 
 		local text = tooltipData.lines[i].leftText
		 if text and (type(text == "string")) then
			--print(i.." "..text)
			if strfind(text, "Level ??") or strfind(text, "Corpse") then 
				return "Despawned"
			end
		end
	end
end
]]


local DNEtooltip = CreateFrame("GameTooltip", "LCDNEScanSpellDescTooltip", UIParent, "GameTooltipTemplate")

local function ObjectDNE(guid) --Used for Infrnals and Ele
	DNEtooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')
	DNEtooltip:SetHyperlink("unit:"..guid or '')

	for i = 1 , DNEtooltip:NumLines() do
		local text =_G["LCDNEScanSpellDescTooltipTextLeft"..i]; 
		text = text:GetText()
		if text and (type(text == "string")) then
			--print(i.." "..text)
			if strfind(text, "Level ??") or strfind(text, "Corpse") then 
				return "Despawned"
			end
		end
	end
end


local function ActionButton_SetupOverlayGlow(button)
	-- If we already have a SpellActivationAlert then just early return. We should already be setup
	if button.SpellActivationAlert then
		return;
	end

	button.SpellActivationAlert = CreateFrame("Frame", nil, button, "ActionBarButtonSpellActivationAlert");

	--Make the height/width available before the next frame:
	local frameWidth, frameHeight = button:GetSize();
	button.SpellActivationAlert:SetSize(frameWidth * 1.6, frameHeight * 1.6);
	button.SpellActivationAlert:SetPoint("CENTER", button, "CENTER", 0, 0);
	button.SpellActivationAlert:Hide();
end

local function ActionButton_ShowOverlayGlow(button)
	ActionButton_SetupOverlayGlow(button);

	button.SpellActivationAlert:Show();
	button.SpellActivationAlert.ProcLoop:Play();
	button.SpellActivationAlert.ProcStartFlipbook:Hide()
end

local function ActionButton_HideOverlayGlow(button)
	if not button.SpellActivationAlert then
		return;
	end

 	button.SpellActivationAlert:Hide();

end

-- Function to check if pvp talents are active for the player
local function ArePvpTalentsActive()
    local inInstance, instanceType = IsInInstance()
    if inInstance and (instanceType == "pvp" or instanceType == "arena") then
        return true
    elseif inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario") then
        return false
    else
        local talents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
        for _, pvptalent in pairs(talents) do
            local spellID = select(6, GetPvpTalentInfoByID(pvptalent))
            if IsPlayerSpell(spellID) then
                return true
            end
        end
    end
end

local function interruptDuration(destGUID, duration)
	local _, destClass = GetPlayerInfoByGUID(destGUID)
	local unitIdFromGUID
	for _, v in pairs(LCframes) do
		if (UnitGUID(v.unitId) == destGUID) then
			unitIdFromGUID = v.unitId
			break
		end
	end
	local duration3 = duration
	if (unitIdFromGUID ~= nil) then
		local duration3 = duration
		local shamTranquilAirBuff = false
		local _, destClass = GetPlayerInfoByGUID(destGUID)
		for i = 1, 120 do
			local _, _, _, _, _, _, _, _, _, auxSpellId = UnitAura(unitIdFromGUID, i, "HELPFUL")
			if not auxSpellId then break end
			if (destClass == "DRUID") then
				if auxSpellId == 234084 then	-- Moon and Stars (Druid) [Interrupted Mechanic Duration -70% (stacks)]
					duration = duration * 0.5
				end
			end
			if auxSpellId == 317920 then		-- Concentration Aura (Paladin) [Interrupted Mechanic Duration -30% (stacks)]
				duration = duration * 0.7
			elseif auxSpellId == 383020 then	-- Tranquil Air (Shaman) [Interrupted Mechanic Duration -50% (doesn't stack)]
				shamTranquilAirBuff = true
			end
		end
		for i = 1, 120 do
			local _, _, _, _, _, _, _, _, _, auxSpellId = UnitAura(unitIdFromGUID, i, "HARMFUL")
			if not auxSpellId then break end
			if auxSpellId == 372048 then	-- Oppressing Roar (Evoker) [Interrupted Mechanic Duration +30%/+50% (PvP/PvE) (stacks)]
				if ArePvpTalentsActive() then
					duration = duration * 1.3
					duration3 = duration3 * 1.3
				else
					duration = duration * 1.5
					duration3 = duration3 * 1.5
				end
			end
		end
		if (shamTranquilAirBuff) then
			duration3 = duration3 * 0.5
			if (duration3 < duration) then
				duration = duration3
			end
		end
	end
	return duration
end

-- This event check pvp interrupts and targettarget/focustarget unit aura triggers
function LoseControl:COMBAT_LOG_EVENT_UNFILTERED()
	if self.unitId == "target" then
		-- Check Interrupts
		local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, _, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
		if (destGUID ~= nil) then --Diables Kicks for Player
			if (event == "SPELL_INTERRUPT") then
				local duration = interruptsIds[spellId]
				if (duration ~= nil) then
					duration = interruptDuration(destGUID, duration) or duration
					local expirationTime = GetTime() + duration
					local priority = LoseControlDB.priority.Interrupt
					local spellCategory = "Interrupt"
					if (destGUID == UnitGUID("arena1")) or (destGUID == UnitGUID("arena2")) or (destGUID == UnitGUID("arena3")) or (destGUID == UnitGUID("arena4")) or (destGUID == UnitGUID("arena5")) then
			       		priority = LoseControlDB.priorityArena.Interrupt
				 	end
					local name, _, icon = GetSpellInfo(spellId)
					if (InterruptAuras[destGUID] == nil) then
						InterruptAuras[destGUID] = {}
					end
					tblinsert(InterruptAuras[destGUID], {  ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
					UpdateUnitAuraByUnitGUID(destGUID, -20)
					--print("interrupt", ")", destGUID, "|", GetSpellInfo(spellId), "|", duration, "|", expirationTime, "|", spellId)
				end
			elseif (((event == "UNIT_DIED") or (event == "UNIT_DESTROYED") or (event == "UNIT_DISSIPATES")) and (select(2, GetPlayerInfoByGUID(destGUID)) ~= "HUNTER")) then --may need to use UNIT_AURA check for Fiegn Death here to make more accurate
       			if (InterruptAuras[destGUID] ~= nil) then --reset if the source of the kick dies
					InterruptAuras[destGUID] = nil
					UpdateUnitAuraByUnitGUID(destGUID, -21)
		  		end
			end
		end

   		-- Check Channel Interrupts for player
     	if (event == "SPELL_CAST_SUCCESS") then
		    if interruptsIds[spellId] then
				if (destGUID == UnitGUID("player")) and (select(7, UnitChannelInfo("player")) == false) then
					local duration = interruptsIds[spellId]
  			  		if (duration ~= nil) then
						duration = interruptDuration(destGUID, duration) or duration
						local expirationTime = GetTime() + duration
						local priority = LoseControlDB.priority.Interrupt
						local spellCategory = "Interrupt"
						local name, _, icon = GetSpellInfo(spellId)
						if (InterruptAuras[destGUID] == nil) then
							InterruptAuras[destGUID] = {}
						end
						tblinsert(InterruptAuras[destGUID], {  ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
						UpdateUnitAuraByUnitGUID(destGUID, -20)
					end
				end
			end
		end
		-- Check Channel Interrupts for arena
		if (event == "SPELL_CAST_SUCCESS") then
			if interruptsIds[spellId] then
				for i = 1, GetNumArenaOpponents() do
					if (destGUID == UnitGUID("arena"..i)) and (select(7, UnitChannelInfo("arena"..i)) == false) then
						local duration = interruptsIds[spellId]
						if (duration ~= nil) then
							duration = interruptDuration(destGUID, duration) or duration
							local expirationTime = GetTime() + duration
							local priority = LoseControlDB.priorityArena.Interrupt
							local spellCategory = "Interrupt"
							local name, _, icon = GetSpellInfo(spellId)
							if (InterruptAuras[destGUID] == nil) then
								InterruptAuras[destGUID] = {}
							end
							tblinsert(InterruptAuras[destGUID], {  ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
							UpdateUnitAuraByUnitGUID(destGUID, -20)
						end
					end
				end
			end
		end
		-- Check Channel Interrupts for party
		if (event == "SPELL_CAST_SUCCESS") then
			if interruptsIds[spellId] then
				for i = 1, GetNumGroupMembers() do
					if (destGUID == UnitGUID("party"..i)) and (select(7, UnitChannelInfo("party"..i)) == false) then
						local duration = interruptsIds[spellId]
						if (duration ~= nil) then
							duration = interruptDuration(destGUID, duration) or duration
							local expirationTime = GetTime() + duration
							local priority = LoseControlDB.priority.Interrupt
							local spellCategory = "Interrupt"
							local name, _, icon = GetSpellInfo(spellId)
							if (InterruptAuras[destGUID] == nil) then
								InterruptAuras[destGUID] = {}
							end
							tblinsert(InterruptAuras[destGUID], { ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue })
							UpdateUnitAuraByUnitGUID(destGUID, -20)
						end
					end
				end
			end
		end

		-----------------------------------------------------------------------------------------------------------------
		--Reset Stealth Table if Unit Dies
		-----------------------------------------------------------------------------------------------------------------
		if ((event == "UNIT_DIED") or (event == "UNIT_DESTROYED") or (event == "UNIT_DISSIPATES")) and ((destGUID == UnitGUID("arena1")) or (destGUID == UnitGUID("arena2")) or (destGUID == UnitGUID("arena3")) or (destGUID == UnitGUID("arena4")) or (destGUID == UnitGUID("arena5"))) then
			if (destGUID == UnitGUID("arena1")) then
				Arenastealth["arena1"] = nil
			elseif (destGUID == UnitGUID("arena2")) then
				Arenastealth["arena2"] = nil
			elseif (destGUID == UnitGUID("arena3")) then
				Arenastealth["arena3"] = nil
			elseif (destGUID == UnitGUID("arena4")) then
				Arenastealth["arena4"] = nil
			elseif (destGUID == UnitGUID("arena5")) then
				Arenastealth["arena5"] = nil
			end
		end

		-----------------------------------------------------------------------------------------------------------------
		--Shaodwy Duel Enemy Check
		-----------------------------------------------------------------------------------------------------------------
		if ((event == "SPELL_CAST_SUCCESS") and (spellId == 207736)) then
			if sourceGUID and (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
				local duration = 5
				local expirationTime = GetTime() + duration
				if (DuelAura[sourceGUID] == nil) then
					DuelAura[sourceGUID] = {}
				end
				if (DuelAura[destGUID] == nil) then
					DuelAura[destGUID] = {}
				end
				DuelAura[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime, ["destGUID"] = destGUID }
				DuelAura[destGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime, ["destGUID"] = destGUID }
				--print("cleu enemy Dueled Data Stored destGUID is"..destGUID)
				--print("cleu enemy Dueled Data Stored sourceGUID is"..sourceGUID)
				Ctimer(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					DuelAura[sourceGUID] = nil
					DuelAura[destGUID] = nil
				end)
			end
		end

		------------------------------------------------------------------------------------------------------------------------------------------------------------------
		----CLEU Deuff Timer
		------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------------
		--SmokeBomb Check
		-----------------------------------------------------------------------------------------------------------------
		if ((event == "SPELL_CAST_SUCCESS") and (spellId == 76577 or spellId == 359053)) then
			if (sourceGUID ~= nil) then
				local duration = 6
				local expirationTime = GetTime() + duration
				if (SmokeBombAuras[sourceGUID] == nil) then
					SmokeBombAuras[sourceGUID] = {}
				end
			SmokeBombAuras[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
				Ctimer(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					SmokeBombAuras[sourceGUID] = nil
				end)
			end
		end

		------------------------------------------------------------------------------------------------------------------------------------------------------------------
		----CLEU Buff Timer
		------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------------------------------
		--Solar Beam Check
		-----------------------------------------------------------------------------------------------------------------
		if ((event == "SPELL_CAST_SUCCESS") and (spellId == 78675)) then
			if (sourceGUID ~= nil) then
				local duration = 8
				local expirationTime = GetTime() + duration
				if (BeamAura[sourceGUID] == nil) then
					BeamAura[sourceGUID] = {}
				end
				BeamAura[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
				Ctimer(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					BeamAura[sourceGUID] = nil
				end)
			end
		end

		-----------------------------------------------------------------------------------------------------------------
		--Barrier Check
		-----------------------------------------------------------------------------------------------------------------
		if ((event == "SPELL_CAST_SUCCESS") and (spellId == 62618)) then
			if (sourceGUID ~= nil) then
				local duration = 10
				local expirationTime = GetTime() + duration
				if (Barrier[sourceGUID] == nil) then
					Barrier[sourceGUID] = {}
				end
				Barrier[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
				Ctimer(duration + 1, function()	-- execute iKn some close next frame to accurate use of UnitAura function
					Barrier[sourceGUID] = nil
				end)
			end
		end

		-----------------------------------------------------------------------------------------------------------------
		--SGrounds Check
		-----------------------------------------------------------------------------------------------------------------
		if ((event == "SPELL_CAST_SUCCESS") and (spellId == 34861)) then
			if (sourceGUID ~= nil) then
				local duration = 5
				local expirationTime = GetTime() + duration
				if (SGrounds[sourceGUID] == nil) then
					SGrounds[sourceGUID] = {}
				end
				SGrounds[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
				Ctimer(duration + 1, function()	-- execute iKn some close next frame to accurate use of UnitAura function
					SGrounds[sourceGUID] = nil
				end)
			end
		end

		-----------------------------------------------------------------------------------------------------------------
		--Earthen Check (Totems Need a Spawn Time Check)
		-----------------------------------------------------------------------------------------------------------------
		if ((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (spellId == 198838) then
			local duration = 18 --Totemic Focus Makes it 18
			local guid = destGUID
			local spawnTime
			local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
			if unitType == "Creature" or unitType == "Vehicle" then
				local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
				local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
				spawnTime = spawnEpoch + spawnEpochOffset
				--print("Earthen Totem Spawned at: "..spawnTime)
			end
			local expirationTime = GetTime() + duration
			if (Earthen[spawnTime] == nil) then --source becomes the totem ><
				Earthen[spawnTime] = {}
			end
			Earthen[spawnTime] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
			C_Timer.After(duration + .2, function()	-- execute in some close next frame to accurate use of UnitAura function
				Earthen[sourceGUID] = nil
			end)
			if sourceGUID and not (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
				C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
					if UnitExists("player") then UpdateUnitAuraByUnitGUID(UnitGUID("player"), -20) end
					if UnitExists("party1") then UpdateUnitAuraByUnitGUID(UnitGUID("party1"), -20) end
					if UnitExists("party2") then UpdateUnitAuraByUnitGUID(UnitGUID("party2"), -20) end
					if UnitExists("party3") then UpdateUnitAuraByUnitGUID(UnitGUID("party3"), -20) end
					if UnitExists("party4") then UpdateUnitAuraByUnitGUID(UnitGUID("party4"), -20) end
				end)
			elseif sourceGUID and (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
				C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
					if UnitExists("arena1") then UpdateUnitAuraByUnitGUID(UnitGUID("arena1"), -20) end
					if UnitExists("arena2") then UpdateUnitAuraByUnitGUID(UnitGUID("arena2"), -20) end
					if UnitExists("arena3") then UpdateUnitAuraByUnitGUID(UnitGUID("arena3"), -20) end
					if UnitExists("arena4") then UpdateUnitAuraByUnitGUID(UnitGUID("arena4"), -20) end
					if UnitExists("arena5") then UpdateUnitAuraByUnitGUID(UnitGUID("arena5"), -20) end
				end)
			end
        end

        -----------------------------------------------------------------------------------------------------------------
        --Grounding Check (Totems Need a Spawn Time Check)
        -----------------------------------------------------------------------------------------------------------------
		if ((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (spellId == 204336) then
			local duration = 3
			local guid = destGUID
			local spawnTime
			local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
			if unitType == "Creature" or unitType == "Vehicle" then
			local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
			local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
			spawnTime = spawnEpoch + spawnEpochOffset
			--print("Grounding Totem Spawned at: "..spawnTime)
			end
			local expirationTime = GetTime() + duration
			if (Grounding[spawnTime] == nil) then --source becomes the totem ><
				Grounding[spawnTime] = {}
			end
			Grounding[spawnTime] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
			C_Timer.After(duration + .2, function()	-- execute in some close next frame to accurate use of UnitAura function
				Grounding[spawnTime] = nil
			end)
			if sourceGUID and not (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
				C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
					if UnitExists("player") then UpdateUnitAuraByUnitGUID(UnitGUID("player"), -20) end
					if UnitExists("party1") then UpdateUnitAuraByUnitGUID(UnitGUID("party1"), -20) end
					if UnitExists("party2") then UpdateUnitAuraByUnitGUID(UnitGUID("party2"), -20) end
					if UnitExists("party3") then UpdateUnitAuraByUnitGUID(UnitGUID("party3"), -20) end
					if UnitExists("party4") then UpdateUnitAuraByUnitGUID(UnitGUID("party4"), -20) end
				end)
			elseif sourceGUID and (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
				C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
					if UnitExists("arena1") then UpdateUnitAuraByUnitGUID(UnitGUID("arena1"), -20) end
					if UnitExists("arena2") then UpdateUnitAuraByUnitGUID(UnitGUID("arena2"), -20) end
					if UnitExists("arena3") then UpdateUnitAuraByUnitGUID(UnitGUID("arena3"), -20) end
					if UnitExists("arena4") then UpdateUnitAuraByUnitGUID(UnitGUID("arena4"), -20) end
					if UnitExists("arena5") then UpdateUnitAuraByUnitGUID(UnitGUID("arena5"), -20) end
				end)
			end
		end

		-----------------------------------------------------------------------------------------------------------------
		--WarBanner Check (Totems Need a Spawn Time Check)
		-----------------------------------------------------------------------------------------------------------------
		if ((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (spellId == 236320) then
			local duration = 15
			local expirationTime = GetTime() + duration

			if destGUID then
				if (WarBanner[destGUID] == nil) then
					WarBanner[destGUID] = {}
				end
				WarBanner[destGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
				C_Timer.After(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					WarBanner[destGUID] = nil
				end)
			end

			if destGUID then
				if (WarBanner[1] == nil) then
					WarBanner[1] = {}
				end
				WarBanner[1] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
				C_Timer.After(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					WarBanner[1] = nil
				end)
			end
		
			if sourceGUID then
				if (WarBanner[sourceGUID] == nil) then --source is friendly unit party12345 raid1...
					WarBanner[sourceGUID] = {}
				end
				WarBanner[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
				C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
					if UnitExists("player") then UpdateUnitAuraByUnitGUID(UnitGUID("player"), -20) end
					if UnitExists("party1") then UpdateUnitAuraByUnitGUID(UnitGUID("party1"), -20) end
					if UnitExists("party2") then UpdateUnitAuraByUnitGUID(UnitGUID("party2"), -20) end
					if UnitExists("party3") then UpdateUnitAuraByUnitGUID(UnitGUID("party3"), -20) end
					if UnitExists("party4") then UpdateUnitAuraByUnitGUID(UnitGUID("party4"), -20) end
				end)
				C_Timer.After(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
					WarBanner[sourceGUID] = nil
				end)
			end

			if destGUID then
				local guid = destGUID
				local spawnTime
				local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
				if unitType == "Creature" or unitType == "Vehicle" then
					local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
					local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
					spawnTime = spawnEpoch + spawnEpochOffset
					--print("WarBanner Totem Spawned at: "..spawnTime)
				end
				if (WarBanner[spawnTime] == nil) then --source becomes the totem ><
					WarBanner[spawnTime] = {}
				end
				WarBanner[spawnTime] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
				C_Timer.After(.2, function()	-- execute a second timer to ensure it catches
					if UnitExists("arena1") then UpdateUnitAuraByUnitGUID(UnitGUID("arena1"), -20) end
					if UnitExists("arena2") then UpdateUnitAuraByUnitGUID(UnitGUID("arena2"), -20) end
					if UnitExists("arena3") then UpdateUnitAuraByUnitGUID(UnitGUID("arena3"), -20) end
					if UnitExists("arena4") then UpdateUnitAuraByUnitGUID(UnitGUID("arena4"), -20) end
					if UnitExists("arena5") then UpdateUnitAuraByUnitGUID(UnitGUID("arena5"), -20) end
				end)
				C_Timer.After(duration +.2, function()	-- execute in some close next frame to accurate use of UnitAura function
					WarBanner[spawnTime] = nil
				end)
			end
		end

		-----------------------------------------------------------------------------------------------------------------
		--CLEU SUMMONS Spell Cast Check (if Cast dies it will not update currently, not sure how to track that)
		-----------------------------------------------------------------------------------------------------------------
		if (((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (cleuPrioCastedSpells[spellId])) then
			--print(event.." "..spellId.." "..GetSpellInfo(spellId).." "..(destName or ""))
			local priority, priorityArena, spellCategory, name
      	------------------------------------------Player/Party/Target/Etc-------------------------------------------------------------
			if cleuPrioCastedSpells[spellId].priority == nil then
				priority = nil
			else
				priority = LoseControlDB.priority[cleuPrioCastedSpells[spellId].priority]
				spellCategory = cleuPrioCastedSpells[spellId].priority
				name = cleuPrioCastedSpells[spellId].name
			end
			------------------------------------------Arena123-----------------------------------------------------------------------------
			if (sourceGUID == UnitGUID("arena1")) or (sourceGUID == UnitGUID("arena2")) or (sourceGUID == UnitGUID("arena3")) or (sourceGUID == UnitGUID("arena4")) or (sourceGUID == UnitGUID("arena5")) then
				if cleuPrioCastedSpells[spellId].priorityArena == nil then
					priority = nil
				else
					priority = LoseControlDB.priorityArena[cleuPrioCastedSpells[spellId].priorityArena]
					spellCategory = cleuPrioCastedSpells[spellId].priorityArena
					name = cleuPrioCastedSpells[spellId].nameArena
				end
	  		end

			local time = GetTime()

			--[[if spellId == 8143 then 
				if InterruptAuras[sourceGUID] then 
					for k, v in pairs(InterruptAuras[sourceGUID]) do
						if v.spellId == 8143 then
							InterruptAuras[sourceGUID][k].newtime = time
							InterruptAuras[sourceGUID][k] = nil
							Ctimer(.2, function()
								UpdateUnitAuraByUnitGUID(sourceGUID, -20)
								print("Tremor LC Recasted")
							end)
						end
					end
				end
			end]]



			--------------------------------------------------------------------------------------------------------------------------------
			if priority then
				local duration = cleuPrioCastedSpells[spellId].duration
				local expirationTime = GetTime() + duration
				if not InterruptAuras[sourceGUID]  then
					InterruptAuras[sourceGUID] = {}
				end
       			if not InterruptAuras[destGUID]  then
					InterruptAuras[destGUID] = {}
				end
				local namePrint, _, icon = GetSpellInfo(spellId)

				if spellId == 321686 then -- Mirror image
					icon = 135994
				end
				if spellId == 157299 or spellId == 157319 then --Strom Elemntal
					icon = 2065626
				end
				local guid = destGUID
				--print(sourceName.." Summoned "..namePrint.." "..substring(destGUID, -7).." for "..duration.." LC")

				--[[if spellId == 8143 then 
					local duration = 3
					local expirationTime = GetTime() + duration
					tblinsert(InterruptAuras[sourceGUID], { ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue, ["destGUID"] = destGUID, ["sourceName"] = sourceName, ["namePrint"] = namePrint, ["spell"] = spellId,  ["OldTime"] = time})
				else
					tblinsert(InterruptAuras[sourceGUID], { ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue, ["destGUID"] = destGUID, ["sourceName"] = sourceName, ["namePrint"] = namePrint, ["spell"] = spellId})
				end]]

				tblinsert(InterruptAuras[sourceGUID], { ["spellId"] = spellId, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue, ["destGUID"] = destGUID, ["sourceName"] = sourceName, ["namePrint"] = namePrint, ["spell"] = spellId})
				
				UpdateUnitAuraByUnitGUID(sourceGUID, -20)
				local ticker = 1
				self.ticker = C_Timer.NewTicker(.1, function()
					if InterruptAuras[sourceGUID] then
						for k, v in pairs(InterruptAuras[sourceGUID]) do
							if v.destGUID and v.spell ~= 394243 and v.spell ~= 387979 and v.spell ~= 394235 then --Dimensional Rift Hack
								if substring(v.destGUID, -5) == substring(guid, -5) then --string.sub is to help witj Mirror Images bug

								--[[if v.spellId == 8143 and InterruptAuras[sourceGUID].newtime and InterruptAuras[sourceGUID].newtime > v.OldTime then 
										InterruptAuras[sourceGUID][k] = nil
										UpdateUnitAuraByUnitGUID(sourceGUID, -20)
										self.ticker:Cancel()
										print("Deleted LC GUID Ticker")
										break
									end]]

									if ObjectDNE(v.destGUID) then
										--print(v.sourceName.." "..ObjectDNE(v.destGUID, ticker, v.namePrint, v.sourceName).." "..v.namePrint.." "..substring(v.destGUID, -7).." left w/ "..strformat("%.2f", v.expirationTime-GetTime()).." LC C_Ticker")
										InterruptAuras[sourceGUID][k] = nil
										UpdateUnitAuraByUnitGUID(sourceGUID, -20)
									break
									end
								end
							end
						end
					end
					ticker = ticker + 1
				end, duration * 10 + 5)
				--[[if spellId == 8143 then 
					self.Tremmor = C_Timer.NewTicker(3, function()
						local object
						if InterruptAuras[sourceGUID] then 
							for k, v in pairs(InterruptAuras[sourceGUID]) do
								if v.destGUID then --Dimensional Rift Hack
									if substring(v.destGUID, -5) == substring(guid, -5) then --string.sub is to help witj Mirror Images bug
										if v.spellId == 8143 and InterruptAuras[sourceGUID].newtime and InterruptAuras[sourceGUID].newtime > v.OldTime then 
											InterruptAuras[sourceGUID][k] = nil
											UpdateUnitAuraByUnitGUID(sourceGUID, -20)
											self.Tremmor:Cancel()
											--print("Deleted LC Tremmor Ticker")
											break
										end
										if ObjectDNE(v.destGUID) then
											--print(v.sourceName.." "..ObjectDNE(v.destGUID, ticker, v.namePrint, v.sourceName).." "..v.namePrint.." "..substring(v.destGUID, -7).." left w/ "..string.format("%.2f", v.expiration-GetTime()).." fPB C_Ticker")
											InterruptAuras[sourceGUID][k] = nil
											UpdateUnitAuraByUnitGUID(sourceGUID, -20)
											self.Tremmor:Cancel()
											--print("Killed LC Tremmor Ticker")
											break
										else
											local expirationTime = GetTime() + 3
											InterruptAuras[sourceGUID][k].expirationTime = expirationTime
											UpdateUnitAuraByUnitGUID(sourceGUID, -20)
											--print("Tremmor LC Pulse")
											break
										end
									end
								end
							end
						end
					end, 100)
				end]]
			end
		end


		-----------------------------------------------------------------------------------------------------------------
		--CLEU CASTED AURA Spell Cast Check (if Cast dies it will not update currently, not sure how to track that)
		-----------------------------------------------------------------------------------------------------------------
		if ((event =="SPELL_CAST_SUCCESS" and (spellId == 23989 or spellId == 11958 or spellId == 14185)) and (cleuPrioCastedSpells[spellId])) then --Readiness, Cold Snap, Prep
			local priority, priorityArena, spellCategory, name
			------------------------------------------Player/Party/Target/Etc-------------------------------------------------------------
			if cleuPrioCastedSpells[spellId].priority == nil then
				priority = nil
			else
				priority = LoseControlDB.priority[cleuPrioCastedSpells[spellId].priority]
				spellCategory = cleuPrioCastedSpells[spellId].priority
				name = cleuPrioCastedSpells[spellId].name
			end
			------------------------------------------Arena123-----------------------------------------------------------------------------
			if (sourceGUID == UnitGUID("arena1")) or (sourceGUID == UnitGUID("arena2")) or (sourceGUID == UnitGUID("arena3")) or (sourceGUID == UnitGUID("arena4")) or (sourceGUID == UnitGUID("arena5")) then
				if cleuPrioCastedSpells[spellId].priorityArena == nil then
					priority = nil
				else
					priority = LoseControlDB.priorityArena[cleuPrioCastedSpells[spellId].priorityArena]
					spellCategory = cleuPrioCastedSpells[spellId].priorityArena
					name = cleuPrioCastedSpells[spellId].nameArena
				end
			end
			--------------------------------------------------------------------------------------------------------------------------------
			if priority then
				local duration = cleuPrioCastedSpells[spellId].duration
				local expirationTime = GetTime() + duration
				if not InterruptAuras[sourceGUID]  then
					InterruptAuras[sourceGUID] = {}
				end
				if not InterruptAuras[destGUID]  then
					InterruptAuras[destGUID] = {}
				end
				local namePrint, _, icon = GetSpellInfo(spellId)

				local guid = destGUID
				--print(sourceName.." Summoned "..namePrint.." "..substring(destGUID, -7).." for "..duration.." LC")
				tblinsert(InterruptAuras[sourceGUID], { ["spellId"] = nil, ["name"] = name, ["duration"] = duration, ["expirationTime"] = expirationTime, ["priority"] = priority, ["spellCategory"] = spellCategory, ["icon"] = icon, ["spellSchool"] = spellSchool, ["hue"] = hue, ["destGUID"] = destGUID, ["sourceName"] = sourceName, ["namePrint"] = namePrint})
				UpdateUnitAuraByUnitGUID(sourceGUID, -20)
			end
		end

		-----------------------------------------------------------------------------------------------------------------
		--Cold Snap Reset (Resets Block/Barrier/Nova/CoC)
		-----------------------------------------------------------------------------------------------------------------
		if ((sourceGUID ~= nil) and (event == "SPELL_CAST_SUCCESS") and (spellId == 235219)) then
			local needUpdateUnitAura = false
			if (InterruptAuras[sourceGUID] ~= nil) then
				for k, v in pairs(InterruptAuras[sourceGUID]) do
					if v.spellSchool then
						if (bit_band(v.spellSchool, 16) > 0) then
							needUpdateUnitAura = true
							if (v.spellSchool > 16) then
								InterruptAuras[sourceGUID][k].spellSchool = InterruptAuras[sourceGUID][k].spellSchool - 16
							else
								InterruptAuras[sourceGUID][k] = nil
							end
						end
					end
				end
				if (next(InterruptAuras[sourceGUID]) == nil) then
					InterruptAuras[sourceGUID] = nil
				end
			end
			if needUpdateUnitAura then
				UpdateUnitAuraByUnitGUID(sourceGUID, -22)
			end
		end

	elseif (self.unitId == "targettarget" and self.unitGUID ~= nil and (not(LoseControlDB.disablePlayerTargetTarget) or (self.unitGUID ~= playerGUID)) and (not(LoseControlDB.disableTargetTargetTarget) or (self.unitGUID ~= LCframes.target.unitGUID))) or (self.unitId == "focustarget" and self.unitGUID ~= nil and (not(LoseControlDB.disablePlayerFocusTarget) or (self.unitGUID ~= playerGUID)) and (not(LoseControlDB.disableFocusFocusTarget) or (self.unitGUID ~= LCframes.focus.unitGUID))) then
		-- Manage targettarget/focustarget UNIT_AURA triggers
		local _, event, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
		if (destGUID ~= nil and destGUID == self.unitGUID) then
			if (event == "SPELL_AURA_APPLIED") or (event == "SPELL_PERIODIC_AURA_APPLIED") or
				(event == "SPELL_AURA_REMOVED") or (event == "SPELL_PERIODIC_AURA_REMOVED") or
				(event == "SPELL_AURA_APPLIED_DOSE") or (event == "SPELL_PERIODIC_AURA_APPLIED_DOSE") or
				(event == "SPELL_AURA_REMOVED_DOSE") or (event == "SPELL_PERIODIC_AURA_REMOVED_DOSE") or
				(event == "SPELL_AURA_REFRESH") or (event == "SPELL_PERIODIC_AURA_REFRESH") or
				(event == "SPELL_AURA_BROKEN") or (event == "SPELL_PERIODIC_AURA_BROKEN") or
				(event == "SPELL_AURA_BROKEN_SPELL") or (event == "SPELL_PERIODIC_AURA_BROKEN_SPELL") or
				(event == "UNIT_DIED") or (event == "UNIT_DESTROYED") or (event == "UNIT_DISSIPATES") then
				local timeCombatLogAuraEvent = GetTime()
				Ctimer(0.01, function()	-- execute in some close next frame to accurate use of UnitAura function
					if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent ~= timeCombatLogAuraEvent)) then
						self:UNIT_AURA(self.unitId, updatedAuras, 3)
					end
				end)
			end
		end
	end
end


-- This is the main event. Check for (de)buffs and update the frame icon and cooldown.
function LoseControl:UNIT_AURA(unitId, updatedAuras, typeUpdate, playerPrimaryspellCat) -- fired when a (de)buff is gained/lost
	if (((typeUpdate ~= nil and typeUpdate > 0) or (typeUpdate == nil and self.unitId == "targettarget") or (typeUpdate == nil and self.unitId == "focustarget")) and (self.lastTimeUnitAuraEvent == GetTime())) then return end
	if ((self.unitId == "targettarget" or self.unitId == "focustarget") and (not UnitIsUnit(unitId, self.unitId))) then return end
	local priority = LoseControlDB.priority
	local durationType = LoseControlDB.durationType
	local enabled = LoseControlDB.spellEnabled
	local customString = LoseControlDB.customString
	local spellIds = spellIds

	if strmatch(unitId, "arena") or ((UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) or (UnitGUID(unitId) == UnitGUID("arena4")) or (UnitGUID(unitId) == UnitGUID("arena5"))) then
		priority =  LoseControlDB.priorityArena
		durationType =  LoseControlDB.durationTypeArena
		enabled = LoseControlDB.spellEnabledArena
		spellIds = spellIdsArena
	end

	local maxPriority = 1
	local maxExpirationTime = 0
	local newExpirationTime = 0
	local maxPriorityIsInterrupt = false
	local Icon, Duration, Hue, Name, Spell, Count, Text, DispelType, SpellCategory
	local LayeredHue = nil
	local forceEventUnitAuraAtEnd = false
	local buffs= {} 
	self.lastTimeUnitAuraEvent = GetTime()


	if (self.anchor:IsVisible() or (self.frame.anchor ~= "None" and self.frame.anchor ~= "Blizzard")) and UnitExists(self.unitId) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disablePlayerTargetPlayerTargetTarget) or not(UnitIsUnit("player", "target")))) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disablePlayerTargetTarget) or not(UnitIsUnit("targettarget", "player")))) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disableTargetTargetTarget) or not(UnitIsUnit("targettarget", "target")))) and ((self.unitId ~= "targettarget") or (not(LoseControlDB.disableTargetDeadTargetTarget) or (UnitHealth("target") > 0))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disablePlayerFocusPlayerFocusTarget) or not(UnitIsUnit("player", "focus") and UnitIsUnit("player", "focustarget")))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disablePlayerFocusTarget) or not(UnitIsUnit("focustarget", "player")))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disableFocusFocusTarget) or not(UnitIsUnit("focustarget", "focus")))) and ((self.unitId ~= "focustarget") or (not(LoseControlDB.disableFocusDeadFocusTarget) or (UnitHealth("focus") > 0))) then
		local reactionToPlayer = ((self.unitId == "target" or self.unitId == "focus" or self.unitId == "targettarget" or self.unitId == "focustarget" or strfind(self.unitId, "arena")) and UnitCanAttack("player", unitId)) and "enemy" or "friendly"
		-- Check debuffs
		for i = 1, 40 do
			local localForceEventUnitAuraAtEnd = false
			local name, icon, count, dispelType, duration, expirationTime, source, _, _, spellId = UnitAura(unitId, i, "HARMFUL")
			local hue
			if not spellId then break end -- no more debuffs, terminate the loop
			if (self.unitId == "targettarget") or (self.unitId == "focustarget") then
				if debug then print(unitId, "debuff", i, ")", name, "|", duration, "|", expirationTime, "|", spellId) end
			end

			if duration == 0 and expirationTime == 0 then
				expirationTime = GetTime() + 1 -- normal expirationTime = 0
			elseif expirationTime > 0 then
				localForceEventUnitAuraAtEnd = (self.unitId == "targettarget")
			end
			-----------------------------------------------------------------------------------------------------------------
			--Finds all Snares in game
			-----------------------------------------------------------------------------------------------------------------
			if unitId == "player" and not spellIds[spellId] then
				if GetDebuffText(unitId, i) then
					print("Found New CC SNARE",spellId,"", name,"", snarestring)
					spellIds[spellId] = "Snare"
					local spellCategory = spellIds[spellId]
					local Priority = priority[spellCategory]
					local Name, instanceType, _, _, _, _, _, instanceID, _, _ = GetInstanceInfo()
					local ZoneName = GetZoneText()
					LoseControlDB.spellEnabled[spellId]= true
					tblinsert(LoseControlDB.customSpellIds, {spellId,  spellCategory, instanceType, Name.."\n"..ZoneName, nil, "Discovered", #L.spells})
					tblinsert(L.spells[#L.spells][tabsIndex["Snare"]], {spellId,  spellCategory, instanceType, Name.."\n"..ZoneName, nil, "Discovered", #L.spells})
					L.SpellsPVEConfig:UpdateTab(#L.spells-1)
					local locClass = "Creature"
					if source then
						local guid, name = UnitGUID(source), UnitName(source)
						local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
						if type == "Creature" then
							print(name .. "'s NPC id is " .. npc_id)
						elseif type == "Vignette" then
							print(name .. " is a Vignette and should have its npc_id be zero (" .. npc_id .. ").") --Vignette" refers to NPCs that appear as a rare when you first encounter them, but appear as a common after you've looted them once.
						elseif type == "Player" then
							local Class, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(guid)
							print(Class.." "..name .. " is a player.")
					  	else
						end
						locClass = Class
					else
					end
				end
			end


			if (not enabled[spellId]) and (not enabled[name]) then spellId = nil; name = nil end

			-----------------------------------------------------------------------------------------------------------------
			--[[Enemy Duel
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 207736 then --Shodowey Duel enemy on friendly, friendly frame (red)
				if DuelAura[UnitGUID(unitId)] then --enemyDuel
					name = "EnemyShadowyDuel"
					spellIds[spellId] = "Enemy_Smoke_Bomb"
					customString[spellId] = "Shadowy".."\n".."Duel"
					--print(unitId.."Duel is Enemy")
					if strmatch(unitId, "arena") or ((UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) or (UnitGUID(unitId) == UnitGUID("arena4")) or (UnitGUID(unitId) == UnitGUID("arena5"))) then
						spellIds[spellId] = "Special_High"
					end
				else
					--print(UnitGUID(unitId).."Duel is Friendly")
					name = "FriendlyShadowyDuel"
					spellIds[spellId] = "Friendly_Smoke_Bomb"
					customString[spellId] = "Shadowy".."\n".."Duel"
					if strmatch(unitId, "arena") or ((UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) or (UnitGUID(unitId) == UnitGUID("arena4")) or (UnitGUID(unitId) == UnitGUID("arena5"))) then
						spellIds[spellId] = "Special_High"
					end
	  			end
			end]]

			-----------------------------------------------------------------------------------------------------------------
			--SmokeBomb Check For Arena
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 88611 then -- Smoke Bomb
				if source and SmokeBombAuras[UnitGUID(source)] then
					--print(source)
					if UnitIsEnemy("player", source) then --still returns true for an enemy currently under mindcontrol I can add your fix.
						duration = SmokeBombAuras[UnitGUID(source)].duration --Add a check, i rogue bombs in stealth there is a source but the cleu doesnt regester a time
						expirationTime = SmokeBombAuras[UnitGUID(source)].expirationTime
						spellIds[spellId] = "Enemy_Smoke_Bomb"
						--print(unitId.."SmokeBombed is enemy check")
						if strmatch(unitId, "arena") or ((UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) or (UnitGUID(unitId) == UnitGUID("arena4")) or (UnitGUID(unitId) == UnitGUID("arena5"))) then
							--print(unitId.."Enemy SmokeBombed in Arean123 check")
							spellIds[spellId] = "Special_High"
						end
						name = "EnemySmokeBomb"
					elseif not UnitIsEnemy("player", source) then --Add a check, i rogue bombs in stealth there is a source but the cleu doesnt regester a time
						duration = SmokeBombAuras[UnitGUID(source)].duration --Add a check, i rogue bombs in stealth there is a source but the cleu doesnt regester a time
						expirationTime = SmokeBombAuras[UnitGUID(source)].expirationTime
						spellIds[spellId] = "Friendly_Smoke_Bomb"
						---customString[spellId] = "Friendly".."\n".."Smoke Bomb"
						if strmatch(unitId, "arena") or ((UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) or (UnitGUID(unitId) == UnitGUID("arena4")) or (UnitGUID(unitId) == UnitGUID("arena5"))) then
							--print(unitId.."Friendly SmokeBombed on Arean123 check")
							spellIds[spellId] = "Special_High" --
						end
					end
				else
					spellIds[spellId] = "Friendly_Smoke_Bomb"
					if strmatch(unitId, "arena") or ((UnitGUID(unitId) == UnitGUID("arena1")) or (UnitGUID(unitId) == UnitGUID("arena2")) or (UnitGUID(unitId) == UnitGUID("arena3")) or (UnitGUID(unitId) == UnitGUID("arena4")) or (UnitGUID(unitId) == UnitGUID("arena5"))) then
						spellIds[spellId] = "Special_High"
					end
				end
			end


			-----------------------------------------------------------------------------------------------------------------
			--Two debuff conidtions like Root Beam
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 81261 then
				local root = {}
				for i = 1, 40 do
					local _, _, _, _, d, e, _, _, _, s = UnitAura(unitId, i, "HARMFUL")
					if not s then break end
					if (spellIds[s] == "RootPhyiscal_Special") or (spellIds[s] == "RootMagic_Special") or (spellIds[s] == "Root") or (spellIds[s] == "Roots_90_Snares") then
						tblinsert(root, {["col1"] = e, ["col2"]  = d})
					end
				end
				if #root then
					tblsort(root, cmp_col1)
				end
				if root[1] then
					expirationTime = root[1].col1 + .01
					duration = root[1].col2
					if source and BeamAura[UnitGUID(source)] then
						if (expirationTime - GetTime()) >  (BeamAura[UnitGUID(source)].expirationTime - GetTime()) then
							duration = BeamAura[UnitGUID(source)].duration
							expirationTime =BeamAura[UnitGUID(source)].expirationTime + .01
						end
					end
				end
			end



			-----------------------------------------------------------------------------------------------------------------
			--Icon Changes
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 45524 then --Chains of Ice Dk
				--icon = 463560
				--icon = 236922
				icon = 236925
			end

			if spellId == 334693 then --Abosolute Zero Frost Dk Legendary Stun to Cube
				icon = 517161
			end

			if spellId == 317898 then -- Blinding Sleept Snare
				icon = 135864
			end
			
			if spellId == 317589 then --Mirros of Toremnt, Tormenting Backlash (Venthyr Mage) to Frost Jaw
				icon = 538562
			end
			
			if spellId == 199845 then --Psyflay
				icon = 537021
			end

			if spellId == 115196 then --Shiv
				icon = 135428
			end


			if spellId == 285515 then --Frost Shock to Frost Nove
				icon = 135848
			end

			if spellId == 7922 or spellId == 96273  then --charge
				icon = 132337
			end

			if spellId == 20253 then --Intercept
				--icon = 132307
			end

			if spellId == 5484 then --howl of terror
				icon = "Interface\\Icons\\ability_warlock_howlofterror"
			end


			-----------------------------------------------------------------------------
			--Prio Change Spell Id same for Friend and Enemey buff/debuff Hacks
			-----------------------------------------------------------------------------
			--[[if spellId == 325216 then
			spellIds[spellId] = "None" --Bonedust pop on enemy hide ,
			end]]

			-----------------------------------------------------------------------------------------------------------------
			--[[Prio Change Hide Surrander if Debuff
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 319952 then
				spellIds[spellId] = "None" --Surrander to Madness Pop on enemy hide
			end]]

			-----------------------------------------------------------------------------
			--Prio Change
			-----------------------------------------------------------------------------


			if spellId == 26679 then  -- dEADLY tHROW
				local tooltipData = CreateFrame("GameTooltip", "LCDThrowScanSpellDescTooltip", UIParent, "GameTooltipTemplate")
				tooltipData:SetOwner(UIParent, "ANCHOR_NONE")
				if nameplateID then
					tooltipData:SetUnitDebuff(unitId, i, "HARMFUL")
				else
					tooltipData:SetSpellByID(spellId)
				end
				local found
				for i = 1 , tooltipData:NumLines() do
					local text =_G["LCDThrowScanSpellDescTooltipTextLeft"..i]; 
					text = text:GetText()
					if text and (type(text == "string")) then
						if strfind(text, "70") then 
							found = true
						end
					end
				end
				if found then 
					spellIds[spellId] = "SnarePhysical70"
					count = 70
				else
					spellIds[spellId] = "SnarePhysical50"
				end
			end


			--[[
			if spellId == 702 then ----Amplify Curse's Weakness
				local tooltipData = C_TooltipInfo.GetUnitAura(unitId, i, "HARMFUL")
				TooltipUtil.SurfaceArgs(tooltipData)
		
				for _, line in ipairs(tooltipData.lines) do
					TooltipUtil.SurfaceArgs(line)
				end
				--print("Unit Aura: ", tooltipData.lines[1].leftText)
				--print("Aura Info: ", tooltipData.lines[2].leftText)
				if strfind(tooltipData.lines[2].leftText, "100") then
					spellIds[spellId] = "Dmg_Hit_Reduction"
					count = 100
				else
					spellIds[spellId] = "None"
				end
			end

			if spellId == 409560 then ---- Temporal Wound Snare
				local tooltipData = C_TooltipInfo.GetUnitAura(unitId, i, "HARMFUL")
				TooltipUtil.SurfaceArgs(tooltipData)
		
				for _, line in ipairs(tooltipData.lines) do
					TooltipUtil.SurfaceArgs(line)
				end
				--print("Unit Aura: ", tooltipData.lines[1].leftText)
				--print("Aura Info: ", tooltipData.lines[2].leftText)
				if strfind(tooltipData.lines[2].leftText, "70") then
					spellIds[spellId] = "SnarePhysical70"
				else
					spellIds[spellId] = "None"
				end
			end]]

			-----------------------------------------------------------------------------
			--Count Change
			-----------------------------------------------------------------------------
			--[[
			if spellId == 1714 then ----Amplify Curse's Tongues
				local tooltipData = C_TooltipInfo.GetUnitAura(unitId, i, "HARMFUL")
				TooltipUtil.SurfaceArgs(tooltipData)
		
				for _, line in ipairs(tooltipData.lines) do
					TooltipUtil.SurfaceArgs(line)
				end
				--print("Unit Aura: ", tooltipData.lines[1].leftText)
				--print("Aura Info: ", tooltipData.lines[2].leftText)
				if not strfind(tooltipData.lines[2].leftText, "10") then
					count = 20
				else

				end
			end
			]]

			if spellId == 79126 then --Groggy (Rogue)
				count = 70
			end  
		
			if spellId == 79124 then --Groggy (Rogue)
				count = 30
			end  

			-----------------------------------------------------------------------------------------------------------------
			--Hue Change
			-----------------------------------------------------------------------------------------------------------------
			--[[if spellId == 320035 then -- Mirros of Torment Haste Reduction
				hue = "Purple"
			end]]

			local spellCategory = spellIds[spellId] or spellIds[name]
			local Priority = priority[spellCategory]

			if self.frame.categoriesEnabled.debuff[reactionToPlayer][spellCategory] then
				if Priority then

					--if typeUpdate == -999 and (Priority >= priority["Root"] or Priority <= priority["SnarePhysical70"]) then 
					if typeUpdate == -999 and (
					(Priority == priority[playerPrimaryspellCat]) or -- Stops the Same Priority 
					(priority[playerPrimaryspellCat] <= priority["SnareSpecial"]) or  -- Stops Never Show Two Snares
					((priority[playerPrimaryspellCat] == priority["RootPhyiscal_Special"] or priority[playerPrimaryspellCat] == priority["RootMagic_Special"] or priority[playerPrimaryspellCat] == priority["Root"]) and 
					(Priority == priority["RootPhyiscal_Special"] or Priority == priority["RootMagic_Special"] or Priority == priority["Root"])) or   -- Stops Two Roots
					((priority[playerPrimaryspellCat] == priority["CC"] or priority[playerPrimaryspellCat] == priority["Silence"] or priority[playerPrimaryspellCat] == priority["RootPhyiscal_Special"] or priority[playerPrimaryspellCat] == priority["RootMagic_Special"] or priority[playerPrimaryspellCat] == priority["Root"]) and
					(Priority <= priority["SnarePhysical70"])) -- Stops Snares From Shwoing with CC, Silence, Roots
					) then

					else
					--Unseen Table Debuffs
						-----------------------------------------------------------------------------------------------------------------
						if strmatch(unitId, "arena") then
							if typeUpdate == -200 and UnitExists(unitId) then
								if not Arenastealth[unitId] then
									Arenastealth[unitId] = {}
								end
								--print(unitId, "Debuff Stealth Table Information Captured", name)
								tblinsert(Arenastealth[unitId],  {["col1"] = priority[spellCategory],["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["spellId"] = spellId, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }})
							end
						end
						---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						tblinsert(buffs,  {["col1"] = priority[spellCategory] ,["col2"]  = expirationTime , ["col3"] =  {["name"]=  name, ["spellId"] = spellId, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }}) -- this will create a table to show the highest duration debuffs
						---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						if not durationType[spellCategory] then     ----Something along these lines for highest duration vs newest table
							if Priority == maxPriority and expirationTime-duration > newExpirationTime then
								maxExpirationTime = expirationTime
								newExpirationTime = expirationTime - duration
								Duration = duration
								Icon = icon
								forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
								Hue = hue
								Name = name
								Count = count
								Spell = spellId
								SpellCategory = spellCategory
								if dispelType then DispelType = dispelType else DispelType = "none" end
								Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
							elseif Priority > maxPriority then
								maxPriority = Priority
								maxExpirationTime = expirationTime
								newExpirationTime = expirationTime - duration
								Duration = duration
								Icon = icon
								forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
								Hue = hue
								Name = name
								Count = count
								Spell = spellId
								SpellCategory = spellCategory
								if dispelType then DispelType = dispelType else DispelType = "none" end
								Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
							end
						elseif durationType[spellCategory] then
							if Priority == maxPriority and expirationTime > maxExpirationTime then
								maxExpirationTime = expirationTime
								newExpirationTime = expirationTime - duration
								Duration = duration
								Icon = icon
								forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
								Hue = hue
								Name = name
								Count = count
								Spell = spellId
								SpellCategory = spellCategory
								if dispelType then DispelType = dispelType else DispelType = "none" end
								Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
							elseif Priority > maxPriority then
								maxPriority = Priority
								maxExpirationTime = expirationTime
								newExpirationTime = expirationTime - duration
								Duration = duration
								Icon = icon
								forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
								Hue = hue
								Name = name
								Count = count
								Spell = spellId
								SpellCategory = spellCategory
								if dispelType then DispelType = dispelType else DispelType = "none" end
								Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
							end
						end
					end
				end
			end
		end

		-- Check buffs
		for i = 1, 40 do
			local localForceEventUnitAuraAtEnd = false
			local name, icon, count, dispelType, duration, expirationTime, source, _, _, spellId = UnitAura(unitId, i)
			local hue
			if not spellId then break end -- no more debuffs, terminate the loop
			if (not enabled[spellId]) and (not enabled[name]) then spellId = nil; name = nil end
			if debug then print(unitId, "buff", i, ")", name, "|", duration, "|", expirationTime, "|", spellId) end

			if duration == 0 and expirationTime == 0 then
				expirationTime = GetTime() + 1 -- normal expirationTime = 0
			elseif expirationTime > 0 then
				localForceEventUnitAuraAtEnd = (self.unitId == "targettarget")
			end

			-----------------------------------------------------------------------------------------------------------------
			--Barrier Add Timer Check For Arena
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 81782 then -- Barrier
				if source and Barrier[UnitGUID(source)] then
					duration = Barrier[UnitGUID(source)].duration
					expirationTime = Barrier[UnitGUID(source)].expirationTime
				end
			end

			-----------------------------------------------------------------------------------------------------------------
			--[[SGrounds Add Timer Check For Arena
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 289655 then -- SGrounds
				if source and SGrounds[UnitGUID(source)] then
					duration = SGrounds[UnitGUID(source)].duration
					expirationTime = SGrounds[UnitGUID(source)].expirationTime
				end
			end]]


			-----------------------------------------------------------------------------------------------------------------
			--Totems Add Timer Check For Arena
			-----------------------------------------------------------------------------------------------------------------

			--[[if spellId == 201633 then -- Earthen Totem (Totems Need a Spawn Time Check)
				if source then
					local guid = UnitGUID(source)
					local spawnTime
					local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
					if unitType == "Creature" or unitType == "Vehicle" then
						local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
						local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
						spawnTime = spawnEpoch + spawnEpochOffset
						--print("Earthen Buff Check at: "..spawnTime)
					end
					if Earthen[spawnTime] then
						duration = Earthen[spawnTime].duration
						expirationTime = Earthen[spawnTime].expirationTime
					end
				end
			end]]

			if spellId == 8178 then -- Grounding (Totems Need a Spawn Time Check)
				if source then
					local guid = UnitGUID(source)
					local spawnTime
					local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
					if unitType == "Creature" or unitType == "Vehicle" then
						local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
						local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
						spawnTime = spawnEpoch + spawnEpochOffset
						--print("Grounding Buff Check at: "..spawnTime)
					end
					if Grounding[spawnTime] then
						duration = Grounding[spawnTime].duration
						expirationTime = Grounding[spawnTime].expirationTime
					end
				end
			end

			if spellId == 871 then --Shield Wall Value
				local tooltipData = CreateFrame("GameTooltip", "LCDWallScanSpellDescTooltip", UIParent, "GameTooltipTemplate")
				tooltipData:SetOwner(UIParent, "ANCHOR_NONE")
				if unitId then
					tooltipData:SetUnitBuff(unitId, i, "HELPFUL")
				else
					tooltipData:SetSpellByID(spellId)
				end
				local found
				for i = 1 , tooltipData:NumLines() do
					local text =_G["LCDWallScanSpellDescTooltipTextLeft"..i]; 
					text = text:GetText()
					if text and (type(text == "string")) then
						if strfind(text, "60") then 
							found = true
						end
					end
				end
				if found then 
					count = 60
				else
					count = 40
				end
			end

			--[[if spellId == 236321 then -- WarBanner (Totems Need a Spawn Time Check)
				if source then
					local guid = UnitGUID(source)
					local spawnTime
					local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
					if unitType == "Creature" or unitType == "Vehicle" then
						local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
						local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
						spawnTime = spawnEpoch + spawnEpochOffset
						--print("WarBanner Buff Check at: "..spawnTime)
					end
					if WarBanner[spawnTime] then
						--print("Spawn: "..UnitName(source))
						duration = WarBanner[spawnTime].duration
						expirationTime = WarBanner[spawnTime].expirationTime
					elseif WarBanner[guid] then
						--print("guid: "..UnitName(source))
						duration = WarBanner[guid].duration 
						expirationTime = WarBanner[guid].expirationTime
					elseif WarBanner[1] then
						--print("1: "..UnitName(source))
						duration = WarBanner[1].duration 
						expirationTime = WarBanner[1].expirationTime
					end
				else
					--print("No WarBanner Source for: "..unitId)
					duration = WarBanner[1].duration 
					expirationTime = WarBanner[1].expirationTime
				end
			end]]

			-----------------------------------------------------------------------------------------------------------------
			--Two Buff conidtions Icy Veins Stacks
			-----------------------------------------------------------------------------------------------------------------
			
			if spellId == 74001 then --Combat Readiness
				for i = 1, 40 do
					local _, _, c, _, d, e, _, _, _, s = UnitAura(unitId, i, "HELPFUL")
					if not s then break end
					if s == 74002 then
						count = c
					end
				end
			end

			if spellId == 74002 then --Combat Readiness
				for i = 1, 40 do
					local _, _, c, _, d, e, _, _, _, s = UnitAura(unitId, i, "HELPFUL")
					if not s then break end
					if s == 74001 then
						spellId = nil
					else
						icon = 458725
					end
				end
			end

			--[[if spellId == 12472 then
				for i = 1, 40 do
					local _, _, c, _, d, e, _, _, _, s = UnitAura(unitId, i, "HELPFUL")
					if not s then break end
					if s == 382148 then
						count = c
					end
				end
			end


			if name == "Stealth" then
				for i = 1, 40 do
					local n, i, c, dt, d, e, so, _, _, s = UnitAura(unitId, i, "HELPFUL")
					if not s then break end
					if n == "Vanish" then
						name, icon, count, dispelType, duration, expirationTime, source, _, _, spellId = n, i, c, dt, d, e, so, _, _, s
					end
				end
			end]]


			-----------------------------------------------------------------------------
			--Mass Invis
			------------------------------------------------------------------------------
			--[[if (spellId == 198158 or spellId == 414664) then --Mass Invis Hack
				if source then
					if (UnitGUID(source) ~= UnitGUID(unitId)) then
						duration = 5
				  		expirationTime = GetTime() + duration
					end
				end
			end]]

			-----------------------------------------------------------------------------
			--Player Only Hacks to Disable on party12 or Target, Focus, Pet and Player Frame
			------------------------------------------------------------------------------
			--[[if strmatch(unitId, "arena") then
			else
				if (spellId == 331937) or (spellId == 354054) then --Euphoria Venthyr Haste Buff Hack or Fatal Flaw Versa
					if unitId ~= "player" then
						spellIds[spellId] = "None"
					else
						spellIds[spellId] = "Movable_Cast_Auras"
					end
				end]]

				--[[if (spellId == 213610) then --Hide Holy Ward
					if unitId == "player" then
						spellIds[spellId] = "None"
					elseif strmatch(unitId, "arena") then
						spellIds[spellId] = "Small_Defensive_CDs"
					else
						spellIds[spellId] = "CC_Reduction"
					end
				end]]

				--[[if (spellId == 332505) then --Soulsteel Clamps Hack player Only
					if unitId ~= "player" then
						spellIds[spellId] = "None"
					elseif strmatch(unitId, "arena") then
						spellIds[spellId] = "Small_Defensive_CDs"
					else
						spellIds[spellId] = "Movable_Cast_Auras"
					end
				end

				if (spellId == 332506) then --Soulsteel Clamps Hack player Only
					if unitId ~= "player" then
						spellIds[spellId] = "None"
					elseif strmatch(unitId, "arena") then
						spellIds[spellId] = "Small_Defensive_CDs"
					else
						spellIds[spellId] = "Movable_Cast_Auras"
					end
				end
			end]]

			-----------------------------------------------------------------------------------------------------------------
			--Icon Changes
			-----------------------------------------------------------------------------------------------------------------
			
			if spellId == 329543 then --Divine Ascension
				icon = 2103871 --618976 -- or 590341
			end

			if spellId == 328530 then --Divine Ascension
				icon = 2103871 --618976 -- or 590341
			end

			if spellId == 317929 then --Aura Mastery Cast Immune Pally
				icon = 135863
			end

			if spellId == 199545 then --Steed of Glory Hack
					icon = 135890
			end

			if spellId == 387636 then --Soulburn Healthstone
				icon = 538745
			end

			if spellId == 385391 then --Spell Reflection 20% Wall
				icon = 135995
			end

			
			if name == "Feral Charge - Bear" then --Feral Charge Effect (Feral Charge talent)
				icon = 136091
			end
			
			if name == "Feral Charge Effect" then --Feral Charge Effect (Feral Charge talent)
				icon = 136091
			end

			if spellId == 63087 then --raptor strike dmg reduced
				icon = 136094
			end

			if spellId == 87153 then --dark archangel
				icon = "Interface\\Icons\\ability_priest_darkarchangel"
			end

			if spellId == 96267 then --ineer focus aura mastery
				icon = 237544
			end

			
			if spellId == 55277 then --stoneclaw totem
				icon = 136097
			end

			-----------------------------------------------------------------------------
			--Prio Change: Same Spell Id , Differnt Spec
			------------------------------------------------------------------------------
			--[[if (spellId == 31884) then --Avenging Wrath
				local i, specID
				if strmatch(unitId, "arena") then
					i = strfind(unitId, "%d")
							specID = GetArenaOpponentSpec(i);
					if specID then
						if (specID == 70) or (specID == 66) then
							--print("Ret Wings Active "..unitId)
							spellIds[spellId] = "Big_Defensive_CDs" --Ranged_Major_OffenisiveCDs Sets Prio to Ret/Prot Wings to DMG
						else
							--print("Holy Wings Active "..unitId)
							spellIds[spellId] = "Big_Defensive_CDs" --Sets Prio to Holyw Wings to Defensive
						end
					end
				end
			end]]

			--[[if (spellId == 310454) then --Weapons of Order
				local i, specID
				if strmatch(unitId, "arena") then
					i = strfind(unitId, "%d")
							specID = GetArenaOpponentSpec(i);
					if specID then
						if (specID == 269) or (specID == 268) then
							--print("WW Weapons Active "..unitId)
							spellIds[spellId] = "Melee_Major_OffenisiveCDs" --Ranged_Major_OffenisiveCDs Sets Prio to Ret/Prot Wings to DMG
						else
							--print("MW Weapons Active "..unitId)
							spellIds[spellId] = "None" --Sets Prio to Holy Wings to Defensive
						end
					end
				end
			end]]

			-----------------------------------------------------------------------------------------------------------------
			--Prio Change: Buff
			-----------------------------------------------------------------------------------------------------------------
			--[[if spellId == 205630 then
				spellIds[spellId] = "None" --I'lldians Grasp Hide CC on Friends
			end

			if spellId == 319952 then
				spellIds[spellId] = "Ranged_Major_OffenisiveCDs" --Surrander to Madness Pop on enemy hide
				if unitId == "player" then
					spellIds[spellId] = "Personal_Offensives"
				end
			end]]

			-----------------------------------------------------------------------------------------------------------------
			--Count Editing
			-----------------------------------------------------------------------------------------------------------------

			--[[if spellId == 248646 then -- WW Tiger Eye Stacks, Removes Timer
				duration = 0
				expirationTime = GetTime() + 1
			end

			if spellId == 247676 then -- Reckoning Ret Stacks, Removes Timer
				duration = 0
				expirationTime = GetTime() + 1
			end

			if spellId == 334320 then -- Lock Drain LIfe Stacks, Removes Timer  247676
				duration = 0
				expirationTime = GetTime() + 1
			end]]

			-----------------------------------------------------------------------------w
			--Ghost Wolf hack for Spectral Recovery and Spirit Wolf
			------------------------------------------------------------------------------
			--[[if spellId == 2645 then
				local ghostwolf = {}
				for i = 1, 40 do
					local _, _, c, _, _, _, _, _, _, s = UnitAura(unitId, i, "HELPFUL")
					if not s then break end
					if s == 204262 or s == 260881 then
						tblinsert(ghostwolf, {s, c})
					end
				end
				if #ghostwolf == 2 then
					if ghostwolf[1][1] == 260881 then
						count = ghostwolf[1][2]
					else
						count = ghostwolf[2][2]
					end
					hue = "GhostPurple"
				elseif #ghostwolf == 1 then
					if ghostwolf[1][1] == 260881 then --Just Spirit Wolf
						count = ghostwolf[1][2]
					elseif ghostwolf[1][1] == 204262 then -- Just Spectral Recovery
						hue = "GhostPurple"
					end
				end
			end]]

			local spellCategory = spellIds[spellId] or spellIds[name]
			local Priority = priority[spellCategory]


			if self.frame.categoriesEnabled.buff[reactionToPlayer][spellCategory] then
				if Priority then
					--if typeUpdate == -999 and (Priority >= priority["Root"] or Priority <= priority["SnarePhysical70"]) then 
					if typeUpdate == -999 and (
					(Priority == priority[playerPrimaryspellCat]) or -- Stops the Same Priority 
					(priority[playerPrimaryspellCat] <= priority["SnareSpecial"]) or  -- Stops Never Show Two Snares
					((priority[playerPrimaryspellCat] == priority["RootPhyiscal_Special"] or priority[playerPrimaryspellCat] == priority["RootMagic_Special"] or priority[playerPrimaryspellCat] == priority["Root"]) and 
					(Priority == priority["RootPhyiscal_Special"] or Priority == priority["RootMagic_Special"] or Priority == priority["Root"])) or   -- Stops Two Roots
					((priority[playerPrimaryspellCat] == priority["CC"] or priority[playerPrimaryspellCat] == priority["Silence"] or priority[playerPrimaryspellCat] == priority["RootPhyiscal_Special"] or priority[playerPrimaryspellCat] == priority["RootMagic_Special"] or priority[playerPrimaryspellCat] == priority["Root"]) and
					(Priority <= priority["SnarePhysical70"])) -- Stops Snares From Shwoing with CC, Silence, Roots
					) then

					else
						-----------------------------------------------------------------------------------------------------------------
						--Unseen Table Debuffs
						-----------------------------------------------------------------------------------------------------------------
						if strmatch(unitId, "arena") then
							if typeUpdate == -200 and UnitExists(unitId) then
								if not Arenastealth[unitId] then
									Arenastealth[unitId] = {}
								end
								--print(unitId, "Buff Stealth Table Information Captured", name)
								tblinsert(Arenastealth[unitId],  {["col1"] = priority[spellCategory] ,["col2"]  = expirationTime , ["col3"] =  {["name"] =  name, ["spellId"] = spellId, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }})
							end
						end
						---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						tblinsert(buffs,  {["col1"] = priority[spellCategory] ,["col2"]  = expirationTime , ["col3"] =  {["name"] =  name, ["spellId"] = spellId, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }}) -- this will create a table to show the highest duration buffs
						---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						if not durationType[spellCategory] then     ----Something along these lines for highest duration vs newest table
							if Priority == maxPriority and expirationTime-duration > newExpirationTime then
								maxExpirationTime = expirationTime
								newExpirationTime = expirationTime - duration
								Duration = duration
								Icon = icon
								forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
								Hue = hue
								Name = name
								Count = count
								Spell = spellId
								SpellCategory = spellCategory
								DispelType = "Buff"
								Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
							elseif Priority > maxPriority then
								maxPriority = Priority
								maxExpirationTime = expirationTime
								newExpirationTime = expirationTime - duration
								Duration = duration
								Icon = icon
								forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
								Hue = hue
								Name = name
								Count = count
								Spell = spellId
								SpellCategory = spellCategory
								DispelType = "Buff"
								Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
							end
						elseif durationType[spellCategory] then
							if Priority == maxPriority and expirationTime > maxExpirationTime then
								maxExpirationTime = expirationTime
								newExpirationTime = expirationTime - duration
								Duration = duration
								Icon = icon
								forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
								Hue = hue
								Name = name
								Count = count
								Spell = spellId
								SpellCategory = spellCategory
								DispelType = "Buff"
								Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
							elseif Priority > maxPriority then
								maxPriority = Priority
								maxExpirationTime = expirationTime
								newExpirationTime = expirationTime - duration
								Duration = duration
								Icon = icon
								forceEventUnitAuraAtEnd = localForceEventUnitAuraAtEnd
								Hue = hue
								Name = name
								Count = count
								Spell = spellId
								SpellCategory = spellCategory
								DispelType = "Buff"
								Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
							end
						end
					end
				end
			end
		end

		-- Check interrupts or cleu
		if ((self.unitGUID ~= nil) and (UnitIsPlayer(unitId) or (((unitId ~= "target") or (LoseControlDB.showNPCInterruptsTarget)) and ((unitId ~= "focus") or (LoseControlDB.showNPCInterruptsFocus)) and ((unitId ~= "targettarget") or (LoseControlDB.showNPCInterruptsTargetTarget)) and ((unitId ~= "focustarget") or (LoseControlDB.showNPCInterruptsFocusTarget))))) then
			local spellSchoolInteruptsTable = {
				[1] = {false, 0},
				[2] = {false, 0},
				[4] = {false, 0},
				[8] = {false, 0},
				[16] = {false, 0},
				[32] = {false, 0},
				[64] = {false, 0}
			}
			if (InterruptAuras[self.unitGUID] ~= nil) then
				for k, v in pairs(InterruptAuras[self.unitGUID]) do
					local Priority = v.priority
					local spellCategory = v.spellCategory
					local expirationTime = v.expirationTime
					local duration = v.duration
					local icon = v.icon
					local spellSchool = v.spellSchool
					local hue = v.hue
					local name = v.name
					local spellId = v.spellId
					if (not enabled[spellId]) and (not enabled[name]) then spellId = nil; name = nil; Priority = 0 end
					if spellCategory ~= "Interrupt" and ((Priority == 0) or (not self.frame.categoriesEnabled.buff[reactionToPlayer][spellCategory])) then
						if (expirationTime < GetTime()) then
							InterruptAuras[self.unitGUID][k] = nil
							if (next(InterruptAuras[self.unitGUID]) == nil) then
								InterruptAuras[self.unitGUID] = nil
							end
						end
					elseif (spellCategory == "Interrupt") and ((Priority == 0) or (not self.frame.categoriesEnabled.interrupt[reactionToPlayer])) then
						if (expirationTime < GetTime()) then
							InterruptAuras[self.unitGUID][k] = nil
							if (next(InterruptAuras[self.unitGUID]) == nil) then
								InterruptAuras[self.unitGUID] = nil
							end
						end
					else
						if Priority then
							--if typeUpdate == -999 and (Priority >= priority["Root"] or Priority <= priority["SnarePhysical70"]) then 
							if typeUpdate == -999 and (
							(Priority == priority[playerPrimaryspellCat]) or -- Stops the Same Priority 
							(priority[playerPrimaryspellCat] <= priority["SnareSpecial"]) or  -- Stops Never Show Two Snares
							((priority[playerPrimaryspellCat] == priority["RootPhyiscal_Special"] or priority[playerPrimaryspellCat] == priority["RootMagic_Special"] or priority[playerPrimaryspellCat] == priority["Root"]) and 
							(Priority == priority["RootPhyiscal_Special"] or Priority == priority["RootMagic_Special"] or Priority == priority["Root"])) or   -- Stops Two Roots
							((priority[playerPrimaryspellCat] == priority["CC"] or priority[playerPrimaryspellCat] == priority["Silence"] or priority[playerPrimaryspellCat] == priority["RootPhyiscal_Special"] or priority[playerPrimaryspellCat] == priority["RootMagic_Special"] or priority[playerPrimaryspellCat] == priority["Root"]) and
							(Priority <= priority["SnarePhysical70"])) -- Stops Snares From Shwoing with CC, Silence, Roots
							) then

							else
							-----------------------------------------------------------------------------------------------------------------
							--Unseen Table CLEU
							-----------------------------------------------------------------------------------------------------------------
								if strmatch(unitId, "arena") then
									if typeUpdate == -200 and UnitExists(unitId) then
										if not Arenastealth[unitId] then
											Arenastealth[unitId] = {}
										end
										--print(unitId, "cleu Stealth Table Information Captured", name)
										local localForceEventUnitAuraAtEnd = false
										tblinsert(Arenastealth[unitId],  {["col1"] = Priority ,["col2"]  = expirationTime , ["col3"] =  {["name"] =  name, ["spellId"] = spellId, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue,  }})
									end
								end
								---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
								local localForceEventUnitAuraAtEnd = false
								tblinsert(buffs,  {["col1"] = Priority ,["col2"]  = expirationTime , ["col3"] =  {["name"] =  name, ["spellId"] = spellId, ["duration"] = duration, ["expirationTime"] = expirationTime,  ["icon"] = icon, ["localForceEventUnitAuraAtEnd"] = localForceEventUnitAuraAtEnd, ["hue"] = hue }}) -- this will create a table to show the highest duration cleu
								---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
								if spellSchool then -- Stop Interrupt Check when Trees Prio or SPELL_CAST_SUCCESS event
									for schoolIntId, _ in pairs(spellSchoolInteruptsTable) do
										if (bit_band(spellSchool, schoolIntId) > 0) then
											spellSchoolInteruptsTable[schoolIntId][1] = true
											if expirationTime > spellSchoolInteruptsTable[schoolIntId][2] then
												spellSchoolInteruptsTable[schoolIntId][2] = expirationTime
											end
										end
									end
								end
								if not durationType[spellCategory] then
									if Priority == maxPriority and expirationTime-duration > newExpirationTime then
										maxExpirationTime = expirationTime
										newExpirationTime = expirationTime - duration
										Duration = duration
										Icon = icon
										maxPriorityIsInterrupt = true
										forceEventUnitAuraAtEnd = false
										Hue = hue
										Name = name
										Count = count
										Spell = spellId
										SpellCategory = spellCategory
										DispelType = "CLEU"
										Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
										local nextTimerUpdate = expirationTime - GetTime() + 0.05
										if nextTimerUpdate < 0.05 then
											nextTimerUpdate = 0.05
										end
										Ctimer(nextTimerUpdate, function()
											if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
												self:UNIT_AURA(unitId, updatedAuras, 20)
											end
											for e, f in pairs(InterruptAuras) do
												for g, h in pairs(f) do
													if (h.expirationTime < GetTime()) then
														InterruptAuras[e][g] = nil
													end
												end
												if (next(InterruptAuras[e]) == nil) then
													InterruptAuras[e] = nil
												end
											end
										end)
									elseif Priority > maxPriority then
										maxPriority = Priority
										maxExpirationTime = expirationTime
										newExpirationTime = expirationTime - duration
										Duration = duration
										Icon = icon
										maxPriorityIsInterrupt = true
										forceEventUnitAuraAtEnd = false
										Hue = hue
										Name = name
										Count = count
										Spell = spellId
										SpellCategory = spellCategory
										DispelType = "CLEU"
										Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
										local nextTimerUpdate = expirationTime - GetTime() + 0.05
										if nextTimerUpdate < 0.05 then
											nextTimerUpdate = 0.05
										end
										Ctimer(nextTimerUpdate, function()
											if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
												self:UNIT_AURA(unitId, updatedAuras, 20)
											end
											for e, f in pairs(InterruptAuras) do
												for g, h in pairs(f) do
													if (h.expirationTime < GetTime()) then
														InterruptAuras[e][g] = nil
													end
												end
												if (next(InterruptAuras[e]) == nil) then
													InterruptAuras[e] = nil
												end
											end
										end)
									end
								elseif durationType[spellCategory] then
									if Priority == maxPriority and expirationTime > maxExpirationTime then
										maxExpirationTime = expirationTime
										newExpirationTime = expirationTime - duration
										Duration = duration
										Icon = icon
										maxPriorityIsInterrupt = true
										forceEventUnitAuraAtEnd = false
										Hue = hue
										Name = name
										Count = count
										Spell = spellId
										SpellCategory = spellCategory
										DispelType = "CLEU"
										Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
										local nextTimerUpdate = expirationTime - GetTime() + 0.05
										if nextTimerUpdate < 0.05 then
											nextTimerUpdate = 0.05
										end
										Ctimer(nextTimerUpdate, function()
											if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
												self:UNIT_AURA(unitId, updatedAuras, 20)
											end
											for e, f in pairs(InterruptAuras) do
												for g, h in pairs(f) do
													if (h.expirationTime < GetTime()) then
														InterruptAuras[e][g] = nil
													end
												end
												if (next(InterruptAuras[e]) == nil) then
													InterruptAuras[e] = nil
												end
											end
										end)
									elseif Priority > maxPriority then
										maxPriority = Priority
										maxExpirationTime = expirationTime
										newExpirationTime = expirationTime - duration
										Duration = duration
										Icon = icon
										maxPriorityIsInterrupt = true
										forceEventUnitAuraAtEnd = false
										Hue = hue
										Name = name
										Count = count
										Spell = spellId
										SpellCategory = spellCategory
										DispelType = "CLEU"
										Text = customString[spellId] or customString[name] or string[spellId] or defaultString[spellCategory]
										local nextTimerUpdate = expirationTime - GetTime() + 0.05
										if nextTimerUpdate < 0.05 then
											nextTimerUpdate = 0.05
										end
										Ctimer(nextTimerUpdate, function()
											if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.04))) then
												self:UNIT_AURA(unitId, updatedAuras, 20)
											end
											for e, f in pairs(InterruptAuras) do
												for g, h in pairs(f) do
													if (h.expirationTime < GetTime()) then
														InterruptAuras[e][g] = nil
													end
												end
												if (next(InterruptAuras[e]) == nil) then
													InterruptAuras[e] = nil
												end
											end
										end)
									end
								end
							end
						end
					end
				end
			end
			if _G.LoseControlDB.InterruptIcons then
				for schoolIntId, schoolIntFrame in pairs(self.iconInterruptList) do
					if spellSchoolInteruptsTable[schoolIntId][1] then
						if (not schoolIntFrame:IsShown()) then
							schoolIntFrame:Show()
						end
						local orderInt = 1
						for schoolInt2Id, schoolInt2Info in pairs(spellSchoolInteruptsTable) do
							if ((schoolInt2Info[1]) and ((spellSchoolInteruptsTable[schoolIntId][2] < schoolInt2Info[2]) or ((spellSchoolInteruptsTable[schoolIntId][2] == schoolInt2Info[2]) and (schoolIntId > schoolInt2Id)))) then
								orderInt = orderInt + 1
							end
						end
						schoolIntFrame:SetPoint("BOTTOMRIGHT", self.interruptIconOrderPos[orderInt][1], self.interruptIconOrderPos[orderInt][2])
						schoolIntFrame.interruptIconOrder = orderInt
					elseif schoolIntFrame:IsShown() then
						schoolIntFrame.interruptIconOrder = nil
						schoolIntFrame:Hide()
					end
				end
			end
		end
	end

	----------------------------------------------------------------------
	--Filters for highest aura duration of specfied priority will not work for cleu , currently set for all snares
	----------------------------------------------------------------------
	if #buffs then
		tblsort(buffs, cmp_col1)
		tblsort(buffs, cmp_col1_col2)
	end

	----------------------------------------------------------------------
	--transfer stealth table to buffs
	----------------------------------------------------------------------
	if Arenastealth[unitId] and (not UnitExists(unitId)) then
		for i = 1, #Arenastealth[unitId] do
			buffs[i] =  {["col1"] = Arenastealth[unitId][i].col1 , ["col2"]  = Arenastealth[unitId][i].col2 , ["col3"] = { ["name"] = Arenastealth[unitId][i].col3.name, ["spellId"] = Arenastealth[unitId][i].col3.spellId, ["duration"] = Arenastealth[unitId][i].col3.duration, ["expirationTime"] = Arenastealth[unitId][i].col3.expirationTime,  ["icon"] = Arenastealth[unitId][i].col3.icon, ["localForceEventUnitAuraAtEnd"] = Arenastealth[unitId][i].col3.localForceEventUnitAuraAtEnd, ["hue"] = Arenastealth[unitId][i].col3.hue }}
		end
		tblsort(buffs, cmp_col1)
		tblsort(buffs, cmp_col1_col2)
	end

	-----------------------------------------------------------------------
	--Stealth Filter What to show while unseen Arena Opponents
	-------------------------------------------------------------------------
	if (not UnitExists(unitId)) then
   		 if strmatch(unitId, "arena") then
			if Arenastealth[unitId] and #buffs then
				local foundbuff = 0
				for i = 1, #buffs do
					if ((buffs[i].col3.expirationTime > GetTime() + .10) and (buffs[i].col3.duration ~= 0 ) and (buffs[i].col1 >= priority.Special_High)) then --Special_High is Stealth for Arena
						maxExpirationTime = buffs[i].col3.expirationTime
						Duration = buffs[i].col3.duration
						Icon = buffs[i].col3.icon
						forceEventUnitAuraAtEnd = false
						Hue = buffs[i].col3.hue
						Name = buffs[i].col3.name
						local nextTimerUpdate = (buffs[i].col3.expirationTime - GetTime()) + 0.05
						if nextTimerUpdate < 0.05 then
							nextTimerUpdate = 0.05
						end
						Ctimer(nextTimerUpdate, function()
								self:UNIT_AURA(unitId, updatedAuras, -5)
						end)
						foundbuff = 1
						--print(unitId, "Unseen or Stealth w/", buffs[i].col3.name)
						break
					elseif ((buffs[i].col1 == priority.Special_High and StealthTable[buffs[i].col3.spellId]) or (buffs[i].col3.name == "FriendlyShadowyDuel") or (buffs[i].col3.name == "EnemyShadowyDuel")) then --and ((duration == 0) or (buffs[i].col3.expirationTime < (GetTime() + .10))) then
						maxExpirationTime = GetTime() + 1
						Duration = 0
						Icon = buffs[i].col3.icon
						forceEventUnitAuraAtEnd = false
						Hue = buffs[i].col3.hue
						Name = buffs[i].col3.name
						foundbuff = 1
						--print(unitId, "Permanent Stealthed w/", buffs[i].col3.name)
						break
					elseif ((buffs[i].col3.expirationTime > GetTime() + .10) and (buffs[i].col3.duration ~= 0 ) and (buffs[i].col1 <= priority.Special_High and not StealthTable[buffs[i].col3.spellId])) then
						maxExpirationTime = buffs[i].col3.expirationTime
						Duration = buffs[i].col3.duration
						Icon = buffs[i].col3.icon
						forceEventUnitAuraAtEnd = false
						Hue = buffs[i].col3.hue
						Name = buffs[i].col3.name
						local nextTimerUpdate = (buffs[i].col3.expirationTime - GetTime()) + 0.05
						if nextTimerUpdate < 0.05 then
							nextTimerUpdate = 0.05
						end
						Ctimer(nextTimerUpdate, function()
								self:UNIT_AURA(unitId, updatedAuras, -5)
						end)
						foundbuff = 1
						--print(unitId, "Unseen or Stealth w/", buffs[i].col3.name)
						break
					end
				end
				if foundbuff == 0 then
					maxExpirationTime = 0
					Duration = Duration
					Icon = Icon
					forceEventUnitAuraAtEnd = forceEventUnitAuraAtEnd
					Hue = Hue
					Name = Name
					--print(unitId, "No Stealth Buff Found")
					if unitId == "arena1" and GladiusClassIconFramearena1 and GladiusHealthBararena1 then
						GladiusClassIconFramearena1:SetAlpha(GladiusHealthBararena1:GetAlpha())
						if GladdyButtonFrame1 then GladdyButtonFrame1:SetAlpha(GladiusHealthBararena1:GetAlpha()) end
					end
					if unitId == "arena2" and GladiusClassIconFramearena2 and GladiusHealthBararena2 then
						GladiusClassIconFramearena2:SetAlpha(GladiusHealthBararena2:GetAlpha())
						if GladdyButtonFrame2 then GladdyButtonFrame2:SetAlpha(GladiusHealthBararena2:GetAlpha()) end
					end
					if unitId == "arena3" and GladiusClassIconFramearena3 and GladiusHealthBararena3 then
						GladiusClassIconFramearena3:SetAlpha(GladiusHealthBararena3:GetAlpha())
							if GladdyButtonFrame3 then GladdyButtonFrame3:SetAlpha(GladiusHealthBararena3:GetAlpha()) end
					end
					if unitId == "arena4" and GladiusClassIconFramearena4 and GladiusHealthBararena4 then
						GladiusClassIconFramearena4:SetAlpha(GladiusHealthBararena4:GetAlpha())
						if GladdyButtonFrame4 then GladdyButtonFrame4:SetAlpha(GladiusHealthBararena4:GetAlpha()) end
					end
					if unitId == "arena5" and GladiusClassIconFramearena5 and GladiusHealthBararena5 then
						GladiusClassIconFramearena5:SetAlpha(GladiusHealthBararena5:GetAlpha())
						if GladdyButtonFrame5 then GladdyButtonFrame5:SetAlpha(GladiusHealthBararena5:GetAlpha()) end
					end
				end
			end
		end
	end

	for i = 1, #buffs do --creates a layered hue for every icon when a specific priority, or spellid is present
		if not buffs[i] then break end
			if (buffs[i].col3.name == "EnemySmokeBomb") or (buffs[i].col3.name == "EnemyShadowyDuel") then --layered hue conidition
				if buffs[i].col3.expirationTime > GetTime() then
					if LoseControlDB.RedSmokeBomb then
						LayeredHue = true
						self.LayeredHue = true
						Hue = "Red"
					end
				local remaining = buffs[i].col3.expirationTime - GetTime() -- refires on layer exit, to reset the icons
				if  remaining  < 0.05 then
					 remaining  = 0.05
				end
				Ctimer(remaining + .05, function() self:UNIT_AURA(unitId, updatedAuras, -55) end)
			end
		end
	end

	if typeUpdate == -999 then 
		SecondaryIconData = {["maxPriority"] = maxPriority, ["maxExpirationTime"] = maxExpirationTime, ["newExpirationTime"] = newExpirationTime, ["Duration"] = Duration, ["Icon"] = Icon, ["forceEventUnitAuraAtEnd"] = forceEventUnitAuraAtEnd, ["Hue"] = Hue, ["Name"] = Name, ["Count"] = Count, ["DispelType"] = DispelType, ["Text"] = Text, ["Spell"] = Spell, ["LayeredHue"] = LayeredHue,  ["SpellCategory"] = SpellCategory}
		return 
	end

	if self.LayeredHue then -- refires the icon to remove the hue for LayeredHUe if the BUff is Removed that trigeers Layered Hue and there Higher Prio Buff Above it w/ Same Expiration
		if not LayeredHue then
			self.LayeredHue = nil
			LayeredHue = true
		end
	end

	if (maxExpirationTime == 0) then -- no (de)buffs found
		self.maxExpirationTime = 0
    	if self.anchor ~= UIParent and self.drawlayer then
			if self.drawanchor == self.anchor and self.anchor.GetDrawLayer and self.anchor.SetDrawLayer then
				self.anchor:SetDrawLayer(self.drawlayer) -- restore the original draw layer
			else
				self.drawlayer = nil
				self.drawanchor = nil
			end
		end
		if self.iconInterruptBackground:IsShown() then
			self.iconInterruptBackground:Hide()
		end
		if self.gloss:IsShown() then
			self.gloss:Hide()
		end
		if self.count:IsShown() then
			self.count:Hide()
		end
		self:Hide()
		self:GetParent():Hide()
    	self.spellCategory = spellIds[Spell]
		self.Spell = Spell
	elseif maxExpirationTime ~= self.maxExpirationTime or Spell ~= self.Spell or ((LayeredHue) or (typeUpdate == -55) or (not UnitExists(unitId)))  then -- this is a different (de)buff, so initialize the cooldown
		self.maxExpirationTime = maxExpirationTime
		self.Spell = Spell
		if self.anchor ~= UIParent then
			self:SetFrameLevel(self.anchor:GetParent():GetFrameLevel()+((self.frame.anchor ~= "None" and self.frame.anchor ~= "Blizzard") and 3 or 0)) -- must be dynamic, frame level changes all the time
			if not self.drawlayer and self.anchor.GetDrawLayer then
				self.drawlayer = self.anchor:GetDrawLayer() -- back up the current draw layer
			end
			if self.drawlayer and self.anchor.SetDrawLayer then
				--self.anchor:SetDrawLayer("BACKGROUND") -- Temporarily put the portrait texture below the debuff texture. This is the only reliable method I've found for keeping the debuff texture visible with the cooldown spiral on top of it.
       		 	self.anchor:SetDrawLayer("BACKGROUND", -1) -- Temporarily put the portrait texture below the debuff texture. This is the only reliable method I've found for keeping the debuff texture visible with the cooldown spiral on top of it.
			end
		end

		if LoseControlDB.EnableGladiusGloss and (self.unitId == "arena1") or (self.unitId == "arena2") or (self.unitId == "arena3")  or (self.unitId == "arena4") or (self.unitId == "arena5") and (self.frame.anchor == "Gladius" or self.frame.anchor == "Gladdy") then
			self.gloss:SetNormalTexture("Interface\\AddOns\\Gladius\\Images\\Gloss")
			self.gloss.normalTexture = _G[self.gloss:GetName().."NormalTexture"]
			self.gloss.normalTexture:SetHeight(self.frame.size)
			self.gloss.normalTexture:SetWidth(self.frame.size)
			if self.frame.anchor == "Gladdy" then
				self.gloss.normalTexture:SetScale(.81) --.81 for Gladdy
			else
				self.gloss.normalTexture:SetScale(1.05) --.88 Gladius 
			end
			self.gloss.normalTexture:ClearAllPoints()
			self.gloss.normalTexture:SetPoint("CENTER", self, "CENTER")
			self.gloss:SetNormalTexture("Interface\\AddOns\\LoseControl\\Textures\\Gloss")
			self.gloss.normalTexture:SetVertexColor(1, 1, 1, 0.4)
			self.gloss:SetFrameLevel((self:GetParent():GetFrameLevel()) + 10)
			if (not self.gloss:IsShown()) then
				self.gloss:Show()
			end
		else
			if self.gloss:IsShown() then
				self.gloss:Hide()
			end
		end

		if Count then
			if ((unitId == "player" and LoseControlDB.CountTextplayer) or ((unitId == "party1" or unitId == "party2" or unitId == "party3" or unitId == "party4") and  LoseControlDB.CountTextparty)) and not (self.frame.anchor == "Blizzard") then
				if ( Count > 1 ) then
					local countText = Count
					if ( Count > 100 ) then
						countText = BUFF_STACKS_OVERFLOW
					end
					self.count:ClearAllPoints()
					self.count:SetFont(STANDARD_TEXT_FONT, self.frame.size*.415, "OUTLINE")
					if strmatch(unitId, "party") then
						self.count:SetPoint("TOPLEFT", 1, self.frame.size*.415/2.5);
						self.count:SetJustifyH("RIGHT");
					else
						self.count:SetPoint("TOPRIGHT", -1, self.frame.size*.415/2.5);
						self.count:SetJustifyH("RIGHT");
					end
					self.count:Show();
					self.count:SetText(countText)
				else
				if self.count:IsShown() then
					self.count:Hide()
				end
			end
			elseif (unitId == "arena1" or unitId == "arena2" or unitId == "arena3" or unitId == "arena4" or unitId == "arena5") and LoseControlDB.CountTextarena and not (self.frame.anchor == "Blizzard") then
				if ( Count > 1 ) then
					local countText = Count
					if ( Count > 100 ) then
						countText = BUFF_STACKS_OVERFLOW
					end
					self.count:ClearAllPoints()
					self.count:SetFont(STANDARD_TEXT_FONT, self.frame.size*.333, "OUTLINE")
					self.count:SetPoint("BOTTOMRIGHT", 0, 0);
					self.count:SetJustifyH("RIGHT");
					self.count:Show();
					self.count:SetText(countText)
				else
					if self.count:IsShown() then
						self.count:Hide()
					end
				end
			end
		else
			if self.count:IsShown() then
				self.count:Hide()
			end
		end

		local inInstance, instanceType = IsInInstance()

		if Spell == 8143 then Text = "Tremmor".."\n".."Totem" end ---------------ADDING TEXT TO TREMMOR TOTEM--------------------------------

		if (instanceType == "arena" or instanceType == "pvp") and LoseControlDB.ArenaPlayerText then
			--Do Nothing
		else
			if Text and unitId == "player" and self.frame.anchor ~= "Blizzard" and LoseControlDB.PlayerText  then
				self.Ltext:SetFont(STANDARD_TEXT_FONT, self.frame.size*.225, "OUTLINE")
				self.Ltext:SetText(Text)
				self.Ltext:Show()
			elseif unitId == "player" and self.frame.anchor ~= "Blizzard" then
				if self.Ltext:IsShown() then
					self.Ltext:Hide()
				end
			end
		end

		if strmatch(unitId, "arena") then
			local i = strmatch(unitId, "%d") 
			local anchor = _G["GladiusClassIconFramearena"..i]
			local frame = LoseControlDB.frames[unitId]
			local icon = LCframes[unitId]
			if self.frame.anchor == "Gladius" and (anchor and icon.anchor ~= anchor) then  
				icon.anchor = anchor
				local Fpoint, FrelativeTo, FrelativePoint, FxOfs, FyOfs = self:GetPoint()
				icon.parent:SetParent(icon.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
				icon:ClearAllPoints() -- if we don't do this then the frame won't always move
				icon:GetParent():ClearAllPoints()
				icon:SetWidth(frame.size)
				icon:SetHeight(frame.size)
				icon:GetParent():SetWidth(frame.size)
				icon:SetPoint("CENTER",	anchor, "CENTER", 0,	0)
				icon:GetParent():SetPoint("CENTER",	anchor, "CENTER", 0,	0)
				if icon.anchor:GetParent() then
					icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
				end
			end
		end

		--[[
		if strmatch(unitId, "party") then
			local i = strmatch(unitId, "%d") 
			local anchor = _G["PartyAnchor"..i]
			local frame = LoseControlDB.frames[unitId]
			local icon = LCframes[unitId]
			if self.frame.anchor == "BambiUI" and (anchor and icon.anchor ~= anchor) then  
				icon.anchor = anchor
				local Fpoint, FrelativeTo, FrelativePoint, FxOfs, FyOfs = self:GetPoint()
				icon.parent:SetParent(icon.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
				icon:ClearAllPoints() -- if we don't do this then the frame won't always move
				icon:GetParent():ClearAllPoints()
				icon:SetWidth(frame.size)
				icon:SetHeight(frame.size)
				icon:GetParent():SetWidth(frame.size)
				icon:SetPoint("CENTER",	anchor, "CENTER", 0,	0)
				icon:GetParent():SetPoint("CENTER",	anchor, "CENTER", 0,	0)
				if icon.anchor:GetParent() then
					icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
				end
			end
		end]]

		if  unitId == "player" and self.frame.anchor ~= "Blizzard" and LoseControlDB.displayTypeDot and DispelType then
			self.dispelTypeframe:SetHeight(self.frame.size*.105)
			self.dispelTypeframe:SetWidth(self.frame.size*.105)
			self.dispelTypeframe.tex:SetDesaturated(nil)
			self.dispelTypeframe.tex:SetVertexColor(colorTypes[DispelType][1], colorTypes[DispelType][2], colorTypes[DispelType][3]);
			self.dispelTypeframe:ClearAllPoints()
			if self.Ltext:IsShown() then
				self.dispelTypeframe:SetPoint("RIGHT", self.Ltext, "LEFT", -2, 0)
			else
				self.dispelTypeframe:SetPoint("TOP", self, "BOTTOM", 0, -1)
			end
			self.dispelTypeframe:Show()
		elseif unitId == "player" and self.frame.anchor ~= "Blizzard" then
			if self.dispelTypeframe:IsShown() then
				self.dispelTypeframe:Hide()
			end
		end

		if maxPriorityIsInterrupt then
			if LoseControlDB.InterruptOverlay and interruptsIds[Spell] then
				if self.frame.anchor == "Blizzard" then
					self.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background_portrait") --CHRIS
				else
					self.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background") --CHRIS
				end
				if (not self.iconInterruptBackground:IsShown()) then
					self.iconInterruptBackground:Show()
				end
			else
				if self.iconInterruptBackground then
					self.iconInterruptBackground:Hide()
				end
			end
		end
		if self.frame.anchor == "Blizzard" then  --CHRIS DISABLE SQ
			if Hue then
				if Hue == "Red" then -- Changes Icon Hue to Red
					SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
					self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
					self.texture:SetDesaturated(1) --Destaurate Icon
					self.texture:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
					self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
				elseif Hue == "Red_No_Desaturate" then -- Changes Hue to Red and any Icon Greater
					SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
					self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
					self.texture:SetDesaturated(nil) --Destaurate  Icon
					self.texture:SetVertexColor(1, 0, 0); --Red Hue Set For Icon
					self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
				elseif Hue == "Yellow" then -- Changes Hue to Yellow and any Icon Greater
					SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
					self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
					self.texture:SetDesaturated(1) --Destaurate  Icon
					self.texture:SetVertexColor(1, 1, 0); --Yellow Hue Set For Icon
					self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
				elseif Hue == "Purple" then -- Changes Hue to Purple and any Icon Greater
					SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
					self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
					self.texture:SetDesaturated(1) --Destaurate Icon
					self.texture:SetVertexColor(1, 0, 1); --Purple Hue Set For Smoke Bomb Icon
					self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
				elseif Hue == "GhostPurple" then -- Changes Hue to Purple and any Icon Greater
					SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
					self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")   --Set Icon
					self.texture:SetDesaturated(1) --Destaurate Icon
					self.texture:SetVertexColor(.65, .5, .9);  --Purple Hue Set For Icon
					self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
				end
			else
				--self.texture:SetTexture(Icon)
				--SetPortraitToTexture(self.texture, self.texture:GetTexture()) -- Sets the texture to be displayed from a filHuee applying a circular opacity mask making it look round like portraits
				SetPortraitToTexture(self.texture, Icon)
				self:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
				self.texture:SetDesaturated(nil) --Destaurate Icon
				self.texture:SetVertexColor(1, 1, 1)
				self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting) ---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
			end
		else
			if Hue then
				self:SetSwipeTexture("Interface\Cooldown\edge")
				if Hue == "Red" then -- Changes Icon Hue to Red
					self.texture:SetTexture(Icon)   --Set Icon
					self.texture:SetDesaturated(1) --Destaurate Icon
					self.texture:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
					self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
				elseif Hue == "Red_No_Desaturate" then -- Changes Hue to Red and any Icon Greater
					self.texture:SetTexture(Icon)   --SetIcon
					self.texture:SetDesaturated(nil) --Destaurate Icon
					self.texture:SetVertexColor(1, 0, 0); --Red Hue Set For Icon
					self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
				elseif Hue == "Yellow" then -- Changes Hue to Yellow and any Icon Greater
					self.texture:SetTexture(Icon)   --Set Icon
					self.texture:SetDesaturated(1) --Destaurate Icon
					self.texture:SetVertexColor(1, 1, 0); --Yellow Hue Set For Icon
					self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
				elseif Hue == "Purple" then -- Changes Hue to Purple and any Icon Greater
					self.texture:SetTexture(Icon)   --Set Icon
					self.texture:SetDesaturated(1) --Destaurate Icon
					self.texture:SetVertexColor(1, 0, 1); --Purple Hue Set For Icon
					self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
				elseif Hue == "GhostPurple" then -- Changes Hue to Purple and any Icon Greater
					self.texture:SetTexture(Icon)   --Set Icon
					self.texture:SetDesaturated(1) --Destaurate Icon
					self.texture:SetVertexColor(.65, .5, .9); --Purple Hue Set For Icon
					self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)	---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
				end
			else
				self:SetSwipeTexture("Interface\Cooldown\edge")
				self.texture:SetTexture(Icon)
				self.texture:SetDesaturated(nil) --Destaurate Icon
				self.texture:SetVertexColor(1, 1, 1)
				self:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting) ---- Orginally 0.8 This is the default alpha of the normal swipe cooldown texture ADD OPTION FOR THIS
			end
		end
		if forceEventUnitAuraAtEnd and maxExpirationTime > 0 and Duration > 0 then
			local nextTimerUpdate = maxExpirationTime - GetTime() + 0.10
			if nextTimerUpdate < 0.10 then
				nextTimerUpdate = 0.10
			end
			Ctimer(nextTimerUpdate, function()
				if ((not self.unlockMode) and (self.lastTimeUnitAuraEvent == nil or self.lastTimeUnitAuraEvent < (GetTime() - 0.08))) then
					self:UNIT_AURA(unitId, updatedAuras, 4)
				end
			end)
		end
		if self.frame.anchor ~= "Blizzard" and Spell and (Spell == 199448 or (Spell == 377362 and self.unitId == "player")) then --Ultimate Sac Glow and Precog
			ActionButton_ShowOverlayGlow(self)
		else
			ActionButton_HideOverlayGlow(self)
		end

		self.texture:SetTexCoord(0.01, .99, 0.01, .99) -- smallborder

		self.spellCategory = spellIds[Spell]
		self.Priority = priority[self.spellCategory]
		self:Show()
		self:GetParent():Show()
		if Duration > 0 then
			if not self:GetDrawSwipe() then
				self:SetDrawSwipe(false) --SET TO FALSE TO DISABLE DRAWSWIPE , ADD OPTION FOR THIS
			end
			if (maxExpirationTime - GetTime()) > (9*60+59) then
				self:SetCooldown(GetTime(), 0)
				self:SetCooldown(GetTime(), 0)
			else
				self:SetCooldown( maxExpirationTime - Duration, Duration )
			end
		else
			if self:GetDrawSwipe() then
				if LoseControlDB.DrawSwipeSetting > 0 then
					self:SetDrawSwipe(true)
				else
					self:SetDrawSwipe(false)
				end
			end
			self:SetCooldown(GetTime(), 0)
			self:SetCooldown(GetTime(), 0)	--needs execute two times (or the icon can dissapear; yes, it's weird...)
		end
		if (self.unitId == "arena1") or (self.unitId == "arena2") or (self.unitId == "arena3") or (self.unitId == "arena4") or (self.unitId == "arena5") then --Chris sets alpha timer/frame inherot of frame of selected units
			if self.frame.anchor == "Gladius" then
				self:GetParent():SetAlpha(self.anchor:GetAlpha())
				if (not UnitExists(unitId)) then
					if unitId == "arena1" and GladiusClassIconFramearena1 then
						self:GetParent():SetAlpha(0.8)
						GladiusClassIconFramearena1:SetAlpha(0)
						--if GladdyButtonFrame1 then GladdyButtonFrame1:SetAlpha(0) end
					end
					if unitId == "arena2" and GladiusClassIconFramearena2 then
						self:GetParent():SetAlpha(0.8)
						GladiusClassIconFramearena2:SetAlpha(0)
						--if GladdyButtonFrame2 then GladdyButtonFrame2:SetAlpha(0) end
					end
					if unitId == "arena3" and GladiusClassIconFramearena3 then
						self:GetParent():SetAlpha(0.8)
						GladiusClassIconFramearena3:SetAlpha(0)
						--if GladdyButtonFrame3 then GladdyButtonFrame3:SetAlpha(0) end
					end
					if unitId == "arena4" and GladiusClassIconFramearena4 then
						self:GetParent():SetAlpha(0.8)
						GladiusClassIconFramearena4:SetAlpha(0)
						--if GladdyButtonFrame4 then GladdyButtonFrame4:SetAlpha(0) end
					end
					if unitId == "arena5" and GladiusClassIconFramearena5 then
						self:GetParent():SetAlpha(0.8)
						GladiusClassIconFramearena5:SetAlpha(0)
						--if GladdyButtonFrame5 then GladdyButtonFrame5:SetAlpha(0) end
					end
				end
			end
		else
			self:GetParent():SetAlpha(self.frame.alpha) -- hack to apply transparency to the cooldown timer
		end
	end
	if unitId == "player" and LoseControlDB.SilenceIcon and self.frame.anchor ~= "Blizzard" and not self.fakeUnitId then
		if self.Priority and self.Priority > LoseControlDB.priority["Silence"] then
		--	LoseControl:Silence(LoseControlplayer, LayeredHue, self.spellCategory)
		else
			if playerSilence then playerSilence:Hide() end
		end
	end

	if unitId == "player" and LoseControlDB.SecondaryIcon and self.frame.anchor ~= "Blizzard" and not self.fakeUnitId then
		--if self.spellCategory  and self.spellCategory ~= "CC" and (self.spellCategory == "Silence" or self.spellCategory == "RootPhyiscal_Special" or self.spellCategory == "RootMagic_Special" or self.spellCategory == "Root") then
		if self.spellCategory then 
			LoseControl:SecondaryIcon(LoseControlplayer, LayeredHue, self.spellCategory)
		else
			if playerSecondaryIcon then playerSecondaryIcon:Hide() end
		end
	end
end




function LoseControl:Silence(frame,  LayeredHue, spellCategory)
  	local playerSilence = frame.playerSilence
  	local Icon, Duration, maxPriority, maxExpirationTime, DispelType
	local maxPriority = 1
	local maxExpirationTime = 0
	local priority = LoseControlDB.priority
	for i = 1, 40 do
		local name, icon, count, debuffType, duration, expirationTime, source, _, _, spellId = UnitAura("player", i, "HARMFUL")
		if not name then break end
		if duration == 0 and expirationTime == 0 then
			expirationTime = GetTime() + 1 -- normal expirationTime = 0
		end
		local spellCategory = spellIds[spellId] or spellIds[name]
		local Priority = priority[spellCategory]
		if spellCategory == "Silence" then
			if expirationTime > maxExpirationTime then
				maxExpirationTime = expirationTime
				Duration = duration
				Icon = icon
				DispelType = debuffType
			end
		end
  	end
	for i = 1, 40 do
		local name, icon, count, debuffType, duration, expirationTime, source, _, _, spellId = UnitAura("player", i, "HELPFUL")
		if not name then break end
		if duration == 0 and expirationTime == 0 then
			expirationTime = GetTime() + 1 -- normal expirationTime = 0
		end
		local spellCategory = spellIds[spellId] or spellIds[name]
		local Priority = priority[spellCategory]
		if spellCategory == "Silence" then
			if expirationTime > maxExpirationTime then
				maxExpirationTime = expirationTime
				Duration = duration
				Icon = icon
				DispelType = debuffType
			end
		end
	end
	playerSilence:SetWidth(frame:GetWidth()*.9)
	playerSilence:SetHeight(frame:GetHeight()*.9)
	playerSilence.cooldown:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
	playerSilence.Ltext:SetFont(STANDARD_TEXT_FONT, frame:GetHeight()*.9*.225, "OUTLINE")
	playerSilence.Ltext:SetText("Silence")
	if maxExpirationTime == 0 then
		playerSilence.maxExpirationTime = 0
		playerSilence:Hide()
	elseif maxExpirationTime then
		playerSilence.maxExpirationTime = maxExpirationTime
		if LoseControlDB.DrawSwipeSetting > 0 then
			playerSilence.cooldown:SetDrawSwipe(true)
		else
			playerSilence.cooldown:SetDrawSwipe(false)
		end
		if LoseControlDB.displayTypeDot and DispelType then
			playerSilence.dispelTypeframe:SetHeight(frame:GetWidth()*.09)
			playerSilence.dispelTypeframe:SetWidth(frame:GetWidth()*.09)
			playerSilence.dispelTypeframe.tex:SetDesaturated(nil)
			playerSilence.dispelTypeframe.tex:SetVertexColor(colorTypes[DispelType][1], colorTypes[DispelType][2], colorTypes[DispelType][3]);
			playerSilence.dispelTypeframe:ClearAllPoints()
			if playerSilence.Ltext:IsShown() then
				playerSilence.dispelTypeframe:SetPoint("LEFT", playerSilence.Ltext, "RIGHT", 1, -1.25)
			else
				playerSilence.dispelTypeframe:SetPoint("TOP", playerSilence, "BOTTOM", 0, -1)
			end
			playerSilence.dispelTypeframe:Show()
		else
			if playerSilence.dispelTypeframe:IsShown() then
				playerSilence.dispelTypeframe:Hide()
			end
		end
		if LayeredHue then
			playerSilence.texture:SetTexture(Icon)   --Set Icon
			playerSilence.texture:SetDesaturated(1) --Destaurate Icon
			playerSilence.texture:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
		else
			playerSilence.texture:SetTexture(Icon)
			playerSilence.texture:SetDesaturated(nil) --Destaurate Icon
			playerSilence.texture:SetVertexColor(1, 1, 1)
		end
		playerSilence.texture:SetTexCoord(0.01, .99, 0.01, .99) -- smallborder
		if Duration > 0 then
			if (maxExpirationTime - GetTime()) > (9*60+59) then
				playerSilence.cooldown:SetCooldown(GetTime(), 0)
				playerSilence.cooldown:SetCooldown(GetTime(), 0)
			else
				playerSilence.cooldown:SetCooldown( maxExpirationTime - Duration, Duration )
			end
		else
			if playerSilence.cooldown:GetDrawSwipe() then
				if LoseControlDB.DrawSwipeSetting > 0 then
					playerSilence.cooldown:SetDrawSwipe(true)
				else
					playerSilence.cooldown:SetDrawSwipe(false)
				end
			end
			playerSilence.cooldown:SetCooldown(GetTime(), 0)
			playerSilence.cooldown:SetCooldown(GetTime(), 0)	--needs execute two times (or the icon can dissapear; yes, it's weird...)
		end
		local inInstance, instanceType = IsInInstance()
		playerSilence:Show()
	end
end

function LoseControl:SecondaryIcon(frame, LayeredHue, spellCategory)
	local playerSecondaryIcon = frame.playerSecondaryIcon
	
	frame:UNIT_AURA("player", true, -999, spellCategory)

	local maxPriority = SecondaryIconData.maxPriority 
	local maxExpirationTime = SecondaryIconData.maxExpirationTime
	local newExpirationTime = SecondaryIconData.newExpirationTime
	local Duration = SecondaryIconData.Duration
	local Icon = SecondaryIconData.Icon
	local forceEventUnitAuraAtEnd = SecondaryIconData.forceEventUnitAuraAtEnd
	local Hue = SecondaryIconData.Hue 
	local Name = SecondaryIconData.Name
	local Count = SecondaryIconData.Count
	local DispelType = SecondaryIconData.DispelType
	local Text = SecondaryIconData.Text
	local Spell = SecondaryIconData.Spell
	local SecondaryLayeredHue = SecondaryIconData.LayeredHue
	local SpellCategory = SecondaryIconData.SpellCategory

	if SpellCategory == "Friendly_Smoke_Bomb" then -- If the Second Icon is Ever Friendly Bomb it Needs to be White
		LayeredHue = nil
		SecondaryLayeredHue = nil
		Hue = nil
	end
	
	playerSecondaryIcon:SetWidth(frame:GetWidth()*.85)
	playerSecondaryIcon:SetHeight(frame:GetHeight()*.85)
	playerSecondaryIcon.cooldown:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
	playerSecondaryIcon.Ltext:SetFont(STANDARD_TEXT_FONT, frame:GetHeight()*.8*.25, "OUTLINE")
	--playerSecondaryIcon.Ltext:SetJustifyH("CENTER")
	--playerSecondaryIcon.Ltext:SetPoint("TOPLEFT", o.playerSecondaryIcon, "BOTTOMLEFT",  0 , -1.25)
	if Text and LoseControlDB.PlayerText then
		playerSecondaryIcon.Ltext:SetFont(STANDARD_TEXT_FONT, frame:GetHeight()*.8*.25, "OUTLINE")
		playerSecondaryIcon.Ltext:SetText(Text)
		playerSecondaryIcon.Ltext:Show()
	else
		if playerSecondaryIcon.Ltext:IsShown() then
			playerSecondaryIcon.Ltext:Hide()
		end
	end
	playerSecondaryIcon.Ltext:SetText(Text)
	if maxExpirationTime == 0 then
		playerSecondaryIcon.maxExpirationTime = 0
		playerSecondaryIcon:Hide()
	elseif maxExpirationTime then
		playerSecondaryIcon.maxExpirationTime = maxExpirationTime
		if Hue or LayeredHue or SecondaryLayeredHue then
			if Hue == "Red" or LayeredHue or SecondaryLayeredHue then -- Changes Icon Hue to Red
				playerSecondaryIcon.texture:SetTexture(Icon)   --Set Icon
				playerSecondaryIcon.texture:SetDesaturated(1) --Destaurate Icon
				playerSecondaryIcon.texture:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
			elseif Hue == "Red_No_Desaturate" then -- Changes Hue to Red and any Icon Greater
				playerSecondaryIcon.texture:SetTexture(Icon)   --SetIcon
				playerSecondaryIcon.texture:SetDesaturated(nil) --Destaurate Icon
				playerSecondaryIcon.texture:SetVertexColor(1, 0, 0); --Red Hue Set For Icon
			elseif Hue == "Yellow" then -- Changes Hue to Yellow and any Icon Greater
				playerSecondaryIcon.texture:SetTexture(Icon)   --Set Icon
				playerSecondaryIcon.texture:SetDesaturated(1) --Destaurate Icon
				playerSecondaryIcon.texture:SetVertexColor(1, 1, 0); --Yellow Hue Set For Icon
			elseif Hue == "Purple" then -- Changes Hue to Purple and any Icon Greater
				playerSecondaryIcon.texture:SetTexture(Icon)   --Set Icon
				playerSecondaryIcon.texture:SetDesaturated(1) --Destaurate Icon
				playerSecondaryIcon.texture:SetVertexColor(1, 0, 1); --Purple Hue Set For Icon
			elseif Hue == "GhostPurple" then -- Changes Hue to Purple and any Icon Greater
				playerSecondaryIcon.texture:SetTexture(Icon)   --Set Icon
				playerSecondaryIcon.texture:SetDesaturated(1) --Destaurate Icon
				playerSecondaryIcon.texture:SetVertexColor(.65, .5, .9); --Purple Hue Set For Icon
			end
		else
			playerSecondaryIcon.texture:SetTexture(Icon)
			playerSecondaryIcon.texture:SetDesaturated(nil) --Destaurate Icon
			playerSecondaryIcon.texture:SetVertexColor(1, 1, 1)
		end
		if Count and LoseControlDB.CountTextplayer then
			if ( Count > 1 ) then
				local countText = Count
				if ( Count > 100 ) then
					countText = BUFF_STACKS_OVERFLOW
				end
				playerSecondaryIcon.count:ClearAllPoints()
				playerSecondaryIcon.count:SetParent(playerSecondaryIcon)
				playerSecondaryIcon.count:SetFont(STANDARD_TEXT_FONT, (frame:GetWidth()*.8)*.415, "OUTLINE")
				playerSecondaryIcon.count:SetPoint("TOPRIGHT", -1, (frame:GetWidth()*.8)*.415/2.5);
				playerSecondaryIcon.count:SetJustifyH("RIGHT");
				playerSecondaryIcon.count:SetText(countText)
				playerSecondaryIcon.count:Show();
			else
				if playerSecondaryIcon.count:IsShown() then
					playerSecondaryIcon.count:Hide()
				end
			end
		else
			if playerSecondaryIcon.count:IsShown() then
				playerSecondaryIcon.count:Hide()
			end
		end
		if LoseControlDB.displayTypeDot and DispelType then
			playerSecondaryIcon.dispelTypeframe:SetHeight(frame:GetWidth()*.09)
			playerSecondaryIcon.dispelTypeframe:SetWidth(frame:GetWidth()*.09)
			playerSecondaryIcon.dispelTypeframe.tex:SetDesaturated(nil)
			playerSecondaryIcon.dispelTypeframe.tex:SetVertexColor(colorTypes[DispelType][1], colorTypes[DispelType][2], colorTypes[DispelType][3]);
			playerSecondaryIcon.dispelTypeframe:ClearAllPoints()
			if playerSecondaryIcon.Ltext:IsShown() then
				playerSecondaryIcon.dispelTypeframe:SetPoint("LEFT", playerSecondaryIcon.Ltext, "RIGHT", 1, -1.25)
			else
				playerSecondaryIcon.dispelTypeframe:SetPoint("TOP", playerSecondaryIcon, "BOTTOM", 0, -1)
			end
			playerSecondaryIcon.dispelTypeframe:Show()
		else
			if playerSecondaryIcon.dispelTypeframe:IsShown() then
				playerSecondaryIcon.dispelTypeframe:Hide()
			end
		end
		if LoseControlDB.DrawSwipeSetting > 0 then
			playerSecondaryIcon.cooldown:SetDrawSwipe(true)
		else
			playerSecondaryIcon.cooldown:SetDrawSwipe(false)
		end
			playerSecondaryIcon.texture:SetTexCoord(0.01, .99, 0.01, .99) -- smallborder
		if Duration > 0 then
			if (maxExpirationTime - GetTime()) > (9*60+59) then
				playerSecondaryIcon.cooldown:SetCooldown(GetTime(), 0)
				playerSecondaryIcon.cooldown:SetCooldown(GetTime(), 0)
			else
				playerSecondaryIcon.cooldown:SetCooldown( maxExpirationTime - Duration, Duration )
			end
		else
			if playerSecondaryIcon.cooldown:GetDrawSwipe() then
				if LoseControlDB.DrawSwipeSetting > 0 then
					playerSecondaryIcon.cooldown:SetDrawSwipe(true)
				else
					playerSecondaryIcon.cooldown:SetDrawSwipe(false)
				end
			end
			playerSecondaryIcon.cooldown:SetCooldown(GetTime(), 0)
			playerSecondaryIcon.cooldown:SetCooldown(GetTime(), 0)	--needs execute two times (or the icon can dissapear; yes, it's weird...)
		end
		if Spell and (Spell == 199448 or Spell == 377362) then --Ultimate Sac Glow and Precog
			ActionButton_ShowOverlayGlow(playerSecondaryIcon)
		else
			ActionButton_HideOverlayGlow(playerSecondaryIcon)
		end
		local inInstance, instanceType = IsInInstance()
		playerSecondaryIcon:Show()
	end
end


function LoseControl:PLAYER_FOCUS_CHANGED()
	--if (debug) then print("PLAYER_FOCUS_CHANGED") end
	if (self.unitId == "focus" or self.unitId == "focustarget") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, updatedAuras, -10)
		end
	end
end

function LoseControl:PLAYER_TARGET_CHANGED()
	--if (debug) then print("PLAYER_TARGET_CHANGED") endw
	if (self.unitId == "target" or self.unitId == "targettarget") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, updatedAuras, -11)
		end
	end
end

function LoseControl:UNIT_TARGET(unitId)
	--if (debug) then print("UNIT_TARGET", unitId) end
	if (self.unitId == "targettarget" or self.unitId == "focustarget") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, updatedAuras, -12)
		end
	end
end

function LoseControl:UNIT_PET(unitId)
	--if (debug) then print("UNIT_PET", unitId) end
	if (self.unitId == "pet") then
		self.unitGUID = UnitGUID(self.unitId)
		if not self.unlockMode then
			self:UNIT_AURA(self.unitId, updatedAuras, -13)
		end
	end
end

-- Handle mouse dragging
function LoseControl:StopMoving()
	local frame = LoseControlDB.frames[self.unitId]
	if self.fakeUnitId == "player3" then 
		frame = LoseControlDB.frames["player3"]
	end
  	local anchor =  frame.anchor
	frame.point, frame.anchor, frame.relativePoint, frame.x, frame.y = self:GetPoint()
	if not frame.anchor then
		frame.anchor = anchor
		local AnchorDropDown = _G['LoseControlOptionsPanel'..self.unitId..'AnchorDropDown']
		if (AnchorDropDown) then
			UIDropDownMenu_SetSelectedValue(AnchorDropDown, frame.anchor)
		end
	end
	self.anchor = _G[anchors[frame.anchor][self.unitId]] or (type(anchors[frame.anchor][self.unitId])=="table" and anchors[frame.anchor][self.unitId] or UIParent)
	self:ClearAllPoints()
	self:GetParent():ClearAllPoints()
	self:SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	self:GetParent():SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	self:StopMovingOrSizing()
end

-- Constructor method
function LoseControl:new(unitId)
	local o = CreateFrame("Cooldown", addonName .. unitId, nil, 'CooldownFrameTemplate') --, UIParent)
	local op = CreateFrame("Button", addonName .. "ButtonParent" .. unitId, nil)
	op:EnableMouse(false)
	if op:GetPushedTexture() ~= nil then op:GetPushedTexture():SetAlpha(0) op:GetPushedTexture():Hide() end
	if op:GetNormalTexture() ~= nil then op:GetNormalTexture():SetAlpha(0) op:GetNormalTexture():Hide() end
	if op:GetDisabledTexture() ~= nil then op:GetDisabledTexture():SetAlpha(0) op:GetDisabledTexture():Hide() end
	if op:GetHighlightTexture() ~= nil then op:GetHighlightTexture():SetAlpha(0) op:GetHighlightTexture():Hide() end
	if _G[op:GetName().."Shine"] ~= nil then _G[op:GetName().."Shine"]:SetAlpha(0) _G[op:GetName().."Shine"]:Hide() end
	if _G[op:GetName().."Count"] ~= nil then _G[op:GetName().."Count"]:SetAlpha(0) _G[op:GetName().."Count"]:Hide() end
	if _G[op:GetName().."HotKey"] ~= nil then _G[op:GetName().."HotKey"]:SetAlpha(0) _G[op:GetName().."HotKey"]:Hide() end
	if _G[op:GetName().."Flash"] ~= nil then _G[op:GetName().."Flash"]:SetAlpha(0) _G[op:GetName().."Flash"]:Hide() end
	if _G[op:GetName().."Name"] ~= nil then _G[op:GetName().."Name"]:SetAlpha(0) _G[op:GetName().."Name"]:Hide() end
	if _G[op:GetName().."Border"] ~= nil then _G[op:GetName().."Border"]:SetAlpha(0) _G[op:GetName().."Border"]:Hide() end
	if _G[op:GetName().."Icon"] ~= nil then _G[op:GetName().."Icon"]:SetAlpha(0) _G[op:GetName().."Icon"]:Hide() end


	setmetatable(o, self)
	self.__index = self

	o:SetParent(op)
	o.parent = op

	if unitId == "player" or unitId == "player3" then
		o.Ltext = o:CreateFontString(nil, "ARTWORK")
		o.Ltext:SetParent(o)
		o.Ltext:SetTextColor(1, 1, 1, 1)

		o.Ltext:SetJustifyH("CENTER")
		o.Ltext:SetPoint("TOP", o, "BOTTOM", 0, -1)
		--o.Ltext:SetJustifyH("RIGHT")
		--o.Ltext:SetPoint("TOPRIGHT", o, "BOTTOMRIGHT", 0, -1)

		o.dispelTypeframe  = CreateFrame("Frame", addonName .. "dispelTypeframe" .. unitId, o)
		o.dispelTypeframe:ClearAllPoints()
		o.dispelTypeframe:SetAlpha(1)
		o.dispelTypeframe:SetFrameLevel(3)
		o.dispelTypeframe:SetFrameStrata("MEDIUM")
		o.dispelTypeframe:EnableMouse(false)
		o.dispelTypeframe.tex = o.dispelTypeframe:CreateTexture()
		o.dispelTypeframe.tex:SetAllPoints(o.dispelTypeframe)
		SetPortraitToTexture(o.dispelTypeframe.tex, "Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
		o.dispelTypeframe.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		o.playerSilence = CreateFrame("Frame", "playerSilence", frame)
		o.playerSilence:SetPoint("BOTTOMLEFT", o, "BOTTOMRIGHT", 1, 0)
		o.playerSilence:SetParent(o)
		o.playerSilence.texture = o.playerSilence:CreateTexture(nil, "BACKGROUND")
		o.playerSilence.texture:SetAllPoints(true)
		o.playerSilence.cooldown = CreateFrame("Cooldown", nil,   o.playerSilence, 'CooldownFrameTemplate')
		o.playerSilence.cooldown:SetAllPoints(o.playerSilence)
		o.playerSilence.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")    --("Interface\\Cooldown\\edge-LoC") Blizz LC CD
		o.playerSilence.cooldown:SetDrawSwipe(true)
		o.playerSilence.cooldown:SetDrawEdge(false)
		o.playerSilence.cooldown:SetReverse(true) --will reverse the swipe if actionbars or debuff, by default bliz sets the swipe to actionbars if this = true it will be set to debuffs
		o.playerSilence.cooldown:SetDrawBling(false)
		o.playerSilence.Ltext = o.playerSilence:CreateFontString(nil, "ARTWORK")
		o.playerSilence.Ltext:SetParent(o.playerSilence)
		o.playerSilence.Ltext:SetJustifyH("CENTER")
		o.playerSilence.Ltext:SetTextColor(1, 1, 1, 1)
		o.playerSilence.Ltext:SetPoint("TOP", o.playerSilence, "BOTTOM", 0 , -1.25)
		o.playerSilence.dispelTypeframe  = CreateFrame("Frame", addonName .. "playerSilence.dispelTypeframe" .. unitId, o.playerSilence)
		o.playerSilence.dispelTypeframe:ClearAllPoints()
		o.playerSilence.dispelTypeframe:SetAlpha(1)
		o.playerSilence.dispelTypeframe:SetFrameLevel(3)
		o.playerSilence.dispelTypeframe:SetFrameStrata("MEDIUM")
		o.playerSilence.dispelTypeframe:EnableMouse(false)
		o.playerSilence.dispelTypeframe.tex = o.playerSilence.dispelTypeframe:CreateTexture()
		o.playerSilence.dispelTypeframe.tex:SetAllPoints(o.playerSilence.dispelTypeframe)
		SetPortraitToTexture(o.playerSilence.dispelTypeframe.tex, "Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
		o.playerSilence.dispelTypeframe.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

		o.playerSecondaryIcon = CreateFrame("Frame", "playerSecondaryIcon", frame)
		o.playerSecondaryIcon:SetPoint("BOTTOMLEFT", o, "BOTTOMRIGHT", 1, 0)
		o.playerSecondaryIcon:SetParent(o)
		o.playerSecondaryIcon.texture = o.playerSecondaryIcon:CreateTexture(nil, "BACKGROUND")
		o.playerSecondaryIcon.texture:SetAllPoints(true)
		o.playerSecondaryIcon.cooldown = CreateFrame("Cooldown", nil,   o.playerSecondaryIcon, 'CooldownFrameTemplate')
		o.playerSecondaryIcon.cooldown:SetAllPoints(o.playerSecondaryIcon)
		o.playerSecondaryIcon.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")    --("Interface\\Cooldown\\edge-LoC") Blizz LC CD
		o.playerSecondaryIcon.cooldown:SetDrawSwipe(true)
		o.playerSecondaryIcon.cooldown:SetDrawEdge(false)
		o.playerSecondaryIcon.cooldown:SetReverse(true) --will reverse the swipe if actionbars or debuff, by default bliz sets the swipe to actionbars if this = true it will be set to debuffs
		o.playerSecondaryIcon.cooldown:SetDrawBling(false)
		o.playerSecondaryIcon.Ltext = o.playerSecondaryIcon:CreateFontString(nil, "ARTWORK")
		o.playerSecondaryIcon.Ltext:SetParent(o.playerSecondaryIcon)
		o.playerSecondaryIcon.Ltext:SetTextColor(1, 1, 1, 1)

		o.playerSecondaryIcon.Ltext:SetJustifyH("CENTER")
		o.playerSecondaryIcon.Ltext:SetPoint("TOP", o.playerSecondaryIcon, "BOTTOM",  0 , -1.25)
		--o.playerSecondaryIcon.Ltext:SetJustifyH("CENTER")
		--o.playerSecondaryIcon.Ltext:SetPoint("TOPLEFT", o.playerSecondaryIcon, "BOTTOMLEFT",  0 , -1.25)

		o.playerSecondaryIcon.count = o.playerSecondaryIcon:CreateFontString(nil, "OVERLAY", "GameFontWhite");
		o.playerSecondaryIcon.dispelTypeframe  = CreateFrame("Frame", addonName .. "playerSecondaryIcon.dispelTypeframe" .. unitId, o.playerSecondaryIcon)
		o.playerSecondaryIcon.dispelTypeframe:ClearAllPoints()
		o.playerSecondaryIcon.dispelTypeframe:SetAlpha(1)
		o.playerSecondaryIcon.dispelTypeframe:SetFrameLevel(3)
		o.playerSecondaryIcon.dispelTypeframe:SetFrameStrata("MEDIUM")
		o.playerSecondaryIcon.dispelTypeframe:EnableMouse(false)
		o.playerSecondaryIcon.dispelTypeframe.tex = o.playerSecondaryIcon.dispelTypeframe:CreateTexture()
		o.playerSecondaryIcon.dispelTypeframe.tex:SetAllPoints(o.playerSecondaryIcon.dispelTypeframe)
		SetPortraitToTexture(o.playerSecondaryIcon.dispelTypeframe.tex, "Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
		o.playerSecondaryIcon.dispelTypeframe.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	end

	o:SetDrawEdge(false)

	-- Init class members
	if unitId == "player2" then
		o.unitId = "player" -- ties the object to a unit
		o.fakeUnitId = unitId
	elseif unitId == "player3" then
		o.unitId = "player" -- ties the object to a unit
		o.fakeUnitId = unitId
	else
		o.unitId = unitId -- ties the object to a unit
	end
	o:SetAttribute("unit", o.unitId)
	o.texture = o:CreateTexture(nil, "BACKGROUND") -- displays the debuff; draw layer should equal "BORDER" because cooldown spirals are drawn in the "ARTWORK" layer.
	o.texture:SetDrawLayer("BACKGROUND", 1)
	o.texture:SetAllPoints(o) -- anchor the texture to the frame
	o:SetReverse(true) -- makes the cooldown shade from light to dark instead of dark to light

	o.text = o:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	if unitId == "player" then
		o.text:SetText(L["playerIcon"])
	elseif unitId == "player3" then
		o.text:SetText(L["player3Icon"])
	else
		o.text:SetText(L[o.unitId])
	end
	o.text:SetPoint("BOTTOM", o, "BOTTOM")
	o.text:Hide()

	o.count = o:CreateFontString(nil, "OVERLAY", "GameFontWhite");
	o.count:Hide()


-----------------------------------------------------------------------------------

	o:Hide()
	op:Hide()

	o.gloss = CreateFrame("Button", addonName .. "Gloss" .. unitId, nil, 'ActionButtonTemplate')
--	o.gloss:SetNormalTexture("Interface\\AddOns\\Gladius\\Images\\Gloss")
--	o.gloss.normalTexture = _G[o.gloss:GetName().."NormalTexture"]
--	o.gloss.normalTexture:SetVertexColor(1, 1, 1, 0.4)
	o.gloss:Hide()

	-- Create and initialize Interrupt Mini Icons
	o.iconInterruptBackground = o:CreateTexture(addonName .. unitId .. "InterruptIconBackground", "ARTWORK", nil, -2)
	--o.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background")
	o.iconInterruptBackground:SetAlpha(0.7)
	o.iconInterruptBackground:SetPoint("TOPLEFT", 0, 0)
	o.iconInterruptBackground:Hide()
	o.iconInterruptPhysical = o:CreateTexture(addonName .. unitId .. "InterruptIconPhysical", "ARTWORK", nil, -1)
	o.iconInterruptPhysical:SetTexture("Interface\\Icons\\Ability_meleedamage")
	o.iconInterruptHoly = o:CreateTexture(addonName .. unitId .. "InterruptIconHoly", "ARTWORK", nil, -1)
	o.iconInterruptHoly:SetTexture("Interface\\Icons\\Spell_holy_holybolt")
	o.iconInterruptFire = o:CreateTexture(addonName .. unitId .. "InterruptIconFire", "ARTWORK", nil, -1)
	o.iconInterruptFire:SetTexture("Interface\\Icons\\Spell_fire_selfdestruct")
	o.iconInterruptNature = o:CreateTexture(addonName .. unitId .. "InterruptIconNature", "ARTWORK", nil, -1)
	o.iconInterruptNature:SetTexture("Interface\\Icons\\Spell_nature_protectionformnature")
	o.iconInterruptFrost = o:CreateTexture(addonName .. unitId .. "InterruptIconFrost", "ARTWORK", nil, -1)
	o.iconInterruptFrost:SetTexture("Interface\\Icons\\Spell_frost_icestorm")
	o.iconInterruptShadow = o:CreateTexture(addonName .. unitId .. "InterruptIconShadow", "ARTWORK", nil, -1)
	o.iconInterruptShadow:SetTexture("Interface\\Icons\\Spell_shadow_antishadow")
	o.iconInterruptArcane = o:CreateTexture(addonName .. unitId .. "InterruptIconArcane", "ARTWORK", nil, -1)
	o.iconInterruptArcane:SetTexture("Interface\\Icons\\Spell_nature_wispsplode")
	o.iconInterruptList = {
		[1] = o.iconInterruptPhysical,
		[2] = o.iconInterruptHoly,
		[4] = o.iconInterruptFire,
		[8] = o.iconInterruptNature,
		[16] = o.iconInterruptFrost,
		[32] = o.iconInterruptShadow,
		[64] = o.iconInterruptArcane
	}
	for _, v in pairs(o.iconInterruptList) do
		v:SetAlpha(.8) --hide Interrupt Icons
		v:Hide()
		SetPortraitToTexture(v, v:GetTexture())
		v:SetTexCoord(0.08,0.92,0.08,0.92)
	end

	-- Handle events
	o:SetScript("OnEvent", self.OnEvent)
	o:SetScript("OnDragStart", self.StartMoving) -- this function is already built into the Frame class
	o:SetScript("OnDragStop", self.StopMoving) -- this is a custom function

	o:RegisterEvent("PLAYER_ENTERING_WORLD")
	o:RegisterEvent("GROUP_ROSTER_UPDATE")
	o:RegisterEvent("GROUP_JOINED")
	o:RegisterEvent("GROUP_LEFT")
	o:RegisterEvent("ARENA_OPPONENT_UPDATE")
	--o:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

	return o
end

-- Create new object instance for each frame
for k in pairs(DBdefaults.frames) do
	if (k ~= "player2") and (k ~= "player3") then
		LCframes[k] = LoseControl:new(k)
	end
end
LCframeplayer2 = LoseControl:new("player2")
LCframeplayer3 = LoseControl:new("player3")
LCframes["player3"] = LCframeplayer3



function OptionsFunctions:UpdateAll()
	for k, v in pairs(LCframes) do
    local enabled = v.frame.enabled and not (
      inInstance and instanceType == "pvp" and (
        ( LoseControlDB.disablePartyInBG and strfind(v.unitId, "party") ) or
        ( LoseControlDB.disableArenaInBG and strfind(v.unitId, "arena") )
      )
    ) and not (
      IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(v.unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp" or instanceType=="party"))
    )
		if enabled and not v.unlockMode then
			v:UNIT_AURA(v.unitId, nil, -55)
			if (k == "player") and LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
				LCframeplayer2:UNIT_AURA(LCframeplayer2.unitId, nil, -55)
			end
			if (k == "player") and LCframeplayer3.frame.enabled and not LCframeplayer3.unlockMode then
				LCframeplayer3:UNIT_AURA(LCframeplayer3.unitId, nil, -55)
			end
		end
	end
end


-- Helper OptionsOanel interface functions
local LCOptionsPanelFuncs = {}
LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable = function(slider)
	getmetatable(slider).__index.Disable(slider);
	slider.Text:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	slider.Low:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	slider.High:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);

	if ( slider.Label ) then
		slider.Label:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end
LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable = function(slider)
	getmetatable(slider).__index.Enable(slider);
	slider.Text:SetVertexColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b);
	slider.Low:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	slider.High:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	if ( slider.Label ) then
		slider.Label:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end
LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable = function(checkBox)
	checkBox:Disable();
	local text = _G[checkBox:GetName().."Text"];
	if ( text ) then
		text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end
LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable = function(checkBox, isWhite)
	checkBox:Enable();
	local text = _G[checkBox:GetName().."Text"];
	if ( not text ) then
		return;
	end
	if ( isWhite ) then
		text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end
-------------------------------------------------------------------------------
-- Add main Interface Option Panel
local O = addonName .. "OptionsPanel"

local OptionsPanel = CreateFrame("Frame", O)
OptionsPanel.name = addonName

local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetText(addonName)

local unlocknewline = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
unlocknewline:SetText("If a icon is Anchored, the Anchor must be showing, find a Target, TargetofTarget, FocusTarget ,FocusTargetofTarget")

local subText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
local notes = GetAddOnMetadata(addonName, "Notes-" .. GetLocale())
if not notes then
	notes = GetAddOnMetadata(addonName, "Notes")
end
subText:SetText(notes)

-- "Unlock" checkbox - allow the frames to be moved
local Unlock = CreateFrame("CheckButton", O.."Unlock", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."UnlockText"]:SetText(L["Unlock"])
Unlock.nextUnlockLoopTime = 0

function Unlock:LoopFunction()
	if (not self) then
		self = Unlock or _G[O.."Unlock"]
		if (not self) then return end
	end
	if (mathabs(GetTime()-self.nextUnlockLoopTime) < 1) then
		if (self:GetChecked()) then
			self:SetChecked(false)
			self:OnClick()
			self:SetChecked(true)
			self:OnClick()
		end
	end
end

function Unlock:OnClick()
	if self:GetChecked() then
		local onlyOneUnlockLoop = true
		_G[O.."UnlockText"]:SetText(L["Unlock"] .. L[" (drag an icon to move)"])
    	local onlyOneUnlockLoop = true
		unlocknewline:SetPoint("TOPLEFT", title, "TOPLEFT", 0, 18)
		unlocknewline:Show()
		local keys = {} -- for random icon sillyness
		for k in pairs(spellIds) do
			tinsert(keys, k)
		end
		for k, v in pairs(LCframes) do
			v.maxExpirationTime = 0
			v.unlockMode = true
			local frame = LoseControlDB.frames[k]
			if frame.enabled and (_G[anchors[frame.anchor][k]] or (type(anchors[frame.anchor][k])=="table" and anchors[frame.anchor][k] or frame.anchor == "None")) then -- only unlock frames whose anchor exists
				v:RegisterUnitEvents(false)

				local duration, newDuration, startTime, startDuration = v:GetCooldownDuration()
				if duration ~= 0 then
					startTime, startDuration = v:GetCooldownTimes()
					newDuration = (startDuration/1000 + startTime/1000) - GetTime()
					v:SetCooldown( startTime/1000, 15 )
				end

				if not newDuration or newDuration < 1 then
					v.textureicon = select(3, GetSpellInfo(keys[random(#keys)]))
				end

				if _G[anchors[frame.anchor][k]] then
					if not _G[anchors[frame.anchor][k]]:IsVisible() then
						local frame = anchors[frame.anchor][k]
					end
				end
				if frame.anchor == "None" then
					v.parent:SetParent(UIParant) -- detach the frame from its parent or else it won't show if the parent is hidden
					v.texture:SetTexture(v.textureicon)
					v.texture:SetTexCoord(0.01, .99, 0.01, .99) -- smallborder
					v:SetSwipeTexture("Interface\Cooldown\edge")
					v:SetFrameLevel(1)
					if LoseControlDB.InterruptOverlay then
						v.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background.blp")
						v.iconInterruptBackground:Show()
					else
						if not LoseControlDB.InterruptOverlay and v.iconInterruptBackground then
						v.iconInterruptBackground:Hide()
						end
					end
				elseif frame.anchor == "Blizzard" then
					v.parent:SetParent(v.anchor:GetParent())
					SetPortraitToTexture(v.texture, v.textureicon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
					v:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
					if LoseControlDB.InterruptOverlay then
						v.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background_portrait.blp")
						v.iconInterruptBackground:Show()
					else
						if not LoseControlDB.InterruptOverlay and v.iconInterruptBackground then
						v.iconInterruptBackground:Hide()
						end
					end
				elseif frame.anchor == "Gladius" then
					v.texture:SetTexture(v.textureicon)
					v.texture:SetTexCoord(0.01, .99, 0.01, .99)
					--Crop Borders
					--local n = 2
					--v.texture:SetTexCoord(n / 64, 1 - n / 64, n / 64, 1 - n / 64)
					v.parent:SetParent(v.anchor:GetParent())
					v:SetSwipeTexture("Interface\Cooldown\edge")
					if LoseControlDB.InterruptOverlay then
						v.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background_portrait.blp")
						v.iconInterruptBackground:Show()
					else
						if not LoseControlDB.InterruptOverlay and v.iconInterruptBackground then
						v.iconInterruptBackground:Hide()
						end
					end
				else
					v.texture:SetTexture(v.textureicon)
					v.texture:SetTexCoord(0.01, .99, 0.01, .99)
					v.parent:SetParent(v.anchor:GetParent())
					v:SetSwipeTexture("Interface\Cooldown\edge")
					if LoseControlDB.InterruptOverlay then
						v.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background.blp")
						v.iconInterruptBackground:Show()
					else
						if not LoseControlDB.InterruptOverlay and v.iconInterruptBackground then
						v.iconInterruptBackground:Hide()
						end
					end
				end

				if v.anchor ~= UIParent and v.drawlayer then
					if v.drawanchor == v.anchor and v.anchor.GetDrawLayer and v.anchor.SetDrawLayer then
						v.anchor:SetDrawLayer(v.drawlayer) -- restore the original draw layer
					else
						v.drawlayer = nil
						v.drawanchor = nil
					end
				end

				if v.anchor ~= UIParent then
					v:SetFrameLevel(v.anchor:GetParent():GetFrameLevel()+((v.frame.anchor ~= "None" and v.frame.anchor ~= "Blizzard") and 3 or 0)) -- must be dynamic, frame level changes all the time
					if not v.drawlayer and v.anchor.GetDrawLayer then
						v.drawlayer = v.anchor:GetDrawLayer() -- back up the current draw layer
					end
					if v.drawlayer and v.anchor.SetDrawLayer then
						--v.anchor:SetDrawLayer("BACKGROUND") -- Temporarily put the portrait texture below the debuff texture. This is the only reliable method I've found for keeping the debuff texture visible with the cooldown spiral on top of it.
						v.anchor:SetDrawLayer("BACKGROUND", -1) -- Temporarily put the portrait texture below the debuff texture. This is the only reliable method I've found for keeping the debuff texture visible with the cooldown spiral on top of it.
					end
				end

				local spellSchoolInteruptsTable = {
					[1] = {true, 0},
					[2] = {true, 0},
					[4] = {true, 0},
					[8] = {true, 0},
					[16] = {true, 0},
					[32] = {true, 0},
					[64] = {true, 0},
				}

				for schoolIntId, schoolIntFrame in pairs(v.iconInterruptList) do
					if spellSchoolInteruptsTable[schoolIntId][1] and LoseControlDB.InterruptIcons then
						if (not schoolIntFrame:IsShown()) then
							schoolIntFrame:Show()
						end
						local orderInt = 1
						for schoolInt2Id, schoolInt2Info in pairs(spellSchoolInteruptsTable) do
							if ((schoolInt2Info[1]) and ((spellSchoolInteruptsTable[schoolIntId][2] < schoolInt2Info[2]) or ((spellSchoolInteruptsTable[schoolIntId][2] == schoolInt2Info[2]) and (schoolIntId > schoolInt2Id)))) then
								orderInt = orderInt + 1
							end
						end
						schoolIntFrame:SetPoint("BOTTOMRIGHT", v.interruptIconOrderPos[orderInt][1], v.interruptIconOrderPos[orderInt][2])
						schoolIntFrame.interruptIconOrder = orderInt
					elseif schoolIntFrame:IsShown() then
						schoolIntFrame.interruptIconOrder = nil
						schoolIntFrame:Hide()
					end
				end


				local Count = tonumber(strmatch(k, "%d"))
				if k == "player" then Count = 1 end
				if k == "player3" then Count = 2 end
				if Count then
					if (((k == "player" or k == "player3") and LoseControlDB.CountTextplayer) or ((k == "party1" or k == "party2" or k == "party3" or k == "party4") and  LoseControlDB.CountTextparty)) and not (v.frame.anchor == "Blizzard") then
						if ( Count >= 1 ) then
							local countText = Count
							if ( Count >= 100 ) then
								countText = BUFF_STACKS_OVERFLOW
							end
							v.count:ClearAllPoints()
							v.count:SetFont(STANDARD_TEXT_FONT, v.frame.size*.415 , "OUTLINE")
							if strmatch(k, "party") then
								v.count:SetPoint("TOPLEFT", 1, v.frame.size*.415/2.5);
								v.count:SetJustifyH("RIGHT");
							else
								v.count:SetPoint("TOPRIGHT", -1, v.frame.size*.415/2.5);
								v.count:SetJustifyH("RIGHT");
							end
							v.count:Show();
							v.count:SetText(countText)
							else
							if v.count:IsShown() then
								v.count:Hide()
							end
						end
					elseif (k == "arena1" or k == "arena2" or k == "arena3" or k == "arena4" or k == "arena5") and not (v.frame.anchor == "Blizzard") and LoseControlDB.CountTextarena then
						if ( Count >= 1 ) then
							local countText = Count
							if ( Count >= 100 ) then
								countText = BUFF_STACKS_OVERFLOW
							end
							v.count:ClearAllPoints()
							v.count:SetFont(STANDARD_TEXT_FONT,  v.frame.size*.333, "OUTLINE")
							v.count:SetPoint("BOTTOMRIGHT", 0, 0);
							v.count:SetJustifyH("RIGHT");
							v.count:Show();
							v.count:SetText(countText)
						else
							if v.count:IsShown() then
								v.count:Hide()
							end
						end
					end
				else
					if v.count:IsShown() then
						v.count:Hide()
					end
				end

				local Types = { "Magic", "Curse", "Disease", "Poison", "none", "Buff", "CLEU" }
				local Text = "Text For".."\n".."Spell Type"
				if Text and (k == "player" or k == "player3") and v.frame.anchor ~= "Blizzard" and LoseControlDB.PlayerText  then
					v.Ltext:SetFont(STANDARD_TEXT_FONT, v.frame.size*.225, "OUTLINE")
					v.Ltext:SetText(Text)
					v.Ltext:Show()
				elseif (k == "player" or k == "player3") then
					if v.Ltext:IsShown() then
						v.Ltext:Hide()
					end
				end
				local DispelType = Types[math.random(1,7)]
				if  (k == "player" or k == "player3") and LoseControlDB.displayTypeDot and DispelType then
					v.dispelTypeframe:SetHeight(v.frame.size*.105)
					v.dispelTypeframe:SetWidth(v.frame.size*.105)
					v.dispelTypeframe.tex:SetDesaturated(nil)
					v.dispelTypeframe.tex:SetVertexColor(colorTypes[DispelType][1], colorTypes[DispelType][2], colorTypes[DispelType][3]);
					v.dispelTypeframe:ClearAllPoints()
					if v.Ltext:IsShown()  then
						v.dispelTypeframe:SetPoint("RIGHT", v.Ltext, "LEFT", -2, 0)
					else
						v.dispelTypeframe:SetPoint("TOP", v, "BOTTOM", 0, -1)
					end
						v.dispelTypeframe:Show()
				elseif (k == "player" or k == "player3") then
					if v.dispelTypeframe:IsShown() then
						v.dispelTypeframe:Hide()
					end
				end
				v.text:Show()
				v:Show()
				v:GetParent():Show()
				v:SetDrawSwipe(true)
				if (k == "player") and v.frame.anchor ~= "Blizzard" then
					v.playerSilence:SetWidth(v.frame.size*.85)
					v.playerSilence:SetHeight(v.frame.size*.85)
					v.playerSilence.cooldown:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
					v.playerSilence.Ltext:SetFont(STANDARD_TEXT_FONT, v.frame.size*.8*.25, "OUTLINE")
					v.playerSilence.Ltext:SetText("Second \nIcon")
					if not newDuration or newDuration < 1 then
						v.playerSilence.texture:SetTexture(select(3, GetSpellInfo(keys[random(#keys)])))
						v.playerSilence.texture:SetTexCoord(0.01, .99, 0.01, .99) -- smallborder
						v.playerSilence.cooldown:SetCooldown( GetTime(), 15 )
					end
				end
				if (k == "player") and v.frame.anchor ~= "Blizzard" and LoseControlDB.SilenceIcon then
					v.playerSilence:Show()
				elseif not LoseControlDB.SilenceIcon and (k == "player" or k == "player3") then
					if v.playerSilence:IsShown() then
						v.playerSilence:Hide()
					end
				end
				if frame.anchor == "Blizzard" then
					v:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
				else
					v:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting) --becasue we are setting the file
				end
				if not newDuration or newDuration < 1 then
					v:SetCooldown( GetTime(), 15 )
					if (onlyOneUnlockLoop) then
						self.nextUnlockLoopTime = GetTime()+15
						C_Timer.After(15, Unlock.LoopFunction)
						onlyOneUnlockLoop = false
					end
				end

				v:GetParent():SetAlpha(frame.alpha) -- hack to apply the alpha to the cooldown timer
				if frame.anchor == "None" or (frame.anchor == "Blizzard" and strmatch(k, "party")) then
					v:SetMovable(true)
					v:RegisterForDrag("LeftButton")
					v:EnableMouse(true)
				end
				if k == "arena3" and (frame.anchor == "Gladius" or frame.anchor == "Gladdy") then
					if GladiusButtonBackground and GladiusButtonBackground:GetAlpha() == 0 then
						DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
						ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
					end
					if GladdyButtonFrame3 then
						GladdyButtonFrame3:SetAlpha(.5)
						GladdyButtonFrame3.classIcon:SetAlpha(0)
						v:SetAlpha(.5)
					end
					if GladiusClassIconFramearena3 then
						GladiusButtonFramearena3:SetAlpha(.5)
						GladiusClassIconFramearena3:SetAlpha(0)
						v:SetAlpha(.5)
					end
				end
				if LoseControlDB.EnableGladiusGloss and (frame.anchor == "Gladius" or frame.anchor == "Gladdy") then
					v.gloss:SetFrameLevel((v:GetParent():GetFrameLevel()) + 10)
					v.gloss:SetNormalTexture("Interface\\AddOns\\LoseControl\\Textures\\Gloss")
					v.gloss.normalTexture = _G[v.gloss:GetName().."NormalTexture"]
					v.gloss.normalTexture:ClearAllPoints()
					v.gloss.normalTexture:SetPoint("CENTER", v, "CENTER")
					v.gloss.normalTexture:SetVertexColor(1, 1, 1, 0.3)
					if frame.anchor == "Gladdy" then
						v.gloss.normalTexture:SetHeight(v.frame.size + 2)
						v.gloss.normalTexture:SetWidth(v.frame.size + 2)
					else
						v.gloss.normalTexture:SetHeight(v.frame.size)
						v.gloss.normalTexture:SetWidth(v.frame.size)
					end
					if frame.anchor == "Gladdy" then
						v.gloss.normalTexture:SetScale(.9) --.81 for Gladdy
					else
						v.gloss.normalTexture:SetScale(1.05) --.81 for Gladdy
					end
				
					if (not v.gloss:IsShown()) then
							v.gloss:Show()
					end
				elseif not LoseControlDB.EnableGladiusGloss then
					v.gloss:Hide()
				end
			end
		end
		LCframeplayer2.maxExpirationTime = 0
		LCframeplayer2.unlockMode = true
		local frame = LoseControlDB.frames.player2
		if frame.enabled and (_G[anchors[frame.anchor][LCframeplayer2.fakeUnitId or LCframeplayer2.unitId]] or (type(anchors[frame.anchor][LCframeplayer2.unitId])=="table" and anchors[frame.anchor][LCframeplayer2.unitId] or frame.anchor == "None")) then -- only unlock frames whose anchor exists
			LCframeplayer2:RegisterUnitEvents(false)

			local duration, newDuration = LCframeplayer2:GetCooldownDuration()
			if duration ~= 0 then
				local startTime, startDuration = LCframeplayer2:GetCooldownTimes()
				newDuration = (startDuration/1000 + startTime/1000) - GetTime()
			end

			if not newDuration or newDuration < 1 then
				LCframeplayer2.textureicon = select(3, GetSpellInfo(keys[random(#keys)]))
			end

			if frame.anchor == "None" then
					LCframeplayer2.parent:SetParent(UIParant) -- detach the frame from its parent or else it won't show if the parent is hidden
			elseif frame.anchor == "Blizzard" then
				LCframeplayer2.parent:SetParent(LCframeplayer2.anchor:GetParent())
				SetPortraitToTexture(LCframeplayer2.texture, LCframeplayer2.textureicon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
				LCframeplayer2:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")

				if LoseControlDB.InterruptOverlay then
					LCframeplayer2.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background_portrait.blp")
					LCframeplayer2.iconInterruptBackground:Show()
				else
					if not LoseControlDB.InterruptOverlay and LCframeplayer2.iconInterruptBackground then
						LCframeplayer2.iconInterruptBackground:Hide()
					end
				end
			else
				LCframeplayer2.texture:SetTexture(v.textureicon)
			end

			if LCframeplayer2.anchor ~= UIParent and LCframeplayer2.drawlayer then
				if LCframeplayer2.drawanchor == LCframeplayer2.anchor and LCframeplayer2.anchor.GetDrawLayer and LCframeplayer2.anchor.SetDrawLayer then
					LCframeplayer2.anchor:SetDrawLayer(LCframeplayer2.drawlayer) -- restore the original draw layer
				else
					LCframeplayer2.drawlayer = nil
					LCframeplayer2.drawanchor = nil
				end
			end

			if LCframeplayer2.anchor ~= UIParent then
				LCframeplayer2:SetFrameLevel(LCframeplayer2.anchor:GetParent():GetFrameLevel()+((LCframeplayer2.frame.anchor ~= "None" and LCframeplayer2.frame.anchor ~= "Blizzard") and 3 or 0)) -- must be dynamic, frame leLCframeplayer2el changes all the time
				if not LCframeplayer2.drawlayer and LCframeplayer2.anchor.GetDrawLayer then
					LCframeplayer2.drawlayer = LCframeplayer2.anchor:GetDrawLayer() -- back up the current draw layer
				end
				if LCframeplayer2.drawlayer and LCframeplayer2.anchor.SetDrawLayer then
					--LCframeplayer2.anchor:SetDrawLayer("BACKGROUND") -- Temporarily put the portrait texture below the debuff texture. This is the only reliable method I'LCframeplayer2e found for keeping the debuff texture LCframeplayer2isible with the cooldown spiral on top of it.
					LCframeplayer2.anchor:SetDrawLayer("BACKGROUND", -1) -- Temporarily put the portrait texture below the debuff texture. This is the only reliable method I'LCframeplayer2e found for keeping the debuff texture LCframeplayer2isible with the cooldown spiral on top of it.
				end
			end
			LCframeplayer2.text:Show()
			LCframeplayer2:Show()
			LCframeplayer2:GetParent():Show()
			LCframeplayer2:SetDrawSwipe(true)
			LCframeplayer2:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)

			if not newDuration or newDuration < 1 then
				LCframeplayer2:SetCooldown( GetTime(), 15 )
			end
			LCframeplayer2:GetParent():SetAlpha(frame.alpha) -- hack to apply the alpha to the cooldown timer
		end
		
	else
		_G[O.."UnlockText"]:SetText(L["Unlock"])
		for k, v in pairs(LCframes) do
			unlocknewline:Hide()
			local frame = LoseControlDB.frames[k]
			if k == "arena3" and (frame.anchor == "Gladius" or frame.anchor == "Gladdy") then
				if GladdyButtonFrame3 then
				GladdyButtonFrame3:SetAlpha(1)
				GladdyButtonFrame3.classIcon:SetAlpha(1)
				v:SetAlpha(1)
				end
				if GladiusClassIconFramearena3 then
				GladiusButtonFramearena3:SetAlpha(1)
				GladiusClassIconFramearena3:SetAlpha(1)
				v:SetAlpha(1)
				DEFAULT_CHAT_FRAME.editBox:SetText("/gladius hide")
				ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
			v.unlockMode = false
			v:EnableMouse(false)
			v:RegisterForDrag()
			v:SetMovable(false)
			v.text:Hide()
			v:PLAYER_ENTERING_WORLD()
		end
		LCframeplayer2.unlockMode = false
		LCframeplayer2.text:Hide()
		LCframeplayer2:PLAYER_ENTERING_WORLD()
	end
end

Unlock:SetScript("OnClick", Unlock.OnClick)

local DisableBlizzardCooldownCount = CreateFrame("CheckButton", O.."DisableBlizzardCooldownCount", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableBlizzardCooldownCountText"]:SetText(L["Disable Blizzard Countdown"])
function DisableBlizzardCooldownCount:Check(value)
	LoseControlDB.noBlizzardCooldownCount = value
	LoseControl.noBlizzardCooldownCount = LoseControlDB.noBlizzardCooldownCount
	LoseControl:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
	for _, v in pairs(LCframes) do
		v:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
	end
	LCframeplayer2:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
	LCframeplayer3:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
end
DisableBlizzardCooldownCount:SetScript("OnClick", function(self)
	DisableBlizzardCooldownCount:Check(self:GetChecked())
end)

local DisableCooldownCount = CreateFrame("CheckButton", O.."DisableCooldownCount", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableCooldownCountText"]:SetText(L["Disable OmniCC Support"])
DisableCooldownCount:SetScript("OnClick", function(self)
  	LoseControlDB.noCooldownCount = self:GetChecked()
  	LoseControl.noCooldownCount = LoseControlDB.noCooldownCount
  	if self:GetChecked() then
  		DisableBlizzardCooldownCount:Enable()
  		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(_G[O.."DisableCooldownCountText"]:GetTextColor())
      LoseControl:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
      for _, v in pairs(LCframes) do
        v:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
      end
      LCframeplayer2:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
	  LCframeplayer3:SetHideCountdownNumbers(LoseControlDB.noBlizzardCooldownCount)
      for k, v in pairs(LCframes) do
        if v._occ_display then
          v._occ_display:Hide()
        end
      end
      if LCframeplayer2._occ_display then
        LCframeplayer2._occ_display:Hide()
      end
	  if LCframeplayer3._occ_display then
        LCframeplayer3._occ_display:Hide()
      end
  	else
      for k, v in pairs(LCframes) do
        local duration, newDuration, startTime, startDuration = v:GetCooldownDuration()
        if duration ~= 0 then
          startTime, startDuration = v:GetCooldownTimes()
          newDuration = (startDuration/1000 + startTime/1000) - GetTime()
        	v:SetCooldown( startTime/1000, 15 )
        end
        if v._occ_display then
          v._occ_display:Show()
        end
      end
      local duration, newDuration, startTime, startDuration = LCframeplayer2:GetCooldownDuration()
      if duration ~= 0 then
        startTime, startDuration = LCframeplayer2:GetCooldownTimes()
        newDuration = (startDuration/1000 + startTime/1000) - GetTime()
        LCframeplayer2:SetCooldown( startTime/1000, 15 )
		LCframeplayer3:SetCooldown( startTime/1000, 15 )
      end
      if LCframeplayer2._occ_display then
        LCframeplayer2._occ_display:Show()
      end
	  if LCframeplayer3._occ_display then
        LCframeplayer3._occ_display:Show()
      end
  		DisableBlizzardCooldownCount:Disable()
  		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(0.5,0.5,0.5)
  		DisableBlizzardCooldownCount:SetChecked(true)
  		DisableBlizzardCooldownCount:Check(true)
  	end
  OptionsFunctions:UpdateAll()
end)

local DisableLossOfControlCooldownAuxText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
DisableLossOfControlCooldownAuxText:SetText(L["NeedsReload"])
DisableLossOfControlCooldownAuxText:SetTextColor(1,0,0)
DisableLossOfControlCooldownAuxText:Hide()

local DisableLossOfControlCooldownAuxButton = CreateFrame("Button", O.."DisableLossOfControlCooldownAuxButton", OptionsPanel, "GameMenuButtonTemplate")
_G[O.."DisableLossOfControlCooldownAuxButtonText"]:SetText(L["ReloadUI"])
DisableLossOfControlCooldownAuxButton:SetHeight(12)
DisableLossOfControlCooldownAuxButton:Hide()
DisableLossOfControlCooldownAuxButton:SetScript("OnClick", function(self)
	ReloadUI()
end)

local DisableLossOfControlCooldown = CreateFrame("CheckButton", O.."DisableLossOfControlCooldown", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."DisableLossOfControlCooldownText"]:SetText(L["DisableLossOfControlCooldownText"])
DisableLossOfControlCooldown:SetScript("OnClick", function(self)
	LoseControlDB.noLossOfControlCooldown = self:GetChecked()
	LoseControl.noLossOfControlCooldown = LoseControlDB.noLossOfControlCooldown
	if (self:GetChecked()) then
		LoseControl:DisableLossOfControlUI()
		DisableLossOfControlCooldownAuxText:Hide()
		DisableLossOfControlCooldownAuxButton:Hide()
	else
		DisableLossOfControlCooldownAuxText:Show()
		DisableLossOfControlCooldownAuxButton:Show()
	end
end)

local LossOfControlSpells = CreateFrame("Button", O.."LossOfControlSpells", OptionsPanel, "GameMenuButtonTemplate")
_G[O.."LossOfControlSpells"]:SetText("PVP Spells")
LossOfControlSpells:SetHeight(18)
LossOfControlSpells:SetWidth(185)
LossOfControlSpells:SetScale(1)
LossOfControlSpells:SetScript("OnClick", function(self)
  L.SpellsConfig:Toggle()
end)
local LossOfControlSpellsArena = CreateFrame("Button", O.."LossOfControlSpellsArena", OptionsPanel, "GameMenuButtonTemplate")
_G[O.."LossOfControlSpellsArena"]:SetText("Arena123")
LossOfControlSpellsArena:SetHeight(18)
LossOfControlSpellsArena:SetWidth(185)
LossOfControlSpellsArena:SetScale(1)
LossOfControlSpellsArena:SetScript("OnClick", function(self)
  L.SpellsArenaConfig:Toggle()
end)
local LossOfControlSpellsPVE = CreateFrame("Button", O.."LossOfControlSpellsPVE", OptionsPanel, "GameMenuButtonTemplate")
_G[O.."LossOfControlSpellsPVE"]:SetText("PVE Spells")
LossOfControlSpellsPVE:SetHeight(18)
LossOfControlSpellsPVE:SetWidth(185)
LossOfControlSpellsPVE:SetScale(1)
LossOfControlSpellsPVE:SetScript("OnClick", function(self)
  L.SpellsPVEConfig:Toggle()
end)

local Priority = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
Priority:SetText(L["Priority"])

local PriorityDescription = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
PriorityDescription:SetText(L["PriorityDescription"])

-------------------------------------------------------------------------------
-- Slider helper function, thanks to Kollektiv


local function CreateEditBox(text, parent, width, maxLetters, globalName)
	local name = globalName or (parent:GetName() .. text)
	local editbox = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
	editbox:SetAutoFocus(false)
	editbox:SetSize(width, 25)
	editbox:SetAltArrowKeyMode(false)
	editbox:ClearAllPoints()
	editbox:SetPoint("RIGHT", parent, "RIGHT", -5, 15)
	editbox:SetMaxLetters(maxLetters or 256)
	editbox:SetMovable(false)
	editbox:SetMultiLine(false)
	return editbox
end

local function CreateSlider(text, parent, low, high, step, globalName, createBox)
	local name = globalName or (parent:GetName() .. text)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetHeight(8)
	slider:SetWidth(150)
	slider:SetScale(.9)
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	--slider:SetObeyStepOnDrag(obeyStep)
	--_G[name .. "Text"]:SetText(text)
	_G[name .. "Low"]:SetText("")
	_G[name .. "High"]:SetText("")
  if createBox then
    slider.editbox = CreateEditBox("EditBox", slider, 25, 3)
    slider.editbox:SetScript("OnEnterPressed", function(self)
      local val = self:GetText()
      if tonumber(val) then
        self:SetText(val)
        self:GetParent():SetValue(val)
        self:ClearFocus()
        if self:GetParent().Func then
          self:GetParent():Func(val)
        end
      else
        self:SetText(self:GetParent():GetValue())
        self:ClearFocus()
      end
    end)
    slider.editbox:SetScript("OnDisable", function(self)
      self:SetTextColor(GRAY_FONT_COLOR:GetRGB())
    end)
    slider.editbox:SetScript("OnEnable", function(self)
      self:SetTextColor(1, 1, 1)
    end)
  end
	return slider
end

local function CreateSliderMain(text, parent, low, high, step, globalName, createBox)
	local name = globalName or (parent:GetName() .. text)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetHeight(8)
	slider:SetWidth(185)
	slider:SetScale(.9)
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	--slider:SetObeyStepOnDrag(obeyStep)
	--_G[name .. "Text"]:SetText(text)
	_G[name .. "Low"]:SetText("")
	_G[name .. "High"]:SetText("")
  if createBox then
    slider.editbox = CreateEditBox("EditBox", slider, 25, 3)
    slider.editbox:SetScript("OnEnterPressed", function(self)
      local val = self:GetText()
      if tonumber(val) then
        self:SetText(val)
        self:GetParent():SetValue(val)
        self:ClearFocus()
        if self:GetParent().Func then
          self:GetParent():Func(val)
        end
      else
        self:SetText(self:GetParent():GetValue())
        self:ClearFocus()
      end
    end)
    slider.editbox:SetScript("OnDisable", function(self)
      self:SetTextColor(GRAY_FONT_COLOR:GetRGB())
    end)
    slider.editbox:SetScript("OnEnable", function(self)
      self:SetTextColor(1, 1, 1)
    end)
  end
	return slider
end



local DrawSwipeSlider = CreateSliderMain(nil, OptionsPanel, 0, 1, .1, "DrawSwipe", false)
DrawSwipeSlider.Func = function(self, value)
  if value == nil then value = self:GetValue() end
  LoseControlDB.DrawSwipeSetting = value
  for k, v in pairs(LCframes) do
    local frame = LoseControlDB.frames[k]
    if frame.anchor == "Blizzard" then
      v:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
    else
      v:SetSwipeTexture("Interface\Cooldown\edge")
      v:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
      if k == "player" then
        v.playerSilence.cooldown:SetSwipeTexture("Interface\Cooldown\edge")
        v.playerSilence.cooldown:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
		v.playerSecondaryIcon.cooldown:SetSwipeTexture("Interface\Cooldown\edge")
        v.playerSecondaryIcon.cooldown:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
      end
    end
  end
  LCframeplayer2:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
  LCframeplayer3:SetSwipeColor(0, 0, 0, LoseControlDB.DrawSwipeSetting)
end
DrawSwipeSlider:SetScript("OnValueChanged", function(self, value, userInput)
  --self.editbox:SetText(format(value))
  _G["DrawSwipeText"]:SetText("DrawSwipe" .. " (" .. ("%.1f"):format(value) .. ")")
  LoseControlDB.DrawSwipeSetting = value
  if userInput and self.Func then
    self:Func(value)
  end
end)


local PrioritySlider = {}
for k in pairs(DBdefaults.priority) do
	PrioritySlider[k] = CreateSliderMain(L[k], OptionsPanel, 0, 100, 1, "Priority"..k.."Slider")
	PrioritySlider[k]:SetScript("OnValueChanged", function(self, value)
		if L[k] then
		_G[self:GetName() .. "Text"]:SetText(L[k] .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priority[k] = value
		else
		_G[self:GetName() .. "Text"]:SetText(tostring(k) .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priority[k] = value
		end
		if k == "Interrupt" then
			local enable = LCframes["target"].frame.enabled
			LCframes["target"]:RegisterUnitEvents(enable)
		end
	end)
end

local PrioritySliderArena = {}
for k in pairs(DBdefaults.priorityArena) do
	PrioritySliderArena[k] = CreateSliderMain(L[k], OptionsPanel, 0, 100, 1, "priorityArena"..k.."Slider")
	PrioritySliderArena[k]:SetScript("OnValueChanged", function(self, value)
		if L[k] then
		_G[self:GetName() .. "Text"]:SetText(L[k] .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priorityArena[k] = value
		else
		_G[self:GetName() .. "Text"]:SetText(tostring(k) .. " (" .. ("%.0f"):format(value) .. ")")
		LoseControlDB.priorityArena[k] = value
		end
		if k == "Interrupt" then
			local enable = LCframes["target"].frame.enabled
			LCframes["target"]:RegisterUnitEvents(enable)
		end
	end)
end

-------------------------------------------------------------------------------
-- Arrange all the options neatly
title:SetPoint("TOPLEFT", 8, -10)

local BambiText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
BambiText:SetFont("Fonts\\MORPHEUS.ttf", 14 )
BambiText:SetText("By ".."|cff00ccffBambi|r")
BambiText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 38, 1)

Unlock:SetPoint("TOPLEFT",  title, "BOTTOMLEFT", 110, 22)
DisableCooldownCount:SetPoint("TOPLEFT", Unlock, "BOTTOMLEFT", 0, 6)

DisableBlizzardCooldownCount:SetPoint("TOPLEFT", subText, "TOPRIGHT", 15, 10)
DisableLossOfControlCooldownAuxButton:SetPoint("TOPLEFT", Unlock, "TOPRIGHT", 20, 40)

Priority:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
subText:SetPoint("TOPLEFT", Priority, "BOTTOMLEFT", 0, -3)
PriorityDescription:SetPoint("TOPLEFT", subText, "BOTTOMLEFT", 0, -3)

PrioritySlider.CC:SetPoint("TOPLEFT", PriorityDescription, "BOTTOMLEFT", 0, -45)
PrioritySlider.Silence:SetPoint("TOPLEFT", PrioritySlider.CC, "BOTTOMLEFT", 0, -14)
PrioritySlider.RootPhyiscal_Special:SetPoint("TOPLEFT", PrioritySlider.Silence, "BOTTOMLEFT", 0, -14)
PrioritySlider.RootMagic_Special:SetPoint("TOPLEFT", PrioritySlider.RootPhyiscal_Special, "BOTTOMLEFT", 0, -14)
PrioritySlider.Root:SetPoint("TOPLEFT", PrioritySlider.RootMagic_Special, "BOTTOMLEFT", 0, -14)
PrioritySlider.ImmunePlayer:SetPoint("TOPLEFT", PrioritySlider.Root, "BOTTOMLEFT", 0, -14)
PrioritySlider.Disarm_Warning:SetPoint("TOPLEFT", PrioritySlider.ImmunePlayer, "BOTTOMLEFT", 0, -14)
PrioritySlider.CC_Warning:SetPoint("TOPLEFT", PrioritySlider.Disarm_Warning, "BOTTOMLEFT", 0, -14)
PrioritySlider.Enemy_Smoke_Bomb:SetPoint("TOPLEFT", PrioritySlider.CC_Warning, "BOTTOMLEFT", 0, -14)
PrioritySlider.Stealth:SetPoint("TOPLEFT", PrioritySlider.Enemy_Smoke_Bomb, "BOTTOMLEFT", 0, -14)
PrioritySlider.Immune:SetPoint("TOPLEFT", PrioritySlider.Stealth, "BOTTOMLEFT", 0, -14)
PrioritySlider.ImmuneSpell:SetPoint("TOPLEFT", PrioritySlider.Immune, "BOTTOMLEFT", 0, -14)
PrioritySlider.ImmunePhysical:SetPoint("TOPLEFT", PrioritySlider.ImmuneSpell, "BOTTOMLEFT", 0, -14)
PrioritySlider.AuraMastery_Cast_Auras:SetPoint("TOPLEFT", PrioritySlider.ImmunePhysical, "BOTTOMLEFT", 0, -14)
PrioritySlider.ROP_Vortex:SetPoint("TOPLEFT", PrioritySlider.AuraMastery_Cast_Auras, "BOTTOMLEFT", 0, -14)
PrioritySlider.Disarm:SetPoint("TOPLEFT", PrioritySlider.ROP_Vortex, "BOTTOMLEFT", 0, -14)
PrioritySlider.Haste_Reduction:SetPoint("TOPLEFT", PrioritySlider.Disarm, "BOTTOMLEFT", 0, -14)
PrioritySlider.Dmg_Hit_Reduction:SetPoint("TOPLEFT", PrioritySlider.Haste_Reduction, "BOTTOMLEFT", 0, -14)
PrioritySlider.Interrupt:SetPoint("TOPLEFT", PrioritySlider.Dmg_Hit_Reduction, "BOTTOMLEFT", 0, -14)
PrioritySlider.AOE_DMG_Modifiers:SetPoint("TOPLEFT", PrioritySlider.Interrupt, "BOTTOMLEFT", 0, -14)
PrioritySlider.Friendly_Smoke_Bomb:SetPoint("TOPLEFT", PrioritySlider.AOE_DMG_Modifiers, "BOTTOMLEFT", 0, -14)
PrioritySlider.AOE_Spell_Refections:SetPoint("TOPLEFT", PrioritySlider.Friendly_Smoke_Bomb, "BOTTOMLEFT", 0, -14)
PrioritySlider.Trees:SetPoint("TOPLEFT", PrioritySlider.AOE_Spell_Refections, "BOTTOMLEFT", 0, -14)

PrioritySlider.Snare:SetPoint("TOPLEFT", PrioritySlider.Trees, "TOPRIGHT", 42, 0)
PrioritySlider.SnareMagic30:SetPoint("BOTTOMLEFT", PrioritySlider.Snare, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePhysical30:SetPoint("BOTTOMLEFT", PrioritySlider.SnareMagic30, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnareMagic50:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePhysical30, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePosion50:SetPoint("BOTTOMLEFT", PrioritySlider.SnareMagic50, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePhysical50:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePosion50, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnareMagic70:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePhysical50, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnarePhysical70:SetPoint("BOTTOMLEFT", PrioritySlider.SnareMagic70, "TOPLEFT", 0, -14*-1)
PrioritySlider.SnareSpecial:SetPoint("BOTTOMLEFT", PrioritySlider.SnarePhysical70, "TOPLEFT", 0, -14*-1)
PrioritySlider.PvE:SetPoint("BOTTOMLEFT", PrioritySlider.SnareSpecial, "TOPLEFT", 0, -14*-1*2)
PrioritySlider.Other:SetPoint("BOTTOMLEFT", PrioritySlider.PvE, "TOPLEFT", 0, -14*-1)
PrioritySlider.Movable_Cast_Auras:SetPoint("BOTTOMLEFT", PrioritySlider.Other, "TOPLEFT", 0, -14*-1*2)
PrioritySlider.Mana_Regen:SetPoint("BOTTOMLEFT", PrioritySlider.Movable_Cast_Auras, "TOPLEFT", 0, -14*-1)
PrioritySlider.Peronsal_Defensives:SetPoint("BOTTOMLEFT", PrioritySlider.Mana_Regen, "TOPLEFT", 0, -14*-1)
PrioritySlider.Personal_Offensives:SetPoint("BOTTOMLEFT", PrioritySlider.Peronsal_Defensives, "TOPLEFT", 0, -14*-1)
PrioritySlider.CC_Reduction:SetPoint("BOTTOMLEFT", PrioritySlider.Personal_Offensives, "TOPLEFT", 0, -14*-1)
PrioritySlider.Friendly_Defensives:SetPoint("BOTTOMLEFT", PrioritySlider.CC_Reduction, "TOPLEFT", 0, -14*-1)
PrioritySlider.Freedoms:SetPoint("BOTTOMLEFT", PrioritySlider.Friendly_Defensives, "TOPLEFT", 0, -14*-1)
PrioritySlider.Speed_Freedoms:SetPoint("BOTTOMLEFT", PrioritySlider.Freedoms, "TOPLEFT", 0, -14*-1)

PrioritySliderArena.Snares_Casted_Melee:SetPoint("TOPLEFT", PrioritySlider.Snare, "TOPRIGHT", 42, 0)
PrioritySliderArena.Snares_Ranged_Spamable:SetPoint("BOTTOMLEFT", PrioritySliderArena.Snares_Casted_Melee, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Special_Low:SetPoint("BOTTOMLEFT", PrioritySliderArena.Snares_Ranged_Spamable, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Snares_WithCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Special_Low, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Freedoms_Speed:SetPoint("BOTTOMLEFT", PrioritySliderArena.Snares_WithCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Small_Defensive_CDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Freedoms_Speed, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Small_Offenisive_CDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Small_Defensive_CDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Player_Party_OffensiveCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Small_Offenisive_CDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Big_Defensive_CDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Player_Party_OffensiveCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Melee_Major_OffenisiveCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Big_Defensive_CDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Disarms:SetPoint("BOTTOMLEFT", PrioritySliderArena.Melee_Major_OffenisiveCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Roots_90_Snares:SetPoint("BOTTOMLEFT", PrioritySliderArena.Disarms, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Ranged_Major_OffenisiveCDs:SetPoint("BOTTOMLEFT", PrioritySliderArena.Roots_90_Snares, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Special_High:SetPoint("BOTTOMLEFT", PrioritySliderArena.Ranged_Major_OffenisiveCDs, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Interrupt:SetPoint("BOTTOMLEFT", PrioritySliderArena.Special_High, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Silence_Arena:SetPoint("BOTTOMLEFT", PrioritySliderArena.Interrupt, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.CC_Arena:SetPoint("BOTTOMLEFT", PrioritySliderArena.Silence_Arena, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Immune_Arena:SetPoint("BOTTOMLEFT", PrioritySliderArena.CC_Arena, "TOPLEFT", 0, -14*-1)
PrioritySliderArena.Drink_Purge:SetPoint("BOTTOMLEFT", PrioritySliderArena.Immune_Arena, "TOPLEFT", 0, -14*-1)

local durationTypeCheckBoxNew = {}
local durationTypeCheckBoxHigh = {}

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxNew[k] = CreateFrame("CheckButton", O.."durationTypeNew"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxNew[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxNew[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationType[k] = false
		durationTypeCheckBoxHigh[k]:SetChecked(false)
	else
		LoseControlDB.durationType[k] = true
		durationTypeCheckBoxHigh[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxHigh[k] = CreateFrame("CheckButton", O.."durationTypeHigh"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxHigh[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxHigh[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationType[k] = true
		durationTypeCheckBoxNew[k]:SetChecked(false)
	else
		LoseControlDB.durationType[k] = false
		durationTypeCheckBoxNew[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxNew[k]:SetPoint("TOPLEFT", "Priority"..k.."Slider", "TOPRIGHT", -2, 9)
durationTypeCheckBoxNew[k]:SetScale(.8)
end

for k in pairs(DBdefaults.priority) do
durationTypeCheckBoxHigh[k]:SetPoint("TOPLEFT", O.."durationTypeNew"..k, "TOPRIGHT", -5, 0)
durationTypeCheckBoxHigh[k]:SetScale(.8)
end

local durationTypeCheckBoxArenaNew = {}
local durationTypeCheckBoxArenaHigh = {}

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaNew[k] = CreateFrame("CheckButton", O.."durationTypeArenaNew"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxArenaNew[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxArenaNew[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationTypeArena[k] = false
		durationTypeCheckBoxArenaHigh[k]:SetChecked(false)
	else
		LoseControlDB.durationTypeArena[k] = true
		durationTypeCheckBoxArenaHigh[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaHigh[k] = CreateFrame("CheckButton", O.."durationTypeArenaHigh"..k, OptionsPanel, "OptionsCheckButtonTemplate")
durationTypeCheckBoxArenaHigh[k]:SetHitRectInsets(0, 0, 0, 0)
durationTypeCheckBoxArenaHigh[k]:SetScript("OnClick", function(self)
	if self:GetChecked() then
		LoseControlDB.durationTypeArena[k] = true
		durationTypeCheckBoxArenaNew[k]:SetChecked(false)
	else
		LoseControlDB.durationTypeArena[k] = false
		durationTypeCheckBoxArenaNew[k]:SetChecked(true)
	end
end)
end

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaNew[k]:SetPoint("TOPLEFT", "priorityArena"..k.."Slider", "TOPRIGHT", -2, 9)
durationTypeCheckBoxArenaNew[k]:SetScale(.8)
end

for k in pairs(DBdefaults.priorityArena) do
durationTypeCheckBoxArenaHigh[k]:SetPoint("TOPLEFT", O.."durationTypeArenaNew"..k, "TOPRIGHT", -5, 0)
durationTypeCheckBoxArenaHigh[k]:SetScale(.8)
end

local durtiontypeArenaText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeArenaText:SetText("|cff00ccff[N]|r ".."|cffff0000[H] |r")
durtiontypeArenaText:SetPoint("BOTTOMLEFT", O.."durationTypeArenaNewDrink_Purge", "TOPLEFT", 1, 0)

local durtiontypeText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeText:SetText("|cff00ccff[N]|r ".."|cffff0000[H] |r")
durtiontypeText:SetPoint("BOTTOMLEFT", O.."durationTypeNewCC", "TOPLEFT", 1, 0)

local durtiontypeText2 = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeText2:SetText("|cff00ccff[N]|r ".."|cffff0000[H] |r")
durtiontypeText2:SetPoint("BOTTOMLEFT", O.."durationTypeNewSpeed_Freedoms", "TOPLEFT", 1, 0)

local durtiontypeArenaText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
durtiontypeArenaText:SetText("Set the duration for the priority:".."|cff00ccff[N]|r Newest Spell to affect you vs ".."|cffff0000[H] |r Highest duration spell affecting you ")
durtiontypeArenaText:SetPoint("TOPLEFT", PriorityDescription, "BOTTOMLEFT", -1, -3)

LossOfControlSpells:SetPoint("CENTER",PrioritySlider.Speed_Freedoms, "CENTER", 8, 55)
LossOfControlSpellsPVE:SetPoint("CENTER", LossOfControlSpells, "CENTER", 0, -20)
LossOfControlSpellsArena:SetPoint("CENTER", PrioritySliderArena.Drink_Purge, "CENTER", 8, 36)


SetInterruptIcons = CreateFrame("CheckButton", O.."SetInterruptIcons", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."SetInterruptIconsText"]:SetText("Enable Interrupt Icons")
SetInterruptIcons:SetScript("OnClick", function(self)
  LoseControlDB.InterruptIcons = self:GetChecked()
	if self:GetChecked() then
		LoseControlDB.InterruptIcons = true
	else
		LoseControlDB.InterruptIcons = false
	end
  if (Unlock:GetChecked()) then
    Unlock:SetChecked(false)
    Unlock:OnClick()
    Unlock:SetChecked(true)
    Unlock:OnClick()
  end
  OptionsFunctions:UpdateAll()
end)

SetRedSmokeBomb = CreateFrame("CheckButton", O.."SetRedSmokeBomb", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."SetRedSmokeBombText"]:SetText("Enable Red Enemy Smoke Bomb / Shadowy Duel")
SetRedSmokeBomb:SetScript("OnClick", function(self)
  LoseControlDB.RedSmokeBomb = self:GetChecked()
	if self:GetChecked() then
		LoseControlDB.RedSmokeBomb = true
	else
		LoseControlDB.RedSmokeBomb = false
	end
  if (Unlock:GetChecked()) then
    Unlock:SetChecked(false)
    Unlock:OnClick()
    Unlock:SetChecked(true)
    Unlock:OnClick()
  end
  OptionsFunctions:UpdateAll()
end)

SetInterruptOverlay = CreateFrame("CheckButton", O.."SetInterruptOverlay", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."SetInterruptOverlayText"]:SetText("Enable Interrupt Overlay")
SetInterruptOverlay:SetScript("OnClick", function(self)
  LoseControlDB.InterruptOverlay = self:GetChecked()
	if self:GetChecked() then
		LoseControlDB.InterruptOverlay = true
	else
		LoseControlDB.InterruptOverlay = false
	end
  if (Unlock:GetChecked()) then
    Unlock:SetChecked(false)
    Unlock:OnClick()
    Unlock:SetChecked(true)
    Unlock:OnClick()
  end
  OptionsFunctions:UpdateAll()
end)

SetInterruptIcons:SetPoint("TOPLEFT", LossOfControlSpells, "TOPRIGHT", 18, -2)
SetInterruptOverlay:SetPoint("TOPLEFT", SetInterruptIcons, "BOTTOMLEFT", 0, 6)
SetRedSmokeBomb:SetPoint("TOPLEFT", Unlock, "TOPRIGHT", 150, 0)
DisableLossOfControlCooldown:SetPoint("TOPLEFT", SetRedSmokeBomb, "BOTTOMLEFT", 0, 6)
DisableLossOfControlCooldownAuxText:SetPoint("TOPLEFT", DisableLossOfControlCooldown, "BOTTOMLEFT", 26, 10)
DrawSwipeSlider:SetPoint("BOTTOMLEFT", SetInterruptIcons, "TOPLEFT", 1, 0)
-------------------------------------------------------------------------------
OptionsPanel.default = function() -- This method will run when the player clicks "defaults"
	L.SpellsConfig:ResetAllSpellList()
	L.SpellsPVEConfig:ResetAllSpellList()
	L.SpellsArenaConfig:ResetAllSpellList()
	_G.LoseControlDB = nil
	L.SpellsPVEConfig:WipeAll()
	L.SpellsConfig:WipeAll()
	L.SpellsArenaConfig:WipeAll()
	LoseControl:ADDON_LOADED(addonName)
	L.SpellsConfig:UpdateAll()
	L.SpellsPVEConfig:UpdateAll()
	L.SpellsArenaConfig:UpdateAll()
	for _, v in pairs(LCframes) do
		v:PLAYER_ENTERING_WORLD()
	end
	LCframeplayer2:PLAYER_ENTERING_WORLD()
end

OptionsPanel.refresh = function() -- This method will run when the Interface Options frame calls its OnShow function and after defaults have been applied via the panel.default method described above.
	DisableCooldownCount:SetChecked(LoseControlDB.noCooldownCount)
	DisableBlizzardCooldownCount:SetChecked(LoseControlDB.noBlizzardCooldownCount)
	DisableLossOfControlCooldown:SetChecked(LoseControlDB.noLossOfControlCooldown)
	DrawSwipeSlider:SetValue(LoseControlDB.DrawSwipeSetting)

	for k in pairs(DBdefaults.priority) do
		if LoseControlDB.durationType[k] == false then durationTypeCheckBoxNew[k]:SetChecked(true) else durationTypeCheckBoxNew[k]:SetChecked(false) end
	end
	for k in pairs(DBdefaults.priority) do
		if LoseControlDB.durationType[k] == true then durationTypeCheckBoxHigh[k]:SetChecked(true) else durationTypeCheckBoxHigh[k]:SetChecked(false) end
	end

	for k in pairs(DBdefaults.priorityArena) do
		if LoseControlDB.durationTypeArena[k] == false then durationTypeCheckBoxArenaNew[k]:SetChecked(true) else durationTypeCheckBoxArenaNew[k]:SetChecked(false) end
	end
	for k in pairs(DBdefaults.priorityArena) do
		if LoseControlDB.durationTypeArena[k] == true then durationTypeCheckBoxArenaHigh[k]:SetChecked(true) else durationTypeCheckBoxArenaHigh[k]:SetChecked(false) end
	end

	if LoseControlDB.InterruptIcons == false then SetInterruptIcons:SetChecked(false) else SetInterruptIcons:SetChecked(true) end
	if LoseControlDB.InterruptOverlay == false then SetInterruptOverlay:SetChecked(false) else SetInterruptOverlay:SetChecked(true) end
	if LoseControlDB.RedSmokeBomb == false then SetRedSmokeBomb:SetChecked(false) else SetRedSmokeBomb:SetChecked(true) end

	if not LoseControlDB.noCooldownCount then
		DisableBlizzardCooldownCount:Disable()
		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(0.5,0.5,0.5)
		DisableBlizzardCooldownCount:SetChecked(true)
		DisableBlizzardCooldownCount:Check(true)
	else
		DisableBlizzardCooldownCount:Enable()
		_G[O.."DisableBlizzardCooldownCountText"]:SetTextColor(_G[O.."DisableCooldownCountText"]:GetTextColor())
	end
	local priority = LoseControlDB.priority
	for k in pairs(priority) do
		PrioritySlider[k]:SetValue(priority[k])
	end
	local priorityArena = LoseControlDB.priorityArena
	for k in pairs(priorityArena) do
		PrioritySliderArena[k]:SetValue(priorityArena[k])
	end
end

InterfaceOptions_AddCategory(OptionsPanel)

-------------------------------------------------------------------------------
-- DropDownMenu helper function
local function AddItem(owner, text, value)
	local info = UIDropDownMenu_CreateInfo()
	info.owner = owner
	info.func = owner.OnClick
	info.text = text
	info.value = value
	info.checked = nil -- initially set the menu item to being unchecked
	UIDropDownMenu_AddButton(info)
end

-------------------------------------------------------------------------------
-- Create sub-option frames
for _, v in ipairs({ "player", "player3", "pet", "target", "targettarget", "focus", "focustarget", "party", "arena" }) do
	local OptionsPanelFrame = CreateFrame("Frame", O..v)
	OptionsPanelFrame.parent = addonName
	OptionsPanelFrame.name = L[v]

	local AnchorDropDownLabel = OptionsPanelFrame:CreateFontString(O..v.."AnchorDropDownLabel", "ARTWORK", "GameFontNormal")
	AnchorDropDownLabel:SetText(L["Anchor"])
	local AnchorDropDown2Label
	if v == "player" then
		AnchorDropDown2Label = OptionsPanelFrame:CreateFontString(O..v.."AnchorDropDown2Label", "ARTWORK", "GameFontNormal")
		AnchorDropDown2Label:SetText(L["Anchor"])
	end
	local CategoriesEnabledLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoriesEnabledLabel", "ARTWORK", "GameFontNormal")
	CategoriesEnabledLabel:SetText(L["CategoriesEnabledLabel"])
	CategoriesEnabledLabel:SetJustifyH("LEFT")

	L.CategoryEnabledInterruptLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledInterruptLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledInterruptLabel:SetText(L["Interrupt"]..":")

	L.CategoryEnabledCCLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCCLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCCLabel:SetText(L["CC"]..":")
	L.CategoryEnabledSilenceLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSilenceLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSilenceLabel:SetText(L["Silence"]..":")
	L.CategoryEnabledRootPhyiscal_SpecialLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRootPhyiscal_SpecialLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRootPhyiscal_SpecialLabel:SetText(L["RootPhyiscal_Special"]..":")
	L.CategoryEnabledRootMagic_SpecialLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRootMagic_SpeciallLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRootMagic_SpecialLabel:SetText(L["RootMagic_Special"]..":")
	L.CategoryEnabledRootLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRootLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRootLabel:SetText(L["Root"]..":")
	L.CategoryEnabledImmunePlayerLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmunePlayerLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmunePlayerLabel:SetText(L["ImmunePlayer"]..":")
	L.CategoryEnabledDisarm_WarningLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDisarm_WarningLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDisarm_WarningLabel:SetText(L["Disarm_Warning"]..":")
	L.CategoryEnabledCC_WarningLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCC_WarningLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledEnemy_Smoke_BombLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledEnemy_Smoke_BombLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCC_WarningLabel:SetText(L["CC_Warning"]..":")
	L.CategoryEnabledEnemy_Smoke_BombLabel:SetText(L["Enemy_Smoke_Bomb"]..":")
	L.CategoryEnabledStealthLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledStealthLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledStealthLabel:SetText(L["Stealth"]..":")
	L.CategoryEnabledImmuneLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmuneLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmuneLabel:SetText(L["Immune"]..":")
	L.CategoryEnabledImmuneSpellLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmuneSpellLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmuneSpellLabel:SetText(L["ImmuneSpell"]..":")
	L.CategoryEnabledImmunePhysicalLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmunePhysicalLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmunePhysicalLabel:SetText(L["ImmunePhysical"]..":")
	L.CategoryEnabledAuraMastery_Cast_AurasLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledAuraMastery_Cast_AurasLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledAuraMastery_Cast_AurasLabel:SetText(L["AuraMastery_Cast_Auras"]..":")
	L.CategoryEnabledROP_VortexLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledROP_VortexLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledROP_VortexLabel:SetText(L["ROP_Vortex"]..":")
	L.CategoryEnabledDisarmLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDisarmLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDisarmLabel:SetText(L["Disarm"]..":")
	L.CategoryEnabledHaste_ReductionLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledHaste_ReductionLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledHaste_ReductionLabel:SetText(L["Haste_Reduction"]..":")
	L.CategoryEnabledDmg_Hit_ReductionLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDmg_Hit_ReductionLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDmg_Hit_ReductionLabel:SetText(L["Dmg_Hit_Reduction"]..":")
	L.CategoryEnabledAOE_DMG_ModifiersLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledAOE_DMG_ModifiersLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledAOE_DMG_ModifiersLabel:SetText(L["AOE_DMG_Modifiers"]..":")
	L.CategoryEnabledFriendly_Smoke_BombLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFriendly_Smoke_BombLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFriendly_Smoke_BombLabel:SetText(L["Friendly_Smoke_Bomb"]..":")
	L.CategoryEnabledAOE_Spell_RefectionsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledAOE_Spell_RefectionsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledAOE_Spell_RefectionsLabel:SetText(L["AOE_Spell_Refections"]..":")
	L.CategoryEnabledTreesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledTreesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledTreesLabel:SetText(L["Trees"]..":")
	L.CategoryEnabledSpeed_FreedomsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSpeed_FreedomsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSpeed_FreedomsLabel:SetText(L["Speed_Freedoms"]..":")
	L.CategoryEnabledFreedomsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFreedomsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFreedomsLabel:SetText(L["Freedoms"]..":")
	L.CategoryEnabledFriendly_DefensivesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFriendly_DefensivesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFriendly_DefensivesLabel:SetText(L["Friendly_Defensives"]..":")
	L.CategoryEnabledMana_RegenLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledMana_RegenLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCC_ReductionLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCC_ReductionLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledMana_RegenLabel:SetText(L["Mana_Regen"]..":")
	L.CategoryEnabledCC_ReductionLabel:SetText(L["CC_Reduction"]..":")
	L.CategoryEnabledPersonal_OffensivesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPersonal_OffensivesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPersonal_OffensivesLabel:SetText(L["Personal_Offensives"]..":")
	L.CategoryEnabledPeronsal_DefensivesLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPeronsal_DefensivesLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPeronsal_DefensivesLabel:SetText(L["Peronsal_Defensives"]..":")
	L.CategoryEnabledMovable_Cast_AurasLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledMovable_Cast_AurasLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledMovable_Cast_AurasLabel:SetText(L["Movable_Cast_Auras"]..":")
	L.CategoryEnabledOtherLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledOtherLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPvELabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPvELabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledOtherLabel:SetText(L["Other"]..":")
	L.CategoryEnabledPvELabel:SetText(L["PvE"]..":")
	L.CategoryEnabledSnareSpecialLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareSpecialLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareSpecialLabel:SetText(L["SnareSpecial"]..":")
	L.CategoryEnabledSnarePhysical70Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePhysical70Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePhysical70Label:SetText(L["SnarePhysical70"]..":")
	L.CategoryEnabledSnareMagic70Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareMagic70Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePhysical50Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePhysical50Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareMagic70Label:SetText(L["SnareMagic70"]..":")
	L.CategoryEnabledSnarePhysical50Label:SetText(L["SnarePhysical50"]..":")
	L.CategoryEnabledSnarePosion50Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePosion50Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePosion50Label:SetText(L["SnarePosion50"]..":")
	L.CategoryEnabledSnareMagic50Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareMagic50Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareMagic50Label:SetText(L["SnareMagic50"]..":")
	L.CategoryEnabledSnarePhysical30Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnarePhysical30Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnarePhysical30Label:SetText(L["SnarePhysical30"]..":")
	L.CategoryEnabledSnareMagic30Label = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareMagic30Label", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareMagic30Label:SetText(L["SnareMagic30"]..":")
	L.CategoryEnabledSnareLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnareLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnareLabel:SetText(L["Snare"]..":")

	L.CategoryEnabledDrink_PurgeLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDrink_PurgeLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDrink_PurgeLabel:SetText(L["Drink_Purge"]..":")
	L.CategoryEnabledImmune_ArenaLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledImmune_ArenaLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledImmune_ArenaLabel:SetText(L["Immune_Arena"]..":")
	L.CategoryEnabledCC_ArenaLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledCC_ArenaLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledCC_ArenaLabel:SetText(L["CC_Arena"]..":")
	L.CategoryEnabledSilence_ArenaLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSilence_ArenaLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSilence_ArenaLabel:SetText(L["Silence_Arena"]..":")
	L.CategoryEnabledSpecial_HighLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSpecial_HighLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSpecial_HighLabel:SetText(L["Special_High"]..":")
	L.CategoryEnabledRanged_Major_OffenisiveCDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRanged_Major_OffenisiveCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRanged_Major_OffenisiveCDsLabel:SetText(L["Ranged_Major_OffenisiveCDs"]..":")
	L.CategoryEnabledRoots_90_SnaresLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledRoots_90_SnaresLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledRoots_90_SnaresLabel:SetText(L["Roots_90_Snares"]..":")
	L.CategoryEnabledDisarmsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledDisarmsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledDisarmsLabel:SetText(L["Disarms"]..":")
	L.CategoryEnabledMelee_Major_OffenisiveCDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledMelee_Major_OffenisiveCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledMelee_Major_OffenisiveCDsLabel:SetText(L["Melee_Major_OffenisiveCDs"]..":")
	L.CategoryEnabledBig_Defensive_CDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledBig_Defensive_CDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledBig_Defensive_CDsLabel:SetText(L["Big_Defensive_CDs"]..":")
	L.CategoryEnabledPlayer_Party_OffensiveCDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledPlayer_Party_OffensiveCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledPlayer_Party_OffensiveCDsLabel:SetText(L["Small_Offenisive_CDs"]..":")
	L.CategoryEnabledSmall_Offenisive_CDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSmall_Offenisive_CDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSmall_Offenisive_CDsLabel:SetText(L["Small_Offenisive_CDs"]..":")
	L.CategoryEnabledSmall_Defensive_CDsLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSmall_Defensive_CDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSmall_Defensive_CDsLabel:SetText(L["Small_Defensive_CDs"]..":")
	L.CategoryEnabledFreedoms_SpeedLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledFreedoms_SpeedLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledFreedoms_SpeedLabel:SetText(L["Freedoms_Speed"]..":")
	L.CategoryEnabledSnares_WithCDsLabel = OptionsPanelFrame:CreateFontString(O..v.." CategoryEnabledSnares_WithCDsLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnares_WithCDsLabel:SetText(L["Snares_WithCDs"]..":")
	L.CategoryEnabledSpecial_LowLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSpecial_LowLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSpecial_LowLabel:SetText(L["Special_Low"]..":")
	L.CategoryEnabledSnares_Ranged_SpamableLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnares_Ranged_SpamableLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnares_Ranged_SpamableLabel:SetText(L["Snares_Ranged_Spamable"]..":")
	L.CategoryEnabledSnares_Casted_MeleeLabel = OptionsPanelFrame:CreateFontString(O..v.."CategoryEnabledSnares_Casted_MeleeLabel", "ARTWORK", "GameFontNormal")
	L.CategoryEnabledSnares_Casted_MeleeLabel:SetText(L["Snares_Casted_Melee"]..":")


	local CategoriesLabels = {
		["Interrupt"] = L.CategoryEnabledInterruptLabel,
		["CC"] = L.CategoryEnabledCCLabel,
		["Silence"] = L.CategoryEnabledSilenceLabel,
		["RootPhyiscal_Special"] = L.CategoryEnabledRootPhyiscal_SpecialLabel,
		["RootMagic_Special"] = L.CategoryEnabledRootMagic_SpecialLabel,
		["Root"] = L.CategoryEnabledRootLabel,
		["ImmunePlayer"] = L.CategoryEnabledImmunePlayerLabel,
		["Disarm_Warning"] = L.CategoryEnabledDisarm_WarningLabel,
		["CC_Warning"] = L.CategoryEnabledCC_WarningLabel,
		["Enemy_Smoke_Bomb"] = L.CategoryEnabledEnemy_Smoke_BombLabel,
		["Stealth"] = L.CategoryEnabledStealthLabel,
		["Immune"] = L.CategoryEnabledImmuneLabel,
		["ImmuneSpell"] = L.CategoryEnabledImmuneSpellLabel,
		["ImmunePhysical"] = L.CategoryEnabledImmunePhysicalLabel,
		["AuraMastery_Cast_Auras"] = L.CategoryEnabledAuraMastery_Cast_AurasLabel,
		["ROP_Vortex"] = L.CategoryEnabledROP_VortexLabel,
		["Disarm"] = L.CategoryEnabledDisarmLabel,
		["Haste_Reduction"] = L.CategoryEnabledHaste_ReductionLabel,
		["Dmg_Hit_Reduction"] = L.CategoryEnabledDmg_Hit_ReductionLabel,
		["AOE_DMG_Modifiers"] = L.CategoryEnabledAOE_DMG_ModifiersLabel,
		["Friendly_Smoke_Bomb"] = L.CategoryEnabledFriendly_Smoke_BombLabel,
		["AOE_Spell_Refections"] = L.CategoryEnabledAOE_Spell_RefectionsLabel,
		["Trees"] = L.CategoryEnabledTreesLabel,
		["Speed_Freedoms"] = L.CategoryEnabledSpeed_FreedomsLabel,
		["Freedoms"] = L.CategoryEnabledFreedomsLabel,
		["Friendly_Defensives"] = L.CategoryEnabledFriendly_DefensivesLabel,
		["CC_Reduction"] = L.CategoryEnabledCC_ReductionLabel,
		["Personal_Offensives"] = L.CategoryEnabledPersonal_OffensivesLabel,
		["Peronsal_Defensives"] = L.CategoryEnabledPeronsal_DefensivesLabel,
		["Mana_Regen"] = L.CategoryEnabledMana_RegenLabel,
		["Movable_Cast_Auras"] = L.CategoryEnabledMovable_Cast_AurasLabel,
		["Other"] =  L.CategoryEnabledOtherLabel,
		["PvE"] = L.CategoryEnabledPvELabel,
		["SnareSpecial"] = L.CategoryEnabledSnareSpecialLabel,
		["SnarePhysical70"] = L.CategoryEnabledSnarePhysical70Label,
		["SnareMagic70"] = L.CategoryEnabledSnareMagic70Label,
		["SnarePhysical50"] = L.CategoryEnabledSnarePhysical50Label,
		["SnarePosion50"] = L.CategoryEnabledSnarePosion50Label,
		["SnareMagic50"] = L.CategoryEnabledSnareMagic50Label,
		["SnarePhysical30"] = L.CategoryEnabledSnarePhysical30Label,
		["SnareMagic30"] = L.CategoryEnabledSnareMagic30Label,
		["Snare"] = L.CategoryEnabledSnareLabel,

		["Drink_Purge"] = L.CategoryEnabledDrink_PurgeLabel,
		["Immune_Arena"] = L.CategoryEnabledImmune_ArenaLabel,
		["CC_Arena"] = L.CategoryEnabledCC_ArenaLabel,
		["Silence_Arena"] = L.CategoryEnabledSilence_ArenaLabel,
		["Special_High"] = L.CategoryEnabledSpecial_HighLabel,
		["Ranged_Major_OffenisiveCDs"] = L.CategoryEnabledRanged_Major_OffenisiveCDsLabel,
		["Roots_90_Snares"] = L.CategoryEnabledRoots_90_SnaresLabel,
		["Disarms"] = L.CategoryEnabledDisarmsLabel,
		["Melee_Major_OffenisiveCDs"] = L.CategoryEnabledMelee_Major_OffenisiveCDsLabel,
		["Big_Defensive_CDs"] = L.CategoryEnabledBig_Defensive_CDsLabel,
		["Player_Party_OffensiveCDs"] = L.CategoryEnabledPlayer_Party_OffensiveCDsLabel,
		["Small_Offenisive_CDs"] = L.CategoryEnabledSmall_Offenisive_CDsLabel,
		["Small_Defensive_CDs"] = L.CategoryEnabledSmall_Defensive_CDsLabel,
		["Freedoms_Speed"] = L.CategoryEnabledFreedoms_SpeedLabel,
		["Snares_WithCDs"] = L.CategoryEnabledSnares_WithCDsLabel,
		["Special_Low"] = L.CategoryEnabledSpecial_LowLabel,
		["Snares_Ranged_Spamable"] = L.CategoryEnabledSnares_Ranged_SpamableLabel,
		["Snares_Casted_Melee"] = L.CategoryEnabledSnares_Casted_MeleeLabel,
	}

	local AnchorDropDown = CreateFrame("Frame", O..v.."AnchorDropDown", OptionsPanelFrame, "UIDropDownMenuTemplate")
	function AnchorDropDown:OnClick()
		UIDropDownMenu_SetSelectedValue(AnchorDropDown, self.value)
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, unitId in ipairs(frames) do
			local frame = LoseControlDB.frames[unitId]
			local icon = LCframes[unitId]

			frame.anchor = self.value
			icon.anchor = _G[anchors[frame.anchor][unitId]] or (type(anchors[frame.anchor][unitId])=="table" and anchors[frame.anchor][unitId] or UIParent)
			if self.value ~= "None"  then -- reset the frame position so it centers on the anchor frame
				frame.point = nil
				frame.relativePoint = nil
				frame.x = nil
				frame.y = nil
				if self.value == "Gladius" and strfind(unitId, "arena") then
					LCframes[unitId]:CheckGladiusUnitsAnchors(true)
					if GladiusClassIconFramearena1 then
						local W = GladiusClassIconFramearena1:GetWidth()
						local H = GladiusClassIconFramearena1:GetWidth()
						print("|cff00ccffLoseControl|r".." : "..unitId.." GladiusClassIconFrame Size "..mathfloor(H).." or ".. H)
						portrSizeValue = W
					else
						if (strfind(unitId, "arena")) then
							portrSizeValue = 42
						end
					end
					frame.size = portrSizeValue
					icon:SetWidth(portrSizeValue)
					icon:SetHeight(portrSizeValue)
					icon:GetParent():SetWidth(portrSizeValue)
					icon:GetParent():SetHeight(portrSizeValue)
					_G[OptionsPanelFrame:GetName() .. "IconSizeSlider"]:SetValue(portrSizeValue)
					if (Unlock:GetChecked()) then
						DEFAULT_CHAT_FRAME.editBox:SetText("/gladius test")
						ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
					end
				end
				if self.value == "Gladdy" and strfind(unitId, "arena") then
					if strfind(unitId, "arena") then
						LCframes[unitId]:CheckGladdyUnitsAnchors(true)
					end
					if GladdyButtonFrame1.classIcon then
						local W = GladdyButtonFrame1.classIcon:GetWidth()
						local H = GladdyButtonFrame1.classIcon:GetWidth()
						print("|cff00ccffLoseControl|r".." : "..unitId.." GladdyClassIconFrame Size "..mathfloor(H))
						portrSizeValue = W
					else
						if (strfind(unitId, "arena")) then
						portrSizeValue = 42
						end
					end
					frame.size = portrSizeValue
					icon:SetWidth(portrSizeValue)
					icon:SetHeight(portrSizeValue)
					icon:GetParent():SetWidth(portrSizeValue)
					icon:GetParent():SetHeight(portrSizeValue)
					_G[OptionsPanelFrame:GetName() .. "IconSizeSlider"]:SetValue(portrSizeValue)
				end
				if self.value == "BambiUI" then
					if (strfind(unitId, "party")) then

						portrSizeValue = 64
					end
					if unitId == "player" then
						portrSizeValue = 44
					end
					frame.size = portrSizeValue
					icon:SetWidth(portrSizeValue)
					icon:SetHeight(portrSizeValue)
					icon:GetParent():SetWidth(portrSizeValue)
					icon:GetParent():SetHeight(portrSizeValue)
					_G[OptionsPanelFrame:GetName() .. "IconSizeSlider"]:SetValue(portrSizeValue)
				end
				if self.value == "Blizzard" then
					local portrSizeValue = 36
					if (unitId == "player" or unitId == "target" or unitId == "focus" or unitId == "player3") then
						portrSizeValue = 56
					elseif (strfind(unitId, "arena")) then
						portrSizeValue = 28
						if (Unlock:GetChecked()) then
						DEFAULT_CHAT_FRAME.editBox:SetText("/gladius hide")
						ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
						end
					end
					if (unitId == "player") and LoseControlDB.duplicatePlayerPortrait then
						local DuplicatePlayerPortrait = _G['LoseControlOptionsPanel'..unitId..'DuplicatePlayerPortrait']
						if DuplicatePlayerPortrait then
							DuplicatePlayerPortrait:SetChecked(false)
							DuplicatePlayerPortrait:Check(false)
						end
					end
					frame.size = portrSizeValue
					icon:SetWidth(portrSizeValue)
					icon:SetHeight(portrSizeValue)
					icon:GetParent():SetWidth(portrSizeValue)
					icon:GetParent():SetHeight(portrSizeValue)
					SetPortraitToTexture(icon.texture, icon.textureicon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits
					icon:SetSwipeTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
					--icon:SetSwipeColor(0, 0, 0, frame.swipeAlpha*0.75)
					icon.iconInterruptBackground:SetTexture("Interface\\AddOns\\LoseControl\\Textures\\lc_interrupt_background_portrait.blp")
					_G[OptionsPanelFrame:GetName() .. "IconSizeSlider"]:SetValue(portrSizeValue)
				end
			else
			end
			if (strfind(unitId, "arena")) then
				if (Unlock:GetChecked()) then
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladius hide")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
				end
			end
			SetInterruptIconsSize(icon, frame.size)
			icon.parent:SetParent(icon.anchor:GetParent()) -- or LoseControl) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
			icon:ClearAllPoints() -- if we don't do this then the frame won't always move
			icon:GetParent():ClearAllPoints()
			icon:SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			icon:GetParent():SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			if icon.anchor:GetParent() then
				icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
			end
			if icon.frame.enabled and not icon.unlockMode then --this updates in realtime
				icon.maxExpirationTime = 0
				icon:UNIT_AURA(icon.unitId, nil, 0)
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end

	end

	local AnchorDropDown2
	if v == "player" then
		AnchorDropDown2	= CreateFrame("Frame", O..v.."AnchorDropDown2", OptionsPanelFrame, "UIDropDownMenuTemplate")
		function AnchorDropDown2:OnClick()
			UIDropDownMenu_SetSelectedValue(AnchorDropDown2, self.value)
			local frame = LoseControlDB.frames.player2
			local icon = LCframeplayer2
			frame.anchor = self.value
			frame.point = nil
			frame.relativePoint = nil
			frame.x = nil
			frame.y = nil
			if self.value == "Blizzard" then
				local portrSizeValue = 62
				frame.size = portrSizeValue
				icon:SetWidth(portrSizeValue)
				icon:SetHeight(portrSizeValue)
				icon:GetParent():SetWidth(portrSizeValue)
				icon:GetParent():SetHeight(portrSizeValue)
			end
			icon.anchor = _G[anchors[frame.anchor][LCframes.player.unitId]] or (type(anchors[frame.anchor][LCframes.player.unitId])=="table" and anchors[frame.anchor][LCframes.player.unitId] or UIParent)
			SetInterruptIconsSize(icon, frame.size)
			icon:ClearAllPoints() -- if we don't do this then the frame won't always move
			icon:GetParent():ClearAllPoints()
			icon:SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			icon:GetParent():SetPoint(
				frame.point or "CENTER",
				icon.anchor,
				frame.relativePoint or "CENTER",
				frame.x or 0,
				frame.y or 0
			)
			if icon.anchor:GetParent() then
				icon:SetFrameLevel(icon.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
			end
			if icon.frame.enabled and not icon.unlockMode then
				icon.maxExpirationTime = 0
				icon:UNIT_AURA(icon.unitId, nil, 0)
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end
	end


	local SizeSlider = CreateSlider(L["Icon Size"], OptionsPanelFrame, 16, 256, 1, OptionsPanelFrame:GetName() .. "IconSizeSlider", true)
	SizeSlider.Func = function(self, value)
		if value == nil then value = self:GetValue() end

		local frames = { v }
		local count = .415

		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
			count = .333
		end

		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].size = value
			LCframes[frame]:SetWidth(value)
			LCframes[frame]:SetHeight(value)
			LCframes[frame]:GetParent():SetWidth(value)
			LCframes[frame]:GetParent():SetHeight(value)
			LCframes[frame].count:SetFont(STANDARD_TEXT_FONT, value*count , "OUTLINE")
			if strmatch(v, "party") then
				LCframes[frame].count:SetPoint("TOPLEFT", 1,  value*.415/2.5);
				LCframes[frame].count:SetJustifyH("RIGHT");
			elseif strmatch(v, "player") then
				LCframes[frame].count:SetPoint("TOPRIGHT", -1,  value*.415/2.5);
				LCframes[frame].count:SetJustifyH("RIGHT");
				LCframes[frame].dispelTypeframe:SetHeight(value*.105)
				LCframes[frame].dispelTypeframe:SetWidth(value*.105)
				LCframes[frame].Ltext:SetFont(STANDARD_TEXT_FONT, value*.225, "OUTLINE")
				LCframes[frame].playerSilence:SetWidth(value*.9)
				LCframes[frame].playerSilence:SetHeight(value*.9)
				LCframes[frame].playerSilence.Ltext:SetFont(STANDARD_TEXT_FONT, value*.9*.25, "OUTLINE")
			end
			SetInterruptIconsSize(LCframes[frame], value)
		end
	end

	SizeSlider:SetScript("OnValueChanged", function(self, value, userInput)
		value = mathfloor(value+0.5)
		_G[self:GetName() .. "Text"]:SetText(L["Icon Size"] .. " (" .. value .. "px)")
		self.editbox:SetText(value)
		if userInput and self.Func then
			self:Func(value)
		end
	end)

	local AlphaSlider = CreateSlider(L["Opacity"], OptionsPanelFrame, 0, 100, 1, OptionsPanelFrame:GetName() .. "OpacitySlider", true) -- I was going to use a range of 0 to 1 but Blizzard's slider chokes on decimal values
	AlphaSlider.Func = function(self, value)
		if value == nil then value = self:GetValue() end
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].alpha = value / 100 -- the real alpha value
			LCframes[frame]:GetParent():SetAlpha(value / 100)
		end
	end
  	AlphaSlider:SetScript("OnValueChanged", function(self, value, userInput)
		value = mathfloor(value+0.5)
		_G[self:GetName() .. "Text"]:SetText(L["Opacity"] .. " (" .. value .. "%)")
		self.editbox:SetText(value)
		if userInput and self.Func then
			self:Func(value)
		end
  	end)

	local AlphaSlider2
	if v == "player" then
		AlphaSlider2 = CreateSlider(L["Opacity"], OptionsPanelFrame, 0, 100, 2, OptionsPanelFrame:GetName() .. "Opacity2Slider", true) -- I was going to use a range of 0 to 1 but Blizzard's slider chokes on decimal values
		AlphaSlider2.Func = function(self, value)
		if value == nil then value = self:GetValue() end
			if v == "player" then
				LoseControlDB.frames.player2.alpha = value / 100 -- the real alpha value
				LCframeplayer2:GetParent():SetAlpha(value / 100)
			end
		end
		AlphaSlider2:SetScript("OnValueChanged", function(self, value, userInput)
			value = mathfloor(value+0.5)
			_G[self:GetName() .. "Text"]:SetText(L["Opacity"] .. " (" .. value .. "%)")
			self.editbox:SetText(value)
			if v == "player" and userInput and self.Func then
				self:Func(value)
			end
		end)
	end

	local DisableInBG
	if v == "party" then
		DisableInBG = CreateFrame("CheckButton", O..v.."DisableInBG", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableInBGText"]:SetText(L["DisableInBG"])
		DisableInBG:SetScript("OnClick", function(self)
			LoseControlDB.disablePartyInBG = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				for i = 1, 4 do
					LCframes[v .. i].maxExpirationTime = 0
					LCframes[v .. i]:PLAYER_ENTERING_WORLD()
				end
			end
			OptionsFunctions:UpdateAll()
		end)
	elseif v == "arena" then
		DisableInBG = CreateFrame("CheckButton", O..v.."DisableInBG", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableInBGText"]:SetText(L["DisableInBG"])
		DisableInBG:SetScript("OnClick", function(self)
			LoseControlDB.disableArenaInBG = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				for i = 1, 5 do
					LCframes[v .. i].maxExpirationTime = 0
					LCframes[v .. i]:PLAYER_ENTERING_WORLD()
				end
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
     		 OptionsFunctions:UpdateAll()
		end)
	end

	local DisableInRaid
	if v == "party" then
		DisableInRaid = CreateFrame("CheckButton", O..v.."DisableInRaid", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableInRaidText"]:SetText(L["DisableInRaid"])
		DisableInRaid:SetScript("OnClick", function(self)
			LoseControlDB.disablePartyInRaid = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				for i = 1, 4 do
					LCframes[v .. i].maxExpirationTime = 0
					LCframes[v .. i]:PLAYER_ENTERING_WORLD()
				end
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local ShowNPCInterrupts
	if v == "target" or v == "focus" or v == "targettarget" or v == "focustarget"  then
		ShowNPCInterrupts = CreateFrame("CheckButton", O..v.."ShowNPCInterrupts", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."ShowNPCInterruptsText"]:SetText(L["ShowNPCInterrupts"])
		ShowNPCInterrupts:SetScript("OnClick", function(self)
			if v == "target" then
				LoseControlDB.showNPCInterruptsTarget = self:GetChecked()
			elseif v == "focus" then
				LoseControlDB.showNPCInterruptsFocus = self:GetChecked()
			elseif v == "targettarget" then
				LoseControlDB.showNPCInterruptsTargetTarget = self:GetChecked()
			elseif v == "focustarget" then
				LoseControlDB.showNPCInterruptsFocusTarget = self:GetChecked()
			end
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
					end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local DisablePlayerTargetTarget
	if v == "targettarget" or v == "focustarget" then
		DisablePlayerTargetTarget = CreateFrame("CheckButton", O..v.."DisablePlayerTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisablePlayerTargetTargetText"]:SetText(L["DisablePlayerTargetTarget"])
		DisablePlayerTargetTarget:SetScript("OnClick", function(self)
			if v == "targettarget" then
				LoseControlDB.disablePlayerTargetTarget = self:GetChecked()
			elseif v == "focustarget" then
				LoseControlDB.disablePlayerFocusTarget = self:GetChecked()
			end
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local DisableTargetTargetTarget
	if v == "targettarget" then
		DisableTargetTargetTarget = CreateFrame("CheckButton", O..v.."DisableTargetTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableTargetTargetTargetText"]:SetText(L["DisableTargetTargetTarget"])
		DisableTargetTargetTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableTargetTargetTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local DisablePlayerTargetPlayerTargetTarget
	if v == "targettarget" then
		DisablePlayerTargetPlayerTargetTarget = CreateFrame("CheckButton", O..v.."DisablePlayerTargetPlayerTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisablePlayerTargetPlayerTargetTargetText"]:SetText(L["DisablePlayerTargetPlayerTargetTarget"])
		DisablePlayerTargetPlayerTargetTarget:SetScript("OnClick", function(self)
			LoseControlDB.disablePlayerTargetPlayerTargetTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local DisableTargetDeadTargetTarget
	if v == "targettarget" then
		DisableTargetDeadTargetTarget = CreateFrame("CheckButton", O..v.."DisableTargetDeadTargetTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableTargetDeadTargetTargetText"]:SetText(L["DisableTargetDeadTargetTarget"])
		DisableTargetDeadTargetTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableTargetDeadTargetTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local DisableFocusFocusTarget
	if v == "focustarget" then
		DisableFocusFocusTarget = CreateFrame("CheckButton", O..v.."DisableFocusFocusTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableFocusFocusTargetText"]:SetText(L["DisableFocusFocusTarget"])
		DisableFocusFocusTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableFocusFocusTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local DisablePlayerFocusPlayerFocusTarget
	if v == "focustarget" then
		DisablePlayerFocusPlayerFocusTarget = CreateFrame("CheckButton", O..v.."DisablePlayerFocusPlayerFocusTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisablePlayerFocusPlayerFocusTargetText"]:SetText(L["DisablePlayerFocusPlayerFocusTarget"])
		DisablePlayerFocusPlayerFocusTarget:SetScript("OnClick", function(self)
			LoseControlDB.disablePlayerFocusPlayerFocusTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local DisableFocusDeadFocusTarget
	if v == "focustarget" then
		DisableFocusDeadFocusTarget = CreateFrame("CheckButton", O..v.."DisableFocusDeadFocusTarget", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DisableFocusDeadFocusTargetText"]:SetText(L["DisableFocusDeadFocusTarget"])
		DisableFocusDeadFocusTarget:SetScript("OnClick", function(self)
			LoseControlDB.disableFocusDeadFocusTarget = self:GetChecked()
			if not Unlock:GetChecked() then -- prevents the icon from disappearing if the frame is currently hidden
				LCframes[v].maxExpirationTime = 0
				LCframes[v]:PLAYER_ENTERING_WORLD()
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local EnableGladiusGloss
	if strfind(v, "arena") then
		EnableGladiusGloss = CreateFrame("CheckButton", O..v.."EnableGladiusGloss", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."EnableGladiusGlossText"]:SetText(L["EnableGladiusGloss"])
		EnableGladiusGloss:SetScript("OnClick", function(self)
			LoseControlDB.EnableGladiusGloss = self:GetChecked()
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local lossOfControlInterrupt
	if  v == "player" then
		lossOfControlInterrupt = CreateSlider(L["lossOfControlInterrupt"], OptionsPanelFrame, 0, 2, 1, "lossOfControlInterrupt")
		lossOfControlInterrupt:SetScript("OnValueChanged", function(self, value)
			lossOfControlInterrupt:SetScale(.82)
			lossOfControlInterrupt:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlInterrupt"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlInterrupt = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlInterrupt", ("%.0f"):format(value))
		end)
	end

	local lossOfControlFull
	if  v == "player" then
		lossOfControlFull = CreateSlider(L["lossOfControlFull"], OptionsPanelFrame, 0, 2, 1, "lossOfControlFull")
		lossOfControlFull:SetScript("OnValueChanged", function(self, value)
			lossOfControlFull:SetScale(.82)
			lossOfControlFull:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlFull"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlFull = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlFull", ("%.0f"):format(value))
		end)
	end

	local lossOfControlSilence
	if  v == "player" then
		lossOfControlSilence = CreateSlider(L["lossOfControlSilence"], OptionsPanelFrame, 0, 2, 1, "lossOfControlSilence")
		lossOfControlSilence:SetScript("OnValueChanged", function(self, value)
			lossOfControlSilence:SetScale(.82)
			lossOfControlSilence:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlSilence"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlSilence = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlSilence", ("%.0f"):format(value))
		end)
	end

	local lossOfControlDisarm
	if  v == "player" then
		lossOfControlDisarm = CreateSlider(L["lossOfControlDisarm"], OptionsPanelFrame, 0, 2, 1, "lossOfControlDisarm")
		lossOfControlDisarm:SetScript("OnValueChanged", function(self, value)
			lossOfControlDisarm:SetScale(.82)
			lossOfControlDisarm:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlDisarm"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlDisarm = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlDisarm", ("%.0f"):format(value))
		end)
	end

	local lossOfControlRoot
	if  v == "player" then
		lossOfControlRoot = CreateSlider(L["lossOfControlRoot"], OptionsPanelFrame, 0, 2, 1, "lossOfControlRoot")
		lossOfControlRoot:SetScript("OnValueChanged", function(self, value)
			lossOfControlRoot:SetScale(.82)
			lossOfControlRoot:SetWidth(200)
			_G[self:GetName() .. "Text"]:SetText(L["lossOfControlRoot"] .. " (" .. ("%.0f"):format(value) .. ")")
			LoseControlDB.lossOfControlRoot = ("%.0f"):format(value)-- the real alpha value
			SetCVar("lossOfControlRoot", ("%.0f"):format(value))
		end)
	end

	local lossOfControl
	if  v == "player" then
		lossOfControl = CreateFrame("CheckButton", O..v.."lossOfControl", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		lossOfControl:SetScale(1)
		lossOfControl:SetHitRectInsets(0, 0, 0, 0)
		_G[O..v.."lossOfControlText"]:SetText(L["lossOfControl"])
		lossOfControl:SetScript("OnClick", function(self)
			LoseControlDB.lossOfControl = self:GetChecked()
			if (self:GetChecked()) then
				SetCVar("lossOfControl", 1)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlInterrupt)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlFull)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlSilence)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlDisarm)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlRoot)
			else
				SetCVar("lossOfControl", 0)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlInterrupt)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlFull)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlSilence)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlDisarm)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlRoot)
			end
		end)
	end

	local PlayerText
	if  v == "player" then
		PlayerText = CreateFrame("CheckButton", O..v.."PlayerText", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		PlayerText:SetScale(1)
		PlayerText:SetHitRectInsets(0, 0, 0, 0)
		_G[O..v.."PlayerTextText"]:SetText("Show Category Text on Frame")
		PlayerText:SetScript("OnClick", function(self)
			LoseControlDB.PlayerText = self:GetChecked()
			OptionsFunctions:UpdateAll()
			if (self:GetChecked()) then
				LoseControlDB.PlayerText = true
			else
				LoseControlDB.PlayerText = false
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local ArenaPlayerText
	if  v == "player" then
		ArenaPlayerText = CreateFrame("CheckButton", O..v.."ArenaPlayerText", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		ArenaPlayerText:SetScale(1)
		ArenaPlayerText:SetHitRectInsets(0, 0, 0, 0)
		_G[O..v.."ArenaPlayerTextText"]:SetText("Disable Player Text in PvP")
		ArenaPlayerText:SetScript("OnClick", function(self)
			LoseControlDB.ArenaPlayerText = self:GetChecked()
			OptionsFunctions:UpdateAll()
			if (self:GetChecked()) then
				LoseControlDB.ArenaPlayerText = true
			else
				LoseControlDB.ArenaPlayerText = false
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local displayTypeDot
	if  v == "player" then
		displayTypeDot = CreateFrame("CheckButton", O..v.."displayTypeDot", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		displayTypeDot:SetScale(1)
		displayTypeDot:SetHitRectInsets(0, 0, 0, 0)
		_G[O..v.."displayTypeDotText"]:SetText("Icon Type Color Next to Text")
		displayTypeDot:SetScript("OnClick", function(self)
			LoseControlDB.displayTypeDot = self:GetChecked()
			OptionsFunctions:UpdateAll()
			if (self:GetChecked()) then
				LoseControlDB.displayTypeDot = true
			else
				LoseControlDB.displayTypeDot = false
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local SilenceIcon
	if  v == "player" then
		SilenceIcon = CreateFrame("CheckButton", O..v.."SilenceIcon", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		SilenceIcon:SetScale(1)
		SilenceIcon:SetHitRectInsets(0, 0, 0, 0)
		_G[O..v.."SilenceIconText"]:SetText("Shows Secondary Priority Icon")
		SilenceIcon:SetScript("OnClick", function(self)
			LoseControlDB.SilenceIcon = self:GetChecked()
			OptionsFunctions:UpdateAll()
			if (self:GetChecked()) then
				LoseControlDB.SilenceIcon = true
				LoseControlDB.SecondaryIcon = true
			else
				LoseControlDB.SilenceIcon = false
				LoseControlDB.SecondaryIcon = false
			end
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local CountText
	if v == "party" then
		CountText = CreateFrame("CheckButton", O..v.."CountText", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."CountTextText"]:SetText("Show Count and Stacks Text")
		CountText:SetScript("OnClick", function(self)
			LoseControlDB.CountTextparty = self:GetChecked()
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	elseif v == "arena" then
		CountText = CreateFrame("CheckButton", O..v.."CountText", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."CountTextText"]:SetText("Show Count and Stacks Text")
		CountText:SetScript("OnClick", function(self)
			LoseControlDB.CountTextarena = self:GetChecked()
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	elseif v == "player" then
		CountText = CreateFrame("CheckButton", O..v.."CountText", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."CountTextText"]:SetText("Show Count and Stacks Text")
		CountText:SetScript("OnClick", function(self)
			LoseControlDB.CountTextplayer = self:GetChecked()
			if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local catListEnChecksButtons = {
		"CC","Silence","RootPhyiscal_Special","RootMagic_Special","Root","ImmunePlayer","Disarm_Warning","CC_Warning","Enemy_Smoke_Bomb","Stealth",
		"Immune","ImmuneSpell","ImmunePhysical","AuraMastery_Cast_Auras","ROP_Vortex","Disarm","Haste_Reduction","Dmg_Hit_Reduction",
		"AOE_DMG_Modifiers","Friendly_Smoke_Bomb","AOE_Spell_Refections","Trees","Speed_Freedoms","Freedoms","Friendly_Defensives",
		"CC_Reduction","Personal_Offensives","Peronsal_Defensives","Mana_Regen","Movable_Cast_Auras","Other","PvE","SnareSpecial","SnarePhysical70","SnareMagic70",
		"SnarePhysical50","SnarePosion50","SnareMagic50","SnarePhysical30","SnareMagic30","Snare",
	}
	--Interrupts
	local CategoriesCheckButtons = { }
	local FriendlyInterrupt = CreateFrame("CheckButton", O..v.."FriendlyInterrupt", OptionsPanelFrame, "OptionsCheckButtonTemplate")
	FriendlyInterrupt:SetScale(.82)
	FriendlyInterrupt:SetHitRectInsets(0, -36, 0, 0)
	_G[O..v.."FriendlyInterruptText"]:SetText(L["CatFriendly"])
	FriendlyInterrupt:SetScript("OnClick", function(self)
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].categoriesEnabled.interrupt.friendly = self:GetChecked()
			LCframes[frame].maxExpirationTime = 0
			if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
				LCframes[frame]:UNIT_AURA(frame, updatedAuras, 0)
			end
		end
	end)
	tblinsert(CategoriesCheckButtons, { frame = FriendlyInterrupt, auraType = "interrupt", reaction = "friendly", categoryType = "Interrupt", anchorPos = L.CategoryEnabledInterruptLabel, xPos = 120, yPos = 5 })

	if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
		local EnemyInterrupt = CreateFrame("CheckButton", O..v.."EnemyInterrupt", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		EnemyInterrupt:SetScale(.82)
		EnemyInterrupt:SetHitRectInsets(0, -36, 0, 0)
		_G[O..v.."EnemyInterruptText"]:SetText(L["CatEnemy"])
		EnemyInterrupt:SetScript("OnClick", function(self)
			local frames = { v }
			if v == "arena" then
				frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
			end
			for _, frame in ipairs(frames) do
				LoseControlDB.frames[frame].categoriesEnabled.interrupt.enemy = self:GetChecked()
				LCframes[frame].maxExpirationTime = 0
				if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
					LCframes[frame]:UNIT_AURA(frame, updatedAuras, 0)
				end
			end
		end)
		tblinsert(CategoriesCheckButtons, { frame = EnemyInterrupt, auraType = "interrupt", reaction = "enemy", categoryType = "Interrupt", anchorPos = L.CategoryEnabledInterruptLabel, xPos = 250, yPos = 5 })
	end

	--Spells
	for _, cat in pairs(catListEnChecksButtons) do
		if not strfind(v, "arena") then
			local FriendlyBuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyBuff:SetScale(.82)
			FriendlyBuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."BuffText"]:SetText(L["CatFriendlyBuff"])
			FriendlyBuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "party" then
					frames = { "party1", "party2", "party3", "party4" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.buff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyBuff, auraType = "buff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 120, yPos = 5 })
		end

		if not strfind(v, "arena") then
			local FriendlyDebuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyDebuff:SetScale(.82)
			FriendlyDebuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."DebuffText"]:SetText(L["CatFriendlyDebuff"])
			FriendlyDebuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "party" then
					frames = { "party1", "party2", "party3", "party4" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.debuff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyDebuff, auraType = "debuff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 185, yPos = 5 })
		end

		if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget"  then
			local EnemyBuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			EnemyBuff:SetScale(.82)
			EnemyBuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Enemy"..cat.."BuffText"]:SetText(L["CatEnemyBuff"])
			EnemyBuff:SetScript("OnClick", function(self)
				LoseControlDB.frames[v].categoriesEnabled.buff.enemy[cat] = self:GetChecked()
				LCframes[v].maxExpirationTime = 0
				if LoseControlDB.frames[v].enabled and not LCframes[v].unlockMode then
					LCframes[v]:UNIT_AURA(v, updatedAuras, 0)
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = EnemyBuff, auraType = "buff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 250, yPos = 5 })
		end

		if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget"  then
			local EnemyDebuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			EnemyDebuff:SetScale(.82)
			EnemyDebuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Enemy"..cat.."DebuffText"]:SetText(L["CatEnemyDebuff"])
			EnemyDebuff:SetScript("OnClick", function(self)
				LoseControlDB.frames[v].categoriesEnabled.debuff.enemy[cat] = self:GetChecked()
				LCframes[v].maxExpirationTime = 0
				if LoseControlDB.frames[v].enabled and not LCframes[v].unlockMode then
					LCframes[v]:UNIT_AURA(v, updatedAuras, 0)
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = EnemyDebuff, auraType = "debuff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 305, yPos = 5 })
		end
	end




	---Spells Arena
	local catListEnChecksButtonsArena = {
			"Drink_Purge",
			"Immune_Arena",
			"CC_Arena",
			"Silence_Arena",
			"Special_High",
			"Ranged_Major_OffenisiveCDs",
			"Roots_90_Snares",
			"Disarms",
			"Melee_Major_OffenisiveCDs",
			"Big_Defensive_CDs",
			"Player_Party_OffensiveCDs",
			"Small_Offenisive_CDs",
			"Small_Defensive_CDs",
			"Freedoms_Speed",
			"Snares_WithCDs",
			"Special_Low",
			"Snares_Ranged_Spamable",
			"Snares_Casted_Melee",
	}
	for _, cat in pairs(catListEnChecksButtonsArena) do
		if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local FriendlyBuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyBuff:SetScale(.82)
			FriendlyBuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."BuffText"]:SetText(L["CatFriendlyBuff"])
			FriendlyBuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.buff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyBuff, auraType = "buff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 120, yPos = 5 })
		end

		if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local FriendlyDebuff = CreateFrame("CheckButton", O..v.."Friendly"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyDebuff:SetScale(.82)
			FriendlyDebuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."DebuffText"]:SetText(L["CatFriendlyDebuff"])
			FriendlyDebuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.debuff.friendly[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = FriendlyDebuff, auraType = "debuff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 185, yPos = 5 })
		end

		if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local EnemyBuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Buff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			EnemyBuff:SetScale(.82)
			EnemyBuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Enemy"..cat.."BuffText"]:SetText(L["CatEnemyBuff"])
			EnemyBuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.buff.enemy[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = EnemyBuff, auraType = "buff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 250, yPos = 5 })
		end

		if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget" or strfind(v, "arena") then
			local EnemyDebuff = CreateFrame("CheckButton", O..v.."Enemy"..cat.."Debuff", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			EnemyDebuff:SetScale(.82)
			EnemyDebuff:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Enemy"..cat.."DebuffText"]:SetText(L["CatEnemyDebuff"])
			EnemyDebuff:SetScript("OnClick", function(self)
				local frames = { v }
				if v == "arena" then
					frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
				end
				for _, frame in ipairs(frames) do
					LoseControlDB.frames[frame].categoriesEnabled.debuff.enemy[cat] = self:GetChecked()
					LCframes[frame].maxExpirationTime = 0
					if LoseControlDB.frames[frame].enabled and not LCframes[frame].unlockMode then
						LCframes[frame]:UNIT_AURA(frame, updatedAuras, 0)
					end
				end
			end)
			tblinsert(CategoriesCheckButtons, { frame = EnemyDebuff, auraType = "debuff", reaction = "enemy", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 305, yPos = 5 })
		end
	end


	local CategoriesCheckButtonsPlayer2
	if (v == "player") then
		CategoriesCheckButtonsPlayer2 = { }
		local FriendlyInterruptPlayer2 = CreateFrame("CheckButton", O..v.."FriendlyInterruptPlayer2", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		FriendlyInterruptPlayer2:SetScale(.82)
		FriendlyInterruptPlayer2:SetHitRectInsets(0, -36, 0, 0)
		_G[O..v.."FriendlyInterruptPlayer2Text"]:SetText(L["CatFriendly"].."|cfff28614(Icon2)|r")
		FriendlyInterruptPlayer2:SetScript("OnClick", function(self)
			LoseControlDB.frames.player2.categoriesEnabled.interrupt.friendly = self:GetChecked()
			LCframeplayer2.maxExpirationTime = 0
			if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
				LCframeplayer2:UNIT_AURA(v, updatedAuras, 0)
			end
		end)
		tblinsert(CategoriesCheckButtonsPlayer2, { frame = FriendlyInterruptPlayer2, auraType = "interrupt", reaction = "friendly", categoryType = "Interrupt", anchorPos = L.CategoryEnabledInterruptLabel, xPos = 250, yPos = 5 })
		for _, cat in pairs(catListEnChecksButtons) do
			local FriendlyBuffPlayer2 = CreateFrame("CheckButton", O..v.."Friendly"..cat.."BuffPlayer2", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyBuffPlayer2:SetScale(.82)
			FriendlyBuffPlayer2:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."BuffPlayer2Text"]:SetText(L["CatFriendlyBuff"].."|cfff28614(Icon2)|r")
			FriendlyBuffPlayer2:SetScript("OnClick", function(self)
				LoseControlDB.frames.player2.categoriesEnabled.buff.friendly[cat] = self:GetChecked()
				LCframeplayer2.maxExpirationTime = 0
				if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(v, updatedAuras, 0)
				end
			end)
			tblinsert(CategoriesCheckButtonsPlayer2, { frame = FriendlyBuffPlayer2, auraType = "buff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 250, yPos = 5 })
			local FriendlyDebuffPlayer2 = CreateFrame("CheckButton", O..v.."Friendly"..cat.."DebuffPlayer2", OptionsPanelFrame, "OptionsCheckButtonTemplate")
			FriendlyDebuffPlayer2:SetScale(.82)
			FriendlyDebuffPlayer2:SetHitRectInsets(0, -36, 0, 0)
			_G[O..v.."Friendly"..cat.."DebuffPlayer2Text"]:SetText(L["CatFriendlyDebuff"].."|cfff28614(Icon2)|r")
			FriendlyDebuffPlayer2:SetScript("OnClick", function(self)
				LoseControlDB.frames.player2.categoriesEnabled.debuff.friendly[cat] = self:GetChecked()
				LCframeplayer2.maxExpirationTime = 0
				if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(v, updatedAuras, 0)
				end
			end)
			tblinsert(CategoriesCheckButtonsPlayer2, { frame = FriendlyDebuffPlayer2, auraType = "debuff", reaction = "friendly", categoryType = cat, anchorPos = CategoriesLabels[cat], xPos = 359, yPos = 5 })
		end
	end

	local DuplicatePlayerPortrait
	if v == "player" then
		DuplicatePlayerPortrait = CreateFrame("CheckButton", O..v.."DuplicatePlayerPortrait", OptionsPanelFrame, "OptionsCheckButtonTemplate")
		_G[O..v.."DuplicatePlayerPortraitText"]:SetText(L["DuplicatePlayerPortrait"])
		function DuplicatePlayerPortrait:Check(value)
			LoseControlDB.duplicatePlayerPortrait = self:GetChecked()
			local enable = LoseControlDB.duplicatePlayerPortrait and LoseControlDB.frames.player.enabled
			if AlphaSlider2 then
				if enable then
					LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(AlphaSlider2)
				else
					LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(AlphaSlider2)
				end
			end
			if AnchorDropDown2 then
				if enable then
					UIDropDownMenu_EnableDropDown(AnchorDropDown2)
				else
					UIDropDownMenu_DisableDropDown(AnchorDropDown2)
				end
			end
			if CategoriesCheckButtonsPlayer2 then
				if enable then
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(checkbuttonframeplayer2.frame)
					end
				else
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
					end
				end
			end
			LoseControlDB.frames.player2.enabled = enable
			LCframeplayer2.maxExpirationTime = 0
			LCframeplayer2:RegisterUnitEvents(enable)
			if self:GetChecked() and LoseControlDB.frames.player.anchor ~= "None" then
				local frame = LoseControlDB.frames["player"]
				frame.anchor = "None"
				local AnchorDropDown = _G['LoseControlOptionsPanel'..LCframes.player.unitId..'AnchorDropDown']
				if (AnchorDropDown) then
					UIDropDownMenu_SetSelectedValue(AnchorDropDown, frame.anchor)
				end
				LCframes.player.anchor = _G[anchors[frame.anchor][LCframes.player.unitId]] or (type(anchors[frame.anchor][LCframes.player.unitId])=="table" and anchors[frame.anchor][LCframes.player.unitId] or UIParent)
				LCframes.player:ClearAllPoints()
				LCframes.player:SetPoint(
					"CENTER",
					LCframes.player.anchor,
					"CENTER",
					0,
					0
				)
				LCframes.player:GetParent():SetPoint(
					"CENTER",
					LCframes.player.anchor,
					"CENTER",
					0,
					0
				)
				if LCframes.player.anchor:GetParent() then
					LCframes.player:SetFrameLevel(LCframes.player.anchor:GetParent():GetFrameLevel()+((frame.anchor ~= "None" and frame.anchor ~= "Blizzard") and 3 or 0))
				end
			end
			if enable and not LCframeplayer2.unlockMode then
				LCframeplayer2:UNIT_AURA(v, updatedAuras, 0)
			end
		end
		DuplicatePlayerPortrait:SetScript("OnClick", function(self)
			DuplicatePlayerPortrait:Check(self:GetChecked())
			if LCframeplayer2.unlockMode then --This updates in unlock mode
				if (Unlock:GetChecked()) then
				Unlock:SetChecked(false)
				Unlock:OnClick()
				Unlock:SetChecked(true)
				Unlock:OnClick()
				end
			end
			OptionsFunctions:UpdateAll()
		end)
	end

	local Enabled = CreateFrame("CheckButton", O..v.."Enabled", OptionsPanelFrame, "OptionsCheckButtonTemplate")
	_G[O..v.."EnabledText"]:SetText(L["Enabled"])
	Enabled:SetScript("OnClick", function(self)
		local enabled = self:GetChecked()
		if enabled then
			if DisableInBG then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableInBG) end
			if EnableGladiusGloss then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(EnableGladiusGloss) end
			if lossOfControl then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(lossOfControl) end
			if PlayerText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(PlayerText) end
			if ArenaPlayerText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(ArenaPlayerText) end
			if displayTypeDot then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(displayTypeDot) end
			if SilenceIcon then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(SilenceIcon) end
			if CountText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(CountText) end
			if DisableInRaid then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableInRaid) end
			if ShowNPCInterrupts then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				if LoseControlDB.duplicatePlayerPortrait then
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(checkbuttonframeplayer2.frame)
					end
				else
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
					end
				end
			end
			CategoriesEnabledLabel:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())

			for k, catColor in ipairs(CategoriesLabels) do
				catColor:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
			end
			if v == "arena" then LoseControlDB.EnableGladiusGloss = true; 
				EnableGladiusGloss:SetChecked(LoseControlDB.EnableGladiusGloss) 
			end
			LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(SizeSlider)
			LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(AlphaSlider)
			if v =="player" then
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlInterrupt)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlFull)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlSilence)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlDisarm)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlRoot)
			end
			UIDropDownMenu_EnableDropDown(AnchorDropDown)
			if LoseControlDB.duplicatePlayerPortrait then
				if AlphaSlider2 then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_EnableDropDown(AnchorDropDown2) end
			else
				if AlphaSlider2 then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
			end
		else
			if DisableInBG then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableInBG) end
			if EnableGladiusGloss then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(EnableGladiusGloss) end
			if lossOfControl then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(lossOfControl) end
			if PlayerText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(PlayerText) end
			if ArenaPlayerText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(ArenaPlayerText) end
			if displayTypeDot then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(displayTypeDot) end
			if SilenceIcon then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(SilenceIcon) end
			if CountText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(CountText) end
			if DisableInRaid then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableInRaid) end
			if ShowNPCInterrupts then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
					LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
				end
			end
			CategoriesEnabledLabel:SetVertexColor(GRAY_FONT_COLOR:GetRGB())

			if v == "arena" then
				LoseControlDB.EnableGladiusGloss = false
				EnableGladiusGloss:SetChecked(LoseControlDB.EnableGladiusGloss)
				if (Unlock:GetChecked()) then
					DEFAULT_CHAT_FRAME.editBox:SetText("/gladius hide")
					ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
					for k, v in pairs(LCframes) do
						if strfind(k, "arena") then
							if v.gloss:IsShown() then
								v.gloss:Hide()
							end
						end
					end
				end
			end

			for k, catGrey in ipairs(CategoriesLabels) do
				catGrey:SetVertexColor(GRAY_FONT_COLOR:GetRGB())
			end
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(SizeSlider)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(AlphaSlider)
			if v =="player" then
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlInterrupt)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlFull)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlSilence)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlDisarm)
				LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlRoot)
			end
				UIDropDownMenu_DisableDropDown(AnchorDropDown)
				if AlphaSlider2 then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
		end
		local frames = { v }
		if v == "party" then
			frames = { "party1", "party2", "party3", "party4" }
		elseif v == "arena" then
			frames = { "arena1", "arena2", "arena3", "arena4", "arena5" }
		end
		for _, frame in ipairs(frames) do
			LoseControlDB.frames[frame].enabled = enabled
			local inInstance, instanceType = IsInInstance()
			local enable = enabled and not (
				inInstance and instanceType == "pvp" and (
					( LoseControlDB.disablePartyInBG and strfind(frame, "party") ) or
					( LoseControlDB.disableArenaInBG and strfind(frame, "arena") )
				)
			) and not (
				IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(frame,  "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp" or instanceType=="party"))
			)
			LCframes[frame].maxExpirationTime = 0
			LCframes[frame]:RegisterUnitEvents(enable)
			if enable and not LCframes[frame].unlockMode then
				LCframes[frame]:UNIT_AURA(frame, updatedAuras, 0)
			end
			if (frame == "player") then
				LoseControlDB.frames.player2.enabled = enabled and LoseControlDB.duplicatePlayerPortrait
				LCframeplayer2.maxExpirationTime = 0
				LCframeplayer2:RegisterUnitEvents(enabled and LoseControlDB.duplicatePlayerPortrait)
				if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
					LCframeplayer2:UNIT_AURA(frame, updatedAuras, 0)
				end
			end
		end
		if (Unlock:GetChecked()) then
			Unlock:SetChecked(false)
			Unlock:OnClick()
			Unlock:SetChecked(true)
			Unlock:OnClick()
		end
    	OptionsFunctions:UpdateAll()
	end)

	Enabled:SetPoint("TOPLEFT", 8, -4)
	if DisableInBG then DisableInBG:SetPoint("TOPLEFT", Enabled, 275, 0) end
	if v == "party" or v == "arena" then
   		if CountText then CountText:SetPoint("TOPLEFT", DisableInBG, "TOPRIGHT", 150, 0) end
 	 end
 	if EnableGladiusGloss then EnableGladiusGloss:SetPoint("TOPLEFT", Enabled, 275, -25)end
	if DisableInRaid then DisableInRaid:SetPoint("TOPLEFT", Enabled, 275, -25) end
	if ShowNPCInterrupts then ShowNPCInterrupts:SetPoint("TOPLEFT", Enabled, 450, 2);ShowNPCInterrupts:SetScale(.8) end
	if DisablePlayerTargetTarget then DisablePlayerTargetTarget:SetPoint("TOPLEFT", Enabled, 450, -13);DisablePlayerTargetTarget:SetScale(.8) end
	if DisableTargetTargetTarget then DisableTargetTargetTarget:SetPoint("TOPLEFT", Enabled, 450, -28); DisableTargetTargetTarget:SetScale(.8) end
	if DisableFocusFocusTarget then DisableFocusFocusTarget:SetPoint("TOPLEFT", Enabled, 450, -28);DisableFocusFocusTarget:SetScale(.8) end
	if DisablePlayerTargetPlayerTargetTarget then DisablePlayerTargetPlayerTargetTarget:SetPoint("TOPLEFT", Enabled, 450, -43);DisablePlayerTargetPlayerTargetTarget:SetScale(.8) end
	if DisablePlayerFocusPlayerFocusTarget then DisablePlayerFocusPlayerFocusTarget:SetPoint("TOPLEFT", Enabled, 450, -43);DisablePlayerFocusPlayerFocusTarget:SetScale(.8) end
	if DisableTargetDeadTargetTarget then DisableTargetDeadTargetTarget:SetPoint("TOPLEFT", Enabled,450, -58);DisableTargetDeadTargetTarget:SetScale(.8) end
	if DisableFocusDeadFocusTarget then DisableFocusDeadFocusTarget:SetPoint("TOPLEFT", Enabled, 450, -58); DisableFocusDeadFocusTarget:SetScale(.8) end

	if DuplicatePlayerPortrait then DuplicatePlayerPortrait:SetPoint("TOPLEFT", Enabled, 275, 0) end
	AnchorDropDown:SetPoint("TOPLEFT", Enabled, "BOTTOMLEFT", -13, -3)
	AnchorDropDown:SetScale(.9)
	AnchorDropDownLabel:SetPoint("BOTTOMLEFT", AnchorDropDown, "TOPRIGHT", 60,-1)
	AnchorDropDownLabel:SetScale(.8)
	SizeSlider:SetPoint("TOPLEFT", Enabled, "TOPRIGHT", 115, -20)
	AlphaSlider:SetPoint("TOPLEFT", SizeSlider, "BOTTOMLEFT", 0, -16)
	CategoriesEnabledLabel:SetPoint("TOPLEFT", AnchorDropDown, "BOTTOMLEFT", 17, -3)

	if L.CategoryEnabledInterruptLabel then L.CategoryEnabledInterruptLabel:SetPoint("TOPLEFT", CategoriesEnabledLabel, "BOTTOMLEFT", 0, -6); L.CategoryEnabledInterruptLabel:SetScale(.75) end

	if v ~= "arena" then
		local labels ={
			L.CategoryEnabledCCLabel,L.CategoryEnabledSilenceLabel,L.CategoryEnabledRootPhyiscal_SpecialLabel,L.CategoryEnabledRootMagic_SpecialLabel,L.CategoryEnabledRootLabel,L.CategoryEnabledImmunePlayerLabel,L.CategoryEnabledDisarm_WarningLabel,L.CategoryEnabledCC_WarningLabel,L.CategoryEnabledEnemy_Smoke_BombLabel,L.CategoryEnabledStealthLabel,L.CategoryEnabledImmuneLabel,L.CategoryEnabledImmuneSpellLabel,L.CategoryEnabledImmunePhysicalLabel,L.CategoryEnabledAuraMastery_Cast_AurasLabel,L.CategoryEnabledROP_VortexLabel,L.CategoryEnabledDisarmLabel,L.CategoryEnabledHaste_ReductionLabel,L.CategoryEnabledDmg_Hit_ReductionLabel,L.CategoryEnabledAOE_DMG_ModifiersLabel,L.CategoryEnabledFriendly_Smoke_BombLabel,L.CategoryEnabledAOE_Spell_RefectionsLabel,L.CategoryEnabledTreesLabel,L.CategoryEnabledSpeed_FreedomsLabel,L.CategoryEnabledFreedomsLabel,L.CategoryEnabledFriendly_DefensivesLabel,L.CategoryEnabledCC_ReductionLabel,L.CategoryEnabledPersonal_OffensivesLabel,L.CategoryEnabledPeronsal_DefensivesLabel,L.CategoryEnabledMana_RegenLabel,L.CategoryEnabledMovable_Cast_AurasLabel,L.CategoryEnabledOtherLabel,L.CategoryEnabledPvELabel,L.CategoryEnabledSnareSpecialLabel,L.CategoryEnabledSnarePhysical70Label,L.CategoryEnabledSnareMagic70Label,L.CategoryEnabledSnarePhysical50Label,L.CategoryEnabledSnarePosion50Label,L.CategoryEnabledSnareMagic50Label,L.CategoryEnabledSnarePhysical30Label,L.CategoryEnabledSnareMagic30Label,L.CategoryEnabledSnareLabel
		}
		for k, catEn in ipairs(labels) do
			if k == 1 then
				if catEn then catEn:SetPoint("TOPLEFT", L.CategoryEnabledInterruptLabel, "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
			else
				if catEn then catEn:SetPoint("TOPLEFT", labels[k-1], "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
			end
		end
	end

	if v == "arena" then
		local labelsArena ={						
			L.CategoryEnabledDrink_PurgeLabel,L.CategoryEnabledImmune_ArenaLabel,L.CategoryEnabledCC_ArenaLabel,L.CategoryEnabledSilence_ArenaLabel,L.CategoryEnabledSpecial_HighLabel,L.CategoryEnabledRanged_Major_OffenisiveCDsLabel,L.CategoryEnabledRoots_90_SnaresLabel,L.CategoryEnabledDisarmsLabel,L.CategoryEnabledMelee_Major_OffenisiveCDsLabel,L.CategoryEnabledBig_Defensive_CDsLabel,L.CategoryEnabledPlayer_Party_OffensiveCDsLabel,L.CategoryEnabledSmall_Offenisive_CDsLabel,L.CategoryEnabledSmall_Defensive_CDsLabel,L.CategoryEnabledFreedoms_SpeedLabel,L.CategoryEnabledSnares_WithCDsLabel,L.CategoryEnabledSpecial_LowLabel,L.CategoryEnabledSnares_Ranged_SpamableLabel,L.CategoryEnabledSnares_Casted_MeleeLabel,
		}
		for k, catEn in ipairs(labelsArena) do
			if k == 1 then
				if catEn then catEn:SetPoint("TOPLEFT", L.CategoryEnabledInterruptLabel, "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
			else
				if catEn then catEn:SetPoint("TOPLEFT", labelsArena[k-1], "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
			end
		end
	end

	if v == "target" or v == "targettarget" or v == "focus" or v == "focustarget"  then
		local labelsArena ={					
			L.CategoryEnabledDrink_PurgeLabel,L.CategoryEnabledImmune_ArenaLabel,L.CategoryEnabledCC_ArenaLabel,L.CategoryEnabledSilence_ArenaLabel,L.CategoryEnabledSpecial_HighLabel,L.CategoryEnabledRanged_Major_OffenisiveCDsLabel,L.CategoryEnabledRoots_90_SnaresLabel,L.CategoryEnabledDisarmsLabel,L.CategoryEnabledMelee_Major_OffenisiveCDsLabel,L.CategoryEnabledBig_Defensive_CDsLabel,L.CategoryEnabledPlayer_Party_OffensiveCDsLabel,L.CategoryEnabledSmall_Offenisive_CDsLabel,L.CategoryEnabledSmall_Defensive_CDsLabel,L.CategoryEnabledFreedoms_SpeedLabel,L.CategoryEnabledSnares_WithCDsLabel,L.CategoryEnabledSpecial_LowLabel,L.CategoryEnabledSnares_Ranged_SpamableLabel,L.CategoryEnabledSnares_Casted_MeleeLabel,
			}
		for k, catEn in ipairs(labelsArena) do
			if k == 1 then
				if catEn then catEn:SetPoint("TOPLEFT", L.CategoryEnabledCCLabel, "TOPRIGHT", 381, 0); catEn:SetScale(.75) end
			else
				if catEn then catEn:SetPoint("TOPLEFT", labelsArena[k-1], "BOTTOMLEFT", 0, -3); catEn:SetScale(.75) end
			end
		end
	end

	if lossOfControl then lossOfControl:SetPoint("TOPLEFT", L.CategoryEnabledCCLabel, "TOPRIGHT", 390, 7) end
	if lossOfControlInterrupt then lossOfControlInterrupt:SetPoint("TOPLEFT", lossOfControl, "BOTTOMLEFT", 0, -18) end
	if lossOfControlFull then lossOfControlFull:SetPoint("TOPLEFT", lossOfControlInterrupt, "BOTTOMLEFT", 0, -18) end
	if lossOfControlSilence then lossOfControlSilence:SetPoint("TOPLEFT", lossOfControlFull, "BOTTOMLEFT", 0, -18) end
	if lossOfControlDisarm then lossOfControlDisarm:SetPoint("TOPLEFT", lossOfControlSilence, "BOTTOMLEFT", 0, -18) end
	if lossOfControlRoot then lossOfControlRoot:SetPoint("TOPLEFT", lossOfControlDisarm, "BOTTOMLEFT", 0, -18) end
	if v == "player" then
		local LoCOptions = OptionsPanelFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		LoCOptions:SetFont("Fonts\\FRIZQT__.TTF", 11 )
		LoCOptions:SetText("Blizzard Loss of Control must be \nenabled to discover new spells \n\n|cffff00000:|r Disables Bliz LoC Type \n1: Shows icon for small duartion \n|cff00ff002:|r Shows icon for full duration \n \n ")
		LoCOptions:SetJustifyH("LEFT")
		LoCOptions:SetPoint("TOPLEFT", lossOfControlRoot, "TOPLEFT", -5, -15)
	end

	if PlayerText then PlayerText:SetPoint("TOPLEFT", lossOfControlRoot, "BOTTOMLEFT", -18, -85) end

	if v == "player" then
		local LoCOptions1 = OptionsPanelFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		LoCOptions1:SetFont("Fonts\\FRIZQT__.TTF", 11 )
		LoCOptions1:SetText("Shows text Type of the Spell")
		LoCOptions1:SetJustifyH("LEFT")
		LoCOptions1:SetPoint("TOPLEFT", PlayerText, "BOTTOMLEFT", 25, 7)
	end

	if ArenaPlayerText then ArenaPlayerText:SetPoint("TOPLEFT", lossOfControlRoot, "BOTTOMLEFT", -18, -115) end

	if v == "player" then
		local LoCOptions2 = OptionsPanelFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		LoCOptions2:SetFont("Fonts\\FRIZQT__.TTF", 11 )
		LoCOptions2:SetText("Disable Player text in Arena")
		LoCOptions2:SetJustifyH("LEFT")
		LoCOptions2:SetPoint("TOPLEFT", ArenaPlayerText, "BOTTOMLEFT", 25, 7)
	end

	if displayTypeDot then displayTypeDot:SetPoint("TOPLEFT", lossOfControlRoot, "BOTTOMLEFT", -18, -145) end

	if v == "player" then
		local LoCOptions3 = OptionsPanelFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		LoCOptions3:SetFont("Fonts\\FRIZQT__.TTF", 11 )
		LoCOptions3:SetText("Curse/Disease/Magic/Etc..")
		LoCOptions3:SetJustifyH("LEFT")
		LoCOptions3:SetPoint("TOPLEFT", displayTypeDot, "BOTTOMLEFT", 25, 7)
	end

	if SilenceIcon then SilenceIcon:SetPoint("TOPLEFT", lossOfControlRoot, "BOTTOMLEFT", -18, -200) end
	if v == "player" then
		if CountText then CountText:SetPoint("TOPLEFT", SilenceIcon, "BOTTOMLEFT", 0, -35) end
	end

	if v == "player" then
		local LoCOptions4 = OptionsPanelFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		LoCOptions4:SetFont("Fonts\\FRIZQT__.TTF", 11 )
		LoCOptions4:SetText("Shows the Next Priority Icon \nGroups Certain Icons for Effciency")
		LoCOptions4:SetJustifyH("LEFT")
		LoCOptions4:SetPoint("TOPLEFT", SilenceIcon, "BOTTOMLEFT", 25, 7)
	end

	for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
		checkbuttonframe.frame:SetPoint("TOPLEFT", checkbuttonframe.anchorPos, checkbuttonframe.xPos, checkbuttonframe.yPos)
	end
	if CategoriesCheckButtonsPlayer2 then
		for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
			checkbuttonframeplayer2.frame:SetPoint("TOPLEFT", checkbuttonframeplayer2.anchorPos, checkbuttonframeplayer2.xPos, checkbuttonframeplayer2.yPos)
		end
	end

	if AnchorDropDown2 then AnchorDropDown2:SetPoint("TOPLEFT", DuplicatePlayerPortrait, "BOTTOMLEFT", -13, -3); AnchorDropDown2:SetScale(.9) end
	if AnchorDropDown2Label then AnchorDropDown2Label:SetPoint("BOTTOMLEFT", AnchorDropDown2, "TOPRIGHT", 60,-2);	AnchorDropDown2Label:SetScale(.8) end
	if AlphaSlider2 then AlphaSlider2:SetPoint("TOPLEFT", AlphaSlider, "TOPRIGHT", 155, 0) end

	OptionsPanelFrame.default = OptionsPanel.default
	OptionsPanelFrame.refresh = function()
		local unitId = v
		if unitId == "party" then
			DisableInBG:SetChecked(LoseControlDB.disablePartyInBG)
			DisableInRaid:SetChecked(LoseControlDB.disablePartyInRaid)
			CountText:SetChecked(LoseControlDB.CountTextparty)
			unitId = "party1"
		elseif unitId == "arena" then
			DisableInBG:SetChecked(LoseControlDB.disableArenaInBG)
			EnableGladiusGloss:SetChecked(LoseControlDB.EnableGladiusGloss)
			CountText:SetChecked(LoseControlDB.CountTextarena)
			unitId = "arena1"
		elseif unitId == "player" then
			DuplicatePlayerPortrait:SetChecked(LoseControlDB.duplicatePlayerPortrait)
			AlphaSlider2:SetValue(LoseControlDB.frames.player2.alpha * 100)
			PlayerText:SetChecked(LoseControlDB.PlayerText)
			ArenaPlayerText:SetChecked(LoseControlDB.ArenaPlayerText)
			displayTypeDot:SetChecked(LoseControlDB.displayTypeDot)
			SilenceIcon:SetChecked(LoseControlDB.SilenceIcon)
			CountText:SetChecked(LoseControlDB.CountTextplayer)
			lossOfControl:SetChecked(LoseControlDB.lossOfControl)
			SetCVar("lossOfControl", LoseControlDB.lossOfControl)
			lossOfControlInterrupt:SetValue(LoseControlDB.lossOfControlInterrupt)
			SetCVar("lossOfControlInterrupt", LoseControlDB.lossOfControlInterrupt)

			lossOfControlFull:SetValue(LoseControlDB.lossOfControlFull)
			SetCVar("lossOfControlFull", LoseControlDB.lossOfControlFull)

			lossOfControlSilence:SetValue(LoseControlDB.lossOfControlSilence)
			SetCVar("lossOfControlSilence", LoseControlDB.lossOfControlSilence)

			lossOfControlDisarm:SetValue(LoseControlDB.lossOfControlDisarm)
			SetCVar("lossOfControlDisarm", LoseControlDB.lossOfControlDisarm)

			lossOfControlRoot:SetValue(LoseControlDB.lossOfControlRoot)
			SetCVar("lossOfControlRoot", LoseControlDB.lossOfControlRoot)
		elseif unitId == "target" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsTarget)
		elseif unitId == "focus" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsFocus)
		elseif unitId == "targettarget" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsTargetTarget)
			DisablePlayerTargetTarget:SetChecked(LoseControlDB.disablePlayerTargetTarget)
			DisableTargetTargetTarget:SetChecked(LoseControlDB.disableTargetTargetTarget)
			DisablePlayerTargetPlayerTargetTarget:SetChecked(LoseControlDB.disablePlayerTargetPlayerTargetTarget)
			DisableTargetDeadTargetTarget:SetChecked(LoseControlDB.disableTargetDeadTargetTarget)
		elseif unitId == "focustarget" then
			ShowNPCInterrupts:SetChecked(LoseControlDB.showNPCInterruptsFocusTarget)
			DisablePlayerTargetTarget:SetChecked(LoseControlDB.disablePlayerFocusTarget)
			DisableFocusFocusTarget:SetChecked(LoseControlDB.disableFocusFocusTarget)
			DisablePlayerFocusPlayerFocusTarget:SetChecked(LoseControlDB.disablePlayerFocusPlayerFocusTarget)
			DisableFocusDeadFocusTarget:SetChecked(LoseControlDB.disableFocusDeadFocusTarget)
		end
		if unitId ~= "player3" then
			LCframes[unitId]:CheckGladiusUnitsAnchors(true)
			LCframes[unitId]:CheckGladdyUnitsAnchors(true)
			LCframes[unitId]:CheckSUFUnitsAnchors(true)
		end
		for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
			if checkbuttonframe.auraType ~= "interrupt" then
				checkbuttonframe.frame:SetChecked(LoseControlDB.frames[unitId].categoriesEnabled[checkbuttonframe.auraType][checkbuttonframe.reaction][checkbuttonframe.categoryType])
			else
				checkbuttonframe.frame:SetChecked(LoseControlDB.frames[unitId].categoriesEnabled[checkbuttonframe.auraType][checkbuttonframe.reaction])
			end
		end
		if CategoriesCheckButtonsPlayer2 then
			for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
				if checkbuttonframeplayer2.auraType ~= "interrupt" then
					checkbuttonframeplayer2.frame:SetChecked(LoseControlDB.frames.player2.categoriesEnabled[checkbuttonframeplayer2.auraType][checkbuttonframeplayer2.reaction][checkbuttonframeplayer2.categoryType])
				else
					checkbuttonframeplayer2.frame:SetChecked(LoseControlDB.frames.player2.categoriesEnabled[checkbuttonframeplayer2.auraType][checkbuttonframeplayer2.reaction])
				end
			end
		end
		local frame = LoseControlDB.frames[unitId]
		Enabled:SetChecked(frame.enabled)
		if frame.enabled then
			if DisableInBG then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableInBG) end
			if EnableGladiusGloss then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(EnableGladiusGloss) end
			if lossOfControl then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(lossOfControl) end
			if PlayerText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(PlayerText) end
			if ArenaPlayerText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(ArenaPlayerText) end
			if displayTypeDot then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(displayTypeDot) end
			if SilenceIcon then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(SilenceIcon) end
			if CountText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(CountText) end
			if DisableInRaid then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableInRaid) end
			if ShowNPCInterrupts then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				if LoseControlDB.duplicatePlayerPortrait then
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Enable(checkbuttonframeplayer2.frame)
					end
				else
					for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
						LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
					end
				end
			end
			CategoriesEnabledLabel:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())

			for k, catColor in ipairs(CategoriesLabels) do
			catColor:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
			end

			LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(SizeSlider)
			LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(AlphaSlider)
			UIDropDownMenu_EnableDropDown(AnchorDropDown)
			if LoseControlDB.lossOfControl then
				if lossOfControlInterrupt then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlInterrupt) end
				if lossOfControlFull then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlFull) end
				if lossOfControlSilence then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlSilence) end
				if lossOfControlDisarm then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlDisarm) end
				if lossOfControlRoot then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(lossOfControlRoot) end
				--
			else
				if lossOfControlInterrupt then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlInterrupt) end
				if lossOfControlFull then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlFull) end
				if lossOfControlSilence then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlSilence) end
				if lossOfControlDisarm then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlDisarm) end
				if lossOfControlRoot then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlRoot) end
			end
			if LoseControlDB.duplicatePlayerPortrait then
				if AlphaSlider2 then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Enable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_EnableDropDown(AnchorDropDown2) end
			else
				if AlphaSlider2 then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(AlphaSlider2) end
				if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
			end
		else
			if DisableInBG then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableInBG) end
			if EnableGladiusGloss then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(EnableGladiusGloss) end
			if lossOfControl then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(lossOfControl) end
			if PlayerText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(PlayerText) end
			if ArenaPlayerText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(ArenaPlayerText) end
			if displayTypeDot then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(displayTypeDot) end
			if SilenceIcon then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(SilenceIcon) end
			if CountText then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(CountText) end
			if DisableInRaid then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableInRaid) end
			if ShowNPCInterrupts then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(ShowNPCInterrupts) end
			if DisablePlayerTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisablePlayerTargetTarget) end
			if DisableTargetTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableTargetTargetTarget) end
			if DisablePlayerTargetPlayerTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisablePlayerTargetPlayerTargetTarget) end
			if DisableTargetDeadTargetTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableTargetDeadTargetTarget) end
			if DisableFocusFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableFocusFocusTarget) end
			if DisablePlayerFocusPlayerFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisablePlayerFocusPlayerFocusTarget) end
			if DisableFocusDeadFocusTarget then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DisableFocusDeadFocusTarget) end
			if DuplicatePlayerPortrait then LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(DuplicatePlayerPortrait) end
			for _, checkbuttonframe in pairs(CategoriesCheckButtons) do
				LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(checkbuttonframe.frame)
			end
			if CategoriesCheckButtonsPlayer2 then
				for _, checkbuttonframeplayer2 in pairs(CategoriesCheckButtonsPlayer2) do
					LCOptionsPanelFuncs.LCOptionsPanel_CheckButton_Disable(checkbuttonframeplayer2.frame)
				end
			end
			CategoriesEnabledLabel:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())

			for k, catColor in ipairs(CategoriesLabels) do
				catColor:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
			end

			LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(SizeSlider)
			LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(AlphaSlider)
			UIDropDownMenu_DisableDropDown(AnchorDropDown)
			if lossOfControlInterrupt then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlInterrupt) end
			if lossOfControlFull then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlFull) end
			if lossOfControlSilence then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlSilence) end
			if lossOfControlDisarm then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlDisarm) end
			if lossOfControlRoot then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(lossOfControlRoot) end
			if AlphaSlider2 then LCOptionsPanelFuncs.LCOptionsPanel_Slider_Disable(AlphaSlider2) end
			if AnchorDropDown2 then UIDropDownMenu_DisableDropDown(AnchorDropDown2) end
		end
		SizeSlider:SetValue(frame.size)
		AlphaSlider:SetValue(frame.alpha * 100)
		UIDropDownMenu_Initialize(AnchorDropDown, function() -- called on refresh and also every time the drop down menu is opened
			AddItem(AnchorDropDown, L["None"], "None")
			if v ~= "player3" then 
				AddItem(AnchorDropDown, "Blizzard", "Blizzard")
			end
			if v == "player" or v == "party" then 
				if PartyAnchor5 then AddItem(AnchorDropDown, "Bambi's UI", "BambiUI") end
			end
			if v == "arena" then 
				if Gladius then AddItem(AnchorDropDown, "Gladius", "Gladius") end
			end
			if v ~= "player3" then 
				if IsAddOnLoaded("Gladdy") then AddItem(AnchorDropDown, "Gladdy", "Gladdy") end
				if _G[anchors["Perl"][unitId]] or (type(anchors["Perl"][unitId])=="table" and anchors["Perl"][unitId]) then AddItem(AnchorDropDown, "Perl", "Perl") end
				if _G[anchors["XPerl"][unitId]] or (type(anchors["XPerl"][unitId])=="table" and anchors["XPerl"][unitId]) then AddItem(AnchorDropDown, "XPerl", "XPerl") end
				if _G[anchors["LUI"][unitId]] or (type(anchors["LUI"][unitId])=="table" and anchors["LUI"][unitId]) then AddItem(AnchorDropDown, "LUI", "LUI") end
				if _G[anchors["SUF"][unitId]] or (type(anchors["SUF"][unitId])=="table" and anchors["SUF"][unitId]) then AddItem(AnchorDropDown, "SUF", "SUF") end
				if _G[anchors["SyncFrames"][unitId]] or (type(anchors["SyncFrames"][unitId])=="table" and anchors["SyncFrames"][unitId]) then AddItem(AnchorDropDown, "SyncFrames", "SyncFrames") end
			end
		end)
		UIDropDownMenu_SetSelectedValue(AnchorDropDown, frame.anchor)
		if AnchorDropDown2 then
			UIDropDownMenu_Initialize(AnchorDropDown2, function() -- called on refresh and also every time the drop down menu is opened
				AddItem(AnchorDropDown2, "Blizzard", "Blizzard")
				if _G[anchors["Perl"][unitId]] or (type(anchors["Perl"][unitId])=="table" and anchors["Perl"][unitId]) then AddItem(AnchorDropDown2, "Perl", "Perl") end
				if _G[anchors["XPerl"][unitId]] or (type(anchors["XPerl"][unitId])=="table" and anchors["XPerl"][unitId]) then AddItem(AnchorDropDown2, "XPerl", "XPerl") end
				if _G[anchors["LUI"][unitId]] or (type(anchors["LUI"][unitId])=="table" and anchors["LUI"][unitId]) then AddItem(AnchorDropDown2, "LUI", "LUI") end
				if _G[anchors["SUF"][unitId]] or (type(anchors["SUF"][unitId])=="table" and anchors["SUF"][unitId]) then AddItem(AnchorDropDown2, "SUF", "SUF") end
			end)
			UIDropDownMenu_SetSelectedValue(AnchorDropDown2, LoseControlDB.frames.player2.anchor)
		end
	end

	InterfaceOptions_AddCategory(OptionsPanelFrame)
end

-------------------------------------------------------------------------------
SLASH_LoseControl1 = "/lc"
SLASH_LoseControl2 = "/losecontrol"

local SlashCmd = {}
function SlashCmd:help()
	print("|cff00ccffLoseControl|r", ": slash commands")
	print("    reset [<unit>]")
	print("    lock")
	print("    unlock")
	print("    enable <unit>")
	print("    disable <unit>")
end
function SlashCmd:debug(value)
	if value == "on" then
		debug = true
		print(addonName, "debugging enabled.")
	elseif value == "off" then
		debug = false
		print(addonName, "debugging disabled.")
	end
end
function SlashCmd:reset(unitId)
	if unitId == nil or unitId == "" or unitId == "all" then
		OptionsPanel.default()
	elseif unitId == "party" then
		for _, v in ipairs({"party1", "party2", "party3", "party4"}) do
			LoseControlDB.frames[v] = CopyTable(DBdefaults.frames[v])
			LCframes[v]:PLAYER_ENTERING_WORLD()
			print(L["LoseControl reset."].." "..v)
		end
	elseif unitId == "arena" then
		for _, v in ipairs({"arena1", "arena2", "arena3", "arena4", "arena5"}) do
			LoseControlDB.frames[v] = CopyTable(DBdefaults.frames[v])
			LCframes[v]:PLAYER_ENTERING_WORLD()
			print(L["LoseControl reset."].." "..v)
		end
	elseif LoseControlDB.frames[unitId] and unitId ~= "player2" then
		LoseControlDB.frames[unitId] = CopyTable(DBdefaults.frames[unitId])
		LCframes[unitId]:PLAYER_ENTERING_WORLD()
		if (unitId == "player") then
			LoseControlDB.frames.player2 = CopyTable(DBdefaults.frames.player2)
			LCframeplayer2:PLAYER_ENTERING_WORLD()
		end
		print(L["LoseControl reset."].." "..unitId)
	end
	Unlock:OnClick()
	OptionsPanel.refresh()
	for _, v in ipairs({ "player", "pet", "target", "targettarget", "focus", "focustarget", "party", "arena" }) do
		_G[O..v].refresh()
	end
end
function SlashCmd:lock()
	Unlock:SetChecked(false)
	Unlock:OnClick()
	print(addonName, "locked.")
end
function SlashCmd:unlock()
	Unlock:SetChecked(true)
	Unlock:OnClick()
	print(addonName, "unlocked.")
end
function SlashCmd:enable(unitId)
	if LCframes[unitId] and unitId ~= "player2" then
		LoseControlDB.frames[unitId].enabled = true
		local inInstance, instanceType = IsInInstance()
		local enabled = not (
			inInstance and instanceType == "pvp" and (
				( LoseControlDB.disablePartyInBG and strfind(unitId, "party") ) or
				( LoseControlDB.disableArenaInBG and strfind(unitId, "arena") )
			)
		) and not (
			IsInRaid() and LoseControlDB.disablePartyInRaid and strfind(unitId, "party") and not (inInstance and (instanceType=="arena" or instanceType=="pvp" or instanceType=="party"))
		)
		LCframes[unitId]:RegisterUnitEvents(enabled)
		if enabled and not LCframes[unitId].unlockMode then
			LCframes[unitId]:UNIT_AURA(unitId, updatedAuras, 0)
		end
		if (unitId == "player") then
			LoseControlDB.frames.player2.enabled = LoseControlDB.duplicatePlayerPortrait
			LCframeplayer2:RegisterUnitEvents(LoseControlDB.duplicatePlayerPortrait)
			if LCframeplayer2.frame.enabled and not LCframeplayer2.unlockMode then
				LCframeplayer2:UNIT_AURA(unitId, updatedAuras, 0)
			end
		end
		print(addonName, unitId, "frame enabled.")
	end
end
function SlashCmd:disable(unitId)
	if LCframes[unitId] and unitId ~= "player2" then
		LoseControlDB.frames[unitId].enabled = false
		LCframes[unitId].maxExpirationTime = 0
		LCframes[unitId]:RegisterUnitEvents(false)
		if (unitId == "player") then
			LoseControlDB.frames.player2.enabled = false
			LCframeplayer2.maxExpirationTime = 0
			LCframeplayer2:RegisterUnitEvents(false)
		end
		print(addonName, unitId, "frame disabled.")
	end
end


SlashCmdList[addonName] = function(cmd)
	local args = {}
	for word in cmd:lower():gmatch("%S+") do
		tinsert(args, word)
	end
	if SlashCmd[args[1]] then
		SlashCmd[args[1]](unpack(args))
	else
		print("|cff00ccffLoseControl|r", ": Type \"/lc help\" for more options.")
		InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
		InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
	end
end
