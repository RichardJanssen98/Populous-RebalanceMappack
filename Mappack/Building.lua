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

Building = {tribe = 0}
Building.__index = Building

function Building:new(o, buildingThing, buildingLocation)
	local o = o or {}
	setmetatable(o, Building)

	o.thing = buildingThing
	o.location = buildingLocation

	o.hasBeenFinishedOnce = 0
	o.wasUnderConstruction = 0
	o.buildingType = 0

	o.wasIDismantlingBeforeDYING = 0

	return o
end

function Building:handleBuilding()
	if (everyPow(1, 1)) then
		if (self.thing ~= nil) then
			
			if (self.thing.u.Bldg ~= nil) then
				if (self.thing.u.Bldg.Flags & BF_DISMANTLE_MODE >= 1) then
					self.wasIDismantlingBeforeDYING = 1
				else
					self.wasIDismantlingBeforeDYING = 0
				end
			end

			if (self.hasBeenFinishedOnce == 0 and self.thing.State == S_BUILDING_STAND) then
				if (CheckIfSproggedThisLocation(self.location) == 1 and self.buildingType == 0 and self.thing.Model == 1) then
					self.thing.u.Bldg.SproggingCount = 0
				elseif (self.buildingType == 0) then
					AddSproggedToList(self.location)
				end
			end

			if (self.buildingType ~= self.thing.Model and self.thing.State == S_BUILDING_STAND) then
				self.hasBeenFinishedOnce = 1
				self.buildingType = self.thing.Model
			end	

			if (self.hasBeenFinishedOnce == 1 and self.thing.State == S_BUILDING_STAND and self.wasUnderConstruction == 1) then
				self.wasUnderConstruction = 0
				self.thing.u.Bldg.SproggingCount = 0
			end

			if (self.thing.u.Bldg == nil and self.wasIDismantlingBeforeDYING == 0) then
				DeleteBuildingFromList(self, 1)
			end

			if (self.thing.u.Bldg == nil and self.wasIDismantlingBeforeDYING == 1) then
				DeleteBuildingFromList(self, 0)
			end

			if (self.thing.State == S_BUILDING_UNDER_CONSTRUCTION and self.hasBeenFinishedOnce == 1) then
				if (self.buildingType ~= self.thing.Model) then
					self.hasBeenFinishedOnce = 0
				end
				self.wasUnderConstruction = 1
			end
		end
	end
end

function Building:buildingBecomingDamaged(smoke)
	local found = 0

	if (get_world_dist_xyz(smoke.Pos.D3, self.location) <= 550) then
		if (self.thing.u.Bldg ~= nil and self.hasBeenFinishedOnce == 1) then
			self.hasBeenFinishedOnce = 0
			found = 1
		end
	end

	return found
end