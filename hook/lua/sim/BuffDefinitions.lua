--****************************************************************************
--**
--**  File     :  /lua/sim/buffdefinition.lua
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
--
--Mod code originally written by Eni
--Modified by Eni, Ghaleon(?), Lewnatics(?), Stormrideron and SATA24

import('/lua/sim/AdjacencyBuffs.lua')
import('/lua/sim/CheatBuffs.lua') -- Buffs for AI Cheating

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - UNIT Energy Storage --SATA24
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyStorageEnergy',
    DisplayName = 'VeterancyStorageEnergy',
    BuffType = 'VETERANCYSTORAGEENERGY',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        StorageEnergy = {
            Add = 0,
            Mult = 1.0036,
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - UNIT Mass Storage --SATA24
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyStorageMass',
    DisplayName = 'VeterancyStorageMass',
    BuffType = 'VETERANCYSTORAGEMASS',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        StorageMass = {
            Add = 0,
            Mult = 1.0036,
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - UNIT HEALTH
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyHealth',
    DisplayName = 'VeterancyHealth',
    BuffType = 'VETERANCYHEALTH',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.005,--was 1.12
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - COMMANDER HEALTH
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyACUHealth',
    DisplayName = 'VeterancyACUHealth',
    BuffType = 'VeterancyACUHealth',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.0025,--was 1.12
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - UNIT REGEN
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyRegen',
    DisplayName = 'VeterancyRegen',
    BuffType = 'VETERANCYREGEN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Regen = {
            Add = 0,
            Mult = 1.0045,--was 1.08
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - NUKE MISSILE DAMAGE and RADIUS
------------------------------------------------------------------------------------------------------------------------------------

--BuffBlueprint {
--    Name = 'VeterancyNuclearDR',
--    DisplayName = 'VeterancyNuclearDR',
--    BuffType = 'VeterancyNuclearDR',
--    Stacks = 'ALWAYS',
--    Duration = -1,
--    Affects = {
--        InnerNukeDamage = {
--            Add = 0,
--            Mult = 1.25,--was 1.1
--        },
--		OuterNukeDamage = {
--           Add = 0,
--           Mult = 1.10,--was 1.1
--        },
--    },
--}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - UNIT DAMAGE
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyDamage',
    DisplayName = 'VeterancyDamage',
    BuffType = 'VETERANCYDAMAGE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Damage = {
            Add = 0,
            Mult = 1.0085,--was 1.1
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - COMMANDER OVERCHARGE
------------------------------------------------------------------------------------------------------------------------------------

--BuffBlueprint {
   -- Name = 'VeterancyOverCharge',
    --DisplayName = 'VeterancyOverCharge',
   -- BuffType = 'VeterancyOverCharge',
   -- Stacks = 'ALWAYS',
    --Duration = -1,
  --  Affects = {
     --   Damage = {
    --        Add = 0,
     --       Mult = 1.0125,--was 1.1
	--		ByName = {
	--			OverCharge = true,
		--	},
     --   },
 --   },
-- }

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - UNIT DAMAGE AOE
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    MaxLevel = 100, 
    Name = 'VeterancyDamageArea',
    DisplayName = 'VeterancyDamageArea',
    BuffType = 'VETERANCYDAMAGEAREA',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        DamageRadius = {
            Add = 0,
            Mult = 1.0025,--was 1.015
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - UNIT Weapon Range
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyRange',
    DisplayName = 'VeterancyRange',
    BuffType = 'VETERANCYRANGE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxRadius = {
            Add = 0,
            Mult = 1.00075,--was 1.01
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - COMMANDER Weapon Range
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyCOMRange',
    DisplayName = 'VeterancyCOMRange',
    BuffType = 'VeterancyCOMRange',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxRadius = {
            Add = 0,
            Mult = 1.00025,--was 1.01
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - UNIT SPEED
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    MaxLevel = 100, --was 20
    Name = 'VeterancySpeed',
    DisplayName = 'VeterancySpeed',
    BuffType = 'VETERANCYSPEED',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MoveMult = {
            Add = 0,
            Mult = 1.0025, --was 1.01
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - UNIT FUEL
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyFuel',
    DisplayName = 'VeterancyFuel',
    BuffType = 'VETERANCYFUEL',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Fuel = {
            Add = 0,
            Mult = 1.00125, -- was 1.05
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - UNIT SHIELD
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyShield',
    DisplayName = 'VeterancyShield',
    BuffType = 'VETERANCYSHIELD',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        ShieldHP = {
            Add = 0,
            Mult = 1.005, -- was 1.05
        },
        ShieldRegen = {
            Add = 0,
            Mult = 1.0025, -- was 1.05
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - COMMANDER SHIELD
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyCOMShield',
    DisplayName = 'VeterancyCOMShield',
    BuffType = 'VeterancyCOMShield',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        ShieldHP = {
            Add = 0,
            Mult = 1.005, -- was 1.05
        },
        ShieldRegen = {
            Add = 0,
            Mult = 1.0025, -- was 1.05
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - VISION
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    MaxLevel = 100, -- was 200
    Name = 'VeterancyVision',
    DisplayName = 'VeterancyVision',
    BuffType = 'VETERANCYVISION',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        VisionRadius = {
            Add = 0,
            Mult = 1.00625, -- was 1.025
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - OMNIVISION
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    MaxLevel = 100,
    Name = 'VeterancyOmniRadius',
    DisplayName = 'VeterancyOmniRadius',
    BuffType = 'VETERANCYOMNIRADIUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        OmniRadius = {
            Add = 0,
            Mult = 1.0025, -- was 1.025
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - RADAR RANGE
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    MaxLevel = 100, -- was 60
    Name = 'VeterancyRadar',
    DisplayName = 'VeterancyRadar',
    BuffType = 'VETERANCYRADAR',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        RadarRadius = {
            Add = 0,
            Mult = 1.0025, -- was 1.025
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - BUILD SPEED
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyBuildRate',
    DisplayName = 'VeterancyBuildRate',
    BuffType = 'VETERANCYBUILDRATE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add = 0,
            Mult = 1.00125, -- was 1.015
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - ENERGY CONSUMPTION
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyEnergyCon',
    DisplayName = 'VeterancyEnergyCon',
    BuffType = 'VeterancyEnergyCon',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        EnergyMaintenance = {
            Add = 0.0025,
            Mult = 1.00125,
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - COMMANDER ENERGY CONSUMPTION
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyCEC',
    DisplayName = 'VeterancyCEC',
    BuffType = 'VeterancyCEC',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        EnergyMaintenance = {
            Add = 0.001,
            Mult = 1.001,
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - ENERGY AND MASS PRODUCTION
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyResourceProduction',
    DisplayName = 'VeterancyResourceProduction',
    BuffType = 'VeterancyResourceProduction',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        EnergyProductionBuf = {
            Add = 0,
            Mult = 1.0055,
        },
        MassProductionBuf = {
            Add = 0,
            Mult = 1.00275,
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - ACU ENERGY AND MASS PRODUCTION
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    MaxLevel = 1000,
	Name = 'VeterancyACUResourceProduction',
	DisplayName = 'VeterancyACUResourceProduction',
	BuffType = 'VeterancyACUResourceProduction',
	Stacks = 'ALWAYS',
	Duration = -1,
	Affects = {
	EnergyProductionBuf = {
	        Add = 1.39375,
			Mult = 1.0066,
        },
	    MassProductionBuf = {
            Add = 0.021875,
			Mult = 1.0045,
        },
	},
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - COMMANDER RATE OF FIRE
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyACURateOfFire',
    DisplayName = 'VeterancyACURateOfFire',
    BuffType = 'VeterancyACURateOfFire',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        RateOfFireBuf = {
            Add = 0,
            Mult = 1.0005,
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY BUFFS - RATE OF FIRE
------------------------------------------------------------------------------------------------------------------------------------

BuffBlueprint {
    Name = 'VeterancyRateOfFire',
    DisplayName = 'VeterancyRateOfFire',
    BuffType = 'VETERANCYRATEOFFIRE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        RateOfFireBuf = {
            Add = 0,
            Mult = 1.002,
        },
    },
}

------------------------------------------------------------------------------------------------------------------------------------
---- VETERANCY PERKS
------------------------------------------------------------------------------------------------------------------------------------

-- Perk Hardened
BuffBlueprint {
    Name = 'VeterancyPerkHardened',
    DisplayName = 'VeterancyPerkHardened',
    BuffType = 'VeterancyPerkHardened',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.3,
        },
	RateOfFireBuf = {
            Add = 0,
            Mult = 1.3,
        },
        Damage = {
            Add = 0,
            Mult = 1.3,
        },
	MoveMult = {
            Add = 0,
            Mult = 1.3, --was 1.01
        },
        Regen = {
            Add = 0,
            Mult = 1.3,--was 1.08
        },
    },
}

-- Perk Veteran
BuffBlueprint {
    Name = 'VeterancyPerkVeteran',
    DisplayName = 'VeterancyPerkVeteran',
    BuffType = 'VeterancyPerkVeteran',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.45,
        },
	RateOfFireBuf = {
            Add = 0,
            Mult = 1.45,
        },
        Damage = {
            Add = 0,
            Mult = 1.45,
        },
	MoveMult = {
            Add = 0,
            Mult = 1.45, --was 1.01
        },
        Regen = {
            Add = 0,
            Mult = 1.45,--was 1.08
        },
    },
}

-- Perk Elite
BuffBlueprint {
    Name = 'VeterancyPerkElite',
    DisplayName = 'VeterancyPerkElite',
    BuffType = 'VeterancyPerkElite',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.6,
        },
	RateOfFireBuf = {
            Add = 0,
            Mult = 1.6,
        },
        Damage = {
            Add = 0,
            Mult = 1.6,
        },
	MoveMult = {
            Add = 0,
            Mult = 1.6, --was 1.01
        },
        Regen = {
            Add = 0,
            Mult = 1.6,--was 1.08
        },
    },
}

-- Perk Rambo
BuffBlueprint {
    Name = 'VeterancyPerkRambo1',
    DisplayName = 'VeterancyPerkRambo1',
    BuffType = 'VeterancyPerkRambo1',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.1,
        },
	RateOfFireBuf = {
            Add = 0,
            Mult = 1.1,
        },
        Damage = {
            Add = 0,
            Mult = 1.1,
        },
    },
}

-- Perk Rambo
BuffBlueprint {
    Name = 'VeterancyPerkRambo2',
    DisplayName = 'VeterancyPerkRambo2',
    BuffType = 'VeterancyPerkRambo2',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.125,
        },
	RateOfFireBuf = {
            Add = 0,
            Mult = 1.125,
        },
        Damage = {
            Add = 0,
            Mult = 1.125,
        },
    },
}

-- Perk Rambo
BuffBlueprint {
    Name = 'VeterancyPerkRambo3',
    DisplayName = 'VeterancyPerkRambo3',
    BuffType = 'VeterancyPerkRambo3',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.15,
        },
	RateOfFireBuf = {
            Add = 0,
            Mult = 1.15,
        },
        Damage = {
            Add = 0,
            Mult = 1.15,
        },
    },
}

-- Perk Rambo
BuffBlueprint {
    Name = 'VeterancyPerkRambo4',
    DisplayName = 'VeterancyPerkRambo4',
    BuffType = 'VeterancyPerkRambo4',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.175,
        },
	RateOfFireBuf = {
            Add = 0,
            Mult = 1.175,
        },
        Damage = {
            Add = 0,
            Mult = 1.175,
        },
    },
}

-- Perk Rambo
BuffBlueprint {
    Name = 'VeterancyPerkRambo5',
    DisplayName = 'VeterancyPerkRambo5',
    BuffType = 'VeterancyPerkRambo5',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.2,
        },
	RateOfFireBuf = {
            Add = 0,
            Mult = 1.2,
        },
        Damage = {
            Add = 0,
            Mult = 1.2,
        },
    },
}

-- Perk Rate of Fire
BuffBlueprint {
    Name = 'VeterancyPerkROF',
    DisplayName = 'VeterancyPerkROF',
    BuffType = 'VeterancyPerkROF',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        RateOfFireBuf = {
            Add = 0,
            Mult = 1.10,
        },
    },
}

-- Perk Damage
BuffBlueprint {
    Name = 'VeterancyPerkDamage',
    DisplayName = 'VeterancyPerkDamage',
    BuffType = 'VeterancyPerkDamage',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Damage = {
            Add = 0,
            Mult = 1.10,
			ByName = {
				OverCharge = false,
			},
        },
    },
}

-- Perk Health
BuffBlueprint {
    Name = 'VeterancyPerkHealth',
    DisplayName = 'VeterancyPerkHealth',
    BuffType = 'VeterancyPerkHealth',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.10,
        },
    },
}

-- Perk Health Regeneration
BuffBlueprint {
    Name = 'VeterancyPerkRegen',
    DisplayName = 'VeterancyPerkRegen',
    BuffType = 'VeterancyPerkRegen',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Regen = {
            Add = 0,
            Mult = 1.10,
        },
    },
}

-- Perk Range
BuffBlueprint {
    Name = 'VeterancyPerkRange',
    DisplayName = 'VeterancyPerkRange',
    BuffType = 'VeterancyPerkRange',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxRadius = {
            Add = 0,
            Mult = 1.10,
        },
    },
}

-- Perk Shield Health
BuffBlueprint {
    Name = 'VeterancyPerkSH',
    DisplayName = 'VeterancyPerkSH',
    BuffType = 'VeterancyPerkSH',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        ShieldHP = {
            Add = 1000,
            Mult = 1.10,
        },
    },
}

-- Perk Shield Regen
BuffBlueprint {
    Name = 'VeterancyPerkSR',
    DisplayName = 'VeterancyPerkSR',
    BuffType = 'VeterancyPerkSR',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        ShieldRegen = {
            Add = 0,
            Mult = 1.10,
        },
    },
}

-- Perk Movement Speed
BuffBlueprint {
    Name = 'VeterancyPerkMS',
    DisplayName = 'VeterancyPerkMS',
    BuffType = 'VeterancyPerkMS',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MoveMult = {
            Add = 0,
            Mult = 1.10,
        },
    },
}

-- Perk Mass and Energy Boost
BuffBlueprint {
	Name = 'VeterancyMEBoost1',
	DisplayName = 'VeterancyMEBoost1',
	BuffType = 'VeterancyMEBoost1',
	Stacks = 'ALWAYS',
	Duration = -1,
	Affects = {
	EnergyProductionBuf = {
	        Add = 0,
			Mult = 1.0666,
        },
	    MassProductionBuf = {
            Add = 0,
			Mult = 1.0666,
        },
	},
}

-- Perk Mass and Energy Boost
BuffBlueprint {
	Name = 'VeterancyMEBoost2',
	DisplayName = 'VeterancyMEBoost2',
	BuffType = 'VeterancyMEBoost2',
	Stacks = 'ALWAYS',
	Duration = -1,
	Affects = {
	EnergyProductionBuf = {
	        Add = 0,
			Mult = 1.1,
        },
	    MassProductionBuf = {
            Add = 0,
			Mult = 1.1,
        },
	},
}

-- Perk Mass and Energy Boost
BuffBlueprint {
	Name = 'VeterancyMEBoost3',
	DisplayName = 'VeterancyMEBoost3',
	BuffType = 'VeterancyMEBoost3',
	Stacks = 'ALWAYS',
	Duration = -1,
	Affects = {
	EnergyProductionBuf = {
	        Add = 0,
			Mult = 1.15,
        },
	    MassProductionBuf = {
            Add = 0,
			Mult = 1.15,
        },
	},
}

-- Perk ACU Health
BuffBlueprint {
    Name = 'VeterancyACUHP',
    DisplayName = 'VeterancyACUHP',
    BuffType = 'VeterancyACUHP',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.50,
        },
	Regen = {
            Add = 0,
            Mult = 1.10,
        },
    },
}

-- Perk Supercharged Cannon I
BuffBlueprint {
    Name = 'VeterancyPerkSCC1',
    DisplayName = 'VeterancyPerkSCC1',
    BuffType = 'VeterancyPerkSCC1',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Damage = {
            Add = 0,
            Mult = 1.165,
        },
		DamageRadius = {
            Add = 0,
            Mult = 1.0275,--was 1.015
        },
    },
}

-- Perk Supercharged Cannon II
BuffBlueprint {
    Name = 'VeterancyPerkSCC2',
    DisplayName = 'VeterancyPerkSCC2',
    BuffType = 'VeterancyPerkSCC2',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Damage = {
            Add = 0,
            Mult = 1.198,
        },
		DamageRadius = {
            Add = 0,
            Mult = 1.033,--was 1.015
        },
    },
}

-- Perk Supercharged Cannon III
BuffBlueprint {
    Name = 'VeterancyPerkSCC3',
    DisplayName = 'VeterancyPerkSCC3',
    BuffType = 'VeterancyPerkSCC3',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Damage = {
            Add = 0,
            Mult = 1.231,
        },
		DamageRadius = {
            Add = 0,
            Mult = 1.0385,--was 1.015
        },
    },
}

-- Perk Supercharged Cannon IV
BuffBlueprint {
    Name = 'VeterancyPerkSCC4',
    DisplayName = 'VeterancyPerkSCC4',
    BuffType = 'VeterancyPerkSCC4',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Damage = {
            Add = 0,
            Mult = 1.264,
        },
		DamageRadius = {
            Add = 0,
            Mult = 1.044,--was 1.015
        },
    },
}

-- Perk Supercharged Cannon V
BuffBlueprint {
    Name = 'VeterancyPerkSCC5',
    DisplayName = 'VeterancyPerkSCC5',
    BuffType = 'VeterancyPerkSCC5',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Damage = {
            Add = 0,
            Mult = 1.297,
        },
		DamageRadius = {
            Add = 0,
            Mult = 1.0495,--was 1.015
        },
    },
}

__moduleinfo.auto_reload = true
