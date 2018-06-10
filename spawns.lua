-- Transport Spawns
NorthGeorgiaTransportSpawns = {
    ["Novorossiysk"] = SPAWN:New("NovoroTransport"),
    ["Gelendzhik"] = SPAWN:New("GelenTransport"), 
    ["Krasnodar-Center"] = SPAWN:New("KDARTransport"),
    ["Krasnodar-East"] = SPAWN:New("KDAR2Transport"),
    ["Krymsk"] = SPAWN:New("KrymskTransport")
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
RussianTheaterAWACSSpawn = SPAWN:New("A50"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(300)
RUSTankerSpawn = SPAWN:New("RUSTanker"):InitDelayOff():InitRepeatOnEngineShutDown():InitLimit(1,0):SpawnScheduled(300)

-- CAP Redfor spawns
RussianTheaterMig212ShipSpawn = SPAWN:New("Mig212ship")
RussianTheaterMig292ShipSpawn = SPAWN:New("Mig292ship")
RussianTheaterSu272sShipSpawn = SPAWN:New("Su272ship")
RussianTheaterAWACSPatrol = SPAWN:New("RUSAWACS Patrol"):InitRepeatOnEngineShutDown():InitLimit(2, 0):SpawnScheduled(600)

-- Strike Target Spawns
RussianHeavyArtySpawn = SPAWN:New("ARTILLERY")
ArmorColumnSpawn = SPAWN:New("ARMOR COLUMN")
MechInfSpawn = SPAWN:New("MECH INF")
AmmoDumpSpawn = SPAWNSTATIC:NewFromStatic("Ammo Dump", country.id.RUSSIA)
CommsArraySpawn = SPAWNSTATIC:NewFromStatic("Comms Array", country.id.RUSSIA)
PowerPlantSpawn = SPAWNSTATIC:NewFromStatic("Power Plant", country.id.RUSSIA)

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
    AddRussianTheaterStrategicSAM(game_state, SpawnedGroup)
end)

RussianTheaterSA10Spawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterStrategicSAM(game_state, SpawnedGroup)
end)

RussianTheaterEWRSpawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterEWR(game_state, SpawnedGroup)
end)

RussianTheaterC2Spawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterC2(game_state, SpawnedGroup)
end)

RUSTankerSpawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterTankerTarget(game_state, SpawnedGroup)
end)

RussianTheaterAWACSSpawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterAWACSTarget(game_state, SpawnedGroup)
end)

for i,v in ipairs(baispawns) do
    v:OnSpawnGroup(function(SpawnedGroup)
        AddRussianTheaterBAITarget(game_state, SpawnedGroup)
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
            AirfieldDefense:SpawnFromVec2(apV3:GetVec2())
            SCHEDULER:New(nil, SpawnedGroup.Destroy, {SpawnedGroup}, 120)
        end
    end)
end

BASE:I("HOGGIT GAW - SPAWNS COMPLETE")
log("spawns.lua complete")
