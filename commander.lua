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
	local ewrs = game_state["Theaters"]["Russian Theater"]["EWR"]
	local striketargets = game_state["Theaters"]["Russian Theater"]["StrikeTargets"]
    local last_cap_spawn = game_state["Theaters"]["Russian Theater"]["last_cap_spawn"]
    local random_cap = 0
    local adcap_chance = 0.4
	local aliveAWACs = 0
	local aliveEWRs = 0
	local aliveAmmoDumps = 0
    local alivec2s = 0
    local alive_caps = 0
    local max_caps = 3
	local nominal_c2s = 4
	local nominal_awacs = 1 --deemed the nominal quantity for 'baseline' operations
	local nominal_ammodumps = 3 --deemed the nominal quantity for 'baseline' operations
	local nominal_ewrs = 2 --deemed the nominal quantity for 'baseline' operations
	local p_spawn_mig31s = 0.95 --Old baseline constant from prior commander
	local p_attack_airbase = 0.2 --Old baseline constant from prior commander
	local p_spawn_airbase_cap = 0.7 --Old baseline constant from prior commander

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
        max_caps = 4
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

	
	-- Get the number of EWRs in existence, as we use this for determination of spawn rates
	for group_name, group_table in pairs(ewrs) do
		aliveEWRs = aliveEWRs + 1
	end
	
	log("Russian commander has " .. aliveEWRs .. " EWRs available...")
	
	-- Get the number of ammo dumps in existence, as we use this for determination of spawn rates
	for group_name, group_table in pairs(striketargets) do
		if group_table['spawn_name'] == 'AmmoDump' then aliveAmmoDumps = aliveAmmoDumps + 1 end
	end

	log("Russian commander has " .. aliveAmmoDumps .. " Ammo Dumps available...")
    
    -- Get alive caps and cleanup state
    for i=#caps, 1, -1 do
        local cap = Group.getByName(caps[i])
        if cap and isAlive(cap) then
            if allOnGround(cap) then
                cap:destroy()
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

    log("The Russian commander has " .. alive_bai_targets .. " ground squads alive.")

    --if alivec2s == 0 then log('Russian commander whispers "BLYAT!" and runs for the hills before he ends up in a gulag.'); return nil end

	
    -- Setup some decision parameters based on how many c2's are alive
	p_attack_airbase = 0.1 + 0.1*(aliveAmmoDumps/nominal_ammodumps) + 0.1*(alivec2s/nominal_c2s)
	p_spawn_mig31s = 0.65 + 0.1*(aliveEWRs/nominal_ewrs) + 0.1*(alivec2s/nominal_c2s)
	p_spawn_airbase_cap = 0.5 + 0.2*(aliveAmmoDumps/nominal_ammodumps)
	
    if alivec2s == 3 then random_cap = 30 end
    if alivec2s == 2 then random_cap = 60; adcap_chance = 0.4 end
    if alivec2s == 1 then random_cap = 120 adcap_chance = 0.8 end
    local command_delay = math.random(10, random_cap)
    log("The Russian commander has a command delay of " .. command_delay .. " and a " .. (adcap_chance * 100) .. "% chance of getting decent planes...")

    if alive_caps < max_caps then
        log("The Russian commander is going to request " .. (max_caps - alive_caps) .. " additional CAP units.")
        for i = alive_caps + 1, max_caps do
            mist.scheduleFunction(function()
                if math.random() < adcap_chance then
                    -- Spawn fancy planes, 70% chance they come from airbase, otherwise they come from "off theater"
                    local capspawn = goodcaps[math.random(#goodcaps)]
                    if math.random() < p_spawn_airbase_cap then
                        capspawn = goodcapsground[math.random(#goodcaps)]
                        capspawn:Spawn()
                        log("The Russian commander is getting a fancy plane from his local airbase")
                    else
                        capspawn:Spawn()
                        log("The Russian commander is getting a fancy plane from a southern theater.")
                    end
                else
                    -- Spawn same ol crap
                    local capspawn = poopcaps[math.random(#poopcaps)]
                    if math.random() < p_spawn_airbase_cap then
                        capspawn = poopcapsground[math.random(#poopcaps)]
                        capspawn:Spawn()
                        log("The Russian commander is getting a poopy plane from his local airbase")
                    else
                        capspawn:Spawn()
                        log("The Russian commander is getting a poopy plane from a southern theater, thanks Ivan you piece of...")
                    end
                end
            end, {}, timer.getTime() + command_delay)
        end
    end

    if alive_bai_targets < max_bai then
        log("The Russian Commander is going to request " .. (max_bai - alive_bai_targets) .. " additional strategic ground units")
        for i = alive_bai_targets + 1, max_bai do
            mist.scheduleFunction(function()
                local baispawn = baispawns[math.random(#baispawns)][1]
                local zone_index = math.random(13)
                local zone = "NorthCAS" .. zone_index
                baispawn:SpawnInZone(zone)
            end, {}, timer.getTime() + command_delay)
        end
    end

    log("Checking interceptors...")
    if math.random() < p_spawn_mig31s then
        for i,g in ipairs(enemy_interceptors) do
            if allOnGround(g) then
                Group.getByName(g):destroy()
            end

            if not isAlive(g) then
                enemy_interceptors = {}
            end
        end

        if #enemy_interceptors == 0 then
            RussianTheaterMig312ShipSpawn:Spawn()
        end
    end
    log("The commander has " .. #enemy_interceptors .. " alive")


    for i,target in ipairs(AttackableAirbases(Airbases)) do
        log("The Russian commander has decided to strike " .. target .. " airbase")
        if not AirfieldIsDefended("airfield-defense-chk" .. target) then
            if math.random() < p_attack_airbase then
                log(target .. " appears undefended! Muahaha!")
                local spawn = SpawnForTargetAirbase(target)
                spawn:Spawn()
            end
        end
    end
end

log("commander.lua complete")
