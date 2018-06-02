-- Setup an initial state object and provide functions for manipulating that state.

game_state = {
    ["CurrentTheater"] = "Russian Theater",
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
        ["CAS"] = {},
        ["Intercepts"] = {}
    }
}

last_launched_time = 0

UpdateState = function(old_state)
    new_state = mist.utils.deepCopy(old_state)
    return function(theater)
        return function(key)
            return function(value)
                new_state[theater][key] = value
                game_state = new_state
            end
        end
    end
end

UpdateRussianSAMState = function(state, sams)
    UpdateState(state)("Russian Theater")("StrategicSAM")(sams)
end

AddStrategicSAM = function(state)
    return function(theater)
        return function(group)
            local sams = mist.utils.deepCopy(state[theater]['StrategicSAM'])
            table.insert(sams, group)
            return sams
        end
    end
end

AddRussianTheaterStrategicSAM = function(state, group)
    local sams = AddStrategicSAM(state)("Russian Theater")(group)
    UpdateRussianSAMState(state, sams)
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
