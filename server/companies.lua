-- Reputation, company unlocking, direct sales, and contract lifecycle.
-- Functions here are deliberately left as plain globals (not `local`) so
-- server/terminal.lua and server/supplyorders.lua can call straight into
-- them - all server_scripts in this resource share one Lua environment
-- per side, so exports() would just be unnecessary indirection.

-- Per-source mutation lock for the contract handlers below. Each does a
-- MySQL .await read (a real coroutine yield point) before acting on what it
-- read - double-firing the same event lets two calls both read the pre-write
-- state and both act on it (e.g. fulfilling one contract twice for double
-- reward if the player holds enough items for both). pcall guarantees the
-- lock always releases even if something inside throws.
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

-- ============================================================
-- Reputation
-- ============================================================
function EnsureReputationRow(identifier, companyId)
    MySQL.query.await('INSERT IGNORE INTO fiji_oil_reputation (identifier, company_id, reputation) VALUES (?, ?, 0)', { identifier, companyId })
end

function GetReputationTable(identifier)
    local rows = MySQL.query.await('SELECT company_id, reputation FROM fiji_oil_reputation WHERE identifier = ?', { identifier })
    local rep = {}
    for _, id in ipairs(Config.CompanyOrder) do rep[id] = 0 end
    for _, row in ipairs(rows or {}) do rep[row.company_id] = row.reputation end
    return rep
end

function GetCompanyReputation(identifier, companyId)
    local rows = MySQL.query.await('SELECT reputation FROM fiji_oil_reputation WHERE identifier = ? AND company_id = ?', { identifier, companyId })
    return rows and rows[1] and rows[1].reputation or 0
end

-- Atomically adds (or subtracts) reputation, clamped to [0, Config.MaxReputation].
function AddCompanyReputation(identifier, companyId, amount)
    if not amount or amount == 0 then return end

    local maxRep = Config.MaxReputation
    local initial = math.max(0, math.min(maxRep, amount))

    MySQL.query.await([[
        INSERT INTO fiji_oil_reputation (identifier, company_id, reputation)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE reputation = LEAST(?, GREATEST(0, reputation + ?))
    ]], { identifier, companyId, initial, maxRep, amount })
end

function GetUnlockedTable(reputation)
    local unlocked = {}
    local globeRep = reputation['globe_oil'] or 0

    for _, id in ipairs(Config.CompanyOrder) do
        local company = Config.Companies[id]
        unlocked[id] = (company.alwaysUnlocked == true) or (globeRep >= Config.UnlockThreshold)
    end

    return unlocked
end

function IsCompanyUnlocked(identifier, companyId)
    local company = Config.Companies[companyId]
    if not company then return false end
    if company.alwaysUnlocked then return true end

    return GetCompanyReputation(identifier, 'globe_oil') >= Config.UnlockThreshold
end

-- Highest perk tier this reputation value has reached for a company, or nil.
function GetCompanyPerkTier(companyId, reputation)
    local company = Config.Companies[companyId]
    if not company then return nil end

    local best = nil
    for _, tier in ipairs(company.perkTiers or {}) do
        if reputation >= tier.threshold then
            best = tier
        end
    end

    return best
end

function FindContractTemplate(companyId, contractId)
    local company = Config.Companies[companyId]
    if not company then return nil end

    for _, c in ipairs(company.contracts or {}) do
        if c.id == contractId then return c end
    end

    return nil
end

-- ============================================================
-- Aggregate state used by the Terminal UI (also called from server/terminal.lua)
-- ============================================================
local function BuildContractsPayload(source, identifier)
    local rows = MySQL.query.await('SELECT id, company_id, contract_id, progress FROM fiji_oil_player_contracts WHERE identifier = ? AND status = ?', { identifier, 'active' })
    local contracts = {}

    for _, row in ipairs(rows or {}) do
        local template = FindContractTemplate(row.company_id, row.contract_id)
        local heldCount = 0

        if template then
            local _, count = Fiji.HasItem(source, template.item)
            heldCount = count
        end

        table.insert(contracts, {
            playerContractId = row.id,
            companyId = row.company_id,
            contractId = row.contract_id,
            progress = row.progress,
            heldCount = heldCount,
            status = 'active',
        })
    end

    return contracts
end

function BuildFullState(source, identifier)
    if not identifier then return {} end

    local reputation = GetReputationTable(identifier)
    local unlocked = GetUnlockedTable(reputation)
    local contracts = BuildContractsPayload(source, identifier)
    local supplyOrders = GetSupplyOrdersPayload and GetSupplyOrdersPayload(identifier) or {}

    return {
        reputation = reputation,
        unlocked = unlocked,
        contracts = contracts,
        supplyOrders = supplyOrders,
    }
end

-- ============================================================
-- Direct sale (physical - must be at that company's trade desk)
-- ============================================================
Callback.Register('fiji-oil:companies:sell', function(source, payload)
    local identifier = Fiji.GetIdentifier(source)
    if not identifier or not payload then return { success = false } end

    local companyId = payload.companyId
    local item = payload.item
    local quantity = math.floor(tonumber(payload.quantity) or 0)

    local company = Config.Companies[companyId]
    if not company or quantity <= 0 then return { success = false } end

    if not IsCompanyUnlocked(identifier, companyId) then
        Fiji.Notify(source, "You haven't unlocked " .. company.label .. " yet.", "error")
        return { success = false }
    end

    local basePrice = company.sellPrices and company.sellPrices[item]
    if not basePrice then
        Fiji.Notify(source, company.label .. " doesn't buy that.", "error")
        return { success = false }
    end

    local hq = Config.HQs[companyId]
    if hq and hq.tradeDesk then
        local ped = GetPlayerPed(source)
        local coords = GetEntityCoords(ped)
        if #(coords - hq.tradeDesk) > 5.0 then
            Fiji.Notify(source, "You need to be at the trade desk to sell.", "error")
            return { success = false }
        end
    end

    local hasItem, count = Fiji.HasItem(source, item)
    if not hasItem or count < quantity then
        Fiji.Notify(source, "You don't have enough " .. Fiji.GetItemLabel(item) .. ".", "error")
        return { success = false }
    end

    -- Blackgold's commerce perk boosts sell price regardless of which company you sell to.
    local blackgoldTier = GetCompanyPerkTier('blackgold', GetCompanyReputation(identifier, 'blackgold'))
    local priceMultiplier = blackgoldTier and blackgoldTier.sellPriceMultiplier or 1.0
    local total = math.floor(basePrice * quantity * priceMultiplier)

    if not Fiji.RemoveItem(source, item, quantity) then
        Fiji.Notify(source, "Failed to remove items from your inventory.", "error")
        return { success = false }
    end

    Fiji.AddMoney(source, 'bank', total, 'Fiji Oil: Sale to ' .. company.label)
    AddCompanyReputation(identifier, companyId, (company.reputationPerSale or 0) * quantity)

    Fiji.Notify(source, ('Sold %dx %s to %s for $%d'):format(quantity, Fiji.GetItemLabel(item), company.label, total), "success")

    return { success = true, total = total }
end)

-- ============================================================
-- Contracts (remote - worked entirely through the Terminal)
-- ============================================================
Callback.Register('fiji-oil:companies:acceptContract', function(source, payload)
    local identifier = Fiji.GetIdentifier(source)
    if not identifier or not payload then return BuildFullState(source, identifier) end

    if not TryLock(source) then return BuildFullState(source, identifier) end

    local ok, result = pcall(function()
        local companyId = payload.companyId
        local contractId = payload.contractId
        local template = FindContractTemplate(companyId, contractId)
        if not template then return BuildFullState(source, identifier) end

        if not IsCompanyUnlocked(identifier, companyId) then
            Fiji.Notify(source, "You haven't unlocked this company yet.", "error")
            return BuildFullState(source, identifier)
        end

        local activeCount = MySQL.scalar.await('SELECT COUNT(*) FROM fiji_oil_player_contracts WHERE identifier = ? AND company_id = ? AND status = ?', { identifier, companyId, 'active' })
        if (activeCount or 0) >= Config.MaxActiveContractsPerCompany then
            Fiji.Notify(source, "You already have the maximum active contracts with this company.", "error")
            return BuildFullState(source, identifier)
        end

        local alreadyActive = MySQL.scalar.await('SELECT COUNT(*) FROM fiji_oil_player_contracts WHERE identifier = ? AND contract_id = ? AND status = ?', { identifier, contractId, 'active' })
        if (alreadyActive or 0) > 0 then
            return BuildFullState(source, identifier)
        end

        MySQL.insert.await('INSERT INTO fiji_oil_player_contracts (identifier, company_id, contract_id, progress, status) VALUES (?, ?, ?, 0, ?)', { identifier, companyId, contractId, 'active' })
        Fiji.Notify(source, "Contract accepted: " .. template.title, "success")

        return BuildFullState(source, identifier)
    end)

    Unlock(source)

    if not ok then
        print(('^1[fiji-oil]^0 acceptContract error: %s'):format(tostring(result)))
        return BuildFullState(source, identifier)
    end

    return result
end)

Callback.Register('fiji-oil:companies:abandonContract', function(source, payload)
    local identifier = Fiji.GetIdentifier(source)
    if not identifier or not payload or not payload.playerContractId then return BuildFullState(source, identifier) end

    MySQL.query.await('DELETE FROM fiji_oil_player_contracts WHERE id = ? AND identifier = ? AND status = ?', { payload.playerContractId, identifier, 'active' })
    Fiji.Notify(source, "Contract abandoned.", "inform")

    return BuildFullState(source, identifier)
end)

Callback.Register('fiji-oil:companies:fulfillContract', function(source, payload)
    local identifier = Fiji.GetIdentifier(source)
    if not identifier or not payload or not payload.playerContractId then return BuildFullState(source, identifier) end

    if not TryLock(source) then return BuildFullState(source, identifier) end

    local ok, result = pcall(function()
        local rows = MySQL.query.await('SELECT * FROM fiji_oil_player_contracts WHERE id = ? AND identifier = ? AND status = ?', { payload.playerContractId, identifier, 'active' })
        local row = rows and rows[1]
        if not row then return BuildFullState(source, identifier) end

        local template = FindContractTemplate(row.company_id, row.contract_id)
        if not template then return BuildFullState(source, identifier) end

        local hasItem, count = Fiji.HasItem(source, template.item)
        if not hasItem or count < template.quantity then
            Fiji.Notify(source, "You don't have enough " .. Fiji.GetItemLabel(template.item) .. " to fulfill this contract.", "error")
            return BuildFullState(source, identifier)
        end

        if not Fiji.RemoveItem(source, template.item, template.quantity) then
            Fiji.Notify(source, "Failed to remove items from your inventory.", "error")
            return BuildFullState(source, identifier)
        end

        -- Blackgold's commerce perk also boosts contract reputation payouts, regardless
        -- of which company the contract is with.
        local blackgoldTier = GetCompanyPerkTier('blackgold', GetCompanyReputation(identifier, 'blackgold'))
        local repMultiplier = blackgoldTier and blackgoldTier.contractReputationMultiplier or 1.0

        local company = Config.Companies[row.company_id]
        Fiji.AddMoney(source, 'bank', template.rewardCash, 'Fiji Oil: Contract - ' .. template.title)
        AddCompanyReputation(identifier, row.company_id, math.floor(template.rewardReputation * repMultiplier))

        MySQL.query.await('UPDATE fiji_oil_player_contracts SET status = ? WHERE id = ?', { 'complete', row.id })

        Fiji.Notify(source, ('Contract fulfilled: %s (+$%d, +%d reputation with %s)'):format(
            template.title, template.rewardCash, template.rewardReputation, company and company.label or row.company_id
        ), "success")

        return BuildFullState(source, identifier)
    end)

    Unlock(source)

    if not ok then
        print(('^1[fiji-oil]^0 fulfillContract error: %s'):format(tostring(result)))
        return BuildFullState(source, identifier)
    end

    return result
end)
