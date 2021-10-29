import(Module_Map)
import(Module_Defines)
import(Module_DataTypes)
import(Module_Table)
import(Module_Objects)
import(Module_Globals)
import(Module_Commands)
import(Module_Players)

local ReincPos = {
  MAP_XZ_2_WORLD_XYZ(200, 46),
  MAP_XZ_2_WORLD_XYZ(158, 208),
  MAP_XZ_2_WORLD_XYZ(226, 164),
  MAP_XZ_2_WORLD_XYZ(82, 196),
  MAP_XZ_2_WORLD_XYZ(106, 70),
  MAP_XZ_2_WORLD_XYZ(66, 128)
}

local teamOne = {}
local teamTwo = {}

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


for i, v in ipairs(teamOne) do
    for k, t in ipairs(teamOne) do
        set_players_allied(v, t)
    end
end

for i, v in ipairs(teamTwo) do
    for k, t in ipairs(teamTwo) do
        set_players_allied(v, t)
    end
end