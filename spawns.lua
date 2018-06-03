-- Transport Spawns
NorthGeorgiaTransportSpawns = {
    ["Novorossiysk"] = SPAWN:New("NovoroTransport"),
    ["Gelendzhik"] = SPAWN:New("GelenTransport"), 
    ["Krasnodar-Center"] = SPAWN:New("KDARTransport"),
    ["Krasnodar-East"] = SPAWN:New("KDAR2Transport"),
    ["Krymsk"] = SPAWN:New("KrymskTransport")
}

-- Local defense spawns.  Usually used after a transport spawn lands somewhere.
AirfieldDefense = SPAWN:New("AirfieldDefense")

-- Strategic REDFOR spawns
RussianTheaterSA10Spawn = SPAWN:New("SA10")
RussianTheaterSA6Spawn = SPAWN:New("SA6")

-- CAP Redfor spawns
RussianTheaterMig212ShipSpawn = SPAWN:New("Mig212ship")

-- Ground forces Redfor
RussianHeavyArtySpawn = SPAWN:New("HeavyArty")


-- OnSpawn Callbacks.  Add ourselves to the game state
RussianTheaterSA6Spawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterStrategicSAM(game_state, SpawnedGroup)
end)

RussianTheaterSA10Spawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterStrategicSAM(game_state, SpawnedGroup)
end)

RussianHeavyArtySpawn:OnSpawnGroup(function(SpawnedGroup)
    --AddRussianTheaterCAS(game_state, SpawnedGroup)
end)

RussianTheaterMig212ShipSpawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterCAP(game_state, SpawnedGroup)
    local PatrolZone = ZONE:New( "NorthAIPatrolZone" )
    local AICapZone = AI_CAP_ZONE:New( PatrolZone, 500, 1000, 500, 600 )
    local EngageZone = ZONE:New("NorthAICAPZone")
    AICapZone:SetControllable(SpawnedGroup)
    AICapZone:SetEngageZone(EngageZone)
    AICapZone:__Start(1)
end)

BASE:I("HOGGIT GAW - SPAWNS COMPLETE")