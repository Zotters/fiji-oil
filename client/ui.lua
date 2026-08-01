-- Custom UI kit: notifications, progress bar, text hints, context menu,
-- input dialog, and the Terminal shell. Replaces every ox_lib UI call.
-- Domain-specific Terminal data wiring (supplies/contracts/reputation) lives
-- in client/terminal.lua - this file only knows generic open/close mechanics.

UI = UI or {}

local activeContextOptions = nil
local inputResolve = nil

-- ============================================================
-- Notifications
-- ============================================================
RegisterNetEvent('fiji-oil:client:notify', function(data)
    UI.Notify(data)
end)

function UI.Notify(data)
    data = data or {}
    SendNUIMessage({
        action = 'notify',
        payload = {
            title = data.title or Config.OilCompany,
            description = data.description or data.message or '',
            type = data.type or 'inform',
            duration = data.duration or 5000,
        }
    })
end

-- ============================================================
-- Text hint (used by bridge.lua's proximity-interaction fallback)
-- ============================================================
function UI.ShowTextUI(label, icon)
    SendNUIMessage({ action = 'textUIShow', payload = { label = label, icon = icon } })
end

function UI.HideTextUI()
    SendNUIMessage({ action = 'textUIHide' })
end

-- ============================================================
-- Progress bar (blocking call, mirrors ox_lib's lib.progressBar ergonomics:
-- returns true on completion, false if cancelled)
-- ============================================================
local function DisableProgressControls(disable)
    if disable.move then
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 32, true)
        DisableControlAction(0, 33, true)
        DisableControlAction(0, 34, true)
        DisableControlAction(0, 35, true)
        DisableControlAction(0, 36, true)
    end

    if disable.car then
        DisableControlAction(0, 63, true)  -- VehicleAccelerate
        DisableControlAction(0, 64, true)  -- VehicleBrake
        DisableControlAction(0, 71, true)  -- VehicleAccelerate (alt)
        DisableControlAction(0, 72, true)  -- VehicleBrake (alt)
        DisableControlAction(0, 75, true)  -- VehicleExit
    end

    if disable.combat then
        DisableControlAction(0, 24, true)  -- Attack
        DisableControlAction(0, 25, true)  -- Aim
        DisableControlAction(0, 140, true) -- MeleeAttackLight
        DisableControlAction(0, 141, true) -- MeleeAttackHeavy
        DisableControlAction(0, 142, true) -- MeleeAttackAlternate
        DisableControlAction(0, 257, true) -- AttackAlternate
    end
end

function UI.ProgressBar(opts)
    opts = opts or {}
    local duration = opts.duration or 1000
    local canCancel = opts.canCancel ~= false
    local disable = opts.disable or {}
    local ped = PlayerPedId()
    local animPlaying = false

    SendNUIMessage({ action = 'progressStart', payload = { label = opts.label or '', duration = duration } })

    if opts.anim and opts.anim.dict and opts.anim.clip then
        RequestAnimDict(opts.anim.dict)
        local timeout = 0
        while not HasAnimDictLoaded(opts.anim.dict) and timeout < 50 do
            Wait(10)
            timeout = timeout + 1
        end

        if HasAnimDictLoaded(opts.anim.dict) then
            TaskPlayAnim(ped, opts.anim.dict, opts.anim.clip, 8.0, -8.0, -1, 1, 0, false, false, false)
            animPlaying = true
        end
    end

    local startTime = GetGameTimer()
    local cancelled = false

    while (GetGameTimer() - startTime) < duration do
        DisableProgressControls(disable)

        if canCancel and IsControlJustReleased(0, 202) then -- ESC
            cancelled = true
            break
        end

        Wait(0)
    end

    if animPlaying then
        ClearPedTasks(ped)
    end

    SendNUIMessage({ action = 'progressEnd' })

    return not cancelled
end

-- ============================================================
-- Context menu (fire-and-forget selection, mirrors lib.registerContext+showContext)
-- ============================================================
function UI.ContextMenu(title, options)
    activeContextOptions = options

    local displayOptions = {}
    for i, option in ipairs(options) do
        displayOptions[#displayOptions + 1] = { index = i, title = option.title, description = option.description }
    end

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'contextOpen', payload = { title = title, options = displayOptions } })
end

RegisterNUICallback('contextSelect', function(data, cb)
    SetNuiFocus(false, false)
    local options = activeContextOptions
    activeContextOptions = nil

    if options and data and data.index and options[data.index] and options[data.index].onSelect then
        options[data.index].onSelect()
    end

    cb('ok')
end)

RegisterNUICallback('contextClose', function(_, cb)
    SetNuiFocus(false, false)
    activeContextOptions = nil
    cb('ok')
end)

-- ============================================================
-- Input dialog (blocking call, mirrors lib.inputDialog: returns a table of
-- values or nil if cancelled)
-- ============================================================
function UI.InputDialog(title, fields)
    local result = nil
    local done = false

    inputResolve = function(values)
        result = values
        done = true
    end

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'inputOpen', payload = { title = title, fields = fields } })

    while not done do
        Wait(0)
    end

    return result
end

RegisterNUICallback('inputSubmit', function(data, cb)
    SetNuiFocus(false, false)
    if inputResolve then
        inputResolve(data and data.values or nil)
        inputResolve = nil
    end
    cb('ok')
end)

RegisterNUICallback('inputCancel', function(_, cb)
    SetNuiFocus(false, false)
    if inputResolve then
        inputResolve(nil)
        inputResolve = nil
    end
    cb('ok')
end)

-- ============================================================
-- Circular countdown HUD (boat rental timer, drilling rig status, etc.)
-- ============================================================
function UI.ShowCountdown(label, seconds)
    SendNUIMessage({ action = 'countdownShow', payload = { label = label, seconds = seconds } })
end

function UI.UpdateCountdown(seconds)
    SendNUIMessage({ action = 'countdownUpdate', payload = { seconds = seconds } })
end

function UI.HideCountdown()
    SendNUIMessage({ action = 'countdownHide' })
end

-- ============================================================
-- Terminal shell (open/close mechanics only)
-- ============================================================
function UI.OpenTerminalShell(staticPayload)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'terminalOpen', payload = staticPayload })
end

function UI.CloseTerminalShell()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'terminalClose' })
end

RegisterNUICallback('terminalClose', function(_, cb)
    UI.CloseTerminalShell()
    cb('ok')
end)
