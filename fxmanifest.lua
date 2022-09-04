fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
game 'gta5'
lua54 'yes'

author 'Mahan Moulaei'
discord 'Mahan#8183'
description 'Backward-compatible resource for the replacement of qb-inventory to ox_inventory'

shared_scripts {
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

dependencies {
	'qb-core',
	'ox_inventory'
}

provide 'qb-inventory'
