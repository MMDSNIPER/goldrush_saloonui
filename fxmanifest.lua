fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Saloons Menu'
description 'Saloons Menu'
version '1.0.0'

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/output.css'
}

client_scripts {
    "client/client.lua"
}

server_scripts {
    "server/server.lua"
}
shared_script '@ox_lib/init.lua'
lua54 "yes"