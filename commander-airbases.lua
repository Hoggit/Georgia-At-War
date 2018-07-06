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
NovoroHeloSpawn = SPAWN:New("NovoroHeloTransport")

KrymskTransportSpawn = SPAWN:New("KrymskRussiaTransport")
KrymskHeloSpawn = SPAWN:New("KrymskHeloTransport")

GelenTransportSpawn = SPAWN:New("GelenRussiaTransport")
GelenHeloSpawn = SPAWN:New("GelenHeloTransport")

KrasnodarCenterTransportSpawn = SPAWN:New("KrasCenterRussiaTransport")
KrasnodarCenterHeloSpawn = SPAWN:New("KrasCenterHeloTransport")

KrasnodarPashkovskyTransportSpawn = SPAWN:New("KrasPashRussiaTransport")
KrasnodarPashkovskyHeloSpawn = SPAWN:New("KrasPashHeloTransport")

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

SpawnForTargetAirbase = function(baseName)
    local base = AIRBASE:FindByName(baseName)
    if base:GetCoalition() == BLUE then
        --Return the helo group since the transport planes can't land if it's blue.
        log(baseName .. " is a capitalist pig airport. Send in the choppas")
        return AirbaseSpawns[baseName][2]
    else
        --It's landable _right now_. Just send the plane.
        log(baseName .. " is not owned by those dogs. Send in a plane!")
        return AirbaseSpawns[baseName][1]
    end
end

--Airbase -> Spawn Map.
AirbaseSpawns = {
    [AIRBASE.Caucasus.Gelendzhik]={GelenTransportSpawn, GelenHeloSpawn, DefGlensPenis},
    [AIRBASE.Caucasus.Krasnodar_Pashkovsky]={KrasnodarPashkovskyTransportSpawn, KrasnodarPashkovskyHeloSpawn, DefKrasPash},
    [AIRBASE.Caucasus.Krasnodar_Center]={KrasnodarCenterTransportSpawn, KrasnodarCenterHeloSpawn, DefKrasCenter},
    [AIRBASE.Caucasus.Novorossiysk]={NovoroTransportSpawn, NovoroHeloSpawn, DefNovo},
    [AIRBASE.Caucasus.Krymsk]={KrymskTransportSpawn, KrymskHeloSpawn, DefKrymsk}
}

onTransportLand = function(defense_group)
    local f = function(SpawnedGroup)
        SpawnedGroup:HandleEvent(EVENTS.Land)
        function SpawnedGroup:OnEventLand(EventData)
            if EventData.place:getName() == airbase then
                defense_group:Spawn()
            end

            SCHEDULER:New(nil, SpawnedGroup.Destroy, {SpawnedGroup}, 120)
        end
    end
    return f
end
for airbase,spawn_info in pairs(AirbaseSpawns) do
    local plane_spawn = spawn_info[1]
    local helo_spawn = spawn_info[2]
    local defense_group = spawn_info[3]
    local onLandFunc = onTransportLand(defense_group)
    plane_spawn:OnSpawnGroup(onLandFunc)
    helo_spawn:OnSpawnGroup(onLandFunc)
end

log("AIRBASE CONFIG LOADED")
