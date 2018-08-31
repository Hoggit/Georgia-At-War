local statefile = io.open(lfs.writedir() .. "Scripts\\GAW\\state.json", 'r')

-- Enable slotblock
trigger.action.setUserFlag("SSB",100)
if statefile then
    local ab_logi_slots = {
        [AIRBASE.Caucasus.Novorossiysk] = NovoLogiSpawn,
        [AIRBASE.Caucasus.Gelendzhik] = nil,
        [AIRBASE.Caucasus.Krymsk] = KryLogiSpawn,
        [AIRBASE.Caucasus.Krasnodar_Center] = KrasCenterLogiSpawn,
        [AIRBASE.Caucasus.Krasnodar_Pashkovsky] = nil,
    }

    MESSAGE:New("Found a statefile.  Processing it instead of starting a new game", 40):ToAll()
    local state = statefile:read("*all")
    statefile:close()
    local saved_game_state = json:decode(state)
    for name, coalition in pairs(saved_game_state["Theaters"]["Russian Theater"]["Airfields"]) do
        local flagval = 100
        local ab = AIRBASE:FindByName(name)
        local apV3 = POINT_VEC3:NewFromVec3(ab:GetPositionVec3())
        apV3:SetX(apV3:GetX() + math.random(100, 200))
        apV3:SetY(apV3:GetY() + math.random(100, 200))
        game_state["Theaters"]["Russian Theater"]["Airfields"][name] = coalition

        if coalition == 1 then
            AirbaseSpawns[name][3]:Spawn()
            flagval = 100
        elseif coalition == 2 then
            AirfieldDefense:SpawnFromVec2(apV3:GetVec2())
            apV3:SetX(apV3:GetX() + math.random(-50, 50))
            apV3:SetY(apV3:GetY() + math.random(-50,50))
            FSW:SpawnFromVec2(apV3:GetVec2())
            flagval = 0

            if ab_logi_slots[name] then
                activateLogi(ab_logi_slots[name])
            end
        end

        for i,grp in ipairs(abslots[name]) do
            trigger.action.setUserFlag(grp, flagval)     
        end
    end

    for name, coalition in pairs(saved_game_state["Theaters"]["Russian Theater"]["FARPS"]) do
        local flagval = 100
        local ab = AIRBASE:FindByName(name)
        local apV3 = POINT_VEC3:NewFromVec3(ab:GetPositionVec3())
        apV3:SetX(apV3:GetX() + math.random(-25, 25))
        apV3:SetY(apV3:GetY() + math.random(-25, 25))
        local spawns = {NWFARPDEF, SWFARPDEF, NEFARPDEF, SEFARPDEF}
        game_state["Theaters"]["Russian Theater"]["FARPS"][name] = coalition

        if coalition == 1 then
            spawns[math.random(4)]:SpawnFromVec2(apV3:GetVec2())
            flagval = 100
        elseif coalition == 2 then
            AirfieldDefense:SpawnFromVec2(apV3:GetVec2())
            apV3:SetX(apV3:GetX() + math.random(-25, 25))
            apV3:SetY(apV3:GetY() + math.random(-25, 25))
            FSW:SpawnFromVec2(apV3:GetVec2())
            flagval = 0
        end

        for i,grp in ipairs(abslots[name]) do
            trigger.action.setUserFlag(grp, flagval)     
        end

        if name == "MK Warehouse" and coalition == 2 then
            activateLogi(MaykopLogiSpawn)
        end

    end

    for name, data in pairs(saved_game_state["Theaters"]["Russian Theater"]["StrategicSAM"]) do
        local spawn
        if data.spawn_name == "SA6" then spawn = RussianTheaterSA6Spawn[1] end
        if data.spawn_name == "SA10" then spawn = RussianTheaterSA10Spawn[1] end
        spawn:SpawnFromVec2({['x'] = data['position'][1], ['y'] = data['position'][2]})
    end

    for name, data in pairs(saved_game_state["Theaters"]["Russian Theater"]["C2"]) do
        RussianTheaterC2Spawn[1]:SpawnFromVec2({['x'] = data['position'][1], ['y'] = data['position'][2]})
    end

    for name, data in pairs(saved_game_state["Theaters"]["Russian Theater"]["EWR"]) do
        RussianTheaterEWRSpawn[1]:SpawnFromVec2({['x'] = data['position'][1], ['y'] = data['position'][2]})
    end

    for name, data in pairs(saved_game_state["Theaters"]["Russian Theater"]["StrikeTargets"]) do        
        local spawn
        if data['spawn_name'] == 'Ammo Dump' then spawn = AmmoDumpSpawn[1] end
        if data['spawn_name'] == 'Comms Array' then spawn = CommsArraySpawn[1] end
        if data['spawn_name'] == 'Power Plant' then spawn = PowerPlantSpawn[1] end
        local static = spawn:SpawnFromPointVec2(
            POINT_VEC2:NewFromVec2({
                ['x'] = data['position'][1],
                ['y'] = data['position'][2]
            }), 0)
        AddRussianTheaterStrikeTarget(STATIC:FindByName(static:getName()), data['spawn_name'], data['callsign'])
    end

    for name, data in pairs(saved_game_state["Theaters"]["Russian Theater"]["BAI"]) do
        local spawn
        if data['spawn_name'] == "ARTILLERY" then spawn = RussianHeavyArtySpawn[1] end
        if data['spawn_name'] == "ARMOR COLUMN" then spawn = ArmorColumnSpawn[1] end
        if data['spawn_name'] == "MECH INF" then spawn = MechInfSpawn[1] end
        spawn:SpawnFromVec2({['x'] = data['position'][1], ['y'] = data['position'][2]})
    end

    for idx, data in ipairs(saved_game_state["Theaters"]["Russian Theater"]["CTLD_ASSETS"]) do
        if data.name == 'hawk' then
            hawkspawn:SpawnFromVec2(data.pos)
        end

        if data.name == 'avenger' then
            avengerspawn:SpawnFromVec2(data.pos)
        end

        if data.name == 'ammo' then
            ammospawn:SpawnFromVec2(data.pos)
        end

        if data.name == 'jtac' then
            local _spawnedGroups = jtacspawn:SpawnFromVec2(data.pos)
            local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
            table.insert(ctld.jtacGeneratedLaserCodes, _code)
            ctld.JTACAutoLase(_spawnedGroups:GetName(), _code)
        end
    end

else
    -- Populate the world and gameplay environment.
    for i=1, 4 do
        local zone_index = math.random(23)
        local zone = ZONE:New("NorthSA6Zone" .. zone_index)
        RussianTheaterSA6Spawn[1]:SpawnInZone(zone, true)
    end

    for i=1, 3 do
        if i < 3 then
            local zone_index = math.random(8)
            local zone = ZONE:New("NorthSA10Zone" .. zone_index)
            RussianTheaterSA10Spawn[1]:SpawnInZone(zone, true)
        end

        local zone_index = math.random(8)
        local zone = ZONE:New("NorthSA10Zone" .. zone_index)
        RussianTheaterEWRSpawn[1]:SpawnInZone(zone, true)

        local zone_index = math.random(8)
        local zone = ZONE:New("NorthSA10Zone" .. zone_index)
        RussianTheaterC2Spawn[1]:SpawnInZone(zone, true)
    end

    for i=1, 10 do
        local zone_index = math.random(18)
        local zone = ZONE:New("NorthStatic" .. zone_index)
        local StaticSpawns = {AmmoDumpSpawn, PowerPlantSpawn, CommsArraySpawn}
        local spawn_index = math.random(3)
        local static = StaticSpawns[spawn_index][1]:SpawnFromPointVec2(zone:GetRandomPointVec2(), 0)
        local callsign = getCallsign()
        AddRussianTheaterStrikeTarget(STATIC:FindByName(static:getName()), StaticSpawns[spawn_index][2], callsign)
    end

    -- Spawn the Sea of Azov navy
    -- for i=1, 4 do
        -- local zone_index = math.random(2)
        -- local zone = ZONE:New("Naval" .. zone_index)

        -- Spawn a oil platform as well
        -- local static = PlatformGroupSpawn[1]:SpawnFromPointVec2(zone:GetRandomPointVec2(), 0)
        -- local callsign = getCallsign()
        -- AddNavalStrike("Russian Theater")(STATIC:FindByName(static:getName()), "Oil Platform", callsign)
    -- end

    AirbaseSpawns[AIRBASE.Caucasus.Krasnodar_Pashkovsky][1]:Spawn()
    NWFARPDEF:Spawn()
    SWFARPDEF:Spawn()
    NEFARPDEF:Spawn()
    SEFARPDEF:Spawn()
    MKFARPDEF:Spawn()

    -- Disable slots
    trigger.action.setUserFlag("Novoro Huey 1",100)
    trigger.action.setUserFlag("Novoro Huey 2",100)
    trigger.action.setUserFlag("Novoro Mi-8 1",100)
    trigger.action.setUserFlag("Novoro Mi-8 2",100)

    trigger.action.setUserFlag("Krymsk Huey 1",100)
    trigger.action.setUserFlag("Krymsk Huey 2",100)
    trigger.action.setUserFlag("Krymsk Mi-8 1",100)
    trigger.action.setUserFlag("Krymsk Mi-8 2",100)

    trigger.action.setUserFlag("Krymsk Gazelle M",100)
    trigger.action.setUserFlag("Krymsk Gazelle L",100)

    trigger.action.setUserFlag("Krasnador Huey 1",100)
    trigger.action.setUserFlag("Krasnador Huey 2",100)
    trigger.action.setUserFlag("Kras Mi-8 1",100)
    trigger.action.setUserFlag("Kras Mi-8 2",100)

    trigger.action.setUserFlag("Krasnador2 Huey 1",100)
    trigger.action.setUserFlag("Krasnador2 Huey 2",100)
    trigger.action.setUserFlag("Kras2 Mi-8 1",100)
    trigger.action.setUserFlag("Kras2 Mi-8 2",100)

    -- FARPS
    trigger.action.setUserFlag("SWFARP Huey 1",100)
    trigger.action.setUserFlag("SWFARP Huey 2",100)
    trigger.action.setUserFlag("SWFARP Mi-8 2",100)
    trigger.action.setUserFlag("SWFARP Mi-8 2",100)

    trigger.action.setUserFlag("SEFARP Gazelle M",100)
    trigger.action.setUserFlag("SEFARP Gazelle L",100)

    trigger.action.setUserFlag("NWFARP Huey 1",100)
    trigger.action.setUserFlag("NWFARP Huey 2",100)
    trigger.action.setUserFlag("SWFARP Mi-8 2",100)
    trigger.action.setUserFlag("SWFARP Mi-8 2",100)

    trigger.action.setUserFlag("NEFARP Huey 1",100)
    trigger.action.setUserFlag("NEFARP Huey 2",100)
    trigger.action.setUserFlag("SWFARP Mi-8 2",100)
    trigger.action.setUserFlag("SWFARP Mi-8 2",100)

    trigger.action.setUserFlag("SEFARP Huey 1",100)
    trigger.action.setUserFlag("SEFARP Huey 2",100)
    trigger.action.setUserFlag("SWFARP Mi-8 2",100)
    trigger.action.setUserFlag("SWFARP Mi-8 2",100)

    trigger.action.setUserFlag("NWFARP KA50",100)
    trigger.action.setUserFlag("SEFARP KA50",100)

    trigger.action.setUserFlag("MK FARP Ka-50", 100)
end

-- Kick off the commanders
SCHEDULER:New(nil, function()
    log("Starting Russian Commander, Comrade")
    pcall(russian_commander)
    --russian_commander()
end, {}, 10, 600)

-- Kick off the supports
RussianTheaterAWACSSpawn:SpawnScheduled(1200, 0)
RussianTheaterAWACSPatrol:SpawnScheduled(1200, 0)
OverlordSpawn:SpawnScheduled(600, 0)
RUSTankerSpawn:SpawnScheduled(1200, 0)
TexacoSpawn:SpawnScheduled(600, 0)
ShellSpawn:SpawnScheduled(600, 0)
RussianTheaterCASSpawn:SpawnScheduled(1400, 0)

buildHitEvent(GROUP:FindByName("FARP DEFENSE #003"), "NE FARP")
buildHitEvent(GROUP:FindByName("FARP DEFENSE"), "NW FARP")
buildHitEvent(GROUP:FindByName("FARP DEFENSE #002"), "SE FARP")
buildHitEvent(GROUP:FindByName("FARP DEFENSE #001"), "SW FARP")

BASE:I("HOGGIT GAW - INIT COMPLETE")
BASE:TraceOnOff( false )
BASE:TraceAll( false )
log("init.lua complete")
