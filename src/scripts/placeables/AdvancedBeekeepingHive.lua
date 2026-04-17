AdvancedBeekeepingHive = {}

AdvancedBeekeepingHive.SPEC_NAME = "advancedBeekeepingHive"
AdvancedBeekeepingHive.DEFAULT_CAPACITY = 15
AdvancedBeekeepingHive.DEFAULT_INTERACTION_RADIUS = 3
AdvancedBeekeepingHive.DEFAULT_INTERACTION_HALF_WIDTH = 1.45
AdvancedBeekeepingHive.DEFAULT_INTERACTION_HALF_LENGTH = 1.45
AdvancedBeekeepingHive.DEFAULT_MINUTES_PER_FRAME = 1
AdvancedBeekeepingHive.DEFAULT_INFO_DISPLAY_DISTANCE = 5
AdvancedBeekeepingHive.activeHives = {}
AdvancedBeekeepingHive.didRegisterModEventListener = false

function AdvancedBeekeepingHive.prerequisitesPresent(specializations)
    return true
end

function AdvancedBeekeepingHive.registerEventListeners(placeableType)
    SpecializationUtil.registerEventListener(placeableType, "onLoad", AdvancedBeekeepingHive)
    SpecializationUtil.registerEventListener(placeableType, "onDelete", AdvancedBeekeepingHive)
    SpecializationUtil.registerEventListener(placeableType, "onFinalizePlacement", AdvancedBeekeepingHive)
    SpecializationUtil.registerEventListener(placeableType, "onUpdate", AdvancedBeekeepingHive)
    SpecializationUtil.registerEventListener(placeableType, "onUpdateTick", AdvancedBeekeepingHive)
    SpecializationUtil.registerEventListener(placeableType, "loadFromXMLFile", AdvancedBeekeepingHive)
    SpecializationUtil.registerEventListener(placeableType, "saveToXMLFile", AdvancedBeekeepingHive)
end

function AdvancedBeekeepingHive.registerFunctions(placeableType)
    SpecializationUtil.registerFunction(placeableType, "advancedBeekeepingHiveInteractionTriggerCallback", AdvancedBeekeepingHive.advancedBeekeepingHiveInteractionTriggerCallback)
end

function AdvancedBeekeepingHive.registerOverwrittenFunctions(placeableType)
end

function AdvancedBeekeepingHive.registerXMLPaths(schema, basePath)
    schema:setXMLSpecializationType("AdvancedBeekeepingHive")
    schema:register(XMLValueType.NODE_INDEX, basePath .. ".advancedBeekeepingHive#interactionNode", "Node used as the center for automatic hive interactions", nil)
    schema:register(XMLValueType.NODE_INDEX, basePath .. ".advancedBeekeepingHive#interactionTriggerNode", "Trigger node used for automatic item interactions", nil)
    schema:register(XMLValueType.NODE_INDEX, basePath .. ".advancedBeekeepingHive#playerTriggerNode", "Node used as the center for the hive information overlay", nil)
    schema:register(XMLValueType.FLOAT, basePath .. ".advancedBeekeepingHive#interactionRadius", "Interaction radius in meters", AdvancedBeekeepingHive.DEFAULT_INTERACTION_RADIUS)
    schema:register(XMLValueType.FLOAT, basePath .. ".advancedBeekeepingHive#interactionHalfWidth", "Half width of the rear interaction zone", AdvancedBeekeepingHive.DEFAULT_INTERACTION_HALF_WIDTH)
    schema:register(XMLValueType.FLOAT, basePath .. ".advancedBeekeepingHive#interactionHalfLength", "Half length of the rear interaction zone", AdvancedBeekeepingHive.DEFAULT_INTERACTION_HALF_LENGTH)
    schema:register(XMLValueType.FLOAT, basePath .. ".advancedBeekeepingHive#infoDisplayDistance", "Distance for hive information interaction", AdvancedBeekeepingHive.DEFAULT_INFO_DISPLAY_DISTANCE)
    schema:register(XMLValueType.INT, basePath .. ".advancedBeekeepingHive#capacity", "Maximum stored frames", AdvancedBeekeepingHive.DEFAULT_CAPACITY)
    schema:register(XMLValueType.FLOAT, basePath .. ".advancedBeekeepingHive#minutesPerFrame", "In-game minutes required to fill one frame", AdvancedBeekeepingHive.DEFAULT_MINUTES_PER_FRAME)
    schema:setXMLSpecializationType()
end

function AdvancedBeekeepingHive.registerSavegameXMLPaths(schema, basePath)
    schema:register(XMLValueType.INT, basePath .. ".advancedBeekeepingHive#beePopulation", "Stored bee population")
    schema:register(XMLValueType.BOOL, basePath .. ".advancedBeekeepingHive#queenPresent", "Queen is present")
    schema:register(XMLValueType.INT, basePath .. ".advancedBeekeepingHive#emptyFrames", "Stored empty frames")
    schema:register(XMLValueType.INT, basePath .. ".advancedBeekeepingHive#fullFrames", "Stored full frames")
    schema:register(XMLValueType.FLOAT, basePath .. ".advancedBeekeepingHive#productionProgressMs", "Current frame production progress")
end

function AdvancedBeekeepingHive:onLoad(savegame)
    local capacity = self.xmlFile:getValue("placeable.advancedBeekeepingHive#capacity", AdvancedBeekeepingHive.DEFAULT_CAPACITY)

    local spec = {
        capacity = capacity,
        interactionRadius = self.xmlFile:getValue("placeable.advancedBeekeepingHive#interactionRadius", AdvancedBeekeepingHive.DEFAULT_INTERACTION_RADIUS),
        interactionHalfWidth = self.xmlFile:getValue("placeable.advancedBeekeepingHive#interactionHalfWidth", AdvancedBeekeepingHive.DEFAULT_INTERACTION_HALF_WIDTH),
        interactionHalfLength = self.xmlFile:getValue("placeable.advancedBeekeepingHive#interactionHalfLength", AdvancedBeekeepingHive.DEFAULT_INTERACTION_HALF_LENGTH),
        interactionNode = self.xmlFile:getValue("placeable.advancedBeekeepingHive#interactionNode", nil, self.components, self.i3dMappings),
        interactionTriggerNode = self.xmlFile:getValue("placeable.advancedBeekeepingHive#interactionTriggerNode", nil, self.components, self.i3dMappings),
        playerTriggerNode = self.xmlFile:getValue("placeable.advancedBeekeepingHive#playerTriggerNode", nil, self.components, self.i3dMappings),
        infoDisplayDistance = self.xmlFile:getValue("placeable.advancedBeekeepingHive#infoDisplayDistance", AdvancedBeekeepingHive.DEFAULT_INFO_DISPLAY_DISTANCE),
        productionMsPerFrame = self.xmlFile:getValue("placeable.advancedBeekeepingHive#minutesPerFrame", AdvancedBeekeepingHive.DEFAULT_MINUTES_PER_FRAME) * 60000,

        beePopulation = 0,
        queenPresent = false,
        emptyFrames = 0,
        fullFrames = 0,
        productionProgressMs = 0,
        productionLastDayTime = nil,
        interactionTimerMs = 0,
        playerRangeTimerMs = 0,

        playerInRange = false,
        triggerObjects = {},

        info = {
            status = { title = AdvancedBeekeepingHive.getText("advancedBeekeeping_info_status"), text = "" },
            bees = { title = AdvancedBeekeepingHive.getText("advancedBeekeeping_info_bees"), text = "" },
            queen = { title = AdvancedBeekeepingHive.getText("advancedBeekeeping_info_queen"), text = "" },
            emptyFrames = { title = AdvancedBeekeepingHive.getText("advancedBeekeeping_info_emptyFrames"), text = "" },
            fullFrames = { title = AdvancedBeekeepingHive.getText("advancedBeekeeping_info_fullFrames"), text = "" },
            warning = { title = AdvancedBeekeepingHive.getText("advancedBeekeeping_info_warning"), text = "" }
        }
    }

    spec.interactionNode = AdvancedBeekeepingHive.getNodeFromValue(spec.interactionNode) or self.rootNode
    spec.interactionTriggerNode = AdvancedBeekeepingHive.getNodeFromValue(spec.interactionTriggerNode)
    spec.playerTriggerNode = AdvancedBeekeepingHive.getNodeFromValue(spec.playerTriggerNode)

    self.spec_advancedBeekeepingHive = spec
    AdvancedBeekeepingHive.ensureModEventListener()
    AdvancedBeekeepingHive.activeHives[self] = self

    if spec.interactionTriggerNode ~= nil and addTrigger ~= nil then
        addTrigger(spec.interactionTriggerNode, "advancedBeekeepingHiveInteractionTriggerCallback", self)
    end

    if self.raiseActive ~= nil then
        self:raiseActive()
    end
end

function AdvancedBeekeepingHive:onDelete()
    local spec = self.spec_advancedBeekeepingHive

    if spec ~= nil then
        if spec.interactionTriggerNode ~= nil and removeTrigger ~= nil then
            removeTrigger(spec.interactionTriggerNode)
        end

        AdvancedBeekeepingHive.activeHives[self] = nil
    end
end

function AdvancedBeekeepingHive:onFinalizePlacement(savegame)
    if AdvancedBeekeepingHive.isServerObject(self) and self.raiseActive ~= nil then
        self:raiseActive()
    end
end

function AdvancedBeekeepingHive:loadFromXMLFile(xmlFile, key)
    local spec = self.spec_advancedBeekeepingHive
    if spec == nil then
        return
    end

    spec.beePopulation = math.max(0, xmlFile:getValue(key .. ".advancedBeekeepingHive#beePopulation", spec.beePopulation))
    spec.queenPresent = xmlFile:getValue(key .. ".advancedBeekeepingHive#queenPresent", spec.queenPresent)
    spec.emptyFrames = math.max(0, math.min(spec.capacity, xmlFile:getValue(key .. ".advancedBeekeepingHive#emptyFrames", spec.emptyFrames)))
    spec.fullFrames = math.max(0, math.min(spec.capacity - spec.emptyFrames, xmlFile:getValue(key .. ".advancedBeekeepingHive#fullFrames", spec.fullFrames)))
    spec.productionProgressMs = math.max(0, xmlFile:getValue(key .. ".advancedBeekeepingHive#productionProgressMs", spec.productionProgressMs))
end

function AdvancedBeekeepingHive:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_advancedBeekeepingHive
    if spec == nil then
        return
    end

    xmlFile:setValue(key .. ".advancedBeekeepingHive#beePopulation", spec.beePopulation)
    xmlFile:setValue(key .. ".advancedBeekeepingHive#queenPresent", spec.queenPresent)
    xmlFile:setValue(key .. ".advancedBeekeepingHive#emptyFrames", spec.emptyFrames)
    xmlFile:setValue(key .. ".advancedBeekeepingHive#fullFrames", spec.fullFrames)
    xmlFile:setValue(key .. ".advancedBeekeepingHive#productionProgressMs", spec.productionProgressMs)
end

function AdvancedBeekeepingHive:onUpdate(dt)
    local spec = self.spec_advancedBeekeepingHive

    if spec ~= nil then
        AdvancedBeekeepingHive.updatePlayerInfoRange(self, dt)

        if self.raiseActive ~= nil then
            self:raiseActive()
        end
    end
end

function AdvancedBeekeepingHive:onUpdateTick(dt)
    AdvancedBeekeepingHive.updateRuntime(self, dt)
end

function AdvancedBeekeepingHive:advancedBeekeepingHiveInteractionTriggerCallback(triggerId, otherId, onEnter, onLeave, onStay, otherShapeId)
    local spec = self.spec_advancedBeekeepingHive
    if spec == nil then
        return
    end

    local object = AdvancedBeekeepingHive.getObjectFromNode(otherId)
    if object == nil or object == self then
        return
    end

    if onLeave then
        spec.triggerObjects[object] = nil
        return
    end

    if onEnter or onStay then
        if not AdvancedBeekeepingHive.isObjectInsideInteractionZone(self, object) then
            spec.triggerObjects[object] = nil
            return
        end

        spec.triggerObjects[object] = object

        if AdvancedBeekeepingHive.isServerObject(self) then
            AdvancedBeekeepingHive.tryAcceptBeeColony(self, object)
            AdvancedBeekeepingHive.tryTransferFrames(self, object)
        end
    end
end

function AdvancedBeekeepingHive.updateRuntime(placeable, dt)
    local spec = placeable.spec_advancedBeekeepingHive
    if spec == nil then
        return
    end

    AdvancedBeekeepingHive.updatePlayerInfoRange(placeable, dt)

    if AdvancedBeekeepingHive.isServerObject(placeable) then
        spec.interactionTimerMs = spec.interactionTimerMs + dt

        if spec.interactionTimerMs >= 1000 then
            spec.interactionTimerMs = 0
            AdvancedBeekeepingHive.processTriggerItems(placeable)
            AdvancedBeekeepingHive.processRearZoneItems(placeable)
        end

        AdvancedBeekeepingHive.updateProduction(placeable, dt)

        if placeable.raiseActive ~= nil then
            placeable:raiseActive()
        end
    end
end

function AdvancedBeekeepingHive.processTriggerItems(placeable)
    local spec = placeable.spec_advancedBeekeepingHive
    if spec == nil or spec.triggerObjects == nil then
        return
    end

    for object in pairs(spec.triggerObjects) do
        if object ~= nil and object.isDeleted ~= true and AdvancedBeekeepingHive.isObjectInsideInteractionZone(placeable, object) then
            AdvancedBeekeepingHive.tryAcceptBeeColony(placeable, object)
            AdvancedBeekeepingHive.tryTransferFrames(placeable, object)
        else
            spec.triggerObjects[object] = nil
        end
    end
end

function AdvancedBeekeepingHive.processRearZoneItems(placeable)
    local spec = placeable.spec_advancedBeekeepingHive
    if spec == nil or g_currentMission == nil then
        return
    end

    local vehicles = AdvancedBeekeepingHive.getMissionVehicles()

    for _, vehicle in pairs(vehicles) do
        if AdvancedBeekeepingHive.isInteractionCandidate(vehicle) and vehicle ~= placeable and vehicle.isDeleted ~= true then
            local isInside = AdvancedBeekeepingHive.getInteractionZoneCheck(placeable, vehicle)

            if isInside then
                AdvancedBeekeepingHive.tryAcceptBeeColony(placeable, vehicle)
                AdvancedBeekeepingHive.tryTransferFrames(placeable, vehicle)
            end
        end
    end
end

function AdvancedBeekeepingHive.isInteractionCandidate(vehicle)
    if vehicle == nil then
        return false
    end

    return (AdvancedBeekeepingFrameBox ~= nil and AdvancedBeekeepingFrameBox.isFrameBox(vehicle))
        or (AdvancedBeekeepingBeeColony ~= nil and AdvancedBeekeepingBeeColony.isBeeColonyBox(vehicle))
end

function AdvancedBeekeepingHive.isObjectInsideInteractionZone(placeable, object)
    local isInside = AdvancedBeekeepingHive.getInteractionZoneCheck(placeable, object)
    return isInside == true
end

function AdvancedBeekeepingHive.getInteractionZoneCheck(placeable, object)
    local spec = placeable ~= nil and placeable.spec_advancedBeekeepingHive
    local objectNodes = AdvancedBeekeepingHive.getVehicleCheckNodes(object)

    if spec == nil or spec.interactionNode == nil or #objectNodes == 0 then
        return false
    end

    local ix, iy, iz = getWorldTranslation(spec.interactionNode)

    for _, node in ipairs(objectNodes) do
        local ox, oy, oz = getWorldTranslation(node)
        local distance = math.sqrt(AdvancedBeekeepingHive.getDistanceSquared(ix, iy, iz, ox, oy, oz))
        local isInside = false

        if worldToLocal ~= nil then
            local lx, _, lz = worldToLocal(spec.interactionNode, ox, oy, oz)
            isInside = math.abs(lx) <= (spec.interactionHalfWidth or AdvancedBeekeepingHive.DEFAULT_INTERACTION_HALF_WIDTH)
                and math.abs(lz) <= (spec.interactionHalfLength or AdvancedBeekeepingHive.DEFAULT_INTERACTION_HALF_LENGTH)
        else
            local maxDistance = spec.interactionRadius or AdvancedBeekeepingHive.DEFAULT_INTERACTION_RADIUS
            isInside = distance <= maxDistance
        end

        if isInside then
            return true
        end
    end

    return false
end

function AdvancedBeekeepingHive.tryAcceptBeeColony(placeable, vehicle)
    local spec = placeable.spec_advancedBeekeepingHive

    if spec == nil then
        return false
    end

    if AdvancedBeekeepingBeeColony == nil or not AdvancedBeekeepingBeeColony.isBeeColonyBox(vehicle) then
        return false
    end

    if spec.beePopulation > 0 then
        return false
    end

    if AdvancedBeekeepingHive.getFrameCount(placeable) == 0 then
        return false
    end

    spec.beePopulation = math.max(0, AdvancedBeekeepingBeeColony.getBeePopulation(vehicle) or 0)
    spec.queenPresent = AdvancedBeekeepingBeeColony.getQueenPresent(vehicle) == true

    if vehicle.delete ~= nil then
        vehicle:delete()
    end

    return true
end

function AdvancedBeekeepingHive.tryTransferFrames(placeable, vehicle)
    local spec = placeable.spec_advancedBeekeepingHive

    if spec == nil then
        return false
    end

    if AdvancedBeekeepingFrameBox == nil or not AdvancedBeekeepingFrameBox.isFrameBox(vehicle) then
        return false
    end

    local changed = false
    local freeHiveSlots = AdvancedBeekeepingHive.getFreeCapacity(placeable)
    local emptyFramesInBox = math.max(0, AdvancedBeekeepingFrameBox.getEmptyFrames(vehicle) or 0)

    if freeHiveSlots > 0 and emptyFramesInBox > 0 then
        local amount = math.min(freeHiveSlots, emptyFramesInBox)
        local removed = math.max(0, AdvancedBeekeepingFrameBox.removeEmptyFrames(vehicle, amount) or 0)

        if removed > 0 then
            spec.emptyFrames = math.min(spec.capacity, spec.emptyFrames + removed)
            changed = true
        end
    end

    local fullFramesInHive = math.max(0, spec.fullFrames)
    local freeBoxSlots = math.max(0, AdvancedBeekeepingFrameBox.getFreeCapacity(vehicle) or 0)
    local currentEmptyFramesInBox = math.max(0, AdvancedBeekeepingFrameBox.getEmptyFrames(vehicle) or 0)

    if fullFramesInHive > 0 and freeBoxSlots > 0 and currentEmptyFramesInBox == 0 then
        local amount = math.min(fullFramesInHive, freeBoxSlots)
        local accepted = math.max(0, AdvancedBeekeepingFrameBox.addFullFrames(vehicle, amount) or 0)

        if accepted > 0 then
            spec.fullFrames = math.max(0, spec.fullFrames - accepted)
            changed = true
        end
    end

    return changed
end

function AdvancedBeekeepingHive.updateProduction(placeable, dt)
    local spec = placeable.spec_advancedBeekeepingHive
    if spec == nil then
        return
    end

    local blockReason = AdvancedBeekeepingHive.getProductionBlockReason(placeable)
    if blockReason ~= nil then
        spec.productionLastDayTime = AdvancedBeekeepingHive.getEnvironmentDayTime()
        return
    end

    local productionDeltaMs = AdvancedBeekeepingHive.getProductionDeltaMs(placeable, dt)
    if productionDeltaMs <= 0 then
        return
    end

    spec.productionProgressMs = spec.productionProgressMs + productionDeltaMs

    while spec.emptyFrames > 0 and spec.productionProgressMs >= spec.productionMsPerFrame do
        spec.productionProgressMs = spec.productionProgressMs - spec.productionMsPerFrame
        spec.emptyFrames = math.max(0, spec.emptyFrames - 1)
        spec.fullFrames = math.min(spec.capacity, spec.fullFrames + 1)
    end
end

function AdvancedBeekeepingHive.getProductionBlockReason(placeable)
    local spec = placeable ~= nil and placeable.spec_advancedBeekeepingHive
    if spec == nil then
        return "missing hive spec"
    end

    if spec.beePopulation <= 0 then
        return "no bees"
    end

    if spec.queenPresent ~= true then
        return "no queen"
    end

    if spec.emptyFrames <= 0 then
        return "no empty frames"
    end

    if not AdvancedBeekeepingHive.isSeasonAllowed() then
        return "season inactive"
    end

    return nil
end

function AdvancedBeekeepingHive.getProductionDeltaMs(placeable, dt)
    local spec = placeable ~= nil and placeable.spec_advancedBeekeepingHive
    if spec == nil then
        return 0
    end

    local dayTime = AdvancedBeekeepingHive.getEnvironmentDayTime()
    if dayTime ~= nil then
        if spec.productionLastDayTime == nil then
            spec.productionLastDayTime = dayTime
            return 0
        end

        local delta = dayTime - spec.productionLastDayTime
        spec.productionLastDayTime = dayTime

        if delta < 0 then
            delta = delta + 24 * 60 * 60 * 1000
        end

        return math.max(0, delta)
    end

    local timeScale = AdvancedBeekeepingHive.getMissionTimeScale()
    return math.max(0, (dt or 0) * timeScale)
end

function AdvancedBeekeepingHive.getEnvironmentDayTime()
    if g_currentMission == nil or g_currentMission.environment == nil then
        return nil
    end

    local environment = g_currentMission.environment

    if type(environment.dayTime) == "number" then
        return environment.dayTime
    end

    if type(environment.currentDayTime) == "number" then
        return environment.currentDayTime
    end

    if type(environment.currentDaytime) == "number" then
        return environment.currentDaytime
    end

    if environment.getDayTime ~= nil then
        local success, dayTime = pcall(environment.getDayTime, environment)
        if success and type(dayTime) == "number" then
            return dayTime
        end
    end

    return nil
end

function AdvancedBeekeepingHive.getMissionTimeScale()
    if g_currentMission ~= nil then
        if g_currentMission.missionInfo ~= nil and type(g_currentMission.missionInfo.timeScale) == "number" then
            return math.max(1, g_currentMission.missionInfo.timeScale)
        end

        if type(g_currentMission.timeScale) == "number" then
            return math.max(1, g_currentMission.timeScale)
        end
    end

    return 1
end

function AdvancedBeekeepingHive.updatePlayerInfoRange(placeable, dt)
    local spec = placeable ~= nil and placeable.spec_advancedBeekeepingHive
    if spec == nil or g_currentMission == nil then
        return
    end

    spec.playerRangeTimerMs = (spec.playerRangeTimerMs or 0) + dt
    if spec.playerRangeTimerMs < 250 then
        return
    end

    spec.playerRangeTimerMs = 0

    local playerNode = AdvancedBeekeepingHive.getCurrentPlayerNode()
    local infoNode = spec.playerTriggerNode or spec.interactionNode or placeable.rootNode

    if playerNode == nil or infoNode == nil or infoNode == 0 or not entityExists(infoNode) then
        if spec.playerInRange == true then
            spec.playerInRange = false
        end

        return
    end

    local px, py, pz = getWorldTranslation(playerNode)
    local ix, iy, iz = getWorldTranslation(infoNode)
    local maxDistance = math.max(0.5, spec.infoDisplayDistance or AdvancedBeekeepingHive.DEFAULT_INFO_DISPLAY_DISTANCE)
    local isInRange = AdvancedBeekeepingHive.getDistanceSquared(px, py, pz, ix, iy, iz) <= (maxDistance * maxDistance)

    if isInRange and spec.playerInRange ~= true then
        spec.playerInRange = true
    elseif not isInRange and spec.playerInRange == true then
        spec.playerInRange = false
    end
end

function AdvancedBeekeepingHive:draw()
    if AdvancedBeekeepingHive.activeHives == nil then
        return
    end

    for placeable in pairs(AdvancedBeekeepingHive.activeHives) do
        if placeable ~= nil and placeable.isDeleted ~= true then
            local spec = placeable.spec_advancedBeekeepingHive

            if spec ~= nil and spec.playerInRange == true then
                AdvancedBeekeepingHive.drawInfoOverlay(placeable)
            end
        end
    end
end

function AdvancedBeekeepingHive.drawInfoOverlay(placeable)
    local spec = placeable ~= nil and placeable.spec_advancedBeekeepingHive
    if spec == nil or spec.playerInRange ~= true then
        return
    end

    if renderText == nil then
        return
    end

    local info = AdvancedBeekeepingHive.updateInfoRows(placeable)
    if info == nil then
        return
    end

    local rows = {
        info.status,
        info.bees,
        info.queen,
        info.emptyFrames,
        info.fullFrames
    }

    if info.warning.text ~= "" then
        table.insert(rows, info.warning)
    end

    local width = 0.235
    local padding = 0.012
    local rowHeight = 0.019
    local titleHeight = 0.024
    local height = padding * 2 + titleHeight + (#rows * rowHeight)
    local x = 1 - width - 0.015
    local y = 0.035
    local titleSize = 0.0135
    local textSize = 0.012

    AdvancedBeekeepingHive.drawRoundedInfoBackground(x, y, width, height, 0.008, 0, 0, 0, 0.52)

    renderText(x + padding, y + height - padding - titleSize, titleSize, AdvancedBeekeepingHive.getText("advancedBeekeeping_dialog_hiveInfoTitle"))

    local rowY = y + height - padding - titleHeight - textSize
    for _, row in ipairs(rows) do
        renderText(x + padding, rowY, textSize, row.title)
        renderText(x + width * 0.55, rowY, textSize, row.text or "")
        rowY = rowY - rowHeight
    end
end

function AdvancedBeekeepingHive.drawRoundedInfoBackground(x, y, width, height, radius, r, g, b, a)
    if drawFilledRect == nil then
        return
    end

    radius = math.min(radius or 0, width * 0.5, height * 0.5)

    if radius <= 0 then
        drawFilledRect(x, y, width, height, r, g, b, a)
        return
    end

    drawFilledRect(x + radius, y, width - radius * 2, height, r, g, b, a)
    drawFilledRect(x, y + radius, width, height - radius * 2, r, g, b, a)
end

function AdvancedBeekeepingHive.updateInfoRows(placeable)
    local spec = placeable.spec_advancedBeekeepingHive
    if spec == nil then
        return nil
    end

    spec.info.status.text = AdvancedBeekeepingHive.getStateText(placeable)
    spec.info.bees.text = string.format("%d", spec.beePopulation)
    spec.info.queen.text = spec.queenPresent and AdvancedBeekeepingHive.getText("advancedBeekeeping_yes") or AdvancedBeekeepingHive.getText("advancedBeekeeping_no")
    spec.info.emptyFrames.text = string.format("%d / %d", spec.emptyFrames, spec.capacity)
    spec.info.fullFrames.text = string.format("%d / %d", spec.fullFrames, spec.capacity)
    spec.info.warning.text = AdvancedBeekeepingHive.getWarningText(placeable)

    return spec.info
end

function AdvancedBeekeepingHive.isWorking(placeable)
    local spec = placeable.spec_advancedBeekeepingHive

    return spec ~= nil
        and spec.beePopulation > 0
        and spec.queenPresent == true
        and spec.emptyFrames > 0
        and AdvancedBeekeepingHive.isSeasonAllowed()
end

function AdvancedBeekeepingHive.isSeasonAllowed()
    if g_currentMission == nil or g_currentMission.environment == nil then
        return true
    end

    local environment = g_currentMission.environment

    if environment.currentSeason ~= nil and Season ~= nil then
        return environment.currentSeason == Season.SPRING or environment.currentSeason == Season.SUMMER
    end

    return true
end

function AdvancedBeekeepingHive.getState(placeable)
    local spec = placeable.spec_advancedBeekeepingHive

    if spec == nil then
        return "empty"
    end

    if spec.beePopulation > 0 and not spec.queenPresent then
        return "noQueen"
    end

    if spec.beePopulation > 0 and spec.queenPresent and spec.emptyFrames == 0 and spec.fullFrames > 0 then
        return "allFramesFilled"
    end

    if spec.beePopulation > 0 and spec.queenPresent and AdvancedBeekeepingHive.getFrameCount(placeable) > 0 and not AdvancedBeekeepingHive.isSeasonAllowed() then
        return "seasonalInactive"
    end

    if AdvancedBeekeepingHive.isWorking(placeable) then
        return "working"
    end

    if AdvancedBeekeepingHive.getFrameCount(placeable) == 0 and spec.beePopulation == 0 then
        return "empty"
    end

    if AdvancedBeekeepingHive.getFrameCount(placeable) == 0 then
        return "waitingForFrames"
    end

    if spec.beePopulation == 0 then
        return "waitingForBeeColony"
    end

    return "waitingForFrames"
end

function AdvancedBeekeepingHive.getStateText(placeable)
    return AdvancedBeekeepingHive.getText("advancedBeekeeping_status_" .. AdvancedBeekeepingHive.getState(placeable))
end

function AdvancedBeekeepingHive.getWarningText(placeable)
    if AdvancedBeekeepingHive.isWorking(placeable) then
        return ""
    end

    return AdvancedBeekeepingHive.getStateText(placeable)
end

function AdvancedBeekeepingHive.getFrameCount(placeable)
    local spec = placeable ~= nil and placeable.spec_advancedBeekeepingHive
    return spec ~= nil and (spec.emptyFrames + spec.fullFrames) or 0
end

function AdvancedBeekeepingHive.getFreeCapacity(placeable)
    local spec = placeable ~= nil and placeable.spec_advancedBeekeepingHive
    return spec ~= nil and math.max(0, spec.capacity - AdvancedBeekeepingHive.getFrameCount(placeable)) or 0
end

function AdvancedBeekeepingHive.getNodeFromValue(value)
    if type(value) == "table" then
        return value.node or value[1]
    end

    return value
end

function AdvancedBeekeepingHive.isServerObject(object)
    if object == nil then
        return false
    end

    if object.isServer ~= nil then
        return object.isServer
    end

    return g_server ~= nil
end

function AdvancedBeekeepingHive.getCurrentPlayerNode()
    if g_currentMission == nil then
        return nil
    end

    local player = g_currentMission.player

    if player ~= nil then
        return player.rootNode or player.node or player.characterNode
    end

    if g_currentMission.players ~= nil then
        for _, missionPlayer in pairs(g_currentMission.players) do
            if missionPlayer ~= nil then
                return missionPlayer.rootNode or missionPlayer.node or missionPlayer.characterNode
            end
        end
    end

    return nil
end

function AdvancedBeekeepingHive.getMissionVehicles()
    if g_currentMission == nil then
        return {}
    end

    if g_currentMission.vehicles ~= nil then
        return g_currentMission.vehicles
    end

    if g_currentMission.vehicleSystem ~= nil and g_currentMission.vehicleSystem.vehicles ~= nil then
        return g_currentMission.vehicleSystem.vehicles
    end

    return {}
end

function AdvancedBeekeepingHive.getVehicleCheckNodes(vehicle)
    local nodes = {}
    local seen = {}

    local function addNode(node)
        if node ~= nil and node ~= 0 and seen[node] ~= true then
            seen[node] = true
            table.insert(nodes, node)
        end
    end

    if vehicle == nil then
        return nodes
    end

    addNode(vehicle.rootNode)
    addNode(vehicle.node)

    if vehicle.components ~= nil then
        for _, component in pairs(vehicle.components) do
            if component ~= nil then
                addNode(component.node)
            end
        end
    end

    return nodes
end

function AdvancedBeekeepingHive.getObjectFromNode(node)
    if node == nil or g_currentMission == nil or g_currentMission.nodeToObject == nil then
        return nil
    end

    local currentNode = node

    while currentNode ~= nil and currentNode ~= 0 do
        local object = g_currentMission.nodeToObject[currentNode]

        if object ~= nil then
            return object
        end

        currentNode = getParent(currentNode)
    end

    return nil
end

function AdvancedBeekeepingHive.getDistanceSquared(x1, y1, z1, x2, y2, z2)
    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2
    return dx * dx + dy * dy + dz * dz
end

function AdvancedBeekeepingHive.getText(key)
    if g_i18n ~= nil and g_i18n.hasText ~= nil and g_i18n:hasText(key) then
        return g_i18n:getText(key)
    end

    if g_i18n ~= nil and g_i18n.getText ~= nil then
        return g_i18n:getText(key)
    end

    return key
end

function AdvancedBeekeepingHive.ensureModEventListener()
    if addModEventListener == nil or AdvancedBeekeepingHive.didRegisterModEventListener == true then
        return
    end

    addModEventListener(AdvancedBeekeepingHive)
    AdvancedBeekeepingHive.didRegisterModEventListener = true
end

AdvancedBeekeepingHive.ensureModEventListener()
