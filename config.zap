opt server_output = "src/Shared/Network/Server.luau"
opt client_output = "src/Shared/Network/Client.luau"
opt casing = "PascalCase"
opt write_checks = true
opt yield_type = "promise"
opt async_lib = "require(game:GetService('ReplicatedStorage').Packages.Promise)"

-- Combat
event Damage_Character = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: (Humanoid: Instance(Humanoid), damage: u8)
}

-- Toolbar
event Equipping_Item = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: (itemName: string, itemType: string)
}

event Drop_Toolbar_Item = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: string
}

event Using_Consumables = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        ConsumeType: string,
        HealPoint: u8,
    }
}

event Fetch_Toolbar = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: map {
            [u8]:struct {
            Slot: u8,
            ItemType: string,
            ItemName: string,
        }
    }
}

funct Get_Weapon = {
    call: Async,
    args: string,
    rets: struct {
        Name: string,
        Type: string,
        Rarity: string,
        Damage: u8,
        Durability: u8,
    }
}

funct Get_Consumable = {
    call: Async,
    args: string,
    rets: struct {
        Name: string,
        Type: string,
        Rarity: string,
        HP: u8,
        Quantity: u8,
    }
}

funct Get_Fuse = {
    call: Async,
    args: string,
    rets: struct {
        Name: string,
        Type: string,
        Rarity: string,
        Quantity: u8,
    }
}

-- Inventory
event Fetch_Inventory = {
    from: Server,
    type: Reliable,
    call: SingleAsync,   
    data: struct {
        Weapons: map 
        {
        [u8]:struct
            {
                ID: string,
                Name: string, 
                Type: string,
                Rarity: string, 
                Damage: u8,
                Durability: u8,
            }
        },

        Consumables: map 
        {
        [u8]:struct
            {
                ID: string,
                Name: string, 
                Type: string,
                Rarity: string, 
                HP : u8,
                Quantity: u8,
            }
        },

        Fuse: map 
        {
        [u8]:struct
            {
                ID: string,
                Name: string, 
                Type: string,
                Rarity: string, 
                Quantity: u8,
            }
        }
    }
}
