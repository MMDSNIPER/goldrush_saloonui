RegisterCommand('managesaloon', function()
    local saloonName = "armadillo"
    local saloonData = lib.callback.await('saloon:getSalonData', false, saloonName)
    lib.registerContext({
        id = 'saloon_management',
        title = saloonData.name .. " Management",
        options = {
            {
                title = 'Edit information',
                description = 'Edit saloon details',
                icon = 'info',
                onSelect = function()
                    lib.callback('saloon:getSalonData', false, function(salonData)
                        local input = lib.inputDialog('Edit Details', {
                            { type = 'input',    label = 'Name',              default = salonData.name or '',                 required = true },
                            { type = 'input',    label = 'Info',              default = salonData.info or '',                 required = true },
                            { type = 'input',    label = 'Logo URL',          default = salonData.logo or '',                 required = true },
                            { type = 'color',    label = 'Background Color',  default = salonData.bgColor or '#1A0D00' },
                            { type = 'color',    label = 'Primary Color',     default = salonData.primaryColor or '#3C2A21' },
                            { type = 'color',    label = 'Secondary Color',   default = salonData.secondaryColor or '#D2B48C' },
                            { type = 'color',    label = 'Accent Color',      default = salonData.accentColor or '#8B0000' },
                            { type = 'color',    label = 'Highlight Color',   default = salonData.highlightColor or '#FFD700' },
                            { type = 'checkbox', label = 'Toggle Open/Close', checked = salonData.isOpen }
                        })

                        if input then
                            TriggerServerEvent("saloon:updateSalon", saloonName, {
                                name = input[1],
                                info = input[2],
                                logo = input[3],
                                bgColor = input[4],
                                primaryColor = input[5],
                                secondaryColor = input[6],
                                accentColor = input[7],
                                highlightColor = input[8],
                                isOpen = input[9]
                            })
                        end
                    end, saloonName)
                end,
            },
            {
                title = 'Add item',
                description = 'Add a new item to the saloon menu',
                icon = 'plus',
                onSelect = function()
                    local input = lib.inputDialog('Add New Item', {
                        { type = 'input',  label = 'Item Name',        required = true },
                        { type = 'number', label = 'Item Price',       required = true },
                        { type = 'input',  label = 'Item Description', required = true },
                        { type = 'input',  label = 'Image URL',        required = true },
                        {
                            type = 'select',
                            label = 'Category',
                            options = {
                                { label = 'Foods',  value = 'foods' },
                                { label = 'Combos', value = 'combos' },
                                { label = 'Others', value = 'others' }
                            }
                        },
                    })
                    if input then
                        local newItem = {
                            name = input[1],
                            price = input[2],
                            description = input[3],
                            image = input[4],
                            category = input[5],
                        }
                        TriggerServerEvent("saloon:addItem", saloonName, input[5], newItem)
                    end
                end,
            },
            {
                title = 'Remove item',
                description = 'Remove an item from the saloon',
                menu = 'remove_menu',
                icon = 'trash'
            },
        }
    })

    local function buildRemoveMenu(categoryName, items)
        local menu = {}
        menu[#menu + 1] = { title = categoryName, disabled = true }
        for _, item in ipairs(items) do
            menu[#menu + 1] = {
                title = item.name,
                description = 'Click to remove',
                event = 'removeitemfromsaloon',
                args = { name = item.name, category = categoryName, saloonName = saloonName }
            }
        end
        return menu
    end

    local itemlist = {}
    for _, cat in ipairs({ "foods", "combos", "others" }) do
        for _, item in ipairs(buildRemoveMenu(cat, saloonData[cat])) do
            table.insert(itemlist, item)
        end
    end

    lib.registerContext({
        id = 'remove_menu',
        title = 'Remove Items',
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
