-- Global Menu, available to everyone
XportMenu = MENU_COALITION:New(coalition.side.BLUE, "Deploy Airfield Security Forces")
FARPXportMenu = MENU_COALITION:New(coalition.side.BLUE, "Deploy FARP/Warehouse Security Forces")
imperialSettings = SETTINGS:Set("IMPERIALDOGS")
imperialSettings:SetImperial()
metricSettings = SETTINGS:Set("COMMUNISTPIGS")

-- Per group menu, called on groupspawn
buildMenu = function(Group)
    local type
    local useSettings

    if string.match(Group.GroupName, "Hawg") then 
        type = 2
        useSettings = imperialSettings

    elseif string.match(Group.GroupName, "Chevy") then
        type = 4
        useSettings = metricSettings
    elseif string.match(Group.GroupName, "Colt") then
        type = 3
        useSettings = imperialSettings
    else
        useSettings = imperialSettings
        type = 1
    end

    MENU_GROUP_COMMAND:New(Group, "FARP/WAREHOUSE Locations", nil, function()
        local output = [[NW FARP: 45 12'10"N 38 4'45" E
SW FARP: 44 55'45"N 38 5'17" E
NE FARP: 45 10'4" N 38 55'22"E
SE FARP: 44 50'7" N 38 46'34"E]]
        MESSAGE:New(output, 60):ToGroup(Group)
    end)

    local MissionMenu = MENU_GROUP_COMMAND:New(Group, "Get Mission Status", nil, function()
        MESSAGE:New(TheaterUpdate("Russian Theater"), 60):ToGroup(Group)
    end)


    local MissionMenu = MENU_GROUP:New(Group, "Get Current Missions")
    MENU_GROUP_COMMAND:New(Group, "SEAD", MissionMenu, function()
        local sams ="ACTIVE SAM REPORT:\n"
        for group_name, group_table in pairs(game_state["Theaters"]["Russian Theater"]["StrategicSAM"]) do
            local type_name = group_table["spawn_name"]
            local coord = COORDINATE:NewFromVec2({['x'] = group_table["position"][1], ['y'] = group_table["position"][2]})
            local callsign = group_table['callsign']
            local coords = {
                coord:ToStringLLDMS(), 
                coord:ToStringMGRS(),
                coord:ToStringLLDDM(),
                "",
            }
            sams = sams .. "OBJ: ".. callsign .." -- TYPE: " .. type_name ..": \t" .. coords[type] .. " " .. coord:ToStringBR(Group:GetCoordinate(), useSettings) .. "\n"
        end
        MESSAGE:New(sams, 60):ToGroup(Group)
    end)

    MENU_GROUP_COMMAND:New(Group, "Air Interdiction", MissionMenu, function()
        local bais ="BAI TASK LIST:\n"
        for id,group_table in pairs(game_state["Theaters"]["Russian Theater"]["BAI"]) do
            --local g = group_table[1]
            local type_name = group_table["spawn_name"]
            local coord = COORDINATE:NewFromVec2({['x'] = group_table["position"][1], ['y'] = group_table["position"][2]})

            local coords = {
                coord:ToStringLLDMS(), 
                coord:ToStringMGRS(),
                coord:ToStringLLDDM(),
                "",
            }
            bais = bais .. "OBJ: " .. group_table["callsign"] .. " -- " .. type_name .. ": \t" .. coords[type] .. " " .. coord:ToStringBR(Group:GetCoordinate(), useSettings) .. "\n"
        end
        MESSAGE:New(bais, 60):ToGroup(Group)
    end)

    MENU_GROUP_COMMAND:New(Group, "Strike", MissionMenu, function()
        local strikes ="STRIKE TARGET LIST:\n"
        for group_name,group_table in pairs(game_state["Theaters"]["Russian Theater"]["C2"]) do
            local coord = COORDINATE:NewFromVec2({['x'] = group_table["position"][1], ['y'] = group_table["position"][2]})
            local callsign = group_table['callsign']
            local coords = {
                coord:ToStringLLDMS(), 
                coord:ToStringMGRS(),
                coord:ToStringLLDDM(),
                "",
            }
            
            strikes = strikes .. "OBJ: " .. callsign .. " -- MOBILE CP: \t" .. coords[type] .. " " .. coord:ToStringBR(Group:GetCoordinate(), useSettings) .. "\n"
        end
        
        for group_name,group_table in pairs(game_state["Theaters"]["Russian Theater"]["StrikeTargets"]) do
            local coord = COORDINATE:NewFromVec2({['x'] = group_table["position"][1], ['y'] = group_table["position"][2]})
            local callsign = group_table['callsign']
            local spawn_name = group_table['spawn_name']
            local coords = {
                coord:ToStringLLDMS(), 
                coord:ToStringMGRS(),
                coord:ToStringLLDDM(),
                "",
            }

            strikes = strikes .. "OBJ: " .. callsign .. " -- " .. spawn_name .. ": \t" .. coords[type] .. " " .. coord:ToStringBR(Group:GetCoordinate(), useSettings) .. "\n"
        end

        MESSAGE:New(strikes, 60):ToGroup(Group)
    end)

    MENU_GROUP_COMMAND:New(Group, "Interception", MissionMenu, function()
        local intercepts ="INTERCEPTION TARGETS:\n"
        for i,group_name in ipairs(game_state["Theaters"]["Russian Theater"]["AWACS"]) do
            local g = GROUP:FindByName(group_name)
            local coord = g:GetCoordinate()
            local group_coord = Group:GetCoordinate()
            local coords = {
                coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringLLDMS(), 
                coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringMGRS(),
                coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringLLDDM(),
                coord:ToStringBRA(group_coord, useSettings),
            }
            intercepts = intercepts .. "AWACS: \t" .. coords[type] .. "\n"
        end

        for i,group_name in ipairs(game_state["Theaters"]["Russian Theater"]["Tanker"]) do
            local g = GROUP:FindByName(group_name)
            local coord = g:GetCoordinate()
            local group_coord = Group:GetCoordinate()

            local coords = {
                coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringLLDMS(), 
                coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringMGRS(),
                coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringLLDDM(),
                coord:ToStringBRA(group_coord, useSettings),
            }
            intercepts = intercepts .. "TANKER: \t" .. coords[type] .. "\n"
        end
        MESSAGE:New(intercepts, 60):ToGroup(Group)
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

for name,spawn in pairs(NorthGeorgiaFARPTransportSpawns) do
    local curMenu = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Deploy to " .. name .. " FARP/WAREHOUSE", FARPXportMenu, function() 
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
                buildMenu(EventData.IniGroup)
            end
        end
    end
end

log("Event Handler complete")

--local ShowNumSames = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "SAMS", StateMenu, function() BASE:I(#game_state["Theaters"]["Russian Theater"]["StrategicSAM"]) end)
--local ShowNumSames = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Dump State", StateMenu, function() log(dump(game_state)) end)

log("menus.lua complete")