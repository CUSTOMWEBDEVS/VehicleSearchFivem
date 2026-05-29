Config = {}

-- Keybind defaults. Players can change these in GTA/FiveM keybind settings.
Config.SearchCommand = "vs_search"
Config.MarkCommand = "vs_markvehicle"

Config.DefaultSearchKey = "O"
Config.DefaultMarkKey = "K"

-- Interaction key: E
Config.InteractControl = 38

Config.SearchDistance = 4.5
Config.VehicleScanRadius = 6.0
Config.TrunkDistance = 2.5
Config.ItemDistance = 2.0
Config.StationDistance = 3.0

Config.SearchTime = 3500
Config.GrabBagTime = 900
Config.BagItemTime = 1600
Config.StoreBagTime = 1000
Config.TurnInTime = 2000

Config.RewardMin = 150
Config.RewardMax = 400

-- If true, emergency class vehicles automatically count as evidence vehicles.
Config.EmergencyVehiclesAreSupply = true

-- If true, any vehicle you have driven this session can be used as a supply vehicle.
Config.PlayerDrivenVehiclesAreSupply = false

Config.PlatePrefixesAreSupply = {
    "POL",
    "LSPD",
    "BCSO",
    "SASP",
    "SAHP",
    "SHERIFF",
    "PD",
    "SO"
}

Config.BlockedSearchClasses = {
    [8] = true,   -- motorcycles
    [13] = true,  -- bicycles
    [14] = true,  -- boats
    [15] = true,  -- helicopters
    [16] = true,  -- planes
    [18] = true,  -- emergency
    [19] = true,  -- military
    [21] = true   -- trains
}

Config.Stations = {
    -- These are intentionally placed in OPEN pavement/lot areas, not tight against buildings.
    -- If your custom map still conflicts, use /vs_stationcoords while standing where you want the marker.

    -- Mission Row - open rear lot entrance area
    { name = "Mission Row evidence", coords = vector3(440.79, -981.13, 30.69) },

    -- Vespucci - open street/lot near station
    { name = "Vespucci evidence", coords = vector3(-1107.73, -844.62, 19.32) },

    -- Davis - open road/lot near station
    { name = "Davis Evidence", coords = vector3(407.63, -1617.21, 29.29) },

    -- Vinewood - open lot/street area
    { name = "Vinewood evidence", coords = vector3(619.87, 16.97, 87.82) },

    -- Rockford - open curb/lot area
    { name = "Rockford evidence", coords = vector3(-561.78, -131.46, 38.42) },

    -- Sandy Shores - open road/lot in front
    { name = "Sandy Shores Evidence", coords = vector3(1857.51, 3688.85, 34.27) },

    -- Paleto - open sheriff parking / roadside
    { name = "Paleto Evidence", coords = vector3(-437.37, 6014.05, 32.27) },

    -- Government Facility
    { name = "Government Facility Evidence", coords = vector3(2523.15, -412.71, 94.12) },

    -- Senora Way HP Building
    { name = "SAHP - Senora Way Evidence", coords = vector3(2479.13, 1586.64, 30.60) },

    -- Route 13 HP Building 
    { name = "SAHP - Route 13 Evidence", coords = vector3(1541.11, 818.57, 77.66) },
    
    -- Chumash - open turnout
    { name = "Chumash Evidence", coords = vector3(-3158.08, 1105.03, 20.85) },

    -- La Mesa - open road/lot
    { name = "La Mesa evidence", coords = vector3(830.52, -1291.43, 28.24) },

    -- Del Perro - open parking/curb
    { name = "Del Perro evidence", coords = vector3(-1632.05, -1015.54, 13.13) },

    -- Airport - open exterior roadway
    { name = "Airport Evidence", coords = vector3(-903.50, -2406.02, 13.91) },

    -- Harbor - open paved lot
    { name = "Harbor Evidence", coords = vector3(770.46, -2978.41, 5.80) },

    -- Bolingbroke - open intake road/lot
    { name = "Bolingbroke Evidence", coords = vector3(1846.96, 2586.02, 45.67) },

    -- Zancudo - open access road
    { name = "Zancudo Evidence", coords = vector3(-2302.91, 3387.64, 31.26) },
}

Config.Items = {
    -- LEGAL ITEMS
    { label = "Wallet", illegal = false, prop = `prop_ld_wallet_01` },
    { label = "Phone", illegal = false, prop = `prop_npc_phone_02` },
    { label = "Keys", illegal = false, prop = `p_car_keys_01` },
    { label = "Cash", illegal = false, prop = `prop_cash_pile_01` },
    { label = "Laptop", illegal = false, prop = `prop_laptop_01a` },
    { label = "Camera", illegal = false, prop = `prop_pap_camera_01` },
    { label = "Watch", illegal = false, prop = `prop_watch_02` },
    { label = "Cigarettes", illegal = false, prop = `prop_cs_ciggy_01` },
    { label = "Lighter", illegal = false, prop = `prop_lighter_01` },
    { label = "Backpack", illegal = false, prop = `p_michael_backpack_s` },
    { label = "Duffel Bag", illegal = false, prop = `xm_prop_x17_bag_01a` },
    { label = "Soda", illegal = false, prop = `prop_ecola_can` },
    { label = "Burger", illegal = false, prop = `prop_cs_burger_01` },
    { label = "Donut", illegal = false, prop = `prop_donut_02` },
    { label = "Coffee", illegal = false, prop = `p_amb_coffeecup_01` },
    { label = "Beer", illegal = false, prop = `prop_beer_bottle` },
    { label = "Fishing Rod", illegal = false, prop = `prop_fishing_rod_01` },
    { label = "Toolbox", illegal = false, prop = `prop_tool_box_04` },
    { label = "Hammer", illegal = false, prop = `prop_tool_hammer` },
    { label = "Wrench", illegal = false, prop = `prop_cs_wrench` },
    { label = "Drill", illegal = false, prop = `prop_tool_drill` },
    { label = "Clipboard", illegal = false, prop = `p_amb_clipboard_01` },
    { label = "Notepad", illegal = false, prop = `prop_notepad_01` },
    { label = "Flashlight", illegal = false, prop = `prop_cs_flashlight` },
    { label = "Radio", illegal = false, prop = `prop_cs_hand_radio` },
    { label = "Tablet", illegal = false, prop = `prop_cs_tablet` },
    { label = "Briefcase", illegal = false, prop = `prop_ld_case_01` },
    { label = "Suitcase", illegal = false, prop = `prop_security_case_01` },
    { label = "Shopping Bag", illegal = false, prop = `prop_shopping_bags01` },
    { label = "Pizza Box", illegal = false, prop = `prop_pizza_box_02` },
    { label = "First Aid Kit", illegal = false, prop = `prop_med_bag_01b` },
    { label = "Bandages", illegal = false, prop = `prop_ld_health_pack` },
    { label = "Gas Can", illegal = false, prop = `prop_jerrycan_01a` },
    { label = "Spray Paint", illegal = false, prop = `prop_spray_can_01` },
    { label = "Bicycle Helmet", illegal = false, prop = `prop_bikini_helmet_01` },
    { label = "Book", illegal = false, prop = `prop_novel_01` },
    { label = "Newspaper", illegal = false, prop = `prop_cliff_paper` },
    { label = "Umbrella", illegal = false, prop = `p_amb_brolly_01` },
    { label = "Tennis Racket", illegal = false, prop = `prop_tennis_rack_01` },
    { label = "Golf Club", illegal = false, prop = `prop_golf_iron_01` },
    { label = "Baseball", illegal = false, prop = `prop_baseball` },
    { label = "Basketball", illegal = false, prop = `prop_bskball_01` },
    { label = "Headphones", illegal = false, prop = `prop_headphones_01` },
    { label = "USB Drive", illegal = false, prop = `prop_cs_usb_drive` },
    { label = "Lottery Ticket", illegal = false, prop = `prop_lotery_winwinners` },
    { label = "Toy", illegal = false, prop = `prop_teddy_01` },
    { label = "Bottle of Water", illegal = false, prop = `prop_ld_flow_bottle` },
    { label = "Milk Crate", illegal = false, prop = `prop_milk_crate01` },

    -- ILLEGAL ITEMS
    { label = "Knife", illegal = true, prop = `w_me_knife_01` },
    { label = "Switchblade", illegal = true, prop = `w_me_switchblade` },
    { label = "Bat", illegal = true, prop = `w_me_bat` },
    { label = "Crowbar", illegal = true, prop = `prop_ing_crowbar` },
    { label = "Brass Knuckles", illegal = true, prop = `prop_cs_knuckle_duster` },
    { label = "Pistol", illegal = true, prop = `w_pi_pistol` },
    { label = "Combat Pistol", illegal = true, prop = `w_pi_combatpistol` },
    { label = "SNS Pistol", illegal = true, prop = `w_pi_sns_pistol` },
    { label = "SMG", illegal = true, prop = `w_sb_smg` },
    { label = "Assault Rifle", illegal = true, prop = `w_ar_assaultrifle` },
    { label = "Shotgun", illegal = true, prop = `w_sg_pumpshotgun` },
    { label = "Ammo Box", illegal = true, prop = `prop_ammo_box_01` },
    { label = "Suppressor", illegal = true, prop = `prop_suppressor` },

    { label = "Meth", illegal = true, prop = `prop_meth_bag_01` },
    { label = "Marijuana", illegal = true, prop = `prop_weed_bottle` },
    { label = "Heroin", illegal = true, prop = `prop_meth_bag_01` },
    { label = "Cocaine", illegal = true, prop = `prop_coke_block_01` },
    { label = "Ecstasy", illegal = true, prop = `prop_drug_package_02` },
    { label = "Crack Pipe", illegal = true, prop = `prop_cs_crackpipe` },
    { label = "Needle", illegal = true, prop = `prop_syringe_01` },
    { label = "Drug Scale", illegal = true, prop = `bkr_prop_coke_scale_01` },
    { label = "Pill Bottle", illegal = true, prop = `prop_cs_pills` },

    { label = "Lockpick", illegal = true, prop = `prop_tool_screwdvr03` },
    { label = "Bolt Cutters", illegal = true, prop = `prop_tool_boltcutters` },
    { label = "Fake ID", illegal = true, prop = `prop_franklin_dl` },
    { label = "Stolen Jewelry", illegal = true, prop = `prop_jewel_pickup_new_01` },
    { label = "Stolen Watch", illegal = true, prop = `prop_watch_01` },
    { label = "Dirty Money", illegal = true, prop = `bkr_prop_money_wrapped_01` },
    { label = "Hacking Device", illegal = true, prop = `hei_prop_hst_laptop` },
    { label = "Signal Jammer", illegal = true, prop = `prop_cs_walkie_talkie` },
    { label = "Burner Phone", illegal = true, prop = `prop_phone_ing` },
    { label = "Police Scanner", illegal = true, prop = `prop_police_radio_handset` },
    { label = "Handcuffs", illegal = true, prop = `p_cs_cuffs_02_s` },
    { label = "Zip Ties", illegal = true, prop = `hei_prop_heist_zip_tie_positioned` },
    { label = "Stolen Credit Card", illegal = true, prop = `prop_cs_credit_card` },
    { label = "Forgery Documents", illegal = true, prop = `prop_cs_documents_01` },
    { label = "Safe Cracking Kit", illegal = true, prop = `prop_tool_pickaxe` },
    { label = "Mask", illegal = true, prop = `prop_mask_test_01` },
    { label = "Black Market USB", illegal = true, prop = `prop_cs_usb_drive` },
    { label = "Explosives", illegal = true, prop = `prop_bomb_01` },
    { label = "Detonator", illegal = true, prop = `prop_ld_bomb` },
    { label = "Molotov", illegal = true, prop = `w_ex_molotov` },
    { label = "Stolen Painting", illegal = true, prop = `ch_prop_vault_painting_01e` },
    { label = "Jewelry Bag", illegal = true, prop = `prop_money_bag_01` },
    { label = "Human Organ Cooler", illegal = true, prop = `prop_coolbox_01` }
}
