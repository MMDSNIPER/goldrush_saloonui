RegisterCommand('managesaloon', function()
    local saloonName = "armadillo"
    local saloonData = lib.callback.await('saloon:getSalonData', false, saloonName)
    lib.registerContext({
        id = 'saloon_management',
        title = saloonData.name .. " Management",
        options = {
            {
                title = 'Edit information',
                description = 'edit saloon name, colors, logo and...',
                icon = 'info',
                onSelect = function()
                    lib.callback('saloon:getSalonData', false, function(salonData)
                        local input = lib.inputDialog('Edit Details', {
                            { type = 'input',    label = 'New Name',          description = 'Enter a new name for the saloon', default = salonData.name or '', required = false },
                            { type = 'input',    label = 'Logo URL',          description = 'Update the saloon logo',          default = salonData.logo or '', required = false },
                            { type = 'color',    label = 'Custom Menu Color', default = salonData.menuColor or '#D2B48C' },
                            { type = 'checkbox', label = 'Toggle Open/Close', checked = salonData.isOpen },
                        })

                        if input then
                            local newName = input[1]
                            local logourl = input[2]
                            local newColor = input[3]
                            local toggleclose = input[4]

                            if newName and newName ~= "" then
                                TriggerServerEvent("saloon:updateSalon", saloonName, "name", newName)
                            end
                            if newColor then
                                TriggerServerEvent("saloon:updateSalon", saloonName, "menuColor", newColor)
                            end
                            if toggleclose ~= nil then
                                TriggerServerEvent("saloon:updateSalon", saloonName, "isOpen", toggleclose)
                            end
                            if logourl then
                                TriggerServerEvent("saloon:updateSalon", saloonName, "logo", logourl)
                            end
                        end
                    end, saloonName)
                end,
            },
            {
                title = 'Add item',
                description = 'add item to saloon',
                icon = 'plus',
                onSelect = function()
                    local newinput = lib.inputDialog('Add new item', {
                        { type = 'input', label = 'Add New Item Name',        description = 'Enter the name of the new item',        required = false },
                        { type = 'input', label = 'Add New Item Price',       description = 'Enter the price of the new item',       required = false },
                        { type = 'input', label = 'Add New Item Description', description = 'Enter the description of the new item', required = false },
                        { type = 'input', label = 'Add New Item Image',       description = 'Enter the image URL of the new item',   required = false },
                        {
                            type = 'select',
                            label = 'Select Category',
                            description = 'Choose the category for the new item',
                            options = {
                                { label = 'foods',  value = 'foods' },
                                { label = 'combos', value = 'combos' },
                                { label = 'others', value = 'others' }
                            }
                        },
                    })
                    if newinput then
                        local newItemName = newinput[1]
                        local newItemPrice = tonumber(newinput[2]) -- تبدیل به عدد
                        local newItemDescription = newinput[3]
                        local newItemImage = newinput[4]
                        local selectedCategory = newinput[5]
                        -- افزودن آیتم جدید به سالون
                        if newItemName and newItemPrice and newItemDescription and newItemImage and selectedCategory then
                            local newItem = {
                                name = newItemName,
                                price = newItemPrice,
                                description = newItemDescription,
                                image = newItemImage,
                                color = selectedCategory == "foods" and "#8B4513" or
                                    (selectedCategory == "combos" and "#CD853F" or "#8B4513")
                            }

                            TriggerServerEvent("saloon:addItem", saloonName, selectedCategory, newItem)
                        end
                    end
                end,
            },
            {
                title = 'Remove item',
                description = 'remove item from saloon menu!',
                menu = 'remove_menu',
                icon = 'trash'
            },
        }
    })
    local itemlist = {}
    itemlist[#itemlist + 1] = {
        title = "Foods & Drinks",
        disabled = true,
    }
    for index, value in ipairs(saloonData.foods) do
        itemlist[#itemlist + 1] = {
            title = value.name,
            description = 'foods',
            event = 'removeitemfromsaloon',
            args = {
                name = value.name,
                category = 'foods',
                saloonName = saloonName
            }
        }
    end
    itemlist[#itemlist + 1] = {
        title = "Combos",
        disabled = true
    }
    for index, value in ipairs(saloonData.combos) do
        itemlist[#itemlist + 1] = {
            title = value.name,
            description = 'combos',
            event = 'removeitemfromsaloon',
            args = {
                name = value.name,
                category = 'foods',
                saloonName = saloonName
            }
        }
    end
    itemlist[#itemlist + 1] = {
        title = "Others",
        disabled = true
    }
    for index, value in ipairs(saloonData.others) do
        itemlist[#itemlist + 1] = {
            title = value.name,
            description = 'others',
            event = 'removeitemfromsaloon',
            args = {
                name = value.name,
                category = 'foods',
                saloonName = saloonName
            }
        }
    end
    lib.registerContext({
        id = 'remove_menu',
        title = 'List of items to remove',
        menu = 'saloon_management',
        options = itemlist,
    })
    lib.showContext('saloon_management')
end)

RegisterNetEvent('removeitemfromsaloon', function(data)
    TriggerServerEvent("saloon:removeItem", data.saloonName, data.category, data.name)
end)

RegisterNetEvent("saloon:notifyUpdate")
AddEventHandler("saloon:notifyUpdate", function(saloonName, key, value)
    lib.notify({
        title = saloonName .. " Updated!",
        description = key .. " was changed to: " .. tostring(value),
        icon = 'info-circle',
        position = 'top-right'
    })
end)

RegisterCommand('opensaloon', function()
    local saloonName = "armadillo"
    lib.callback('saloon:getSalonData', false, function(salonData)
        if salonData.isOpen == false then
            return lib.notify({
                title = salonData.name,
                description = 'Saloon is close!',
                icon = 'info-circle',
                position = 'top-right'
            })
        end
        SendNUIMessage({
            type = "open",
            data = salonData
        })
        SetNuiFocus(true, true)
    end, saloonName)
end, false)

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
