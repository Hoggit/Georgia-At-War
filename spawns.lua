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

-- OnSpawn Callbacks.  Add ourselves to the game state
RussianTheaterSA6Spawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterStrategicSAM(game_state, SpawnedGroup)
end)

RussianTheaterSA10Spawn:OnSpawnGroup(function(SpawnedGroup)
    AddRussianTheaterStrategicSAM(game_state, SpawnedGroup)
end)

BASE:I("HOGGIT GAW - SPAWNS COMPLETE")