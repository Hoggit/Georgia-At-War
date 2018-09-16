-- Coalition Menu additions
CoalitionMenu = function( coalition, text )
    return missionCommands.addSubMenuForCoalition( coalition, text )
end

GroupMenu = function( groupId, text )
    return missionCommands.addSubMenuForGroup( groupId, text )
end

CoalitionCommand = function(coalition, text, parent, handler)
    missionCommands.addCommandForCoalition( coalition, text, parent, handler)
end

GroupCommand = function(group, text, parent, handler)
    missionCommands.addCommandForGroup( group, text, parent, handler)
end

MessageToGroup = function(groupId, text, displayTime)
    trigger.action.outTextForGroup( groupId, text, displayTime )
end

-- Global Menu, available to everyone
XportMenu = CoalitionMenu(coalition.side.BLUE, "Deploy Airfield Security Forces")
FARPXportMenu = CoalitionMenu(coalition.side.BLUE, "Deploy FARP/Warehouse Security Forces")
--imperialSettings = SETTINGS:Set("IMPERIALDOGS")
--imperialSettings:SetImperial()
--metricSettings = SETTINGS:Set("COMMUNISTPIGS")

-- Per group menu, called on groupspawn
buildMenu = function(Group)
    log("Building radio menus")
    local type
    local useSettings

    --if string.match(Group.GroupName, "Hawg") then 
    --   type = 2
    --   useSettings = imperialSettings

    --elseif string.match(Group.GroupName, "Chevy") then
    --    type = 4
    --    useSettings = metricSettings
    -- elseif string.match(Group.GroupName, "Colt") then
    --     type = 3
    --     useSettings = imperialSettings
    -- else
    --     useSettings = imperialSettings
    --     type = 1
    -- end

    if Group.GroupName == "Chevy 3" or Group.GroupName == "Chevy 4" then
        type = 1
    end

    GroupCommand(Group, "FARP/WAREHOUSE Locations", nil, function()
        local output = [[NW FARP: 45 12'10"N 38 4'45" E
SW FARP: 44 55'45"N 38 5'17" E
NE FARP: 45 10'4" N 38 55'22"E
SE FARP: 44 50'7" N 38 46'34"E
MAYKOP AREA FARP: 44 42'47" N 39 34' 55"E]]
        --MESSAGE:New(output, 60):ToGroup(Group)
        MessageToGroup( Group:GetID(), output, 60 )
    end)

    local MissionMenu = GroupMenu(Group:GetID(), "Get Mission Status", nil, function()
        --MESSAGE:New(TheaterUpdate("Russian Theater"), 60):ToGroup(Group)
        MessageToGroup(Group:GetID(), TheaterUpdate("Russian Theater"), 60)
    end)


    local MissionMenu = GroupMenu(Group, "Get Current Missions")
    GroupCommand(Group:GetID(), "Convoy Strike", MissionMenu, function()
        ConvoyUpdate(Group)
    end)

    --MENU_GROUP_COMMAND:New(Group, "SEAD", MissionMenu, function()
    GroupMenu(Group:GetID(), "SEAD", MissionMenu, function()
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
        --MESSAGE:New(sams, 60):ToGroup(Group)
        MessageToGroup(Group:GetID(), sams, 60)
    end)

    --MENU_GROUP_COMMAND:New(Group, "Air Interdiction", MissionMenu, function()
    GroupMenu(Group:GetID(), "Air Interdiction", MissionMenu, function()
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
        --MESSAGE:New(bais, 60):ToGroup(Group)
        MessageToGroup(Group:GetID(), bais, 60)
    end)

    --MENU_GROUP_COMMAND:New(Group, "Strike", MissionMenu, function()
    GroupMenu(Group:GetID(), "Strike", MissionMenu, function()
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

        --MESSAGE:New(strikes, 60):ToGroup(Group)
        MessageToGroup(Group:GetID(), strikes, 60)
    end)

    --MENU_GROUP_COMMAND:New(Group, "Naval Strike", MissionMenu, function()
    GroupMenu(Group:GetID(), "Naval Strike", MissionMenu, function()
        local output ="MARITIME REPORT:\n"
        for group_name, group_table in pairs(game_state["Theaters"]["Russian Theater"]["NavalStrike"]) do
            local type_name = group_table["spawn_name"]
            local coord = COORDINATE:NewFromVec2({['x'] = group_table["position"][1], ['y'] = group_table["position"][2]})
            if coord then
                local callsign = group_table['callsign']
                local coords = {
                    coord:ToStringLLDMS(), 
                    coord:ToStringMGRS(),
                    coord:ToStringLLDDM(),
                    "",
                }
                output = output .. "OBJ: ".. callsign .." -- TYPE: " .. type_name ..": \t" .. coords[type] .. " " .. coord:ToStringBR(Group:GetCoordinate(), useSettings) .. "\n"
            end
        end
        --MESSAGE:New(output, 60):ToGroup(Group)
        MessageToGroup(Group:GetID(), output, 60)
    end)

    --MENU_GROUP_COMMAND:New(Group, "Interception", MissionMenu, function()
    GroupMenu(Group:GetID(), "Interception", MissionMenu, function()
        local intercepts ="INTERCEPTION TARGETS:\n"
        for i,group_name in ipairs(game_state["Theaters"]["Russian Theater"]["AWACS"]) do
            local g = GROUP:FindByName(group_name)
            local coord = g:GetCoordinate()
            if coord then
                local group_coord = Group:GetCoordinate()
                local coords = {
                    coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringLLDMS(), 
                    coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringMGRS(),
                    coord:ToStringBRA(group_coord, useSettings) .. " -- " .. coord:ToStringLLDDM(),
                    coord:ToStringBRA(group_coord, useSettings),
                }
                intercepts = intercepts .. "AWACS: \t" .. coords[type] .. "\n"
            end
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

    --MENU_GROUP_COMMAND:New(Group, "Check In On-Call CAS", MissionMenu, function()
    GroupMenu(Group:GetID(), "Check In On-Call CAS", MissionMenu, function()
        if #oncall_cas > 2 then
            --MESSAGE:New("No more on call CAS taskings are available, please try again when players currently running CAS are finished."):ToGroup(Group)
            MessageToGroup(Group:GetID(), "No more on call CAS taskings are available, please try again when players currently running CAS are finished.", 30)
            return
        end

        for i,v in ipairs(oncall_cas) do
            if v.name == Group:GetName() then
                --MESSAGE:New("You are already on call for CAS.  Stand by for tasking")
                MessageToGroup( Group:GetID(), "You are already on call for CAS.  Stand by for tasking", 30)
                return
            end
        end

        trigger.action.outSoundForGroup(Group:GetID(), standbycassound)
        --MESSAGE:New("Understood " .. Group:GetName() .. ", hold position east of Anapa and stand by for tasking.\nSelect 'Check Out On-Call CAS' to cancel mission" ):ToGroup(Group)
        MessageToGroup(Group:GetID(), "Understood " .. Group:GetName() .. ", hold position east of Anapa and stand by for tasking.\nSelect 'Check Out On-Call CAS' to cancel mission", 30)
        table.insert(oncall_cas, {name = Group:GetName(), mission = nil})
    end)

    --MENU_GROUP_COMMAND:New(Group, "Check Out On-Call CAS", MissionMenu, function()
    GroupCommand(Group:GetID(), "Check Out On-Call CAS", MissionMenu, function()
        for i,v in ipairs(oncall_cas) do
            if v.name == Group:GetName() then
                pcall(function() Group.getByName(oncall_cas[i].mission[1]):destroy() end)
                pcall(function() Group.getByName(oncall_cas[i].mission[2]):destroy() end)
                table.remove(oncall_cas, i)
                trigger.action.outSoundForGroup(Group:GetID(), terminatecassound)
                return
            end
        end
    end)

    --MENU_GROUP_COMMAND:New(Group, "Get Current CAS Target Location", MissionMenu, function()
    GroupCommand(Group:GetID(), "Get Current CAS Target Location", MissionMenu, function()
        for i,v in ipairs(oncall_cas) do
            if v.name == Group:GetName() then
                local enemy_coord = Group.getByName(v.mission[1]):GetCoordinate()
                local group_coord = Group:GetCoordinate()
                --MESSAGE:New("TGT: IFV's and Dismounted Infantry\n\nLOC:\n" .. enemy_coord:ToStringLLDMS() .. "\n" .. enemy_coord:ToStringLLDDM() .. "\n" .. enemy_coord:ToStringMGRS() .. "\n" .. enemy_coord:ToStringBRA(group_coord) .. "\n" .. "Marked with RED smoke", 60):ToGroup(Group)
                MessageToGroup( Group:GetID(), "TGT: IFV's and Dismounted Infantry\n\nLOC:\n" .. enemy_coord:ToStringLLDMS() .. "\n" .. enemy_coord:ToStringLLDDM() .. "\n" .. enemy_coord:ToStringMGRS() .. "\n" .. enemy_coord:ToStringBRA(group_coord) .. "\n" .. "Marked with RED smoke", 60)
            end
        end
    end)
    log("Done building radio menus")
end

for name,spawn in pairs(NorthGeorgiaTransportSpawns) do
    log("Preparing menus for NorthGeorgiaTransportSpawns")
    --local curMenu = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Deploy to " .. name, XportMenu, function()
    local curMenu = CoalitionCommand(coalition.side.BLUE, "Deploy to " .. name, XportMenu, function()
        local spawn_idx =1
        if Airbase.getByName(name):GetCoalition() == 1 then spawn_idx = 2 end
        local new_spawn_time = SpawnDefenseForces(timer.getAbsTime() + env.mission.start_time, game_state["last_launched_time"], spawn[spawn_idx])
        if new_spawn_time ~= nil then
            trigger.action.outSoundForCoalition(2, ableavesound)
            game_state["last_launched_time"] = new_spawn_time
        end
    end)
    log("Done preparing menus for NorthGeorgiaTransportSpawns")
end

for name,spawn in pairs(NorthGeorgiaFARPTransportSpawns) do
    log("Preparing menus for NorthGeorgiaFARPTransportSpawns")
    --local curMenu = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Deploy to " .. name .. " FARP/WAREHOUSE", FARPXportMenu, function() 
    local curMenu = CoalitionCommand(coalition.side.BLUE, "Deploy to " .. name .. " FARP/WAREHOUSE", FARPXportMenu, function() 
        local new_spawn_time = SpawnDefenseForces(timer.getAbsTime() + env.mission.start_time, game_state["last_launched_time"], spawn)
        if new_spawn_time ~= nil then
            trigger.action.outSoundForCoalition(2, farpleavesound)
            game_state["last_launched_time"] = new_spawn_time
        end
    end)
    log("Done Preparing menus for NorthGeorgiaFARPTransportSpawns")
end


function groupBirthHandler( Event )
    local Group = Event.initiator:getGroup()
    if Group then
        for i,u in ipairs(Group:GetUnits()) do
            if u:GetPlayerName() ~= "" then
                log("Group birth. Building menus")
                buildMenu(Group)
                log("Done group birth. Building menus")
            end
        end
    end
end

log("Event Handler complete")
log("menus.lua complete")