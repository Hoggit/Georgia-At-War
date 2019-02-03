-- Objective Names
objective_names = {
    "Eiger", "Snax", "Asteroid", "Sephton", "Blacklist", "Boot", "Maria",
    "Cheeki Breeki", "Husky", "Carrack", "Vegabond", "Jar Jar", "Plowshare", "Primrose", "Cracow",
    "Chaser", "Rockstar", "Rintaro", "Schwifty", "Tombstone", "Zip", "Foxhound","Ysterplaat", "Hamburg", "BlackPearl", "Nitro", "SledgeHammer"
}

objective_idx = 1

getMarkerId = function()
    objectiveCounter = objectiveCounter + 1
    return objectiveCounter
end

getCallsign = function()
    local callsign = objective_names[objective_idx]
    objective_idx = objective_idx + 1
    if objective_idx > #objective_names then objective_idx = 1 end
    return callsign
end


function respawnHAWKFromState(_points)
    log("Spawning hawk from state")
    -- spawn HAWK crates around center point
    ctld.spawnCrateAtPoint("blue",551, _points["Hawk pcp"])
    ctld.spawnCrateAtPoint("blue",540, _points["Hawk ln"])
    ctld.spawnCrateAtPoint("blue",545, _points["Hawk sr"])
    ctld.spawnCrateAtPoint("blue",550, _points["Hawk tr"])

    -- spawn a helper unit that will "build" the site
    local _SpawnObject = Spawner( "SukXportHelo" )
    local _SpawnGroup = _SpawnObject:SpawnAtPoint({x=_points["Hawk pcp"]["x"], y=_points["Hawk pcp"]["z"]})
    local _unit=_SpawnGroup:getUnit(1)

    -- enumerate nearby crates
    local _crates = ctld.getCratesAndDistance(_unit)
    local _crate = ctld.getClosestCrate(_unit, _crates)
    local terlaaTemplate = ctld.getAATemplate(_crate.details.unit)

    ctld.unpackAASystem(_unit, _crate, _crates, terlaaTemplate)
    _SpawnGroup:destroy()
    log("Done Spawning hawk from state")
end

log("Creating player placed spawns")
-- player placed spawns
hawkspawn = Spawner('hawk')
avengerspawn = Spawner('avenger')
ammospawn = Spawner('ammo')
jtacspawn = Spawner('HMMWV - JTAC')
gepardspawn = Spawner('gepard')
mlrsspawn = Spawner('mlrs')
log("Done Creating player placed spawns")

--local logispawn = SPAWNSTATIC:NewFromStatic("logistic3", country.id.USA)
local logispawn = {
    type = "HEMTT TFFT",
    country = "USA",
    category = "Ground vehicles"
}

-- Forward Logistics spawns
LogiFARPALPHASpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -90692,
        ['y'] = 551377
    },
    "LogiFARPAlpha"
}

LogiFARPBRAVOSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -83517,
        ['y'] = 617694
    },
    "LogiFARPBravo"
}

LogiFARPCHARLIESpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -126126,
        ['y'] = 420423
    },
    "LogiFARPCharlie"
}

LogiFARPDELTASpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -98874,
        ['y'] = 808161
    },
    "LogiFARPDelta"
}

LogiVodySpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -77884,
        ['y'] = 761336
    },
    "LogiVody"
}

LogiAdlerSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -166113,
        ['y'] = 462824
    },
    "LogiSochi"
}

LogiGudautaSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -195671,
        ['y'] = 517492
    },
    "LogiGudauta"
}

-- Transport Spawns
NorthGeorgiaTransportSpawns = {
    ['Sochi-Adler'] = {Spawner("SochiXport"), Spawner("SochiXportHelo"), LogiAdlerSpawn},
    ['Gudauta'] = {Spawner("GudautaXport"), Spawner("GudautaXportHelo"), LogiGudautaSpawn},
    ['Sukhumi-Babushara'] = {Spawner("SukXport"), Spawner("SukXportHelo"), nil},
    ['Mineralnye Vody'] = {Spawner("VodyXport"), Spawner("VodyXportHelo"), LogiVodySpawn},
    ['Nalchik'] = {Spawner("NalchikXport"), Spawner("NalchikXportHelo"), nil},
    ['Mozdok'] = {Spawner("MozdokXport"), Spawner("MozdokXportHelo"), nil},
    ['Beslan'] = {Spawner("BeslanXport"), Spawner("BeslanXportHelo"), nil}
}

NorthGeorgiaFARPTransportSpawns = {
    ["FARP ALPHA"] = {Spawner("FARPAlphaXportHelo"), nil, LogiFARPALPHASpawn},
    ["FARP BRAVO"] = {Spawner("FARPBravoXportHelo"), nil, LogiFARPBRAVOSpawn},
    ["FARP CHARLIE"] = {Spawner("FARPCharlieXportHelo"),nil, LogiFARPCHARLIESpawn},
    ["FARP DELTA"] = {Spawner("FARPDeltaXportHelo"),nil, LogiFARPDELTASpawn},
}
scheduledSpawns = {}
BlueSecurityForcesGroups = {}
BlueFarpSupportGroups = {}
-- Support Spawn
TexacoSpawn = Spawner("Texaco")
TexacoSpawn:OnSpawnGroup(function(grp)
    scheduledSpawns[grp:getUnit(1):getName()] = {TexacoSpawn, 600}
end)

ArcoSpawn = Spawner("Arco")
ArcoSpawn:OnSpawnGroup(function(grp)
    scheduledSpawns[grp:getUnit(1):getName()] = {ArcoSpawn, 600}
end)

ShellSpawn = Spawner("Shell")
ShellSpawn:OnSpawnGroup(function(grp)
    scheduledSpawns[grp:getUnit(1):getName()] = {ShellSpawn, 600}
end)

OverlordSpawn = Spawner("AWACS Overlord")
OverlordSpawn:OnSpawnGroup(function(grp)
    scheduledSpawns[grp:getUnit(1):getName()] = {OverlordSpawn, 600}
end)

-- Local defense spawns.  Usually used after a transport spawn lands somewhere.
AirfieldDefense = Spawner("AirfieldDefense")

-- Strategic REDFOR spawns
RussianTheaterSA10Spawn = { Spawner("SA10"), "SA10" }
RussianTheaterSA6Spawn = { Spawner("SA6"), "SA6" }
RussianTheaterEWRSpawn = { Spawner("EWR"), "EWR" }
RussianTheaterC2Spawn = { Spawner("C2"), "C2" }
--RussianTheaterAirfieldDefSpawn = Spawner("Russia-Airfield-Def")
RussianTheaterAWACSSpawn = Spawner("A50")
RussianTheaterAWACSPatrol = Spawner("SU27-RUSAWACS Patrol")

RussianTheaterAWACSSpawn:OnSpawnGroup(function(grp)
    scheduledSpawns[grp:getUnit(1):getName()] = {RussianTheaterAWACSSpawn, 1800}
end)

-- CAP Redfor spawns
RussianTheaterMig212ShipSpawn = Spawner("Mig21-2ship")
RussianTheaterMig292ShipSpawn = Spawner("Mig29-2ship")
RussianTheaterSu272sShipSpawn = Spawner("Su27-2ship")
RussianTheaterF5Spawn = Spawner("f52ship")
RussianTheaterJ11Spawn = Spawner("j112ship")

RussianTheaterMig212ShipSpawnGROUND = Spawner("Mig21-2shipGROUND")
RussianTheaterMig292ShipSpawnGROUND = Spawner("Mig29-2shipGROUND")
RussianTheaterSu272sShipSpawnGROUND = Spawner("Su27-2shipGROUND")
RussianTheaterF5SpawnGROUND = Spawner("f52shipGROUND")
RussianTheaterJ11SpawnGROUND = Spawner("j112shipGROUND")

RussianTheaterMig312ShipSpawn = Spawner("Mig31-2ship")

RussianTheaterMig312ShipSpawn:OnSpawnGroup(function(spawned_group)
    table.insert(enemy_interceptors, spawned_group:getName())
end)

VIPSpawns = { "VIPTransport" }

VIPSpawnZones = {
  {"VIPSpawn-Tuapse", "Tuapse"},
  {"VIPSpawn-Sochi", "Sochi"},
  {"VIPSpawn-Gudauta", "Gudauta"},
  {"VIPSpawn-Vody", "Vody"}
}
VIPDropoffZones = {
  "VIPDropOff-Maykop",
  "VIPDropOff-MaykopSouth",
  "VIPDropOff-MaykopNorth",
  "VIPDropOff-FARPAlpha",
  "VIPDropOff-FARPBravo",
  "VIPDropOff-FARPCharlie",
  "VIPDropOff-FARPDelta",
  "VIPDropOff-Gudauta",
  "VIPDropOff-Sochi",
  "VIPDropOff-Vody"
}

--Theater Objectives. Must be spawned once, and only where in the ME has them.
TuapseRefinery = TheaterObjectiveSpawner("Tuapse Refinery", "TuapseRefineryDef")
ChemSite = TheaterObjectiveSpawner("Chemical Factory", "CHEM SITE VEHICLES")
AmmoDump = TheaterObjectiveSpawner("Chemical Factory", "AMMO DUMP GROUND FORCES")


TheaterObjectives = {}
TheaterObjectives["Tuapse Refinery"] = TuapseRefinery
TheaterObjectives["Chemical Factory"] = ChemSite
TheaterObjectives["Ammunitions Depot"] = AmmoDump


-- Strike Target Spawns
RussianHeavyArtySpawn = { Spawner("ARTILLERY"), "ARTILLERY" }
ArmorColumnSpawn = { Spawner("ARMOR COLUMN"), "ARMOR COLUMN" }
MechInfSpawn = { Spawner("MECH INF"), "MECH INF" }
AmmoDumpDef = Spawner("Ammo DumpDEF")
CommsArrayDef = Spawner("Comms ArrayDEF")
PowerPlantDef = Spawner("Power PlantDEF")

AmmoDumpSpawn = StaticSpawner("Ammo Dump", 7, {
    {0, 0},
    {40, 0},
    {80, -50},
    {80, 0},
    {90, 50},
    {0, 90},
    {-90, 0}
})

AmmoDumpSpawn:OnSpawnGroup(function(staticNames, pos)
    local callsign = getCallsign()
    AddStaticObjective(getMarkerId(), callsign, "AmmoDump", staticNames)
    SpawnStaticDefense("Ammo DumpDEF", pos)
    GameStats:increment("ammo")
end)

CommsArraySpawn = StaticSpawner("Comms Array", 3, {
    {0, 0},
    {80, 0},
    {80, -50},
})

CommsArraySpawn:OnSpawnGroup(function(staticNames, pos)
    local callsign = getCallsign()
    AddStaticObjective(getMarkerId(), callsign, "CommsArray", staticNames)
    SpawnStaticDefense("Comms ArrayDEF", pos)
    GameStats:increment("comms")
end)

PowerPlantSpawn = StaticSpawner("Power Plant", 7, {
    {0, 0},
    {100, 0},
    {200, 150},
    {400, 150},
    {130,  200},
    {160, 200},
    {190, 200}
})

PowerPlantSpawn:OnSpawnGroup(function(staticNames, pos)
    local callsign = getCallsign()
    AddStaticObjective(getMarkerId(), callsign, "PowerPlant", staticNames)
    SpawnStaticDefense("Power PlantDEF", pos)
end)

SpawnStaticDefense = function(group_name, position)
    local groupData = mist.getGroupData(group_name)
    local leaderPos = {groupData.units[1].x, groupData.units[1].y}
    for i,unit in ipairs(groupData.units) do
        local separation = {}
        separation[1] = unit.x - leaderPos[1]
        separation[2] = unit.y - leaderPos[2]
        unit.x = position[1] + separation[1]
        unit.y = position[2] + separation[2]
    end

    groupData.clone = true
    mist.dynAdd(groupData)
end

StrikeTargetSpawns = {
  AmmoDumpSpawn,
  CommsArraySpawn,
  PowerPlantSpawn
}

SpawnStrikeTarget = function()
  local zone_index = math.random(10)
  local zone = "NorthStatic" .. zone_index
  local spawn = randomFromList(StrikeTargetSpawns)
  local vec2 = mist.getRandomPointInZone(zone)
  return spawn:Spawn({vec2.x, vec2.y})
end
-- Naval Strike target Spawns
--PlatformGroupSpawn = {SPAWNSTATIC:NewFromStatic("Oil Platform", country.id.RUSSIA), "Oil Platform"}

-- Airfield CAS Spawns
RussianTheaterCASSpawn = Spawner("Su25T-CASGroup")
RussianTheaterSOUTHCASSpawn = Spawner("Su25T-CASGroupSOUTH")

-- FARP defenses
FARPALPHADEF = Spawner("FARP ALPHA DEF_1")
FARPBRAVODEF = Spawner("FARP BRAVO DEF_1")
FARPCHARLIEDEF = Spawner("FARP CHARLIE DEF_1")
FARPDELTADEF = Spawner("Russia-Airfield-Def")

-- FARP Support Groups
FSW = Spawner("FARP Support West")

-- Group spanws for easy randomization
local allcaps = {
    RussianTheaterMig212ShipSpawn, RussianTheaterSu272sShipSpawn, RussianTheaterMig292ShipSpawn, RussianTheaterJ11Spawn, RussianTheaterF5Spawn,
    RussianTheaterMig212ShipSpawnGROUND, RussianTheaterSu272sShipSpawnGROUND, RussianTheaterMig292ShipSpawnGROUND, RussianTheaterJ11SpawnGROUND, RussianTheaterF5SpawnGROUND
}
poopcaps = {RussianTheaterMig212ShipSpawn, RussianTheaterF5Spawn}
goodcaps = {RussianTheaterMig292ShipSpawn, RussianTheaterSu272sShipSpawn, RussianTheaterJ11Spawn}
poopcapsground = {RussianTheaterMig212ShipSpawnGROUND, RussianTheaterF5SpawnGROUND}
goodcapsground = {RussianTheaterMig292ShipSpawnGROUND, RussianTheaterSu272sShipSpawnGROUND, RussianTheaterJ11SpawnGROUND}
baispawns = {RussianHeavyArtySpawn, ArmorColumnSpawn, MechInfSpawn}

function activateLogi(spawn)
    if spawn then
        local statictable = mist.utils.deepCopy(logispawn)
        statictable.x = spawn[3].x
        statictable.y = spawn[3].y
        local static = mist.dynAddStatic(statictable)
        table.insert(ctld.logisticUnits, static.name)
        ctld.activatePickupZone(spawn[4])
    end
end

-- OnSpawn Callbacks.  Add ourselves to the game state
--for i,spawn_tbl in ipairs(convoy_spawns) do
--    spawn_tbl[1]:OnSpawnGroup(function(SpawnedGroup)
--        local cs = getCallsign()
--        log("Giving new convoy callsign: " .. cs)
--        AddConvoy(SpawnedGroup, spawn_tbl[2],cs)
--    end)
--end

DestructibleStatics = {
    'TUAPSE',
    'CHEM SITE',
    'AMMO DUMP'
}
DestroyedStatics = {}


RussianTheaterAWACSSpawn:OnSpawnGroup(function(SpawnedGroup)
    local callsign = "Overseer"
    AddObjective("AWACS", getMarkerId())(SpawnedGroup, "AWACS", callsign)
    RussianTheaterAWACSPatrol:Spawn()
    GameStats:increment("awacs")
end)

RussianTheaterSA6Spawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    AddObjective("StrategicSAM", getMarkerId())(SpawnedGroup, RussianTheaterSA6Spawn[2], callsign)
    buildCheckSAMEvent(SpawnedGroup, callsign)
end)

RussianTheaterSA10Spawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    AddObjective("StrategicSAM", getMarkerId())(SpawnedGroup, RussianTheaterSA10Spawn[2], callsign)
    buildCheckSAMEvent(SpawnedGroup, callsign)
end)

RussianTheaterEWRSpawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    AddObjective("EWR", getMarkerId())(SpawnedGroup, RussianTheaterEWRSpawn[2], callsign)
    buildCheckEWREvent(SpawnedGroup, callsign)
    GameStats:increment("ewr")
end)

RussianTheaterC2Spawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    AddObjective("C2", getMarkerId())(SpawnedGroup, RussianTheaterC2Spawn[2], callsign)
    buildCheckC2Event(SpawnedGroup, callsign)
    GameStats:increment("c2")
end)

SpawnOPFORCas = function(spawn)
    --log("===== CAS Spawn begin")
    local casGroup = spawn:Spawn()
end

for i,v in ipairs(baispawns) do
    v[1]:OnSpawnGroup(function(SpawnedGroup)
        local callsign = getCallsign()
        AddObjective("BAI", getMarkerId())(SpawnedGroup, v[2], callsign)
        GameStats:increment("bai")
    end)
end

for i,v in ipairs(allcaps) do
    v:OnSpawnGroup(function(SpawnedGroup)
        AddRussianTheaterCAP(SpawnedGroup)
        GameStats:increment("caps")
    end)
end

activeBlueXports = {}

addToActiveBlueXports = function(group, defense_group_spawner, target, is_farp, xport_data, logiunit)
    activeBlueXports[group:getName()] = {defense_group_spawner, target, is_farp, xport_data, logiunit}
    log("Added " .. group:getName() .. " to active blue transports")
end

removeFromActiveBlueXports = function(group, defense_group_spawner, target)
    activeBlueXports[group:getName()] = nil
end

for name,spawn in pairs(NorthGeorgiaTransportSpawns) do
    for i=1,2 do
        if i == 1 then
            spawn[i]:OnSpawnGroup(function(SpawnedGroup)
                addToActiveBlueXports(SpawnedGroup, AirfieldDefense, name, false, spawn[i], spawn[3])
            end)
        end

        if i == 2 then
            spawn[i]:OnSpawnGroup(function(SpawnedGroup)
                addToActiveBlueXports(SpawnedGroup, AirfieldDefense, name, false, spawn[i], spawn[3])
            end)
        end

    end
end

for name,spawn in pairs(NorthGeorgiaFARPTransportSpawns) do
    spawn[1]:OnSpawnGroup(function(SpawnedGroup)
        addToActiveBlueXports(SpawnedGroup, AirfieldDefense, name, true, spawn, spawn[3])
    end)
end

log("spawns.lua complete")
