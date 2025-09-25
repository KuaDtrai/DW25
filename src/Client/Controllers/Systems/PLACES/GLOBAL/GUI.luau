--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local PlayerGUIFolder = ReplicatedStorage.Shared.Assets

export type GUI = {
	__index: GUI,
	new: () -> GUI,
	Destroy: (self: GUI) -> (),
}
local Class: GUI = {} :: GUI
Class.__index = Class

function Class.new(): GUI
	local self: GUI = setmetatable({} :: any, Class)

	-- Assume you have BillboardGui templates in ReplicatedStorage.GuiTemplates
	local guiFolder = PlayerGUIFolder:FindFirstChild("PlayerGUI")

	local healthTemplate = guiFolder:WaitForChild("Health") :: BillboardGui
	local powTemplate = guiFolder:WaitForChild("Pow") :: BillboardGui

	-- Clone so each character has its own
	self.Health = healthTemplate:Clone()
	self.HealthValue = self.Health:WaitForChild("Frame") :: Frame
	self.Pow = powTemplate:Clone()
	self.PowValue = self.Pow:WaitForChild("Frame") :: Frame

	Class.ShowGui(self.Health, self.Pow, self.HealthValue, self.PowValue)

	return self
end

function Class.ShowGui(HealthGUI, PowGUI, HealthValue, PowValue)
	Player.CharacterAdded:Connect(function(character)
		local head = character:WaitForChild("Head")
		local humanoid = character:WaitForChild("Humanoid")

		HealthGUI.Parent = head
		PowGUI.Parent = head

		local function update()
			Class.updateHealth(humanoid, HealthGUI, HealthValue, PowValue)
		end

		humanoid.HealthChanged:Connect(update)
		humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(update)

		update() -- run once at spawn
	end)
end

function Class.updateHealth(humanoid, HealthGUI, HealthValue, PowValue)
	local health = humanoid.Health
	local maxHealth = humanoid.MaxHealth
	local percent = health / maxHealth
	HealthValue.Size = UDim2.new(percent, 0, 1, 0)

	-- Optional: change color when low
	if percent > 0.5 then
		HealthValue.BackgroundColor3 = Color3.new(0, 1, 0)
	elseif percent > 0.25 then
		HealthValue.BackgroundColor3 = Color3.new(1, 1, 0)
	else
		HealthValue.BackgroundColor3 = Color3.new(1, 0, 0)
	end
end

function Class:Destroy() end

return Class
