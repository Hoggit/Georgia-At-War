function cleanup()
    -- Get Alive BAI Targets and cleanup state
    local baitargets = game_state["Theaters"]["Russian Theater"]["BAI"]
    for group_name, baitarget_table in pairs(baitargets) do        
        local baitarget = GROUP:FindByName(group_name)
        if baitarget and baitarget:IsAlive() then
            local alive_units = 0
            for UnitID, UnitData in pairs(baitarget:GetUnits()) do
                if UnitData and UnitData:IsAlive() then
                    alive_units = alive_units + 1
                end
            end

            if alive_units == 0 or alive_units / baitarget:GetInitialSize() * 100 < 30 then
                MESSAGE:New("BAI target " .. baitarget_table['callsign'] .. " destroyed!", 15):ToAll()
                log("Not enough units, destroying")
                baitarget:Destroy()
                baitargets[group_name] = nil
            end
        else
            MESSAGE:New("BAI target " .. baitarget_table['callsign'] .. " destroyed!", 15):ToAll()
            baitargets[group_name] = nil
        end
    end

    -- Get the number of C2s in existance, and cleanup the state for dead ones.
    local c2s = game_state["Theaters"]["Russian Theater"]["C2"]
    for group_name, group_table in pairs(c2s) do
        local c2 = GROUP:FindByName(group_name)
        local callsign = group_table['callsign']
        if not c2 or not c2:IsAlive() then
            MESSAGE:New("Mobile CP " .. group_table['callsign'] .. " destroyed!", 15):ToAll()
            game_state["Theaters"]["Russian Theater"]["C2"][group_name] = nil
        end
    end

    -- Get the number of Strikes in existance, and cleanup the state for dead ones.
    local striketargets = game_state["Theaters"]["Russian Theater"]["StrikeTargets"]
    for group_name, group_table in pairs(striketargets) do
        local st = STATIC:FindByName(group_name)
        local callsign = group_table['callsign']
        if not st or not st:IsAlive() then
            MESSAGE:New("Strike Target " .. group_table['callsign'] .. " destroyed!", 15):ToAll()
            game_state["Theaters"]["Russian Theater"]["StrikeTargets"][group_name] = nil
        end
    end
end

SCHEDULER:New(nil, cleanup, {}, 40, 60)
