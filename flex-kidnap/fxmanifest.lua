fx_version "bodacious"
game "gta5"
lua54 "yes"

author "flexiboii"
description "Flex-kidnap"
version "1.0.0"

shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'config/c_config.lua',
    'locale/*.lua',
}

server_scripts {
    'server/*.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
	'client/**.lua',
}