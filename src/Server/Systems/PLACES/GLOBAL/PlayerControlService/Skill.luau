--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HitBoxFolder = ReplicatedStorage.Shared.Assets.HitBox :: Folder

export type Skill = {
	__index: Skill,
	new: () -> Skill,
	onSkill: (self: Skill, player: Player) -> (),
	Destroy: (self: Skill) -> (),
}
local Class: Skill = {} :: Skill
Class.__index = Class

function Class.new(): Skill
	local self: Skill = setmetatable({} :: any, Class)

	local cone_45 = HitBoxFolder:FindFirstChild("45_degree")
	local cone_90 = HitBoxFolder:FindFirstChild("90_degree")
	local cone_180 = HitBoxFolder:FindFirstChild("180_degree")

	self.Combo = {
		cone_45,
		cone_90,
		cone_180,
	}

	self.HitboxTime = 1
	self.Green = Color3.new(0.145098, 1, 0.011764)
	self.Blue = Color3.new(0.027450, 0.011764, 1)
	self.Purple = Color3.new(0.721568, 0.011764, 1)

	return self
end

function Class:onSkill(Player: Player)
	local character = Player.Character
	if not character then
		warn("No character found for player:", Player.Name)
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then
		warn("Humanoid or HRP missing for character:", character.Name)
		return
	end

	local combo = Player:GetAttribute("Combo")

	if combo == 1 then
		Class.spawnArcHitbox(character, self.Combo[1], self.HitboxTime, self.Green)
	elseif combo == 2 then
		Class.spawnArcHitbox(character, self.Combo[2], self.HitboxTime, self.Blue)
	elseif combo == 3 then
		Class.spawnArcHitbox(character, self.Combo[3], self.HitboxTime, self.Purple)
	end
end

function Class.spawnArcHitbox(character: Model, hitbox: Model, time: number, color: Color3)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local Humanoid = character:FindFirstChild("Humanoid")
	Humanoid.WalkSpeed = 0

	local clone = hitbox:Clone()
	clone.Parent = hrp
	clone.CFrame = hrp.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, math.rad(180), 0)

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = clone
	weld.Parent = clone

	clone.Transparency = 0.5
	clone.Color = color

	task.delay(time, function()
		if clone then
			clone:Destroy()
			Humanoid.WalkSpeed = 16
		end
	end)
end

function Class:Destroy() end

return Class
