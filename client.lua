ESX = exports['es_extended']:getSharedObject()

local deadNPCs = {}

Citizen.CreateThread(function()
    while true do
        local pedPool = GetGamePool("CPed")
        for _, ped in ipairs(pedPool) do
            if not IsPedAPlayer(ped) and IsPedDeadOrDying(ped, true) and not deadNPCs[ped] then
                deadNPCs[ped] = NetworkGetNetworkIdFromEntity(ped)
            end
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isNearby = false

        for ped, netId in pairs(deadNPCs) do
            if DoesEntityExist(ped) then
                local npcCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - npcCoords)

                if distance <= 1.5 then
                    isNearby = true
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour collecter un échantillon d'ADN.")
                    
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('dna_collection:collectFromDeadNPC', netId)
                        deadNPCs[ped] = nil
                        SetEntityAsNoLongerNeeded(ped)
                        DeleteEntity(ped)
                    end
                end
            else
                deadNPCs[ped] = nil
            end
        end

        if not isNearby then
            Citizen.Wait(500)
        end

        Citizen.Wait(0)
    end
end)

RegisterNetEvent('dna_collection:startInteractionAnimation')
AddEventHandler('dna_collection:startInteractionAnimation', function()
    print("Animation demandée")
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, true) then
        print("Personnage dans un véhicule")
    elseif IsPedDeadOrDying(playerPed) then
        print("Personnage mort ou mourant")
    else
        print("Personnage prêt à jouer l'animation")
        TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, -8.0, 5000, 49, 0, false, false, false)
        Citizen.Wait(5000)
        print("Animation terminée")
    end
end)