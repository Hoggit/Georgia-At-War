-- Global Menu, available to everyone
XportMenu = MENU_COALITION:New(coalition.side.BLUE, "Deploy Airfield Security Forces")

-- Per group menu, called on groupspawn
buildMenu = function(Group)
    local type

    if string.match(Group.GroupName, "Hawg") then 
        type = 2
    elseif string.match(Group.GroupName, "Chevy") then
        type = 1
    elseif string.match(Group.GroupName, "Colt") then
        type = 3
    else
        type = 1
    end

    local MissionMenu = MENU_GROUP:New(Group, "Get Current Missions")
    MENU_GROUP_COMMAND:New(Group, "SEAD", MissionMenu, function()
        local sams ="ACTIVE SAM REPORT:\n"
        for i,g in ipairs(game_state["Theaters"]["Russian Theater"]["StrategicSAM"]) do
            local coords = {
                g:GetCoordinate():ToStringLLDMS(), 
                g:GetCoordinate():ToStringMGRS(),
                g:GetCoordinate():ToStringLLDDM()
                --g:GetCoordinate():ToStringBR(g:GetCoordinate(), Group:GetCoordinate())
            }
            sams = sams .. "TYPE " .. split(g.GroupName, "#")[1] ..": \t" .. coords[type] .. "\n"
        end
        MESSAGE:New(sams, 60):ToGroup(Group)
    end)

    MENU_GROUP_COMMAND:New(Group, "Air Interdiction", MissionMenu, function()
        local bais ="BAI TASK LIST:\n"
        for i,g in ipairs(game_state["Theaters"]["Russian Theater"]["BAI"]) do
            local coords = {
                g:GetCoordinate():ToStringLLDMS(), 
                g:GetCoordinate():ToStringMGRS(),
                g:GetCoordinate():ToStringLLDDM()
                --g:GetCoordinate():ToStringBR(g:GetCoordinate(), Group:GetCoordinate())
            }
            bais = bais .. split(g.GroupName, "#")[1] .. ": \t" .. coords[type] .. "\n"
        end
        MESSAGE:New(bais, 60):ToGroup(Group)
    end)

    MENU_GROUP_COMMAND:New(Group, "Strike", MissionMenu, function()
        local strikes ="STRIKE TARGET LIST:\n"
        for i,g in ipairs(game_state["Theaters"]["Russian Theater"]["C2"]) do
            local coords = {
                g:GetCoordinate():ToStringLLDMS(), 
                g:GetCoordinate():ToStringMGRS(),
                g:GetCoordinate():ToStringLLDDM()
                --g:GetCoordinate():ToStringBR(g:GetCoordinate(), Group:GetCoordinate())
            }
            
            strikes = strikes .. "MOBILE CP: \t" .. coords[type] .. "\n"
        end
        
        for i,g in ipairs(game_state["Theaters"]["Russian Theater"]["StrikeTargets"]) do
            local coords = {
                g:GetCoordinate():ToStringLLDMS(), 
                g:GetCoordinate():ToStringMGRS(),
                g:GetCoordinate():ToStringLLDDM()
                --g:GetCoordinate():ToStringBR(g:GetCoordinate(), Group:GetCoordinate())
            }

            strikes = strikes .. split(g.StaticName, "#")[1] .. ": \t" .. coords[type] .. "\n"
        end

        MESSAGE:New(strikes, 60):ToGroup(Group)
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