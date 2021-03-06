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
include("UtilRefs.lua")

local ReincPos = {
  MAP_XZ_2_WORLD_XYZ(174, 52), -- Team 1
  MAP_XZ_2_WORLD_XYZ(106, 56), -- Team 1
  MAP_XZ_2_WORLD_XYZ(138, 152), -- Team 1

  MAP_XZ_2_WORLD_XYZ(108, 174), -- Team 2
  MAP_XZ_2_WORLD_XYZ(168, 170), -- Team 2
  MAP_XZ_2_WORLD_XYZ(136, 82) -- Team 2
}

local teamOne = {}
local teamTwo = {}

blueShaman = nil
redShaman = nil
yellowShaman = nil
greenShaman = nil
cyanShaman = nil
pinkShaman = nil

_gsi = gsi();
hillRemoved = 0

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

        if (i == 3 or i == 6) then
          EnableSpell(t.Owner, M_SPELL_INVISIBILITY)
          DisableSpellCharging(t.Owner, M_SPELL_INVISIBILITY)

          EnableSpell(t.Owner, M_SPELL_FIRESTORM)
          DisableSpellCharging(t.Owner, M_SPELL_FIRESTORM)

          EnableSpell(t.Owner, M_SPELL_EROSION)
          DisableSpellCharging(t.Owner, M_SPELL_EROSION)

          EnableSpell(t.Owner, M_SPELL_ANGEL_OF_DEATH)
          DisableSpellCharging(t.Owner, M_SPELL_ANGEL_OF_DEATH)

          EnableSpell(t.Owner, M_SPELL_EARTHQUAKE)
          DisableSpellCharging(t.Owner, M_SPELL_EARTHQUAKE)

          EnableSpell(t.Owner, M_SPELL_FLATTEN)
          DisableSpellCharging(t.Owner, M_SPELL_FLATTEN)
          
          EnableSpell(t.Owner, M_SPELL_VOLCANO)
          DisableSpellCharging(t.Owner, M_SPELL_VOLCANO)

          EnableSpell(t.Owner, M_SPELL_SHIELD)
          DisableSpellCharging(t.Owner, M_SPELL_SHIELD)
          
          EnableSpell(t.Owner, M_SPELL_BLOODLUST)
          DisableSpellCharging(t.Owner, M_SPELL_BLOODLUST)
        end


        if (i <= 3) then
          table.insert(teamOne, t.Owner)
        else
          table.insert(teamTwo, t.Owner)
        end
      end
    end
    return true
  end)
end

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
  if (hillRemoved == 0 and everyPow(12, 1)) then
    for i=0, 7 do
      _gsi.ThisLevelInfo.PlayerThings[i].SpellsAvailable = _gsi.ThisLevelInfo.PlayerThings[i].SpellsAvailable ~ (1 << M_SPELL_BLOODLUST)
    end
    
    _gsi.ThisLevelInfo.PlayerThings[yellowShaman.Owner].SpellsAvailable = _gsi.ThisLevelInfo.PlayerThings[yellowShaman.Owner].SpellsAvailable | (1 << M_SPELL_BLOODLUST)
    _gsi.ThisLevelInfo.PlayerThings[yellowShaman.Owner].SpellsNotCharging = _gsi.ThisLevelInfo.PlayerThings[yellowShaman.Owner].SpellsNotCharging ~ (1 << M_SPELL_BLOODLUST-1)

    _gsi.ThisLevelInfo.PlayerThings[pinkShaman.Owner].SpellsAvailable = _gsi.ThisLevelInfo.PlayerThings[pinkShaman.Owner].SpellsAvailable | (1 << M_SPELL_BLOODLUST)
    _gsi.ThisLevelInfo.PlayerThings[pinkShaman.Owner].SpellsNotCharging = _gsi.ThisLevelInfo.PlayerThings[pinkShaman.Owner].SpellsNotCharging ~ (1 << M_SPELL_BLOODLUST-1)

    hillRemoved = 1
  end

  if (yellowShaman ~= nil) then
    if (yellowShaman.State == S_PERSON_DYING or yellowShaman.State == S_PERSON_DROWNING or yellowShaman.State == S_PERSON_ELECTROCUTED or yellowShaman.State == S_PERSON_SWAMP_DROWNING) then
      local c2d = Coord2D.new()
      local c3d = Coord3D.new()

      map_xz_to_world_coord2d(198, 252, c2d)

      coord2D_to_coord3D(c2d, c3d)
      _gsi.Players[yellowShaman.Owner].ReincarnSiteCoord = c3d
      yellowShaman = nil
    end
  end

  if (pinkShaman ~= nil) then
    if (pinkShaman.State == S_PERSON_DYING or pinkShaman.State == S_PERSON_DROWNING or pinkShaman.State == S_PERSON_ELECTROCUTED or pinkShaman.State == S_PERSON_SWAMP_DROWNING) then
      local c2d = Coord2D.new()
      local c3d = Coord3D.new()

      map_xz_to_world_coord2d(58, 240, c2d)

      coord2D_to_coord3D(c2d, c3d)
      _gsi.Players[pinkShaman.Owner].ReincarnSiteCoord = c3d
      pinkShaman = nil
    end
  end

  if (everyPow(36, 1)) then
		if (_gsi.Counts.GameTurn > 240) then

			for i = 0, 7 do
				local tribe = _gsi.Players[i].NumPeople

				if (tribe == 1) then
					local shaman = getShaman(i)
					if (shaman ~= nil) then

						if (shaman.State == S_PERSON_SHAMAN_IN_PRISON) then

							local mp = MapPosXZ.new()
							mp.Pos = world_coord2d_to_map_idx(shaman.Pos.D2)

              SearchMapCells(CIRCULAR, 0, 0, 0, world_coord3d_to_map_idx(shaman.Pos.D3), function(me)
                me.MapWhoList:processList(function(p)
                  if (p.Type == T_BUILDING) then
                    if (p.Model == M_BUILDING_PRISON) then
                      p.u.Bldg.Damaged = 696969
                      shaman.State = S_PERSON_DYING
                    end
                  end
                return true
                end)
              return true
              end)
						end
					end
				end
			end
		end
	end
end