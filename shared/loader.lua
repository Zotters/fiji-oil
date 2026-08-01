local version = '2.0.0'
local resourceName = GetCurrentResourceName()
local repoOwner = 'Zotters'
local repoName = 'fiji-oil'

-- NOTE: `Fiji` here refers to the global table bridge.lua sets up (see that
-- file's header comment) - not a require()'d module. Deliberately not
-- declared `local` here so it isn't shadowed.

local FRAMEWORK_LABELS = {
    qb = 'QB Core',
    qbx = 'QBX Core',
    esx = 'ESX',
}

local function ParseDate(dateString)
    local year, month, day, hour, min, sec = dateString:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z")
    return os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec)
    })
end

-- FXServer's PerformHttpRequest has no native timeout parameter - this guarantees
-- `callback` fires within timeoutMs regardless, so a hung/slow GitHub request can
-- never leave anything waiting indefinitely. If the real response arrives after
-- our synthetic timeout already fired, it's silently ignored.
local function HttpRequestWithTimeout(url, method, data, headers, timeoutMs, callback)
    local done = false

    PerformHttpRequest(url, function(err, text, respHeaders)
        if done then return end
        done = true
        callback(err, text, respHeaders)
    end, method, data or '', headers or {})

    CreateThread(function()
        Wait(timeoutMs)
        if not done then
            done = true
            callback(-1, nil, nil)
        end
    end)
end

local function CheckVersion(callback)
    local rawUrl = ('https://raw.githubusercontent.com/%s/%s/main/version.lua'):format(repoOwner, repoName)

    HttpRequestWithTimeout(rawUrl, 'GET', '', {}, 6000, function(err, text)
        if err == 200 and text then
            local latestVersion = text:match("return%s+['\"]([%d%.]+)['\"]")

            if latestVersion and latestVersion ~= version then
                local updateInfo = {
                    current = version,
                    latest = latestVersion,
                    date = "Unknown",
                    url = ('https://github.com/%s/%s/releases'):format(repoOwner, repoName),
                    notes = "Visit GitHub for release notes."
                }

                if callback then callback(true, updateInfo) end
                return
            elseif latestVersion then
                if callback then callback(false, nil) end
                return
            end
        end

        local apiUrl = ('https://api.github.com/repos/%s/%s/releases/latest'):format(repoOwner, repoName)

        HttpRequestWithTimeout(apiUrl, 'GET', '', {
            ['User-Agent'] = resourceName .. '/' .. version,
            ['Accept'] = 'application/vnd.github.v3+json'
        }, 6000, function(apiErr, apiText)
            if apiErr ~= 200 then
                if apiErr == 403 then
                    print('^3[' .. resourceName .. '] GitHub API rate limit exceeded. Unable to check for updates.^0')
                    print('^3[' .. resourceName .. '] You can manually check for updates at: https://github.com/' .. repoOwner .. '/' .. repoName .. '/releases^0')
                elseif apiErr == -1 then
                    print('^3[' .. resourceName .. '] Update check timed out.^0')
                else
                    print('^3[' .. resourceName .. '] Failed to check for updates: HTTP Error ' .. tostring(apiErr) .. '^0')
                end

                if callback then callback(false, nil) end
                return
            end

            local data = json.decode(apiText)
            if not data or not data.tag_name then
                print('^3[' .. resourceName .. '] Failed to parse release data^0')
                if callback then callback(false, nil) end
                return
            end

            local latestVersion = data.tag_name:gsub('v', '')

            if latestVersion ~= version then
                local releaseUrl = data.html_url or ('https://github.com/%s/%s/releases/latest'):format(repoOwner, repoName)
                local releaseDate = data.published_at and os.date('%Y-%m-%d', os.time(os.date('!*t', ParseDate(data.published_at)))) or 'Unknown'

                local updateInfo = {
                    current = version,
                    latest = latestVersion,
                    date = releaseDate,
                    url = releaseUrl,
                    notes = data.body
                }

                if callback then callback(true, updateInfo) end
            else
                if callback then callback(false, nil) end
            end
        end)
    end)
end

local function PrintLogo()
    print([[
^5 ███████████ █████       █████ █████       ███████    █████ █████
^5░░███░░░░░░█░░███       ░░███ ░░███      ███░░░░░███ ░░███ ░░███
^5 ░███   █ ░  ░███        ░███  ░███     ███     ░░███ ░███  ░███
^5 ░███████    ░███        ░███  ░███    ░███      ░███ ░███  ░███
^5 ░███░░░█    ░███        ░███  ░███    ░███      ░███ ░███  ░███
^5 ░███  ░     ░███  ███   ░███  ░███    ░░███     ███  ░███  ░███      █
^5 █████       █████░░████████   █████    ░░░███████░   █████ ███████████
^5░░░░░       ░░░░░  ░░░░░░░░   ░░░░░       ░░░░░░░    ░░░░░ ░░░░░░░░░░░
^7]])
end

local function PrintInfoBelow(framework, updateInfo, targetSystem)
    print('')
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    print('^3Version: ^7' .. version)
    print('^3Author: ^7Zotters')
    print('^3Framework: ^7' .. framework)

    if targetSystem then
        print('^3Target System: ^7' .. targetSystem)
    else
        print('^3Target System: ^7Disabled (using proximity interactions)')
    end

    if updateInfo then
        print('')
        print('^1UPDATE AVAILABLE^0')
        print('^3Latest version: ^2' .. updateInfo.latest .. ' ^7(Released: ' .. updateInfo.date .. ')')
        print('^3Download: ^7' .. updateInfo.url)

        if updateInfo.notes and updateInfo.notes ~= "Visit GitHub for release notes." then
            print('')
            print('^3Release Notes:^0')

            local notes = updateInfo.notes:gsub('\r\n', '\n')
            local noteLines = {}

            for line in notes:gmatch("[^\n]+") do
                if not line:match("^-+$") and line:gsub("%s+", "") ~= "" then
                    table.insert(noteLines, line)
                end
            end

            for i = 1, math.min(5, #noteLines) do
                print('^7- ' .. noteLines[i])
            end

            if #noteLines > 5 then
                print('^7... (see full notes on GitHub)')
            end
        elseif updateInfo.notes then
            print('^7' .. updateInfo.notes)
        end
    else
        print('^2You are running the latest version!^0')
    end

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    print('')
end

local function InitializeBridge()
    if not Fiji.Init() then
        return false, nil
    end

    local targetSystem = nil
    if Config.UseTarget then
        targetSystem = Fiji.GetTargetSystem()
        if not targetSystem then
            Config.UseTarget = false
        end
    end

    return true, targetSystem
end

-- Retries instead of a single flat delay: resolves immediately once the
-- inventory resource is actually up, and tolerates a slow-starting server
-- instead of gambling everything on one arbitrary point in time.
local function TryInitializeBridge(maxAttempts, intervalMs)
    for attempt = 1, maxAttempts do
        local ok, targetSystem = InitializeBridge()
        if ok then
            return true, targetSystem
        end

        Wait(intervalMs)
    end

    return false, nil
end

local function Initialize()
    local bridgeSuccess, targetSystem = TryInitializeBridge(40, 250) -- up to ~10s

    if not bridgeSuccess then
        print('^1[' .. resourceName .. '] ERROR: NO SUPPORTED INVENTORY DETECTED after 10s^0')
        print('^1[' .. resourceName .. '] Please install a compatible inventory: ox_inventory, qb-inventory, qs-inventory, or ESX^0')
        return false
    end

    -- The startup banner and update check are server-console diagnostics only -
    -- printing them on every connecting client's F8 console has no player-facing
    -- value, so only the server does it.
    if IsDuplicityVersion() then
        PrintLogo()

        local framework = FRAMEWORK_LABELS[Fiji.GetFramework()] or 'Unknown (no money/identifier integration)'

        CheckVersion(function(updateAvailable, updateInfo)
            PrintInfoBelow(framework, updateAvailable and updateInfo or nil, targetSystem)
        end)
    end

    return true
end

CreateThread(function()
    if not Initialize() then
        print('^1[' .. resourceName .. '] Failed to initialize. Please check the error messages above.^0')
    end
end)

return {
    version = version,
    Initialize = Initialize,
    Fiji = function() return Fiji end
}
