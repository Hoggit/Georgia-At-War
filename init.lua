-- Populate the world and gameplay environment.
for i=1, 4 do
    local zone_index = math.random(23)
    local zone = ZONE:New("NorthSA6Zone" .. zone_index)
    RussianTheaterSA6Spawn:SpawnInZone(zone, true)
end

for i=1, 3 do
    if i < 3 then
        local zone_index = math.random(8)
        local zone = ZONE:New("NorthSA10Zone" .. zone_index)
        RussianTheaterSA10Spawn:SpawnInZone(zone, true)
    end

    local zone_index = math.random(8)
    local zone = ZONE:New("NorthSA10Zone" .. zone_index)
    RussianTheaterEWRSpawn:SpawnInZone(zone, true)

    local zone_index = math.random(8)
    local zone = ZONE:New("NorthSA10Zone" .. zone_index)
    RussianTheaterC2Spawn:SpawnInZone(zone, true)
end

for i=1, 10 do
    local zone_index = math.random(18)
    local zone = ZONE:New("NorthStatic" .. zone_index)
    local StaticSpawns = {AmmoDumpSpawn, PowerPlantSpawn, CommsArraySpawn}
    local spawn_index = math.random(3)
    local static = StaticSpawns[spawn_index]:SpawnFromPointVec2(zone:GetRandomPointVec2(), 0)
    local callsign = getCallsign()
    AddRussianTheaterStrikeTarget(game_state, STATIC:FindByName(static:getName()), callsign)
end

-- Kick off the commanders
local commander_coro = coroutine.create(russian_commander)
local last_complete_time = 0
function commander_loop()
    mist.scheduleFunction(commander_loop, {}, timer.getTime() + 1)
    if coroutine.status(commander_coro) == 'suspended' then
        coroutine.resume(commander_coro)
    end

    if coroutine.status(commander_coro) == 'dead' and timer.getTime() > last_complete_time + 400 then
        commander_coro = coroutine.create(russian_commander)
        coroutine.resume(commander_coro)
    end
end

commander_loop()

-- Kick off the supports
RussianTheaterAWACSSpawn:Spawn()
OverlordSpawn:Spawn()
RUSTankerSpawn:Spawn()
TexacoSpawn:Spawn()
ShellSpawn:Spawn()

SCHEDULER:New(nil, function() 
    local state = TheaterUpdate(game_state, "Russian Theater")
    MESSAGE:New(state, 45):ToAll()
end, {}, 120, 900)

buildHitEvent(GROUP:FindByName("FARP DEFENSE #003"), "NE FARP")
buildHitEvent(GROUP:FindByName("FARP DEFENSE"), "NW FARP")
buildHitEvent(GROUP:FindByName("FARP DEFENSE #002"), "SE FARP")
buildHitEvent(GROUP:FindByName("FARP DEFENSE #001"), "SW FARP")

AirbaseSpawns[AIRBASE.Caucasus.Krasnodar_Pashkovsky][1]:Spawn()

BASE:I("HOGGIT GAW - INIT COMPLETE")
log("init.lua complete")
