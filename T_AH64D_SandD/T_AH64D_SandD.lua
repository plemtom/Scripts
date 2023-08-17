do
    if not randomized then 
        math.random()
        local debug = false
        local zoneNumber = math.random(1, 5)
        local tgtNumber = math.random(1, 6)
        local aaa1Number = math.random(1, 8)
        local aaa2Number = math.random(1, 8)
        local aaa3Number = math.random(1, 8)
        while aaa1Number == aaa2Number do
            aaa2Number = math.random(1, 8)
        end
        while aaa3Number == aaa2Number or aaa3Number == aaa1Number do
            aaa3Number = math.random(1, 8)
        end

        tgtName = string.format("TGT0%d", tgtNumber)
        zoneName = string.format("TargetArea0%d", zoneNumber)
        local aaa1Name = string.format("AAA0%d", aaa1Number)
        local aaa2Name = string.format("AAA0%d", aaa2Number)
        local aaa3Name = string.format("AAA0%d", aaa3Number)
        if debug then 
            trigger.action.outText(string.format("Target name: %s", tgtName), 30)
            trigger.action.outText(string.format("Target area name: %s", zoneName), 30)
        end 

        mist.teleportInZone(tgtName, zoneName, 200)
        Group.activate(Group.getByName(tgtName))
        mist.teleportInZone(aaa1Name, zoneName, 100)
        Group.activate(Group.getByName(aaa1Name))
        mist.teleportInZone(aaa2Name, zoneName, 100)
        Group.activate(Group.getByName(aaa2Name))
        mist.teleportInZone(aaa3Name, zoneName, 100)
        Group.activate(Group.getByName(aaa3Name))

        mist.marker.drawZone(zoneName)
        tgtGroupAlive = true
        randomized = true
        trigger.action.outTextForCoalition(2, string.format("Search and destroy targets in zone %s. Enemy AAA is present in the area.", zoneName), 60)
    end 

    if tgtGroupAlive then
        local gp = Group.getByName(tgtName)
        if not (gp and #Group.getUnits(gp) > 0) then
            tgtGroupAlive = false
            trigger.action.setUserFlag("101", 101)
        end
    end     
end



