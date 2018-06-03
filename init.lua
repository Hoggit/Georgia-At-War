-- Populate the world and gameplay environment.

local XportMenu = MENU_COALITION:New(coalition.side.BLUE, "Deploy Airfield Security Forces")
local russianTheaterMenu = MENU_COALITION:New(coalition.side.BLUE, "Russian Theater", XportMenu)

local StateMenu = MENU_COALITION:New(coalition.side.BLUE, "Theater Targets")
local ShowNumSames = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "SAMS", StateMenu, function() BASE:I(#game_state["Theaters"]["Russian Theater"]["StrategicSAM"]) end)
local ShowNumSames = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Dump State", StateMenu, function() BASE:I(dump(game_state)) end)

for i=1, 4 do
    local zone_index = math.random(4)
    local zone = ZONE:New("NorthSA6Zone" .. zone_index)
    RussianTheaterSA6Spawn:SpawnInZone(zone, true)
end

for i=1, 2 do
    local zone_index = math.random(3)
    local zone = ZONE:New("NorthSA10Zone" .. zone_index)
    RussianTheaterSA10Spawn:SpawnInZone(zone, true)
end

for i=1, 2 do
    RussianTheaterMig212ShipSpawn:SpawnAtAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Maykop_Khanskaya), SPAWN.Takeoff.Cold)
end

for name,spawn in pairs(NorthGeorgiaTransportSpawns) do
    spawn:OnSpawnGroup(function(SpawnedGroup)
        SpawnedGroup:HandleEvent(EVENTS.Land)
        function SpawnedGroup:OnEventLand(EventData)
            local apV3 = POINT_VEC3:NewFromVec3(EventData.place:getPosition().p)
            apV3:SetX(apV3:GetX() + 300)
            AirfieldDefense:SpawnFromVec2(apV3:GetVec2())
            SpawnedGroup:Destroy()
        end
    end)

    local curMenu = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Deploy to " .. name, russianTheaterMenu, function() 
        local new_spawn_time = SpawnDefenseForces(timer.getAbsTime() + env.mission.start_time, game_state["last_launched_time"], spawn)
        if new_spawn_time ~= nil then
            game_state["last_launched_time"] = new_spawn_time
        end
    end)
end

BASE:I("HOGGIT GAW - INIT COMPLETE")
