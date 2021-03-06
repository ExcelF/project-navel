-- EntityStatic Definitions for SKoA-Sandbox:
local Abilities = require "sandbox.statics.abilitiydefinitions"

local EStats = {

	FirstEncounter = {
		BattlefieldComponent = {
			units = {
				{
					unitId = "Wolf",
					pos = {60, 100},
				},
				{
					unitId = "Wolf",
					pos = {60, 200},
				},
				{
					unitId = "Knight",
					pos = {1000, 100},
				},
				{
					unitId = "Archer",
					pos = {1000, 200},
				},
				{
					unitId = "Priest",
					pos = {1000, 300},
				},
				{
					unitId = "Mage",
					pos = {1000, 400},
				},
			}
		}
	},

    Knight = {
    	UnitComponent = {
    		health = 90,
    		damage = 20,
            attackRange = 90,
    		defense = 10,
    		walkRate = 32,
            baseActionPts = 6,
            maxActionPts = 10,
            initiative = 8,

            abilities = {
                Abilities.Definitions.Heal.name,
            }
    	},
        SimpleIconComponent = {
            iconPath = "/sandbox/resources/unit_pictures/co_armygroup_axeman_circle.png",
            width = 64,
            height = 64,
        },
        CollisionComponent = {
            width = 64,
            height = 64,
        },
        MovementComponent = {

        },
    },

    Priest = {
    	UnitComponent = {
    		health = 60,
    		damage = 20,
            attackRange = 90,
    		defense = 5,
            walkRate = 32,
            baseActionPts = 6,
            maxActionPts = 10,
            initiative = 3,
            
            abilities = {
                Abilities.Definitions.Heal.name,
            }
    	},
        SimpleIconComponent = {
            iconPath = "/sandbox/resources/unit_pictures/co_armygroup_viking_outcast_circle.png",
            width = 64,
            height = 64,
        },
        CollisionComponent = {
            width = 64,
            height = 64,
        },
        MovementComponent = {

        },
    },

    Archer = {
    	UnitComponent = {
    		health = 45,
    		damage = 30,
            attackRange = 330,
    		defense = 5,
            walkRate = 32,
            baseActionPts = 6,
            maxActionPts = 10,
            initiative = 6,

            abilities = {
                Abilities.Definitions.Heal.name,
            }
    	},
        SimpleIconComponent = {
            iconPath = "/sandbox/resources/unit_pictures/co_armygroup_bowman_circle.png",
            width = 64,
            height = 64,
        },
        CollisionComponent = {
            width = 64,
            height = 64,
        },
        MovementComponent = {

        },
    },

    Mage = {
    	UnitComponent = {
    		health = 30,
    		damage = 25,
            attackRange = 210,
    		defense = 0,
            walkRate = 32,
            baseActionPts = 6,
            maxActionPts = 10,
            initiative = 4,
 
            abilities = {
                Abilities.Definitions.Heal.name,
            }
    	},
        SimpleIconComponent = {
            iconPath = "/sandbox/resources/unit_pictures/co_armygroup_brother_circle.png",
            width = 64,
            height = 64,
        },
        CollisionComponent = {
            width = 64,
            height = 64,
        },
        MovementComponent = {

        },
    },

    Wolf = {
    	UnitComponent = {
    		health = 50,
    		damage = 10,
            attackRange = 90,
    		defense = 5,
            walkRate = 32,
            baseActionPts = 6,
            maxActionPts = 10,
            initiative = 7,

            abilities = {
                Abilities.Definitions.Heal.name,
            }
    	},
        SimpleIconComponent = {
            iconPath = "/sandbox/resources/unit_pictures/co_armygroup_tamed_wolf_circle.png",
            width = 64,
            height = 64,
        },
        CollisionComponent = {
            width = 64,
            height = 64,
        },
        MovementComponent = {

        },
    },
}

-- Set name to key.
for name, data in pairs(EStats) do
    if data.UnitComponent then
        data.UnitComponent.name = name
    end
end

return EStats

