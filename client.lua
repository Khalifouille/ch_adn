ESX = exports['es_extended']:getSharedObject()

local interactiveNPCs = {
    {x = 680.030762, y = 559.279114, z = 129.030762, heading = 90.0, model = "a_m_y_business_01"},
}
local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end
end

local spawnedNPCs = {}

Citizen.CreateThread(function()
    for index, npcData in ipairs(interactiveNPCs) do
        local model = npcData.model or "a_m_y_business_01"
        loadModel(model)

        local npc = CreatePed(4, GetHashKey(model), npcData.x, npcData.y, npcData.z - 1.0, npcData.heading, false, true)
        SetEntityAsMissionEntity(npc, true, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        SetPedFleeAttributes(npc, 0, false)
        SetPedCombatAttributes(npc, 17, true)
        SetPedCanRagdoll(npc, false)
        FreezeEntityPosition(npc, true)

        spawnedNPCs[index] = npc
    end
end)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isNearby = false

        for index, npc in pairs(spawnedNPCs) do
            if DoesEntityExist(npc) then
                local npcCoords = GetEntityCoords(npc)
                local distance = #(playerCoords - npcCoords)

                if distance <= 2.0 then
                    isNearby = true
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour collecter l'ADN.")
                    
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('dna_collection:interactWithNPC', index)
                    end
                end
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
    local playerPed = PlayerPedId()
    RequestAnimDict("mp_common")
    while not HasAnimDictLoaded("mp_common") do
        Citizen.Wait(10)
    end

    TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, -8.0, 5000, 49, 0, false, false, false)
end)
