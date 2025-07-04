-- [[ REFINING LOGIC ]] --

local isFrozen = false

local function freezePlayer(state)
    local ped = PlayerPedId()
    isFrozen = state
    FreezeEntityPosition(ped, state)
    SetEntityInvincible(ped, state)

    if state then
        CreateThread(function()
            while isFrozen do
                DisableControlAction(0, 21, true) -- sprint
                DisableControlAction(0, 24, true) -- attack
                DisableControlAction(0, 25, true) -- aim
                DisableControlAction(0, 30, true) -- move left/right
                DisableControlAction(0, 31, true) -- move forward/back
                Wait(0)
            end
        end)
    end
end

local function playAnim(dict, clip, duration)
    local ped = PlayerPedId()
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    TaskPlayAnim(ped, dict, clip, 1.0, 1.0, duration, 1, 0, false, false, false)
end

local function runPhaseLoop(label, total, duration, animDict, animClip, onStep)
    freezePlayer(true)
    local cancelled = false

    for i = 1, total do
        SendNUIMessage({
            action = "updatePhaseProgress",
            label = label,
            current = i,
            total = total,
            duration = duration
        })

        playAnim(animDict, animClip, duration)

        local start = GetGameTimer()
        local lastCheck = 0

        while GetGameTimer() - start < duration do
            local now = GetGameTimer()
            if now - lastCheck > 100 then
                if IsControlJustPressed(0, Config.RefineryPanel.cancelKey) then
                    cancelled = true
                    break
                end
                lastCheck = now
            end
            Wait(0)
        end

        ClearPedTasksImmediately(PlayerPedId())
        if cancelled then break end

        if onStep then onStep(i) end
        Wait(100)
    end

    freezePlayer(false)
    return not cancelled
end

-- [[ PHASE 1: HOPPER LOADING ]] --
RegisterNetEvent("ZOTTERS-REFINERY:BeginHopperLoad", function(toLoad, oilType)
    if not Config.RefineryTypes[oilType] then return end

    runPhaseLoop("Loading Hopper", toLoad, Config.HopperTime,
        "anim@amb@business@cfm@cfm_drying_notes@", "loading_v2_worker",
        function()
            TriggerServerEvent("ZOTTERS-REFINERY:LoadOne")
        end
    )
end)

-- [[ PHASE 2: DISTILLATION ]] --
RegisterNetEvent("ZOTTERS-REFINERY:BeginDistillation", function(toDistill, oilType)
    local oilConfig = Config.RefineryTypes[oilType]
    if not oilConfig then return end

    local duration = oilConfig.distillTime or 4000

    local success = runPhaseLoop(
        "Distilling",
        toDistill,
        duration,
        "anim@amb@business@cfm@cfm_drying_notes@",
        "loading_v2_worker",
        function()
            TriggerServerEvent("ZOTTERS-REFINERY:DistillOne")
        end
    )
    TriggerServerEvent("ZOTTERS-REFINERY:DistillComplete")
end)

-- [[ PHASE 3: EXTRACTION ]] --
RegisterNetEvent("ZOTTERS-REFINERY:BeginExtraction", function(toExtract, resultItem, oilType)
    local oilConfig = Config.RefineryTypes[oilType]
    if not oilConfig then return end

    runPhaseLoop("Extracting", toExtract, oilConfig.extractionTime or 1500,
        "anim@amb@drug_field_workers@weeding@male_a@idles", "idle_c",
        function()
            TriggerServerEvent("ZOTTERS-REFINERY:ExtractOne", resultItem, oilType)
        end
    )
end)

-- [[ UI SYNC ]] --
RegisterNetEvent("ZOTTERS-REFINERY:UpdateUI", function(data)
    SendNUIMessage({
        action = "updateRefinery",
        payload = data
    })
    SendNUIMessage({ action = "showRefinery" })
end)

RegisterNetEvent("ZOTTERS-REFINERY:HideUI", function()
    SendNUIMessage({ action = "hideRefinery" })
end)



-- [[ DEBUG COMMANDS ]] --
