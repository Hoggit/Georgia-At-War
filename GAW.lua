-- Setup JSON
local jsonlib = lfs.writedir() .. "Scripts\\GAW\\json.lua"
json = loadfile(jsonlib)()

-- Setup logging
logFile = io.open(lfs.writedir()..[[Logs\Hoggit-GAW.log]], "w")
--JSON = (loadfile "JSON.lua")()

function log(str)
    if str == nil then str = 'nil' end
    if logFile then
        logFile:write("HOGGIT GAW LOG - " .. str .."\r\n")
        logFile:flush()
    end
end

SecondsToClock = function(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00m 00s";
    else
        mins = string.format("%02.f", math.floor(seconds/60));
        secs = string.format("%02.f", math.floor(seconds - mins *60));
        return mins.."m "..secs.."s"
    end
end

-- Replace the spawn stuff
Spawner = function(grpName)
    local CallBack = {}
    return {
        Spawn = function(self)
            local added_grp = Group.getByName(mist.cloneGroup(grpName, true).name)
            if CallBack.func then
                if not CallBack.args then CallBack.args = {} end
                mist.scheduleFunction(CallBack.func, {added_grp, unpack(CallBack.args)}, timer.getTime() + 1)
            end
            return added_grp
        end,
        SpawnAtPoint = function(self, point)
            local vars = {
                groupName = grpName,
                point = point,
                action = "clone"
            }

            local new_group = mist.teleportToPoint(vars)
            if new_group then
                local name = new_group.name
                if CallBack.func then
                    if not CallBack.args then CallBack.args = {} end
                    mist.scheduleFunction(CallBack.func, {Group.getByName(name), unpack(CallBack.args)}, timer.getTime() + 1)
                end
                return Group.getByName(name)
            else
                trigger.action.outText("Error spawning " .. grpName, 15)
            end

        end,
        SpawnInZone = function(self, zoneName)
            local added_grp = Group.getByName(mist.cloneInZone(grpName, zoneName).name)
            if CallBack.func then
                if not CallBack.args then CallBack.args = {} end
                mist.scheduleFunction(CallBack.func, {added_grp, unpack(CallBack.args)}, timer.getTime() + 1)
            end
            return added_grp
        end,
        OnSpawnGroup = function(self, f, args)
            CallBack.func = f
            CallBack.args = args
        end
    }
end

StaticSpawner = function(groupName, numberInGroup, groupOffsets)
    local CallBack = {}
    return {
        Spawn = function(self, firstPos)
            local names = {}
            for i=1,numberInGroup do
                local groupData = mist.getGroupData(groupName .. i)
                groupData.units[1].x = firstPos[1] + groupOffsets[i][1]
                groupData.units[1].y = firstPos[2] + groupOffsets[i][2]
                groupData.clone = true
                table.insert(names, mist.dynAddStatic(groupData).name)
            end

            if CallBack.func then
                if not CallBack.args then CallBack.args = {} end
                mist.scheduleFunction(CallBack.func, {names, firstPos, unpack(CallBack.args)}, timer.getTime() + 1)
            end

            return names
        end,
        OnSpawnGroup = function(self, f, args)
            CallBack.func = f
            CallBack.args = args
        end
    }
end

GetCoordinate = function(grp)
    local firstUnit = grp:GetUnit(1)
    if firstUnit then
        return firstUnit:getPosition().p
    end
end

-- Coalition Menu additions
CoalitionMenu = function( coalition, text )
    return missionCommands.addSubMenuForCoalition( coalition, text )
end

GroupMenu = function( groupId, text, parent )
    return missionCommands.addSubMenuForGroup( groupId, text, parent )
end


HandleError = function(err)
    log("Error in pcall: "  .. err)
    log(debug.traceback())
    return err
end

try = function(func, catch)
    return function()
        local r, e = xpcall(func, HandleError)
        if not r then
            catch(e)
        end
    end
end

CoalitionCommand = function(coalition, text, parent, handler)
    callback = try(handler, function(err) log("Error in coalition command: " .. err) end)
    missionCommands.addCommandForCoalition( coalition, text, parent, callback)
end

GroupCommand = function(group, text, parent, handler)
    callback = try(handler, function(err) log("Error in group command" .. err) end)
    missionCommands.addCommandForGroup( group, text, parent, callback)
end

MessageToGroup = function(groupId, text, displayTime)
    trigger.action.outTextForGroup( groupId, text, displayTime )
end

MessageToAll = function( text, displayTime )
    trigger.action.outText( text, displayTime )
end

standbycassound = "l10n/DEFAULT/standby.ogg"
ninelinecassound = "l10n/DEFAULT/marked.ogg"
targetdestroyedsound = "l10n/DEFAULT/targetdestroyed.ogg"
terminatecassound = "l10n/DEFAULT/depart.ogg"
ableavesound =  "l10n/DEFAULT/transport.ogg"
farpleavesound =  "l10n/DEFAULT/transportfarp.ogg"
abcapsound = "l10n/DEFAULT/arrive.ogg"
farpcapsound = "l10n/DEFAULT/arrivefarp.ogg"

oncall_cas = {}
enemy_interceptors = {}

--function log(str)end
log("Logging System INIT")

function isAlive(group)
    local grp = nil
    if type(group) == "string" then
        grp = Group.getByName(group)
    else
        grp = group
    end
    if grp and grp:isExist() and grp:getSize() > 0 then return true else return false end
end

function groupIsDead(groupName)
    if (Group.getByName(groupName) and Group.getByName(groupName):isExist() == false) or (Group.getByName(groupName) and #Group.getByName(groupName):getUnits() < 1) or not Group.getByName(groupName) then
        return true
    end
    return false
end

function allOnGround(group)
    local grp = nil
    local allOnGround = true
    if type(group) == "string" then
        grp = Group.getByName(group)
    else
        grp = group
    end
    if not grp then return false end

    for i,unit in ipairs(grp:getUnits()) do
        if unit:inAir() then allOnGround = false end
    end

    return allOnGround
end

checkedSams = {}
checkedEWRs = {}
checkedC2s = {}

buildCheckSAMEvent = function(group, callsign)
    checkedSams[group] = callsign
end

buildCheckEWREvent = function(group, callsign)
    checkedEWRs[group] = callsign
end

buildCheckC2Event = function(group, callsign)
    checkedC2s[group] = callsign
end

mist.addEventHandler(handleDeaths)

-- Setup an initial state object and provide functions for manipulating that state.
game_state = {
    ["last_launched_time"] = 0,
    ["CurrentTheater"] = "Russian Theater",
    ["Theaters"] = {
        ["Russian Theater"] ={
            ["last_cap_spawn"] = 0,
            ["Airfields"] = {
                ["Novorossiysk"] = Airbase.getByName("Novorossiysk"):getCoalition(),
                ["Gelendzhik"] = Airbase.getByName("Gelendzhik"):getCoalition(),
                ["Krymsk"] = Airbase.getByName("Krymsk"):getCoalition(),
                ["Krasnodar-Center"] = Airbase.getByName("Krasnodar-Center"):getCoalition(),
                ["Krasnodar-Pashkovsky"] = Airbase.getByName("Krasnodar-Pashkovsky"):getCoalition(),
            },
            ["Primary"] = {
                ["Maykop-Khanskaya"] = false
            },
            ["StrategicSAM"] = {},
            ["C2"] = {},
            ["EWR"] = {},
            ["CASTargets"] = {},
            ["StrikeTargets"] = {},
            ["InterceptTargets"] = {},
            ["OpforCAS"] = {},
            ["CAP"] = {},
            ["BAI"] = {},
            ["AWACS"] = {},
            ["Tanker"] = {},
            ["NavalStrike"] = {},
            ["CTLD_ASSETS"] = {},
            ['Convoys'] ={},
            ["FARPS"] = {
                ["SW Warehouse"] = Airbase.getByName("SW Warehouse"):getCoalition(),
                ["NW Warehouse"] = Airbase.getByName("NW Warehouse"):getCoalition(),
                ["SE Warehouse"] = Airbase.getByName("SE Warehouse"):getCoalition(),
                ["NE Warehouse"] = Airbase.getByName("NE Warehouse"):getCoalition(),
                ["MK Warehouse"] = Airbase.getByName("MK Warehouse"):getCoalition(),
            }
        }
    }
}

log("Game State INIT")

abslots = {
    ['Novorossiysk'] = {"Novoro Huey 1", "Novoro Huey 2", "Novoro Mi-8 1", "Novoro Mi-8 2"},
    ['Gelendzhik'] = {},
    ['Krymsk'] = {"Krymsk Gazelle M", "Krymsk Gazelle L", "Krymsk Huey 1", "Krymsk Huey 2", "Krymsk Mi-8 1", "Krymsk Mi-8 2"},
    ['Krasnodar-Center'] = {"Krasnador Huey 1", "Kras Mi-8 1", "Krasnador Huey 2", "Kras Mi-8 2"},
    ['Krasnodar-Pashkovsky'] = {"Krasnador2 Huey 1", "Kras2 Mi-8 1", "Krasnador2 Huey 2", "Kras2 Mi-8 2"},
    ['SW Warehouse'] = {"SWFARP Huey 1", "SWFARP Huey 2", "SWFARP Mi-8 1", "SWFARP Mi-8 2"},
    ['NW Warehouse'] = {"NWFARP Huey 1", "NWFARP Huey 2", "NWFARP Mi-8 1", "NWFARP Mi-8 2", "NWFARP KA50"},
    ['SE Warehouse'] = {"SEFARP Gazelle M", "SEFARP Gazelle L", "SEFARP Huey 1", "SEFARP Huey 2", "SEFARP Mi-8 1", "SEFARP Mi-8 2", "SEFARP KA50"},
    ['NE Warehouse'] = {"NEFARP Huey 1", "NEFARP Huey 2", "NEFARP Mi-8 1", "NEFARP Mi-8 2"},
    ['MK Warehouse'] = {"MKFARP Huey 1", "MKFARP Huey 2", "MKFARP Mi-8 1", "MKFARP Mi-8 2", "MK FARP Ka-50"},
}

logiSlots = {
    ['Novorossiysk'] = NovoLogiSpawn,
    ['Gelendzhik'] = nil,
    ['Krymsk'] = KryLogiSpawn,
    ['Krasnodar-Center'] = KrasCenterLogiSpawn,
    ['Krasnodar-Pashkovsky'] = KrasPashLogiSpawn,
    ['MK Warehouse'] = MaykopLogiSpawn
}

function handleDeaths(event)
    -- The scheduledSpawn stuff only works for groups with a single unit atm.
    if event.id == world.event.S_EVENT_DEAD or event.id == world.event.S_EVENT_ENGINE_SHUTDOWN then
        if checkedSams[event.initiator:getGroup():getName()] then
            local radars = 0
            local launchers = 0
            for i, unit in pairs(event.initiator:getGroup():getUnits()) do
                local type_name = unit:getTypeName()
                if type_name == "Kub 2P25 ln" then launchers = launchers + 1 end
                if type_name == "Kub 1S91 str" then radars = radars + 1 end
                if type_name == "S-300PS 64H6E sr" then radars = radars + 1 end
                if type_name == "S-300PS 40B6MD sr" then radars = radars + 1 end
                if type_name == "S-300PS 40B6M tr" then radars = radars + 1 end
                if type_name == "S-300PS 5P85C ln" then launchers = launchers + 1 end
                if type_name == "S-300PS 5P85D ln" then launchers = launchers + 1 end
            end

            if radars == 0 or launchers == 0 then
                game_state['Theaters']['Russian Theater']['StrategicSAM'][event.initiator:getGroup():GetName()] = nil
                checkedSams[event.initiator:getGroup():getName()] = nil
                trigger.action.outText("SAM " .. callsign .. " has been destroyed!", 15)
            end
        end

        if checkedC2s[event.initiator:getGroup():getName()] then
            local cps = 0
            for i, unit in pairs(event.initiator:getGroup():getUnits()) do
                if unit:getTypeName() == "SKP-11" then cps = cps + 1 end
            end

            if cps == 0 then
                game_state['Theaters']['Russian Theater']['C2'][event.initiator:getGroup():GetName()] = nil
                checkedC2s[event.initiator:getGroup():getName()] = nil
                trigger.action.outText("C2 " .. callsign .. " has been destroyed!", 15)
            end
        end

        if checkedEWRs[event.initiator:getGroup():getName()] then
            local ewrs = 0
            for i, unit in pairs(event.initiator:getGroup():getUnits()) do
                if unit:getTypeName() == "1L13 EWR" then ewrs = ewrs + 1 end
            end

            if ewrs == 0 then
                game_state['Theaters']['Russian Theater']['EWR'][event.initiator:getGroup():GetName()] = nil
                checkedEWRs[event.initiator:getGroup():getName()] = nil
                trigger.action.outText("EWR " .. callsign .. " has been destroyed!", 15)
            end
        end

        if scheduledSpawns[event.initiator:getName()] then
            local spawner = scheduledSpawns[event.initiator:getName()][1]
            local stimer = scheduledSpawns[event.initiator:getName()][2]
            scheduledSpawns[event.initiator:getName()] = nil
            mist.scheduleFunction(function()
                spawner:Spawn()
                if event.initiator:getGroup() then
                    event.initiator:getGroup():destroy()
                end
            end, {}, timer.getTime() + stimer)
        end
    end
end

mist.addEventHandler(handleDeaths)

function securityForcesLanding(event)
    if event.id == world.event.S_EVENT_LAND then
        local xport = activeBlueXports[event.initiator:getGroup():getName()]
        if xport then
            local abname = xport[2]
            if xport[3] then abname = abname .. " Warehouse" end
            log('Xport just landed at ' .. abname)
            local grpLoc = event.initiator:getPosition().p
            local landPos = Airbase.getByName(abname):getPosition().p
            local distance = mist.utils.get2DDist(grpLoc, landPos)
            log("Transport landed " .. distance .. " meters from target")
            if (distance <= 2500) then
                log("Within range, spawning Friendly Forces")
                if xport[3] then
                    trigger.action.outSoundForCoalition(2, farpcapsound)
                else
                    trigger.action.outSoundForCoalition(2, abcapsound)
                end

                if xport[4][3] then
                    activateLogi(xport[4][3])
                    log("Logi activated")
                else
                    log("No logi point here")
                end

                local randFactor = 200
                if xport[3] then
                    randFactor = 50
                end

                local pos = {
                    x = landPos.x + 80,
                    y = landPos.z + 80
                }

                AirfieldDefense:SpawnAtPoint(pos)
                FSW:SpawnAtPoint({
                    x = pos.x - 10,
                    y = pos.y - 10
                })
                log("Security forces have spawned")
            end
            mist.scheduleFunction(event.initiator.destroy, {event.initiator}, timer.getTime() + 120)
        end
    end
end
mist.addEventHandler(securityForcesLanding)

function baseCaptured(event)
    if event.id == world.event.S_EVENT_BASE_CAPTURED then
        local abname = event.place:getName()
        local coalition = event.place:getCoalition()
        local capString
        local flagval
        if coalition == 1 then
            capString = "Russian forces"
            flagval = 100
        elseif coalition == 2 then
            capString = "Coalition forces"
            flagval = 0
        end

        if abslots[abname] then
            for i,grp in ipairs(abslots[abname]) do
                trigger.action.setUserFlag(grp, flagval)
            end
        end

        if logiSlots[abname] then
            --activateLogi(logiSlots[abname])
        end

        if abname == 'SW Warehouse' or abname == 'MK Warehouse' or abname == 'NW Warehouse' or abname == 'SE Warehouse' or abname == 'NE Warehouse' then
            game_state["Theaters"]["Russian Theater"]['FARPS'][abname] = coalition
        else
            game_state["Theaters"]["Russian Theater"]['Airfields'][abname] = coalition
        end

        --if capString then
        --MESSAGE:New(event.place:getName() .. " has been captured by " .. capString, 20):ToAll()
        --end
    end
end

local objectiveTypeMap = {
    ["NavalStrike"] = "NAVAL",
    ["StrategicSAM"] = "SAM",
    ["Convoys"] = "CONVOY",
    ["C2"] = "C2",
    ["EWR"] = "EWR",
    ["StrikeTargets"] = "STRIKE",
    ["InterceptTargets"] = "INTERCEPT",
    ["BAI"] = "BAI",
    ["AWACS"] = "AWACS",
    ["Tanker"] = "Tanker"
}

mist.addEventHandler(baseCaptured)
objectiveCounter = 99
AddObjective = function(type, id)
    return function(group, spawn_name, callsign)
        if not group then
            return
        end
        local unit = group:getUnit(1)
        if unit then
            game_state["Theaters"]["Russian Theater"][type][group:getName()] = {
                ["callsign"] = callsign,
                ["spawn_name"] = spawn_name,
                ["position"] = unit:getPosition().p,
                ["markerID"] = id
            }

            trigger.action.markToCoalition(id, objectiveTypeMap[type] .. " - " .. callsign, unit:getPosition().p, 2, true)
        end
    end
end

AddStaticObjective = function(id, callsign, spawn_name, staticNames)
    local point = StaticObject.getByName(staticNames[1]):getPosition().p
    game_state["Theaters"]["Russian Theater"]["StrikeTargets"]["strike" .. id] = {
        ['callsign'] = callsign,
        ['spawn_name'] = spawn_name,
        ['position'] = point,
        ['markerID'] = id,
        ['statics'] = staticNames
    }
end

AddConvoy = function(group, spawn_name, callsign)
    log("Adding convoy " .. callsign)
    game_state['Theaters']['Russian Theater']['Convoys'][group:getName()] = {spawn_name, callsign}
end



AddCAP = function(theater)
    return function(group)
        table.insert(game_state["Theaters"][theater]["CAP"], group:getName())
    end
end

AddRussianTheaterCAP = function(group)
    AddCAP("Russian Theater")(group)
end

AddAWACSTarget = function(theater)
    return function(group)
        table.insert(game_state["Theaters"][theater]["AWACS"], group:getName())
    end
end

AddRussianTheaterAWACSTarget = function(group)
    AddAWACSTarget("Russian Theater")(group)
end

AddTankerTarget = function(theater)
    return function(group)
        table.insert(game_state["Theaters"][theater]["Tanker"], group:getName())
    end
end

AddRussianTheaterTankerTarget = function(group)
    AddTankerTarget("Russian Theater")(group)
end

SpawnDefenseForces = function(target_string, time, last_launched_time, spawn)
    log("Defense forces requested to " .. target_string)
    local launch_frequency_seconds = 600
    if time > (last_launched_time + launch_frequency_seconds) then
        log("Time OK. Spawning Security forces")
        spawn:Spawn()
        MessageToAll("Security Forces en route to ".. target_string, 30)
        return time
    else
        log("Can't send security forces yet. Still on cooldown")
        MessageToAll("Unable to send security forces, next mission available in " .. SecondsToClock(launch_frequency_seconds + last_launched_time - time), 30)
        return nil
    end
end

ConvoyUpdate = function(group)
    log("Doing convoy update")
    local output = "REDFOR Convoy Report:\n\n"
    local numConvoys = 0
    for name, convoy_info in pairs(game_state['Theaters']['Russian Theater']['Convoys']) do
        local convoy = Group.getByName(name)
        local cunits = {}
        if convoy then
            cunits = convoy:getUnits()
            numConvoys = numConvoys + 1

            local names = {}
            if cunits then
                for idx, unit in pairs(cunits) do
                    table.insert(names, unit:getName())
                end
                output = output .. convoy_info[2] .." MGRS: " .. mist.getMGRSString({
                    units=names,
                    acc=2
                }) .. "\nLat/Long: " .. mist.getLLString({
                    units=names,
                    acc=1,
                    DMS=true
                })  .. "\n\n"
            end
        end
    end

    log("Done iterating convoys")
    if numConvoys == 0 then
        output = output .. "No Active Convoys"
    end
    if group == 'all' then
        MessageToAll(output, 20)
    else

        MessageToGroup(group:getID(), output, 20)
    end
    log("Done convoy update")
end

--SCHEDULER:New(nil, ConvoyUpdate, {"all"}, 300, 900)
mist.scheduleFunction(ConvoyUpdate, {"all"}, timer.getTime()+ 300, 900)


TheaterUpdate = function(theater)
    log("Doing theater Update")
    local output = "OPFOR Strategic Report: " .. theater .. "\n--------------------------\n\nSAM COVERAGE: "
    local numsams = 0
    for i,sam in pairs(game_state["Theaters"][theater]['StrategicSAM']) do
        numsams = numsams + 1
    end

    if numsams > 5 then
        output = output .. "Fully Operational"
    elseif numsams > 3 then
        output = output .. "Degraded"
    elseif numsams > 0 then
        output = output .. "Critical"
    else
        output = output .. "None"
    end

    local numc2 = 0
    for i,c2 in pairs(game_state["Theaters"][theater]['C2']) do
        numc2 = numc2 + 1
    end

    output = output .. "\n\nCOMMAND AND CONTROL: "
    if numc2 == 3 then
        output = output .. "Fully Operational"
    elseif numc2 == 2 then
        output = output .. "Degraded"
    elseif numc2 == 1 then
        output = output .. "Critical"
    else
        output = output .. "Destroyed"
    end

    local numewr = 0
    for i,ewr in pairs(game_state["Theaters"][theater]['EWR']) do
        numewr = numewr + 1
    end
    output = output .. "\n\nEW RADAR COVERAGE: "
    if numewr == 3 then
        output = output .. "Fully Operational"
    elseif numewr == 2 then
        output = output .. "Degraded"
    elseif numewr == 1 then
        output = output .. "Critical"
    else
        output = output .. "None"
    end

    output = output .. "\n\nPRIMARY AIRFIELDS: \n"
    for name,capped in pairs(game_state['Theaters'][theater]["Primary"]) do
        output = output .. "    " .. name .. ": "
        if capped then output = output .. "Captured\n" else output = output .. "NOT CAPTURED\n" end
    end

    output = output .. "\n\nTHEATER OBJECTIVE:  Destroy all strike targets, all Command and Control (C2) units, and capture all primary airfields."

    log("Done theater update")
    return output
end

log("GAW.lua complete")
