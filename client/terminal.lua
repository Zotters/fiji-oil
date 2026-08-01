-- One-time terminal pickup at the Globe Oil HQ kiosk.
CreateThread(function()
    Wait(1500)

    Fiji.AddInteraction(
        'globe_oil_terminal_kiosk',
        { type = 'sphere', coords = Config.HQs.globe_oil.terminalKiosk, radius = 1.2 },
        {
            {
                name = 'claim_terminal',
                icon = 'fa-solid fa-tablet-screen-button',
                label = 'Register for a Globe Oil Terminal',
                onSelect = function()
                    TriggerServerEvent('fiji-oil:server:claimTerminal')
                end,
            },
        },
        Config.Debug or false
    )
end)

local function staticPayload()
    return {
        companies = Config.Companies,
        companyOrder = Config.CompanyOrder,
        hqs = Config.HQs,
        unlockThreshold = Config.UnlockThreshold,
        maxReputation = Config.MaxReputation,
        maxActiveContractsPerCompany = Config.MaxActiveContractsPerCompany,
        itemLabels = Config.ItemLabels,
    }
end

local function refreshState()
    Callback.Trigger('fiji-oil:terminal:getState', nil, function(state)
        SendNUIMessage({ action = 'terminalState', payload = state or {} })
    end)
end

RegisterNetEvent('fiji-oil:client:openTerminal', function()
    UI.OpenTerminalShell(staticPayload())
    refreshState()
end)

RegisterNUICallback('placeSupplyOrder', function(data, cb)
    Callback.Trigger('fiji-oil:supplyorders:place', data, function(state)
        cb(state or {})
    end)
end)

RegisterNUICallback('acceptContract', function(data, cb)
    Callback.Trigger('fiji-oil:companies:acceptContract', data, function(state)
        cb(state or {})
    end)
end)

RegisterNUICallback('abandonContract', function(data, cb)
    Callback.Trigger('fiji-oil:companies:abandonContract', data, function(state)
        cb(state or {})
    end)
end)

RegisterNUICallback('fulfillContract', function(data, cb)
    Callback.Trigger('fiji-oil:companies:fulfillContract', data, function(state)
        cb(state or {})
    end)
end)
