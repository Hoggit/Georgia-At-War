casspawns = { Spawner("CAS1") }--, SPAWN:New("CAS2"), SPAWN:New("CAS3") }
bcasspawns = { Spawner("BCAS1") }--, SPAWN:New("BCAS2"), SPAWN:New("BCAS3") }


schedule_tasking = function()
    log("Iterating on-call CAS")
    for i=#oncall_cas,1,-1 do
        local v = oncall_cas[i]
        local grp = Group.getByName(v.name)
        if not v.mission then
            if not grp or not isAlive(grp) then
              table.remove(oncall_cas, i)
              return
            end

            --local idx = math.random(3)
            local idx = 1
            local zone_idx = math.random(10)
            local bzone = "BOCC" .. zone_idx
            local rzone = "ROCC" .. zone_idx
            local bspawn = bcasspawns[idx]:SpawnInZone(bzone, true)
            local rspawn = casspawns[idx]:SpawnInZone(rzone, true)
            --local enemy_coord = rspawn:GetCoordinate()
            local enemy_coord = GetCoordinate(rspawn)
            local group_coord = GetCoordinate(grp)

            v.mission = {rspawn:GetName(), bspawn:GetName()}
            enemy_coord:SmokeRed()
            GetCoordinate(bspawn):SmokeBlue()
            trigger.action.outSoundForGroup(grp:GetID(), ninelinecassound)
            --MESSAGE:New(v.name .. ", Standby for coordinates to target area...", 10):ToGroup(grp)
            MessageToGroup(grp, v.name .. ", Standby for coordinates to target area...", 10)
            MessageToGroup(grp, "TGT: IFV's and Dismounted Infantry\n\nLOC:\n" .. enemy_coord:ToStringLLDMS() .. "\n" .. enemy_coord:ToStringLLDDM() .. "\n" .. enemy_coord:ToStringMGRS() .. "\n" .. enemy_coord:ToStringBRA(group_coord) .. "\n" .. "Marked with RED smoke\nTroops in contact marked with BLUE smoke", 60)
            --SCHEDULER:New(nil, function() rspawn:Destroy() end, {}, 10)
        else
            local enemy = Group.getByName(v.mission[1])
            local friendly = Group.getByName(v.mission[2])

            if not grp or not IsAlive(grp) then
                friendly:destroy()
                enemy:destroy()
                table.remove(oncall_cas, i)
                return
            end
            if not enemy or not IsAlive(enemy) then
                trigger.action.outSoundForGroup(grp:GetID(), targetdestroyedsound)
                --MESSAGE:New(v.name .. " target destroyed.  Stand by for new tasking."):ToGroup(grp)
                MessageToGroup(grp, v.name .. " target destroyed.  Stand by for new tasking.")
                friendly:destroy()
                v.mission = nil
            else
                GetCoordinate(enemy):SmokeRed()
                GetCoordinate(friendly):SmokeBlue()
            end
        end
    end
    log("Done Iterating on-call CAS")
end

--SCHEDULER:New(nil, function() pcall(schedule_tasking) end, {}, 120, 120)
mist.scheduleFunction(function() pcall(schedule_taking) end, {}, timer.getTime() + 120, 120)
--SCHEDULER:New(nil,schedule_tasking, {}, 10, 20)
