fs = require('lfs')
package.path = fs.currentdir() .. "Scripts\\?.lua;" .. package.path
--logFile = io.open(fs.writedir()..[[Logs\HoggitGCI\GCI.log]], "w")
--dofile(fs.writedir()..[[Scripts\HoggitGCI\worldstate.lua]])
socket = require('socket')

local stateFile = fs.writedir()..[[Scripts\HoggitGCI\state.json]]
log("STATEFILE: " .. stateFile )

-- Get AWACS units
--AWACSGroups = SET_GROUP:New():FilterPrefixes( "AWACS" ):FilterStart()
--AWACSDetection = DETECTION_UNITS:New(AWACSGroups):FilterCategories(Unit.Category.AIRPLANE)
--AWACSDetection:Start()

--SCHEDULER:New(nil, function()
--    for i,v in pairs(AWACSDetection:GetDetectedItems()) do
--        lat, lon = coord.LOtoLL(v.Coordinate:GetVec3())
--    end
--end, {}, 10, 10)

--local file = io.open(stateFile, 'w')
--file:write(state)
--file:close()