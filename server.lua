ESX = exports['es_extended']:getSharedObject()

local DNA_ITEM = "dna_sample"
local function generateDNAId()
    return "DNA-" .. math.random(100000, 999999)
end

RegisterNetEvent('dna_collection:interactWithNPC')
AddEventHandler('dna_collection:interactWithNPC', function(npcIndex)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local dnaId = generateDNAId()
    local success = exports.ox_inventory:AddItem(source, DNA_ITEM, 1, { dna_id = dnaId })

    if success then
        TriggerClientEvent('esx:showNotification', source, "Vous avez collecté un échantillon d'ADN: ~y~" .. dnaId)
    else
        TriggerClientEvent('esx:showNotification', source, "Votre inventaire est plein.")
    end
end)
