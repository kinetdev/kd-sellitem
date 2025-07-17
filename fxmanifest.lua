fx_version 'cerulean'
game 'gta5'

author 'KD Scripts'
description 'KD Bán Vật Phẩm'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/img/*.png',
    'html/img/*.jpg',
    'html/img/*.jpeg',
    'html/img/*.gif'
}

dependencies {
    'es_extended'
} 