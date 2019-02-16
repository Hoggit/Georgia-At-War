local statefile = io.open(lfs.writedir() .. "Scripts\\GAW\\state.json", 'r')

-- Enable slotblock
trigger.action.setUserFlag("SSB",100)
if statefile then
    local ab_logi_slots = {
        ["Novorossiysk"] = NovoLogiSpawn,
        ["Gelendzhik"] = nil,
        ["Krymsk"] = KryLogiSpawn,
        ["Krasnodar-Center"] = KrasCenterLogiSpawn,
        ["Krasnodar-Pashkovsky"] = nil,
    }

    trigger.action.outText("Found a statefile.  Processing it instead of starting a new game", 40)
    local state = statefile:read("*all")
    statefile:close()
    local saved_game_state = json:decode(state)
    trigger.action.outText("Game state read", 10)
    for name, coalition in pairs(saved_game_state["Theaters"]["Russian Theater"]["Airfields"]) do
        local flagval = 100
        local ab = Airbase.getByName(name)
        local apV3 = ab:getPosition().p
        local posx = apV3.x + math.random(800, 1000)
        local posy = apV3.z - math.random(100, 200)
        game_state["Theaters"]["Russian Theater"]["Airfields"][name] = coalition

        if coalition == 1 then
            if AirbaseSpawns[name] then
            AirbaseSpawns[name][3]:Spawn()
            flagval = 100
            end
        elseif coalition == 2 then
            AirfieldDefense:SpawnAtPoint({
                x = posx,
                y = posy
            })

            posx = posx + math.random(100, 200)
            posy = posy + math.random(100, 200)
            FSW:SpawnAtPoint({x=posx, y=posy})
            flagval = 0

            if ab_logi_slots[name] then
                activateLogi(ab_logi_slots[name])
            end
        end

        if abslots[name] then
          for i,grp in ipairs(abslots[name]) do
              trigger.action.setUserFlag(grp, flagval)
          end
        end
    end

    trigger.action.outText("Finished processing airfields", 10)

    for name, coalition in pairs(saved_game_state["Theaters"]["Russian Theater"]["FARPS"]) do
        local flagval = 100
        local ab = Airbase.getByName(name)
        local apV3 = ab:getPosition().p

        apV3.x = apV3.x + math.random(-25, 25)
        apV3.z = apV3.z + math.random(-25, 25)
        local spawns = {NWFARPDEF, SWFARPDEF, NEFARPDEF, SEFARPDEF}
        game_state["Theaters"]["Russian Theater"]["FARPS"][name] = coalition

        if coalition == 1 then
            spawns[math.random(4)]:SpawnAtPoint({x = apV3.x, y= apV3.z})
            flagval = 100
        elseif coalition == 2 then
            AirfieldDefense:SpawnAtPoint(apV3)
            apV3.x = apV3.x + 50
            apV3.z = apV3.z - 50
            FSW:SpawnAtPoint({x=apV3.x, y=apV3.z}, true)
            flagval = 0

            if ab_logi_slots[name] then
                activateLogi(ab_logi_slots[name])
            end
        end

        if abslots[name] then
          for i,grp in ipairs(abslots[name]) do
              trigger.action.setUserFlag(grp, flagval)
          end
        end

        if name == "MK Warehouse" and coalition == 2 then
            activateLogi(MaykopLogiSpawn)
        end

    end

    trigger.action.outText("Finished processing FARPs", 10)

    for name, data in pairs(saved_game_state["Theaters"]["Russian Theater"]["StrategicSAM"]) do
        local spawn
        if data.spawn_name == "SA6" then spawn = RussianTheaterSA6Spawn[1] end
        if data.spawn_name == "SA10" then spawn = RussianTheaterSA10Spawn[1] end
        spawn:SpawnAtPoint({
            x = data['position'].x,
            y = data['position'].z
        })
    end

    for name, data in pairs(saved_game_state["Theaters"]["Russian Theater"]["C2"]) do
        RussianTheaterC2Spawn[1]:SpawnAtPoint({
            x = data['position'].x,
            y = data['position'].z
        })
    end

    for name, data in pairs(saved_game_state["Theaters"]["Russian Theater"]["EWR"]) do
        RussianTheaterEWRSpawn[1]:SpawnAtPoint({
            x = data['position'].x,
            y = data['position'].z
        })
    end

    trigger.action.outText("Finished processing strategic assets", 10)

    for name, data in pairs(saved_game_state["Theaters"]["Russian Theater"]["StrikeTargets"]) do
        local spawn
        if data['spawn_name'] == 'AmmoDump' then spawn = AmmoDumpSpawn end
        if data['spawn_name'] == 'CommsArray' then spawn = CommsArraySpawn end
        if data['spawn_name'] == 'PowerPlant' then spawn = PowerPlantSpawn end
        local static = spawn:Spawn({
            data['position'].x,
            data['position'].z
        })
    end


    for name, data in pairs(saved_game_state["Theaters"]["Russian Theater"]["BAI"]) do
        local spawn
        if data['spawn_name'] == "ARTILLERY" then spawn = RussianHeavyArtySpawn[1] end
        if data['spawn_name'] == "ARMOR COLUMN" then spawn = ArmorColumnSpawn[1] end
        if data['spawn_name'] == "MECH INF" then spawn = MechInfSpawn[1] end
        local baitarget = spawn:SpawnAtPoint({
            x = data['position'].x,
            y = data['position'].z
        })
    end

    trigger.action.outText("Finished processing BAI", 10)

    local theaterobjs = saved_game_state["Theaters"]["Russian Theater"]["TheaterObjectives"]
    if theaterobjs ~= nil then
      for name, data in pairs(saved_game_state["Theaters"]["Russian Theater"]["TheaterObjectives"]) do
        local spawner = TheaterObjectives[name]
        if not spawner then
          log("Found TheaterObjective " .. name .. " but no spawner for it!")
        else
          log(" Spawning TheaterObjective " .. name)
          spawner:Spawn()
        end
      end
    end

    for idx, data in ipairs(saved_game_state["Theaters"]["Russian Theater"]["CTLD_ASSETS"]) do
        if data.name == 'avenger' then
            avengerspawn:SpawnAtPoint({
                x = data.pos.x,
                y = data.pos.z
            })
        end

        if data.name == 'ammo' then
            ammospawn:SpawnAtPoint({
                x = data.pos.x,
                y = data.pos.z
            })
        end

        if data.name == 'gepard' then
            gepardspawn:SpawnAtPoint({
                x = data.pos.x,
                y = data.pos.z
            })
        end

        if data.name == 'mlrs' then
            mlrsspawn:SpawnAtPoint({
                x = data.pos.x,
                y = data.pos.z
            })
        end

        if data.name == 'jtac' then
            local _spawnedGroup = jtacspawn:SpawnAtPoint({
                x = data.pos.x,
                y = data.pos.z
            })
              local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
              table.insert(ctld.jtacGeneratedLaserCodes, _code)
              ctld.JTACAutoLase(_spawnedGroup:getName(), _code)
            end
        end

    local destroyedStatics = saved_game_state["Theaters"]["Russian Theater"]["DestroyedStatics"]
    if destroyedStatics ~= nil then
        for k, v in pairs(destroyedStatics) do
            local obj = StaticObject.getByName(k)
            if obj ~= nil then
                StaticObject.destroy(obj)
            end
        end
        game_state["Theaters"]["Russian Theater"]["DestroyedStatics"] = saved_game_state["Theaters"]["Russian Theater"]["DestroyedStatics"]
    end

    local CTLDstate = saved_game_state["Theaters"]["Russian Theater"]["Hawks"]
    if CTLDstate ~= nil then
        for k,v in pairs(CTLDstate) do
            respawnHAWKFromState(v)
        end
    end

    game_state["Theaters"]["Russian Theater"]["CTLD_ASSETS"] = saved_game_state["Theaters"]["Russian Theater"]["CTLD_ASSETS"]

else
    -- Populate the world and gameplay environment.
    trigger.action.outText("No state file detected.  Creating new situation", 10)
    for i=1, 4 do
        local zone_index = math.random(23)
        local zone = "NorthSA6Zone"
        RussianTheaterSA6Spawn[1]:SpawnInZone(zone .. zone_index)
    end

    for i=1, 3 do
        if i < 3 then
            local zone_index = math.random(8)
            local zone = "NorthSA10Zone"
            RussianTheaterSA10Spawn[1]:SpawnInZone(zone .. zone_index)
        end

        local zone_index = math.random(8)
        local zone = "NorthSA10Zone"
        RussianTheaterEWRSpawn[1]:SpawnInZone(zone .. zone_index)

        local zone_index = math.random(8)
        local zone = "NorthSA10Zone"
        RussianTheaterC2Spawn[1]:SpawnInZone(zone .. zone_index)
    end

    for i=1, 10 do
        local zone_index = math.random(18)
        local zone = "NorthStatic" .. zone_index
        local StaticSpawns = {AmmoDumpSpawn, PowerPlantSpawn, CommsArraySpawn}
        local spawn_index = math.random(3)
        local vec2 = mist.getRandomPointInZone(zone)
        local id = StaticSpawns[spawn_index]:Spawn({vec2.x, vec2.y})
    end


    AirbaseSpawns["Krasnodar-Pashkovsky"][1]:Spawn()
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

-- Kick off supports
mist.scheduleFunction(function()
    -- Friendly
    TexacoSpawn:Spawn()
    ShellSpawn:Spawn()
    OverlordSpawn:Spawn()

    -- Enemy
    RussianTheaterAWACSSpawn:Spawn()
end, {}, timer.getTime() + 10)

mist.scheduleFunction(function()
  RussianTheaterCASSpawn:Spawn()
  log("Spawned CAS Groups...")
end, {}, timer.getTime() + 10, 1800)
-- Kick off the commanders
mist.scheduleFunction(russian_commander, {}, timer.getTime() + 10, 600)
log("init.lua complete")
