local statefile = io.open(lfs.writedir() .. "Scripts\\GAW2\\state.json", 'r')

-- Enable slotblock
trigger.action.setUserFlag("SSB",100)
if statefile then
    local ab_logi_slots = {
        ['Sochi-Adler'] = LogiAdlerSpawn,
        ['Gudauta'] = LogiGudautaSpawn,
        ['Mineralnye Vody'] = LogiVodySpawn,
        ['FARP ALPHA'] = LogiFARPALPHASpawn,
        ['FARP BRAVO'] = LogiFARPBRAVOSpawn,
        ['FARP CHARLIE'] = LogiFARPCHARLIESpawn,
        ['FARP DELTA'] = LogiFARPDELTASpawn
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
            BlueSecurityForcesGroups[name] = AirfieldDefense:SpawnAtPoint({
                x = posx,
                y = posy
            })

            posx = posx + math.random(100, 200)
            posy = posy + math.random(100, 200)
            BlueFarpSupportGroups[name] = FSW:SpawnAtPoint({x=posx, y=posy})
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
        local spawns = {FARPALPHADEF, FARPBRAVODEF, FARPCHARLIEDEF, FARPDELTADEF}
        game_state["Theaters"]["Russian Theater"]["FARPS"][name] = coalition

        if coalition == 1 then
            spawns[math.random(4)]:SpawnAtPoint({x = apV3.x, y= apV3.z})
            flagval = 100
        elseif coalition == 2 then
            BlueSecurityForcesGroups[name] = AirfieldDefense:SpawnAtPoint(apV3)
            apV3.x = apV3.x + 50
            apV3.z = apV3.z - 50
            BlueFarpSupportGroups[name] = FSW:SpawnAtPoint({x=apV3.x, y=apV3.z}, true)
            flagval = 0

            if ab_logi_slots[name] then
                activateLogi(ab_logi_slots[name])
            end
        end

        for i,grp in ipairs(abslots[name]) do
            trigger.action.setUserFlag(grp, flagval)
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
        log('spawning ' .. data['spawn_name'])
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
        local zone = "SA6Zone"
        RussianTheaterSA6Spawn[1]:SpawnInZone(zone .. zone_index)
    end

    for i=1, 3 do
        if i < 3 then
            local zone_index = math.random(13)
            local zone = "SA10Zone"
            RussianTheaterSA10Spawn[1]:SpawnInZone(zone .. zone_index)
        end

        local zone_index = math.random(13)
        local zone = "SA10Zone"
        RussianTheaterEWRSpawn[1]:SpawnInZone(zone .. zone_index)

        local zone_index = math.random(13)
        local zone = "SA10Zone"
        RussianTheaterC2Spawn[1]:SpawnInZone(zone .. zone_index)
    end

    for i=1, 5 do
        SpawnStrikeTarget()
    end

    AirbaseSpawns["Nalchik"][1]:Spawn()
    FARPALPHADEF:Spawn()
    FARPBRAVODEF:Spawn()
    FARPCHARLIEDEF:Spawn()
    FARPDELTADEF:Spawn()

    for _,spawn in pairs(TheaterObjectives) do
      spawn:Spawn()
    end

    -- Make Sukhumi Red 
    AirbaseSpawns['Sukhumi-Babushara'][3]:Spawn()

    -- Disable slots
    trigger.action.setUserFlag("Sochi Mi8 1",100)
    trigger.action.setUserFlag("Sochi Mi8 2",100)
    trigger.action.setUserFlag("Sochi UH-1H 1",100)
    trigger.action.setUserFlag("Sochi UH-1H 2",100)
    trigger.action.setUserFlag("Sochi Ka50",100)
    trigger.action.setUserFlag("Sochi SA342M",100)
    trigger.action.setUserFlag("Sochi SA342Mistral",100)

    trigger.action.setUserFlag("Gudauta Mi8 1",100)
    trigger.action.setUserFlag("Gudauta Mi8 2",100)
    trigger.action.setUserFlag("Gudauta Mi8 3",100)
    trigger.action.setUserFlag("Gudauta Mi8 4",100)
    trigger.action.setUserFlag("Gudauta UH-1H 1",100)
    trigger.action.setUserFlag("Gudauta UH-1H 2",100)
    trigger.action.setUserFlag("Gudauta Ka50",100)
    trigger.action.setUserFlag("Gudauta SA342M",100)
    trigger.action.setUserFlag("Gudauta SA342Mistral",100)

    trigger.action.setUserFlag("Maykop North Mi8 1",100)
    trigger.action.setUserFlag("Maykop North Mi8 2",100)
    trigger.action.setUserFlag("Maykop North UH-1H 1",100)
    trigger.action.setUserFlag("Maykop North UH-1H 2",100)
    trigger.action.setUserFlag("Maykop North Ka50",100)
    trigger.action.setUserFlag("Maykop North SA342M",100)
    trigger.action.setUserFlag("Maykop North SA342Mistral",100)

    trigger.action.setUserFlag("Maykop South Mi8 1",100)
    trigger.action.setUserFlag("Maykop South Mi8 2",100)
    trigger.action.setUserFlag("Maykop South UH-1H 1",100)
    trigger.action.setUserFlag("Maykop South UH-1H 2",100)
    trigger.action.setUserFlag("Maykop South Ka50",100)
    trigger.action.setUserFlag("Maykop South SA342M",100)
    trigger.action.setUserFlag("Maykop South SA342Mistral",100)

    trigger.action.setUserFlag("Vody Ka50",100)
    trigger.action.setUserFlag("Vody Mi8 1",100)
    trigger.action.setUserFlag("Vody Mi8 2",100)
    trigger.action.setUserFlag("Vody Mi8 3",100)
    trigger.action.setUserFlag("Vody Mi8 4",100)
    trigger.action.setUserFlag("Vody UH-1H 1",100)
    trigger.action.setUserFlag("Vody UH-1H 2",100)
    trigger.action.setUserFlag("Vody UH-1H 3",100)
    trigger.action.setUserFlag("Vody UH-1H 4",100)
    trigger.action.setUserFlag("Vody A-10C",100)
    trigger.action.setUserFlag("Vody F-18",100)
    trigger.action.setUserFlag("Vody Su25T",100)


    trigger.action.setUserFlag("FARP Alpha Mi8 1",100)
    trigger.action.setUserFlag("FARP Alpha Mi8 2",100)
    trigger.action.setUserFlag("FARP Alpha UH-1H 1",100)
    trigger.action.setUserFlag("FARP Alpha UH-1H 2",100)


    trigger.action.setUserFlag("FARP Bravo Ka50",100)
    trigger.action.setUserFlag("FARP Bravo SA342M",100)
    trigger.action.setUserFlag("FARP Bravo SA342Mistral",100)
    trigger.action.setUserFlag("FARP Bravo Mi8 1",100)
    trigger.action.setUserFlag("FARP Bravo Mi8 2",100)
    trigger.action.setUserFlag("FARP Bravo UH-1H 1",100)
    trigger.action.setUserFlag("FARP Bravo UH-1H 2",100)

    trigger.action.setUserFlag("FARP Charlie Ka50",100)
    trigger.action.setUserFlag("FARP Charlie SA342M",100)
    trigger.action.setUserFlag("FARP Charlie SA342Mistral",100)
    trigger.action.setUserFlag("FARP Charlie Mi8 1",100)
    trigger.action.setUserFlag("FARP Charlie Mi8 2",100)
    trigger.action.setUserFlag("FARP Charlie UH-1H 1",100)
    trigger.action.setUserFlag("FARP Charlie UH-1H 2",100)


    trigger.action.setUserFlag("FARP Delta Ka50",100)
    trigger.action.setUserFlag("FARP Delta SA342M",100)
    trigger.action.setUserFlag("FARP Delta SA342Mistral",100)
    trigger.action.setUserFlag("FARP Delta Mi8 1",100)
    trigger.action.setUserFlag("FARP Delta Mi8 2",100)
    trigger.action.setUserFlag("FARP Delta Mi8 3",100)
    trigger.action.setUserFlag("FARP Delta Mi8 4",100)
    trigger.action.setUserFlag("FARP Delta Harrier",100)
    trigger.action.setUserFlag("FARP Delta UH-1H 1",100)
    trigger.action.setUserFlag("FARP Delta UH-1H 2",100)
    trigger.action.setUserFlag("FARP Delta UH-1H 3",100)
    trigger.action.setUserFlag("FARP Delta UH-1H 4",100)
    trigger.action.setUserFlag("FARP Delta UH-1H 5",100)
    trigger.action.setUserFlag("FARP Delta UH-1H 6",100)
end

-- Kick off supports
mist.scheduleFunction(function()
    -- Friendly
    TexacoSpawn:Spawn()
    ShellSpawn:Spawn()
    ArcoSpawn:Spawn()
    OverlordSpawn:Spawn()

    -- Enemy
    RussianTheaterAWACSSpawn:Spawn()
end, {}, timer.getTime() + 10)

mist.scheduleFunction(function()
  RussianTheaterCASSpawn:Spawn()
  RussianTheaterSOUTHCASSpawn:Spawn()
end, {}, timer.getTime() + 10, 1800)

-- Kick off the commanders
mist.scheduleFunction(russian_commander, {}, timer.getTime() + 10, 600)
log("init.lua complete")
