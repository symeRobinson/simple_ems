-- config.lua

Config = {}

-- Define all available treatments with their display names and any additional properties
Config.Treatments = {
    -- Airway
    oxygen = { name = "Oxygen", type = "airway", successRate = 0.9 },
    suction = { name = "Suction", type = "airway", successRate = 0.95 },
    cpap = { name = "CPAP", type = "airway", successRate = 0.85 },
    video_laryngoscopy = { name = "Video Laryngoscopy", type = "airway", successRate = 0.95 },
    sedation_assisted_intubation = { name = "Sedation Assisted Intubation", type = "airway", successRate = 0.9 },
    orotracheal_intubation = { name = "Orotracheal Intubation", type = "airway", successRate = 0.85 },
    peep = { name = "PEEP", type = "airway", successRate = 0.9 },
    eti_verification = { name = "ETI Verification", type = "airway", successRate = 1.0 },
    igel = { name = "iGel", type = "airway", successRate = 0.8 },
    pleural_decompression = { name = "Pleural Decompression", type = "airway", successRate = 0.9 },
    npa = { name = "Nasal Pharyngeal Airway", type = "airway", successRate = 0.6 },
    opa = { name = "Oropharyngeal Airway", type = "airway", successRate = 0.5 },
    manual_airway = { name = "Manual Airway Maneuver", type = "airway", successRate = 0.4 },
    surgical_cricothyroidotomy = { name = "Surgical Cricothyroidotomy", type = "airway", successRate = 0.7 },
    tracheostomy_care = { name = "Tracheostomy Care", type = "airway", successRate = 0.9 },
    tracheostomy_tube_replacement = { name = "Tracheostomy Tube Replacement", type = "airway", successRate = 0.85 },
    back_blows = { name = "Back Blows", type = "airway", successRate = 0.5 },
    chest_thrusts = { name = "Chest Thrusts", type = "airway", successRate = 0.5 },
    heimlich_maneuver = { name = "Heimlich Maneuver", type = "airway", successRate = 0.7 },
    cricoid_pressure = { name = "Cricoid Pressure", type = "airway", successRate = 0.6 },
    magill_forceps = { name = "Magill Forceps", type = "airway", successRate = 0.8 },
    -- Defib/Cardio
    mechanical_cpr = { name = "Mechanical CPR", type = "cardio" },
    mechanical_cpr_stop = { name = "Stop Mechanical CPR", type = "cardio" },
    manual_defib = { name = "Manual Defibrillation", type = "cardio" },
    aed = { name = "AED", type = "cardio" },
    cardioversion = { name = "Cardioversion", type = "cardio" },
    ccr = { name = "CCR", type = "cardio" },
    cpr = { name = "CPR", type = "cardio" },
    cpr_discontinued = { name = "CPR Discontinued", type = "cardio" },
    pacing = { name = "Pacing", type = "cardio" },
    pacing_discontinue = { name = "Pacing Discontinue", type = "cardio" },
    vagal_maneuver = { name = "Vagal Maneuver", type = "cardio" },
    -- IV Therapy
    io = { name = "Intraosseous Access", type = "iv" },
    iv_bolus = { name = "IV Bolus", type = "iv" },
    iv_monitoring = { name = "IV Monitoring", type = "iv" },
    iv_therapy = { name = "IV Therapy", type = "iv" },
    -- Medications
    acetaminophen = { name = "Acetaminophen", type = "medication", indications = { "fever", "pain_mild" } },
    adenosine = { name = "Adenosine", type = "medication", indications = { "svt" } },
    albuterol = { name = "Albuterol", type = "medication", indications = { "asthma", "copd_exacerbation" } },
    amiodarone = { name = "Amiodarone", type = "medication", indications = { "v_tach", "v_fib" } },
    aspirin = { name = "Aspirin", type = "medication", indications = { "chest_pain" } },
    atropine = { name = "Atropine", type = "medication", indications = { "bradycardia" } },
    benadryl = { name = "Benadryl", type = "medication", indications = { "allergic_reaction" } },
    calcium_chloride = { name = "Calcium Chloride", type = "medication", indications = { "hyperkalemia", "calcium_channel_blocker_overdose" } },
    dexamethasone = { name = "Dexamethasone", type = "medication", indications = { "cerebral_edema", "anaphylaxis" } },
    d10 = { name = "D10", type = "medication", indications = { "hypoglycemia" } },
    diphenhydramine = { name = "Diphenhydramine", type = "medication", indications = { "allergic_reaction" } },
    dopamine = { name = "Dopamine", type = "medication", indications = { "hypotension", "bradycardia" } },
    droperidol = { name = "Droperidol", type = "medication", indications = { "agitation", "psychosis" } },
    duodote = { name = "Duodote", type = "medication", indications = { "organophosphate_poisoning" } },
    duoneb = { name = "Duoneb", type = "medication", indications = { "asthma", "copd_exacerbation" } },
    epi_1_to_1000 = { name = "Epinephrine 1:1000", type = "medication", indications = { "anaphylaxis", "asthma_severe" } },
    epipen = { name = "EpiPen", type = "medication", indications = { "anaphylaxis" } },
    epipen_jr = { name = "EpiPen Jr", type = "medication", indications = { "anaphylaxis_pediatric" } },
    epi_1_to_1 = { name = "Epinephrine 1:1", type = "medication", indications = { "cardiac_arrest" } },
    epi_10_to_1 = { name = "Epinephrine 10:1", type = "medication", indications = { "cardiac_arrest" } },
    etomidate = { name = "Etomidate", type = "medication", indications = { "sedation" } },
    glucagon = { name = "Glucagon", type = "medication", indications = { "hypoglycemia", "beta_blocker_overdose" } },
    haloperidol = { name = "Haloperidol", type = "medication", indications = { "agitation", "psychosis" } },
    hydroxocobalamin = { name = "Hydroxocobalamin", type = "medication", indications = { "cyanide_poisoning" } },
    ketamine = { name = "Ketamine", type = "medication", indications = { "sedation", "pain_severe" } },
    ketorolac = { name = "Ketorolac", type = "medication", indications = { "pain_moderate" } },
    lidocaine_2 = { name = "Lidocaine 2%", type = "medication", indications = { "v_tach", "v_fib" } },
    mag_sulfate_infusion = { name = "Magnesium Sulfate Infusion", type = "medication", indications = { "eclampsia", "torsades_de_pointes" } },
    midazolam = { name = "Midazolam", type = "medication", indications = { "seizure", "sedation" } },
    morphine = { name = "Morphine", type = "medication", indications = { "pain_severe" } },
    narcan = { name = "Narcan", type = "medication", indications = { "opioid_overdose" } },
    neosynephrine = { name = "Neosynephrine", type = "medication", indications = { "nasal_intubation" } },
    nitrostat = { name = "Nitrostat", type = "medication", indications = { "chest_pain", "pulmonary_edema" } },
    ondansetron = { name = "Ondansetron", type = "medication", indications = { "nausea", "vomiting" } },
    oral_glucose = { name = "Oral Glucose", type = "medication", indications = { "hypoglycemia" } },
    sodium_bicarb = { name = "Sodium Bicarbonate", type = "medication", indications = { "acidosis", "tricyclic_overdose" } },
    saline = { name = "Saline", type = "medication", indications = { "hypotension", "dehydration" } },
    txa = { name = "TXA", type = "medication", indications = { "hemorrhage_severe" } },
    -- Other Treatments
    ecg_12_lead = { name = "12 Lead ECG", type = "diagnostic" },
    ecg_4_lead = { name = "4 Lead ECG", type = "diagnostic" },
    bandaging = { name = "Bandaging", type = "wound_care" },
    bleeding_control = { name = "Bleeding Control", type = "wound_care" },
    c_spine_clearance = { name = "C-Spine Clearance", type = "immobilization" },
    cooling = { name = "Cooling", type = "temperature" },
    ecg_transmission = { name = "ECG Transmission", type = "diagnostic" },
    irrigation = { name = "Irrigation", type = "wound_care" },
    joint_reduction = { name = "Joint Reduction", type = "musculoskeletal" },
    ob_delivery = { name = "OB Delivery", type = "obstetrics" },
    patella_reduction = { name = "Patella Reduction", type = "musculoskeletal" },
    soft_restraints = { name = "Soft Restraints", type = "restraints" },
    basic_splinting = { name = "Basic Splinting", type = "immobilization" },
    c_collar = { name = "C-Collar", type = "immobilization" },
    stroke_alert = { name = "Stroke Alert", type = "neurological" },
    taser_barb_removal = { name = "Taser Barb Removal", type = "wound_care" },
    time_of_death = { name = "Time Of Death", type = "documentation" },
    tourniquet = { name = "Tourniquet", type = "wound_care" },
    traction_splint = { name = "Traction Splint", type = "immobilization" },
    warming = { name = "Warming", type = "temperature" },
    occlusive_dressing = { name = "Occlusive Dressing", type = "wound_care" },
    needle_decompression = { name = "Needle Decompression", type = "airway" },
    pain_management = { name = "Pain Management", type = "medication" },
    fluid_resuscitation = { name = "Fluid Resuscitation", type = "iv" },
}

-- Define assessment areas
Config.AssessmentAreas = {
    head = "Head",
    face = "Face",
    eyes = "Eyes",
    neck = "Neck",
    chest = "Chest",
    lungs = "Lung Sounds",
    back = "Back",
    abdomen = "Abdomen",
    pelvis = "Pelvis",
    arms = "Extremities",
    legs = "Extremities",
    neurological = "Neurological",
    skin = "Skin Condition",
    mental_status = "Mental Status",
}

-- Define injuries with their effects, treatments, and assessment areas
Config.Injuries = {
    abrasion = {
        displayName = "Abrasion",
        severity = { mild = 1, moderate = 1.2, severe = 1.5 },
        effects = {
            hemorrhage = false,
            desaturation = false,
            vitalChanges = { HR = 0, RR = 0, BP = 0, SpO2 = 0 },
        },
        treatments = { "bandaging" },
        assessmentArea = "skin",
    },
    acute_amputation = {
        displayName = "Acute Amputation",
        severity = { mild = 1, moderate = 1.5, severe = 2 },
        effects = {
            hemorrhage = true,
            desaturation = false,
            vitalChanges = { HR = 30, RR = 5, BP = -40, SpO2 = -10 },
        },
        treatments = { "tourniquet", "bandaging", "fluid_resuscitation" },
        assessmentArea = "extremities",
    },
    avulsion = {
        displayName = "Avulsion",
        severity = { mild = 1, moderate = 1.2, severe = 1.5 },
        effects = {
            hemorrhage = true,
            desaturation = false,
            vitalChanges = { HR = 15, RR = 2, BP = -10, SpO2 = 0 },
        },
        treatments = { "bandaging" },
        assessmentArea = "skin",
    },
    flail_segment = {
        displayName = "Flail Segment",
        severity = { mild = 1, moderate = 1.3, severe = 1.6 },
        effects = {
            hemorrhage = false,
            desaturation = true,
            vitalChanges = { HR = 20, RR = 5, BP = -20, SpO2 = -15 },
        },
        treatments = { "oxygen", "basic_splinting" },
        assessmentArea = "chest",
    },
    femur_fracture = {
        displayName = "Femur Fracture",
        severity = { mild = 1, moderate = 1.5, severe = 2 },
        effects = {
            hemorrhage = true,
            desaturation = false,
            vitalChanges = { HR = 25, RR = 3, BP = -30, SpO2 = -5 },
        },
        treatments = { "traction_splint", "bandaging", "fluid_resuscitation" },
        assessmentArea = "extremities",
        specificParts = { "upper_leg" },
    },
    gunshot_wound_chest = {
        displayName = "Gunshot Wound to Chest",
        severity = { mild = 1, moderate = 1.5, severe = 2 },
        effects = {
            hemorrhage = true,
            desaturation = true,
            vitalChanges = { HR = 35, RR = 5, BP = -40, SpO2 = -20 },
        },
        treatments = { "occlusive_dressing", "needle_decompression", "fluid_resuscitation" },
        assessmentArea = "chest",
        triggers = { ["tension_pneumothorax"] = 180000 },
    },
    gunshot_wound_peripheral = {
        displayName = "Gunshot Wound to Peripheral Area",
        severity = { mild = 1, moderate = 1.3, severe = 1.6 },
        effects = {
            hemorrhage = true,
            desaturation = false,
            vitalChanges = { HR = 20, RR = 2, BP = -25, SpO2 = 0 },
        },
        treatments = { "tourniquet", "bandaging", "fluid_resuscitation" },
        assessmentArea = "extremities",
    },
    burn_blistering = {
        displayName = "Burn - Blistering",
        severity = { mild = 1, moderate = 1.2, severe = 1.5 },
        effects = {
            hemorrhage = false,
            desaturation = true,
            vitalChanges = { HR = 15, RR = 3, BP = -10, SpO2 = -5 },
        },
        treatments = { "cooling", "bandaging" },
        assessmentArea = "skin",
    },
    burn_charring = {
        displayName = "Burn - Charring",
        severity = { mild = 1.5, moderate = 2, severe = 2.5 },
        effects = {
            hemorrhage = true,
            desaturation = true,
            vitalChanges = { HR = 25, RR = 5, BP = -20, SpO2 = -15 },
        },
        treatments = { "cooling", "bandaging", "pain_management", "fluid_resuscitation" },
        assessmentArea = "skin",
    },
    burn_redness = {
        displayName = "Burn - Redness",
        severity = { mild = 1, moderate = 1.2, severe = 1.3 },
        effects = {
            hemorrhage = false,
            desaturation = false,
            vitalChanges = { HR = 10, RR = 0, BP = 0, SpO2 = 0 },
        },
        treatments = { "cooling" },
        assessmentArea = "skin",
    },
    burn_white_waxy = {
        displayName = "Burn - White Waxy Appearance",
        severity = { mild = 1.5, moderate = 2, severe = 2.5 },
        effects = {
            hemorrhage = false,
            desaturation = true,
            vitalChanges = { HR = 20, RR = 4, BP = -15, SpO2 = -10 },
        },
        treatments = { "cooling", "bandaging", "fluid_resuscitation" },
        assessmentArea = "skin",
    },
    puncture_stab_wound = {
        displayName = "Puncture/Stab Wound",
        severity = { mild = 1, moderate = 1.3, severe = 1.6 },
        effects = {
            hemorrhage = true,
            desaturation = true,
            vitalChanges = { HR = 25, RR = 3, BP = -30, SpO2 = -10 },
        },
        treatments = { "occlusive_dressing", "bandaging", "fluid_resuscitation" },
        assessmentArea = "chest",
    },
    laceration = {
        displayName = "Laceration",
        severity = { mild = 1, moderate = 1.2, severe = 1.5 },
        effects = {
            hemorrhage = true,
            desaturation = false,
            vitalChanges = { HR = 15, RR = 2, BP = -10, SpO2 = 0 },
        },
        treatments = { "bandaging" },
        assessmentArea = "skin",
    },
    fracture_closed = {
        displayName = "Fracture - Closed",
        severity = { mild = 1, moderate = 1.3, severe = 1.6 },
        effects = {
            hemorrhage = false,
            desaturation = false,
            vitalChanges = { HR = 10, RR = 0, BP = 0, SpO2 = 0 },
        },
        treatments = { "basic_splinting" },
        assessmentArea = "extremities",
    },
    fracture_open = {
        displayName = "Fracture - Open",
        severity = { mild = 1.5, moderate = 2, severe = 2.5 },
        effects = {
            hemorrhage = true,
            desaturation = false,
            vitalChanges = { HR = 30, RR = 4, BP = -20, SpO2 = -5 },
        },
        treatments = { "basic_splinting", "bandaging", "fluid_resuscitation" },
        assessmentArea = "extremities",
    },
    crush_injury = {
        displayName = "Crush Injury",
        severity = { mild = 1.5, moderate = 2, severe = 2.5 },
        effects = {
            hemorrhage = true,
            desaturation = true,
            vitalChanges = { HR = 30, RR = 6, BP = -25, SpO2 = -15 },
        },
        treatments = { "pain_management", "tourniquet", "fluid_resuscitation" },
        assessmentArea = "extremities",
    },
    decapitation = {
        displayName = "Decapitation",
        severity = { mild = 3, moderate = 3.5, severe = 4 },
        effects = {
            hemorrhage = true,
            desaturation = true,
            vitalChanges = { HR = 0, RR = 0, BP = 0, SpO2 = 0 },
        },
        treatments = {},
        assessmentArea = "head",
    },
    deformity = {
        displayName = "Deformity",
        severity = { mild = 1, moderate = 1.2, severe = 1.5 },
        effects = {
            hemorrhage = false,
            desaturation = false,
            vitalChanges = { HR = 5, RR = 0, BP = 0, SpO2 = 0 },
        },
        treatments = { "basic_splinting" },
        assessmentArea = "extremities",
    },
    dislocation = {
        displayName = "Dislocation",
        severity = { mild = 1, moderate = 1.2, severe = 1.5 },
        effects = {
            hemorrhage = false,
            desaturation = false,
            vitalChanges = { HR = 5, RR = 0, BP = 0, SpO2 = 0 },
        },
        treatments = { "joint_reduction" },
        assessmentArea = "extremities",
    },
    edema = {
        displayName = "Edema",
        severity = { mild = 1, moderate = 1.3, severe = 1.5 },
        effects = {
            hemorrhage = false,
            desaturation = true,
            vitalChanges = { HR = 5, RR = 2, BP = -5, SpO2 = -5 },
        },
        treatments = { "oxygen" },
        assessmentArea = "extremities",
    },
}

-- Define medical conditions with their effects, treatments, and assessment areas
Config.Conditions = {
    asthma_mild = {
        displayName = "Mild Asthma Exacerbation",
        severity = { mild = 1, moderate = 1.5, severe = 2 },
        effects = {
            desaturation = true,
            vitalChanges = { HR = 10, RR = 5, BP = 0, SpO2 = -10 },
        },
        treatments = { "albuterol" },
        triggers = { ["asthma_moderate"] = 180000 },
        assessmentArea = "lungs",
    },
    asthma_moderate = {
        displayName = "Moderate Asthma Exacerbation",
        severity = { mild = 1.5, moderate = 2, severe = 2.5 },
        effects = {
            desaturation = true,
            vitalChanges = { HR = 20, RR = 10, BP = -10, SpO2 = -20 },
        },
        treatments = { "albuterol", "cpap" },
        triggers = { ["asthma_severe"] = 180000 },
        assessmentArea = "lungs",
    },
    asthma_severe = {
        displayName = "Severe Asthma Exacerbation",
        severity = { mild = 2, moderate = 2.5, severe = 3 },
        effects = {
            desaturation = true,
            vitalChanges = { HR = 30, RR = 15, BP = -20, SpO2 = -30 },
        },
        treatments = { "epi_1_to_1000", "orotracheal_intubation" },
        assessmentArea = "lungs",
    },
    combative_behavior = {
        displayName = "Combative Behavior",
        severity = { mild = 1, moderate = 1.2, severe = 1.5 },
        effects = {
            vitalChanges = { HR = 15, RR = 5, BP = 10, SpO2 = 0 },
        },
        treatments = { "droperidol", "haloperidol", "midazolam", "ketamine" },
        assessmentArea = "mental_status",
    },
    excited_delirium = {
        displayName = "Excited Delirium",
        severity = { mild = 1.5, moderate = 2, severe = 2.5 },
        effects = {
            vitalChanges = { HR = 30, RR = 10, BP = 20, SpO2 = -5 },
        },
        treatments = { "ketamine", "midazolam" },
        assessmentArea = "mental_status",
    },
    tension_pneumothorax = {
        displayName = "Tension Pneumothorax",
        severity = { mild = 1.5, moderate = 2, severe = 2.5 },
        effects = {
            desaturation = true,
            vitalChanges = { HR = 40, RR = 15, BP = -50, SpO2 = -30 },
        },
        treatments = { "needle_decompression" },
        assessmentArea = "chest",
    },
    v_fib = {
        displayName = "Ventricular Fibrillation",
        severity = { mild = 3, moderate = 3, severe = 3 },
        effects = {
            desaturation = true,
            vitalChanges = { HR = 0, RR = 0, BP = 0, SpO2 = 0 },
        },
        treatments = { "manual_defib", "cpr", "epi_1_to_1" },
        assessmentArea = "cardiac",
    },
    v_tach = {
        displayName = "Ventricular Tachycardia",
        severity = { mild = 3, moderate = 3, severe = 3 },
        effects = {
            desaturation = true,
            vitalChanges = { HR = 0, RR = 0, BP = 0, SpO2 = 0 },
        },
        treatments = { "manual_defib", "cpr", "amiodarone" },
        assessmentArea = "cardiac",
    },
    asystole = {
        displayName = "Asystole",
        severity = { mild = 3, moderate = 3, severe = 3 },
        effects = {
            desaturation = true,
            vitalChanges = { HR = 0, RR = 0, BP = 0, SpO2 = 0 },
        },
        treatments = { "cpr", "epi_1_to_1" },
        assessmentArea = "cardiac",
    },
    -- Add more conditions as needed...
}

-- Thresholds for critical conditions
Config.CriticalThresholds = {
    cardiac_arrest = {
        HR = { min = 0, max = 30 }, -- HR <= 30 triggers arrest
        BP = { systolic = 45 }, -- Systolic BP <= 45 triggers arrest
    },
    unconsciousness = {
        BP = { systolic = 60 },
    },
    respiratory_depression = {
        RR = 8,
        SpO2 = 85,
    },
}

-- List of body locations for injury application
Config.BodyLocations = {
    "Head",
    "Face",
    "Eyes",
    "Neck",
    "Chest",
    "Back",
    "Abdomen",
    "Pelvis",
    "Upper Left Arm",
    "Lower Left Arm",
    "Upper Right Arm",
    "Lower Right Arm",
    "Left Hand",
    "Right Hand",
    "Upper Left Leg",
    "Lower Left Leg",
    "Upper Right Leg",
    "Lower Right Leg",
    "Left Foot",
    "Right Foot",
}

-- List of severities
Config.Severities = { "mild", "moderate", "severe" }

-- Certification levels
Config.CertificationLevels = {
    emr = { name = "EMR", treatments = { "cpr", "bandaging", "tourniquet", "oxygen" } },
    emt = { name = "EMT", treatments = { "cpr", "bandaging", "tourniquet", "oxygen", "albuterol", "nitrostat", "epi_pen", "narcan", "glucose" } },
    paramedic = { name = "Paramedic", treatments = "all" },
}
