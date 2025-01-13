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
                    -- Vérifier si le ped est dans un véhicule
                    if IsPedInAnyVehicle(ped, false) then
                        ESX.ShowHelpNotification("Vous ne pouvez pas collecter d'échantillon d'ADN d'un NPC dans un véhicule.")
                    else
                        isNearby = true
                        ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour collecter un échantillon d'ADN.")
                        
                        if IsControlJustReleased(0, 38) then
                            TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
                            Citizen.Wait(3000)
                            ClearPedTasks(playerPed)
                            TriggerServerEvent('dna_collection:NPCMOW', netId)
                            deadNPCs[ped] = nil
                            SetEntityAsNoLongerNeeded(ped)
                            DeleteEntity(ped)
                        end
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