-- Setup an initial state object and provide functions for manipulating that state.
primaryFARPS = {"SW Warehouse", "NW Warehouse", "SE Warehouse", "NE Warehouse", "MK Warehouse"}
primaryAirfields = {"Maykop-Khanskaya"}
game_state = {
    ["last_launched_time"] = 0,
    ["CurrentTheater"] = "Russian Theater",
    ["Theaters"] = {
        ["Russian Theater"] ={
            ["last_cap_spawn"] = 0,
            ["Airfields"] = {
                ["Novorossiysk"] = Airbase.getByName("Novorossiysk"):getCoalition(),
                ["Gelendzhik"] = Airbase.getByName("Gelendzhik"):getCoalition(),
                ["Krymsk"] = Airbase.getByName("Krymsk"):getCoalition(),
                ["Krasnodar-Center"] = Airbase.getByName("Krasnodar-Center"):getCoalition(),
                ["Krasnodar-Pashkovsky"] = Airbase.getByName("Krasnodar-Pashkovsky"):getCoalition(),
            },
            ["Primary"] = {
                ["Maykop-Khanskaya"] = false,
            },
            ["StrategicSAM"] = {},
            ["C2"] = {},
            ["EWR"] = {},
            ["CASTargets"] = {},
            ["StrikeTargets"] = {},
            ["TheaterObjectives"] = {},
            ["InterceptTargets"] = {},
            ["DestroyedStatics"] = {},
            ["OpforCAS"] = {},
            ["CAP"] = {},
            ["BAI"] = {},
            ["AWACS"] = {},
            ["Tanker"] = {},
            ["NavalStrike"] = {},
            ["CTLD_ASSETS"] = {},
            ['Convoys'] ={},
            ["FARPS"] = {
                ["SW Warehouse"] = Airbase.getByName("SW Warehouse"):getCoalition(),
                ["NW Warehouse"] = Airbase.getByName("NW Warehouse"):getCoalition(),
                ["SE Warehouse"] = Airbase.getByName("SE Warehouse"):getCoalition(),
                ["NE Warehouse"] = Airbase.getByName("NE Warehouse"):getCoalition(),
                ["MK Warehouse"] = Airbase.getByName("MK Warehouse"):getCoalition(),
            }
        }
    }
}


--Airbases in play.
-- use to be called "AirbaseSpawns"
bases = {
    ["Gelendzhik"]           = {
        [coalition.side.RED]  = {
            def     = Spawner("Red Airfield Defense GlensDick 1"),
            cargo   = Spawner("GelenRussiaTransport"),
            helo    = Spawner("GelenHeloTransport"),
            logi    = nil,
            players = nil,
        },
        [coalition.side.BLUE] = {
            def     = nil,
            cargo   = Spawner("GelenTransport"),
            helo    = Spawner("GelenTransportHelo"),
            logi    = nil,
            players = nil,
        },
    },
    ["Krasnodar-Pashkovsky"] = {
        [coalition.side.RED]  = {
            def     = Spawner("Red Airfield Defense Kras-Pash 1"),
            cargo   = Spawner("KrasPashRussiaTransport"),
            helo    = Spawner("KrasPashHeloTransport"),
            logi    = nil,
            players = nil,
        },
        [coalition.side.BLUE] = {
            def     = nil,
            cargo   = Spawner("KDAR2Transport"),
            helo    = Spawner("KrasPashTransportHelo"),
            logi    = nil,
            players = {
            -- note I am not sure we need these lists of slots, these
            -- lists seem like they can be generated from the mission
            -- reading mist.DBs.humansByName or mist.DBs.humansById
            -- gives all player spawns in a mission. The problem will
            -- be figuring out if a slot spawns on a base vs. in the
            -- air. For now keep these specifically listed slot names
            -- as mist makes it very difficult to get the information
            -- easily, mist.DBs.humansByName does not copy the airbaseId.
            -- The problem with staticlly defined lists is slots can be
            -- missed (bugs) and so eventually getting to an algorithimic
            -- approach is better for the misstion designer and game.
                "Krasnador2 Huey 1",
                "Kras2 Mi-8 1",
                "Krasnador2 Huey 2",
                "Kras2 Mi-8 2",
            },
        },
    },
    ["Krasnodar-Center"]     = {
        [coalition.side.RED]  = {
            def     = Spawner("Red Airfield Defense Kras-Center 1"),
            cargo   = Spawner("KrasCenterRussiaTransport"),
            helo    = Spawner("KrasCenterHeloTransport"),
            logi    = nil,
            players = nil,
        },
        [coalition.side.BLUE] = {
            def     = nil,
            cargo   = Spawner("KDARTransport"),
            helo    = Spawner("KrasCenterTransportHelo"),
            logi    = KrasCenterLogiSpawn,
            players = {
                "Krasnador Huey 1",
                "Kras Mi-8 1",
                "Krasnador Huey 2",
                "Kras Mi-8 2",
            },
        },
    },
    ["Novorossiysk"]         = {
        [coalition.side.RED]  = {
            def     = Spawner("Red Airfield Defense Novo 1"),
            cargo   = Spawner("NovoroRussiaTransport"),
            helo    = Spawner("NovoroHeloTransport"),
            logi        = nil,
            players     = nil,
        },
        [coalition.side.BLUE] = {
            def     = nil,
            cargo   = Spawner("NovoroTransport"),
            helo    = Spawner("NovoroTransportHelo"),
            logi    = NovoLogiSpawn,
            players = {
                "Novoro Huey 1",
                "Novoro Huey 2",
                "Novoro Mi-8 1",
                "Novoro Mi-8 2",
            },
        },
    },
    ["Krymsk"]               = {
        [coalition.side.RED]  = {
            def     = Spawner("Red Airfield Defense Krymsk 1"),
            cargo   = Spawner("KrymskRussiaTransport"),
            helo    = Spawner("KrymskHeloTransport"),
            logi    = nil,
            players = nil,
        },
        [coalition.side.BLUE] = {
            def     = nil,
            cargo   = Spawner("KrymskTransport"),
            helo    = Spawner("KrymskTransportHelo"),
            logi    = KryLogiSpawn,
            players = {
                "Krymsk Gazelle M",
                "Krymsk Gazelle L",
                "Krymsk Huey 1",
                "Krymsk Huey 2",
                "Krymsk Mi-8 1",
                "Krymsk Mi-8 2",
            },
        },
    },
    ['SW Warehouse']         = {
        [coalition.side.RED]  = {
            def     = Spawner("FARP DEFENSE #001"),
            cargo   = nil,
            helo    = nil,
            logi    = nil,
            players = nil,
        },
        [coalition.side.BLUE] = {
            def     = nil,
            cargo   = nil,
            helo    = Spawner("SW FARP HELO"),
            logi    = Spawner("FARP Support West"),
            players = {
                "SWFARP Huey 1",
                "SWFARP Huey 2",
                "SWFARP Mi-8 1",
                "SWFARP Mi-8 2",
            },
        },
    },
    ['NW Warehouse']         = {
        [coalition.side.RED]  = {
            def     = Spawner("FARP DEFENSE"),
            cargo   = nil,
            helo    = nil,
            logi    = nil,
            players = nil,
        },
        [coalition.side.BLUE] = {
            def     = nil,
            cargo   = nil,
            helo    = Spawner("NW FARP HELO"),
            logi    = Spawner("FARP Support West"),
            players = {
                "NWFARP Huey 1",
                "NWFARP Huey 2",
                "NWFARP Mi-8 1",
                "NWFARP Mi-8 2",
                "NWFARP KA50",
            },
        },
    },
    ['SE Warehouse']         = {
        [coalition.side.RED]  = {
            def     = Spawner("FARP DEFENSE #002"),
            cargo   = nil,
            helo    = nil,
            logi    = nil,
            players = nil,

        },
        [coalition.side.BLUE] = {
            def     = nil,
            cargo   = nil,
            helo    = Spawner("SE FARP HELO"),
            logi    = SEFARPLogiSpawn,
            players = {
                "SEFARP Gazelle M",
                "SEFARP Gazelle L",
                "SEFARP Huey 1",
                "SEFARP Huey 2",
                "SEFARP Mi-8 1",
                "SEFARP Mi-8 2",
                "SEFARP KA50",
            },
        },
    },
    ['NE Warehouse']         = {
        [coalition.side.RED]  = {
            def     = Spawner("FARP DEFENSE #003"),
            cargo   = nil,
            helo    = nil,
            logi    = nil,
            players = nil,

        },
        [coalition.side.BLUE] = {
            def     = nil,
            cargo   = nil,
            helo    = Spawner("NE FARP HELO"),
            logi    = Spawner("FARP Support West"),
            players = {
                "NEFARP Huey 1",
                "NEFARP Huey 2",
                "NEFARP Mi-8 1",
                "NEFARP Mi-8 2",
            },
        },
    },
    ['MK Warehouse']         = {
        [coalition.side.RED]  = {
            def     = Spawner("FARP DEFENSE #004"),
            cargo   = nil,
            helo    = nil,
            logi    = nil,
            players = nil,

        },
        [coalition.side.BLUE] = {
            def     = nil,
            cargo   = nil,
            helo    = Spawner("MK FARP HELO"),
            logi    = MaykopLogiSpawn,
            players = {
                "MKFARP Huey 1",
                "MKFARP Huey 2",
                "MKFARP Mi-8 1",
                "MKFARP Mi-8 2",
                "MK FARP Ka-50"
            },
        },
    },
    --[[
    ['Anapa Area FARP East'] = {
FSW = Spawner("FARP Support West #001")
    },
    ['Anapa Area FARP West'] = {
FSW = Spawner("FARP Support West #002")
    },
    --]]
}

assets = {
}

-- Forward Logistics spawns - I don't understand what these are for
NovoLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -39857.5703125,
        ['y'] = 279000.5
    },
    "novologizone"
}

KryLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -5951.622558,
        ['y'] = 293862.25
    },
    "krymsklogizone"
}

KrasCenterLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = 11981.98046875,
        ['y'] = 364532.65625
    },
    "krascenterlogizone"
}

KrasPashLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = 8229.2353515625,
        ['y'] = 386831.65625
    },
    "kraspashlogizone"
}

MaykopLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -26322.15625,
        ['y'] = 421495.96875
    },
    "mklogizone"
}

SEFARPLogiSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -26322.15625,
        ['y'] = 421495.96875
    },
    "sefarplogizone"
}

-- Airfield CAS Spawns
RussianTheaterCASSpawn = Spawner("Su25T-CASGroup")

-- Group spanws for easy randomization
local allcaps = {
    RussianTheaterMig212ShipSpawn, RussianTheaterSu272sShipSpawn, RussianTheaterMig292ShipSpawn, RussianTheaterJ11Spawn, RussianTheaterF5Spawn,
    RussianTheaterMig212ShipSpawnGROUND, RussianTheaterSu272sShipSpawnGROUND, RussianTheaterMig292ShipSpawnGROUND, RussianTheaterJ11SpawnGROUND, RussianTheaterF5SpawnGROUND
}
poopcaps = {RussianTheaterMig212ShipSpawn, RussianTheaterF5Spawn}
goodcaps = {RussianTheaterMig292ShipSpawn, RussianTheaterSu272sShipSpawn, RussianTheaterJ11Spawn}
poopcapsground = {RussianTheaterMig212ShipSpawnGROUND, RussianTheaterF5SpawnGROUND}
goodcapsground = {RussianTheaterMig292ShipSpawnGROUND, RussianTheaterSu272sShipSpawnGROUND, RussianTheaterJ11SpawnGROUND}
baispawns = {RussianHeavyArtySpawn, ArmorColumnSpawn, MechInfSpawn}
