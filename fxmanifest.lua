fx_version 'cerulean'
game 'gta5'

author 'OEKXC'
description 'HUD  OEKXC Development'
version '1.0.0'
lua54 'yes'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/image/*.png',
    'locales/*.json'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'setup.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'ox_lib'
}

