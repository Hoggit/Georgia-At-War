SCHEDULER:New(nil,function()
    local stateFile = fs.writedir()..[[Scripts\GAW\state.json]]
    local fp = io.open(stateFile, 'w')
    fp:write(json:encode(game_state))
    fp:close()
end, {}, 10, 580)