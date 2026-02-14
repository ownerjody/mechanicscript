fx_version 'cerulean'
game 'gta5'

name 'mechanic_tablet'
author 'Codex'
description 'Mechanic tablet supporting open, ESX, and QBCore frameworks'
version '1.0.0'

lua54 'yes'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
