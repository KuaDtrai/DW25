--!strict
-- WeaponPickupSystem.server.lua (không dùng Tool)

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Openday = require(ReplicatedStorage.Shared.Openday)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local WeaponPickupSystem = {
	_Extensions = {},
} :: System

local TAG = "WEAPON_PROMPT"

local WEAPON_CFRAME = CFrame.Angles(math.rad(-90), math.rad(90), 0)

local function pickupWeapon(prompt: ProximityPrompt, player: Player)
	local character = player.Character
	if not character then
		return
	end

	local rightHand = character:FindFirstChild("RightHand")
	if not rightHand then
		warn("Không tìm thấy RightHand!")
		return
	end

	-- handle = BasePart chứa prompt
	local handle = prompt.Parent
	if not handle or not handle:IsA("BasePart") then
		return
	end

	-- tìm model vũ khí
	local weaponRoot = handle
	repeat
		if weaponRoot:IsA("Model") then
			break
		end
		weaponRoot = weaponRoot.Parent
	until not weaponRoot or not weaponRoot.Parent

	if not weaponRoot then
		weaponRoot = handle
	end

	------------------------------------------------------------------
	-- 🔥 DROP VŨ KHÍ CŨ
	------------------------------------------------------------------
	local oldWeapon = rightHand:FindFirstChild("Weapon")
	if oldWeapon then
		local oldMotor = rightHand:FindFirstChild("WeaponGrip")
		if oldMotor then
			oldMotor:Destroy()
		end

		-- đưa ra workspace
		oldWeapon.Parent = workspace

		for _, part in ipairs(oldWeapon:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = false
				part.CanCollide = true
			end
		end

		-- đặt vị trí rớt xuống dưới tay
		local dropPos = rightHand.Position - Vector3.new(0, 1, 0)
		if oldWeapon:IsA("Model") and oldWeapon.PrimaryPart then
			oldWeapon:SetPrimaryPartCFrame(CFrame.new(dropPos))
		elseif oldWeapon:IsA("BasePart") then
			oldWeapon.Position = dropPos
		end

		-- Gắn prompt để nhặt lại
		local newPrompt = Instance.new("ProximityPrompt")
		newPrompt.Name = "PickupPrompt"
		newPrompt.ActionText = "Nhặt"
		newPrompt.ObjectText = "Vũ khí"
		newPrompt.MaxActivationDistance = 8
		newPrompt.Parent = oldWeapon:FindFirstChildWhichIsA("BasePart") or oldWeapon

		CollectionService:AddTag(newPrompt, TAG)
	end

	------------------------------------------------------------------
	-- 🔥 EQUIP VŨ KHÍ MỚI
	------------------------------------------------------------------
	for _, part in ipairs(weaponRoot:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
		end
	end

	weaponRoot.Name = "Weapon"
	weaponRoot.Parent = rightHand

	local motor = Instance.new("Motor6D")
	motor.Name = "WeaponGrip"
	motor.Part0 = rightHand
	motor.Part1 = handle
	motor.C0 = WEAPON_CFRAME
	motor.C1 = CFrame.new()
	motor.Parent = rightHand

	prompt:Destroy()

	print(player.Name, "đã nhặt vũ khí")
end

-- setup prompt
local function setupPrompt(prompt: Instance)
	if not prompt:IsA("ProximityPrompt") then
		return
	end

	prompt.Triggered:Connect(function(player)
		task.spawn(pickupWeapon, prompt, player)
	end)
end

function WeaponPickupSystem:_Start()
	for _, obj in CollectionService:GetTagged(TAG) do
		setupPrompt(obj)
	end

	CollectionService:GetInstanceAddedSignal(TAG):Connect(setupPrompt)
	print("[WeaponPickupSystem] Start")
end

function WeaponPickupSystem:_Setup() end

return WeaponPickupSystem
