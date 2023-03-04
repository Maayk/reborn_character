fx_version 'cerulean'
game 'gta5'

ui_page "html/index.html"

shared_script '@reborn_core/import.lua'

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

files {
    'html/*.html',
    'html/*.css',
    'html/*.js',
    'html/*.png',
    'html/*.gif',
}