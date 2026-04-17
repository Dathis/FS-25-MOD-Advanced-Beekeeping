AdvancedBeekeepingFrameBox = {}

function AdvancedBeekeepingFrameBox.prerequisitesPresent(specializations)
    return true
end

function AdvancedBeekeepingFrameBox.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", AdvancedBeekeepingFrameBox)
    SpecializationUtil.registerEventListener(vehicleType, "loadFromXMLFile", AdvancedBeekeepingFrameBox)
    SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", AdvancedBeekeepingFrameBox)
    SpecializationUtil.registerEventListener(vehicleType, "onReadStream", AdvancedBeekeepingFrameBox)
    SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", AdvancedBeekeepingFrameBox)
    SpecializationUtil.registerEventListener(vehicleType, "onReadUpdateStream", AdvancedBeekeepingFrameBox)
    SpecializationUtil.registerEventListener(vehicleType, "onWriteUpdateStream", AdvancedBeekeepingFrameBox)
end

function AdvancedBeekeepingFrameBox.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getName", AdvancedBeekeepingFrameBox.getName)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getFullName", AdvancedBeekeepingFrameBox.getFullName)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "showInfo", AdvancedBeekeepingFrameBox.showInfo)
end

function AdvancedBeekeepingFrameBox.registerSavegameXMLPaths(schema, basePath)
    schema:register(XMLValueType.INT, basePath .. ".advancedBeekeepingFrameBox#emptyFrames", "Stored empty frames")
    schema:register(XMLValueType.INT, basePath .. ".advancedBeekeepingFrameBox#fullFrames", "Stored full frames")
end

function AdvancedBeekeepingFrameBox:onLoad(savegame)
    local spec = {
        capacity = 15,
        emptyFrames = 15,
        fullFrames = 0,
        isFrameBox = true,
        frameNodes = {},
        frameVisualNodes = {},
        dirtyFlag = self.getNextDirtyFlag ~= nil and self:getNextDirtyFlag() or nil
    }

    for i = 1, spec.capacity do
        local mappingId = string.format("honeycomb_empty%02d", i)
        local fallbackPath = string.format("0>4|0|%d", i - 1)
        local node = AdvancedBeekeepingFrameBox.getMappedNode(self, mappingId, fallbackPath)

        if node ~= nil then
            table.insert(spec.frameNodes, node)
            spec.frameVisualNodes[node] = AdvancedBeekeepingFrameBox.collectNodeTree(node)
        end
    end

    self.spec_advancedBeekeepingFrameBox = spec
    self.advancedBeekeepingFrameBox = spec

    AdvancedBeekeepingFrameBox.updateVisuals(self)
    AdvancedBeekeepingFrameBox.updateFillUnitState(self)
end

function AdvancedBeekeepingFrameBox:loadFromXMLFile(xmlFile, key)
    local spec = self.spec_advancedBeekeepingFrameBox

    if spec == nil then
        return
    end

    spec.emptyFrames = xmlFile:getValue(key .. ".advancedBeekeepingFrameBox#emptyFrames", spec.emptyFrames)
    spec.fullFrames = xmlFile:getValue(key .. ".advancedBeekeepingFrameBox#fullFrames", spec.fullFrames)
    AdvancedBeekeepingFrameBox.sanitizeFrameCounts(spec)

    AdvancedBeekeepingFrameBox.updateVisuals(self)
    AdvancedBeekeepingFrameBox.updateFillUnitState(self)
end

function AdvancedBeekeepingFrameBox:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_advancedBeekeepingFrameBox

    if spec == nil then
        return
    end

    xmlFile:setValue(key .. ".advancedBeekeepingFrameBox#emptyFrames", spec.emptyFrames)
    xmlFile:setValue(key .. ".advancedBeekeepingFrameBox#fullFrames", spec.fullFrames)
end

function AdvancedBeekeepingFrameBox:onReadStream(streamId, connection)
    local spec = self.spec_advancedBeekeepingFrameBox
    if spec == nil then
        return
    end

    spec.emptyFrames = AdvancedBeekeepingFrameBox.readFrameCount(streamId)
    spec.fullFrames = AdvancedBeekeepingFrameBox.readFrameCount(streamId)
    AdvancedBeekeepingFrameBox.sanitizeFrameCounts(spec)
    AdvancedBeekeepingFrameBox.updateVisuals(self)
    AdvancedBeekeepingFrameBox.updateFillUnitState(self)
end

function AdvancedBeekeepingFrameBox:onWriteStream(streamId, connection)
    local spec = self.spec_advancedBeekeepingFrameBox
    if spec == nil then
        return
    end

    AdvancedBeekeepingFrameBox.writeFrameCount(streamId, spec.emptyFrames)
    AdvancedBeekeepingFrameBox.writeFrameCount(streamId, spec.fullFrames)
end

function AdvancedBeekeepingFrameBox:onReadUpdateStream(streamId, timestamp, connection)
    local spec = self.spec_advancedBeekeepingFrameBox
    if spec == nil or streamReadBool == nil then
        return
    end

    if streamReadBool(streamId) then
        spec.emptyFrames = AdvancedBeekeepingFrameBox.readFrameCount(streamId)
        spec.fullFrames = AdvancedBeekeepingFrameBox.readFrameCount(streamId)
        AdvancedBeekeepingFrameBox.sanitizeFrameCounts(spec)
        AdvancedBeekeepingFrameBox.updateVisuals(self)
        AdvancedBeekeepingFrameBox.updateFillUnitState(self)
    end
end

function AdvancedBeekeepingFrameBox:onWriteUpdateStream(streamId, connection, dirtyMask)
    local spec = self.spec_advancedBeekeepingFrameBox
    if spec == nil or streamWriteBool == nil then
        return
    end

    local hasUpdate = AdvancedBeekeepingFrameBox.getDirtyMaskHasFlag(dirtyMask, spec.dirtyFlag)
    streamWriteBool(streamId, hasUpdate)

    if hasUpdate then
        AdvancedBeekeepingFrameBox.writeFrameCount(streamId, spec.emptyFrames)
        AdvancedBeekeepingFrameBox.writeFrameCount(streamId, spec.fullFrames)
    end
end

function AdvancedBeekeepingFrameBox.isFrameBox(vehicle)
    return vehicle ~= nil and vehicle.spec_advancedBeekeepingFrameBox ~= nil
end

function AdvancedBeekeepingFrameBox.getCapacity(vehicle)
    local spec = vehicle ~= nil and vehicle.spec_advancedBeekeepingFrameBox
    return spec ~= nil and spec.capacity or 0
end

function AdvancedBeekeepingFrameBox.getEmptyFrames(vehicle)
    local spec = vehicle ~= nil and vehicle.spec_advancedBeekeepingFrameBox
    return spec ~= nil and spec.emptyFrames or 0
end

function AdvancedBeekeepingFrameBox.getFullFrames(vehicle)
    local spec = vehicle ~= nil and vehicle.spec_advancedBeekeepingFrameBox
    return spec ~= nil and spec.fullFrames or 0
end

function AdvancedBeekeepingFrameBox.getFrameCount(vehicle)
    return AdvancedBeekeepingFrameBox.getEmptyFrames(vehicle) + AdvancedBeekeepingFrameBox.getFullFrames(vehicle)
end

function AdvancedBeekeepingFrameBox.getFreeCapacity(vehicle)
    return math.max(0, AdvancedBeekeepingFrameBox.getCapacity(vehicle) - AdvancedBeekeepingFrameBox.getFrameCount(vehicle))
end

function AdvancedBeekeepingFrameBox.addEmptyFrames(vehicle, amount)
    return AdvancedBeekeepingFrameBox.addFrames(vehicle, amount, true)
end

function AdvancedBeekeepingFrameBox.addFullFrames(vehicle, amount)
    return AdvancedBeekeepingFrameBox.addFrames(vehicle, amount, false)
end

function AdvancedBeekeepingFrameBox.addFrames(vehicle, amount, addEmptyFrames)
    local spec = vehicle ~= nil and vehicle.spec_advancedBeekeepingFrameBox
    amount = math.max(0, math.floor(amount or 0))

    if spec == nil or amount == 0 then
        return 0
    end

    local acceptedAmount = math.min(amount, AdvancedBeekeepingFrameBox.getFreeCapacity(vehicle))

    if addEmptyFrames == true then
        spec.emptyFrames = spec.emptyFrames + acceptedAmount
    else
        spec.fullFrames = spec.fullFrames + acceptedAmount
    end

    if acceptedAmount > 0 then
        AdvancedBeekeepingFrameBox.syncState(vehicle)
    end

    return acceptedAmount
end

function AdvancedBeekeepingFrameBox.removeEmptyFrames(vehicle, amount)
    return AdvancedBeekeepingFrameBox.removeFrames(vehicle, amount, true)
end

function AdvancedBeekeepingFrameBox.removeFullFrames(vehicle, amount)
    return AdvancedBeekeepingFrameBox.removeFrames(vehicle, amount, false)
end

function AdvancedBeekeepingFrameBox.removeFrames(vehicle, amount, removeEmptyFrames)
    local spec = vehicle ~= nil and vehicle.spec_advancedBeekeepingFrameBox
    amount = math.max(0, math.floor(amount or 0))

    if spec == nil or amount == 0 then
        return 0
    end

    if removeEmptyFrames == true then
        local removedAmount = math.min(amount, spec.emptyFrames)
        spec.emptyFrames = spec.emptyFrames - removedAmount
        if removedAmount > 0 then
            AdvancedBeekeepingFrameBox.syncState(vehicle)
        end
        return removedAmount
    end

    local removedAmount = math.min(amount, spec.fullFrames)
    spec.fullFrames = spec.fullFrames - removedAmount
    if removedAmount > 0 then
        AdvancedBeekeepingFrameBox.syncState(vehicle)
    end
    return removedAmount
end

function AdvancedBeekeepingFrameBox.syncState(vehicle)
    local spec = vehicle ~= nil and vehicle.spec_advancedBeekeepingFrameBox
    if spec == nil then
        return
    end

    AdvancedBeekeepingFrameBox.sanitizeFrameCounts(spec)
    AdvancedBeekeepingFrameBox.updateVisuals(vehicle)
    AdvancedBeekeepingFrameBox.updateFillUnitState(vehicle)

    if vehicle.raiseDirtyFlags ~= nil and spec.dirtyFlag ~= nil then
        vehicle:raiseDirtyFlags(spec.dirtyFlag)
    end
end

function AdvancedBeekeepingFrameBox.updateVisuals(vehicle)
    local spec = vehicle ~= nil and vehicle.spec_advancedBeekeepingFrameBox

    if spec == nil or spec.frameNodes == nil then
        return
    end

    local visibleFrames = AdvancedBeekeepingFrameBox.getFrameCount(vehicle)
    for index, node in ipairs(spec.frameNodes) do
        if node ~= nil then
            local isVisible = index <= visibleFrames
            AdvancedBeekeepingFrameBox.setNodeTreeVisibility(spec.frameVisualNodes[node], isVisible)
        end
    end
end

function AdvancedBeekeepingFrameBox.updateFillUnitState(vehicle)
    local spec = vehicle ~= nil and vehicle.spec_advancedBeekeepingFrameBox
    if spec == nil then
        return
    end

    local frameCount = AdvancedBeekeepingFrameBox.getFrameCount(vehicle)

    if vehicle.setFillUnitFillLevel ~= nil then
        local farmId = vehicle.getOwnerFarmId ~= nil and vehicle:getOwnerFarmId() or 0
        local fillTypeIndex = AdvancedBeekeepingFrameBox.getFillTypeIndex("HONEY")
        local success = pcall(vehicle.setFillUnitFillLevel, vehicle, farmId, 1, frameCount, fillTypeIndex)

        if success then
            return
        end
    end

    if vehicle.setMassDirty ~= nil then
        vehicle:setMassDirty()
    end
end

function AdvancedBeekeepingFrameBox.getFillTypeIndex(fillTypeName)
    if g_fillTypeManager ~= nil and g_fillTypeManager.getFillTypeIndexByName ~= nil then
        return g_fillTypeManager:getFillTypeIndexByName(fillTypeName)
    end

    if FillType ~= nil and FillType.UNKNOWN ~= nil then
        return FillType.UNKNOWN
    end

    return 0
end

function AdvancedBeekeepingFrameBox.collectNodeTree(rootNode)
    local nodes = {}

    local function collect(node)
        if node == nil or node == 0 then
            return
        end

        table.insert(nodes, node)

        if getNumOfChildren ~= nil and getChildAt ~= nil then
            for i = 0, getNumOfChildren(node) - 1 do
                collect(getChildAt(node, i))
            end
        end
    end

    collect(rootNode)

    return nodes
end

function AdvancedBeekeepingFrameBox.setNodeTreeVisibility(nodes, isVisible)
    if nodes == nil then
        return 0
    end

    local touchedNodes = 0

    for _, node in ipairs(nodes) do
        if node ~= nil and node ~= 0 then
            setVisibility(node, isVisible)
            touchedNodes = touchedNodes + 1
        end
    end

    return touchedNodes
end

function AdvancedBeekeepingFrameBox.sanitizeFrameCounts(spec)
    if spec == nil then
        return
    end

    spec.emptyFrames = math.max(0, math.min(spec.capacity, math.floor(spec.emptyFrames or 0)))
    spec.fullFrames = math.max(0, math.min(spec.capacity - spec.emptyFrames, math.floor(spec.fullFrames or 0)))
end

function AdvancedBeekeepingFrameBox.getDirtyMaskHasFlag(dirtyMask, dirtyFlag)
    if dirtyMask == nil or dirtyFlag == nil then
        return false
    end

    if bitAND ~= nil then
        return bitAND(dirtyMask, dirtyFlag) ~= 0
    end

    return dirtyMask == dirtyFlag
end

function AdvancedBeekeepingFrameBox.writeFrameCount(streamId, count)
    count = math.max(0, math.floor(count or 0))

    if streamWriteUIntN ~= nil then
        streamWriteUIntN(streamId, count, 5)
    elseif streamWriteInt32 ~= nil then
        streamWriteInt32(streamId, count)
    end
end

function AdvancedBeekeepingFrameBox.readFrameCount(streamId)
    if streamReadUIntN ~= nil then
        return streamReadUIntN(streamId, 5)
    end

    if streamReadInt32 ~= nil then
        return streamReadInt32(streamId)
    end

    return 0
end

function AdvancedBeekeepingFrameBox:getName(superFunc)
    return AdvancedBeekeepingFrameBox.getText("storeItem_frameBox", "Frame Box")
end

function AdvancedBeekeepingFrameBox:getFullName(superFunc)
    return AdvancedBeekeepingFrameBox.getText("storeItem_frameBox", "Frame Box")
end

function AdvancedBeekeepingFrameBox:showInfo(superFunc, box)
    if superFunc ~= nil then
        superFunc(self, box)
    end

    if box == nil or box.addLine == nil then
        return
    end

    local spec = self.spec_advancedBeekeepingFrameBox
    if spec == nil then
        return
    end

    local totalFrames = AdvancedBeekeepingFrameBox.getFrameCount(self)
    box:addLine(AdvancedBeekeepingFrameBox.getText("advancedBeekeeping_frameBoxInfo_frames", "Frames"), string.format("%d / %d", totalFrames, spec.capacity or 0))
    box:addLine(AdvancedBeekeepingFrameBox.getText("advancedBeekeeping_frameBoxInfo_emptyFrames", "Empty frames"), tostring(spec.emptyFrames or 0))
    box:addLine(AdvancedBeekeepingFrameBox.getText("advancedBeekeeping_frameBoxInfo_fullFrames", "Full frames"), tostring(spec.fullFrames or 0))
end

function AdvancedBeekeepingFrameBox.getMappedNode(vehicle, mappingId, fallbackPath)
    if vehicle == nil then
        return nil, "noVehicle"
    end

    if vehicle.i3dMappings ~= nil then
        local mapping = vehicle.i3dMappings[mappingId]
        local node = nil

        if type(mapping) == "table" then
            node = mapping.node or mapping[1]
        elseif mapping ~= nil then
            node = mapping
        end

        node = AdvancedBeekeepingFrameBox.getNodeFromValue(node)

        if AdvancedBeekeepingFrameBox.isValidNode(node) then
            return node
        end
    end

    if vehicle.xmlFile ~= nil then
        local mappingIndex = AdvancedBeekeepingFrameBox.getMappingIndex(vehicle, mappingId)

        if mappingIndex >= 0 then
            local key = string.format("vehicle.i3dMappings.i3dMapping(%d)#node", mappingIndex)
            local node = vehicle.xmlFile:getValue(key, nil, vehicle.components, vehicle.i3dMappings)

            if node ~= nil then
                node = AdvancedBeekeepingFrameBox.getNodeFromValue(node)

                if AdvancedBeekeepingFrameBox.isValidNode(node) then
                    return node
                end
            end
        end
    end

    local fallbackNode = AdvancedBeekeepingFrameBox.getNodeByPath(vehicle, fallbackPath)
    if AdvancedBeekeepingFrameBox.isValidNode(fallbackNode) then
        return fallbackNode
    end

    local namedNode = AdvancedBeekeepingFrameBox.findChildByName(vehicle, mappingId)
    if AdvancedBeekeepingFrameBox.isValidNode(namedNode) then
        return namedNode
    end

    return nil
end

function AdvancedBeekeepingFrameBox.getMappingIndex(vehicle, mappingId)
    if vehicle == nil or vehicle.xmlFile == nil then
        return -1
    end

    local index = 0
    while true do
        local key = string.format("vehicle.i3dMappings.i3dMapping(%d)", index)
        local id = vehicle.xmlFile:getValue(key .. "#id")

        if id == nil then
            return -1
        end

        if id == mappingId then
            return index
        end

        index = index + 1
    end
end

function AdvancedBeekeepingFrameBox.getNodeFromValue(value)
    if type(value) == "table" then
        return value.node or value[1]
    end

    return value
end

function AdvancedBeekeepingFrameBox.isValidNode(node)
    return type(node) == "number" and node ~= 0
end

function AdvancedBeekeepingFrameBox.getNodeByPath(vehicle, path)
    if vehicle == nil or path == nil or getChildAt == nil then
        return nil
    end

    local componentIndexText, childPath = string.match(path, "^(%d+)>(.*)$")
    local componentIndex = tonumber(componentIndexText)

    if componentIndex == nil or vehicle.components == nil or vehicle.components[componentIndex + 1] == nil then
        return nil
    end

    local node = vehicle.components[componentIndex + 1].node

    for childIndexText in string.gmatch(childPath or "", "%d+") do
        local childIndex = tonumber(childIndexText)

        if childIndex == nil or node == nil or node == 0 then
            return nil
        end

        if getNumOfChildren ~= nil and childIndex >= getNumOfChildren(node) then
            return nil
        end

        node = getChildAt(node, childIndex)
    end

    return node
end

function AdvancedBeekeepingFrameBox.findChildByName(vehicle, nodeName)
    if vehicle == nil or nodeName == nil or getNumOfChildren == nil or getChildAt == nil or getName == nil then
        return nil
    end

    local function scan(node)
        if not AdvancedBeekeepingFrameBox.isValidNode(node) then
            return nil
        end

        if getName(node) == nodeName then
            return node
        end

        for i = 0, getNumOfChildren(node) - 1 do
            local foundNode = scan(getChildAt(node, i))
            if foundNode ~= nil then
                return foundNode
            end
        end

        return nil
    end

    if vehicle.components ~= nil then
        for _, component in pairs(vehicle.components) do
            if component ~= nil then
                local foundNode = scan(component.node)
                if foundNode ~= nil then
                    return foundNode
                end
            end
        end
    end

    return scan(vehicle.rootNode)
end

function AdvancedBeekeepingFrameBox.getText(key, fallback)
    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local text = g_i18n:getText(key)
        if text ~= nil and text ~= "" and text ~= key then
            return text
        end
    end

    return fallback or key
end
