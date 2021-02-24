local userName = 'DGsloth'
local addonName = 'esx_steal'
PerformHttpRequest('https://raw.githubusercontent.com/'..userName..'/'..addonName..'/main/version.txt', function(err, serverVersion, headers)
    local version = '1.1'
    if string.find(serverVersion, version) == nil then
        print('^4ADDON: ^3', GetCurrentResourceName(), '^7[^3'..addonName..'^7]', '^7[^1OUTDATED^7] - https://github.com/'..userName..'/'..addonName)
    else
        print('^4ADDON: ^3', GetCurrentResourceName(), '^7[^3'..addonName..'^7]', '[^2UP-TO-DATE^7]')
    end
end)