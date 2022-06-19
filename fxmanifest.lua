fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'AXFW-INVENTORY'
shared_scripts {
	'main/callbacks.lua',
	'main/shared.lua',
	'main/player.lua',
	'main/events.lua'
}
server_scripts {
	"server/*.lua",
}
client_scripts {
	"client/*.lua"
}
ui_page {
	'ui/index.html'
}
files {
	'ui/index.html',
	'ui/*.css',
	'ui/*.js',
	'ui/items/*.png',
	'ui/items/*.jpg',
	'ui/cloth/*.png',
	'ui/cloth/*.svg',
	'ui/*ttf'
}