fx_version 'cerulean'
games { 'gta5' }

author 'Zotters'
description 'Zotters Oil'
version '0.5.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

server_scripts {
    'core/server.lua'
}
client_scripts {
    'core/zones.lua',
    'core/events.lua',
    'core/pump.lua',
}