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

Vehicle = {tribe = 0}
Vehicle.__index = Vehicle

function Vehicle:new(o, tribe, maxHealth, vehicleThing)
	local o = o or {}
	setmetatable(o, Vehicle)

	o.tribe = tribe
	o.maxHealth = maxHealth
	o.currentHealth = maxHealth
	o.vehicleThing = vehicleThing

	return o
end

function Vehicle:handleVehicle()
	if (self.currentHealth <= 0) then
		if (self.vehicleThing ~= nil) then
			self.vehicleThing.u.Vehicle.Life = -1
			self.vehicleThing = nil
		end
		
	end

	if (everyPow(12, 1)) then
		if (self.currentHealth <= self.maxHealth) then
			self.currentHealth = self.currentHealth + 32
		end
	end
end

function Vehicle:damageVehicle(dmg)
	self.currentHealth = self.currentHealth - dmg
end

function Vehicle:getVehicleByPosition(D2Pos)
	if (self.vehicleThing ~= nil) then
		local c2d = Coord2D.new()
		coord3D_to_coord2D(self.vehicleThing.Pos.D3, c2d)

		if (get_world_dist_xz(D2Pos, c2d) < 56) then
			return self
		end
	end

	return nil
end