do
    local debug = false 

    unitsToPlace = {"T_mot_rif_1", "T_mot_rif_2", "T_tank"}
    samNames = {"T_SA9", "T_SA8", "T_SA13", "T_SA15"}
    artNames = {"T_mlrs", "T_art"}

    function randomizeUnits()
        math.random()
        local unitsTable = {"T_mot_rif_1", "T_mot_rif_2", "T_tank"}

        local sam = samNames[math.random(1,4)]
        local art = artNames[math.random(1,2)]

        table.insert(unitsTable, sam)
        table.insert(unitsTable, art)

        return unitsTable
    end

    function placeUnits(spotNameCore)
        local units = randomizeUnits()
        local spots = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}

        while #units > 0 do
            local spotNr = math.random(1, #spots)
            local spot = spots[spotNr]
            local spotName = string.format("%s-%d", spotNameCore, spot)
            local gp = mist.cloneInZone(units[#units], spotName, 200)
            if debug then 
                trigger.action.outText(spotName, 60)
            end 
            Group.activate(Group.getByName(gp.name))

            table.remove(units)
            table.remove(spots, spotNr)
        end

    end

    placeUnits("spot1")
    placeUnits("spot2")
    placeUnits("spot3")
end