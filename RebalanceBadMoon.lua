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
include("Vehicle.lua")
include("Swampy.lua")

sti = spells_type_info();
_constants = constants();
initializedShamanHealth = 0

sti[M_SPELL_INVISIBILITY].Cost = 75000;
InvisNumPeopleAffected = 3;

aliveShamans = {}
deadShamans = {}
deadShamansIntArray = {[0]= 0, 0, 0, 0, 0, 0, 0, 0}

swampyTable = {}

vehiclesTable = {}
vehicleHealth = 1000

lightningBolts = {}
vehicleDamageFirewarriorBlast = 50 --Firewarriors seem to be doing double damage? Perhaps per fireball
vehicleDamageBlast = 100
vehicleDamageLightning = 1050
vehicleDamageTornado = 25
vehicleDamageFirestormExplosions = 100
vehicleDamageVolcanoBigRockExplosions = 250
vehicleDamageVolcanoSmallRockExplosions = 150

shamFindBools = {[0]= 0, 0, 0, 0, 0, 0, 0, 0}
shamAngelDeathBools = {[0]= 0, 0, 0, 0, 0, 0, 0, 0}
shamSwarmHitBools = {[0]= 0, 0, 0, 0, 0, 0, 0, 0}
shamSwampDeathBools = {[0]= 0, 0, 0, 0, 0, 0, 0, 0}

_constants.InvisNumPeopleAffected = 1;
_constants.ShieldNumPeopleAffected = 1;
_constants.BloodlustNumPeopleAffected = 1;
_constants.SwampNumPeopleAffected = 10;

BloodlustNumPeopleAffected = 3;

sti[M_SPELL_SHIELD].Cost = 75000;
ShieldNumPeopleAffected = 3;

sti[M_SPELL_GHOST_ARMY].Cost = 20000;
sti[M_SPELL_EARTHQUAKE].Cost = 210000;
sti[M_SPELL_EROSION].Cost = 175000;
sti[M_SPELL_FIRESTORM].OneOffMaximum = 1;

sti[M_SPELL_ARMAGEDDON].CursorSpriteNum = sti[M_SPELL_HILL].CursorSpriteNum;
sti[M_SPELL_ARMAGEDDON].DiscoveryDrawIdx = sti[M_SPELL_HILL].DiscoveryDrawIdx;
sti[M_SPELL_ARMAGEDDON].AvailableSpriteIdx = sti[M_SPELL_HILL].AvailableSpriteIdx;
sti[M_SPELL_ARMAGEDDON].NotAvailableSpriteIdx = sti[M_SPELL_HILL].NotAvailableSpriteIdx;
sti[M_SPELL_ARMAGEDDON].ClickedSpriteIdx = sti[M_SPELL_HILL].ClickedSpriteIdx;
sti[M_SPELL_ARMAGEDDON].ToolTipStrIdx = sti[M_SPELL_HILL].ToolTipStrIdx;
sti[M_SPELL_ARMAGEDDON].ToolTipStrIdxLSME = sti[M_SPELL_HILL].ToolTipStrIdxLSME;
sti[M_SPELL_ARMAGEDDON].GUIButtonId = sti[M_SPELL_ARMAGEDDON].GUIButtonId;

_gsi = gsi();
--_gsi.CurrLevelFlags = FlagSet(_gsi.CurrLevelFlags, GS_GUEST_SPELLS_CHARGE);

-- this might not work, in which case you might wanna check
--  for T_SPELL && M_SPELL_ARMAGEDDON inside OnCreateThing
sti[M_SPELL_ARMAGEDDON].EffectModels[3] = M_SPELL_HILL; 
_gsi.CurrLevelFlags = _gsi.CurrLevelFlags ~ LEVEL_FLAGS_NO_GUEST
_gsi.CurrLevelFlags = _gsi.CurrLevelFlags | GS_GUEST_SPELLS_CHARGE

function OnTurn()
  if (initializedShamanHealth == 0) then
    for i=0, 7 do
      --_gsi.ThisLevelInfo.PlayerThings[i].SpellsAvailable = _gsi.ThisLevelInfo.PlayerThings[i].SpellsAvailable | (1 << M_SPELL_ARMAGEDDON)
      --_gsi.ThisLevelInfo.PlayerThings[i].SpellsNotCharging = _gsi.ThisLevelInfo.PlayerThings[i].SpellsNotCharging ~ (1 << M_SPELL_ARMAGEDDON-1)
      
      local shaman = getShaman(i)

      if (shaman ~= nil) then
        HandleMaxShamanHealth(shaman)
      end
    end
    initializedShamanHealth = 1
    sti[M_SPELL_ARMAGEDDON].OneOffMaximum = 3
    sti[M_SPELL_ARMAGEDDON].Cost = 200000;
    sti[M_SPELL_ARMAGEDDON].OptimalChargeSecs = 240
    sti[M_SPELL_ARMAGEDDON].WorldCoordRange = 4096

    --Put any vehicles into the vehicles list just in case the map has some pre made vehicles
    ProcessGlobalTypeList(T_VEHICLE, function(t)
      if (t.Type == T_VEHICLE) then
        local maxHealth = math.floor(vehicleHealth * 0.75) + G_RANDOM(math.floor(vehicleHealth * 0.25))
        local vehicle = Vehicle:new(nil, t.Owner, maxHealth, t) --Simulate random unit health. The unit gets 75% of its max health for free and then the last 25% is a random range.
        table.insert(vehiclesTable, vehicle)
      end
    return true
    end)
  end

  if (everyPow(36, 1)) then
    for i, sham in pairs(aliveShamans) do
      if (sham ~= nil) then
        shamFindBools[sham.Owner] = 1
      end
    end

    for i=0, 7 do
      if (shamFindBools[i] == 0) then
        local sham  = getShaman(i)
        if (sham ~= nil) then
          table.insert(aliveShamans, sham)
        end
      end
    end

    for i, sham in pairs(aliveShamans) do
      if (sham ~= nil) then
        if (sham.State == S_PERSON_AOD2_VICTIM) then
          shamAngelDeathBools[sham.Owner] = 1
        end
      end

      shamFindBools = {[0]= 0, 0, 0, 0, 0, 0, 0, 0}
    end
  end

  if (everyPow(1, 1)) then
    for i, sham in pairs(aliveShamans) do
      if ((sham.Owner == TRIBE_BLUE and shamAngelDeathBools[0] == 1) or (sham.Owner == TRIBE_RED and shamAngelDeathBools[1] == 1) or (sham.Owner == TRIBE_YELLOW and shamAngelDeathBools[2] == 1) or (sham.Owner == TRIBE_GREEN and shamAngelDeathBools[3] == 1) or (sham.Owner == TRIBE_CYAN and shamAngelDeathBools[4] == 1) or (sham.Owner == TRIBE_PINK and shamAngelDeathBools[5] == 1) or (sham.Owner == TRIBE_BLACK and shamAngelDeathBools[6] == 1) or (sham.Owner == TRIBE_ORANGE and shamAngelDeathBools[7] == 1)) then
        sham.u.Pers.u.Owned.LastDamagedBy = TRIBE_NEUTRAL
      end

      if (is_person_in_airship(sham) == 1 or is_person_in_boat(sham) == 1) then
        
        SearchMapCells(CIRCULAR, 0, 0, 0, world_coord3d_to_map_idx(sham.Pos.D3), function(me)
					me.MapWhoList:processList(function(p)
						if (p.Type == T_EFFECT) then
              if ((p.Model == M_EFFECT_INSECT_PLAGUE or p.Model == M_EFFECT_FLY_THINGUMMY) and p.Owner ~= sham.Owner) then  
                shamSwarmHitBools[sham.Owner] = 1             
              end
						end
					return true
					end)
				return true
				end)
      end

      if (sham.State == S_PERSON_DYING or sham.State == S_PERSON_DROWNING or sham.State == S_PERSON_ELECTROCUTED or sham.State == S_PERSON_SWAMP_DROWNING) then
        table.remove(aliveShamans, i)
      end
    end

    for i=0, 7 do
      if (getShaman(i) == nil and shamAngelDeathBools[i] == 1) then
        shamAngelDeathBools[i] = 0
      end
    end
  end

  if (everyPow(1, 1)) then
    for i=0, 7 do
      local sham = getShaman(i)
      if(sham ~= nil) then
        if (is_person_in_airship(sham) == 0 and is_person_in_boat(sham) == 0 and is_thing_on_ground(sham) == 1 and (sham.State == S_PERSON_GOTO_BASE_AND_WAIT or sham.State == S_PERSON_UNDER_COMMAND or sham.State == S_PERSON_WAIT_AT_POINT) and shamSwarmHitBools[i] == 1) then
          set_person_new_state(sham, S_PERSON_RUN_AWAY)
          shamSwarmHitBools[i] = 0
        elseif ((is_person_in_airship(sham) == 1 or is_person_in_boat(sham) == 1) and shamSwarmHitBools[i] == 1) then
          jumpOutCommand = Commands.new()
          jumpOutCommand.CommandType = CMD_GET_OUT_OF_VEHICLE
          add_persons_command(sham, jumpOutCommand, 0)
          sham.Flags2 = sham.Flags2 ~ TF2_IN_AIRSHIP
        end
      else
        shamSwarmHitBools[i] = 0
      end
    end
  end

  for k, sham in pairs(deadShamans) do
    if (sham ~= nil) then
      if (sham.Model == M_INTERNAL_SOUL_CONVERT_2) then
        if (sham.u.SoulConvert.CurrModel == M_PERSON_MEDICINE_MAN) then
          if (sham.SubState == SS_SC2_SOUL_IN_LIMBO) then
            sham.u.SoulConvert.Count = 57
            deadShamansIntArray[sham.Owner] = deadShamansIntArray[sham.Owner] + 1

            if (deadShamansIntArray[sham.Owner] == 3) then
              deadShamansIntArray[sham.Owner] = 0
              table.remove(deadShamans, k)
            end
            
          end
        end
      end
    end
  end

  if (everyPow(1, 1)) then
    for i, veh in pairs(vehiclesTable) do
      veh:handleVehicle()
    end

    for i, swmp in pairs(swampyTable) do
      swmp:handleSwampy()
    end
  end
end

function SetShamanSwampDeath(sham)
  shamSwampDeathBools[sham.Owner] = 1
end

function DeleteVehicleFromList(t)
  for i, veh in pairs(vehiclesTable) do
    if (veh == t) then
      table.remove(vehiclesTable, i)
    end
  end
end

function FindVehicle(t) 
  for i, veh in pairs(vehiclesTable) do
    if (veh ~= nil) then
      local result = veh:getVehicleByPosition(t.Pos.D2)
      
      if (result ~= nil) then
        return result
      end
    end
  end
  return nil
end

function DamageVehicle(t, dmg)
  local targetVehicle = nil
  local foundVehicle = 0

  if (t.Type == T_SHOT) then
    SearchMapCells(CIRCULAR, 0, 0, 1, world_coord3d_to_map_idx(t.u.Shot.TargetCoord), function(me)
      me.MapWhoList:processList(function(p)
          if (p.Type == T_VEHICLE and p.Owner ~= t.Owner and foundVehicle == 0) then
            targetVehicle = FindVehicle(p)
            
            if (targetVehicle ~= nil) then
              foundVehicle = 1
              targetVehicle:damageVehicle(dmg)
              return false
            end
          end
      return true
      end)
    return true
    end)
  else
    SearchMapCells(CIRCULAR, 0, 0, 1, world_coord3d_to_map_idx(t.Pos.D3), function(me)
      me.MapWhoList:processList(function(p)
          if (p.Type == T_VEHICLE and foundVehicle == 0) then
            targetVehicle = FindVehicle(p)

            if (targetVehicle ~= nil) then
              c2d = Coord2D.new()
              coord3D_to_coord2D(p.Pos.D3, c2d)
              local dist = get_world_dist_xz(t.Pos.D2, c2d)

              foundVehicle = 1

              if (dist > 351) then
                dmg = math.floor(dmg * 0.25)
              end

              --Special Tornado checking
              if (t.Model == M_EFFECT_WW_DUST and (p.Model == M_VEHICLE_AIRSHIP_1 or p.Model == M_VEHICLE_AIRSHIP_2)) then
                local randomExplodeChance = G_RANDOM(101)
                if (randomExplodeChance <= 3) then
                  dmg = vehicleHealth + 1
                end

                --Don't damage if whirlwind is nearby only if it's ON the vehicle
                if (dist > 513) then
                  dmg = 0
                end
              end

              targetVehicle:damageVehicle(dmg)
              return false
            end
          end
      return true
      end)
    return true
    end)
  end
end

function OnCreateThing(t)
  if (t.Type == T_VEHICLE) then
    local maxHealth = math.floor(vehicleHealth * 0.75) + G_RANDOM(math.floor(vehicleHealth * 0.25))
    local vehicle = Vehicle:new(nil, t.Owner, maxHealth, t) --Simulate random unit health. The unit gets 75% of its max health for free and then the last 25% is a random range.
    table.insert(vehiclesTable, vehicle)
  end

  if (t.Type == T_SPELL) then
    local shamanOwner = getShaman(t.Owner)
    if (is_person_in_airship(shamanOwner) == 1) then
      t.Model = M_SPELL_NONE
    end
    if (is_person_in_boat(shamanOwner) == 1 and shamanOwner.Pos.D3.Ypos >= 49) then
      t.Model = M_SPELL_NONE
    end

    if (t.Model == M_SPELL_LIGHTNING_BOLT) then
      local c2d = Coord2D.new()
      coord3D_to_coord2D(t.u.Spell.TargetCoord, c2d)
      table.insert(lightningBolts, c2d)
    end
  end

  if (t.Type == T_EFFECT) then
    if (t.Model == M_EFFECT_GHOST_ARMY) then
      HandleGhostArmy(t)
    elseif (t.Model == M_EFFECT_INVISIBILITY or t.Model == M_EFFECT_SHIELD or t.Model == M_EFFECT_BLOODLUST) then
      HandleBuffingSpells(t)
    elseif (t.Model == M_EFFECT_SWAMP) then
      HandleSwamp(t)
    elseif (t.Model == M_EFFECT_FLATTEN) then
      HandleFlatten(t)
    end

    if (t.Model == M_EFFECT_SPELL_BLAST) then
      DamageVehicle(t, vehicleDamageBlast)
    end

    if (t.Model == M_EFFECT_SIMPLE_BLAST) then
      if (tableLength(lightningBolts) > 0) then
        for i, light in pairs(lightningBolts) do
          if (get_world_dist_xz(light, t.Pos.D2) <= 512) then
            DamageVehicle(t, vehicleDamageLightning)
            break
          end
        end
        lightningBolts = {}
      end
    end
      
    if (t.Model == M_EFFECT_SPHERE_EXPLODE_AND_FIRE) then
      DamageVehicle(t, vehicleDamageFirestormExplosions)
    end
    if (t.Model == M_EFFECT_WW_DUST) then
      DamageVehicle(t, vehicleDamageTornado)
    end
    if (t.Model == M_EFFECT_EXPLOSION_3) then
      DamageVehicle(t, vehicleDamageVolcanoBigRockExplosions)
    end
    if (t.Model == M_EFFECT_ROCK_EXPLOSION) then
      DamageVehicle(t, vehicleDamageVolcanoSmallRockExplosions)
    end
  end

  if (t.Type == T_SHOT) then
    if (t.Model == M_SHOT_SUPER_WARRIOR) then
      local fwDmg = vehicleDamageFirewarriorBlast

      SearchMapCells(CIRCULAR, 0, 0, 0, world_coord3d_to_map_idx(t.Pos.D3), function(me)
        me.MapWhoList:processList(function(p)
          if (p.Type == T_BUILDING) then
            if (p.Model == M_BUILDING_DRUM_TOWER) then
              fwDmg = fwDmg * 2
              return false
            end
          end

        return true
        end)
      return true
      end)

      DamageVehicle(t, fwDmg)
    end
  end
  
  if (t.Type == T_PERSON) then
    if (t.Model == M_PERSON_MEDICINE_MAN) then
      HandleMaxShamanHealth(t)
    end
  end

  if (t.Type == T_INTERNAL) then
    if (t.Model == M_INTERNAL_SOUL_CONVERT_2) then
      if (t.u.SoulConvert.CurrModel == M_PERSON_MEDICINE_MAN) then
        for i=0, 7 do
          if (t.Owner == i and shamSwampDeathBools[i] == 1) then
            table.insert(deadShamans, t)
            shamSwampDeathBools[i] = 0
          end
        end
      end
    end
  end
end

function HandleMaxShamanHealth(t)
  if (t.u.Pers.MaxLife < 1600) then
    t.u.Pers.MaxLife = 1600
    t.u.Pers.Life = 1600
  end
end

function HandleSwamp(t)
  local swampLoc = Coord3D.new()
  swampLoc = t.Pos.D3
  centre_coord3d_on_block(swampLoc)
  local swampy = Swampy:new(nil, t.Owner, swampLoc)
  table.insert(swampyTable, swampy)
  
  DestroyThing(t)
end

function DeleteSwampFromList(t)
  for i, swmp in pairs(swampyTable) do
    if (swmp == t) then
      table.remove(swampyTable, i)
    end
  end
end

function HandleFlatten(t)
  SearchMapCells(CIRCULAR, 0, 0, 2, world_coord3d_to_map_idx(t.Pos.D3), function(me)
    if (me.Flags & (1<<26) >= 1) then
      me.Flags = me.Flags ~ (1<<26)
      me.Cliff = 40
    end
  return true
  end)
end

function HandleGhostArmy(t)
  local createdGhosts = 0

  SearchMapCells(CIRCULAR, 0, 0, 1, world_coord3d_to_map_idx(t.Pos.D3), function(me)
  me.MapWhoList:processList(function(p)
    if (p.Type == T_PERSON and createdGhosts == 0) then
      if (p.Model == M_PERSON_MEDICINE_MAN and p.Owner == t.Owner) then
        createThing(T_PERSON, M_PERSON_MEDICINE_MAN, t.Owner, t.Pos.D3, false, true)
        createdGhosts = 1
        return false
      elseif (p.Model == M_PERSON_WARRIOR and p.Owner == t.Owner) then
        createThing(T_PERSON, M_PERSON_WARRIOR, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_WARRIOR, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_WARRIOR, t.Owner, t.Pos.D3, false, true)
        createdGhosts = 1
        return false
      elseif (p.Model == M_PERSON_SUPER_WARRIOR and p.Owner == t.Owner) then
        createThing(T_PERSON, M_PERSON_SUPER_WARRIOR, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_SUPER_WARRIOR, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_SUPER_WARRIOR, t.Owner, t.Pos.D3, false, true)
        createdGhosts = 1
        return false
      elseif (p.Model == M_PERSON_RELIGIOUS and p.Owner == t.Owner) then
        createThing(T_PERSON, M_PERSON_RELIGIOUS, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_RELIGIOUS, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_RELIGIOUS, t.Owner, t.Pos.D3, false, true)
        createdGhosts = 1
        return false
      elseif (p.Model == M_PERSON_SPY and p.Owner == t.Owner) then
        createThing(T_PERSON, M_PERSON_SPY, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_SPY, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_SPY, t.Owner, t.Pos.D3, false, true)
        createdGhosts = 1
        return false
      elseif (p.Model == M_PERSON_BRAVE and p.Owner == t.Owner) then
        createThing(T_PERSON, M_PERSON_BRAVE, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_BRAVE, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_BRAVE, t.Owner, t.Pos.D3, false, true)
        createdGhosts = 1
        return false
      end
    end
    return true
    end)
    return true
    end)

    if (createdGhosts == 0) then
        createThing(T_PERSON, M_PERSON_BRAVE, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_BRAVE, t.Owner, t.Pos.D3, false, true)
        createThing(T_PERSON, M_PERSON_BRAVE, t.Owner, t.Pos.D3, false, true)
        createdGhosts = 1
    end
    
    c3d = Coord3D.new()

    for i = 0, 19 do
      c3d.Xpos = world_coord_start_of_cell(t.Pos.D3.Xpos) + G_RANDOM(512);
      c3d.Zpos = world_coord_start_of_cell(t.Pos.D3.Zpos) + G_RANDOM(512);
      createThing(T_EFFECT, M_EFFECT_SMOKE, TRIBE_NEUTRAL, c3d, false, false)
    end

    DestroyThing(t)

    queue_sound_event(nil, SND_EVENT_SP_GHOST, SEF_FIXED_VARS)
end

function HandleBuffingSpells(t)
  if (t.Model == M_EFFECT_INVISIBILITY) then
    spellModel = M_SPELL_INVISIBILITY
  elseif (t.Model == M_EFFECT_SHIELD) then
    spellModel = M_SPELL_SHIELD
  elseif (t.Model == M_EFFECT_BLOODLUST) then
    spellModel = M_SPELL_BLOODLUST
  end

  local unitsFound = {}
  local unitsFoundWithBuffs = {}
  local unitsFoundWithSameBuffs = {}
  local unitsFoundWithoutBuffs = {}

  local unitsAffected = {}
  local maxUnits = 0;
  local unitsFoundCount = 0

  if (spellModel == M_SPELL_INVISIBILITY) then
    maxUnits = InvisNumPeopleAffected;
  elseif (spellModel == M_SPELL_SHIELD) then
    maxUnits = ShieldNumPeopleAffected;
  elseif (spellModel == M_SPELL_BLOODLUST) then
    maxUnits = BloodlustNumPeopleAffected;
  end

  SearchMapCells(CIRCULAR, 0, 0, 1, world_coord3d_to_map_idx(t.Pos.D3), function(me)
  me.MapWhoList:processList(function(p)
    if (p.Type == T_PERSON) then
      if (p.Model ~= M_PERSON_MEDICINE_MAN and (p.Owner == t.Owner or are_players_allied(p.Owner, t.Owner) == 1) and p.Flags2 & TF2_THING_IS_A_GHOST_PERSON == 0) then
        --For some reason it finds the first person twice???? So check if the person isnt double.
        if (p ~= unitsFound[unitsFoundCount-1]) then
          unitsFound[unitsFoundCount] = p
          unitsFoundCount = unitsFoundCount + 1
        end
        
      end
    end
  return true
  end)
  return true
  end)

  local unitsFoundWithBuffsIndex = 0
  local unitsFoundWithSameBuffsIndex = 0
  local unitsFoundWithoutBuffsIndex = 0
  
  for i=0, unitsFoundCount - 1 do
	  if (unitsFound[i].Flags2 & TF2_THING_IS_AN_INVISIBLE_PERSON >= 1 or unitsFound[i].Flags3 & TF3_SHIELD_ACTIVE >= 1 or unitsFound[i].Flags3 & TF3_BLOODLUST_ACTIVE >= 1) then
      if ((unitsFound[i].Flags2 & TF2_THING_IS_AN_INVISIBLE_PERSON >= 1 and spellModel == M_SPELL_INVISIBILITY) or (unitsFound[i].Flags3 & TF3_SHIELD_ACTIVE >= 1 and spellModel == M_SPELL_SHIELD) or (unitsFound[i].Flags3 & TF3_BLOODLUST_ACTIVE >= 1 and spellModel == M_SPELL_BLOODLUST)) then
        unitsFoundWithSameBuffs[unitsFoundWithSameBuffsIndex] = unitsFound[i]
        unitsFoundWithSameBuffsIndex = unitsFoundWithSameBuffsIndex + 1
      else
        unitsFoundWithBuffs[unitsFoundWithBuffsIndex] = unitsFound[i]
        unitsFoundWithBuffsIndex = unitsFoundWithBuffsIndex + 1
      end
    else
      unitsFoundWithoutBuffs[unitsFoundWithoutBuffsIndex] = unitsFound [i]
      unitsFoundWithoutBuffsIndex = unitsFoundWithoutBuffsIndex + 1
    end
  end 

  local withBuffsSpecialIndex = 0
  local withSameBuffsSpecialIndex = 0

  for i=0, maxUnits-1 do
	  if (tableLength(unitsFoundWithoutBuffs) >= i + 1) then
      unitsAffected[i] = unitsFoundWithoutBuffs[i]
    elseif (tableLength(unitsFoundWithBuffs) >= withBuffsSpecialIndex + 1) then
      unitsAffected[i] = unitsFoundWithBuffs[withBuffsSpecialIndex]
      withBuffsSpecialIndex = withBuffsSpecialIndex + 1
    elseif (tableLength(unitsFoundWithSameBuffs) >= withSameBuffsSpecialIndex + 1) then
      unitsAffected[i] = unitsFoundWithSameBuffs[withSameBuffsSpecialIndex]
      withSameBuffsSpecialIndex = withSameBuffsSpecialIndex + 1
    end
  end

  if (tableLength(unitsAffected) >= 1) then
    for i, pers in pairs(unitsAffected) do
      --First turn all other buff spells off.
      if (pers.Flags2 & TF2_THING_IS_AN_INVISIBLE_PERSON >= 1) then
        pers.u.Pers.u.Owned.InvisibleCount = 0
        pers.Flags2 = pers.Flags2 ~ TF2_THING_IS_AN_INVISIBLE_PERSON -- Invis

        --If they are standing still make them move so the source code actually applies the invisibility effect...
        if (pers.State == S_PERSON_NONE or pers.State == S_PERSON_WAIT_AT_POINT) then
          command_person_go_to_coord2d(pers, pers.Pos.D2)
          remove_all_persons_commands(pers)
        end
      end
      if (pers.Flags3 & TF3_SHIELD_ACTIVE >= 1) then
        pers.u.Pers.u.Owned.ShieldCount = 0
        pers.Flags3 = pers.Flags3 ~ TF3_SHIELD_ACTIVE --Shield
      end
      if (pers.Flags3 & TF3_BLOODLUST_ACTIVE >= 1) then
        pers.u.Pers.u.Owned.BloodlustCount = 0
        pers.Flags3 = pers.Flags3 ~ TF3_BLOODLUST_ACTIVE --Bloodlust
      end

      if (spellModel == M_SPELL_INVISIBILITY) then
        pers.Flags2 = pers.Flags2 | TF2_THING_IS_AN_INVISIBLE_PERSON
        pers.u.Pers.u.Owned.InvisibleCount = _constants.InvisibleCount
       
        --If they are standing still make them move so the source code actually applies the invisibility effect...
        if (pers.State == S_PERSON_NONE or pers.State == S_PERSON_WAIT_AT_POINT) then
          command_person_go_to_coord2d(pers, pers.Pos.D2)
          remove_all_persons_commands(pers)
        end
      elseif (spellModel == M_SPELL_SHIELD) then
        pers.Flags3 = pers.Flags3 | TF3_SHIELD_ACTIVE
        pers.u.Pers.u.Owned.ShieldCount = _constants.ShieldCount
      elseif (spellModel == M_SPELL_BLOODLUST) then
        pers.Flags3 = pers.Flags3 | TF3_BLOODLUST_ACTIVE
        pers.u.Pers.u.Owned.BloodlustCount = _constants.BloodlustCount
      end
    end
  end

  DestroyThing(t)
end

function tableLength(Table)
  local count = 0
  for _ in pairs(Table) do count = count + 1 end
  return count
end