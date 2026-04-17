AdvancedBeekeepingStoreCategories = {}

AdvancedBeekeepingStoreCategories.modDirectory = g_currentModDirectory
AdvancedBeekeepingStoreCategories.modName = g_currentModName
AdvancedBeekeepingStoreCategories.didQueueModCategories = false

function AdvancedBeekeepingStoreCategories.register()
    if g_storeManager == nil then
        return
    end

    if AdvancedBeekeepingStoreCategories.didQueueModCategories == true then
        return
    end

    local modDescFile = XMLFile.load("advancedBeekeepingModDesc", AdvancedBeekeepingStoreCategories.modDirectory .. "modDesc.xml")

    if modDescFile ~= nil then
        for _, storeTypeKey in modDescFile:iterator("modDesc.storeCategories.storeType") do
            g_storeManager:loadCategoryType(modDescFile, storeTypeKey, nil)
        end

        for _, storeCategoryKey in modDescFile:iterator("modDesc.storeCategories.storeCategory") do
            g_storeManager:loadCategoryFromXML(modDescFile, storeCategoryKey, AdvancedBeekeepingStoreCategories.modDirectory, AdvancedBeekeepingStoreCategories.modName, true)
        end

        modDescFile:delete()
        AdvancedBeekeepingStoreCategories.didQueueModCategories = true
    end
end

local function loadAdvancedBeekeepingStoreCategories(storeManager, superFunc, xmlFile, missionInfo, baseDirectory)
    local result = superFunc(storeManager, xmlFile, missionInfo, baseDirectory)

    if g_storeManager ~= nil and g_storeManager.getCategoryByName ~= nil and g_storeManager:getCategoryByName("beekeeping") == nil then
        pcall(g_storeManager.addCategory, g_storeManager,
            "beekeeping",
            "Beekeeping",
            "src/xml/beehive/store_beehive.dds",
            "OBJECT",
            AdvancedBeekeepingStoreCategories.modDirectory,
            "pallets"
        )
    end

    return result
end

local function loadAdvancedBeekeepingStoreCategoriesBeforeStoreItems(typeManager, superFunc, xmlFile, key, baseDir, customEnvironment, isMod, modName)
    AdvancedBeekeepingStoreCategories.register()
    return superFunc(typeManager, xmlFile, key, baseDir, customEnvironment, isMod, modName)
end

AdvancedBeekeepingStoreCategories.register()
StoreManager.loadMapData = Utils.overwrittenFunction(StoreManager.loadMapData, loadAdvancedBeekeepingStoreCategories)

if TypeManager ~= nil and TypeManager.loadTypeFromXML ~= nil then
    TypeManager.loadTypeFromXML = Utils.overwrittenFunction(TypeManager.loadTypeFromXML, loadAdvancedBeekeepingStoreCategoriesBeforeStoreItems)
end
