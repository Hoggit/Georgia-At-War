BASE:I(
    mist.getLLString({
        ['units'] = {'[g]jers'},
        ['acc'] = 10
    })
)

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
            ["CAP"] = {},
            ["BAI"] = {}
        }
    }
}

log("Game State INIT")

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

AddStrategicSAM = function(state)
    return function(theater)
        return function(group)
            local sams = mist.utils.deepCopy(state["Theaters"][theater]['StrategicSAM'])
            table.insert(sams, group)
            return sams
        end
    end
end

AddRussianTheaterStrategicSAM = function(state, group)
    local sams = AddStrategicSAM(state)("Russian Theater")(group)
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
        return function(group)
            local castargets = mist.utils.deepCopy(state["Theaters"][theater]["CASTargets"])
            table.insert(castargets, group)
            return castargets
        end
    end
end

AddRussianTheaterCASTarget = function(state, group)
    local castargets = AddCASTarget(state)("Russian Theater")(group)
    UpdateRussianCASTargetsState(state, castargets)
end

AddC2 = function(state)
    return function(theater)
        return function(group)
            local c2s = mist.utils.deepCopy(state["Theaters"][theater]["C2"])
            table.insert(c2s, group)
            return c2s
        end
    end
end

AddRussianTheaterC2 = function(state, group)
    local c2s = AddC2(state)("Russian Theater")(group)
    UpdateRussianC2State(state, c2s)
end

AddEWR = function(state)
    return function(theater)
        return function(group)
            local EWRs = mist.utils.deepCopy(state["Theaters"][theater]["EWR"])
            table.insert(EWRs, group)
            return EWRs
        end
    end
end

AddRussianTheaterEWR = function(state, group)
    local ewrs = AddEWR(state)("Russian Theater")(group)
    UpdateRussianEWRState(state, ewrs)
end

AddStrikeTarget = function(state)
    return function(theater)
        return function(group)
            local StrikeTargets = mist.utils.deepCopy(state["Theaters"][theater]["StrikeTargets"])
            table.insert(StrikeTargets, group)
            return StrikeTargets
        end
    end
end

AddRussianTheaterStrikeTarget = function(state, group)
    local targets = AddStrikeTarget(state)("Russian Theater")(group)
    UpdateRussianStrikeTargetState(state, targets)
end

AddBAITarget = function(state)
    return function(theater)
        return function(group)
            local BAITargets = mist.utils.deepCopy(state["Theaters"][theater]["BAI"])
            table.insert(BAITargets, group)
            return BAITargets
        end
    end
end

AddRussianTheaterBAITarget = function(state, group)
    local targets = AddBAITarget(state)("Russian Theater")(group)
    UpdateRussianBAIState(state, targets)
end

SpawnDefenseForces = function(time, last_launched_time, spawn)
    if time - last_launched_time > 300 then
        spawn:Spawn()
        return time
    else
        return nil
    end
end

BASE:I("HOGGIT GAW - GAW COMPLETE")
log("GAW.lua complete")
