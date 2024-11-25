-- client.lua

-- Ensure Config is loaded
local Config = Config or {}

-- Initialize variables
local defaultVitals = {
    HR = 80, -- Heart Rate
    RR = 16, -- Respiratory Rate
    systolicBP = 120, -- Systolic Blood Pressure
    diastolicBP = 80, -- Diastolic Blood Pressure
    SpO2 = 98 -- Oxygen Saturation
}

local vitalSigns = { -- Current player's vital signs
    HR = 80,
    RR = 16,
    systolicBP = 120,
    diastolicBP = 80,
    SpO2 = 98
}

local injuries = {} -- Table to store local player's injuries
local conditions = {} -- Table to store local player's conditions
local treatmentsApplied = {} -- Treatments applied to the player
local isCardiacArrest = false
local isUnconscious = false
local isMechanicalCPRActive = false
local hasAirwayAdjunct = false
local currentAirwayEffectiveness = 0
local cardiacArrestStartTime = nil
local cprStartTime = nil
local ROSC = false -- Return of Spontaneous Circulation
local sedated = false
local currentRhythm = "normal" -- Current cardiac rhythm
local patientAnimation = nil -- To store the animation status

local playersData = {} -- Data for all players (injuries, conditions, vitals)

local state = {
    selectedLocation = 1,
    selectedInjury = 1,
    selectedSeverity = 1,
    selectedInjuryIndex = nil,
    currentViewedPlayer = nil,
    isSimulationEnabled = false,
    isProviderEnabled = false,
    inventory = {},
    certificationLevel = "paramedic", -- Default to paramedic
    selectedCertificationIndex = 3, -- Default to paramedic
}

-- Initialize inventory based on certification level
local function initializeInventory()
    state.inventory = {}
    local allowedTreatments = {}
    local certLevel = Config.CertificationLevels[state.certificationLevel]
    if certLevel then
        if certLevel.treatments == "all" then
            for treatmentName, _ in pairs(Config.Treatments) do
                allowedTreatments[treatmentName] = true
            end
        else
            for _, treatmentName in ipairs(certLevel.treatments) do
                allowedTreatments[treatmentName] = true
            end
        end
    end

    for treatmentName, _ in pairs(allowedTreatments) do
        state.inventory[treatmentName] = 5 -- Each treatment has 5 uses
    end
end

initializeInventory()

-- Helper function to show notifications
function ShowNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, true)
end

-- Function to check for critical conditions based on vital signs
local function checkCriticalConditions()
    -- Check if patient enters cardiac arrest
    if (vitalSigns.HR <= Config.CriticalThresholds.cardiac_arrest.HR.max or vitalSigns.systolicBP <= Config.CriticalThresholds.cardiac_arrest.BP.systolic) and not isCardiacArrest then
        isCardiacArrest = true
        cardiacArrestStartTime = GetGameTimer()
        cprStartTime = nil
        vitalSigns.HR = 0
        vitalSigns.SpO2 = 10 -- O2 saturation drops to 10%
        currentRhythm = math.random() < 0.5 and "v_fib" or "v_tach" -- Random rhythm
        ShowNotification("~r~You have gone into cardiac arrest.")
        StartUnconsciousAnimation()
    end

    -- Check for unconsciousness
    if vitalSigns.systolicBP <= Config.CriticalThresholds.unconsciousness.BP.systolic and not isUnconscious then
        isUnconscious = true
        ShowNotification("~r~You have lost consciousness.")
        StartUnconsciousAnimation()
    end
end

-- Function to start unconscious animation
function StartUnconsciousAnimation()
    local playerPed = PlayerPedId()
    if not IsEntityPlayingAnim(playerPed, "misslamar1dead_body", "dead_idle", 3) then
        RequestAnimDict("misslamar1dead_body")
        while not HasAnimDictLoaded("misslamar1dead_body") do
            Citizen.Wait(100)
        end
        TaskPlayAnim(playerPed, "misslamar1dead_body", "dead_idle", 8.0, 0.0, -1, 1, 0, false, false, false)
    end
end

-- Function to stop unconscious animation
function StopUnconsciousAnimation()
    ClearPedTasks(PlayerPedId())
end

-- Function to check for desaturation causes
local function hasDesaturationCause()
    for _, injury in ipairs(injuries) do
        local injuryConfig = Config.Injuries[injury.injury]
        if injuryConfig and injuryConfig.effects.desaturation and not injury.resolved then
            return true
        end
    end
    for _, condition in ipairs(conditions) do
        local conditionConfig = Config.Conditions[condition.condition]
        if conditionConfig and conditionConfig.effects.desaturation and not condition.resolved then
            return true
        end
    end
    return false
end

-- Function to calculate defibrillation success rate
local function calculateDefibSuccessRate()
    local baseSuccessRate = 0.2 -- Base 20% chance
    local timeSinceArrest = (GetGameTimer() - cardiacArrestStartTime) / 1000 -- in seconds

    -- Adjust success rate based on time
    if timeSinceArrest > 480 then -- After 8 minutes, success rate is 0
        return 0
    elseif timeSinceArrest > 300 then -- After 5 minutes, reduce success rate
        baseSuccessRate = baseSuccessRate * 0.5
    end

    -- Increase success rate if CPR is ongoing
    if cprStartTime then
        baseSuccessRate = baseSuccessRate + 0.1
    end

    -- Increase success rate if epinephrine given
    if treatmentsApplied["epi_1_to_1"] then
        baseSuccessRate = baseSuccessRate + 0.1
    end

    -- Increase success rate if airway is managed
    if hasAirwayAdjunct and currentAirwayEffectiveness >= 0.8 then
        baseSuccessRate = baseSuccessRate + 0.1
    end

    -- Decrease success rate if severe hemorrhage not controlled
    local uncontrolledSevereHemorrhage = false
    for _, injury in ipairs(injuries) do
        local injuryConfig = Config.Injuries[injury.injury]
        if injuryConfig and injuryConfig.effects.hemorrhage and injury.severity == "severe" and not injury.resolved then
            uncontrolledSevereHemorrhage = true
            break
        end
    end
    if uncontrolledSevereHemorrhage then
        baseSuccessRate = baseSuccessRate - 0.1
    end

    -- Clamp success rate between 0 and 1
    baseSuccessRate = math.max(0, math.min(1, baseSuccessRate))

    return baseSuccessRate
end

-- Function to attempt defibrillation
local function attemptDefibrillation()
    if not isCardiacArrest then
        ShowNotification("Patient is not in cardiac arrest.")
        return
    end

    if currentRhythm == "asystole" then
        ShowNotification("Defibrillation not indicated for asystole.")
        return
    end

    local successRate = calculateDefibSuccessRate()
    local randomValue = math.random()
    if randomValue <= successRate then
        -- ROSC achieved
        ROSC = true
        isCardiacArrest = false
        isUnconscious = true -- Patient remains unconscious
        vitalSigns.HR = 60
        vitalSigns.systolicBP = 90
        vitalSigns.diastolicBP = 60
        vitalSigns.SpO2 = 85
        currentRhythm = "normal"
        ShowNotification("~g~ROSC achieved! Return of spontaneous circulation.")
        StopUnconsciousAnimation()
        StartUnconsciousAnimation()
    else
        ShowNotification("Defibrillation attempt unsuccessful.")
    end
end

-- Function to update cardiac rhythm over time
local function updateCardiacRhythm()
    if isCardiacArrest then
        local timeSinceArrest = (GetGameTimer() - cardiacArrestStartTime) / 1000 -- in seconds
        if timeSinceArrest >= 300 and currentRhythm ~= "asystole" then
            currentRhythm = "asystole"
            ShowNotification("Patient has progressed to asystole.")
        end
    end
end

-- Function to apply an injury
local function applyInjury(location, injuryName, severity)
    local injuryConfig = Config.Injuries[injuryName]
    if not injuryConfig then
        print("Invalid injury: " .. injuryName)
        return
    end

    -- Prevent duplicate injuries on the same location
    for _, injury in ipairs(injuries) do
        if injury.location == location and injury.injury == injuryName then
            print("Injury already exists on this location: " .. injuryName)
            return
        end
    end

    table.insert(injuries, { location = location, injury = injuryName, severity = severity, resolved = false })

    -- Check for triggers
    if injuryConfig.triggers then
        for triggeredCondition, time in pairs(injuryConfig.triggers) do
            Citizen.SetTimeout(time, function()
                applyCondition(triggeredCondition, "moderate")
            end)
        end
    end

    calculateVitalSigns()
    checkCriticalConditions()
end

-- Function to remove an injury
local function removeInjury(index)
    table.remove(injuries, index)
    calculateVitalSigns()
    checkCriticalConditions()
end

-- Function to apply a medical condition
local function applyCondition(conditionName, severity)
    local conditionConfig = Config.Conditions[conditionName]
    if not conditionConfig then
        print("Invalid condition: " .. conditionName)
        return
    end

    -- Prevent duplicate conditions
    for _, condition in ipairs(conditions) do
        if condition.condition == conditionName then
            print("Condition already exists: " .. conditionName)
            return
        end
    end

    table.insert(conditions, { condition = conditionName, severity = severity, resolved = false })

    -- Check for triggers
    if conditionConfig.triggers then
        for triggeredCondition, time in pairs(conditionConfig.triggers) do
            Citizen.SetTimeout(time, function()
                applyCondition(triggeredCondition, "severe")
            end)
        end
    end

    calculateVitalSigns()
    checkCriticalConditions()
end

-- Function to remove a medical condition
local function removeCondition(index)
    table.remove(conditions, index)
    calculateVitalSigns()
    checkCriticalConditions()
end

-- Airway device effectiveness
local airwayDeviceEffectiveness = {
    opa = 0.5,  -- 50% effectiveness
    npa = 0.6,  -- 60% effectiveness
    igel = 0.8, -- 80% effectiveness
    orotracheal_intubation = 1.0, -- 100% effectiveness
    surgical_cricothyroidotomy = 1.0, -- 100% effectiveness
}

-- Function to apply a treatment
local function applyTreatment(treatmentName)
    local treatmentConfig = Config.Treatments[treatmentName]
    if not treatmentConfig then
        print("Invalid treatment: " .. treatmentName)
        return
    end

    -- Check inventory
    if state.inventory[treatmentName] and state.inventory[treatmentName] > 0 then
        state.inventory[treatmentName] = state.inventory[treatmentName] - 1
    else
        ShowNotification("You do not have enough " .. treatmentConfig.name)
        return
    end

    -- Random chance for success or failure
    local success = true
    if treatmentConfig.successRate then
        success = math.random() <= treatmentConfig.successRate
    end

    if success then
        -- Add treatment to applied list
        treatmentsApplied[treatmentName] = true

        -- Airway treatments
        if airwayDeviceEffectiveness[treatmentName] then
            hasAirwayAdjunct = true
            currentAirwayEffectiveness = airwayDeviceEffectiveness[treatmentName]
            ShowNotification("Airway device applied successfully: " .. treatmentConfig.name)
        end

        -- Sedative medications
        if treatmentConfig.type == "medication" and treatmentConfig.effects and treatmentConfig.effects.sedation then
            sedated = true
            ShowNotification("Patient sedated with " .. treatmentConfig.name)
        end

        -- Mechanical CPR
        if treatmentName == "mechanical_cpr" or treatmentName == "cpr" then
            isMechanicalCPRActive = true
            cprStartTime = GetGameTimer()
            ShowNotification("CPR initiated.")
        elseif treatmentName == "mechanical_cpr_stop" or treatmentName == "cpr_discontinued" then
            isMechanicalCPRActive = false
            cprStartTime = nil
            ShowNotification("CPR stopped.")
        end

        -- Defibrillation
        if treatmentName == "manual_defib" or treatmentName == "aed" then
            attemptDefibrillation()
        end

        -- Check if treatment resolves any injuries or conditions
        for _, injury in ipairs(injuries) do
            local injuryConfig = Config.Injuries[injury.injury]
            if injuryConfig and injuryConfig.treatments and not injury.resolved then
                local allTreatmentsApplied = true
                for _, requiredTreatment in ipairs(injuryConfig.treatments) do
                    if not treatmentsApplied[requiredTreatment] then
                        allTreatmentsApplied = false
                        break
                    end
                end
                if allTreatmentsApplied then
                    injury.resolved = true
                    ShowNotification("Injury treated: " .. injuryConfig.displayName)
                end
            end
        end

        for _, condition in ipairs(conditions) do
            local conditionConfig = Config.Conditions[condition.condition]
            if conditionConfig and conditionConfig.treatments and not condition.resolved then
                local allTreatmentsApplied = true
                for _, requiredTreatment in ipairs(conditionConfig.treatments) do
                    if not treatmentsApplied[requiredTreatment] then
                        allTreatmentsApplied = false
                        break
                    end
                end
                if allTreatmentsApplied then
                    condition.resolved = true
                    ShowNotification("Condition resolved: " .. conditionConfig.displayName)
                end
            end
        end

        calculateVitalSigns()
        checkCriticalConditions()
    else
        ShowNotification("Failed to apply " .. treatmentConfig.name)
        -- Random changes for failed attempts
        -- For example, airway swelling increases
        if treatmentConfig.type == "airway" then
            vitalSigns.SpO2 = vitalSigns.SpO2 - 5
            ShowNotification("Patient's airway condition worsened.")
        end
    end
end

-- Helper function to check if a table contains a value
function table.contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Gradually adjust vital signs based on injuries, conditions, and recovery.
local function updateVitalSigns()
    -- Start with default vitals as a baseline
    local targetVitals = {
        HR = defaultVitals.HR,
        RR = defaultVitals.RR,
        systolicBP = defaultVitals.systolicBP,
        diastolicBP = defaultVitals.diastolicBP,
        SpO2 = defaultVitals.SpO2
    }

    -- Apply unresolved injury effects to targetVitals
    for _, injury in ipairs(injuries) do
        if not injury.resolved then
            local injuryConfig = Config.Injuries[injury.injury]
            if injuryConfig then
                local severityMultiplier = injuryConfig.severity[injury.severity] or 1
                if injuryConfig.effects then
                    targetVitals.HR = math.max(0, targetVitals.HR + (injuryConfig.effects.vitalChanges.HR * severityMultiplier))
                    targetVitals.RR = math.max(0, targetVitals.RR + (injuryConfig.effects.vitalChanges.RR * severityMultiplier))
                    targetVitals.systolicBP = math.max(0, targetVitals.systolicBP + (injuryConfig.effects.vitalChanges.BP * severityMultiplier))
                    targetVitals.diastolicBP = math.max(0, targetVitals.diastolicBP + (injuryConfig.effects.vitalChanges.BP * severityMultiplier))
                    targetVitals.SpO2 = math.max(0, targetVitals.SpO2 + (injuryConfig.effects.vitalChanges.SpO2 * severityMultiplier))
                end
            end
        end
    end

    -- Apply unresolved condition effects to targetVitals
    for _, condition in ipairs(conditions) do
        if not condition.resolved then
            local conditionConfig = Config.Conditions[condition.condition]
            if conditionConfig then
                local severityMultiplier = conditionConfig.severity[condition.severity] or 1
                if conditionConfig.effects then
                    targetVitals.HR = math.max(0, targetVitals.HR + (conditionConfig.effects.vitalChanges.HR * severityMultiplier))
                    targetVitals.RR = math.max(0, targetVitals.RR + (conditionConfig.effects.vitalChanges.RR * severityMultiplier))
                    targetVitals.systolicBP = math.max(0, targetVitals.systolicBP + (conditionConfig.effects.vitalChanges.BP * severityMultiplier))
                    targetVitals.diastolicBP = math.max(0, targetVitals.diastolicBP + (conditionConfig.effects.vitalChanges.BP * severityMultiplier))
                    targetVitals.SpO2 = math.max(0, targetVitals.SpO2 + (conditionConfig.effects.vitalChanges.SpO2 * severityMultiplier))
                end
            end
        end
    end

    -- Handle cardiac arrest and ROSC
    if isCardiacArrest and not ROSC then
        vitalSigns.HR = 0
        vitalSigns.RR = 0
        vitalSigns.systolicBP = 0
        vitalSigns.diastolicBP = 0
        vitalSigns.SpO2 = 0
        updateCardiacRhythm()
    elseif ROSC then
        -- Gradually recover vitals after ROSC
        local adjustmentSpeed = 0.1
        vitalSigns.HR = vitalSigns.HR + math.ceil((targetVitals.HR - vitalSigns.HR) * adjustmentSpeed)
        vitalSigns.RR = vitalSigns.RR + math.ceil((targetVitals.RR - vitalSigns.RR) * adjustmentSpeed)
        vitalSigns.systolicBP = vitalSigns.systolicBP + math.ceil((targetVitals.systolicBP - vitalSigns.systolicBP) * adjustmentSpeed)
        vitalSigns.diastolicBP = vitalSigns.diastolicBP + math.ceil((targetVitals.diastolicBP - vitalSigns.diastolicBP) * adjustmentSpeed)
        vitalSigns.SpO2 = vitalSigns.SpO2 + math.ceil((targetVitals.SpO2 - vitalSigns.SpO2) * adjustmentSpeed)
    else
        -- Normal adjustments
        local adjustmentSpeed = 0.1
        vitalSigns.HR = vitalSigns.HR + math.ceil((targetVitals.HR - vitalSigns.HR) * adjustmentSpeed)
        vitalSigns.RR = vitalSigns.RR + math.ceil((targetVitals.RR - vitalSigns.RR) * adjustmentSpeed)
        vitalSigns.systolicBP = vitalSigns.systolicBP + math.ceil((targetVitals.systolicBP - vitalSigns.systolicBP) * adjustmentSpeed)
        vitalSigns.diastolicBP = vitalSigns.diastolicBP + math.ceil((targetVitals.diastolicBP - vitalSigns.diastolicBP) * adjustmentSpeed)
        vitalSigns.SpO2 = vitalSigns.SpO2 + math.ceil((targetVitals.SpO2 - vitalSigns.SpO2) * adjustmentSpeed)
    end

    -- Clamp values
    vitalSigns.HR = math.min(math.max(vitalSigns.HR, 0), 200)
    vitalSigns.RR = math.min(math.max(vitalSigns.RR, 0), 60)
    vitalSigns.systolicBP = math.min(math.max(vitalSigns.systolicBP, 0), 250)
    vitalSigns.diastolicBP = math.min(math.max(vitalSigns.diastolicBP, 0), 150)
    vitalSigns.SpO2 = math.min(math.max(vitalSigns.SpO2, 0), 100)

    -- Check critical conditions
    checkCriticalConditions()
end

calculateVitalSigns = updateVitalSigns

-- Main thread to update vital signs and sync with server
Citizen.CreateThread(function()
    while true do
        if state.isSimulationEnabled then
            updateVitalSigns() -- Gradually update vital signs

            -- Sync data with the server every 5 seconds
            TriggerServerEvent('ems:updatePlayerData', {
                injuries = injuries,
                conditions = conditions,
                vitalSigns = vitalSigns,
                isCardiacArrest = isCardiacArrest,
                isUnconscious = isUnconscious,
                treatmentsApplied = treatmentsApplied,
                ROSC = ROSC,
                sedated = sedated,
                currentRhythm = currentRhythm,
            })
        end

        Citizen.Wait(1000) -- Adjust vitals every second
    end
end)

RegisterNetEvent('ems:receivePlayersData')
AddEventHandler('ems:receivePlayersData', function(data)
    playersData = data

    -- Update local injuries and conditions if the data is for the local player
    local playerId = GetPlayerServerId(PlayerId())
    if playersData[playerId] then
        injuries = playersData[playerId].injuries
        conditions = playersData[playerId].conditions
    end
end)


Citizen.CreateThread(function()
    TriggerServerEvent('ems:requestPlayersData')
end)
-- Event handlers for treatments applied by another player
RegisterNetEvent('ems:treatmentApplied')
AddEventHandler('ems:treatmentApplied', function(treatmentName)
    applyTreatment(treatmentName)
    local treatmentConfig = Config.Treatments[treatmentName]
    if treatmentConfig then
        ShowNotification("Treatment applied: " .. treatmentConfig.name)
    end
end)

function applyTreatmentToPatient(targetPlayerId, treatmentName)
    local treatmentConfig = Config.Treatments[treatmentName]
    if not treatmentConfig then
        ShowNotification("Invalid treatment.")
        return
    end

    -- If the treatment addresses trauma, prompt for injury location
    if treatmentConfig.type == "Wound Care" then
        -- Retrieve patient data
        local patientData = playersData[targetPlayerId]
        if not patientData then
            ShowNotification("No patient data available.")
            return
        end

        -- Collect injuries that haven't been resolved
        local injuryOptions = {}
        for i, injury in ipairs(patientData.injuries) do
            if not injury.resolved and injury.found then
                local injuryConfig = Config.Injuries[injury.injury]
                table.insert(injuryOptions, { index = i, label = injuryConfig.displayName .. " at " .. injury.location })
            end
        end

        if #injuryOptions == 0 then
            ShowNotification("No injuries found to treat.")
            return
        end

        -- Prompt player to select an injury
        local selectedInjury = selectInjuryMenu(injuryOptions)
        if selectedInjury then
            -- Send treatment application request to the server with injury index
            TriggerServerEvent('ems:applyTreatment', targetPlayerId, treatmentName, selectedInjury.index)
        end
    else
        -- For other treatments, send the request directly
        TriggerServerEvent('ems:applyTreatment', targetPlayerId, treatmentName)
    end
end

function selectInjuryMenu(injuryOptions)
    -- Create a temporary menu
    WarMenu.CreateMenu('injurySelectionMenu', 'Select Injury')

    while true do
        if WarMenu.IsMenuOpened('injurySelectionMenu') then
            for _, injuryOption in ipairs(injuryOptions) do
                if WarMenu.Button(injuryOption.label) then
                    WarMenu.CloseMenu()
                    return injuryOption
                end
            end
            if WarMenu.Button('Cancel') then
                WarMenu.CloseMenu()
                return nil
            end
            WarMenu.Display()
        else
            WarMenu.OpenMenu('injurySelectionMenu')
        end
        Citizen.Wait(0)
    end
end

RegisterNetEvent('ems:updateInjuries')
AddEventHandler('ems:updateInjuries', function(updatedInjuries)
    injuries = updatedInjuries
end)


function assessArea(targetPlayerId, areaKey)
    -- Retrieve patient data
    local patientData = playersData[targetPlayerId]
    if not patientData then
        ShowNotification("No patient data available.")
        return
    end

    -- Check for injuries or conditions related to the assessment area
    local findings = {}

    -- Check injuries
    for _, injury in ipairs(patientData.injuries) do
        local injuryConfig = Config.Injuries[injury.injury]
        if injuryConfig and injuryConfig.assessmentArea == areaKey and not injury.found then
            table.insert(findings, injuryConfig.displayName .. " (" .. injury.severity .. ") at " .. injury.location)
            injury.found = true -- Mark as found
        end
    end

    -- Check conditions
    for _, condition in ipairs(patientData.conditions) do
        local conditionConfig = Config.Conditions[condition.condition]
        if conditionConfig and conditionConfig.assessmentArea == areaKey and not condition.found then
            table.insert(findings, conditionConfig.displayName .. " (" .. condition.severity .. ")")
            condition.found = true -- Mark as found
        end
    end

    if #findings > 0 then
        -- Display findings to the player
        for _, finding in ipairs(findings) do
            ShowNotification("Found: " .. finding)
        end

        -- Update patient data on the server
        TriggerServerEvent('ems:updatePatientFindings', targetPlayerId, patientData)
    else
        ShowNotification("No abnormal findings in " .. Config.AssessmentAreas[areaKey] .. ".")
    end
end
-- Initialize menus
Citizen.CreateThread(function()
    -- Main Menus
    WarMenu.CreateMenu('emsMainMenu', 'EMS Simulator')
    WarMenu.CreateMenu('emsProviderMenu', 'EMS Provider')
    -- Sub Menus
    WarMenu.CreateSubMenu('enableSimulationMenu', 'emsMainMenu', 'Enable Simulation')
    WarMenu.CreateSubMenu('injuryManagementMenu', 'enableSimulationMenu', 'Injury Management')
    WarMenu.CreateSubMenu('addInjuryMenu', 'injuryManagementMenu', 'Add Injuries')
    WarMenu.CreateSubMenu('enableConditionsMenu', 'enableSimulationMenu', 'Enable Medical Conditions')
    WarMenu.CreateSubMenu('removeConditionsMenu', 'enableSimulationMenu', 'Remove Medical Condition')
    WarMenu.CreateSubMenu('vitalSignsMenu', 'enableSimulationMenu', 'View Vital Signs')
    WarMenu.CreateSubMenu('assessmentMenu', 'emsProviderMenu', 'Patient Assessment')
    WarMenu.CreateSubMenu('treatmentsMenu', 'emsProviderMenu', 'Treatments')
    WarMenu.CreateSubMenu('inventoryMenu', 'emsProviderMenu', 'Inventory')
    WarMenu.CreateSubMenu('certificationMenu', 'emsMainMenu', 'Select Certification Level')

    -- Menu Loop
    while true do
        -- EMS Main Menu
        if WarMenu.IsMenuOpened('emsMainMenu') then
            if WarMenu.MenuButton('Select Certification Level', 'certificationMenu') then end
            if WarMenu.MenuButton('Enable Simulation', 'enableSimulationMenu') then
                state.isSimulationEnabled = true
                ShowNotification("Simulation Enabled")
            end
            if WarMenu.MenuButton('Enable Provider Simulation', 'emsProviderMenu') then
                state.isProviderEnabled = true
                ShowNotification("Provider Simulation Enabled")
            end
            if WarMenu.Button('Exit') then
                WarMenu.CloseMenu()
            end
            WarMenu.Display()

        -- Certification Menu
        elseif WarMenu.IsMenuOpened('certificationMenu') then
            local certLevels = { "EMR", "EMT", "Paramedic" }
            local _, selectedCertIndex = WarMenu.ComboBox('Select Level', certLevels, state.selectedCertificationIndex)
            state.selectedCertificationIndex = selectedCertIndex

            if WarMenu.Button('Confirm') then
                local selectedLevel = certLevels[state.selectedCertificationIndex]:lower()
                state.certificationLevel = selectedLevel
                initializeInventory()
                ShowNotification("Certification level set to " .. certLevels[state.selectedCertificationIndex])
            end
            if WarMenu.Button('Back') then
                WarMenu.OpenMenu('emsMainMenu')
            end
            WarMenu.Display()

        -- Enable Simulation Menu
        elseif WarMenu.IsMenuOpened('enableSimulationMenu') then
            if WarMenu.MenuButton('View Vital Signs', 'vitalSignsMenu') then end
            if WarMenu.MenuButton('Injury Management', 'injuryManagementMenu') then end
            if WarMenu.MenuButton('Enable Medical Conditions', 'enableConditionsMenu') then end
            if #conditions > 0 and WarMenu.MenuButton('Remove Medical Condition', 'removeConditionsMenu') then end
            if WarMenu.Button('Back') then
                WarMenu.OpenMenu('emsMainMenu')
            end
            WarMenu.Display()

        -- View Vital Signs Menu
        elseif WarMenu.IsMenuOpened('vitalSignsMenu') then
            WarMenu.Button('Heart Rate: ' .. vitalSigns.HR .. ' bpm')
            WarMenu.Button('Blood Pressure: ' .. vitalSigns.systolicBP .. '/' .. vitalSigns.diastolicBP .. ' mmHg')
            WarMenu.Button('Respiratory Rate: ' .. vitalSigns.RR .. ' breaths/min')
            WarMenu.Button('Oxygen Saturation: ' .. vitalSigns.SpO2 .. '%')
            if isCardiacArrest then
                WarMenu.Button('~r~Cardiac Arrest~s~') -- Red text for critical condition
            else
                WarMenu.Button('Mental Status: ' .. (isUnconscious and 'Unconscious' or 'Conscious'))
            end
            if WarMenu.Button('Back') then
                WarMenu.OpenMenu('enableSimulationMenu')
            end
            WarMenu.Display()

        -- Injury Management Menu
        elseif WarMenu.IsMenuOpened('injuryManagementMenu') then
            if WarMenu.MenuButton('Add Injuries', 'addInjuryMenu') then end
            if #injuries > 0 then
                for i, injury in ipairs(injuries) do
                    local injuryConfig = Config.Injuries[injury.injury]
                    WarMenu.Button(i .. '. ' .. injuryConfig.displayName .. ' (' .. injury.severity .. ') at ' .. injury.location)
                end
            else
                WarMenu.Button('No Injuries')
            end
            if WarMenu.Button('Back') then
                WarMenu.OpenMenu('enableSimulationMenu')
            end
            WarMenu.Display()

        -- Add Injuries Menu
        elseif WarMenu.IsMenuOpened('addInjuryMenu') then
            local injuryNames = {}
            for name, _ in pairs(Config.Injuries) do
                table.insert(injuryNames, name)
            end
            local _, selectedInjuryIndex = WarMenu.ComboBox('Select Injury', injuryNames, state.selectedInjury)
            state.selectedInjury = selectedInjuryIndex

            local _, selectedSeverityIndex = WarMenu.ComboBox('Select Severity', Config.Severities, state.selectedSeverity)
            state.selectedSeverity = selectedSeverityIndex

            local _, selectedLocationIndex = WarMenu.ComboBox('Select Location', Config.BodyLocations, state.selectedLocation)
            state.selectedLocation = selectedLocationIndex

            if WarMenu.Button('Confirm') then
                local injuryName = injuryNames[state.selectedInjury]
                local severity = Config.Severities[state.selectedSeverity]
                local location = Config.BodyLocations[state.selectedLocation]
                applyInjury(location, injuryName, severity)
                ShowNotification("Injury Applied: " .. injuryName .. " (" .. severity .. ") at " .. location)
            end
            if WarMenu.Button('Back') then
                WarMenu.OpenMenu('injuryManagementMenu')
            end
            WarMenu.Display()

        -- Enable Medical Conditions Menu
        elseif WarMenu.IsMenuOpened('enableConditionsMenu') then
            local conditionNames = {}
            for name, _ in pairs(Config.Conditions) do
                table.insert(conditionNames, name)
            end
            local _, selectedConditionIndex = WarMenu.ComboBox('Select Condition', conditionNames, state.selectedCondition or 1)
            state.selectedCondition = selectedConditionIndex

            local _, selectedSeverityIndex = WarMenu.ComboBox('Select Severity', Config.Severities, state.selectedSeverity)
            state.selectedSeverity = selectedSeverityIndex

            if WarMenu.Button('Start') then
                local conditionName = conditionNames[state.selectedCondition]
                local severity = Config.Severities[state.selectedSeverity]
                applyCondition(conditionName, severity)
                ShowNotification("Condition Applied: " .. conditionName .. " (" .. severity .. ")")
            end
            if WarMenu.Button('Back') then
                WarMenu.OpenMenu('enableSimulationMenu')
            end
            WarMenu.Display()

        -- Remove Medical Condition Menu
        elseif WarMenu.IsMenuOpened('removeConditionsMenu') then
            for i, condition in ipairs(conditions) do
                local conditionConfig = Config.Conditions[condition.condition]
                if WarMenu.Button(i .. '. ' .. conditionConfig.displayName .. ' (' .. condition.severity .. ')') then
                    removeCondition(i)
                    ShowNotification("Condition Removed: " .. conditionConfig.displayName)
                end
            end
            if WarMenu.Button('Back') then
                WarMenu.OpenMenu('enableSimulationMenu')
            end
            WarMenu.Display()

        -- EMS Provider Menu
        elseif WarMenu.IsMenuOpened('emsProviderMenu') then
            if WarMenu.MenuButton('Patient Assessment', 'assessmentMenu') then
                state.currentViewedPlayer = detectClosestPlayer()
                if not state.currentViewedPlayer then
                    ShowNotification("~r~No patient nearby.")
                end
            end
            if WarMenu.MenuButton('Treatments', 'treatmentsMenu') then
                state.currentViewedPlayer = detectClosestPlayer()
                if not state.currentViewedPlayer then
                    ShowNotification("~r~No patient nearby.")
                end
            end
            if WarMenu.MenuButton('Inventory', 'inventoryMenu') then end
            if WarMenu.Button('Close') then
                WarMenu.CloseMenu()
            end
            WarMenu.Display()
        else
            Citizen.Wait(500) -- Pause the thread if no menu is open
        end
        Citizen.Wait(0) -- Keep the thread alive
    end
end)

local function detectClosestPlayer()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPlayer = nil
    local closestDistance = 5.0 -- Detection range

    for playerId, data in pairs(playersData) do
        if playerId ~= GetPlayerServerId(PlayerId()) then
            local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
            if DoesEntityExist(targetPed) then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)
                if distance < closestDistance then
                    closestPlayer = playerId
                    closestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

Citizen.CreateThread(function()
    while true do
        if state.isProviderEnabled and not WarMenu.IsAnyMenuOpened() then
            local closestPlayer = detectClosestPlayer()
            if closestPlayer then
                -- Display interaction prompt
                SetTextComponentFormat("STRING")
                AddTextComponentString("Press ~INPUT_CONTEXT~ to assess patient")
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                if IsControlJustPressed(1, 51) then -- E key
                    state.currentViewedPlayer = closestPlayer
                    WarMenu.OpenMenu('emsProviderMenu')
                end
            end
        end
        Citizen.Wait(0)
    end
end)

-- Command to open EMS Main Menu
RegisterCommand('ems', function()
    WarMenu.OpenMenu('emsMainMenu')
end)

-- Ensure playersData is updated when resource starts
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerServerEvent('ems:requestPlayersData')
    end
end)
