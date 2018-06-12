local EscortableUnits = {
    "Chevy 1", "Chevy 2", "Chevy 3", "Chevy 4", 
    "Ford 1", "Ford 2", "Ford 3", "Ford 4",
    "Ford 5", "Ford 6", "Ford 7", "Ford 8", 
    "Hawg 1", "Hawg 2", "Hawg 3", "Hawg 4"
}

local EscortSpawns = {
    SPAWN:New("Escort F-16"), SPAWN:New("Escort F-14"), SPAWN:New("Escort Mirage")
}

EscortSets = SET_GROUP:New():FilterPrefixes("Escort"):FilterStart()
EscortDetection = DETECTION_AREAS:New( EscortSets, 5000 )
EscortDetection:SetRefreshTimeInterval(15)
EscortDetection:FilterCategories(Unit.Category.AIRPLANE)

local current_escorts = {}

process_escorts = function()
    --log("Processing escorts")
    local escort_zone = ZONE:New("Escort Zone")
    for i,name in ipairs(EscortableUnits) do
        log("Checking " .. name)
        local unit
        local status,client = pcall(function() return CLIENT:FindByName(name, "", false) end)
        if status then
            log("Getting unit for client")
            unit = client:GetClientGroupUnit()
        end

        if unit then
            if not current_escorts[client] and unit:IsInZone(escort_zone) then
                log("Found Unit " .. unit:GetName())
                local spawn = EscortSpawns[math.random(3)]
                local escort = spawn:Spawn()
                log("Spawned " .. escort.GroupName)
                current_escorts[client] = escort
                MESSAGE:New("An " .. escort.GroupName .. " has been assigned to you.", 60):ToClient(client)

                local Escorter = ESCORT:New(client, escort, escort.GroupName):Menus()
                Escorter:JoinUpAndFollow(escort, client, 75)
                Escorter:SetDetection(EscortDetection)
            end
        end
    end
end

prune_escorts_table = function()
    for client, escort in pairs(current_escorts) do
        if escort:AllOnGround() then
            escort:Destroy()
        end

        if not escort:IsAlive() then
            current_escorts[client] = nil
        end
    end
end

SCHEDULER:New(nil, process_escorts, {}, 60, 10)
SCHEDULER:New(nil, prune_escorts_table, {}, 70, 10)
