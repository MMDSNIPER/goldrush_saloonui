RegisterCommand('managesaloon', function()
    local saloonName = "armadillo"
    lib.callback('saloon:getSalonData', false, function(salonData)
        local input = lib.inputDialog('Edit Details', {
            { type = 'input',    label = 'New Name',          description = 'Enter a new name for the saloon', default = salonData.name or '', required = false },
            { type = 'input',    label = 'Logo URL',          description = 'Update the saloon logo',          default = salonData.logo or '', required = false },
            { type = 'color',    label = 'Custom Menu Color', default = salonData.menuColor or '#D2B48C' },
            { type = 'checkbox', label = 'Toggle Open/Close', checked = salonData.isOpen }
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
        print(json.encode(salonData))
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
