fx_version 'cerulean'
game 'gta5'

author 'Syme Robinson'
description 'Basic EMS Script'
version '1.0.0'

-- NativeUI dependency
client_scripts {
    '@NativeUI/NativeUI.lua',
    'config.lua',
    'scripts/client.lua'
}

server_scripts {
    'config.lua',
    'scripts/server.lua'
}
