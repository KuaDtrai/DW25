--!strict
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

export type Death = {
	__index: Death,
	new: () -> Death,
	Destroy: (self: Death) -> (),
}
local Class: Death = {} :: Death
Class.__index = Class

function Class.new(npcModel: Model): Death
	local self: Death = setmetatable({} :: any, Class)

	local humanoid = npcModel:FindFirstChildOfClass("Humanoid")
	humanoid.Died:Connect(function()
		print("Creep has died:", npcModel.Name)
		Debris:AddItem(npcModel, 3)
		for index, joint in pairs(npcModel:GetDescendants()) do
			if joint:IsA("Motor6D") then
				local socket = Instance.new("BallSocketConstraint")
				local a1 = Instance.new("Attachment")
				local a2 = Instance.new("Attachment")
				a1.Parent = joint.Part0
				a2.Parent = joint.Part1
				socket.Parent = joint.Parent
				npcModel.Head.CanCollide = true
				npcModel.LeftHand.CanCollide = true
				npcModel.RightHand.CanCollide = true
				npcModel.RightFoot.CanCollide = true
				npcModel.LeftFoot.CanCollide = true
				npcModel.UpperTorso.CanCollide = true
				npcModel.LowerTorso.CanCollide = true
				npcModel.LeftUpperLeg.CanCollide = true
				npcModel.RightUpperLeg.CanCollide = true
				npcModel.LeftUpperArm.CanCollide = true
				npcModel.RightUpperArm.CanCollide = true
				npcModel.LeftLowerLeg.CanCollide = true
				npcModel.RightLowerLeg.CanCollide = true
				npcModel.LeftLowerArm.CanCollide = true
				npcModel.HumanoidRootPart.CanCollide = false
				script.Parent.HumanoidRootPart.Velocity = script.Parent.LowerTorso.CFrame.lookVector * 1
				socket.Attachment0 = a1
				socket.Attachment1 = a2
				a1.CFrame = joint.C0
				a2.CFrame = joint.C1
				socket.LimitsEnabled = true
				socket.TwistLimitsEnabled = true
				joint:Destroy()
			elseif joint:IsA("Attachment") then
				joint:Destroy()
			end
		end
	end)
	-- CollectionService:RemoveTag(npcModel, "Creep")

	return self
end

function Class:OnDeath(npcModel: Model) end

function Class:Destroy() end

return Class
