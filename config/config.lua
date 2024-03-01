config = {}

config.Core = {
    framework = 'qb-core', -- 'esx' or 'qb-core'
    inventory = 'qs-inventory', -- 'ox_inventory', 'qb-inventory', 'qs-inventory', 'ps-inventory', or 'lj-inventory'
    target = 'qb-target', -- 'qb-target', 'ox_target', or 'qtarget'
    notify = function(title, message, types, duration) 

        -- you can add your own notification exports/events here (client sided) 

        lib.notify({ -- uses ox_lib by default.
            title = title, 
            description = message,
            type = types, 
            duration = duration,
        })
    end
}

config.locations = {
    registration = vector4(-915.71, -2038.11, 9.4, 231.45), -- coords to get vehicle registration
    insurance = vector4(117.26, -204.13, 54.66, 337.01) -- coords to get vehicle insurance
}

config.costs = {
    registration = 100, -- price per registration
    insurance = 500 -- price per month (billed all at once, not once per month)
}

config.expire = 30 -- how many days should registration expire after registration date

config.blip = {
    registration = {
        enable = true, -- enable or disable the blip
        sprite = 326, -- the blip icon/sprite (see ref: https://docs.fivem.net/docs/game-references/blips/#blips)
        color = 2, -- the blip color (see ref: https://docs.fivem.net/docs/game-references/blips/#blip-colors)
        scale = 0.8, -- the blip scale/size (0.1 - 1.0)
        label = 'Vehicle Registration', -- the name of the blip
    },
    insurance = {
        enable = true, -- enable or disable the blip
        sprite = 408, -- the blip icon/sprite (see ref: https://docs.fivem.net/docs/game-references/blips/#blips)
        color = 5, -- the blip color (see ref: https://docs.fivem.net/docs/game-references/blips/#blip-colors)
        scale = 0.8, -- the blip scale/size (0.1 - 1.0)
        label = 'Vehicle Insurance', -- the name of the blip
    },
}