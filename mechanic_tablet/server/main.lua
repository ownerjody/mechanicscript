local resourceName = GetCurrentResourceName()

CreateThread(function()
    Wait(1000)
    print(('[%s] Loaded successfully. Framework mode: %s'):format(resourceName, Config.Framework))
end)
