local NEUTRAL=0
local RED=1
local BLUE=2

--Airbases in play.
Airbases = {
    AIRBASE.Caucasus.Gelendzhik,
    AIRBASE.Caucasus.Krasnodar_Pashkovsky,
    AIRBASE.Caucasus.Krasnodar_Center,
    AIRBASE.Caucasus.Novorossiysk,
    AIRBASE.Caucasus.Krymsk
}

-- Russian IL-76MD spawns to capture airfields
NovoroTransportSpawn = SPAWN:New("NovoroRussiaTransport")
KrymskTransportSpawn = SPAWN:New("KrymskRussiaTransport")
GelenTransportSpawn = SPAWN:New("GelenRussiaTransport")
KrasnodarCenterTransportSpawn = SPAWN:New("KrasCenterRussiaTransport")
KrasnodarPashkovskyTransportSpawn = SPAWN:New("KrasPashRussiaTransport")
RussianTheaterAirfieldDefSpawn = SPAWN:New("Russia-Airfield-Def")

AttackableAirbases = function(airbaseList)
    local filtered = {}
    for k,baseName in pairs(airbaseList) do
        local base = AIRBASE:FindByName(baseName)
        if base:GetCoalition() == NEUTRAL or base:GetCoalition() == BLUE then
            table.insert(filtered,baseName)
        end
    end
    return filtered
end

AirfieldIsDefended = function(baseName)
    local base = AIRBASE:FindByName(baseName)
    local zone = ZONE_RADIUS:New("airfield-defense-chk", base:GetVec2(), 1500)
    -- return zone:GetScannedCoalition(BLUE) ~= nil --BROKEN
    local groupsInZone = SET_GROUP
        :New()
        :FilterCoalitions("blue")
        :FilterCategoryGround()
        :FilterStart()
    return #groupsInZone > 0
end

--Airbase -> Spawn Map.
AirbaseSpawns = {
    [AIRBASE.Caucasus.Gelendzhik]={GelenTransportSpawn, DefGlensPenis},
    [AIRBASE.Caucasus.Krasnodar_Pashkovsky]={KrasnodarPashkovskyTransportSpawn, DefKrasPash},
    [AIRBASE.Caucasus.Krasnodar_Center]={KrasnodarCenterTransportSpawn, DefKrasCenter},
    [AIRBASE.Caucasus.Novorossiysk]={NovoroTransportSpawn, DefNovo},
    [AIRBASE.Caucasus.Krymsk]={KrymskTransportSpawn, DefKrymsk}
}

for airbase,spawn_info in pairs(AirbaseSpawns) do
    local spawn = spawn_info[1]
    local defense_group = spawn_info[2]
    spawn:OnSpawnGroup(function(SpawnedGroup)
        SpawnedGroup:HandleEvent(EVENTS.Land)
        function SpawnedGroup:OnEventLand(EventData)
            defense_group:Spawn()
            SCHEDULER:New(nil, SpawnedGroup.Destroy, {SpawnedGroup}, 120)
        end
    end)
end

log("AIRBASE CONFIG LOADED")
