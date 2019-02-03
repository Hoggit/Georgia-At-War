CLEANUP_PERIOD = 125
CLEANUP_CAP_PERIOD = 600
last_cap_cleanup_time = env.mission.start_time

function cleanup()
    log("Starting Cleanup BAI Targets")
    local current_time = timer.getAbsTime() + env.mission.start_time

    -- Get Alive BAI Targets and cleanup state
    local baitargets = game_state["Theaters"]["Russian Theater"]["BAI"]
    for group_name, baitarget_table in pairs(baitargets) do
        local baitarget = Group.getByName(group_name)
        if baitarget and isAlive(baitarget) then
            local alive_units = 0
            for UnitID, UnitData in pairs(baitarget:getUnits()) do
                if UnitData and UnitData:getLife() > 0 and UnitData:isExist() then
                    alive_units = alive_units + 1
                end
            end

            log("There are " .. alive_units .. " in BAI target " .. baitarget_table['callsign'])
            if alive_units == 0 or alive_units / baitarget:getInitialSize() * 100 < 30 then
                trigger.action.outText("BAI target " .. baitarget_table['callsign'] .. " destroyed!", 15)
                log("Not enough units, destroying")
                baitarget:destroy()
                baitargets[group_name] = nil
                GameStats:decrement("bai")
            end
        else
            --for i,rearm_spawn in ipairs(rearm_spawns) do
            --    rearm_spawn[1]:Spawn()
           -- end
            trigger.action.outText("BAI target " .. baitarget_table['callsign'] .. " destroyed!", 15)
            baitargets[group_name] = nil
            GameStats:decrement("bai")
        end
    end

    log("Starting Cleanup C2")
    -- Get the number of C2s in existance, and cleanup the state for dead ones.
    local c2s = game_state["Theaters"]["Russian Theater"]["C2"]
    for group_name, group_table in pairs(c2s) do
        local callsign = group_table['callsign']
        if groupIsDead(group_name) then
            trigger.action.outText("Mobile CP " .. group_table['callsign'] .. " destroyed!", 15)
            game_state["Theaters"]["Russian Theater"]["C2"][group_name] = nil
            GameStats:decrement("c2")
        end
    end

    log("Starting Strike Cleanup")
    -- Get the number of Strikes in existance, and cleanup the state for dead ones.
    local striketargets = game_state["Theaters"]["Russian Theater"]["StrikeTargets"]
    for group_name, group_table in pairs(striketargets) do
        local alive_units = 0
        for i,staticname in ipairs(group_table.statics) do
            local staticunit = StaticObject.getByName(staticname)
            if staticunit and staticunit:getLife() > 0 and staticunit:isExist() then
                alive_units = alive_units + 1
            end
        end

        if alive_units == 0 then
            trigger.action.outText("Strike Target " .. group_table['callsign'] .. " destroyed!", 15)
            game_state["Theaters"]["Russian Theater"]["StrikeTargets"][group_name] = nil
        else
            log(group_name .. " has " .. alive_units .. " buildings alive.")
        end
    end

    log("Starting Theater Objectives Cleanup")
    local theaterObjectives = game_state["Theaters"]["Russian Theater"]["TheaterObjectives"]
    for obj_name, obj in pairs(theaterObjectives) do
      log("Checking " .. obj_name .. " for removal")
      if not isAlive(obj.groupName) then
        game_state["Theaters"]["Russian Theater"]["TheaterObjectives"][obj_name] = nil
        MessageToAll(obj_name .. " has been destroyed!")
        log("Theater objective " .. obj_name .. " has been removed from the state")
      else
        log("Objective " .. obj_name .. " is still alive with " .. Group.getByName(obj.groupName):getSize() .. " units")
      end
    end

    if (current_time - last_cap_cleanup_time) >= CLEANUP_CAP_PERIOD then
        last_cap_cleanup_time = current_time

        local caps = game_state["Theaters"]["Russian Theater"]["CAP"]
        for i=#caps, 1, -1 do
            local cap = Group.getByName(caps[i])
            if cap and isAlive(cap) then
                if allOnGround(cap) then
                    cap:destroy()
                    log("Found inactive cap, removing")
                    table.remove(caps, i)
                    GameStats:decrement("caps")
                end
            else
                table.remove(caps, i)
                GameStats:decrement("caps")
            end
        end

        for i,g in ipairs(enemy_interceptors) do
            if allOnGround(g) then
                Group.getByName(g):destroy()
            end

            if not isAlive(g) then
                enemy_interceptors = {}
            end
        end
    end
    log("Done Clean script")
end

mist.scheduleFunction(cleanup, {}, timer.getTime() + 47, CLEANUP_PERIOD)
