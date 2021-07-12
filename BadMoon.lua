import(Module_Commands)
import(Module_Control)
import(Module_DataTypes)
import(Module_Defines)
import(Module_Draw)
import(Module_Game)
import(Module_GameStates)
import(Module_Globals)
import(Module_Helpers)
import(Module_Level)
import(Module_Map)
import(Module_MapWho)
import(Module_Objects)
import(Module_Person)
import(Module_Players)
import(Module_PopScript)
import(Module_System)
import(Module_Sound)
import(Module_Table)
import(Module_Math)
include("LibBuildings.lua")
include("LibSpellsRali.lua")

local ReincPos = {
  MAP_XZ_2_WORLD_XYZ(254, 66), -- Team 1
  MAP_XZ_2_WORLD_XYZ(30, 70), -- Team 1
  MAP_XZ_2_WORLD_XYZ(56, 78), -- Team 1
  MAP_XZ_2_WORLD_XYZ(78, 52), -- Team 1

  MAP_XZ_2_WORLD_XYZ(238, 174), -- Team 2
  MAP_XZ_2_WORLD_XYZ(36, 184), -- Team 2
  MAP_XZ_2_WORLD_XYZ(70, 200), -- Team 2
  MAP_XZ_2_WORLD_XYZ(78, 4)  -- Team 2
}

-- Don't mess with the code bellow, unless you know what you are doing :)

local teamOne = {}
local teamTwo = {}

sti = spells_type_info();
sti[M_SPELL_LIGHTNING_BOLT].OneOffMaximum = 1;
sti[M_SPELL_SWAMP].OneOffMaximum = 1;
sti[M_SPELL_HYPNOTISM].OneOffMaximum = 2;
sti[M_SPELL_INSECT_PLAGUE].OneOffMaximum = 2;
sti[M_SPELL_LAND_BRIDGE].OneOffMaximum = 2;
sti[M_SPELL_FLATTEN].OneOffMaximum = 1;
sti[M_SPELL_WHIRLWIND].OneOffMaximum = 1;
sti[M_SPELL_EROSION].OneOffMaximum = 1;

blueShaman = nil
redShaman = nil
yellowShaman = nil
greenShaman = nil
cyanShaman = nil
pinkShaman = nil
blackShaman = nil
orangeShaman = nil

_gsi = gsi();

-- Setting up both teams
for i,k in ipairs(ReincPos) do
  local me = world_coord3d_to_map_ptr(k)
  me.MapWhoList:processList(function(t)
    if (t.Type == T_PERSON) then
      if (t.Model == M_PERSON_MEDICINE_MAN) then  
        if (i == 1) then
          blueShaman = t
        end
        if (i == 2) then
          redShaman = t
        end
        if (i == 3) then
          yellowShaman = t
        end
        if (i == 4) then
          greenShaman = t
        end
        if (i == 5) then
          cyanShaman = t
        end
        if (i == 6) then
          pinkShaman = t
        end
        if (i == 7) then
          blackShaman = t
        end
        if (i == 8) then
          orangeShaman = t
        end

        if (i == 1 or i == 5) then
          EnableBuilding(t.Owner, M_BUILDING_SUPER_TRAIN)

          EnableSpell(t.Owner, M_SPELL_WHIRLWIND)
          DisableSpellCharging(t.Owner, M_SPELL_WHIRLWIND)
          EnableSpell(t.Owner, M_SPELL_SHIELD)
          DisableSpellCharging(t.Owner, M_SPELL_SHIELD)
          EnableSpell(t.Owner, M_SPELL_LIGHTNING_BOLT)
          DisableSpellCharging(t.Owner, M_SPELL_LIGHTNING_BOLT)
        elseif (i == 2 or i == 6) then
          EnableBuilding(t.Owner, M_BUILDING_WARRIOR_TRAIN)
          EnableBuilding(t.Owner, M_BUILDING_AIRSHIP_HUT_1)
          
          EnableSpell(t.Owner, M_SPELL_WHIRLWIND)
          DisableSpellCharging(t.Owner, M_SPELL_WHIRLWIND)
          EnableSpell(t.Owner, M_SPELL_LAND_BRIDGE)
          DisableSpellCharging(t.Owner, M_SPELL_LAND_BRIDGE)
          EnableSpell(t.Owner, M_SPELL_FLATTEN)
          DisableSpellCharging(t.Owner, M_SPELL_FLATTEN)
        elseif (i == 3 or i == 7) then
          EnableBuilding(t.Owner, M_BUILDING_TEMPLE)

          EnableSpell(t.Owner, M_SPELL_EROSION)
          DisableSpellCharging(t.Owner, M_SPELL_EROSION)
          EnableSpell(t.Owner, M_SPELL_HYPNOTISM)
          DisableSpellCharging(t.Owner, M_SPELL_HYPNOTISM)
          EnableSpell(t.Owner, M_SPELL_INSECT_PLAGUE)
          DisableSpellCharging(t.Owner, M_SPELL_INSECT_PLAGUE)
        elseif (i == 4 or i == 8) then
          EnableBuilding(t.Owner, M_BUILDING_SPY_TRAIN)
          EnableBuilding(t.Owner, M_BUILDING_BOAT_HUT_1)

          EnableSpell(t.Owner, M_SPELL_WHIRLWIND)
          DisableSpellCharging(t.Owner, M_SPELL_WHIRLWIND)
          EnableSpell(t.Owner, M_SPELL_INVISIBILITY)
          DisableSpellCharging(t.Owner, M_SPELL_INVISIBILITY)
          EnableSpell(t.Owner, M_SPELL_GHOST_ARMY)
          DisableSpellCharging(t.Owner, M_SPELL_GHOST_ARMY)
          EnableSpell(t.Owner, M_SPELL_SWAMP)
          DisableSpellCharging(t.Owner, M_SPELL_SWAMP)
        end


        if (i <= 4) then
          table.insert(teamOne, t.Owner)
        else
          table.insert(teamTwo, t.Owner)
        end
      end
    end
    return true
  end)
end

log_msg(TRIBE_NEUTRAL, "Magical shield and Invisibility can target allies in this level.")

-- Allying Team 1
for i, v in ipairs(teamOne) do
    for k, t in ipairs(teamOne) do
        set_players_allied(v, t)
    end
end

-- Allying Team 2
for i, v in ipairs(teamTwo) do
    for k, t in ipairs(teamTwo) do
        set_players_allied(v, t)
    end
end

function OnTurn()
  if (blueShaman ~= nil) then
    if (blueShaman.State == S_PERSON_DYING or blueShaman.State == S_PERSON_DROWNING or blueShaman.State == S_PERSON_ELECTROCUTED or blueShaman.State == S_PERSON_SWAMP_DROWNING) then
      local c2d = Coord2D.new()
      local c3d = Coord3D.new()

      map_xz_to_world_coord2d(212, 172, c2d)

      coord2D_to_coord3D(c2d, c3d)
      _gsi.Players[blueShaman.Owner].ReincarnSiteCoord = c3d
      blueShaman = nil
    end
  end
  if (redShaman ~= nil) then
    if (redShaman.State == S_PERSON_DYING or redShaman.State == S_PERSON_DROWNING or redShaman.State == S_PERSON_ELECTROCUTED or redShaman.State == S_PERSON_SWAMP_DROWNING) then
      local c2d = Coord2D.new()
      local c3d = Coord3D.new()

      map_xz_to_world_coord2d(40, 160, c2d)

      coord2D_to_coord3D(c2d, c3d)
      _gsi.Players[redShaman.Owner].ReincarnSiteCoord = c3d
      redShaman = nil
    end
  end
  
  if (yellowShaman ~= nil) then
    if (yellowShaman.State == S_PERSON_DYING or yellowShaman.State == S_PERSON_DROWNING or yellowShaman.State == S_PERSON_ELECTROCUTED or yellowShaman.State == S_PERSON_SWAMP_DROWNING) then
      local c2d = Coord2D.new()
      local c3d = Coord3D.new()

      map_xz_to_world_coord2d(70, 174, c2d)

      coord2D_to_coord3D(c2d, c3d)
      _gsi.Players[yellowShaman.Owner].ReincarnSiteCoord = c3d
      yellowShaman = nil
    end
  end
  
  if (greenShaman ~= nil) then
    if (greenShaman.State == S_PERSON_DYING or greenShaman.State == S_PERSON_DROWNING or greenShaman.State == S_PERSON_ELECTROCUTED or greenShaman.State == S_PERSON_SWAMP_DROWNING) then
      local c2d = Coord2D.new()
      local c3d = Coord3D.new()

      map_xz_to_world_coord2d(106, 232, c2d)

      coord2D_to_coord3D(c2d, c3d)
      _gsi.Players[greenShaman.Owner].ReincarnSiteCoord = c3d
      greenShaman = nil
    end
  end
  
  if (cyanShaman ~= nil) then
    if (cyanShaman.State == S_PERSON_DYING or cyanShaman.State == S_PERSON_DROWNING or cyanShaman.State == S_PERSON_ELECTROCUTED or cyanShaman.State == S_PERSON_SWAMP_DROWNING) then
      local c2d = Coord2D.new()
      local c3d = Coord3D.new()

      map_xz_to_world_coord2d(230, 92, c2d)

      coord2D_to_coord3D(c2d, c3d)
      _gsi.Players[cyanShaman.Owner].ReincarnSiteCoord = c3d
      cyanShaman = nil
    end
  end

  if (pinkShaman ~= nil) then
    if (pinkShaman.State == S_PERSON_DYING or pinkShaman.State == S_PERSON_DROWNING or pinkShaman.State == S_PERSON_ELECTROCUTED or pinkShaman.State == S_PERSON_SWAMP_DROWNING) then
      local c2d = Coord2D.new()
      local c3d = Coord3D.new()

      map_xz_to_world_coord2d(254, 102, c2d)

      coord2D_to_coord3D(c2d, c3d)
      _gsi.Players[pinkShaman.Owner].ReincarnSiteCoord = c3d
      pinkShaman = nil
    end
  end
  
  if (blackShaman ~= nil) then
    if (blackShaman.State == S_PERSON_DYING or blackShaman.State == S_PERSON_DROWNING or blackShaman.State == S_PERSON_ELECTROCUTED or blackShaman.State == S_PERSON_SWAMP_DROWNING) then
      local c2d = Coord2D.new()
      local c3d = Coord3D.new()

      map_xz_to_world_coord2d(48, 116, c2d)

      coord2D_to_coord3D(c2d, c3d)
      _gsi.Players[blackShaman.Owner].ReincarnSiteCoord = c3d
      blackShaman = nil
    end
  end
  
  if (orangeShaman ~= nil) then
    if (orangeShaman.State == S_PERSON_DYING or orangeShaman.State == S_PERSON_DROWNING or orangeShaman.State == S_PERSON_ELECTROCUTED or orangeShaman.State == S_PERSON_SWAMP_DROWNING) then
      local c2d = Coord2D.new()
      local c3d = Coord3D.new()

      map_xz_to_world_coord2d(92, 94, c2d)

      coord2D_to_coord3D(c2d, c3d)
      _gsi.Players[orangeShaman.Owner].ReincarnSiteCoord = c3d
      orangeShaman = nil
    end
  end
end

function OnTrigger(trigger)
	if (trigger.Pos.D2.Xpos == -3072 and trigger.Pos.D2.Zpos == 4096) then
    local cd2d = Coord2D.new()
    local cd3d = Coord3D.new()
    map_xz_to_world_coord2d(252, 16, cd2d)
    coord2D_to_coord3D(cd2d, cd3d)

    createThing(T_EFFECT, M_EFFECT_ANGEL_OF_DEATH, TRIBE_NEUTRAL, cd3d, false, false)
	end
  return 0
end