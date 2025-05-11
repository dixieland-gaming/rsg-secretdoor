local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterNetEvent("rsg_door:server:rotateDoor", function()
    TriggerClientEvent("rsg_door:client:rotateDoor", -1)
end)

RegisterNetEvent("rsg_door:server:rotateTrapdoor", function()
    TriggerClientEvent("rsg_door:client:rotateTrapdoor", -1)
end)

RegisterNetEvent("rsg_door:server:rotateTrapdoor2", function()
    TriggerClientEvent("rsg_door:client:rotateTrapdoor2", -1)
end)

RegisterNetEvent("rsg_door:server:rotateTrapdoor3", function()
    TriggerClientEvent("rsg_door:client:rotateTrapdoor3", -1)
end)
