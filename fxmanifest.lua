fx_version "cerulean"
use_experimental_fxv2_oal 'yes'
game 'gta5'
lua54 'yes'
author 'ENT510'
version '1.0.0'


shared_scripts {
    '@ox_lib/init.lua',
    "shared/*.lua",
    'init.lua',
}

client_scripts {
    "Modules/client/cl-main.lua",
    "Modules/client/cl-utils.lua",
}

server_scripts {
    "Modules/server/sv-main.lua",
}
