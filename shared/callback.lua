Callback = Callback or {}

if IsDuplicityVersion() then
    -- ===================== SERVER =====================
    local handlers = {}

    function Callback.Register(name, handler)
        handlers[name] = handler
    end

    RegisterNetEvent('fiji-oil:callback:request', function(name, requestId, payload)
        local source = source
        local handler = handlers[name]

        if not handler then
            print(('^1[fiji-oil]^0 callback "%s" has no registered handler'):format(tostring(name)))
            TriggerClientEvent('fiji-oil:callback:response', source, requestId, nil)
            return
        end

        local ok, result = pcall(handler, source, payload)
        if not ok then
            print(('^1[fiji-oil]^0 callback "%s" error: %s'):format(name, tostring(result)))
            result = nil
        end

        TriggerClientEvent('fiji-oil:callback:response', source, requestId, result)
    end)
else
    -- ===================== CLIENT =====================
    local pending = {}
    local nextRequestId = 0

    RegisterNetEvent('fiji-oil:callback:response', function(requestId, result)
        local cb = pending[requestId]
        if cb then
            pending[requestId] = nil
            cb(result)
        end
    end)

    -- Callback.Trigger('some:name', { foo = 'bar' }, function(result) ... end)
    function Callback.Trigger(name, payload, cb)
        nextRequestId = nextRequestId + 1
        local requestId = nextRequestId
        pending[requestId] = cb or function() end
        TriggerServerEvent('fiji-oil:callback:request', name, requestId, payload)
    end

    -- Blocking-style variant (mirrors UI.ProgressBar/UI.InputDialog's ergonomics):
    -- local result = Callback.TriggerSync('some:name', { foo = 'bar' })
    -- Every gathering loop (drilling/refinery/packaging) calls this once per unit,
    -- so it's on the hot path - suspend on a promise instead of busy-polling with
    -- Wait(0) every frame until the network round trip comes back.
    function Callback.TriggerSync(name, payload)
        local p = promise.new()
        Callback.Trigger(name, payload, function(r) p:resolve(r) end)
        return Citizen.Await(p)
    end
end
