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

local ReincPos = {
  MAP_XZ_2_WORLD_XYZ(198, 230), -- Team 1
  MAP_XZ_2_WORLD_XYZ(146, 236), -- Team 1
  MAP_XZ_2_WORLD_XYZ(16, 210), -- Team 1

  MAP_XZ_2_WORLD_XYZ(30, 26), -- Team 2
  MAP_XZ_2_WORLD_XYZ(108, 20), -- Team 2
  MAP_XZ_2_WORLD_XYZ(212, 44) -- Team 2
}

local teamOne = {}
local teamTwo = {}

-- Setting up both teams
for i,k in ipairs(ReincPos) do
  local me = world_coord3d_to_map_ptr(k)
  me.MapWhoList:processList(function(t)
    if (t.Type == T_PERSON) then
      if (t.Model == M_PERSON_MEDICINE_MAN) then  
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