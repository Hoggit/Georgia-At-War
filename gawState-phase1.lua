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

log("Game State INIT")


abslots = {
    ['Novorossiysk'] = {"Novoro Huey 1", "Novoro Huey 2", "Novoro Mi-8 1", "Novoro Mi-8 2"},
    ['Gelendzhik'] = {},
    ['Krymsk'] = {"Krymsk Gazelle M", "Krymsk Gazelle L", "Krymsk Huey 1", "Krymsk Huey 2", "Krymsk Mi-8 1", "Krymsk Mi-8 2"},
    ['Krasnodar-Center'] = {"Krasnador Huey 1", "Kras Mi-8 1", "Krasnador Huey 2", "Kras Mi-8 2"},
    ['Krasnodar-Pashkovsky'] = {"Krasnador2 Huey 1", "Kras2 Mi-8 1", "Krasnador2 Huey 2", "Kras2 Mi-8 2"},
    ['SW Warehouse'] = {"SWFARP Huey 1", "SWFARP Huey 2", "SWFARP Mi-8 1", "SWFARP Mi-8 2"},
    ['NW Warehouse'] = {"NWFARP Huey 1", "NWFARP Huey 2", "NWFARP Mi-8 1", "NWFARP Mi-8 2", "NWFARP KA50"},
    ['SE Warehouse'] = {"SEFARP Gazelle M", "SEFARP Gazelle L", "SEFARP Huey 1", "SEFARP Huey 2", "SEFARP Mi-8 1", "SEFARP Mi-8 2", "SEFARP KA50"},
    ['NE Warehouse'] = {"NEFARP Huey 1", "NEFARP Huey 2", "NEFARP Mi-8 1", "NEFARP Mi-8 2"},
    ['MK Warehouse'] = {"MKFARP Huey 1", "MKFARP Huey 2", "MKFARP Mi-8 1", "MKFARP Mi-8 2", "MK FARP Ka-50"},
}

logiSlots = {
    ['Novorossiysk'] = NovoLogiSpawn,
    ['Gelendzhik'] = nil,
    ['Krymsk'] = KryLogiSpawn,
    ['Krasnodar-Center'] = KrasCenterLogiSpawn,
    ['Krasnodar-Pashkovsky'] = KrasPashLogiSpawn,
    ['MK Warehouse'] = MaykopLogiSpawn
}
