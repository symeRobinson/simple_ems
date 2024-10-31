-- config.lua

Config = {}

-- List of Units
Config.Units = {
    "Medic 1",
    "Medic 2",
    "Rescue 1",
    "EMS Supervisor",
    "Ambulance 1"
}

-- List of Stations with coordinates
Config.Stations = {
    ["Station 1"] = { x = 200.0, y = -1000.0, z = 30.0 },
    ["Station 2"] = { x = 300.0, y = -1400.0, z = 30.0 },
    ["Station 3"] = { x = 400.0, y = -1200.0, z = 30.0 }
}

-- List of Body Parts
Config.BodyParts = {
    "Head",
    "Neck",
    "Chest",
    "Abdomen",
    "Back",
    "Left Arm",
    "Right Arm",
    "Left Leg",
    "Right Leg"
}

-- Injuries per Body Part
Config.Injuries = {
    ["Head"] = {
        "Laceration",
        "Concussion",
        "Fracture",
        "Burns",
        "Bruising"
    },
    ["Neck"] = {
        "Laceration",
        "Jugular Trauma",
        "Cervical Spinal Fracture",
        "Tracheal Trauma",
        "Airway Compromise",
        "Burns",
        "Bruising"
    },
    -- Add more body parts and their injuries similarly
    ["Chest"] = {
        "Laceration",
        "Pneumothorax",
        "Cardiac Contusion",
        "Burns",
        "Bruising"
    },
    ["Abdomen"] = {
        "Laceration",
        "Internal Bleeding",
        "Burns",
        "Bruising"
    },
    ["Back"] = {
        "Laceration",
        "Spinal Fracture",
        "Burns",
        "Bruising"
    },
    ["Left Arm"] = {
        "Laceration",
        "Fracture",
        "Burns",
        "Bruising"
    },
    ["Right Arm"] = {
        "Laceration",
        "Fracture",
        "Burns",
        "Bruising"
    },
    ["Left Leg"] = {
        "Laceration",
        "Fracture",
        "Burns",
        "Bruising"
    },
    ["Right Leg"] = {
        "Laceration",
        "Fracture",
        "Burns",
        "Bruising"
    }
}

-- Medical Conditions
Config.MedicalConditions = {
    "Asthma",
    "COPD",
    "Diabetes",
    "Hypertension",
    "Heart Disease"
}

-- Treatments
Config.Treatments = {
    "Bandage",
    "Painkillers",
    "Sutures",
    "Splint",
    "CPR",
    "Defibrillation",
    "Epinephrine",
    "Oxygen Therapy"
}

-- Sex Options
Config.SexOptions = {
    "Male",
    "Female",
    "Other"
}
