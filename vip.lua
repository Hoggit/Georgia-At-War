-- AFTER GAW.LUA, SPAWNS.LUA, UTIL.LUA
-- BEFORE COMMANDER.LUA, MENUS.LUA

GAW.VIP = {}
GAW.VIP.pickupTime = 10 -- seconds
GAW.VIP.pickupRange = 100
GAW.VIP.activeTime = 3600
GAW.VIP.activeVIPTransports = {}
GAW.VIP.activeVIPs = {}
GAW.VIP.carriedVIPs = {}
GAW.VIP.vipLoadStatus = {}

inDropOffZone = function(grp)
  for _, zoneName in pairs(VIPDropoffZones) do
    local zone = trigger.misc.getZone(zoneName)
    if zone ~= nil then
      local dist = mist.utils.get2DDist(GetCoordinate(grp), zone.point)
      if dist <= zone.radius then
        return true
      end
    end
  end
  return false
end

DropVIP = function(grp)
  if GAW.VIP.carriedVIPs[grp:getName()] ~= nil then
    if not inDropOffZone(grp) then
      MessageToGroup(grp:getID(), "You're not in a VIP Drop off zone. Head to the nearest logistics point!")
    else
      MessageToGroup(grp:getID(), "VIP Dropped off successfully!")
      GAW.VIP.carriedVIPs[grp:getName()] = nil
      SpawnStrikeTarget()
      MessageToAll("A strike target has been located based off intelligence captured from Russia. Check Mission Status for details")
      log("VIP intel has revealed a strike target")
    end
  else
    MessageToGroup(grp:getID(), "You're not carrying any VIPs!", 3)
  end
end

SpawnVIPTransport = function()
  local vipGrp = randomFromList(VIPSpawns)
  local spawner = Spawner(vipGrp)
  local spawnZone = GetRandomVIPSpawnZone()
  local zone = spawnZone[1]
  local spawnName = spawnZone[2]
  MessageToAll("A VIP carrying classified intelligence has been spotted trying to get to Beslan from " .. spawnName)
  log("VIP spawned")
  local spawnedGroup = spawner:SpawnInZone(zone)
  local path = mist.getGroupRoute(vipGrp, true)
  mist.scheduleFunction(mist.goRoute, {spawnedGroup, path}, timer.getTime() + 5)
  table.insert(GAW.VIP.activeVIPTransports, spawnedGroup:getName())
end

VIPDeathHandler = function(event)
  if event.id ~= world.event.S_EVENT_CRASH and event.id ~= world.event.S_EVENT_LAND then return end
  log("VIPDeathHandler")
  if not event.initiator then return end
  if not event.initiator.getGroup then return end
  local grp = event.initiator:getGroup()
  local grpName = grp:getName()
  if listContains(GAW.VIP.activeVIPTransports, grpName) then
    if event.id == world.event.S_EVENT_CRASH then
      local pt = event.initiator:getPoint()
      local lat,long = coord.LOtoLL(pt)
      SpawnVIPForPickup(pt, true)
      MessageToAll("Russian VIP transport has been downed! Intelligence can be found at: \n" .. mist.tostringLL(lat,long,6), 60)
      log("Russian VIP has been shot down")
    else
      MessageToAll("Russian VIP has successfully evacuated the AO!")
      log("Russian VIP escaped on the transport to Beslan.")
    end
    table.remove(GAW.VIP.activeVIPTransports, tableIndex(GAW.VIP.activeVIPTransports, grpName))
    mist.scheduleFunction(Group.destroy, {grp}, timer.getTime() + 10)
  end
end

SpawnVIPForPickup = function(point, remove)
  trigger.action.smoke(point, trigger.smokeColor.Red)
  table.insert(GAW.VIP.activeVIPs, point)
  if remove ~= nil and not remove then
    mist.scheduleFunction(RemoveVIPSpawn, {point}, timer.getTime() + GAW.VIP.activeTime)
  end
end

RemoveVIPSpawn = function(point)
  if tableIndex(GAW.VIP.activeVIPs, point) == nil then return end
  table.remove(GAW.VIP.activeVIPs, tableIndex(GAW.VIP.activeVIPs, point))
  local lat,long = coord.LOtoLL(point)
  MessageToAll("Russian VIP at " .. mist.tostringLL(lat,long,6) .. " has escaped.")
  log("Russian VIP escaped after waiting for an hour")
end

mist.addEventHandler(VIPDeathHandler)

GetRandomVIPSpawnZone = function()
  local spawnableZones = VIPSpawnZones
  return randomFromList(spawnableZones)
end

CheckVIPPickup = function()
  --Use the ctld transports for now
  mist.scheduleFunction(CheckVIPPickup, nil, timer.getTime() + 1)
  local vipPoints = GAW.VIP.activeVIPs
  for _, name in ipairs(ctld.transportPilotNames) do
    local resetStatus = true
    local unit = ctld.getTransportUnit(name)
    if unit ~= nil then
      if not GAW.VIP.carriedVIPs[unit:getName()] and not unit:inAir() then
        local unitPos = unit:getPoint()
        for i, vipLoc in pairs(vipPoints) do
          local distToVip = mist.utils.get2DDist(vipLoc, unitPos)
          if distToVip <= GAW.VIP.pickupRange then
            resetStatus = false
            local _time = GAW.VIP.vipLoadStatus[unit:getName()]
            if _time == nil then
              GAW.VIP.vipLoadStatus[unit:getName()] = GAW.VIP.pickupTime
              _time = GAW.VIP.pickupTime
            else
              _time = GAW.VIP.vipLoadStatus[unit:getName()] - 1
              GAW.VIP.vipLoadStatus[unit:getName()] = _time
            end

            if _time > 0 then
              MessageToGroup(unit:getGroup():getID(), "Landed by VIP! Wait " .. _time .. " more seconds to load", 2, true)
            else
              GAW.VIP.carriedVIPs[unit:getGroup():getName()] = true
              --GAW.VIP.activeVIPs[i] = nil
              table.remove(GAW.VIP.activeVIPs, i)
              MessageToGroup(unit:getGroup():getID(), "Loaded VIP!", 3)
              log("VIP loaded into " .. unit:getGroup())
            end
          end
        end
      end
    end
    if resetStatus then GAW.VIP.vipLoadStatus[name] = nil end
  end
end
mist.scheduleFunction(CheckVIPPickup, nil, timer.getTime() + 1)

RefreshVIPSmoke = function()
  mist.scheduleFunction(RefreshVIPSmoke, nil, timer.getTime() + 300)
  for _, pt in pairs(GAW.VIP.activeVIPs) do
    trigger.action.smoke(pt, trigger.smokeColor.Red)
  end
end
mist.scheduleFunction(RefreshVIPSmoke, nil, timer.getTime() + 300)

PlayerVIPTransportDeathHandler = function(event)
  if event.id ~= world.event.S_EVENT_CRASH and event.id ~= world.event.S_EVENT_PLAYER_LEAVE_UNIT then return end
  log("PlayerVIPTransportDeathHandler")
  if not event.initiator then return end
  if not event.initiator.getGroup then return end
  local grp = event.initiator:getGroup()
  if GAW.VIP.carriedVIPs[grp:getName()] ~= nil then
    log("VIP carrier " .. grp:getName() .. " killed. VIP dead and intelligence destroyed.")
    MessageToAll("VIP carrier killed. VIP dead and intelligence destroyed.")
    GAW.VIP.carriedVIPs[grp:getName()] = nil
  end
end
mist.addEventHandler(PlayerVIPTransportDeathHandler)
