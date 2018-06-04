-- Global Menu, available to everyone
XportMenu = MENU_COALITION:New(coalition.side.BLUE, "Deploy Airfield Security Forces")

-- Per group menu, called on groupspawn
buildMenu = function(Group)
    local MissionMenu = MENU_GROUP:New(Group, "Get Current Missions")
    MENU_GROUP_COMMAND:New(Group, "SEAD Missions", MissionMenu, function()
        local sams ="ACTIVE SAM REPORT:\n"
        for i,g in ipairs(game_state["Theaters"]["Russian Theater"]["StrategicSAM"]) do
            sams = sams .. "TYPE " .. split(g.GroupName, "#")[1] ..": " .. mist.getLLString({units = mist.makeUnitTable({'[g]' .. g.GroupName}), acc = 3}) .. "\n"
        end
        MESSAGE:New(sams):ToGroup(Group)
    end)

    MENU_GROUP_COMMAND:New(Group, "Air Interdiction Missions", MissionMenu, function()
        local bais ="BAI TASK LIST:\n"
        for i,g in ipairs(game_state["Theaters"]["Russian Theater"]["BAI"]) do
            bais = bais .. "ARTILLERY: " .. mist.getLLString({units = mist.makeUnitTable({'[g]' .. g.GroupName}), acc = 3}) .. "\n"
        end
        MESSAGE:New(bais):ToGroup(Group)
    end)
end

local playableUnits = {
    'Hawg 1',
    'Hawg 2',
    'Hawg 3',
    'Hawg 4',
    'Uzi 1',
    'Uzi 2',
    'Uzi 3',
    'Uzi 4',
    'Uzi 5',
    'Uzi 6',
    'Uzi 7',
    'Uzi 8',
    'Uzi 9',
    'Uzi 10',
    'Colt 1',
    'Colt 2', 
    'Colt 3',
    'Colt 4',
    'Ford 1',
    'Ford 2',
    'Ford 3',
    'Ford 4',
    'Ford 5',
    'Ford 6',
    'Ford 7',
    'Ford 8'
}

for i,unit in ipairs(playableUnits) do
     local client = CLIENT:FindByName(unit)
     client:HandleEvent(EVENTS.PlayerEnterUnit)
     function client:OnEventPlayerEnterUnit(EventData)
        SCHEDULER:New(nil, function() buildMenu(GROUP:FindByName(EventData.IniDCSGroupName)) end, {}, 10)
     end
end

for name,spawn in pairs(NorthGeorgiaTransportSpawns) do
    local curMenu = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Deploy to " .. name, XportMenu, function() 
        local new_spawn_time = SpawnDefenseForces(timer.getAbsTime() + env.mission.start_time, game_state["last_launched_time"], spawn)
        if new_spawn_time ~= nil then
            game_state["last_launched_time"] = new_spawn_time
        end
    end)
end

--local ShowNumSames = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "SAMS", StateMenu, function() BASE:I(#game_state["Theaters"]["Russian Theater"]["StrategicSAM"]) end)
--local ShowNumSames = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Dump State", StateMenu, function() log(dump(game_state)) end)

log("menus.lua complete")