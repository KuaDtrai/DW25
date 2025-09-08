local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LOADEDEVENT = ReplicatedStorage:WaitForChild("PLAYER_LOADED")

LOADEDEVENT.OnServerEvent:Once(function(player: Player)
	player:SetAttribute("_PLAYER_LOADED", true)
end)
