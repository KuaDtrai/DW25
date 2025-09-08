opt server_output = "src/Shared/Network/Server.luau"
opt client_output = "src/Shared/Network/Client.luau"
opt casing = "PascalCase"
opt write_checks = true
opt yield_type = "promise"
opt async_lib = "require(game:GetService('ReplicatedStorage').Packages.Promise)"

event MatchMaking = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: boolean,
}

funct SaveCharacter = {
    call: Async,
    args: (
        Strength: u8,
        Dexterity: u8,
        Constitution: u8,
        Athletics: u8,
        Equipment: string,
    ),
    rets: enum { Success, Fail },
}

event ShiftToggle = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: boolean,
}

event AltToggle = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
}

event LeftClicked = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
}

event UnitCommand = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: map{
        [u8]: struct {
            vec2: Vector3,
        }
    }
}