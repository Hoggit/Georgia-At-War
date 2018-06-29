MENU_MISSION_COMMAND:New("DUMPSTATE", nil, function()
    log(json:encode(game_state["Theaters"]["Russian Theater"]["BAI"]))
end)