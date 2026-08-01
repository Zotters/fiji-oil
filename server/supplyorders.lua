-- Same double-fire race as server/companies.lua's contract handlers - this
-- reads then updates each ready row across separate MySQL .await yields, so
-- a rapid second trigger could re-collect the same order before the first
-- call's UPDATE lands. pcall guarantees the lock always releases.
local locked = {}

local function TryLock(source)
    if locked[source] then return false end
    locked[source] = true
    return true
end

local function Unlock(source)
    locked[source] = nil
end

AddEventHandler('playerDropped', function()
    local source = source
    locked[source] = nil
end)

local function FindCatalogEntry(companyId, item)
    local company = Config.Companies[companyId]
    if not company then return nil end

    for _, entry in ipairs(company.catalog or {}) do
        if entry.item == item then return entry end
    end

    return nil
end

-- Called from server/companies.lua's BuildFullState, and available generally.
function GetSupplyOrdersPayload(identifier)
    local rows = MySQL.query.await(
        'SELECT id, company_id, item, quantity, dropoff_hq, UNIX_TIMESTAMP(ready_at) as readyAt, status FROM fiji_oil_supply_orders WHERE identifier = ? AND status != ?',
        { identifier, 'collected' }
    )

    local orders = {}
    for _, row in ipairs(rows or {}) do
        table.insert(orders, {
            id = row.id,
            companyId = row.company_id,
            item = row.item,
            quantity = row.quantity,
            dropoffHq = row.dropoff_hq,
            readyAt = row.readyAt,
            status = row.status,
        })
    end

    return orders
end

Callback.Register('fiji-oil:supplyorders:place', function(source, payload)
    local identifier = Fiji.GetIdentifier(source)
    if not identifier or not payload then return BuildFullState(source, identifier) end

    local companyId = payload.companyId
    local item = payload.item
    local quantity = math.floor(tonumber(payload.quantity) or 0)
    local dropoffHq = payload.dropoffHq

    if quantity <= 0 or quantity > 50 then
        Fiji.Notify(source, "Invalid quantity.", "error")
        return BuildFullState(source, identifier)
    end

    if not Config.HQs[dropoffHq] then
        Fiji.Notify(source, "Invalid drop-off location.", "error")
        return BuildFullState(source, identifier)
    end

    if not IsCompanyUnlocked(identifier, companyId) then
        Fiji.Notify(source, "You haven't unlocked that company yet.", "error")
        return BuildFullState(source, identifier)
    end

    if not IsCompanyUnlocked(identifier, dropoffHq) then
        Fiji.Notify(source, "You haven't unlocked that drop-off location yet.", "error")
        return BuildFullState(source, identifier)
    end

    local entry = FindCatalogEntry(companyId, item)
    if not entry then
        Fiji.Notify(source, "That item isn't in this company's catalog.", "error")
        return BuildFullState(source, identifier)
    end

    local totalPrice = entry.price * quantity

    if not Fiji.RemoveMoney(source, 'cash', totalPrice, 'Fiji Oil: Supply order') then
        Fiji.Notify(source, "You don't have enough cash for this order.", "error")
        return BuildFullState(source, identifier)
    end

    MySQL.insert.await(
        'INSERT INTO fiji_oil_supply_orders (identifier, company_id, item, quantity, dropoff_hq, ready_at, status) VALUES (?, ?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL ? SECOND), ?)',
        { identifier, companyId, item, quantity, dropoffHq, entry.deliverySeconds, 'pending' }
    )

    local hqLabel = Config.HQs[dropoffHq] and Config.HQs[dropoffHq].label or dropoffHq
    Fiji.Notify(source, ('Order placed: %dx %s. Ready in about %d minutes at %s.'):format(
        quantity, entry.label, math.ceil(entry.deliverySeconds / 60), hqLabel
    ), "success")

    return BuildFullState(source, identifier)
end)

RegisterNetEvent('fiji-oil:server:collectSupplyOrders', function(companyId)
    local source = source
    local identifier = Fiji.GetIdentifier(source)
    if not identifier or not Config.HQs[companyId] then return end

    if not TryLock(source) then return end

    local ok, err = pcall(function()
        local rows = MySQL.query.await(
            'SELECT id, item, quantity FROM fiji_oil_supply_orders WHERE identifier = ? AND dropoff_hq = ? AND status != ? AND ready_at <= NOW()',
            { identifier, companyId, 'collected' }
        )

        if not rows or #rows == 0 then
            Fiji.Notify(source, "You don't have any orders ready for pickup here.", "inform")
            return
        end

        local collected = 0
        for _, row in ipairs(rows) do
            -- Claim this specific row atomically before granting items - if another
            -- call already collected it, this UPDATE affects 0 rows and we skip it.
            local claimed = MySQL.update.await('UPDATE fiji_oil_supply_orders SET status = ? WHERE id = ? AND status != ?', { 'collected', row.id, 'collected' })
            if claimed and claimed > 0 then
                if Fiji.AddItem(source, row.item, row.quantity) then
                    collected = collected + 1
                else
                    -- Couldn't fit it - put the order back so it isn't lost.
                    MySQL.query.await('UPDATE fiji_oil_supply_orders SET status = ? WHERE id = ?', { 'ready', row.id })
                end
            end
        end

        if collected > 0 then
            Fiji.Notify(source, ('Collected %d supply order(s).'):format(collected), "success")
        else
            Fiji.Notify(source, "Your inventory is full - couldn't collect any orders.", "error")
        end
    end)

    Unlock(source)

    if not ok then
        print(('^1[fiji-oil]^0 collectSupplyOrders error: %s'):format(tostring(err)))
    end
end)
