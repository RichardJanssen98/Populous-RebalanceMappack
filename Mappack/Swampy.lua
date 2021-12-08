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

Swampy = {tribe = 0}
Swampy.__index = Swampy

function Swampy:new(o, tribe, c3dLocation)
	local o = o or {}
	setmetatable(o, Swampy)

	o.tribe = tribe
	o.c3dLocation = c3dLocation
	o.initialized = 0
	o.myTiles = {}
	o.decorations = {}

	o.maxTime = 1440
	o.maxKills = 10
	
	o.currentTime = 0
	o.currentKills = 0

	--o.numTilesDisabled = 0

	return o
end

function Swampy:deleteMe()
	DeleteSwampFromList(self)
	for i, tile in pairs(self.myTiles) do
		if (tile ~= nil) then
			DestroyThing(tile)
		end
	end

	for i, deco in pairs(self.decorations) do
		DestroyThing(deco)
	end
end

function Swampy:handleSwampy()
	if (self.initialized == 0) then

		for i=1, 9 do
			placeLocation = Coord3D.new()
			placeLocation = self.c3dLocation

			--Place mist
			if (i == 2) then
				placeLocation.Zpos = placeLocation.Zpos - 512
			elseif (i == 3) then
				placeLocation.Xpos = placeLocation.Xpos + 512
			elseif (i == 4) then
				placeLocation.Zpos = placeLocation.Zpos + 512
			elseif (i == 5) then
				placeLocation.Zpos = placeLocation.Zpos + 512
			elseif (i == 6) then
				placeLocation.Xpos = placeLocation.Xpos - 512
			elseif (i == 7) then
				placeLocation.Xpos = placeLocation.Xpos - 512
			elseif (i == 8) then
				placeLocation.Zpos = placeLocation.Zpos - 512
			elseif (i == 9) then
				placeLocation.Zpos = placeLocation.Zpos - 512
			end

			SearchMapCells(CIRCULAR, 0, 0, 0, world_coord3d_to_map_idx(self.c3dLocation), function(me)
          if (is_map_elem_all_sea(me) > 0) then
							
					else
						ensure_point_on_ground(placeLocation)
						local swampTile = createThing(T_EFFECT, M_EFFECT_SWAMP_MIST, self.tribe, placeLocation, false, false)
						table.insert(self.myTiles, swampTile)
						local decorationMist = createThing(T_EFFECT, M_EFFECT_SWAMP_MIST, self.tribe, placeLocation, false, false)
						table.insert(self.decorations, decorationMist)

						--Place plants
						local plantLocation = Coord3D.new()
						plantLocation = self.c3dLocation

						local locationOffset = G_RANDOM(150) - G_RANDOM(150)
						if (i == 2) then
							plantLocation.Xpos = plantLocation.Xpos + locationOffset
							local plantDecoration = createThing(T_EFFECT, M_EFFECT_REEDY_GRASS, self.tribe, placeLocation, false, false)
							table.insert(self.decorations, plantDecoration)
							plantLocation.Xpos = plantLocation.Xpos - locationOffset
						elseif (i == 4) then
							plantLocation.Xpos = plantLocation.Xpos + locationOffset
							local plantDecoration = createThing(T_EFFECT, M_EFFECT_REEDY_GRASS, self.tribe, placeLocation, false, false)
							table.insert(self.decorations, plantDecoration)
							plantLocation.Xpos = plantLocation.Xpos - locationOffset
						elseif (i == 6) then
							plantLocation.Xpos = plantLocation.Xpos + locationOffset
							local plantDecoration = createThing(T_EFFECT, M_EFFECT_REEDY_GRASS, self.tribe, placeLocation, false, false)
							table.insert(self.decorations, plantDecoration)
							plantLocation.Xpos = plantLocation.Xpos - locationOffset
						elseif (i == 8) then
							plantLocation.Xpos = plantLocation.Xpos + locationOffset
							local plantDecoration = createThing(T_EFFECT, M_EFFECT_REEDY_GRASS, self.tribe, placeLocation, false, false)
							table.insert(self.decorations, plantDecoration)
							plantLocation.Xpos = plantLocation.Xpos - locationOffset
						end
					end
					return true
					end)
		end
		queue_sound_event(self.myTiles[1], SND_EVENT_SP_SWAMP, SEF_LOOPED)

		self.initialized = 1
	end

	if (everyPow(3, 1)) then
		for i, tile in pairs(self.myTiles) do
			if (tile ~= nil) then
				SearchMapCells(CIRCULAR, 0, 0, 0, world_coord3d_to_map_idx(tile.Pos.D3), function(me)
					me.MapWhoList:processList(function(p)
						if (p.Type == T_PERSON and is_thing_on_ground(p) == 1) then
							if (p.Model == M_PERSON_MEDICINE_MAN and p.Owner ~= tile.Owner) then
								SetShamanSwampDeath(p)
							end

							--self.myTiles[i] = nil

							--if (p.Flags2 & TF2_THING_IS_A_GHOST_PERSON == 0) then
							--	DestroyThing(tile)
							--end
							
							--self.numTilesDisabled = self.numTilesDisabled + 1
							p.u.Pers.u.Owned.LastDamagedBy = tile.Owner
							p.u.Pers.Life = p.u.Pers.Life - 350

							if (p.u.Pers.Life <= 0) then
								self.currentKills = self.currentKills + 1
							end
						end
					return true
					end)
				return true
				end)
			end
		end

		if (self.currentKills >= self.maxKills or self.currentTime >= self.maxTime) then
			DeleteSwampFromList(self)
			for i, tile in pairs(self.myTiles) do
				if (tile ~= nil) then
					DestroyThing(tile)
				end
			end

			for i, deco in pairs(self.decorations) do
				DestroyThing(deco)
			end
		end
	end

	self.currentTime = self.currentTime + 1
end