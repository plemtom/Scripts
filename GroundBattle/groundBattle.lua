-- to be tested:

-- - spawn invisible infantry with AT weapons
-- - make infantry visible as soon as they fire

-- implementation:

-- - alternative frontline orders processing - graph traversing instead of random protocol
-- - more defensive units and figure our defensive groups mix

-- - APC groups transport ground units with AT weapons (between warehouse and frontline/back area zones)
-- - Manage APC groups orders based on zones stats - keep track of defensive infantry units
-- - IFVs deploy aggresive infantry with AT weapons

-- - hide infantry back after some time since they fired their weapon

-- - Finetune groups speed for attack and move
-- - Add artilery fire support logic
-- - add artillery group template

-- - add trucks to reload SAMs
-- - figure out roles for different group types. What should infantry do? What should infantry carriers Init done. Combat zones: %d.
-- - Check victory condition    


-- initialize LUA tables
groundBattle = {}
groundBattle.prodTime = 300
groundBattle.debug = true
groundBattle.dmt = 10 -- debug message time
groundBattle.combatZones = {}
groundBattle.combatZones.frontlineZones = {}
groundBattle.prodZoneNames = {}
groundBattle.initiated = false 
groundBattle.productionInitiated = false 
    
--init Factions
groundBattle.factions = {}
groundBattle.factions.red = {}
groundBattle.factions.red.aaaCount = 3
groundBattle.factions.red.infCount = 5
groundBattle.factions.red.prodTimePerc = 100
groundBattle.factions.red.name = "red"
groundBattle.factions.red.groundTemplates = {}
groundBattle.factions.red.groundGroups = {}     -- group structure {name, zoneName, order, factionName, type}. Orders: none, move (between friendly zones), attack
groundBattle.factions.red.groundGroupsLimit = 0


groundBattle.factions.blue = {}
groundBattle.factions.blue.aaaCount = 3
groundBattle.factions.blue.infCount = 5
groundBattle.factions.blue.prodTimePerc = 100
groundBattle.factions.blue.name = "blue"
groundBattle.factions.blue.groundTemplates = {}
groundBattle.factions.blue.groundGroups = {}
groundBattle.factions.blue.groundGroupsLimit = 0

groundBattle.factions.neutral = {}
groundBattle.factions.neutral.name = "neutral"

-- events handler 
function groundBattle.eventHandler(event)
    if event.id == 1 then 
        groundBattle.debugMessage("Shot event captured.")
        groundBattle.debugMessage(groundBattle.logTable(event, 1))
        
        local u = Unit.get
        local grp = Unit.getGroup(event.initiator)
        if grp then
            groundBattle.debugMessage(groundBattle.logTable(grp, 1))
            groundBattle.debugMessage("Group found. Name: " .. grp.name .. ", groupName: " .. grp.groupName)
            groundBattle.setVisible(grp.name)
        else
            groundBattle.debugMessage("Group not returned for unit: " .. event.initiator.id)
        end
    end
end 

function groundBattle.logTable(tbl, indLevel)
    local retVal = {}
    local ind = ""

    for i=1, indLevel do
        ind = ind .. " "
    end
    
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            retVal[#retVal+1] = ind .. k .. ": \n" .. groundBattle.logTable(v, indLevel+1)
        else
            retVal[#retVal+1] = ind .. k .. ": " .. v .. "\n"
        end
    end
    return table.concat(retVal)
end


-- some assorted functions
function groundBattle.isCombatZoneFrontline(zoneName)
    zone = groundBattle.combatZones.getZoneByName(zoneName)
    for i=1, #zone.links do
        local linkedZone = groundBattle.combatZones.getZoneByName(zone.links[i])
        if zone.faction ~= linkedZone.faction then 
            return true
        end
    end
    return false
end

function groundBattle.getRandomLinkedFriendlyZone(zoneName) -- return string of random linked friendly zone name
    local zones = {}
    local zone = groundBattle.combatZones.getZoneByName(zoneName)
    -- groundBattle.debugMessage(string.format("getRandomLinkedFriendlyZone. Zone: %s, linked zones: %d", zone.name, #zone.links))

    for i = 1, #zone.links do 
        if groundBattle.combatZones.getZoneByName(zone.links[i]).faction == zone.faction then
            table.insert(zones, zone.links[i])
        end
    end
    if #zones > 0 then 
        local retZone = zones[math.random(1, #zones)]
        -- groundBattle.debugMessage(string.format("Random friendly zone: %s", retZone))
        return retZone
    else
        -- groundBattle.debugMessage(string.format("Random friendly zone: nil"))
        return nil 
    end
end

function groundBattle.getRandomLinkedHostileZone(zoneName)
    local zones = {}
    local zone = groundBattle.combatZones.getZoneByName(zoneName)
    -- groundBattle.debugMessage(string.format("getRandomLinkedFriendlyZone. Zone: %s, linked zones: %d", zone.name, #zone.links))

    for i = 1, #zone.links do 
        if groundBattle.combatZones.getZoneByName(zone.links[i]).faction ~= zone.faction then
            table.insert(zones, zone.links[i])
        end
    end
    if #zones > 0 then 
        local retZone = zones[math.random(1, #zones)]
        -- groundBattle.debugMessage(string.format("Random friendly zone: %s", retZone))
        return retZone
    else
        -- -- groundBattle.debugMessage(string.format("Random friendly zone: nil"))
        return nil 
    end
end

function groundBattle.getZoneFaction(zoneName)
    return groundBattle.combatZones.getZoneByName(zoneName).faction
end

function groundBattle.debugMessage(msg)
    if groundBattle.debug then
        trigger.action.outText(msg, groundBattle.dmt)
        env.info(msg)
    end
end

function groundBattle.combatZones.getZoneByName(zoneName)
    for i=1, #groundBattle.combatZones do
        if groundBattle.combatZones[i].name == zoneName then
            return groundBattle.combatZones[i]
        end
    end
end

function groundBattle.combatZones.updateFaction(zoneName, factionName)
    for i=1, #groundBattle.combatZones do
        if groundBattle.combatZones[i].name == zoneName then
            if factionName == "red" then 
                groundBattle.combatZones[i].faction = groundBattle.factions.red
                --groundBattle.debugMessage(string.format("Updating zone %s faction to red.", zoneName))
            elseif factionName == "blue" then
                groundBattle.combatZones[i].faction = groundBattle.factions.blue
                --groundBattle.debugMessage(string.format("Updating zone %s faction to blue.", zoneName))
            elseif factionName == "neutral" then
                groundBattle.combatZones[i].faction = groundBattle.factions.neutral
            end
            break
        end
    end
    local params = {factionName, zoneName}
    mist.scheduleFunction(groundBattle.spawnAAA, params, timer.getTime()+300, nil, nil)
    mist.scheduleFunction(groundBattle.spawnInfantry, params, timer.getTime()+300, nil, nil)
end

function groundBattle.getGroupInfoByName(groupName)
    for i = 1, #groundBattle.factions.blue.groundGroups do
        if groundBattle.factions.blue.groundGroups[i].name == groupName then 
            return groundBattle.factions.blue.groundGroups[i]
        end 
    end 
    for i = 1, #groundBattle.factions.red.groundGroups do
        if groundBattle.factions.red.groundGroups[i].name == groupName then 
            return groundBattle.factions.red.groundGroups[i]
        end 
    end 
    return nil
end 

function groundBattle.checkConflict(zoneName)
    local blufor = false
    local redfor = false

    local redgrps = groundBattle.factions.red.groundGroups
    local blugrps = groundBattle.factions.blue.groundGroups

    local zone = groundBattle.combatZones.getZoneByName(zoneName)

    if #zone.defences > 0 then 
        if zone.faction.name == "red" then 
            redfor = true
        elseif zone.faction.name == "blue" then 
            blufor = true
        end 
    end

    if redgrps and #redgrps > 0 and not redfor then 
        for i=1, #redgrps do
            if redgrps[i].zoneName == zoneName then 
                --- check distance to zone ComCenter
                local zoneData = trigger.misc.getZone(zoneName)
                local units = Group.getByName(redgrps[i].name):getUnits()
                if units and #units > 0 then 
                    for i=1, #units do
                        local upos = Unit.getPosition(units[i]).p
                        local dist = math.sqrt(math.pow(zoneData.point.x - upos.x, 2) + math.pow(zoneData.point.y - upos.y, 2) + math.pow(zoneData.point.z - upos.z, 2))
                        if dist < zoneData.radius then 
                            redfor = true
                            break
                        end
                    end
                end 
            end 
        end
    end 

    if blugrps and #blugrps > 0 and not blufor then 
        -- groundBattle.debugMessage(string.format("Found %d blue groups.", #blugrps))
        for i=1, #blugrps do
            if blugrps[i].zoneName == zoneName then 
                --- check distance to zone ComCenter
                local zoneData = trigger.misc.getZone(zoneName)
                local units = Group.getByName(blugrps[i].name):getUnits()

                if units and #units > 0 then 
                    for i=1, #units do
                        local upos = Unit.getPosition(units[i]).p
                        local dist = math.sqrt(math.pow(zoneData.point.x - upos.x, 2) + math.pow(zoneData.point.y - upos.y, 2) + math.pow(zoneData.point.z - upos.z, 2))
                        
                        if dist < zoneData.radius then 
                            blufor = true
                            break
                        end
                    end
                end 
            end 
        end
    end 

    if blufor and redfor then 
        if zone.faction.name ~= "neutral" then 
            groundBattle.combatZones.updateFaction(zoneName, "neutral")
        end
        return true
    elseif blufor then
        if zone.faction.name ~= "blue" then 
            groundBattle.combatZones.updateFaction(zoneName, "blue")
        end
        return false 
    elseif redfor and zone.faction.name ~= "red" then
        if zone.faction.name ~= "red" then 
            groundBattle.combatZones.updateFaction(zoneName, "red")
        end
        return false
    else
        return true
    end
end 

function groundBattle.redrawMapMarks()
    groundBattle.debugMessage("Redrawing markers")
    local zones = groundBattle.combatZones
    if zones and #zones > 0 then 
        for i=1, #zones do
            local zoneColor = {0.8, 0.8, 0.8, 0.5}
            local fillCol = {0.8, 0.8, 0.8, 0.2}

            if zones[i].faction.name == groundBattle.factions.red.name then 
                zoneColor = {0.8, 0.2, 0.2, 0.5}
                fillCol = {0.8, 0.2, 0.2, 0.2}
            elseif zones[i].faction.name == groundBattle.factions.blue.name then 
                zoneColor = {0.2, 0.2, 0.8, 0.5}
                fillCol = {0.2, 0.2, 0.8, 0.2}
            end

            if mist.marker.get(i) then 
                mist.marker.remove(i)
                --groundBattle.debugMessage("Removing marker " .. i)
            end 
            mist.marker.drawZone(zones[i].name, {id=i, color=zoneColor, fillColor=fillCol, text=zones[i].name})
            --groundBattle.debugMessage("Drawing marker " .. i)
        end
    end
end

function groundBattle.listCombatZones()
    msg = {}
    msg[#msg+1] = "Combat zones:"
    for i=1, #groundBattle.combatZones do
        msg[#msg+1] = groundBattle.combatZones[i].name .. " - " .. groundBattle.combatZones[i].faction.name
    end
    groundBattle.debugMessage(table.concat(msg, "\n"))
end

function groundBattle.updateZoneFactions()
    groundBattle.updateDefences()

    for i=1, #groundBattle.combatZones do
        groundBattle.checkConflict(groundBattle.combatZones[i].name)
    end
    groundBattle.redrawMapMarks()
end

function groundBattle.combatZones.addLink(zoneName1, zoneName2)
    local zone1 = groundBattle.combatZones.getZoneByName(zoneName1)
    local zone2 = groundBattle.combatZones.getZoneByName(zoneName2)
    table.insert(zone1.links, zoneName2)
    table.insert(zone2.links, zoneName1)
end

function groundBattle.updateFrontlineZones()
    local newZones = {}
    for i=1, #groundBattle.combatZones do 
        if groundBattle.isCombatZoneFrontline(groundBattle.combatZones[i].name) then 
            table.insert(newZones, groundBattle.combatZones[i])
        end
    end
    groundBattle.combatZones.frontlineZones = newZones
end

function groundBattle.getFriendlyFrontlineZones(factionName)
    local retZones = {}
    for i=1, #groundBattle.combatZones.frontlineZones do
        if groundBattle.combatZones.frontlineZones[i].faction.name == factionName then
            table.insert(retZones, groundBattle.combatZones.frontlineZones[i])
        end
    end
    return retZones
end 

function groundBattle.getClosestFriendlyFrontlineZone(factionName, startZone)
    local zones = {}
    zones = groundBattle.getFriendlyFrontlineZones(factionName)


    
end

function groundBattle.isGroupinZone(grpName, zoneName)
    local zoneData = trigger.misc.getZone(zoneName)
    local units = Group.getByName(grpName):getUnits()
    if units and #units > 0 then 
        for i=1, #units do
            local upos = Unit.getPosition(units[i]).p
            local dist = math.sqrt(math.pow(zoneData.point.x - upos.x, 2) + math.pow(zoneData.point.z - upos.z, 2))
            if dist < zoneData.radius then 
                return true 
            end
        end
    end 
    return false
end

function groundBattle.setInvisible(grpName)
    local grp = Group.getByName(grpName)
    if grp then
        local cmd = {id = 'SetInvisible', params = {value = true}}
        local cntr = Group.getController(grp)
        Controller.setCommand(cntr, cmd)
    end
end

function groundBattle.setVisible(grpName)
    local grp = Group.getByName(grpName)
    if grp then
        local cmd = {id = 'SetInvisible', params = {value = false}}
        local cntr = Group.getController(grp)
        if cntr == nil then 
            groundBattle.debugMessage("Controller is nil!")
        end
        Controller.setCommand(cntr, cmd)
    end
end

-- production functions ------------------------------------------------------------------------------------------------

function groundBattle.initiateProduction()
    --schedule production runs for each faction
    mist.scheduleFunction(groundBattle.produceGroup, {groundBattle.factions.red}, timer.getTime() + 5, groundBattle.prodTime/100*groundBattle.factions.red.prodTimePerc)
    mist.scheduleFunction(groundBattle.produceGroup, {groundBattle.factions.blue}, timer.getTime() + 5, groundBattle.prodTime/100*groundBattle.factions.blue.prodTimePerc)
end 

function groundBattle.produceGroup(faction, zoneName)

    --remove entries for dead groups
    groundBattle.freeProdSlots(faction)

    --check if max ground groups reached
    if #faction.groundGroups >= faction.groundGroupsLimit then 
        return
    end

    --randomize group type, get proper faction groups templates and randomize the template to clone
    local groupTemplates = {}
    local groupType = ""

    local randomNumber = math.random(1, 100)
    if randomNumber <= faction.apcPerc then
        groupTemplates = faction.groundTemplates.apc
        groupType = "apc"
    elseif randomNumber <= (faction.apcPerc + faction.ifvPerc) then
        groupTemplates = faction.groundTemplates.ifv
        groupType = "ifv"
    elseif randomNumber <= (faction.apcPerc + faction.ifvPerc + faction.mbtPerc) then
        groupTemplates = faction.groundTemplates.mbt
        groupType = "mbt"
    end

    local groupToSpawnName = groupTemplates[math.random(1, #groupTemplates)]
    ---- groundBattle.debugMessage("Ground group to spawn: " .. groupToSpawnName, 5)
    
    --get faction controlled zones and randomize zone to spawn the group in
    local zoneNames 
    if zoneName then
        zoneNames[#zoneNames+1] = zoneName
    else
        zoneNames = groundBattle.getFactionProdZoneNames(faction.name)
    end
    if #zoneNames == 0 then
        return 
    end

    local spawnZoneName = zoneNames[math.random(1, #zoneNames)]
    ---- groundBattle.debugMessage("Spawn zone name: " .. spawnZoneName, 5)

    --spawn the group
    local grp = mist.cloneInZone(groupToSpawnName, spawnZoneName)
    -- groundBattle.debugMessage("Group spawned. Name: " .. grp.name)

    --register the group in faction
    table.insert(faction.groundGroups, {name=grp.name, zoneName=spawnZoneName, order="none", factionName=faction.name, type=groupType})
    -- groundBattle.debugMessage(string.format("Faction groups: %d", #faction.groundGroups))
end 

function groundBattle.getFactionProdZoneNames(factionName)
    local returnZoneNames = {}
    for i=1, #groundBattle.prodZoneNames do
        local zone = groundBattle.combatZones.getZoneByName(groundBattle.prodZoneNames[i])
        if zone.faction.name == factionName then
            table.insert(returnZoneNames, zone.name)
        end
    end
    return returnZoneNames
end 

function groundBattle.freeProdSlots(faction)
    local toRemove = {}

    for i=1, #faction.groundGroups do
        local grp = Group.getByName(faction.groundGroups[i].name)

        if grp == nil or #Group.getUnits(grp) == 0 then 
            table.insert(toRemove, i)
        end 
    end

    if #toRemove > 0 then
        for i=1, #toRemove do 
            table.remove(faction.groundGroups, toRemove[i])
        end 
    end
end

function groundBattle.updateDefences()
    for i=1, #groundBattle.combatZones do 
        local zone = groundBattle.combatZones[i]
        local toRemove = {}

        for j=#zone.defences, 1, -1 do 
            local grp = Group.getByName(zone.defences[j])

            if grp == nil or #Group.getUnits(grp) == 0 then
                table.remove(zone.defences, j)
            end
        end 
    end 
end

function groundBattle.spawnAAA(factionName, zoneName)
    local zone = groundBattle.combatZones.getZoneByName(zoneName)

    if zone.faction.name == factionName then
        local faction = {}
        if factionName == "red"  then
            faction = groundBattle.factions.red
        elseif factionName == "blue" then 
            faction = groundBattle.factions.blue
        else
            return
        end 

        for i=1, faction.aaaCount do
            if #faction.groundTemplates.aaa > 0 then
                local template = faction.groundTemplates.aaa[math.random(1, #faction.groundTemplates.aaa)]
                local grp = mist.cloneInZone(template, zoneName, true, 100)

                table.insert(zone.defences, grp.name)
            end
        end
    end
end 

function groundBattle.spawnInfantry(factionName, zoneName)
    local faction = {}
    if factionName == "red"  then
        faction = groundBattle.factions.red
    elseif factionName == "blue" then 
        faction = groundBattle.factions.blue
    else
        return
    end 

    for i=1, faction.infCount do
        -- groundBattle.debugMessage("Iterating infCount for zone " .. zoneName)
        if #faction.groundTemplates.inf > 0 then
            local template = faction.groundTemplates.inf[math.random(1, #faction.groundTemplates.inf)]
            local grp = mist.cloneInZone(template, zoneName, true, 30)

            -- if grp then 
                -- groundBattle.debugMessage("Spawning infantry group in zone " .. zoneName)
            -- end
            groundBattle.setInvisible(grp.name)
            local zone = groundBattle.combatZones.getZoneByName(zoneName)
            table.insert(zone.defences, grp.name)
        -- else
            -- groundBattle.debugMessage("No infantry templates in faction " .. factionName)
        end
    end
end

-- ground groups orders system
function groundBattle.initiateOrdersProcessing()
    mist.scheduleFunction(groundBattle.processOrders, {groundBattle.factions.red}, timer.getTime() + 10, 300)
    mist.scheduleFunction(groundBattle.processOrders, {groundBattle.factions.blue}, timer.getTime() + 10, 300)
end

function groundBattle.processOrders(faction)
    if #faction.groundGroups == 0 then 
        return
    end 
    
    --iterate through all faction groups
    -- groundBattle.debugMessage(string.format("Processing orders for %d units of faction %s", #faction.groundGroups, faction.name))
    for i=1, #faction.groundGroups do
        --check if previous orders completed
        groundBattle.checkOrderCompleted(faction.groundGroups[i].name)
        -- groundBattle.debugMessage(string.format("Order for group %s: %s", faction.groundGroups[i].name, faction.groundGroups[i].order))
        if faction.groundGroups[i].order == "none" then -- only process idle groups
            --check if combat zone is frontline
            local isFrontline = groundBattle.isCombatZoneFrontline(faction.groundGroups[i].zoneName)
            -- groundBattle.debugMessage(string.format("Processing order for group %s. Frontline zone: %s", faction.groundGroups[i].name, tostring(isFrontline)))

            --generate order 
            local order = groundBattle.decideOrder(isFrontline, faction.groundGroups[i].type)
            if order == "move" then
                local linkedZoneName = groundBattle.getRandomLinkedFriendlyZone(faction.groundGroups[i].zoneName)
                if linkedZoneName then 
                    groundBattle.giveMoveOrder(faction.groundGroups[i].name, linkedZoneName)
                    -- groundBattle.debugMessage(string.format("Move to %s order for group %s", linkedZoneName, faction.groundGroups[i].name))
                end 
            elseif order == "front" then 
                local frontlineZones = groundBattle.getFriendlyFrontlineZones(faction.name)
                if #frontlineZones > 0 then 
                    local frontlineZone = frontlineZones[math.random(1, #frontlineZones)]
                    groundBattle.giveMoveOrder(faction.groundGroups[i].name, frontlineZone.name)
                end
            elseif order == "attack" then
                local linkedZoneName = groundBattle.getRandomLinkedHostileZone(faction.groundGroups[i].zoneName)
                if linkedZoneName then 
                    groundBattle.giveAttackOrder(faction.groundGroups[i].name, linkedZoneName)
                end
            end
        elseif faction.groundGroups[i].order == "attack" then
            groundBattle.giveAttackOrder(faction.groundGroups[i].name, faction.groundGroups[i].zoneName)
        end
    end
end

function groundBattle.decideOrder(isFrontline, groupType)
    local rnd = math.random(1, 100)
    local order = "none"

    if groupType == "apc" then 
        if isFrontline and rnd > 95 then 
            order = "attack"
        elseif isFrontline and rnd > 50 then 
            order = "move"
        elseif not isFrontline and rnd > 75 then 
            order = "front"
        elseif not isFrontline and rnd > 45 then
            order = "move"
        end
    elseif groupType == "ifv" then 
        if isFrontline and rnd > 95 then 
            order = "attack"
        elseif not isFrontline then 
            order = "front"
        end 
    elseif groupType == "mbt" then 
        if isFrontline and rnd > 85 then
            order = "attack"
        elseif not isFrontline then 
            order = "front"
        end
    end

    return order
end 

function groundBattle.giveMoveOrder(groupName, zoneName)
    mist.groupToRandomZone(groupName, zoneName, "column", nil, 80, false)
    local group = groundBattle.getGroupInfoByName(groupName)
    if group then 
        group.zoneName = zoneName
        group.order = "move"
        -- groundBattle.debugMessage("Order updated to move.")
    end
end

function groundBattle.giveAttackOrder(groupName, zoneName)
    mist.groupToRandomZone(groupName, zoneName, "line", nil, 20, true)
    local group = groundBattle.getGroupInfoByName(groupName)
    if group then 
        group.zoneName = zoneName
        group.order = "attack"
        -- groundBattle.debugMessage("Order updated to attack.")
    end
end 

function groundBattle.checkOrderCompleted(groupName)
    local group = groundBattle.getGroupInfoByName(groupName)
    local zoneName = group.zoneName

    if group.order == "move" then
        if groundBattle.isGroupinZone(group.name, zoneName) then 
            group.order = "none"
        end
    elseif group.order == "attack" then
        local zoneFactionName = groundBattle.combatZones.getZoneByName(group.zoneName).faction.name
        if zoneFactionName == group.factionName and groundBattle.isGroupinZone(group.name, zoneName) then
            group.order = "none" -- battle won, order reset to none
        end
        -- groundBattle.debugMessage(string.format("Attack order completed for group: %s", groupName))
    end 
end
-- air groups orders system

-- main function to be executed after initialization is done
function groundBattle.run()
    if not groundBattle.initiated then 
        -- groundBattle.debugMessage("groundBattle not initiated.")
        return 
    end 

    mist.addEventHandler(groundBattle.eventHandler)

    groundBattle.updateFrontlineZones()

    groundBattle.redrawMapMarks()
    mist.scheduleFunction(groundBattle.updateZoneFactions, {}, timer.getTime()+5, 600)

    if not groundBattle.productionInitiated then 
        groundBattle.initiateProduction()
        groundBattle.productionInitiated = true 
    end

    groundBattle.initiateOrdersProcessing()    

    --mist.scheduleFunction(groundBattle.listCombatZones, {}, timer.getTime()+5, 60)
end 

