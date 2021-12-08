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
include("UtilRefs.lua")

latestAngel = nil

function OnTurn()
	GIVE_MANA_TO_PLAYER(TRIBE_BLUE, 6969)
	GIVE_MANA_TO_PLAYER(TRIBE_RED, 6969)

	if (latestAngel ~= nil) then
		if (latestAngel.u.Pers ~= nil) then
			if (everyPow(4, 1)) then
				log_msg(TRIBE_BLUE, "Angel Life: "..latestAngel.u.Pers.Life)
			end
		end
	end
end

function OnCreateThing(t)
	if (t.Type == T_PERSON) then
		if (t.Model == M_PERSON_ANGEL) then
			latestAngel = t
		end
	end
end