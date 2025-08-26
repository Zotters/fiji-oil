fx_version 'cerulean'
games { 'gta5' }

author 'Zotters'
description 'Fiji Oils'
version '1.0.0'
lua54 'yes'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/script.css',
    'ui/script.js'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'bridge.lua',
    'loader.lua'
}

client_scripts {
    'config.lua',
    'client/main.lua',
    'client/zones.lua',
    'client/pump.lua',
    'client/refinery.lua',
    'client/packaging.lua',
    'client/delivery.lua'
}

server_scripts {
    'config.lua',
    'server/main.lua',
    'server/pump.lua',
    'server/refinery.lua',
    'server/packaging.lua',
    'server/delivery.lua'
}

dependencies {
    'ox_lib'
}
