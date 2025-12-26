opt server_output = "src/Shared/Network/Server.luau"
opt client_output = "src/Shared/Network/Client.luau"
opt casing = "PascalCase"
opt write_checks = true
opt yield_type = "promise"
opt async_lib = "require(game:GetService('ReplicatedStorage').Packages.Promise)"


----- Teleport -----
event MatchMaking = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: boolean,
}

--VFX Signal--
event VFX_Signal = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: (
        Name: enum{COMBO1, COMBO2, COMBO3, HIT},
        Position: CFrame,
    ),
}

event TeleportToCampaign = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: enum{LOBBY, LACDUONG, MAP1, MAP2, MAP3},
}

----- Player Control -----
event Player_Action = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: (
        Action: enum{ATTACK, DASH, SKILL, BLOCK},
        State: boolean,
    ),
}

event Dash = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
}

event Attack = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
}

event Skill = {
    from: Client,
    type: Reliable,
	call: SingleAsync,
}

event Block = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: boolean,
}
