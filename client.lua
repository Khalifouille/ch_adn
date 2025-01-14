ESX = exports['es_extended']:getSharedObject()

local deadNPCs = {}
local function isHumanPed(ped)
    local model = GetEntityModel(ped)
    return model ~= GetHashKey("a_c_cat_01") and
           model ~= GetHashKey("a_c_chickenhawk") and
           model ~= GetHashKey("a_c_husky") and
           model ~= GetHashKey("a_c_poodle") and
           model ~= GetHashKey("a_c_rat") and
           model ~= GetHashKey("a_c_seagull") and
           model ~= GetHashKey("a_c_shepherd") and
           model ~= GetHashKey("a_c_cow")

end

Citizen.CreateThread(function()
    while true do
        local pedPool = GetGamePool("CPed")
        for _, ped in ipairs(pedPool) do
            if not IsPedAPlayer(ped) and IsPedDeadOrDying(ped, true) and not deadNPCs[ped] and isHumanPed(ped) then
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
                    if IsPedInAnyVehicle(ped, false) then
                        ESX.ShowHelpNotification("OH SORT LE AVANT NN?")
                    else
                        isNearby = true
                        ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour collecter un échantillon d'ADN.")
                        
                        if IsControlJustReleased(0, 38) then
                            TriggerServerEvent('dna_collection:NPCMOW', netId)
                            TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
                            Citizen.Wait(3000)
                            ClearPedTasks(playerPed)
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