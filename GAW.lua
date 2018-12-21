-- Setup JSON
local jsonlib = lfs.writedir() .. "Scripts\\GAW\\json.lua"
json = loadfile(jsonlib)()

-- Setup logging
logFile = io.open(lfs.writedir()..[[Logs\Hoggit-GAW.log]], "w")
--JSON = (loadfile "JSON.lua")()

GAW = {}
function log(str)
  if str == nil then str = 'nil' end
  if logFile then
    logFile:write("HOGGIT GAW LOG - " .. str .."\r\n")
    logFile:flush()
  end
end

SecondsToClock = function(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00m 00s";
  else
    mins = string.format("%02.f", math.floor(seconds/60));
    secs = string.format("%02.f", math.floor(seconds - mins *60));
    return mins.."m "..secs.."s"
  end
end

-- Replace the spawn stuff
Spawner = function(grpName)
  local CallBack = {}
  return {
    Spawn = function(self)
      local added_grp = Group.getByName(mist.cloneGroup(grpName, true).name)
      if CallBack.func then
        if not CallBack.args then CallBack.args = {} end
        mist.scheduleFunction(CallBack.func, {added_grp, unpack(CallBack.args)}, timer.getTime() + 1)
      end
      return added_grp
    end,
    SpawnAtPoint = function(self, point, noDisperse)
      local vars = {
        groupName = grpName,
        point = point,
        action = "clone",
        disperse = true,
        maxDisp = 1000
      }

      if noDisperse then
        vars.disperse = false
      end

      local new_group = mist.teleportToPoint(vars)
      if new_group then
        local name = new_group.name
        if CallBack.func then
          if not CallBack.args then CallBack.args = {} end
          mist.scheduleFunction(CallBack.func, {Group.getByName(name), unpack(CallBack.args)}, timer.getTime() + 1)
        end
        return Group.getByName(name)
      else
        log("Error spawning " .. grpName)
      end

    end,
    SpawnInZone = function(self, zoneName)
      local added_grp = Group.getByName(mist.cloneInZone(grpName, zoneName).name)
      if CallBack.func then
        if not CallBack.args then CallBack.args = {} end
        mist.scheduleFunction(CallBack.func, {added_grp, unpack(CallBack.args)}, timer.getTime() + 1)
      end
      return added_grp
    end,
    OnSpawnGroup = function(self, f, args)
      CallBack.func = f
      CallBack.args = args
    end
  }
end

TheaterObjectiveSpawner = function(objectiveName, groupName)
  return {
    Spawn = function(self)
      local spawned = mist.cloneGroup(groupName)
      if spawned then
        log("Spawned " .. spawned.name.. "!")
      else
        log("Did not spawn ".. groupName .. "!")
        return
      end
      local data = {
        groupName = spawned.name,
        objectiveName = objectiveName
      }
      game_state["Theaters"]["Russian Theater"]["TheaterObjectives"][objectiveName] = data
      return grpName
    end
  }
end

StaticSpawner = function(groupName, numberInGroup, groupOffsets)
  local CallBack = {}
  return {
    Spawn = function(self, firstPos)
      local names = {}
      for i=1,numberInGroup do
        local groupData = mist.getGroupData(groupName .. i)
        groupData.units[1].x = firstPos[1] + groupOffsets[i][1]
        groupData.units[1].y = firstPos[2] + groupOffsets[i][2]
        groupData.clone = true
        table.insert(names, mist.dynAddStatic(groupData).name)
      end

      if CallBack.func then
        if not CallBack.args then CallBack.args = {} end
        mist.scheduleFunction(CallBack.func, {names, firstPos, unpack(CallBack.args)}, timer.getTime() + 1)
      end

      return names
    end,
    OnSpawnGroup = function(self, f, args)
      CallBack.func = f
      CallBack.args = args
    end
  }
end

GetCoordinate = function(grp)
  local firstUnit = grp:getUnit(1)
  if firstUnit then
    return firstUnit:getPosition().p
  end
end

-- Coalition Menu additions
CoalitionMenu = function( coalition, text )
  return missionCommands.addSubMenuForCoalition( coalition, text )
end
GAW.GroupMenuAdded={}
GroupMenu = function( groupId, text, parent )
  if GAW.GroupMenuAdded[tostring(groupId)] == nil then
    log("No commands from groupId " .. groupId .. " yet. Initializing menu state")
    GAW.GroupMenuAdded[tostring(groupId)] = {}
  end
  if not GAW.GroupMenuAdded[tostring(groupId)][text] then
    log("Adding " .. text .. " to groupId: " .. tostring(groupId))
    GAW.GroupMenuAdded[tostring(groupId)][text] = missionCommands.addSubMenuForGroup( groupId, text, parent )
  end
  return GAW.GroupMenuAdded[tostring(groupId)][text]
end


HandleError = function(err)
  log("Error in pcall: "  .. err)
  log(debug.traceback())
  return err
end

try = function(func, catch)
  return function()
    local r, e = xpcall(func, HandleError)
    if not r then
      catch(e)
    end
  end
end

CoalitionCommand = function(coalition, text, parent, handler)
  callback = try(handler, function(err) log("Error in coalition command: " .. err) end)
  missionCommands.addCommandForCoalition( coalition, text, parent, callback)
end

-- This is a global to hold records of which groups have had
-- group menus added to already.
-- We might try and add menus to the same group twice, this
-- should prevent that.
GAW.GroupCommandAdded= {}
GroupCommand = function(group, text, parent, handler)
  if GAW.GroupCommandAdded[tostring(group)] == nil then
    log("No commands from group " .. group .. " yet. Initializing menu state")
    GAW.GroupCommandAdded[tostring(group)] = {}
  end
  if not GAW.GroupCommandAdded[tostring(group)][text] then
    log("Adding " .. text .. " to group: " .. tostring(group))
    callback = try(handler, function(err) log("Error in group command" .. err) end)
    missionCommands.addCommandForGroup( group, text, parent, callback)
    GAW.GroupCommandAdded[tostring(group)][text] = true
  end
end

MessageToGroup = function(groupId, text, displayTime, clear)
  if not displayTime then displayTime = 10 end
  if clear == nil then clear = false end
  trigger.action.outTextForGroup( groupId, text, displayTime, clear)
end

MessageToAll = function( text, displayTime )
  if not displayTime then displayTime = 10 end
  trigger.action.outText( text, displayTime )
end

standbycassound = "l10n/DEFAULT/standby.ogg"
ninelinecassound = "l10n/DEFAULT/marked.ogg"
targetdestroyedsound = "l10n/DEFAULT/targetdestroyed.ogg"
terminatecassound = "l10n/DEFAULT/depart.ogg"
ableavesound =  "l10n/DEFAULT/transport.ogg"
farpleavesound =  "l10n/DEFAULT/transportfarp.ogg"
abcapsound = "l10n/DEFAULT/arrive.ogg"
farpcapsound = "l10n/DEFAULT/arrivefarp.ogg"

oncall_cas = {}
enemy_interceptors = {}

--function log(str)end
log("Logging System INIT")

function isAlive(group)
  local grp = nil
  if type(group) == "string" then
    grp = Group.getByName(group)
  else
    grp = group
  end
  if grp and grp:isExist() and grp:getSize() > 0 then return true else return false end
end

function groupIsDead(groupName)
  if (Group.getByName(groupName) and Group.getByName(groupName):isExist() == false) or (Group.getByName(groupName) and #Group.getByName(groupName):getUnits() < 1) or not Group.getByName(groupName) then
    return true
  end
  return false
end

function allOnGround(group)
  local grp = nil
  local allOnGround = true
  if type(group) == "string" then
    grp = Group.getByName(group)
  else
    grp = group
  end
  if not grp then return false end

  for i,unit in ipairs(grp:getUnits()) do
    if unit:inAir() then allOnGround = false end
  end

  return allOnGround
end

checkedSams = {}
checkedEWRs = {}
checkedC2s = {}

buildCheckSAMEvent = function(group, callsign)
  checkedSams[group:getName()] = callsign
end

buildCheckEWREvent = function(group, callsign)
  checkedEWRs[group:getName()] = callsign
end

buildCheckC2Event = function(group, callsign)
  checkedC2s[group:getName()] = callsign
end

function handleDeaths(event)
  -- The scheduledSpawn stuff only works for groups with a single unit atm.
  if event.id == world.event.S_EVENT_DEAD or event.id == world.event.S_EVENT_ENGINE_SHUTDOWN then
    log("Death event handler")
    if not event.initiator.getGroup then
      if event.initiator.getName then
        local sobname = event.initiator.getName(event.initiator)
        log('Static object destroyed: ' .. sobname)
        for k, v in ipairs(DestructibleStatics) do
          if string.match(sobname, v) then
            log('adding ' .. sobname .. ' to list of destroyed static objects')
            game_state['Theaters']['Russian Theater']['DestroyedStatics'][sobname] = true
          end
        end
      end
      --We're done.
      return
    end
    local grp = event.initiator:getGroup()
    if not grp then return end
    log("Death for grp " .. grp:getName())
    if checkedSams[grp:getName()] then
      local radars = 0
      local launchers = 0
      log("Group death is a sam group. Iterating units")
      for i, unit in pairs(grp:getUnits()) do
        local type_name = unit:getTypeName()
        if type_name == "Kub 2P25 ln" then launchers = launchers + 1 end
        if type_name == "Kub 1S91 str" then radars = radars + 1 end
        if type_name == "S-300PS 64H6E sr" then radars = radars + 1 end
        if type_name == "S-300PS 40B6MD sr" then radars = radars + 1 end
        if type_name == "S-300PS 40B6M tr" then radars = radars + 1 end
        if type_name == "S-300PS 5P85C ln" then launchers = launchers + 1 end
        if type_name == "S-300PS 5P85D ln" then launchers = launchers + 1 end
      end

      log("Done iterating sam units")
      if radars == 0 or launchers == 0 then
        log("SAM considered dead. removing from state")
        game_state['Theaters']['Russian Theater']['StrategicSAM'][grp:getName()] = nil
        trigger.action.outText("SAM " .. checkedSams[grp:getName()] .. " has been destroyed!", 15)
        checkedSams[grp:getName()] = nil
      end
    end

    if checkedC2s[grp:getName()] then
      log("Group death is a c2 group")
      local cps = 0
      log("Iterating c2 units")
      for i, unit in pairs(grp:getUnits()) do
        if unit:getTypeName() == "SKP-11" then cps = cps + 1 end
      end

      if cps == 0 then
        log("C2 group considered dead. removing from state")
        game_state['Theaters']['Russian Theater']['C2'][grp:getName()] = nil
        trigger.action.outText("C2 " .. checkedC2s[grp:getName()] .. " has been destroyed!", 15)
        checkedC2s[grp:getName()] = nil
      end
    end

    if checkedEWRs[grp:getName()] then
      log("Group death is EWR. Iterating units.")
      local ewrs = 0
      for i, unit in pairs(grp:getUnits()) do
        if unit:getTypeName() == "1L13 EWR" then ewrs = ewrs + 1 end
      end

      if ewrs == 0 then
        log("EWR considered dead. removing from state")
        game_state['Theaters']['Russian Theater']['EWR'][grp:getName()] = nil
        trigger.action.outText("EWR " .. checkedEWRs[grp:getName()] .. " has been destroyed!", 15)
        checkedEWRs[grp:getName()] = nil
      end
    end

    if scheduledSpawns[event.initiator:getName()] then
      log("Dead group was a scheduledSpawn.")
      local spawner = scheduledSpawns[event.initiator:getName()][1]
      local stimer = scheduledSpawns[event.initiator:getName()][2]
      scheduledSpawns[event.initiator:getName()] = nil
      mist.scheduleFunction(function()
        spawner:Spawn()
        if grp then
          grp:destroy()
        end
      end, {}, timer.getTime() + stimer)
    end
  end
end

mist.addEventHandler(handleDeaths)

function securityForcesLanding(event)
  if event.id == world.event.S_EVENT_LAND then
    log("Land Event!")
    local xport = activeBlueXports[event.initiator:getGroup():getName()]
    if xport then
      local abname = xport[2]
      if xport[3] then abname = abname .. " Warehouse" end
      log('Xport just landed at ' .. abname)
      local grpLoc = event.initiator:getPosition().p
      local landPos = Airbase.getByName(abname):getPosition().p
      local distance = mist.utils.get2DDist(grpLoc, landPos)
      log("Transport landed " .. distance .. " meters from target")
      if (distance <= 2500) then
        log("Within range, spawning Friendly Forces")
        if xport[3] then
          trigger.action.outSoundForCoalition(2, farpcapsound)
        else
          trigger.action.outSoundForCoalition(2, abcapsound)
        end

        if xport[4][3] then
          activateLogi(xport[4][3])
          log("Logi activated")
        else
          log("No logi point here")
        end

        local randFactor = 200
        if xport[3] then
          randFactor = 50
        end

        local pos = {
          x = landPos.x + 80,
          y = landPos.z + 80
        }

        AirfieldDefense:SpawnAtPoint(pos)
        FSW:SpawnAtPoint({
          x = pos.x - 10,
          y = pos.y - 10
        })
        log("Security forces have spawned")
      end
      mist.scheduleFunction(event.initiator.destroy, {event.initiator}, timer.getTime() + 120)
    end
  end
end
mist.addEventHandler(securityForcesLanding)

function baseCaptured(event)
  if event.id == world.event.S_EVENT_BASE_CAPTURED then
    log("baseCaptured")
    local abname = event.place:getName()
    local coalition = event.place:getCoalition()
    local flagval
    if coalition == 1 then
      flagval = 100
    elseif coalition == 2 then
      flagval = 0
    end

    if abslots[abname] then
      for i,grp in ipairs(abslots[abname]) do
        trigger.action.setUserFlag(grp, flagval)
      end
    end

    if abname == 'FARP ALPHA' or abname == 'FARP BRAVO' or abname == 'FARP CHARLIE' or abname == 'FARP DELTA' then
      game_state["Theaters"]["Russian Theater"]['FARPS'][abname] = coalition
    else
      game_state["Theaters"]["Russian Theater"]['Airfields'][abname] = coalition
    end

    -- update primary goal state
    if abname == 'Sukhumi-Babushara' or abname == 'Beslan' then
      if coalition == 2 then
        game_state["Theaters"]["Russian Theater"]['Primary'][abname] = true
      else
        game_state["Theaters"]["Russian Theater"]['Primary'][abname] = false
      end
    end

    -- disable Sukhumi airport red CAP spawn if it is captured by blufor
    if abname == 'Sukhumi-Babushara' then
      if coalition == 2 then
        poopcapsground = {RussianTheaterF5SpawnGROUND}
        goodcapsground = {RussianTheaterJ11SpawnGROUND}
      else
        poopcapsground = {RussianTheaterMig212ShipSpawnGROUND, RussianTheaterF5SpawnGROUND}
        goodcapsground = {RussianTheaterMig292ShipSpawnGROUND, RussianTheaterSu272sShipSpawnGROUND, RussianTheaterJ11SpawnGROUND}
      end
    end

  end
end

local objectiveTypeMap = {
  ["NavalStrike"] = "NAVAL",
  ["StrategicSAM"] = "SAM",
  ["Convoys"] = "CONVOY",
  ["C2"] = "C2",
  ["EWR"] = "EWR",
  ["StrikeTargets"] = "STRIKE",
  ["InterceptTargets"] = "INTERCEPT",
  ["BAI"] = "BAI",
  ["AWACS"] = "AWACS",
  ["Tanker"] = "Tanker"
}

mist.addEventHandler(baseCaptured)
objectiveCounter = 99
AddObjective = function(type, id)
  return function(group, spawn_name, callsign)
    if not group then
      return
    end
    local unit = group:getUnit(1)
    if unit then
      game_state["Theaters"]["Russian Theater"][type][group:getName()] = {
        ["callsign"] = callsign,
        ["spawn_name"] = spawn_name,
        ["position"] = unit:getPosition().p,
        ["markerID"] = id
      }

      trigger.action.markToCoalition(id, objectiveTypeMap[type] .. " - " .. callsign, unit:getPosition().p, 2, true)
    end
  end
end

AddStaticObjective = function(id, callsign, spawn_name, staticNames)
  local point = StaticObject.getByName(staticNames[1]):getPosition().p
  game_state["Theaters"]["Russian Theater"]["StrikeTargets"]["strike" .. id] = {
    ['callsign'] = callsign,
    ['spawn_name'] = spawn_name,
    ['position'] = point,
    ['markerID'] = id,
    ['statics'] = staticNames
  }
end

AddConvoy = function(group, spawn_name, callsign)
  log("Adding convoy " .. callsign)
  game_state['Theaters']['Russian Theater']['Convoys'][group:getName()] = {spawn_name, callsign}
end

AddCAP = function(theater)
  return function(group)
    table.insert(game_state["Theaters"][theater]["CAP"], group:getName())
  end
end

AddRussianTheaterCAP = function(group)
  AddCAP("Russian Theater")(group)
end

AddAWACSTarget = function(theater)
  return function(group)
    table.insert(game_state["Theaters"][theater]["AWACS"], group:getName())
  end
end

AddRussianTheaterAWACSTarget = function(group)
  AddAWACSTarget("Russian Theater")(group)
end

AddTankerTarget = function(theater)
  return function(group)
    table.insert(game_state["Theaters"][theater]["Tanker"], group:getName())
  end
end

AddRussianTheaterTankerTarget = function(group)
  AddTankerTarget("Russian Theater")(group)
end

SpawnDefenseForces = function(target_string, time, last_launched_time, spawn)
  log("Defense forces requested to " .. target_string)
  local launch_frequency_seconds = 600
  if time > (last_launched_time + launch_frequency_seconds) then
    log("Time OK. Spawning Security forces")
    spawn:Spawn()
    MessageToAll("Security Forces en route to ".. target_string, 30)
    return time
  else
    log("Can't send security forces yet. Still on cooldown")
    MessageToAll("Unable to send security forces, next mission available in " .. SecondsToClock(launch_frequency_seconds + last_launched_time - time), 30)
    return nil
  end
end

ConvoyUpdate = function(group)
  log("Doing convoy update")
  local output = "REDFOR Convoy Report:\n\n"
  local numConvoys = 0
  for name, convoy_info in pairs(game_state['Theaters']['Russian Theater']['Convoys']) do
    local convoy = Group.getByName(name)
    local cunits = {}
    if convoy then
      cunits = convoy:getUnits()
      numConvoys = numConvoys + 1

      local names = {}
      if cunits then
        for idx, unit in pairs(cunits) do
          table.insert(names, unit:getName())
        end
        output = output .. convoy_info[2] .." MGRS: " .. mist.getMGRSString({
          units=names,
          acc=2
        }) .. "\nLat/Long: " .. mist.getLLString({
          units=names,
          acc=1,
          DMS=true
        })  .. "\n\n"
      end
    end
  end

  log("Done iterating convoys")
  if numConvoys == 0 then
    output = output .. "No Active Convoys"
  end
  if group == 'all' then
    MessageToAll(output, 20)
  else

    MessageToGroup(group:getID(), output, 20)
  end
  log("Done convoy update")
end

--SCHEDULER:New(nil, ConvoyUpdate, {"all"}, 300, 900)
mist.scheduleFunction(ConvoyUpdate, {"all"}, timer.getTime()+ 300, 900)


TheaterUpdate = function(theater)
  log("Doing theater Update")
  local output = "OPFOR Strategic Report: " .. theater .. "\n--------------------------\n\nSAM COVERAGE: "
  local numsams = 0
  for i,sam in pairs(game_state["Theaters"][theater]['StrategicSAM']) do
    numsams = numsams + 1
  end

  if numsams > 5 then
    output = output .. "Fully Operational"
  elseif numsams > 3 then
    output = output .. "Degraded"
  elseif numsams > 0 then
    output = output .. "Critical"
  else
    output = output .. "None"
  end

  local numc2 = 0
  for i,c2 in pairs(game_state["Theaters"][theater]['C2']) do
    numc2 = numc2 + 1
  end

  output = output .. "\n\nCOMMAND AND CONTROL: "
  if numc2 == 3 then
    output = output .. "Fully Operational"
  elseif numc2 == 2 then
    output = output .. "Degraded"
  elseif numc2 == 1 then
    output = output .. "Critical"
  else
    output = output .. "Destroyed"
  end

  local numewr = 0
  for i,ewr in pairs(game_state["Theaters"][theater]['EWR']) do
    numewr = numewr + 1
  end
  output = output .. "\n\nEW RADAR COVERAGE: "
  if numewr == 3 then
    output = output .. "Fully Operational"
  elseif numewr == 2 then
    output = output .. "Degraded"
  elseif numewr == 1 then
    output = output .. "Critical"
  else
    output = output .. "None"
  end

  output = output .. "\n\nPRIMARY AIRFIELDS: \n"
  for name,capped in pairs(game_state['Theaters'][theater]["Primary"]) do
    output = output .. "    " .. name .. ": "
    if capped then output = output .. "Captured\n" else output = output .. "NOT CAPTURED\n" end
  end

  output = output .. "\n\nTHEATER OBJECTIVE:  Destroy all strike targets, all Command and Control (C2) units, and capture all primary airfields."

  log("Done theater update")
  return output
end

log("GAW.lua complete")
