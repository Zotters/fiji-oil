local version = '1.0.1'
local resourceName = GetCurrentResourceName()
local repoOwner = 'Zotters'
local repoName = 'fiji-oil'
local Fiji = nil

local function DetectFramework()
    if GetResourceState('ox_inventory') == 'started' then
        return 'ox_inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        return 'qb-inventory'
    elseif GetResourceState('qbx_core') == 'started' then
        return 'QBX Core'
    elseif GetResourceState('qb-core') == 'started' then
        return 'QB Core'
    elseif GetResourceState('qs-inventory') == 'started' then
        return 'qs-inventory'
    elseif GetResourceState('es_extended') == 'started' then
        return 'ESX'
    else
        return 'Unknown'
    end
end

local function CheckVersion(callback)
    local rawUrl = ('https://raw.githubusercontent.com/%s/%s/main/version.lua'):format(repoOwner, repoName)
    
    PerformHttpRequest(rawUrl, function(err, text, headers)
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
        
        PerformHttpRequest(apiUrl, function(err, text, headers)
            if err ~= 200 then 
                if err == 403 then
                    print('^3[' .. resourceName .. '] GitHub API rate limit exceeded. Unable to check for updates.^0')
                    print('^3[' .. resourceName .. '] You can manually check for updates at: https://github.com/' .. repoOwner .. '/' .. repoName .. '/releases^0')
                else
                    print('^3[' .. resourceName .. '] Failed to check for updates: HTTP Error ' .. tostring(err) .. '^0')
                end
                
                if callback then callback(false, nil) end
                return 
            end
            
            local data = json.decode(text)
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
        end, 'GET', '', {
            ['User-Agent'] = resourceName .. '/' .. version,
            ['Accept'] = 'application/vnd.github.v3+json'
        })
    end, 'GET')
end

function ParseDate(dateString)
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
    Fiji = require 'bridge'
    
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

local function Initialize()
    local framework = DetectFramework()
    
    PrintLogo()
    
    if framework == 'Unknown' then
        print('')
        print('^1ERROR: NO SUPPORTED FRAMEWORK DETECTED^0')
        print('^1Please install a compatible framework: QB Core, QBX Core, ESX, or ox_inventory^0')
        print('')
        return false
    else
        local bridgeSuccess, targetSystem = InitializeBridge()
        if not bridgeSuccess then
            print('^1[' .. resourceName .. '] Failed to initialize bridge component. Some features may not work correctly.^0')
        end
        
        CheckVersion(function(updateAvailable, updateInfo)
            PrintInfoBelow(framework, updateAvailable and updateInfo or nil, targetSystem)
        end)
        
        return true
    end
end

CreateThread(function()
    Wait(500)
    
    if not Initialize() then
        print('^1[' .. resourceName .. '] Failed to initialize. Please check the error messages above.^0')
    end
end)

return {
    version = version,
    Initialize = Initialize,
    Fiji = function() return Fiji end
}
