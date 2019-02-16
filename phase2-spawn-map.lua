-- Setup an initial state object and provide functions for manipulating that state.
game_state = {
    ["last_launched_time"] = 0,
    ["CurrentTheater"] = "North Georgia",
    ["Theaters"] = {
        ["Russian Theater"] ={
            ["last_cap_spawn"] = 0,
            ["Airfields"] = {
                ["Sochi-Adler"] = Airbase.getByName("Sochi-Adler"):getCoalition(),
                ["Gudauta"] = Airbase.getByName("Gudauta"):getCoalition(),
                ["Mineralnye Vody"] = Airbase.getByName("Mineralnye Vody"):getCoalition(),
                ["Nalchik"] = Airbase.getByName("Nalchik"):getCoalition(),
                ["Mozdok"] = Airbase.getByName("Mozdok"):getCoalition(),
                ["Sukhumi-Babushara"] = Airbase.getByName("Sukhumi-Babushara"):getCoalition(),
            },
            ["Primary"] = {
                ["Beslan"] = false,
                ["Sukhumi-Babushara"] = false
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
                ["FARP ALPHA"] = Airbase.getByName("FARP ALPHA"):getCoalition(),
                ["FARP BRAVO"] = Airbase.getByName("FARP BRAVO"):getCoalition(),
                ["FARP CHARLIE"] = Airbase.getByName("FARP CHARLIE"):getCoalition(),
                ["FARP DELTA"] = Airbase.getByName("FARP DELTA"):getCoalition(),
            }
        }
    }
}

game_stats = {
    c2    = {
        alive = 0,
        nominal = 3,
        tbl   = game_state["Theaters"]["Russian Theater"]["C2"],
    },
    ewr = {
        alive = 0,
        nominal = 3,
        tbl   = game_state["Theaters"]["Russian Theater"]["EWR"],
    },
    awacs = {
        alive = 0,
        nominal = 1,
        tbl   = game_state["Theaters"]["Russian Theater"]["AWACS"],
    },
    bai = {
        alive = 0,
        nominal = 5,
        tbl = game_state["Theaters"]["Russian Theater"]["BAI"],
    },
    ammo = {
        alive = 0,
        nominal = 3,
        tbl   = game_state["Theaters"]["Russian Theater"]["StrikeTargets"],
        subtype = "AmmoDump",
    },
    comms = {
        alive = 0,
        nominal = 2,
        tbl   = game_state["Theaters"]["Russian Theater"]["StrikeTargets"],
        subtype = "CommsArray",
    },
    caps = {
        alive = 0,
        nominal = 7,
        tbl = game_state["Theaters"]["Russian Theater"]["CAP"],
    },
    airports = {
        alive = 0,
        nominal = 3,
        tbl = game_state["Theaters"]["Russian Theater"]["Airfields"],
    },
}

log("Game State INIT")


abslots = {
    ['Sochi-Adler'] = {"Sochi Mi8 1", "Sochi Mi8 2", "Sochi UH-1H 1", "Sochi UH-1H 2", "Sochi Ka50", "Sochi SA342M", "Sochi SA342Mistral"},
    ['Gudauta'] = {"Gudauta Ka50", "Gudauta Mi8 1", "Gudauta Mi8 2", "Gudauta Mi8 3", "Gudauta Mi8 4", "Gudauta UH-1H 1", "Gudauta UH-1H 2", "Gudauta SA342M", "Gudauta SA342Mistral"},
    ['Sukhumi-Babushara'] = {},
    ['Mineralnye Vody'] = {"Vody UH-1H 1", "Vody UH-1H 2", "Vody UH-1H 3", "Vody UH-1H 4", 
    "Vody Mi8 1", "Vody Mi8 2", "Vody Mi8 3", "Vody Mi8 4", "Vody Ka50"},
    ['Nalchik'] = {},
    ['Mozdok'] = {},
    ['FARP ALPHA'] = {"FARP Alpha UH-1H 1", "FARP Alpha UH-1H 2", "FARP Alpha Mi8 1", "FARP Alpha Mi8 2"},
    ['FARP BRAVO'] = {"FARP Bravo Mi8 1", "FARP Bravo Mi8 2", "FARP Bravo UH-1H 1", "FARP Bravo UH-1H 2", "FARP Bravo SA342M", "FARP Bravo SA342Mistral", "FARP Bravo Ka50"},
    ['FARP CHARLIE'] = {"FARP Charlie Mi8 1", "FARP Charlie Mi8 2", "FARP Charlie UH-1H 1", "FARP Charlie UH-1H 2", "FARP Charlie Ka50", "FARP Charlie SA342M", "FARP Charlie SA342Mistral"},
    ['FARP DELTA'] = {"FARP Delta UH-1H 1", "FARP Delta UH-1H 2","FARP Delta UH-1H 3", "FARP Delta UH-1H 4", "FARP Delta UH-1H 5", "FARP Delta UH-1H 6",
     "FARP Delta Mi8 1", "FARP Delta Mi8 2", "FARP Delta Mi8 3", "FARP Delta Mi8 4",
     "FARP Delta Harrier","FARP Delta Ka50", "FARP Delta Ka50", "FARP Charlie SA342M", "FARP Charlie SA342Mistral"}
}

logiSlots = {
    ['Sochi-Adler'] = LogiAdlerSpawn,
    ['Gudauta'] = LogiGudautaSpawn,
    ['Mineralnye Vody'] = LogiVodySpawn,
    ['FARP ALPHA'] = LogiFARPALPHASpawn,
    ['FARP BRAVO'] = LogiFARPBRAVOSpawn,
    ['FARP CHARLIE'] = LogiFARPCHARLIESpawn,
    ['FARP DELTA'] = LogiFARPDELTASpawn
}

--Airbases in play.
Airbases = {
    "Sochi-Adler",
    "Gudauta",
    "Mineralnye Vody",
    "Nalchik",
    "Mozdok",
    "Sukhumi-Babushara"
}

-- Russian IL-76MD spawns to capture airfields
MozdokTransportSpawn = Spawner("MozdokTransport")
MozdokHeloSpawn = Spawner("MozdokHeloTransport")
MozdokDefSpawn = Spawner("MozdokDefense")

NalchikTransportSpawn = Spawner("NalchikTransport")
NalchikHeloSpawn = Spawner("NalchikHeloTransport")
NalchikDefSpawn = Spawner("NalchikDefense")

VodyTransportSpawn = Spawner("VodyTransport")
VodyHeloSpawn = Spawner("VodyHeloTransport")
VodyDefSpawn = Spawner("VodyDefense")

SochiTransportSpawn = Spawner("SochiTransport")
SochiHeloSpawn = Spawner("SochiHeloTransport")
SochiDefSpawn = Spawner("SochiDefense")

GudautaTransportSpawn = Spawner("GudautaTransport")
GudautaHeloSpawn = Spawner("GudautaHeloTransport")
GudautaDefSpawn = Spawner("GudautaDefense")

SukhumiTransportSpawn = Spawner("SukhumiTransport")
SukhumiHeloSpawn = Spawner("SukhumiHeloTransport")
SukhumiDefSpawn = Spawner("SukhumiDefense")

RussianTheaterAirfieldDefSpawn = Spawner("Russia-Airfield-Def")

--Airbase -> Spawn Map.
AirbaseSpawns = {
    ["Mozdok"]={MozdokTransportSpawn, MozdokHeloSpawn, MozdokDefSpawn},
    ["Nalchik"]={NalchikTransportSpawn, NalchikHeloSpawn, NalchikDefSpawn},
    ["Mineralnye Vody"]={VodyTransportSpawn, VodyHeloSpawn, VodyDefSpawn},
    ["Gudauta"]={GudautaTransportSpawn, GudautaHeloSpawn, GudautaDefSpawn},
    ["Sochi-Adler"]={SochiTransportSpawn, SochiHeloSpawn, SochiDefSpawn},
    ["Sukhumi-Babushara"]={SukhumiTransportSpawn, SukhumiHeloSpawn, SukhumiDefSpawn}
}

-- Forward Logistics spawns
LogiFARPALPHASpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -90692,
        ['y'] = 551377
    },
    "LogiFARPAlpha"
}

LogiFARPBRAVOSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -83517,
        ['y'] = 617694
    },
    "LogiFARPBravo"
}

LogiFARPCHARLIESpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -126126,
        ['y'] = 420423
    },
    "LogiFARPCharlie"
}

LogiFARPDELTASpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -98874,
        ['y'] = 808161
    },
    "LogiFARPDelta"
}

LogiVodySpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -77884,
        ['y'] = 761336
    },
    "LogiVody"
}

LogiAdlerSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -166113,
        ['y'] = 462824
    },
    "LogiSochi"
}

LogiGudautaSpawn = {logispawn, "HEMTT TFFT",
    {
        ['x'] = -195671,
        ['y'] = 517492
    },
    "LogiGudauta"
}

-- Transport Spawns
NorthGeorgiaTransportSpawns = {
    ['Sochi-Adler'] = {Spawner("SochiXport"), Spawner("SochiXportHelo"), LogiAdlerSpawn},
    ['Gudauta'] = {Spawner("GudautaXport"), Spawner("GudautaXportHelo"), LogiGudautaSpawn},
    ['Sukhumi-Babushara'] = {Spawner("SukXport"), Spawner("SukXportHelo"), nil},
    ['Mineralnye Vody'] = {Spawner("VodyXport"), Spawner("VodyXportHelo"), LogiVodySpawn},
    ['Nalchik'] = {Spawner("NalchikXport"), Spawner("NalchikXportHelo"), nil},
    ['Mozdok'] = {Spawner("MozdokXport"), Spawner("MozdokXportHelo"), nil},
    ['Beslan'] = {Spawner("BeslanXport"), Spawner("BeslanXportHelo"), nil}
}

NorthGeorgiaFARPTransportSpawns = {
    ["FARP ALPHA"] = {Spawner("FARPAlphaXportHelo"), nil, LogiFARPALPHASpawn},
    ["FARP BRAVO"] = {Spawner("FARPBravoXportHelo"), nil, LogiFARPBRAVOSpawn},
    ["FARP CHARLIE"] = {Spawner("FARPCharlieXportHelo"),nil, LogiFARPCHARLIESpawn},
    ["FARP DELTA"] = {Spawner("FARPDeltaXportHelo"),nil, LogiFARPDELTASpawn},
}

VIPSpawns = { "VIPTransport" }

VIPSpawnZones = {
  {"VIPSpawn-Tuapse", "Tuapse"},
  {"VIPSpawn-Sochi", "Sochi"},
  {"VIPSpawn-Gudauta", "Gudauta"},
  {"VIPSpawn-Vody", "Vody"}
}
VIPDropoffZones = {
  "VIPDropOff-Maykop",
  "VIPDropOff-MaykopSouth",
  "VIPDropOff-MaykopNorth",
  "VIPDropOff-FARPAlpha",
  "VIPDropOff-FARPBravo",
  "VIPDropOff-FARPCharlie",
  "VIPDropOff-FARPDelta",
  "VIPDropOff-Gudauta",
  "VIPDropOff-Sochi",
  "VIPDropOff-Vody"
}

--Theater Objectives. Must be spawned once, and only where in the ME has them.
TuapseRefinery = TheaterObjectiveSpawner("Tuapse Refinery", "TuapseRefineryDef")
ChemSite = TheaterObjectiveSpawner("Chemical Factory", "CHEM SITE VEHICLES")
AmmoDump = TheaterObjectiveSpawner("Chemical Factory", "AMMO DUMP GROUND FORCES")

TheaterObjectives = {}
TheaterObjectives["Tuapse Refinery"] = TuapseRefinery
TheaterObjectives["Chemical Factory"] = ChemSite
TheaterObjectives["Ammunitions Depot"] = AmmoDump

-- FARP defenses
FARPALPHADEF = Spawner("FARP ALPHA DEF_1")
FARPBRAVODEF = Spawner("FARP BRAVO DEF_1")
FARPCHARLIEDEF = Spawner("FARP CHARLIE DEF_1")
FARPDELTADEF = Spawner("Russia-Airfield-Def")

-- FARP Support Groups
FSW = Spawner("FARP Support West")

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

StrikeTargetSpawns = {
  AmmoDumpSpawn,
  CommsArraySpawn,
  PowerPlantSpawn
}

-- Airfield CAS Spawns
RussianTheaterCASSpawn = Spawner("Su25T-CASGroup")
RussianTheaterSOUTHCASSpawn = Spawner("Su25T-CASGroupSOUTH")


abslots = {
    ['Sochi-Adler'] = {"Sochi Mi8 1", "Sochi Mi8 2", "Sochi UH-1H 1", "Sochi UH-1H 2", "Sochi Ka50", "Sochi SA342M", "Sochi SA342Mistral"},
    ['Gudauta'] = {"Gudauta Ka50", "Gudauta Mi8 1", "Gudauta Mi8 2", "Gudauta Mi8 3", "Gudauta Mi8 4", "Gudauta UH-1H 1", "Gudauta UH-1H 2", "Gudauta SA342M", "Gudauta SA342Mistral"},
    ['Sukhumi-Babushara'] = {},
    ['Mineralnye Vody'] = {"Vody UH-1H 1", "Vody UH-1H 2", "Vody UH-1H 3", "Vody UH-1H 4", 
    "Vody Mi8 1", "Vody Mi8 2", "Vody Mi8 3", "Vody Mi8 4", "Vody Ka50"},
    ['Nalchik'] = {},
    ['Mozdok'] = {},
    ['FARP ALPHA'] = {"FARP Alpha UH-1H 1", "FARP Alpha UH-1H 2", "FARP Alpha Mi8 1", "FARP Alpha Mi8 2"},
    ['FARP BRAVO'] = {"FARP Bravo Mi8 1", "FARP Bravo Mi8 2", "FARP Bravo UH-1H 1", "FARP Bravo UH-1H 2", "FARP Bravo SA342M", "FARP Bravo SA342Mistral", "FARP Bravo Ka50"},
    ['FARP CHARLIE'] = {"FARP Charlie Mi8 1", "FARP Charlie Mi8 2", "FARP Charlie UH-1H 1", "FARP Charlie UH-1H 2", "FARP Charlie Ka50", "FARP Charlie SA342M", "FARP Charlie SA342Mistral"},
    ['FARP DELTA'] = {"FARP Delta UH-1H 1", "FARP Delta UH-1H 2","FARP Delta UH-1H 3", "FARP Delta UH-1H 4", "FARP Delta UH-1H 5", "FARP Delta UH-1H 6",
     "FARP Delta Mi8 1", "FARP Delta Mi8 2", "FARP Delta Mi8 3", "FARP Delta Mi8 4",
     "FARP Delta Harrier","FARP Delta Ka50", "FARP Delta Ka50", "FARP Charlie SA342M", "FARP Charlie SA342Mistral"}
}

logiSlots = {
    ['Sochi-Adler'] = LogiAdlerSpawn,
    ['Gudauta'] = LogiGudautaSpawn,
    ['Mineralnye Vody'] = LogiVodySpawn,
    ['FARP ALPHA'] = LogiFARPALPHASpawn,
    ['FARP BRAVO'] = LogiFARPBRAVOSpawn,
    ['FARP CHARLIE'] = LogiFARPCHARLIESpawn,
    ['FARP DELTA'] = LogiFARPDELTASpawn
}
