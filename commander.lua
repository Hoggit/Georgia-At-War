-- Main game loop, decision making about spawns happen here.
russian_commander = function()
    -- Russian Theater Decision Making
    log("Russian commander is thinking...")
    local time = timer.getAbsTime() + env.mission.start_time
    local c2s = game_state["Theaters"]["Russian Theater"]["C2"]
    local caps = game_state["Theaters"]["Russian Theater"]["CAP"]
    local castargets = game_state["Theaters"]["Russian Theater"]["CASTargets"]
    local baitargets = game_state["Theaters"]["Russian Theater"]["BAI"]
    local last_cap_spawn = game_state["Theaters"]["Russian Theater"]["last_cap_spawn"]
    local random_cap = 0
    local adcap_chance = 0.2
    local alivec2s = 0
    local alive_caps = 0
    local alive_bai_targets = 0

    -- Get the number of C2s in existance, and cleanup the state for dead ones.
    -- We'll make some further determiniation of what happens based on this
    for i,v in ipairs(c2s) do
        if v:IsAlive() then
            alivec2s = alivec2s + 1
        else
            table.remove(c2s, i)
        end
    end

    log("Russian commander has " .. alivec2s .. " command posts available...")

    -- Get alive caps and cleanup state
    for i,v in ipairs(caps) do
        if v:IsAlive() then
            alive_caps = alive_caps + 1
        else
            table.remove(caps, i)
        end
    end

    -- Get Alive BAI Targets and cleanup state
    for i,v in ipairs(baitargets) do
        -- Destroy the group if less than 30% remain
        if v:IsAlive() then
            local alive_units = 0
            for UnitID, UnitData in pairs(v:GetUnits()) do
                if UnitData:IsAlive() then
                    alive_units = alive_units + 1
                end
            end

            if alive_units / v:InitialSize() * 100 < 30 then
                v:Destroy()
                table.remove(baitargets, i)
            else
                alive_bai_targets = alive_bai_targets + 1
            end
        else
            table.remove(baitargets, i)
        end
    end

    -- If there are no more alive C2s then nothign new can happen, the units out there are completely on their own
    if alivec2s == 0 then log('Russian commander whispers "BLYAT!" and runs for the hills before he ends up in a gulag.'); return nil end

    -- Setup some decision parameters based on how many c2's are alive
    if alivec2s == 3 then random_cap = 60 end
    if alivec2s == 2 then random_cap = 300; adcap_chance = 0.4 end
    if alivec2s == 1 then random_cap = 600 adcap_chance = 0.8 end
    local command_delay = math.random(10, random_cap)
    log("The Russian commander has a command delay of " .. command_delay .. " and a " .. (adcap_chance * 100) .. "% chance of getting decent planes...")

    if alive_caps < 3 then
        log("The Russian commander is going to request " .. (3 - alive_caps) .. " additional CAP units.")
        for i = alive_caps + 1, 3 do
            SCHEDULER:New(nil, function()
                if math.random() < adcap_chance then
                    -- Spawn fancy planes, 70% chance they come from airbase, otherwise they come from "off theater"
                    if math.random() > 0.3 then
                        RussianTheaterMig292ShipSpawn:SpawnAtAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Maykop_Khanskaya), SPAWN.Takeoff.Cold)
                        log("The Russian commander is getting a fancy MIG29 from his local airbase")
                    else
                        RussianTheaterMig292ShipSpawn:Spawn()
                        log("The Russian commander is getting a fancy MIG29 from a southern theater")
                    end
                else
                    -- Spawn same ol crap
                    if math.random() > 0.3 then
                        RussianTheaterMig212ShipSpawn:SpawnAtAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Maykop_Khanskaya), SPAWN.Takeoff.Cold)
                        log("The Russian commander is getting a poopy MIG21 from his local airbase")
                    else
                        RussianTheaterMig212ShipSpawn:Spawn()
                        log("The Russian commander is getting a poopy MIG21 from a southern theater, thanks Ivan you piece of...")
                    end
                end
            end, {}, command_delay)
        end
    end

    if alive_bai_targets < 3 then
        log("The Russian Commander is going to request " .. (3 - alive_bai_targets) .. " additional strategic ground units")
        for i = alive_bai_targets + 1, 3 do
            SCHEDULER:New(nil, function()
                local zone_index = math.random(13)
                local zone = ZONE:New("NorthCAS" .. zone_index)
                RussianHeavyArtySpawn:SpawnInZone(zone, true)
            end, {}, command_delay)
        end
    end
end

log("commander.lua complete")