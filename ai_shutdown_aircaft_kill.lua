
  local e = {}
  function e:onEvent(event)
    if event.id == 19 then -- engine shutdown event
        local unit = event.initiator
        if unit.getCoalition(unit) == 1 then -- only destroys RED units
            unit.destroy(unit)
        end
    end 
  end
  world.addEventHandler(e)
