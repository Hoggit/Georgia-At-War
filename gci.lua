fs = require('lfs')
package.path = fs.currentdir() .. "Scripts\\?.lua;" .. package.path
--logFile = io.open(fs.writedir()..[[Logs\HoggitGCI\GCI.log]], "w")
--dofile(fs.writedir()..[[Scripts\HoggitGCI\worldstate.lua]])
--socket = require('socket')

local stateFile = fs.writedir()..[[Scripts\HoggitGCI\state.json]]
log("STATEFILE: " .. stateFile )

-- Get AWACS units
AWACSGroups = SET_GROUP:New():FilterPrefixes( "AWACS" ):FilterStart()
AWACSDetection = DETECTION_UNITS:New(AWACSGroups):FilterCategories(Unit.Category.AIRPLANE)
AWACSDetection:Start()

-- All blue
BlueGroups = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()

SCHEDULER:New(nil, function()
    local state = {}
    local blue_state = {}
    local file = io.open(stateFile, 'w')

    for i,v in pairs(AWACSDetection:GetDetectedItems()) do
        local lat, lon = coord.LOtoLL(v.Coordinate:GetVec3())
        local unit = UNIT:FindByName(v.Name)
        local id = unit:GetID()
        local group = unit:GetGroup()
        local heading = group:GetHeading()
        local velocity = VELOCITY_POSITIONABLE:New(unit):GetMiph() * .86
        table.insert(state, {["lat"] = lat, ["long"] = lon, ["speed"]= velocity, ["id"]=id, ["name"] = v.Name, ["heading"] = heading})
    end

    BlueGroups:ForEachGroup(function(group)
        if group:IsAlive() then
            for i,unit in ipairs(group:GetUnits()) do
                local lat, lon = coord.LOtoLL(unit:GetCoordinate():GetVec3())
                local id = unit:GetID()
                local heading = group:GetHeading()
                local velocity = VELOCITY_POSITIONABLE:New(unit):GetMiph() * .86
                table.insert(blue_state, {["id"] = id, ["lat"] = lat, ["long"] = lon, ["speed"] = velocity, ["heading"] = heading, ["playerName"] = unit:GetPlayerName() or '', ["name"] = unit:GetCallsign()})
            end
        end
    end)
    file:write('{"red":[')
    local idx = 1
    for j,unit in ipairs(state) do
        if idx > 1 then file:write(',') end
        file:write('{"id":' .. unit['id'] .. ', "lat":' .. unit['lat'] ..  ', "long": ' .. unit['long']  ..  ', "heading": ' .. unit['heading'] .. ', "speed": ' .. unit['speed'] .. ', "name": "' .. split(unit['name'], '-')[1] ..'"}')
        idx = idx + 1
    end

    file:write('],"blue":[')
    idx = 1
    for k,blue_unit in ipairs(blue_state) do
        if idx > 1 then file:write(',') end
        file:write('{"id":' .. blue_unit['id'] .. ', "lat":' .. blue_unit['lat'] ..  ', "long": ' .. blue_unit['long']  ..  ', "heading": ' .. blue_unit['heading'] .. ', "speed": ' .. blue_unit['speed'] .. ', "name": "' .. blue_unit['name'] ..'", "playerName": "'.. blue_unit['playerName'] ..'"}')
        idx = idx + 1
    end

    file:write('], "FARPS":[')
    idx = 1
    for name,object in pairs(game_state["Theaters"]["Russian Theater"]["FARPS"]) do
        if idx > 1 then file:write(',') end
        file:write('{"'.. name ..'":"'.. object:GetCoalition() ..'"}')
        idx = idx + 1
    end

    file:write(']}')
    file:close()
end, {}, 10, 10)
