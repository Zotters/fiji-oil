local isRefining = false
local showConsole = false
local refineryState = {
    phase = 0,
    oilType = nil,
    hopperCount = 0,
    distilledCount = 0,
    extractedCount = 0
}
local Fiji = require 'bridge'

RegisterNetEvent('fiji-oil:client:openHopperMenu')
AddEventHandler('fiji-oil:client:openHopperMenu', function()
    OpenHopperMenu()
end)

RegisterNetEvent('fiji-oil:client:startDistillation')
AddEventHandler('fiji-oil:client:startDistillation', function()
    StartDistillation()
end)

RegisterNetEvent('fiji-oil:client:startExtraction')
AddEventHandler('fiji-oil:client:startExtraction', function()
    StartExtraction()
end)

RegisterNetEvent('fiji-oil:client:updateRefineryState')
AddEventHandler('fiji-oil:client:updateRefineryState', function(state)
    refineryState = state
    
    if showConsole then
        SendNUIMessage({
            action = "updateRefinery",
            payload = {
                oilLabel = GetOilLabel(refineryState.oilType),
                hopperCount = refineryState.hopperCount or 0,
                maxFill = Config.HopperFill,
                phase = GetPhaseLabel(refineryState.phase),
                position = Config.RefineryPanel.position
            }
        })
    end
end)

function OpenHopperMenu()
    if isRefining then
        lib.notify({
            title = Config.OilCompany,
            description = 'Refinery is busy',
            type = 'error'
        })
        return
    end
    
    lib.callback('fiji-oil:server:getAvailableOil', false, function(oilData)
        if not oilData or #oilData == 0 then
            lib.notify({
                title = Config.OilCompany,
                description = "You don't have any crude oil",
                type = 'error'
            })
            return
        end
        
        local options = {}
        for _, oil in ipairs(oilData) do
            table.insert(options, {
                title = "Load " .. oil.label,
                description = "You have " .. oil.count .. "x " .. oil.label,
                onSelect = function()
                    LoadHopper(oil.name, oil.count)
                end
            })
        end
        
        lib.registerContext({
            id = 'refinery_hopper_menu',
            title = 'Select Oil Type',
            options = options
        })
        
        lib.showContext('refinery_hopper_menu')
    end)
end

function LoadHopper(oilType, availableCount)
    if isRefining then return end
    
    lib.callback('fiji-oil:server:getRefineryState', false, function(state)
        refineryState = state or {
            phase = 0,
            oilType = nil,
            hopperCount = 0,
            distilledCount = 0,
            extractedCount = 0
        }
        
        if refineryState.oilType and refineryState.oilType ~= oilType then
            lib.notify({
                title = Config.OilCompany,
                description = "Cannot mix different oil types",
                type = 'error'
            })
            return
        end
        
        local maxLoad = Config.HopperFill - (refineryState.hopperCount or 0)
        local toLoad = math.min(availableCount, maxLoad)
        
        if toLoad <= 0 then
            lib.notify({
                title = Config.OilCompany,
                description = "Hopper is already full",
                type = 'error'
            })
            return
        end
        
        isRefining = true
        
        local loaded = 0
        local cancelled = false
        
        for i = 1, toLoad do
            if i > 1 and not showConsole then
                showConsole = true
                SendNUIMessage({
                    action = "showRefinery"
                })
                SendNUIMessage({
                    action = "updateRefinery",
                    payload = {
                        oilLabel = GetOilLabel(oilType),
                        hopperCount = refineryState.hopperCount or 0,
                        maxFill = Config.HopperFill,
                        phase = "Loading",
                        position = Config.RefineryPanel.position
                    }
                })
            end
            
            if lib.progressBar({
                duration = Config.HopperTime,
                label = 'Loading Hopper (' .. i .. '/' .. toLoad .. ')',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = {
                    dict = 'anim@amb@business@cfm@cfm_drying_notes@',
                    clip = 'loading_v2_worker'
                },
            }) then
                TriggerServerEvent('fiji-oil:server:loadHopper', oilType)
                loaded = loaded + 1
                
                if i == 1 then
                    showConsole = true
                    SendNUIMessage({
                        action = "showRefinery"
                    })
                    Wait(100)
                    SendNUIMessage({
                        action = "updateRefinery",
                        payload = {
                            oilLabel = GetOilLabel(oilType),
                            hopperCount = 1,
                            maxFill = Config.HopperFill,
                            phase = "Loading",
                            position = Config.RefineryPanel.position
                        }
                    })
                end
            else
                cancelled = true
                break
            end
        end
        
        isRefining = false
        
        showConsole = false
        SendNUIMessage({
            action = "hideRefinery"
        })
        
        if cancelled then
            lib.notify({
                title = Config.OilCompany,
                description = 'Hopper loading cancelled after loading ' .. loaded .. ' units',
                type = 'inform'
            })
        else
            lib.notify({
                title = Config.OilCompany,
                description = 'Successfully loaded ' .. loaded .. ' units into the hopper',
                type = 'success'
            })
        end
    end)
end

function StartDistillation()
    if isRefining then return end
    
    lib.callback('fiji-oil:server:getRefineryState', false, function(state)
        refineryState = state or {
            phase = 0,
            oilType = nil,
            hopperCount = 0,
            distilledCount = 0,
            extractedCount = 0
        }
        
        if not refineryState.oilType or refineryState.hopperCount <= 0 then
            lib.notify({
                title = Config.OilCompany,
                description = "Hopper is empty",
                type = 'error'
            })
            return
        end
        
        isRefining = true
        
        showConsole = true
        SendNUIMessage({
            action = "showRefinery"
        })
        SendNUIMessage({
            action = "updateRefinery",
            payload = {
                oilLabel = GetOilLabel(refineryState.oilType),
                hopperCount = refineryState.hopperCount or 0,
                maxFill = Config.HopperFill,
                phase = "Distilling",
                position = Config.RefineryPanel.position
            }
        })
        
        local oilConfig = Config.RefineryTypes[refineryState.oilType]
        if not oilConfig then
            lib.notify({
                title = Config.OilCompany,
                description = "Invalid oil type",
                type = 'error'
            })
            isRefining = false
            showConsole = false
            SendNUIMessage({
                action = "hideRefinery"
            })
            return
        end
        
        local toDistill = refineryState.hopperCount
        local distilled = 0
        local cancelled = false
        
        for i = 1, toDistill do
            if lib.progressBar({
                duration = oilConfig.distillTime,
                label = 'Distilling Oil (' .. i .. '/' .. toDistill .. ')',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = {
                    dict = 'anim@amb@business@cfm@cfm_drying_notes@',
                    clip = 'loading_v2_worker'
                },
            }) then
                TriggerServerEvent('fiji-oil:server:distillOne')
                distilled = distilled + 1
            else
                cancelled = true
                break
            end
        end
        
        isRefining = false
        
        showConsole = false
        SendNUIMessage({
            action = "hideRefinery"
        })
        
        TriggerServerEvent('fiji-oil:server:distillComplete')
        
        if cancelled then
            lib.notify({
                title = Config.OilCompany,
                description = 'Distillation cancelled after processing ' .. distilled .. ' units',
                type = 'inform'
            })
        else
            lib.notify({
                title = Config.OilCompany,
                description = 'Successfully distilled ' .. distilled .. ' units of oil',
                type = 'success'
            })
        end
    end)
end

function StartExtraction()
    if isRefining then return end
    
    lib.callback('fiji-oil:server:getRefineryState', false, function(state)
        refineryState = state or {
            phase = 0,
            oilType = nil,
            hopperCount = 0,
            distilledCount = 0,
            extractedCount = 0
        }
        
        local toExtract = (refineryState.distilledCount or 0) - (refineryState.extractedCount or 0)
        if toExtract <= 0 then
            lib.notify({
                title = Config.OilCompany,
                description = "No distilled oil to extract",
                type = 'error'
            })
            return
        end
        
        isRefining = true
        
        local oilConfig = Config.RefineryTypes[refineryState.oilType]
        if not oilConfig then
            lib.notify({
                title = Config.OilCompany,
                description = "Invalid oil type",
                type = 'error'
            })
            isRefining = false
            return
        end
        
        local extracted = 0
        local cancelled = false
        
        for i = 1, toExtract do
            if lib.progressBar({
                duration = oilConfig.extractionTime,
                label = 'Extracting Oil (' .. i .. '/' .. toExtract .. ')',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = {
                    dict = 'anim@amb@drug_field_workers@weeding@male_a@idles',
                    clip = 'idle_c'
                },
            }) then
                TriggerServerEvent('fiji-oil:server:extractOil', refineryState.oilType)
                extracted = extracted + 1
            else
                cancelled = true
                break
            end
        end
        
        isRefining = false
        
        if cancelled then
            lib.notify({
                title = Config.OilCompany,
                description = 'Extraction cancelled after extracting ' .. extracted .. ' units',
                type = 'inform'
            })
        else
            lib.notify({
                title = Config.OilCompany,
                description = 'Successfully extracted ' .. extracted .. ' units of refined oil',
                type = 'success'
            })
        end
    end)
end

function GetOilLabel(oilType)
    if not oilType then return "None" end
    
    for _, oil in ipairs(Config.OilTypes) do
        if oil.name == oilType then
            return oil.label
        end
    end
    return "Unknown Oil"
end

function GetPhaseLabel(phase)
    local phaseLabels = {
        [0] = "Idle",
        [1] = "Loading",
        [2] = "Distilling",
        [3] = "Extracting"
    }
    return phaseLabels[phase or 0] or "Idle"
end

