-- Setup logging
logLevel = 2 --0=quiet, 1=normal, 2=verbose

function log(str, level)
    local level = level or 1
    if level <= logLevel then
        local logFile = io.open(lfs.writedir()..[[Logs\Hoggit-GAW.log]], "a")
        if str == nil then str = 'nil' end
        if logFile then
            logFile:write("HOGGIT GAW LOG - " .. str .."\r\n")
        end
    end
end

log("Logging System INIT")

-- Setup an initial state object and provide functions for manipulating that state.
game_state = {
    ["last_launched_time"] = 0,
    ["CurrentTheater"] = "Russian Theater",
    ["Theaters"] = {
        ["Russian Theater"] ={
            ["last_cap_spawn"] = 0,
            ["Airfields"] = {
                ["Novorossiysk"] = false,
                ["Gelendzhik"] = false,
                ["Krymsk"] = false,
                ["Krasnodar-Center"] = false,
                ["Krasnodar-Pashkovsky"] = false
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
            ["FARPS"] = {
                ["SW"] = AIRBASE:FindByName("SW Warehouse"),
                ["NW"] = AIRBASE:FindByName("NW Warehouse"),
                ["SE"] = AIRBASE:FindByName("SE Warehouse"),
                ["NE"] = AIRBASE:FindByName("NE Warehouse"),
            }
        }
    }
}

log("Game State INIT")
coros = {}

UpdateTheaterState = function(old_state)
    local new_state = mist.utils.deepCopy(old_state)
    return function(theater)
        return function(key)
            return function(value)
                new_state["Theaters"][theater][key] = value
                game_state = new_state
            end
        end
    end
end

UpdateRussianSAMState = function(state, sams)
    UpdateTheaterState(state)("Russian Theater")("StrategicSAM")(sams)
end

UpdateRussianStrikeTargetState = function(state, targets)
    UpdateTheaterState(state)("Russian Theater")("StrikeTargets")(targets)
end

UpdateRussianCAPState = function(state, caps)
    UpdateTheaterState(state)("Russian Theater")("CAP")(caps)
end

UpdateRussianCASTargetsState = function(state, castargets)
    UpdateTheaterState(state)("Russian Theater")("CASTargets")(castargets)
end

UpdateRussianC2State = function(state, c2s)
    UpdateTheaterState(state)("Russian Theater")("C2")(c2s)
end

UpdateRussianEWRState = function(state, ewrs)
    UpdateTheaterState(state)("Russian Theater")("EWR")(ewrs)
end

UpdateRussianBAIState = function(state, bais)
    UpdateTheaterState(state)("Russian Theater")("BAI")(bais)
end

UpdateRussianTankerState = function(state, tankers)
    UpdateTheaterState(state)("Russian Theater")("Tanker")(tankers)
end

UpdateRussianAWACSState = function(state, awacs)
    UpdateTheaterState(state)("Russian Theater")("AWACS")(awacs)
end

AddStrategicSAM = function(state)
    return function(theater)
        return function(group, callsign)
            local sams = mist.utils.deepCopy(state["Theaters"][theater]['StrategicSAM'])
            table.insert(sams, {group, callsign})
            return sams
        end
    end
end

AddRussianTheaterStrategicSAM = function(state, group, callsign)
    local sams = AddStrategicSAM(state)("Russian Theater")(group, callsign)
    UpdateRussianSAMState(state, sams)
end

AddCAP = function(state)
    return function(theater)
        return function(group)
            local caps = mist.utils.deepCopy(state["Theaters"][theater]["CAP"])
            table.insert(caps, group)
            return caps
        end
    end
end

AddRussianTheaterCAP = function(state, group)
    local caps = AddCAP(state)("Russian Theater")(group)
    UpdateRussianCAPState(state, caps)
end

AddCASTarget = function(state)
    return function(theater)
        return function(group, callsign)
            local castargets = mist.utils.deepCopy(state["Theaters"][theater]["CASTargets"])
            table.insert(castargets, group)
            group:GetCoordinate():MarkToCoalitionBlue("CAS - " .. callsign)
            return castargets
        end
    end
end

AddRussianTheaterCASTarget = function(state, group, callsign)
    local castargets = AddCASTarget(state)("Russian Theater")(group, callsign)
    UpdateRussianCASTargetsState(state, castargets)
end

AddC2 = function(state)
    return function(theater)
        return function(group, callsign)
            local c2s = mist.utils.deepCopy(state["Theaters"][theater]["C2"])
            table.insert(c2s, {group, callsign})
            group:GetCoordinate():MarkToCoalitionBlue("C2 - "..callsign)
            return c2s
        end
    end
end

AddRussianTheaterC2 = function(state, group, callsign)
    local c2s = AddC2(state)("Russian Theater")(group, callsign)
    UpdateRussianC2State(state, c2s)
end

AddEWR = function(state)
    return function(theater)
        return function(group, callsign)
            local EWRs = mist.utils.deepCopy(state["Theaters"][theater]["EWR"])
            table.insert(EWRs, {group, callsign})
            group:GetCoordinate():MarkToCoalitionBlue("EWR - "..callsign)
            return EWRs
        end
    end
end

AddRussianTheaterEWR = function(state, group, callsign)
    local ewrs = AddEWR(state)("Russian Theater")(group, callsign)
    UpdateRussianEWRState(state, ewrs)
end

AddStrikeTarget = function(state)
    return function(theater)
        return function(group, callsign)
            local StrikeTargets = mist.utils.deepCopy(state["Theaters"][theater]["StrikeTargets"])
            table.insert(StrikeTargets, {group, callsign})
            group:GetCoordinate():MarkToCoalitionBlue("STRIKE - "..callsign)
            return StrikeTargets
        end
    end
end

AddRussianTheaterStrikeTarget = function(state, group, callsign)
    local targets = AddStrikeTarget(state)("Russian Theater")(group, callsign)
    UpdateRussianStrikeTargetState(state, targets)
end

AddBAITarget = function(state)
    return function(theater)
        return function(group, callsign)
            local BAITargets = mist.utils.deepCopy(state["Theaters"][theater]["BAI"])
            table.insert(BAITargets, {group, callsign})
            group:GetCoordinate():MarkToCoalitionBlue("BAI - "..callsign)
            return BAITargets
        end
    end
end

AddRussianTheaterBAITarget = function(state, group, callsign)
    local targets = AddBAITarget(state)("Russian Theater")(group, callsign)
    UpdateRussianBAIState(state, targets)
end

AddAWACSTarget = function(state)
    return function(theater)
        return function(group)
            local AWACS = mist.utils.deepCopy(state["Theaters"][theater]["AWACS"])
            table.insert(AWACS, group)
            return AWACS
        end
    end
end

AddRussianTheaterAWACSTarget = function(state, group)
    local targets = AddAWACSTarget(state)("Russian Theater")(group)
    UpdateRussianAWACSState(state, targets)
end

AddTankerTarget = function(state)
    return function(theater)
        return function(group)
            local Tankers = mist.utils.deepCopy(state["Theaters"][theater]["Tanker"])
            table.insert(Tankers, group)
            return Tankers
        end
    end
end

AddRussianTheaterTankerTarget = function(state, group)
    local targets = AddTankerTarget(state)("Russian Theater")(group)
    UpdateRussianTankerState(state, targets)
end

SpawnDefenseForces = function(time, last_launched_time, spawn)
    if time > last_launched_time + 120 then
        spawn:Spawn()
        return time
    else
        MESSAGE:New("Unable to send security forces, next mission available in " .. (120 + last_launched_time - time) .. " seconds"):ToAll()
        return nil
    end
end

TheaterUpdate = function(state, theater)
    local output = "OPFOR Strategic Report: " .. theater .. "\n--------------------------\n\nSAM COVERAGE: "
    local numsams = #state["Theaters"][theater]['StrategicSAM']
    if numsams > 5 then
        output = output .. "Fully Operational"
    elseif numsams > 3 then
        output = output .. "Degraded"
    elseif numsams > 0 then
        output = output .. "Critical"
    else
        output = output .. "None"
    end

    local numc2 = #state["Theaters"][theater]['C2']
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

    local numewr = #state["Theaters"][theater]['EWR']
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
    for name,capped in pairs(state['Theaters'][theater]["Primary"]) do
        output = output .. "    " .. name .. ": "
        if capped then output = output .. "Captured\n" else output = output .. "NOT CAPTURED\n" end
    end

    output = output .. "\n\nTHEATER OBJECTIVE:  Destroy all strike targets, all Command and Control (C2) units, and capture all primary airfields."

    return output
end

CreateRussianCASMission = function(targetV3, zoneRadius)
    log("===== CAS Mission Requested.")
    --Create the zone
    local v2Point = POINT_VEC2:NewFromVec3(targetV3)
    local message = "---- ( " .. v2Point:ToStringLLDMS() .." ) ---"
    log(message)
    local zone = ZONE_RADIUS:New("CAS Zone", v2Point:GetVec2(), zoneRadius)
    SCHEDULER:New(nil, SpawnOPFORCas, {zone, RussianTheaterCASSpawn}, seconds) 
end

BASE:I("HOGGIT GAW - GAW COMPLETE")
log("GAW.lua complete")
