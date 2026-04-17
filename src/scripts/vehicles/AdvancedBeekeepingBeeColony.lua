AdvancedBeekeepingBeeColony = {}

function AdvancedBeekeepingBeeColony.prerequisitesPresent(specializations)
    return true
end

function AdvancedBeekeepingBeeColony.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", AdvancedBeekeepingBeeColony)
end

function AdvancedBeekeepingBeeColony:onLoad(savegame)
    local spec = {
        beePopulation = 50000,
        queenPresent = true,
        isConsumable = true,
        isInsertedIntoHive = false
    }

    self.spec_advancedBeekeepingBeeColony = spec
    self.advancedBeekeepingBeeColony = spec
end

function AdvancedBeekeepingBeeColony.getBeePopulation(vehicle)
    local spec = vehicle ~= nil and vehicle.spec_advancedBeekeepingBeeColony
    return spec ~= nil and spec.beePopulation or 0
end

function AdvancedBeekeepingBeeColony.getQueenPresent(vehicle)
    local spec = vehicle ~= nil and vehicle.spec_advancedBeekeepingBeeColony
    return spec ~= nil and spec.queenPresent == true
end

function AdvancedBeekeepingBeeColony.isBeeColonyBox(vehicle)
    return vehicle ~= nil and vehicle.spec_advancedBeekeepingBeeColony ~= nil
end
