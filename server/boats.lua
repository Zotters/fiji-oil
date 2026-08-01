local function FindTier(tierId)
    for _, tier in ipairs(Config.BoatTiers) do
        if tier.id == tierId then return tier end
    end
    return nil
end

-- Server-authoritative rental state, keyed by source. The client's countdown is
-- cosmetic only - refunds are computed from expiresAt here, never from anything
-- the client reports, otherwise a fabricated 'return' call with no real rental
-- behind it could mint cash out of nowhere.
local activeRentals = {}

Callback.Register('fiji-oil:boats:rent', function(source, payload)
    if activeRentals[source] then
        return { success = false, message = 'You already have an active boat rental.' }
    end

    local tier = payload and FindTier(payload.tierId)
    if not tier then return { success = false, message = 'Invalid boat tier.' } end

    if not Fiji.RemoveMoney(source, 'cash', tier.price, 'Fiji Oil: Boat rental') then
        return { success = false, message = "You don't have enough cash." }
    end

    activeRentals[source] = { tierId = tier.id, expiresAt = GetGameTimer() + (tier.rentalMinutes * 60000) }

    return { success = true }
end)

Callback.Register('fiji-oil:boats:return', function(source, payload)
    local rental = activeRentals[source]
    if not rental then return { refund = 0 } end

    local tier = FindTier(rental.tierId)
    activeRentals[source] = nil
    if not tier then return { refund = 0 } end

    local remainingMs = math.max(0, rental.expiresAt - GetGameTimer())
    local totalMs = tier.rentalMinutes * 60000
    local unusedRatio = totalMs > 0 and (remainingMs / totalMs) or 0
    local refund = math.floor(tier.price * unusedRatio * Config.BoatReturnRefundPct)

    if refund > 0 then
        Fiji.AddMoney(source, 'cash', refund, 'Fiji Oil: Boat rental refund')
    end

    return { refund = refund }
end)

Callback.Register('fiji-oil:boats:expire', function(source)
    activeRentals[source] = nil
    return {}
end)

AddEventHandler('playerDropped', function()
    local source = source
    activeRentals[source] = nil
end)
