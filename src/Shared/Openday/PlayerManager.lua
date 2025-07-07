--!strict
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

type CharacterFunction = (player: Player, character: Model) -> ()
type PlayerFunction = (player: Player) -> ()

export type Connections = {
	AddPlayerAddedCallback: (func: PlayerFunction) -> (),
	AddPlayerRemovingCallback: (func: PlayerFunction) -> (),

	AddCharacterAddedCallback: (func: CharacterFunction) -> (),
	AddCharacterRemovingCallback: (func: CharacterFunction) -> (),

	AddLocalCharacterAddedCallback: (func: CharacterFunction) -> (),
	AddLocalCharacterRemovingCallback: (func: CharacterFunction) -> (),
}

local PlayerAddedCallbacks: { PlayerFunction } = {}
local PlayerRemovingCallbacks: { PlayerFunction } = {}

local CharacterAddedCallbacks: { CharacterFunction } = {}
local CharacterRemovingCallbacks: { CharacterFunction } = {}

local PlayerConnections = {}

local Functions: Connections = {} :: Connections

function Functions.AddPlayerAddedCallback(func: PlayerFunction, priority: number?)
	if priority then
		table.insert(PlayerAddedCallbacks, priority, func)
	else
		table.insert(PlayerAddedCallbacks, func)
	end

	for _, Player in Players:GetPlayers() do
		task.spawn(func, Player)
	end
end

function Functions.AddPlayerRemovingCallback(func: PlayerFunction)
	table.insert(PlayerRemovingCallbacks, func)
end

function Functions.AddCharacterAddedCallback(func: CharacterFunction)
	table.insert(CharacterAddedCallbacks, func)

	for _, player in Players:GetPlayers() do
		if player.Character then
			func(player, player.Character)
		end
	end
end

function Functions.AddCharacterRemovingCallback(func: CharacterFunction): ...any
	table.insert(CharacterRemovingCallbacks, func)
end

if RunService:IsClient() then
	local Player = Players.LocalPlayer

	--@desc: CLIENT ONLY
	function AddLocalCharacterAddedCallback(func: CharacterFunction)
		table.insert(CharacterAddedCallbacks, func)

		if Player.Character then
			func(Player, Player.Character)
		end
	end

	function AddLocalCharacterRemovingCallback(func: CharacterFunction)
		table.insert(CharacterRemovingCallbacks, func)
	end

	Player.CharacterAdded:Connect(function(character: Model)
		for _, func: (Player, Model) -> ...any in pairs(CharacterAddedCallbacks) do
			task.spawn(func, Player, character)
		end
	end)

	Player.CharacterRemoving:Connect(function(character: Model)
		for _, func: (Player, Model) -> ...any in pairs(CharacterRemovingCallbacks) do
			task.spawn(func, Player, character)
		end
	end)

	Functions.AddLocalCharacterAddedCallback = AddLocalCharacterAddedCallback
	Functions.AddLocalCharacterRemovingCallback = AddLocalCharacterRemovingCallback
end

Players.PlayerAdded:Connect(function(player: Player)
	for _, func: (Player) -> ...any in pairs(PlayerAddedCallbacks) do
		task.spawn(func, player)
	end

	local connections: { RBXScriptConnection } = {}

	table.insert(
		connections,
		player.CharacterAdded:Connect(function(character: Model)
			for _, func: (Player, Model) -> ...any in pairs(CharacterAddedCallbacks) do
				task.spawn(func, player, character)
			end
		end)
	)

	table.insert(
		connections,
		player.CharacterRemoving:Connect(function(character: Model)
			for _, func: (Player, Model) -> ...any in pairs(CharacterRemovingCallbacks) do
				task.spawn(func, player, character)
			end
		end)
	)

	PlayerConnections[player.UserId] = connections
end)

Players.PlayerRemoving:Connect(function(player: Player)
	for _, func: (Player) -> ...any in pairs(PlayerRemovingCallbacks) do
		task.spawn(func, player)
	end

	if PlayerConnections[player.UserId] then
		for _, connection: RBXScriptConnection in pairs(PlayerConnections[player.UserId]) do
			connection:Disconnect()
		end

		PlayerConnections[player.UserId] = {}
	end
end)

return Functions
