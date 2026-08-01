-- Physical company HQ interactions: sell desk (direct cash sale) and
-- supply drop-off (collect orders placed through the Terminal).

local function OpenSellMenu(companyId)
    local company = Config.Companies[companyId]
    if not company or not company.sellPrices then return end

    local options = {}
    for item, price in pairs(company.sellPrices) do
        local label = Fiji.GetItemLabel(item)
        table.insert(options, {
            title = 'Sell ' .. label,
            description = ('$%d each'):format(price),
            onSelect = function()
                local input = UI.InputDialog('Sell ' .. label, {
                    { type = 'number', label = 'Quantity', description = ('$%d each'):format(price), default = 1, min = 1, max = 999 },
                })

                if not input or not input[1] then return end

                local quantity = math.floor(input[1])
                if quantity < 1 then return end

                Callback.Trigger('fiji-oil:companies:sell', { companyId = companyId, item = item, quantity = quantity }, function() end)
            end,
        })
    end

    table.sort(options, function(a, b) return a.title < b.title end)

    UI.ContextMenu(company.label .. ' - Sell Oil', options)
end

CreateThread(function()
    Wait(1500)

    for _, hqId in ipairs(Config.CompanyOrder) do
        local hq = Config.HQs[hqId]
        if hq then
            if hq.tradeDesk then
                Fiji.AddInteraction(
                    'fiji_tradedesk_' .. hqId,
                    { type = 'sphere', coords = hq.tradeDesk, radius = 1.2 },
                    {
                        {
                            name = 'sell_' .. hqId,
                            icon = 'fa-solid fa-money-bill-wave',
                            label = 'Sell Oil to ' .. hq.label,
                            onSelect = function() OpenSellMenu(hqId) end,
                        },
                    },
                    Config.Debug or false
                )
            end

            if hq.supplyDropoff then
                Fiji.AddInteraction(
                    'fiji_dropoff_' .. hqId,
                    { type = 'sphere', coords = hq.supplyDropoff, radius = 1.2 },
                    {
                        {
                            name = 'collect_' .. hqId,
                            icon = 'fa-solid fa-box-open',
                            label = 'Collect Supply Orders',
                            onSelect = function()
                                TriggerServerEvent('fiji-oil:server:collectSupplyOrders', hqId)
                            end,
                        },
                    },
                    Config.Debug or false
                )
            end
        end
    end
end)
