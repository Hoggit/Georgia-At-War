write_state = function()
    log("Writing State...")
    local stateFile = lfs.writedir()..[[Scripts\GAW\state.json]]
    local fp = io.open(stateFile, 'w')
    fp:write(json:encode(game_state))
    fp:close()
    log("Done writing state.")
end

mist.scheduleFunction(write_state, {}, timer.getTime() + 524, 580)

-- update list of active CTLD AA sites in the global game state
function enumerateCTLD()
    local CTLDstate = {}
    log("Enumerating CTLD")
    for _groupname, _groupdetails in pairs(ctld.completeAASystems) do
        local CTLDsite = {}
        for k,v in pairs(_groupdetails) do
            CTLDsite[v['unit']] = v['point']
        end
        CTLDstate[_groupname] = CTLDsite
    end
    game_state["Theaters"]["Russian Theater"]["Hawks"] = CTLDstate
    log("Done Enumerating CTLD")
end

ctld.addCallback(function(_args)
    if _args.action and _args.action == "unpack" then
        local name
        local groupname = _args.spawnedGroup:getName()
        if string.match(groupname, "Hawk") then
            name = "hawk"
        elseif string.match(groupname, "Avenger") then
            name = "avenger"
        elseif string.match(groupname, "M 818") then
            name = 'ammo'
        elseif string.match(groupname, "Gepard") then
            name = 'gepard'
        elseif string.match(groupname, "MLRS") then
            name = 'mlrs'
        elseif string.match(groupname, "JTAC") then
            name = 'jtac'
        elseif string.match(groupname, "Hummer") then
            name = 'jtac'
        end

        table.insert(game_state["Theaters"]["Russian Theater"]["CTLD_ASSETS"], {
            name=name,
            pos=GetCoordinate(Group.getByName(groupname))
        })

        enumerateCTLD()
        write_state()
    end
end)
