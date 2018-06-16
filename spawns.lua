-- Objective Names
objective_names = {
    "Blackjack", "Wildcard", "Crackpipe", "Bullhorn", "Outlaw", "Eclipse","Joker", "Anthill",
    "Firefly", "Buzzard", "Eagle", "Rambo", "Rocky", "Dredd", "Smokey", "Vulture", "Parrot",
    "Copper", "Ender", "Sanchez", "Freeman", "Bandito", "Atlanta", "Raleigh", "Charlotte", "Orlando",
    "Tiger", "Moocow", "Turkey", "Scarecrow", "Lancer", "Subaru", "Tucker", "Blazer", "Snowball"
}

objective_idx = 1

getCallsign = function()
    local callsign = objective_names[objective_idx]
    objective_idx = objective_idx + 1
    if objective_idx > #objective_names then objective_idx = 1 end
    return callsign
end

-- Transport Spawns
NorthGeorgiaTransportSpawns = {
    ["Novorossiysk"] = SPAWN:New("NovoroTransport"),
    ["Gelendzhik"] = SPAWN:New("GelenTransport"), 
    ["Krasnodar-Center"] = SPAWN:New("KDARTransport"),
    ["Krasnodar-East"] = SPAWN:New("KDAR2Transport"),
    ["Krymsk"] = SPAWN:New("KrymskTransport")
}

NorthGeorgiaFARPTransportSpawns = {
    ["NW"] = SPAWN:New("NW FARP HELO"),
    ["NE"] = SPAWN:New("NE FARP HELO"), 
    ["SW"] = SPAWN:New("SW FARP HELO"),
    ["SE"] = SPAWN:New("SE FARP HELO"),
}

-- Support Spawn
TexacoSpawn = SPAWN:New("Texaco"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(120)
ShellSpawn = SPAWN:New("Shell"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(140)
OverlordSpawn = SPAWN:New("AWACS Overlord"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(160)
AWACSPatrol = SPAWN:New("AWACS Patrol"):InitRepeatOnEngineShutDown():InitLimit(2, 0):SpawnScheduled(600)

-- Local defense spawns.  Usually used after a transport spawn lands somewhere.
AirfieldDefense = SPAWN:New("AirfieldDefense")

-- Strategic REDFOR spawns
RussianTheaterSA10Spawn = SPAWN:New("SA10")
RussianTheaterSA6Spawn = SPAWN:New("SA6")
RussianTheaterEWRSpawn = SPAWN:New("EWR")
RussianTheaterC2Spawn = SPAWN:New("C2")
RussianTheaterAirfieldDefSpawn = SPAWN:New("Russia-Airfield-Def")
RussianTheaterAWACSSpawn = SPAWN:New("A50"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(300)
RUSTankerSpawn = SPAWN:New("IL78-RUSTanker"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(300)

-- CAP Redfor spawns
RussianTheaterMig212ShipSpawn = SPAWN:New("Mig21-2ship")
RussianTheaterMig292ShipSpawn = SPAWN:New("Mig29-2ship")
RussianTheaterSu272sShipSpawn = SPAWN:New("Su27-2ship")
RussianTheaterMig312ShipSpawn = SPAWN:New("Mig31-2ship"):InitLimit(2, 0)
RussianTheaterAWACSPatrol = SPAWN:New("SU27-RUSAWACS Patrol"):InitRepeatOnEngineShutDown():InitLimit(2, 0):SpawnScheduled(600)

-- Strike Target Spawns
RussianHeavyArtySpawn = SPAWN:New("ARTILLERY")
ArmorColumnSpawn = SPAWN:New("ARMOR COLUMN")
MechInfSpawn = SPAWN:New("MECH INF")
AmmoDumpSpawn = SPAWNSTATIC:NewFromStatic("Ammo Dump", country.id.RUSSIA)
CommsArraySpawn = SPAWNSTATIC:NewFromStatic("Comms Array", country.id.RUSSIA)
PowerPlantSpawn = SPAWNSTATIC:NewFromStatic("Power Plant", country.id.RUSSIA)

-- Airfield CAS Spawns
RussianTheaterCASSpawn = SPAWN:New("Su25T-CASGroup")
RussianTheaterCASSpawn:HandleEvent(EVENTS.EngineShutdown)
function RussianTheaterCASSpawn:_OnEngineShutdown(EventData)
    local grp = EventData.IniGroup
    grp:Destroy()
end
--RussianTheatreCASEscort = SPAWN:New("Su27CASEscort")

-- Group spanws for easy randomization
local allcaps = {RussianTheaterMig212ShipSpawn, RussianTheaterSu272sShipSpawn, RussianTheaterMig292ShipSpawn}
poopcaps = {RussianTheaterMig212ShipSpawn}
goodcaps = {RussianTheaterMig292ShipSpawn, RussianTheaterSu272sShipSpawn}
baispawns = {RussianHeavyArtySpawn, ArmorColumnSpawn, MechInfSpawn}

-- OnSpawn Callbacks.  Add ourselves to the game state
RussianTheaterAWACSSpawn:OnSpawnGroup(function(SpawnedGroup)
    RussianTheaterAWACSPatrol:Spawn()
end)

OverlordSpawn:OnSpawnGroup(function(SpawnedGroup)
    AWACSPatrol:Spawn()
end)

RussianTheaterSA6Spawn:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    AddRussianTheaterStrategicSAM(game_state, SpawnedGroup, callsign)
end)

RussianTheaterSA10Spawn:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    AddRussianTheaterStrategicSAM(game_state, SpawnedGroup, callsign)
end)

RussianTheaterEWRSpawn:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    AddRussianTheaterEWR(game_state, SpawnedGroup, callsign)
end)

RussianTheaterC2Spawn:OnSpawnGroup(function(SpawnedGroup)
    local callsign = getCallsign()
    AddRussianTheaterC2(game_state, SpawnedGroup, callsign)
end)

RUSTankerSpawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterTankerTarget(game_state, SpawnedGroup)
end)

RussianTheaterAWACSSpawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterAWACSTarget(game_state, SpawnedGroup)
end)

-- RussianTheaterCASSpawn:OnSpawnGroup(function(SpawnedGroup)
--     AddRussianTheaterCASGroup(game_state, SpawnedGroup)
-- end)

for i,v in ipairs(baispawns) do
    v:OnSpawnGroup(function(SpawnedGroup)
        local callsign = getCallsign()
        AddRussianTheaterBAITarget(game_state, SpawnedGroup, callsign)
    end)
end

for i,v in ipairs(allcaps) do
    v:OnSpawnGroup(function(SpawnedGroup)
        AddRussianTheaterCAP(game_state, SpawnedGroup)
    end)
end

for name,spawn in pairs(NorthGeorgiaTransportSpawns) do
    spawn:OnSpawnGroup(function(SpawnedGroup)
        SpawnedGroup:HandleEvent(EVENTS.Land)
        function SpawnedGroup:OnEventLand(EventData)
            local apV3 = POINT_VEC3:NewFromVec3(EventData.place:getPosition().p)
            apV3:SetX(apV3:GetX() + math.random(400, 600))
            apV3:SetY(apV3:GetY() + math.random(200))
            local air_def_grp = AirfieldDefense:SpawnFromVec2(apV3:GetVec2())
            SCHEDULER:New(nil, SpawnedGroup.Destroy, {SpawnedGroup}, 120)
            ScheduleCASMission(apV3, RussianTheaterCASSpawn, 1000, air_def_grp)
        end
    end)
end

for name,spawn in pairs(NorthGeorgiaFARPTransportSpawns) do
    spawn:OnSpawnGroup(function(SpawnedGroup)
        SpawnedGroup:HandleEvent(EVENTS.Land)
        function SpawnedGroup:OnEventLand(EventData)
            local apV3 = POINT_VEC3:NewFromVec3(EventData.IniGroup:GetPositionVec3())
            apV3:SetX(apV3:GetX() + math.random(-100, 200))
            apV3:SetY(apV3:GetY() + math.random(-100, 200))
            AirfieldDefense:SpawnFromVec2(apV3:GetVec2())
            SCHEDULER:New(nil, SpawnedGroup.Destroy, {SpawnedGroup}, 120)
        end
    end)
end

BASE:I("HOGGIT GAW - SPAWNS COMPLETE")
log("spawns.lua complete")
