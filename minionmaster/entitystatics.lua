-- Static Settings

local EntityStatics = 
{
    master = 
    {
        type = "master",
        health = 1000,
        damage = 1,
        speed = 200,
    },

    minion = 
    {
        type = "minion",
        health = 10,
        damage = 1,
        speed = 250,
        cost = 1,
        attackRange = 300,
    },

    enemy = 
    {
        type = "enemy",
        health = 100,
        damage = 1,
        speed = 100,
        dna = 10,
    },

    building = 
    {
        health = 1000,
        radius = 40,
        dna = 100,
    },
}

return EntityStatics