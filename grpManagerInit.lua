grpManager = {}
grpManager.airGrpoupNames = {}
grpManager.actCAP = {}
grpManager.inactCAP = {}
grpManager.actCAS = {}
grpManager.inactCAS = {}
grpManager.targetCAP = 0
grpManager.targetCAS = 0
grpManager.debug = false
grpManager.keepConstActiveNumber = false

function table.findString(tab, str)
    for i, val in pairs(tab) do
        if val == str then
            return i
        end
    end
    return nil 
end 

do
    local grps = mist.getGroupsByAttribute({coalition='red'})
    for i, name in pairs(grps) do
        if string.find(name, 'CAS') then
            table.insert(grpManager.airGrpoupNames, name)
            table.insert(grpManager.inactCAS, name)
        end
        if string.find(name, 'CAP') then
            table.insert(grpManager.airGrpoupNames, name)
            table.insert(grpManager.inactCAP, name)
        end
    end

    if grpManager.debug then
        trigger.action.outText(string.format("CAP: active/inactive - %d/%d. Active target: %d", #grpManager.actCAP, #grpManager.inactCAP, grpManager.targetCAP) , 20)
        trigger.action.outText(string.format("CAS: active/inactive - %d/%d. Active target: %d", #grpManager.actCAS, #grpManager.inactCAS, grpManager.targetCAS) , 20)
        trigger.action.outText(table.concat(grpManager.airGrpoupNames, "\n"), 20)
    end
end
env.info("grpManager init complete.")