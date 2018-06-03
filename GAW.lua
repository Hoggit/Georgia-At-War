-- Setup an initial state object and provide functions for manipulating that state.

game_state = {
    ["last_launched_time"] = 0,
    ["CurrentTheater"] = "Russian Theater",
    ["Theaters"] = {
        ["Russian Theater"] ={
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
            ["CASTargets"] = {},
            ["InterceptTargets"] = {},
            ["CAP"] = {}
        }
    }
}

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

UpdateRussianCAPState = function(state, caps)
    UpdateTheaterState(state)("Russian Theater")("CAP")(caps)
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

SpawnDefenseForces = function(time, last_launched_time, spawn)
    if time - last_launched_time > 300 then
        spawn:Spawn()
        return time
    else
        return nil
    end
end

BASE:I("HOGGIT GAW - GAW COMPLETE")
