RegisterNetEvent('fiji-oil:server:claimTerminal', function()
    local source = source
    local identifier = Fiji.GetIdentifier(source)
    if not identifier then return end

    local hasTerminal = Fiji.HasItem(source, Config.TerminalItem)
    if hasTerminal then
        Fiji.Notify(source, "You already have a Globe Oil Terminal.", "error")
        return
    end

    if Fiji.AddItem(source, Config.TerminalItem, 1) then
        EnsureReputationRow(identifier, 'globe_oil')
        Fiji.Notify(source, "You've been issued a Globe Oil Terminal. Use it any time to manage supplies, contracts, and reputation.", "success")
    else
        -- Fiji.AddItem already logs the precise reason (unregistered item vs.
        -- actually full/overweight) to the server console - don't guess here.
        Fiji.Notify(source, "Failed to issue your Terminal. Contact staff if this persists.", "error")
    end
end)

Callback.Register('fiji-oil:terminal:getState', function(source)
    local identifier = Fiji.GetIdentifier(source)
    return BuildFullState(source, identifier)
end)

-- Fiji.RegisterUsableItem inspects the detected Inventory/Framework, which
-- loader.lua only finishes setting up ~500ms after resource start - wait
-- past that (same pattern V1's server/main.lua used) before registering.
CreateThread(function()
    Wait(1000)

    Fiji.RegisterUsableItem(Config.TerminalItem, function(source)
        TriggerClientEvent('fiji-oil:client:openTerminal', source)
    end)
end)
