-- local json = require("json")

-- local function loadSalons()
--     local config = LoadResourceFile(GetCurrentResourceName(), "config.json")
--     return json.decode(config)
-- end

-- local function saveSalons(data)
--     SaveResourceFile(GetCurrentResourceName(), "config.json", json.encode(data, {indent = true}), -1)
-- end

-- RegisterServerEvent("saloon:loadSalon")
-- AddEventHandler("saloon:loadSalon", function(salonName)
--     local src = source
--     local salons = loadSalons().salons

--     if salons[salonName] then
--         TriggerClientEvent("saloon:openUI", src, salons[salonName])
--     else
--         TriggerClientEvent("saloon:error", src, "Saloon not found!")
--     end
-- end)

-- RegisterServerEvent("saloon:updateSalon")
-- AddEventHandler("saloon:updateSalon", function(salonName, key, value)
--     local salons = loadSalons()
--     if salons.salons[salonName] then
--         salons.salons[salonName][key] = value
--         saveSalons(salons)
--         TriggerClientEvent("saloon:syncSalon", -1, salonName, salons.salons[salonName])
--     end
-- end)
-- RegisterServerEvent("saloon:loadSalon")
-- AddEventHandler("saloon:loadSalon", function(salonName)
--     local src = source
--     local config = LoadResourceFile(GetCurrentResourceName(), "config.json")
--     local salons = json.decode(config).salons

--     if salons[salonName] then
--         TriggerClientEvent("saloon:showMenu", src, salons[salonName])
--     else
--         TriggerClientEvent("saloon:showMenu", src, {name = "Saloon Not Found", logo = ""})
--     end
-- end)

local salonsData = json.decode(LoadResourceFile(GetCurrentResourceName(), "config.json"))

lib.callback.register('saloon:getSalonData', function(source, saloon)
    salonsData = json.decode(LoadResourceFile(GetCurrentResourceName(), "config.json"))
    return salonsData.salons[saloon]
end)

RegisterServerEvent("saloon:updateSalon")
AddEventHandler("saloon:updateSalon", function(saloonName, updates)
    local src = source
    if not salonsData.salons[saloonName] then
        print(("Attempt to update non-existent saloon '%s' by player %s"):format(saloonName, src))
        return
    end

    local updatedKeys = {}
    for key, value in pairs(updates) do
        salonsData.salons[saloonName][key] = value
        table.insert(updatedKeys, key)
    end

    local success, err = pcall(function()
        SaveResourceFile(GetCurrentResourceName(), "config.json", json.encode(salonsData, { indent = true }), -1)
    end)

    if not success then
        print(("Error saving saloon data: %s"):format(err))
        return
    end

    for _, key in ipairs(updatedKeys) do
        TriggerClientEvent("saloon:notifyUpdate", -1, saloonName, key, salonsData.salons[saloonName][key])
    end

    print(("Saloon '%s' updated successfully by player %s"):format(saloonName, src))
end)

RegisterServerEvent("saloon:addItem")
AddEventHandler("saloon:addItem", function(saloonName, category, item)
    local salonsData = json.decode(LoadResourceFile(GetCurrentResourceName(), "config.json"))

    if salonsData.salons[saloonName] then
        table.insert(salonsData.salons[saloonName][category], item)
        SaveResourceFile(GetCurrentResourceName(), "config.json", json.encode(salonsData, { indent = true }), -1)
        TriggerClientEvent("saloon:notifyUpdate", -1, saloonName, category, item)
    end
end)

RegisterServerEvent("saloon:removeItem")
AddEventHandler("saloon:removeItem", function(saloonName, category, itemName)
    local salonsData = json.decode(LoadResourceFile(GetCurrentResourceName(), "config.json"))

    if salonsData.salons[saloonName] then
        for i, item in ipairs(salonsData.salons[saloonName][category]) do
            if item.name == itemName then
                table.remove(salonsData.salons[saloonName][category], i)
                SaveResourceFile(GetCurrentResourceName(), "config.json", json.encode(salonsData, { indent = true }), -1)
                TriggerClientEvent("saloon:notifyUpdate", -1, saloonName, category, itemName, "removed")
                break
            end
        end
    end
end)
