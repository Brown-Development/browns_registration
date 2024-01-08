fx_version 'bodacious'
author 'Brown Development'
description 'Vehicle Registration'
game 'gta5'
lua54 'yes'

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
    'shared/*.lua'
}

files {
    'html/*.html',
    'html/*.css',
    'html/*.js',
    'html/img/*.png',
    'html/img/*.jpg'
}

ui_page 'html/index.html'

dependencies {
    'oxmysql',
    'ox_lib'
}