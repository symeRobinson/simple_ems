local Config = Config or {}
local playersData = {} -- Data for all players

-- Receive player data from client
RegisterNetEvent('ems:updatePlayerData')
AddEventHandler('ems:updatePlayerData', function(data)
    local playerId = source
    playersData[playerId] = data

    -- Send updated data to all clients
    TriggerClientEvent('ems:receivePlayersData', -1, playersData)
end)

-- Handle player disconnect
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    playersData[playerId] = nil

    -- Update other clients
    TriggerClientEvent('ems:receivePlayersData', -1, playersData)
end)

-- Event to handle treatments applied by EMS providers
RegisterNetEvent('ems:applyTreatment')
AddEventHandler('ems:applyTreatment', function(targetPlayerId, treatmentName)
    local sourcePlayerId = source

    -- Validate treatment
    if not Config.Treatments[treatmentName] then
        print("Invalid treatment applied by player " .. sourcePlayerId)
        return
    end

    -- Apply treatment to target player
    if playersData[targetPlayerId] then
        -- Notify target player to apply treatment
        TriggerClientEvent('ems:treatmentApplied', targetPlayerId, treatmentName)
    end
end)

-- Request player data when a client connects
RegisterNetEvent('ems:requestPlayersData')
AddEventHandler('ems:requestPlayersData', function()
    local playerId = source
    TriggerClientEvent('ems:receivePlayersData', playerId, playersData)
end)

-- Debug command to reset a player's data
RegisterCommand('resetPlayerData', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    if playersData[targetId] then
        playersData[targetId] = nil
        TriggerClientEvent('ems:receivePlayersData', -1, playersData)
        print("Reset player data for ID: " .. targetId)
    end
end, true)
