--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local COOLDOWN = 5
local FireworksFolder = ReplicatedStorage.Shared.Assets.Fireworks
local VFXFolder = ReplicatedStorage.Shared.Assets.VFXs.Fireworks

local function playEmitters(container: Instance)
	for _, obj in ipairs(container:GetDescendants()) do
		if obj:IsA("ParticleEmitter") then
			local emitCount = obj:GetAttribute("EmitCount") or 0
			local emitDelay = obj:GetAttribute("EmitDelay") or 0
			local emitDuration = obj:GetAttribute("EmitDuration") or 0

			task.delay(emitDelay, function()
				if emitCount > 0 then
					obj:Emit(emitCount)
				else
					obj.Enabled = true
				end

				if emitDuration > 0 then
					task.delay(emitDuration, function()
						obj.Enabled = false
					end)
				end
			end)
		end
	end
end

export type UseFireworkModule = {
	__index: UseFireworkModule,
	new: () -> UseFireworkModule,
	Destroy: (self: UseFireworkModule) -> (),
}
local Class: UseFireworkModule = {} :: UseFireworkModule
Class.__index = Class

function Class.new(): UseFireworkModule
	local self: UseFireworkModule = setmetatable({} :: any, Class)
	self._cooldowns = {}

	return self
end

function Class:Use(player: Player, pos: Vector3)
	local now = os.clock()
	local last = self._cooldowns[player] or 0

	if now - last < COOLDOWN then
		return
	end

	self._cooldowns[player] = now

	-------------------------------------------------
	-- Spawn Firework Model
	-------------------------------------------------
	local templates = FireworksFolder:GetChildren()
	if #templates == 0 then
		return
	end

	local model = templates[math.random(1, #templates)]:Clone()
	model.Parent = workspace
	model.PrimaryPart.Anchored = true
	if not model.PrimaryPart then
		model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart")
	end

	local prompt = model.Part:FindFirstChild("ProximityPrompt")
	if prompt:IsA("ProximityPrompt") then
		prompt.Enabled = false
	end

	Debris:AddItem(model, 10)

	if not model.PrimaryPart then
		return
	end

	model:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)))

	local primary = model.PrimaryPart

	-------------------------------------------------
	-- Phase 1 — Attachment emitters (3s)
	-------------------------------------------------
	local attach = primary:FindFirstChild("Attachment")
	if attach then
		playEmitters(attach)
	end

	-------------------------------------------------
	-- After 3 seconds
	-------------------------------------------------
	task.delay(3, function()
		-- Hide model
		for _, obj in ipairs(model:GetDescendants()) do
			if obj:IsA("BasePart") then
				obj.Transparency = 1
			end
		end
		-- model:Destroy()

		-- Smoke emitters
		local smoke = primary:FindFirstChild("SmokeATM")
		if smoke then
			playEmitters(smoke)
		end

		-------------------------------------------------
		-- After 2 more seconds → Sky explosion
		-------------------------------------------------
		task.delay(2, function()
			local vfxList = VFXFolder:GetChildren()
			if #vfxList == 0 then
				return
			end

			local part = vfxList[math.random(1, #vfxList)]:Clone()
			part.Parent = workspace

			if part:IsA("BasePart") then
				part.CFrame = CFrame.new(pos + Vector3.new(0, math.random(70, 100), 0))
			elseif part:IsA("Model") and part.PrimaryPart then
				part:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(0, 200, 0)))
			end

			playEmitters(part)

			Debris:AddItem(part, 10)
		end)
	end)

	Debris:AddItem(model, 15)
end

function Class:Destroy() end

return Class
