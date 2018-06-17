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

AttackableAirfield = function()
    local filtered = {}
    for k,baseName in pairs(Airbases) do
        local base = AIRBASE:FindByName(baseName)
        if base:GetCoalition() == NEUTRAL or base:GetCoalition() == BLUE then
            table.insert(filtered,base)
        end
    end
    return filtered
end

AirFieldIsDefended = function(baseName)
    local base = AIRBASE:FindByName(baseName)
    local zone = ZONE_RADIUS:New("airfield-defense-chk", base:GetVec2(), 1500)
    return zone:GetScannedCoalition(BLUE) ~= nil
end


--Airbase -> Spawn Map.
AirbaseSpawns = {
    [AIRBASE.Caucasus.Gelendzhik]=GelenTransportSpawn,
    [AIRBASE.Caucasus.Krasnodar_Pashkovsky]=KrasnodarPashkovskyTransportSpawn,
    [AIRBASE.Caucasus.Krasnodar_Center]=KrasnodarCenterTransportSpawn,
    [AIRBASE.Caucasus.Novorossiysk]=NovoroTransportSpawn,
    [AIRBASE.Caucasus.Krymsk]=KrymskTransportSpawn
}

for airbase,spawn in pairs(AirbaseSpawns) do
    spawn:OnSpawnGroup(function(SpawnedGroup)
        SpawnedGroup:HandleEvvent(EVENTS.Land)
        function SpawnedGroup:OnEventLand(EventData)
            local apV3 = POINT_VEC3:NewFromVec3(EventData.place:getPosition().p)
            apV3:SetX(apV3:GetX() + math.random(400, 600))
            apV3:SetY(apV3:GetY() + math.random(200))
            local air_def_grp = AirfieldDefense:SpawnFromVec2(apV3:GetVec2())
            SCHEDULER:New(nil, SpawnedGroup.Destroy, {SpawnedGroup}, 120)
        end
    end)
end

log("AIRBASE CONFIG LOADED")
