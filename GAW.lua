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

--function log(str)end

log("Logging System INIT")

-- Setup an initial state object and provide functions for manipulating that state.
game_state = {
    ["last_launched_time"] = 0,
    ["CurrentTheater"] = "Russian Theater",
    ["Theaters"] = {
        ["Russian Theater"] ={
            ["last_cap_spawn"] = 0,
            ["Airfields"] = {
                [AIRBASE.Caucasus.Novorossiysk] = AIRBASE:FindByName(AIRBASE.Caucasus.Novorossiysk):GetCoalition(),
                [AIRBASE.Caucasus.Gelendzhik] = AIRBASE:FindByName(AIRBASE.Caucasus.Gelendzhik):GetCoalition(),
                [AIRBASE.Caucasus.Krymsk] = AIRBASE:FindByName(AIRBASE.Caucasus.Krymsk):GetCoalition(),
                [AIRBASE.Caucasus.Krasnodar_Center] = AIRBASE:FindByName(AIRBASE.Caucasus.Krasnodar_Center):GetCoalition(),
                [AIRBASE.Caucasus.Krasnodar_Pashkovsky] = AIRBASE:FindByName(AIRBASE.Caucasus.Krasnodar_Pashkovsky):GetCoalition()
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
            ["FARPS"] = {
                ["SW Warehouse"] = AIRBASE:FindByName("SW Warehouse"):GetCoalition(),
                ["NW Warehouse"] = AIRBASE:FindByName("NW Warehouse"):GetCoalition(),
                ["SE Warehouse"] = AIRBASE:FindByName("SE Warehouse"):GetCoalition(),
                ["NE Warehouse"] = AIRBASE:FindByName("NE Warehouse"):GetCoalition(),
            }
        }
    }
}

log("Game State INIT")

abslots = {
    [AIRBASE.Caucasus.Novorossiysk] = {"Novoro Huey 1", "Novoro Huey 2", "Novoro Mi-8 1", "Novoro Mi-8 2"},
    [AIRBASE.Caucasus.Gelendzhik] = {},
    [AIRBASE.Caucasus.Krymsk] = {"Krymsk Huey 1", "Krymsk Huey 2", "Krymsk Mi-8 1", "Krymsk Mi-8 2"},
    [AIRBASE.Caucasus.Krasnodar_Center] = {"Krasnador Huey 1", "Kras Mi-8 1", "Krasnador Huey 2", "Kras Mi-8 2"},
    [AIRBASE.Caucasus.Krasnodar_Pashkovsky] = {},
    ['SW Warehouse'] = {"SWFARP Huey 1", "SWFARP Huey 2", "SWFARP Mi-8 1", "SWFARP Mi-8 2"},
    ['NW Warehouse'] = {"NWFARP Huey 1", "NWFARP Huey 2", "NWFARP Mi-8 1", "NWFARP Mi-8 2", "NWFARP KA50"},
    ['SE Warehouse'] ={"SEFARP Huey 1", "SEFARP Huey 2", "SEFARP Mi-8 1", "SEFARP Mi-8 2", "SEFARP KA50"},
    ['NE Warehouse'] = {"NEFARP Huey 1", "NEFARP Huey 2", "NEFARP Mi-8 1", "NEFARP Mi-8 2"},
}

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

        for i,grp in ipairs(abslots[abname]) do
            trigger.action.setUserFlag(grp, flagval)     
        end

        if abname == 'SW Warehouse' or abname == 'NW Warehouse' or abname == 'SE Warehouse' or abname == 'NE Warehouse' then
            game_state["Theaters"]["Russian Theater"]['FARPS'][abname] = coalition
        else
            game_state["Theaters"]["Russian Theater"]['Airfields'][abname] = coalition
        end 

        if capString then
            MESSAGE:New(event.place:getName() .. " has been captured by " .. capString, 20):ToAll()
        end
    end
end

mist.addEventHandler(baseCaptured)

AddNavalStrike = function(theater)
    return function(group, spawn_name, callsign)
        game_state["Theaters"][theater]['NavalStrike'][group:GetName()] = {
            ["callsign"] = callsign, 
            ["spawn_name"] = spawn_name, 
            ["position"] = {group:GetVec2().x, group:GetVec2().y}
        }

        group:GetCoordinate():MarkToCoalitionBlue("NAVAL - "..callsign)
    end
end

AddStrategicSAM = function(theater)
    return function(group, spawn_name, callsign)
        game_state["Theaters"][theater]['StrategicSAM'][group:GetName()] = {
            ["callsign"] = callsign, 
            ["spawn_name"] = spawn_name, 
            ["position"] = {group:GetVec2().x, group:GetVec2().y}
        }

        group:GetCoordinate():MarkToCoalitionBlue("SAM - "..callsign)
    end
end

AddRussianTheaterStrategicSAM = function(group, spawn_name, callsign)
    AddStrategicSAM("Russian Theater")(group, spawn_name, callsign)
end

AddCAP = function(theater)
    return function(group)
        table.insert(game_state["Theaters"][theater]["CAP"], group:GetName())
    end
end

AddRussianTheaterCAP = function(group)
    AddCAP("Russian Theater")(group)
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

AddC2 = function(theater)
    return function(group, spawn_name, callsign)
        game_state["Theaters"][theater]["C2"][group:GetName()] = {
            ["callsign"] = callsign, 
            ["spawn_name"] = spawn_name,
            ["position"] = {group:GetVec2().x, group:GetVec2().y}
        }
        group:GetCoordinate():MarkToCoalitionBlue("C2 - "..callsign)
    end
end

AddRussianTheaterC2 = function(group, spawn_name, callsign)
    AddC2("Russian Theater")(group, spawn_name, callsign)
end

AddEWR = function(theater)
    return function(group, spawn_name, callsign)
        game_state["Theaters"][theater]["EWR"][group:GetName()] = {
            ["callsign"] = callsign, 
            ["spawn_name"] = spawn_name, 
            ["position"] = {group:GetVec2().x, group:GetVec2().y}
        }
    end
end

AddRussianTheaterEWR = function(group, spawn_name, callsign)
    AddEWR("Russian Theater")(group, spawn_name, callsign)
end

AddStrikeTarget = function(theater)
    return function(group, spawn_name, callsign)
        game_state["Theaters"][theater]["StrikeTargets"][group:GetName()] = {
            ["callsign"] = callsign, 
            ["spawn_name"] = spawn_name, 
            ["position"] = {group:GetVec2().x, group:GetVec2().y}
        }

        group:GetCoordinate():MarkToCoalitionBlue("STRIKE - "..callsign)
    end
end

AddRussianTheaterStrikeTarget = function(group, spawn_name, callsign)
    AddStrikeTarget("Russian Theater")(group, spawn_name, callsign)
end

AddBAITarget = function(theater)
    return function(group, spawn_name, callsign)
        game_state["Theaters"][theater]["BAI"][group:GetName()] = {
            ["callsign"] = callsign, 
            ["spawn_name"] = spawn_name, 
            ["position"] = {group:GetVec2().x, group:GetVec2().y}
        }

        group:GetCoordinate():MarkToCoalitionBlue("BAI - "..callsign)
    end
end

AddRussianTheaterBAITarget = function(group, spawn_name, callsign)
    AddBAITarget("Russian Theater")(group, spawn_name, callsign)
end

AddAWACSTarget = function(theater)
    return function(group)
        table.insert(game_state["Theaters"][theater]["AWACS"], group:GetName())
    end
end

AddRussianTheaterAWACSTarget = function(group)
    AddAWACSTarget("Russian Theater")(group)
end

AddTankerTarget = function(theater)
    return function(group)
        table.insert(game_state["Theaters"][theater]["Tanker"], group:GetName())
    end
end

AddRussianTheaterTankerTarget = function(group)
    AddTankerTarget("Russian Theater")(group)
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

TheaterUpdate = function(theater)
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
