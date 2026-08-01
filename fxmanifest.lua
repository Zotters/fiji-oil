fx_version 'cerulean'
games { 'gta5' }

author 'Zotters'
description 'Fiji Oils'
version '2.0.0'
lua54 'yes'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js'
}

shared_scripts {
    'shared/config.lua',
    'shared/bridge.lua',
    'shared/callback.lua',
    'shared/loader.lua'
}

client_scripts {
    'client/ui.lua',
    'client/main.lua',
    'client/terminal.lua',
    'client/companies.lua',
    'client/drilling.lua',
    'client/boats.lua',
    'client/refinery.lua',
    'client/packaging.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/terminal.lua',
    'server/companies.lua',
    'server/supplyorders.lua',
    'server/drilling.lua',
    'server/boats.lua',
    'server/refinery.lua',
    'server/packaging.lua'
}

dependencies {
    'oxmysql'
}
