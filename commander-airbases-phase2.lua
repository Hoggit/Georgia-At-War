local NEUTRAL=0
local RED=1
local BLUE=2

--Airbases in play.
Airbases = {
    "Sochi-Adler",
    "Gudauta",
    "Mineralnye Vody",
    "Nalchik",
    "Mozdok",
    "Sukhumi-Babushara"
}

-- Russian IL-76MD spawns to capture airfields
MozdokTransportSpawn = Spawner("MozdokTransport")
MozdokHeloSpawn = Spawner("MozdokHeloTransport")
MozdokDefSpawn = Spawner("MozdokDefense")

NalchikTransportSpawn = Spawner("NalchikTransport")
NalchikHeloSpawn = Spawner("NalchikHeloTransport")
NalchikDefSpawn = Spawner("NalchikDefense")

VodyTransportSpawn = Spawner("VodyTransport")
VodyHeloSpawn = Spawner("VodyHeloTransport")
VodyDefSpawn = Spawner("VodyDefense")

SochiTransportSpawn = Spawner("SochiTransport")
SochiHeloSpawn = Spawner("SochiHeloTransport")
SochiDefSpawn = Spawner("SochiDefense")

GudautaTransportSpawn = Spawner("GudautaTransport")
GudautaHeloSpawn = Spawner("GudautaHeloTransport")
GudautaDefSpawn = Spawner("GudautaDefense")

SukhumiTransportSpawn = Spawner("SukhumiTransport")
SukhumiHeloSpawn = Spawner("SukhumiHeloTransport")
SukhumiDefSpawn = Spawner("SukhumiDefense")

RussianTheaterAirfieldDefSpawn = Spawner("Russia-Airfield-Def")

AttackableAirbases = function(airbaseList)
    local filtered = {}
    log("Iterating airbases")
    for i,ab in ipairs(airbaseList) do
        local base = Airbase.getByName(ab)
        if base:getCoalition() == NEUTRAL or base:getCoalition() == BLUE then
            table.insert(filtered,ab)
        end
    end
    log("Done iterating airbases, found " .. #filtered .. " attackable airbases")
    return filtered
end

AirfieldIsDefended = function(baseZone)
    local units = mist.getUnitsInZones(mist.makeUnitTable({'[blue][vehicle]'}), {baseZone})
    if #units > 0 then return true else return false end
end

SpawnForTargetAirbase = function(baseName)
    local base = Airbase.getByName(baseName)
    if base:getCoalition() == BLUE then
        --Return the helo group since the transport planes can't land if it's blue.
        log(baseName .. " is a capitalist pig airport. Send in the choppas")
        return AirbaseSpawns[baseName][2]
    else
        --It's landable _right now_. Just send the plane.
        log(baseName .. " is not owned by those dogs. Send in a plane!")
        return AirbaseSpawns[baseName][1]
    end
end

activeXports = {}

addToActiveXports = function(group, defense_group_spawner, target)
    activeXports[group:getName()] = {defense_group_spawner, target}
    log("Added " .. group:getName() .. " to active red transports")
end

removeFromActiveXports = function(group, defense_group_spawner, target)
    activeXports[group:getName()] = nil
end

--Airbase -> Spawn Map.
AirbaseSpawns = {
    ["Mozdok"]={MozdokTransportSpawn, MozdokHeloSpawn, MozdokDefSpawn},
    ["Nalchik"]={NalchikTransportSpawn, NalchikHeloSpawn, NalchikDefSpawn},
    ["Mineralnye Vody"]={VodyTransportSpawn, VodyHeloSpawn, VodyDefSpawn},
    ["Gudauta"]={GudautaTransportSpawn, GudautaHeloSpawn, GudautaDefSpawn},
    ["Sochi-Adler"]={SochiTransportSpawn, SochiHeloSpawn, SochiDefSpawn},
    ["Sukhumi-Babushara"]={SukhumiTransportSpawn, SukhumiHeloSpawn, SukhumiDefSpawn}
}

function transportLand(event)
  if event.id == world.event.S_EVENT_LAND then
    log("TransportLand")
    if activeXports[event.initiator:getGroup():getName()] then
      local grpLoc = event.initiator:getPosition().p
      local destinationLoc = Airbase.getByName(activeXports[event.initiator:getGroup():getName()][2]):getPosition().p
      local distance = mist.utils.get2DDist(grpLoc, destinationLoc)
      log("Transport landed " .. distance .. " meters from target")
      if (distance <= 3000) then
        log("Within range, spawning Russian Forces")
        activeXports[event.initiator:getGroup():getName()][1]:Spawn()
        mist.scheduleFunction(event.initiator.destroy, {event.initiator}, timer.getTime() + 120)
      end
    end
  end
end

mist.addEventHandler(transportLand)

for airbase,spawn_info in pairs(AirbaseSpawns) do
    local plane_spawn = spawn_info[1]
    local helo_spawn = spawn_info[2]
    local defense_group = spawn_info[3]
    plane_spawn:OnSpawnGroup(addToActiveXports, {defense_group, airbase})
    helo_spawn:OnSpawnGroup(addToActiveXports, {defense_group, airbase})
end

log("AIRBASE CONFIG LOADED")
