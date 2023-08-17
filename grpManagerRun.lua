if grpManager then 
    for i, name in pairs(grpManager.airGrpoupNames) do
        if mist.groupIsDead(name) then
            local index = table.findString(grpManager.actCAP, name)
            if index then 
                table.remove(grpManager.actCAP, index)
                table.insert(grpManager.inactCAP, name)
            end 
            index = table.findString(grpManager.actCAS, name)
            if index then
                table.remove(grpManager.actCAS, index)
                table.insert(grpManager.inactCAS, name)
            end
            --mist.respawnGroup(name, false)
        end 
    end

    -- 2) check if enough caps active and activate if needed
    while grpManager.targetCAP > #grpManager.actCAP do
        if #grpManager.inactCAP > 0 then 
            local rnd = math.random(1, #grpManager.inactCAP)
            local gName = grpManager.inactCAP[rnd]
            local grp = Group.getByName(gName)
            if grp then 
                if mist.groupIsDead(gName) then
                    mist.respawnGroup(gName, false)
                end
                grp.activate(grp)
                table.insert(grpManager.actCAP, gName)
                table.remove(grpManager.inactCAP, rnd)
                if grpManager.debug then
                    trigger.action.outText(string.format("CAP: %d/%d, target: %d. Activating group %s", #grpManager.actCAP, #grpManager.inactCAP, grpManager.targetCAP, gName) , 20)
                end
                if grpManager.keepConstActiveNumber == false then 
                    grpManager.targetCAP = grpManager.targetCAP - 1
                end
            end
        else 
            break
        end 
    end

    -- 3) check if enough cass active and activate if needed
    while grpManager.targetCAS > #grpManager.actCAS do
        if #grpManager.inactCAS > 0 then 
            local rnd = math.random(1, #grpManager.inactCAS)
            local gName = grpManager.inactCAS[rnd]
            local grp = Group.getByName(gName)
            if grp then 
                if mist.groupIsDead(gName) then
                    mist.respawnGroup(gName, false)
                end
                grp.activate(grp)
                table.insert(grpManager.actCAS, gName)
                table.remove(grpManager.inactCAS, rnd)
                if grpManager.debug then
                    trigger.action.outText(string.format("CAS: %d/%d, target: %d. Activating group %s", #grpManager.actCAS, #grpManager.inactCAS, grpManager.targetCAS, gName) , 20)
                end
                if grpManager.keepConstActiveNumber == false then 
                    grpManager.targetCAS = grpManager.targetCAS - 1
                end
            end
            
        else 
            break
        end 
    end
else 
    env.info("grpManager not loaded.")
end