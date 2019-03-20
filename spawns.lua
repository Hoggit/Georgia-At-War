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
    local _SpawnObject = Spawner( "HawkHelo" )
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
NovoLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -39857.5703125,
        ['y'] = 279000.5
    },
    "novologizone"
}

KryLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -5951.622558,
        ['y'] = 293862.25
    },
    "krymsklogizone"
}

KrasCenterLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = 11981.98046875,
        ['y'] = 364532.65625
    },
    "krascenterlogizone"
}

KrasPashLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = 8229.2353515625,
        ['y'] = 386831.65625
    },
    "kraspashlogizone"
}

MaykopLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -26322.15625,
        ['y'] = 421495.96875
    },
    "mklogizone"
}

SEFARPLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -26322.15625,
        ['y'] = 421495.96875
    },
    "sefarplogizone"
}

-- Transport Spawns
NorthGeorgiaTransportSpawns = {
    ['Novorossiysk'] = {Spawner("NovoroTransport"), Spawner("NovoroTransportHelo"), NovoLogiSpawn},
    ['Gelendzhik'] = {Spawner("GelenTransport"), Spawner("GelenTransportHelo"), nil},
    ['Krasnodar-Center'] = {Spawner("KDARTransport"), Spawner("KrasCenterTransportHelo"), KrasCenterLogiSpawn},
    ['Krasnodar_Pashkovsky'] = {Spawner("KDAR2Transport"), Spawner("KrasPashTransportHelo"), nil},
    ['Krymsk'] = {Spawner("KrymskTransport"), Spawner("KrymskTransportHelo"), KryLogiSpawn}
}

NorthGeorgiaFARPTransportSpawns = {
    ["NW"] = {Spawner("NW FARP HELO"), nil, nil},
    ["NE"] = {Spawner("NE FARP HELO"), nil, nil},
    ["SW"] = {Spawner("SW FARP HELO"),nil, nil},
    ["SE"] = {Spawner("SE FARP HELO"),nil, SEFARPLogiSpawn},
    ["MK"] = {Spawner("MK FARP HELO"), nil, MaykopLogiSpawn}
}

-- Tells a tanker (or other aircraft for that matter) to orbit between two points at a set altitude

WeatherPositioning = {}
WeatherPositioning.hMaxFlightAlt	= 5486	-- meters [18 000']: Don't let the aircraft fly higher than this as Hogs won't be able to refuel. TODO: Make overrideable
WeatherPositioning.vSpeed			= 160		-- m/s [300kts]: Default speed of the unit
WeatherPositioning.hClearance		= 305		-- meters [1000']: Default clearance to cloud

function WeatherPositioning.getCloudFreeAltitude()
	local clouds = env.mission.weather.clouds
	
	local hAltitude = WeatherPositioning.hMaxFlightAlt
	if (((clouds.base + clouds.thickness) >= hAltitude - WeatherPositioning.hClearance) and (clouds.density >= 7)) then
		hAltitude = math.min(clouds.base - WeatherPositioning.hClearance, WeatherPositioning.hMaxFlightAlt)
	end
	return hAltitude
end

function WeatherPositioning.avoidCloudLayer(planeGroup, vSpeed)
	local planeGroupName	= planeGroup:getName()
	vSpeed = vSpeed or WeatherPositioning.vSpeed
	
	-- Calculate orbit height. Ignore for partial cloud conditions
	local hOrbit = WeatherPositioning.getCloudFreeAltitude()
	
	local curRoute = mist.getGroupRoute(planeGroupName, true)
	
	for i = 1, #curRoute do
		curRoute[i].alt = hOrbit
		
		-- Modify any orbit taskings
		if #curRoute[i] ~= nil and #curRoute[i].task ~= nil and #curRoute[i].task.params ~= nil and #curRoute[i].task.params.tasks ~= nil then
			for t = 1, #curRoute[i].task.params.tasks do
				local curTask = curRoute[i].task.params.tasks[t]
				if curTask.id == "Orbit" then
					curTask.params.altitude = hOrbit
					curTask.params.speed = vSpeed
				end
			end
		end
	end
	
	local route = mist.goRoute(planeGroup, curRoute)
end



scheduledSpawns = {}
DestructibleStatics = {}
DestroyedStatics = {}
-- Support Spawn
TexacoSpawn = Spawner("Texaco")
TexacoSpawn:OnSpawnGroup(function(grp)
    scheduledSpawns[grp:getUnit(1):getName()] = {TexacoSpawn, 600}
	WeatherPositioning.avoidCloudLayer(grp, 145) -- Init against cloud base at 145m/s (280 knots)
end)

ShellSpawn = Spawner("Shell")
ShellSpawn:OnSpawnGroup(function(grp)
    scheduledSpawns[grp:getUnit(1):getName()] = {ShellSpawn, 600}
	WeatherPositioning.avoidCloudLayer(grp, 165) -- Init against cloud base at 165m/s (320 knots)
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
RussianTheaterAirfieldDefSpawn = Spawner("Russia-Airfield-Def")
RussianTheaterAWACSSpawn = Spawner("A50")
RussianTheaterAWACSPatrol = Spawner("SU27-RUSAWACS Patrol")

RussianTheaterAWACSSpawn:OnSpawnGroup(function(grp)
    scheduledSpawns[grp:getUnit(1):getName()] = {RussianTheaterAWACSSpawn, 1800}
end)

-- REDFOR specific airfield defense spawns
DefKrasPash = Spawner("Red Airfield Defense Kras-Pash 1")
DefKrasCenter = Spawner("Red Airfield Defense Kras-Center 1")
DefKrymsk = Spawner("Red Airfield Defense Krymsk 1")
DefNovo = Spawner("Red Airfield Defense Novo 1")
DefGlensPenis = Spawner("Red Airfield Defense GlensDick 1")

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

-- Naval Strike target Spawns
--PlatformGroupSpawn = {SPAWNSTATIC:NewFromStatic("Oil Platform", country.id.RUSSIA), "Oil Platform"}

-- Airfield CAS Spawns
RussianTheaterCASSpawn = Spawner("Su25T-CASGroup")

-- FARP defenses
NWFARPDEF = Spawner("FARP DEFENSE")
SWFARPDEF = Spawner("FARP DEFENSE #001")
NEFARPDEF = Spawner("FARP DEFENSE #003")
SEFARPDEF = Spawner("FARP DEFENSE #002")
MKFARPDEF = Spawner("FARP DEFENSE #004")

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

RussianTheaterAWACSSpawn:OnSpawnGroup(function(SpawnedGroup)
    local callsign = "Overseer"
    AddObjective("AWACS", getMarkerId())(SpawnedGroup, "AWACS", callsign)
    RussianTheaterAWACSPatrol:Spawn()
end)

--local sammenu = MENU_MISSION:New("DESTROY SAMS")
RussianTheaterSA6Spawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    --MENU_MISSION_COMMAND:New("DESTROY " .. callsign, sammenu, function()
    --    SpawnedGroup:Destroy()
    --end)

    AddObjective("StrategicSAM", getMarkerId())(SpawnedGroup, RussianTheaterSA6Spawn[2], callsign)
    buildCheckSAMEvent(SpawnedGroup, callsign)
end)

RussianTheaterSA10Spawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    --MENU_MISSION_COMMAND:New("DESTROY " .. callsign, sammenu, function()
    --    SpawnedGroup:Destroy()
    --end)
    AddObjective("StrategicSAM", getMarkerId())(SpawnedGroup, RussianTheaterSA10Spawn[2], callsign)
    buildCheckSAMEvent(SpawnedGroup, callsign)
end)

--local ewrmenu = MENU_MISSION:New("DESTROY EWRS")
RussianTheaterEWRSpawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    --MENU_MISSION_COMMAND:New("DESTROY " .. callsign, ewrmenu, function()
    --    SpawnedGroup:Destroy()
    --end)
    AddObjective("EWR", getMarkerId())(SpawnedGroup, RussianTheaterEWRSpawn[2], callsign)
    buildCheckEWREvent(SpawnedGroup, callsign)
end)

--local c2menu = MENU_MISSION:New("DESTROY C2S")
RussianTheaterC2Spawn[1]:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    --MENU_MISSION_COMMAND:New("DESTROY " .. callsign, c2menu, function()
    --    SpawnedGroup:Destroy()
    --end)
    AddObjective("C2", getMarkerId())(SpawnedGroup, RussianTheaterC2Spawn[2], callsign)
    buildCheckC2Event(SpawnedGroup, callsign)
end)

SpawnOPFORCas = function(spawn)
    --log("===== CAS Spawn begin")
    local casGroup = spawn:Spawn()
end

--local baimenu = MENU_MISSION:New("DESTROY BAIS")
for i,v in ipairs(baispawns) do
    v[1]:OnSpawnGroup(function(SpawnedGroup)
        local callsign = getCallsign()
        --MENU_MISSION_COMMAND:New("DESTROY " .. callsign, baimenu, function()
        --    SpawnedGroup:Destroy()
        --end)
        AddObjective("BAI", getMarkerId())(SpawnedGroup, v[2], callsign)
        --AddRussianTheaterBAITarget(SpawnedGroup, v[2], callsign)
    end)
end

--local capsmenu = MENU_MISSION:New("DESTROY CAPS")
for i,v in ipairs(allcaps) do
    v:OnSpawnGroup(function(SpawnedGroup)
       -- MENU_MISSION_COMMAND:New("DESTROY " .. SpawnedGroup:GetName(), capsmenu, function()
        --    SpawnedGroup:Destroy()
        --end)
        AddRussianTheaterCAP(SpawnedGroup)
    end)
end

activeBlueXports = {}

addToActiveBlueXports = function(group, defense_group_spawner, target, is_farp, xport_data)
    activeBlueXports[group:getName()] = {defense_group_spawner, target, is_farp, xport_data}
    log("Added " .. group:getName() .. " to active blue transports")
end

removeFromActiveBlueXports = function(group, defense_group_spawner, target)
    activeBlueXports[group:getName()] = nil
end

for name,spawn in pairs(NorthGeorgiaTransportSpawns) do
    for i=1,2 do
        if i == 1 then
            spawn[i]:OnSpawnGroup(function(SpawnedGroup)
                addToActiveBlueXports(SpawnedGroup, AirfieldDefense, name, false, spawn[i])
            end)
        end

        if i == 2 then
            spawn[i]:OnSpawnGroup(function(SpawnedGroup)
                addToActiveBlueXports(SpawnedGroup, AirfieldDefense, name, false, spawn[i])
            end)
        end

    end
end

for name,spawn in pairs(NorthGeorgiaFARPTransportSpawns) do
    spawn[1]:OnSpawnGroup(function(SpawnedGroup)
        addToActiveBlueXports(SpawnedGroup, AirfieldDefense, name, true, spawn)
    end)
end

log("spawns.lua complete")
