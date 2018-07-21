casspawns = { SPAWN:New("CAS1")}--, SPAWN:New("CAS2"), SPAWN:New("CAS3") }
bcasspawns = { SPAWN:New("BCAS1")}--, SPAWN:New("BCAS2"), SPAWN:New("BCAS3") }

schedule_tasking = function()
    for i=#oncall_cas,1,-1 do
        local v = oncall_cas[i]
        local grp = GROUP:FindByName(v.name)
        if not v.mission then
            if not grp or not grp:IsAlive() then
              table.remove(oncall_cas, i)
              return
            end

            --local idx = math.random(3)
            local idx = 1
            local zone_idx = math.random(10)
            local bzone = ZONE:New("BOCC" .. zone_idx)
            local rzone = ZONE:New("ROCC" .. zone_idx)
            local bspawn = bcasspawns[idx]:SpawnInZone(bzone, true)
            local rspawn = casspawns[idx]:SpawnInZone(rzone, true)
            local enemy_coord = rspawn:GetCoordinate()
            local group_coord = grp:GetCoordinate()

            v.mission = {rspawn:GetName(), bspawn:GetName()}
            enemy_coord:SmokeRed()
            bspawn:GetCoordinate():SmokeBlue()
            trigger.action.outSoundForGroup(grp:GetID(), ninelinecassound)
            MESSAGE:New(v.name .. ", Standby for coordinates to target area...", 10):ToGroup(grp)
            MESSAGE:New("TGT: IFV's and Dismounted Infantry\n\nLOC:\n" .. enemy_coord:ToStringLLDMS() .. "\n" .. enemy_coord:ToStringLLDDM() .. "\n" .. enemy_coord:ToStringMGRS() .. "\n" .. enemy_coord:ToStringBRA(group_coord) .. "\n" .. "Marked with RED smoke\nTroops in contact marked with BLUE smoke", 60):ToGroup(grp)
        else
            local enemy = GROUP:FindByName(v.mission[1])
            local friendly = GROUP:FindByName(v.mission[2])

            if not grp or not grp:IsAlive() then
                friendly:Destroy()
                enemy:Destroy()
                table.remove(oncall_cas, i)
                return
            end
            if not enemy or not enemy:IsAlive() then
                trigger.action.outSoundForGroup(grp:GetID(), targetdestroyedsound)
                MESSAGE:New(v.name .. " target destroyed.  Stand by for new tasking."):ToGroup(grp)
                friendly:Destroy()
                v.mission = nil
            else
                enemy:GetCoordinate():SmokeRed()
                friendly:GetCoordinate():SmokeBlue()
            end
        end
    end
end

--SCHEDULER:New(nil, function() pcall(schedule_tasking) end, {}, 10, 10)
SCHEDULER:New(nil,schedule_tasking, {}, 10, 10)
