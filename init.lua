-- Populate the world and gameplay environment.
for i=1, 4 do
    local zone_index = math.random(4)
    local zone = ZONE:New("NorthSA6Zone" .. zone_index)
    RussianTheaterSA6Spawn:SpawnInZone(zone, true)
end

for i=1, 3 do
    if i < 3 then
        local zone_index = math.random(3)
        local zone = ZONE:New("NorthSA10Zone" .. zone_index)
        RussianTheaterSA10Spawn:SpawnInZone(zone, true)

        local zone_index = math.random(3)
        local zone = ZONE:New("NorthSA10Zone" .. zone_index)
        RussianTheaterEWRSpawn:SpawnInZone(zone, true)
    end

    local zone_index = math.random(3)
    local zone = ZONE:New("NorthSA10Zone" .. zone_index)
    RussianTheaterC2Spawn:SpawnInZone(zone, true)
end

-- Kick off the commanders
SCHEDULER:New(nil, function()
    log("Starting Russian Commander, Comrade")
    pcall(russian_commander)
end, {}, 10, 300)

BASE:I("HOGGIT GAW - INIT COMPLETE")
log("init.lua complete")
