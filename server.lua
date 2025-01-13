ESX = exports['es_extended']:getSharedObject()

local DNA_ITEM = "dna_sample"
local DNA_KIT = "dna_kit"

local function generateDNAId()
    return "DNA-" .. math.random(100000, 999999)
end

RegisterNetEvent('dna_collection:NPCMOW')
AddEventHandler('dna_collection:NPCMOW', function(npcNetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if not exports.ox_inventory:Search(source, 'count', DNA_KIT) then
        TriggerClientEvent('esx:showNotification', source, "Vous avez besoin d'un kit ADN pour collecter un échantillon.")
        return
    end

    local dnaId = generateDNAId()
    local success = exports.ox_inventory:AddItem(source, DNA_ITEM, 1, { dna_id = dnaId })
    if success then
        exports.ox_inventory:RemoveItem(source, DNA_KIT, 1)
        TriggerClientEvent('esx:showNotification', source, "Vous avez collecté un échantillon d'ADN.")

        local query = "INSERT INTO dna_samples (player_id, dna_id, ped_id) VALUES (@playerId, @dnaId, @pedId)"
        exports.oxmysql:execute(query, {
            ['@playerId'] = xPlayer.identifier,
            ['@dnaId'] = dnaId,
            ['@pedId'] = npcNetId
        })
    else
        TriggerClientEvent('esx:showNotification', source, "Votre inventaire est plein.")
    end
end)