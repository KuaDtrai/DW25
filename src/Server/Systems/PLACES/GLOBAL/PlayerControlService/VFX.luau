--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

export type VFX = {
	__index: VFX,
	new: () -> VFX,
	Destroy: (self: VFX) -> (),
}
local Class: VFX = {} :: VFX
Class.__index = Class

function Class.new(): VFX
	local self: VFX = setmetatable({} :: any, Class)
	return self
end

function Class.PlayVFX(character, duration)
	local weapon = character.RightHand.Cube.Cube056.Attachment1.Trail

	if weapon:IsA("Trail") then
		weapon.Enabled = true
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://137628815514180"
		sound.Volume = 0.5 -- Adjust volume as needed (0-1)
		sound.Pitch = 1.0 -- Adjust pitch as needed
		sound.Parent = humanoidRootPart

		-- Play sound
		sound:Play()

		-- Cleanup sound when finished or after duration
		sound.Ended:Connect(function()
			sound:Destroy()
		end)

		-- Failsafe cleanup after duration
		task.delay(duration, function()
			if sound and sound.Parent then
				sound:Destroy()
			end
		end)
	else
		warn("VFX.PlayVFX: HumanoidRootPart not found in character")
	end

	task.delay(duration, function()
		weapon.Enabled = false
	end)

	local audio = "rbxassetid://137628815514180"
end

function Class:Destroy() end

return Class
