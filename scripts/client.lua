-- client.lua

local isMedicOnDuty = false
local selectedUnit = ""
local selectedStation = ""
local teleportToStation = false
local playerAge = 0
local playerSex = ""
local playerMedicalConditions = {}
local playerInjuries = {}
local injuryDetectionEnabled = false

-- Menu pool for NativeUI
_menuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu("Basic EMS", "Created by Syme Robinson v1.1")
_menuPool:Add(mainMenu)

-- Notify helper function
function Notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-- Toggle the EMS menu with F5
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
        if IsControlJustPressed(1, 166) then -- F5 Key
            mainMenu:Visible(not mainMenu:Visible())
        end
    end
end)

-- Main EMS Menu setup
function OpenEMSMenu()
    -- Toggle Duty Submenu
    local toggleDutyMenu = _menuPool:AddSubMenu(mainMenu, "Toggle Duty")

    -- Configurable Units from Config
    local unitItem = NativeUI.CreateListItem("Unit", Config.Units, 1, "Select your unit.")
    toggleDutyMenu:AddItem(unitItem)

    -- Configurable Stations from Config
    local stationNames = {}
    for stationName, _ in pairs(Config.Stations) do
        table.insert(stationNames, stationName)
    end
    local stationItem = NativeUI.CreateListItem("Station", stationNames, 1, "Select your station.")
    toggleDutyMenu:AddItem(stationItem)

    -- Teleport Checkbox
    local teleportItem = NativeUI.CreateCheckboxItem("Teleport me?", teleportToStation, "Teleport to selected station on duty toggle.")
    toggleDutyMenu:AddItem(teleportItem)

    -- Done Button
    local doneToggleDuty = NativeUI.CreateItem("Done", "Confirm selection and toggle duty.")
    toggleDutyMenu:AddItem(doneToggleDuty)

    toggleDutyMenu.OnListSelect = function(sender, item, index)
        if item == unitItem then
            selectedUnit = item:IndexToItem(index)
            Notify("Selected Unit: " .. selectedUnit)
        elseif item == stationItem then
            selectedStation = item:IndexToItem(index)
            Notify("Selected Station: " .. selectedStation)
        end
    end

    toggleDutyMenu.OnCheckboxChange = function(sender, item, checked)
        if item == teleportItem then
            teleportToStation = checked
        end
    end

    toggleDutyMenu.OnItemSelect = function(sender, item, index)
        if item == doneToggleDuty then
            isMedicOnDuty = not isMedicOnDuty
            Notify("Duty Status: " .. (isMedicOnDuty and "On Duty" or "Off Duty"))

            if isMedicOnDuty then
                TriggerServerEvent('ems:setOnDuty', isMedicOnDuty, selectedUnit, selectedStation)
                if teleportToStation and selectedStation ~= "" then
                    local stationCoords = Config.Stations[selectedStation]
                    if stationCoords then
                        SetEntityCoords(PlayerPedId(), stationCoords.x, stationCoords.y, stationCoords.z)
                        Notify("Teleported to " .. selectedStation)
                    else
                        Notify("Station coordinates not found.")
                    end
                end
            else
                TriggerServerEvent('ems:setOnDuty', isMedicOnDuty)
            end

            mainMenu:Visible(false)
        end
    end

    -- Civilian Setup Menu
    local civilianSetupMenu = _menuPool:AddSubMenu(mainMenu, "Civilian Setup")

    -- Injury Detection Checkbox
    local injuryDetectionItem = NativeUI.CreateCheckboxItem("Injury Detection", injuryDetectionEnabled, "Enable or disable injury detection.")
    civilianSetupMenu:AddItem(injuryDetectionItem)

    -- Enter Age and Sex
    local ageItem = NativeUI.CreateItem("Enter Age", "Set the age for medical simulation.")
    local sexItem = NativeUI.CreateListItem("Enter Sex", Config.SexOptions, 1, "Select sex for medical simulation.")
    civilianSetupMenu:AddItem(ageItem)
    civilianSetupMenu:AddItem(sexItem)

    -- Medical Conditions
    local medicalConditionsMenu = _menuPool:AddSubMenu(civilianSetupMenu, "Medical Conditions")
    local medicalConditionItems = {}
    for _, condition in ipairs(Config.MedicalConditions) do
        local conditionItem = NativeUI.CreateCheckboxItem(condition, false, "Toggle " .. condition .. " condition.")
        medicalConditionsMenu:AddItem(conditionItem)
        medicalConditionItems[condition] = conditionItem
    end

    -- Finished Button for Civilian Setup
    local finishCivilianSetup = NativeUI.CreateItem("Finished", "Save civilian setup data.")
    civilianSetupMenu:AddItem(finishCivilianSetup)

    civilianSetupMenu.OnItemSelect = function(sender, item, index)
        if item == finishCivilianSetup then
            -- Collect medical conditions
            playerMedicalConditions = {}
            for condition, conditionItem in pairs(medicalConditionItems) do
                if conditionItem:Checked() then
                    table.insert(playerMedicalConditions, condition)
                end
            end
            playerSex = sexItem:IndexToItem(sexItem:SelectedIndex())
            TriggerServerEvent('ems:updateCivilianData', playerAge, playerSex, playerMedicalConditions, playerInjuries)
            Notify("Civilian setup saved.")
            mainMenu:Visible(false)
        end
    end

    -- Injury Submenu setup (for civilian setup)
    local injuryMenu = _menuPool:AddSubMenu(mainMenu, "Enter Injuries", "Select injuries for medical simulation.")
    for _, bodyPart in ipairs(Config.BodyParts) do
        local injuriesForPart = Config.Injuries[bodyPart] or {}
        if #injuriesForPart > 0 then
            local injurySubMenu = _menuPool:AddSubMenu(injuryMenu, bodyPart)
            local injuryItems = {}
            for _, injury in ipairs(injuriesForPart) do
                local injuryItem = NativeUI.CreateCheckboxItem(injury, false, "Select " .. injury .. " on " .. bodyPart)
                injurySubMenu:AddItem(injuryItem)
                injuryItems[injury] = injuryItem
            end

            injurySubMenu.OnCheckboxChange = function(sender, item, checked)
                local selectedInjury = nil
                for injuryName, injuryItem in pairs(injuryItems) do
                    if item == injuryItem then
                        selectedInjury = injuryName
                        break
                    end
                end
                if checked then
                    table.insert(playerInjuries, { bodyPart = bodyPart, injury = selectedInjury })
                    Notify(selectedInjury .. " added to " .. bodyPart)
                else
                    -- Remove the injury
                    for i, injuryData in ipairs(playerInjuries) do
                        if injuryData.bodyPart == bodyPart and injuryData.injury == selectedInjury then
                            table.remove(playerInjuries, i)
                            Notify(selectedInjury .. " removed from " .. bodyPart)
                            break
                        end
                    end
                end
                -- Update server with latest injuries
                TriggerServerEvent('ems:updateCivilianData', playerAge, playerSex, playerMedicalConditions, playerInjuries)
            end
        end
    end
end

-- Initialize the menu
OpenEMSMenu()
