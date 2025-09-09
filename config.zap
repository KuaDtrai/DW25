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

event TeleportToCampaign = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: (
        Hero: string,
        Campaign: string,
        )
    
}

----- Player Control -----
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
