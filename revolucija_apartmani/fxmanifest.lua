fx54 "yes"
fx_version "cerulean"
game "gta5"
author "Josip \"j0le\" Tomašević"

shared_scripts
{
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "config/config.lua"
}

client_script "client/client.lua"

server_scripts
{
    "@oxmysql/lib/MySQL.lua",
    "server/server.lua"
}

files
{
    "html/assets/css/framwork-inline.css",
    "html/assets/css/style.css",
    "html/assets/js/jquery.min.js",
    "html/assets/js/script.js",
    "html/index.html"
}

ui_page "html/index.html"