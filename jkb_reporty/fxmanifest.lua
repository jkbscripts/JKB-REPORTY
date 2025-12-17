fx_version 'cerulean'
game 'gta5'

author '.jkbb'
version '1.0.0'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_script 'client.lua'
server_script 'server.lua'

dependencies {
    'ox_lib',
    'screencapture'
}