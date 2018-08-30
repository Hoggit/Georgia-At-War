-- Main game loop, decision making about spawns happen here.
russian_commander = function()
    -- Russian Theater Decision Making
    log("Russian commander is thinking...")
    local bluePlanes = mist.makeUnitTable({'[blue][plane]'})
    local bluePlaneCount = 0
    for i,v in pairs(bluePlanes) do
        if Unit.getByName(v) then bluePlaneCount = bluePlaneCount + 1 end
    end
    local time = timer.getAbsTime() + env.mission.start_time
    local c2s = game_state["Theaters"]["Russian Theater"]["C2"]
    local caps = game_state["Theaters"]["Russian Theater"]["CAP"]
    local castargets = game_state["Theaters"]["Russian Theater"]["CASTargets"]
    local baitargets = game_state["Theaters"]["Russian Theater"]["BAI"]
    local last_cap_spawn = game_state["Theaters"]["Russian Theater"]["last_cap_spawn"]
    local random_cap = 0
    local adcap_chance = 0.4
    local alivec2s = 0
    local alive_caps = 0
    local max_caps = 3

    if bluePlaneCount < 13 then
        max_caps = 1
    end

    if bluePlaneCount > 13 then
        max_caps = 2
    end

    if bluePlaneCount > 18 then
        max_caps = 3
    end

    if bluePlaneCount > 28 then
        max_caps = 5
    end

    log("There are " .. bluePlaneCount .. " blue planes in the mission, so we'll spawn a max of " .. max_caps .. " groups of enemy CAP")

    local alive_bai_targets = 0

    local max_bai = 5

    -- Get the number of C2s in existance, and cleanup the state for dead ones.
    -- We'll make some further determiniation of what happens based on this
    for group_name, group_table in pairs(c2s) do
        alivec2s = alivec2s + 1
    end

    log("Russian commander has " .. alivec2s .. " command posts available...")

    -- Get alive caps and cleanup state
    for i=#caps, 1, -1 do
        local cap = GROUP:FindByName(caps[i])
        if cap and cap:IsAlive() then
            if cap:AllOnGround() then
                cap:Destroy()
                log("Found inactive cap, removing")
                table.remove(caps, i)
            else
                alive_caps = alive_caps + 1
            end
        else
            table.remove(caps, i)
        end
    end


    log("The Russian commander has " .. alive_caps .. " flights alive")
    -- Get Alive BAI Targets
    for group_name, baitarget_table in pairs(baitargets) do
        alive_bai_targets = alive_bai_targets + 1
    end

    --if alivec2s == 0 then log('Russian commander whispers "BLYAT!" and runs for the hills before he ends up in a gulag.'); return nil end

    -- Setup some decision parameters based on how many c2's are alive
    if alivec2s == 3 then random_cap = 30 end
    if alivec2s == 2 then random_cap = 60; adcap_chance = 0.4 end
    if alivec2s == 1 then random_cap = 120 adcap_chance = 0.8 end
    local command_delay = math.random(10, random_cap)
    log("The Russian commander has a command delay of " .. command_delay .. " and a " .. (adcap_chance * 100) .. "% chance of getting decent planes...")

    if alive_caps < max_caps then
        log("The Russian commander is going to request " .. (max_caps - alive_caps) .. " additional CAP units.")
        for i = alive_caps + 1, max_caps do
            SCHEDULER:New(nil, function()
                if math.random() < adcap_chance then
                    -- Spawn fancy planes, 70% chance they come from airbase, otherwise they come from "off theater"
                    local capspawn = goodcaps[math.random(#goodcaps)]
                    if math.random() > 0.3 then
                        capspawn:SpawnAtAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Maykop_Khanskaya), SPAWN.Takeoff.Cold)
                        log("The Russian commander is getting a fancy plane from his local airbase")
                    else
                        capspawn:Spawn()
                        log("The Russian commander is getting a fancy plane from a southern theater")
                    end
                else
                    -- Spawn same ol crap
                    local capspawn = poopcaps[math.random(#poopcaps)]
                    if math.random() > 0.3 then
                        capspawn:SpawnAtAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Maykop_Khanskaya), SPAWN.Takeoff.Cold)
                        log("The Russian commander is getting a poopy plane from his local airbase")
                    else
                        capspawn:Spawn()
                        log("The Russian commander is getting a poopy plane from a southern theater, thanks Ivan you piece of...")
                    end
                end
            end, {}, command_delay)
        end
    end

    if alive_bai_targets < max_bai then
        log("The Russian Commander is going to request " .. (max_bai - alive_bai_targets) .. " additional strategic ground units")
        for i = alive_bai_targets + 1, max_bai do
            SCHEDULER:New(nil, function()
                local baispawn = baispawns[math.random(#baispawns)][1]
                local zone_index = math.random(13)
                local zone = ZONE:New("NorthCAS" .. zone_index)
                baispawn:SpawnInZone(zone, true)
            end, {}, command_delay)
        end
    end

    if math.random() > 0.8 then
        local g = RussianTheaterMig312ShipSpawn:GetFirstAliveGroup()
        if g then
            if g:AllOnGround() then
                g:Destroy()
            end
        end

        RussianTheaterMig312ShipSpawn:Spawn()
    end

    for i,target in pairs(AttackableAirbases(Airbases)) do
        log("The Russian commander has decided to strike " .. target[1] .. " airbase")
        if not AirfieldIsDefended(target[2]) then
            if math.random() > 0.8 then
                log(target[1] .. " appears undefended! Muahaha!")
                local spawn = SpawnForTargetAirbase(target[1])
                spawn:Spawn()
            end
        end
    end
end

log("commander.lua complete")
