--[[
--  TODO: convert to using spawn queues combined with scheduled function
--        it is more efficient and resource management is easier.
--
--  Example:
--      given a CAP spawn priority queue
--
--      allows to easily determine if CAPs have already been requested
--      by checking the depth of the queue, since no newly requested
--      CAP can possibly arrive before the already requested ones there
--      is no point in requesting more if alive + queued == 1.2 * max.
--
--      since spawn objects can be treated polymorphicly a global spawn
--      queue can be used to control resource creation and prevent spawn
--      flooding
--]]

max_caps_for_player_count = function(players)
    if players == nil then
      players = get_player_count()
    end
    local caps = 0

    if players < 13 then
        caps = 1
    elseif players >= 13 and players < 18 then
        caps = 2
    elseif players >= 18 and players < 28 then
        caps = 3
    else
        caps = 4
    end
    return caps
end

get_player_count = function()
    local bluePlanes = mist.makeUnitTable({'[blue][plane]'})
    local bluePlaneCount = 0
    for i,v in pairs(bluePlanes) do
        if Unit.getByName(v) then bluePlaneCount = bluePlaneCount + 1 end
    end
    return bluePlaneCount
end

--[[
--  Utility here is rooted in the concepts of utility theory.
--
--  c2_utility - represents the command efficiency over a theater
--      Simply put as command installations are taken out it becomes
--      increasingly harder for the AI commander it issue orders and receive
--      timely intel to make decisions. The reason a rotate quadratic curve was
--      used is used to depict the non-linear fall-off nature of what happened
--      in the real world when commands are taken out but there is enough
--      redundancy in the system that the fall-off is not quite linear.
--
--  radar_utility - represents the raw radar coverage of the ewr in theater
--      AWACS are effectively worth two EWR sites and the sum of the two are
--      multiplied by 3/4ths to represent ground masking due to placement
--      (blind spots) in the radar coverage.
--
--  logistics_utility - represents how well the enemy can supply itself with
--      its remaining ammo dumps
--      A logistics function is used to simply not have a linear fall-off, it
--      is also a nice representation that of how travel times are non-linear.
--
--  comms_utility - a simple linear representation of the ability for the emeny
--      to communicate.
--
--  detection_efficiency - the combination of command and control capability and
--      radar coverage. If either type of asset still exists some amount of
--      detection is still possible, however, the moment one is completely
--      wiped out detection should no longer be possible. This is suppose to
--      represent a central command and control type organization. Which was a
--      Russian doctrinal mainstay during the cold war.
--
--  airbase_attack - the ability to conduct airstrikes
--      As ammo dumps are hit fewer and fewer resources will be allocated to
--      airstrikes until all command assets are taken out.
--
--  command_delay - is simply the inverse of command_efficiency (c2_utility)
--      As command efficiency reduces the delay for command to issue new orders
--      increases.
--]]

c2_utility = function(stats)
    return (math.pow(stats.c2.alive/stats.c2.nominal, 1/2))
end

radar_utility = function(stats)
    return (.75 * ((stats.ewr.alive/stats.ewr.nominal) +
                    (2*stats.awacs.alive)/stats.ewr.nominal))
end

logistics_utility = function(stats)
    return (1/(1+math.exp(-2*(stats.ammo.alive - stats.ammo.nominal/2))))
end

comms_utility = function(stats)
    return (stats.comms.alive/stats.comms.nominal)
end

detection_efficiency = function(c2s, radar)
    return clamp(c2s * radar, 0, 1)
end

airbase_attack = function(c2s, logistics)
    if c2s < 0.10 then
        return 0
    end
    return logistics
end

command_delay = function(util, min, max)
    return clamp((1-util) * max, min, max)
end

calculate_utilities = function(stats)
    local utils = {
        command_efficiency   = c2_utility(stats),
        radar_coverage       = radar_utility(stats),
        logistics            = logistics_utility(stats),
        comms                = comms_utility(stats),
        detection_efficiency = 0,
        airbase_strike       = 0,
    }

    utils.detection_efficiency =
        detection_efficiency(utils.command_efficiency,
                             utils.radar_coverage)
    utils.airbase_strike =
        airbase_attack(utils.command_efficiency,
                       utils.logistics)
    return utils
end

spawn_cap = function(spawn)
    local stats = GameStats:get()
    if stats.caps.alive >= stats.caps.nominal then
        return
    end
    spawn:Spawn()
end

request_cap = function(caps, time, utils)
    if caps.alive >= caps.nominal then
        return
    end

    local delay = {
        airbase = {
            max   =  360,
            min   =  180,
            sigma =   60,
        },
        offmap = {
            max   = 1800,
            min   =  600,
            sigma =  180,
        },
    }
    local spawn = 0
    local d = 0

    log("Russian Commander is going to request " ..
        (caps.nominal - caps.alive) .. " additional CAP units.")

    for i = caps.alive + 1, caps.nominal do
        if utils.command_efficiency < .6 and utils.comms > 0 then
            d = time + command_delay(utils.detection_efficiency,
                                     delay.offmap.min,
                                     delay.offmap.max)
            d = addstddev(d, delay.offmap.sigma)
            if math.random() < utils.comms * .75 then
                spawn = goodcaps[math.random(#goodcaps)]
            else
                spawn = poopcaps[math.random(#poopcaps)]
            end
        else
            d = time + command_delay(utils.detection_efficiency,
                                     delay.airbase.min,
                                     delay.airbase.max)
            d = addstddev(d, delay.airbase.sigma)
            if math.random() < utils.logistics then
                spawn = goodcapsground[math.random(#goodcapsground)]
            else
                spawn = poopcapsground[math.random(#poopcapsground)]
            end
        end
        mist.scheduleFunction(spawn_cap, {spawn}, d)
    end
end

spawn_bai = function()
    local stats = GameStats:get()
    if stats.bai.alive >= stats.bai.nominal then
        return
    end

    local baispawn = baispawns[math.random(#baispawns)][1]
    local zone_index = math.random(13)
    local zone = "NorthCAS" .. zone_index
    baispawn:SpawnInZone(zone)
end

request_bai = function(bai, time, utils)
    local delay_max = 1200
    local delay_min = 180
    local sigma = 60
    local delay = time + command_delay(utils.command_efficiency, delay_min, delay_max)

    if bai.alive < bai.nominal then
        log("Russian Commander is going to request " ..
            (bai.nominal - bai.alive) ..
            " additional strategic ground units")
        for i = bai.alive + 1, bai.nominal do
            mist.scheduleFunction(spawn_bai, {}, addstddev(delay, sigma))
        end
    end
end

log_cmdr_stats = function(stats)
    log("Russian commander has " .. stats.bai.alive   .. " ground squads alive.")
    log("Russian commander has " .. stats.ewr.alive   .. " EWRs available.")
    log("Russian commander has " .. stats.c2.alive    .. " command posts available.")
    log("Russian commander has " .. stats.ammo.alive  .. " Ammo Dumps available.")
    log("Russian commander has " .. stats.comms.alive .. " Comms Arrays available.")
    log("Russian commander has " .. stats.caps.alive  .. " flights alive.")
end

-- Main game loop, decision making about spawns happen here.
russian_commander = function()
    log("Russian commander is thinking...")

    local time = timer.getTime()
    local stats = GameStats:get()
    local utils = calculate_utilities(stats)

    log_cmdr_stats(stats)

    request_bai(stats.bai,  time, utils)
    request_cap(stats.caps, time, utils)

    if #enemy_interceptors == 0 and
       math.random() < utils.detection_efficiency then
        RussianTheaterMig312ShipSpawn:Spawn()
    end
    log("The commander has " .. #enemy_interceptors .. " alive")

    for i,target in ipairs(AttackableAirbases(Airbases)) do
        if not AirfieldIsDefended("DefenseZone" .. target) then
            if utils.airbase_strike and
               math.random() < utils.airbase_strike then
                log("Russian commander has decided to strike " ..
                    target .. " airbase")
                local spawn = SpawnForTargetAirbase(target)
                spawn:Spawn()
            end
        end
    end

    --VIP Spawn Chance
    local VIPChance = 0.1
    if math.random() >= (1 - VIPChance) then
      log("Spawning russian VIP transport")
      SpawnVIPTransport()
    end
end

log("commander.lua complete")
