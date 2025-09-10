--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CONSTANTS = require(ReplicatedStorage.Shared.Libraries.CONSTANTS)

export type Block = {
	__index: Block,
	new: () -> Block,
	onBlock: (self: Block, player: Player, state: boolean) -> (),
	Destroy: (self: Block) -> (),
}
local Class: Block = {} :: Block
Class.__index = Class

function Class.new(): Block
	local self: Block = setmetatable({} :: any, Class)
	return self
end

local animationTracks = {} -- Lưu trữ AnimationTrack cho từng người chơi

function Class:onBlock(Player, state)
	local character = Player.Character
	if not character then
		warn("No character found for player", Player)
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("No Humanoid found for player", Player)
		return
	end

	local animationId = CONSTANTS:getAnimation("BLOCK")
	if animationId == "" then
		warn("No AnimationId found for BLOCK")
		return
	end

	if state then
		local animation = Instance.new("Animation", humanoid)
		animation.AnimationId = animationId
		local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
		local animationTrack = animator:LoadAnimation(animation)
		animationTrack:Play()
		animationTracks[Player] = animationTrack
	else
		local animationTrack = animationTracks[Player]
		if animationTrack then
			animationTrack:Stop()
			animationTracks[Player] = nil
		end
	end
	-- Clean up animationTracks when player leaves
	game.Players.PlayerRemoving:Connect(function(player)
		animationTracks[player] = nil
	end)
end

function Class:Destroy() end

return Class
