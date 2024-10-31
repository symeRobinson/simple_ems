-- server.lua

local onDutyPlayers = {}

-- Event to set a player on or off duty
RegisterNetEvent('ems:setOnDuty')
AddEventHandler('ems:setOnDuty', function(isOnDuty, selectedUnit, selectedStation)
    local src = source
    if isOnDuty then
        -- Add player to onDutyPlayers list
        onDutyPlayers[src] = {
            unit = selectedUnit,
            station = selectedStation,
            identifier = GetPlayerIdentifiers(src)[1]  -- Store unique identifier for tracking
        }
        TriggerClientEvent('chat:addMessage', -1, { args = { "EMS", GetPlayerName(src) .. " is now on duty as " .. selectedUnit } })
    else
        -- Remove player from onDutyPlayers list
        onDutyPlayers[src] = nil
        TriggerClientEvent('chat:addMessage', -1, { args = { "EMS", GetPlayerName(src) .. " has gone off duty." } })
    end
end)

-- Event to update a civilian's selected data
RegisterNetEvent('ems:updateCivilianData')
AddEventHandler('ems:updateCivilianData', function(age, sex, medicalConditions, injuries)
    local src = source
    local civilianData = {
        age = age,
        sex = sex,
        medicalConditions = medicalConditions,
        injuries = injuries
    }
    -- Save civilian data (you may wish to save this to a database)
    onDutyPlayers[src] = civilianData
    print("Updated civilian data for player: " .. GetPlayerName(src))
end)

-- Command to list all on-duty players (for admin/testing purposes)
RegisterCommand('listonduty', function(source, args, rawCommand)
    local src = source
    if src == 0 then -- Server console
        print("On-Duty EMS Players:")
        for playerId, data in pairs(onDutyPlayers) do
            print("Player ID: " .. playerId .. ", Unit: " .. (data.unit or "N/A") .. ", Station: " .. (data.station or "N/A"))
        end
    else -- In-game command
        TriggerClientEvent('chat:addMessage', src, { args = { "EMS", "Check console for on-duty players." } })
    end
end, true)

-- Clean up player data when they disconnect
AddEventHandler('playerDropped', function(reason)
    local src = source
    if onDutyPlayers[src] then
        onDutyPlayers[src] = nil
    end
end)
