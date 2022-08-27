fx_version 'cerulean'
games { 'gta5' }

author 'MaDHouSe'
description 'MH AI EMS Services - When there is no ems players online to help you.'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua', -- change nl to your language
    'config.lua',
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'oxmysql',
    'qb-core',
}

lua54 'yes'