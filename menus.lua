-- Global Menu, available to everyone
XportMenu = MENU_COALITION:New(coalition.side.BLUE, "Deploy Airfield Security Forces")

-- Per group menu, called on groupspawn
buildMenu = function(Group)
    local MissionMenu = MENU_GROUP:New(Group, "Get Current Missions")
    MENU_GROUP_COMMAND:New(Group, "SEAD", MissionMenu, function()
        local sams ="ACTIVE SAM REPORT:\n"
        for i,g in ipairs(game_state["Theaters"]["Russian Theater"]["StrategicSAM"]) do
            sams = sams .. "TYPE " .. split(g.GroupName, "#")[1] ..": " .. mist.getLLString({units = mist.makeUnitTable({'[g]' .. g.GroupName}), acc = 3}) .. "\n"
        end
        MESSAGE:New(sams):ToGroup(Group)
    end)

    MENU_GROUP_COMMAND:New(Group, "Air Interdiction", MissionMenu, function()
        local bais ="BAI TASK LIST:\n"
        for i,g in ipairs(game_state["Theaters"]["Russian Theater"]["BAI"]) do
            bais = bais .. "ARTILLERY: " .. mist.getLLString({units = mist.makeUnitTable({'[g]' .. g.GroupName}), acc = 3}) .. "\n"
        end
        MESSAGE:New(bais):ToGroup(Group)
    end)

    MENU_GROUP_COMMAND:New(Group, "Strike", MissionMenu, function()
        local strikes ="STRIKE TARGET LIST:\n"
        for i,g in ipairs(game_state["Theaters"]["Russian Theater"]["StrikeTargets"]) do
            strikes = strikes .. split(g.StaticName, "#")[1] .. ": " .. g:GetCoordinate():ToStringLLDMS() .. "\n"
        end
        MESSAGE:New(strikes):ToGroup(Group)
    end)
end

for name,spawn in pairs(NorthGeorgiaTransportSpawns) do
    local curMenu = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Deploy to " .. name, XportMenu, function() 
        local new_spawn_time = SpawnDefenseForces(timer.getAbsTime() + env.mission.start_time, game_state["last_launched_time"], spawn)
        if new_spawn_time ~= nil then
            game_state["last_launched_time"] = new_spawn_time
        end
    end)
end

EventHandler = EVENTHANDLER:New()

EventHandler:HandleEvent( EVENTS.Birth )
function EventHandler:OnEventBirth( EventData )
    if EventData.IniGroup then
        for i,u in ipairs(EventData.IniGroup:GetUnits()) do
            if u:GetPlayerName() ~= "" then
                log(u:GetPlayerName())
                buildMenu(EventData.IniGroup)
            end
        end
    end
end

log("Event Handler complete")

--local ShowNumSames = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "SAMS", StateMenu, function() BASE:I(#game_state["Theaters"]["Russian Theater"]["StrategicSAM"]) end)
--local ShowNumSames = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Dump State", StateMenu, function() log(dump(game_state)) end)

log("menus.lua complete")