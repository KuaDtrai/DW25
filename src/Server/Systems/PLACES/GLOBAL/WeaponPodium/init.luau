--!strict
-- WeaponPickupSystem.server.lua (không dùng Tool)

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local pickupCooldown = {}
local PICKUP_DELAY = 0.5

local WeaponAssets = ReplicatedStorage.Shared.Assets.Weapon

local Openday = require(ReplicatedStorage.Shared.Openday)

export type System = {
	_Extensions: { Openday.Extension },
	_Start: (self: System) -> (),
	_Setup: (self: System) -> (),
}

local WeaponPickupSystem = {
	_Extensions = {},
} :: System

local TAG = "WEAPON_PODIUM"

local WEAPON_CFRAME = CFrame.Angles(math.rad(-90), math.rad(90), 0)

local function getWeaponType(pickupModel: Instance): string?
	if pickupModel:HasTag("WEAPON_SWORD") then
		return "SWORD"
	elseif pickupModel:HasTag("WEAPON_LANCE") then
		return "LANCE"
	elseif pickupModel:HasTag("WEAPON_GREATSWORD") then
		return "GREATSWORD"
	end
	return nil
end

local function pickupWeapon(prompt: ProximityPrompt, player: Player)
	local uid = player.UserId
	if pickupCooldown[uid] then
		return
	end

	pickupCooldown[uid] = true
	task.delay(PICKUP_DELAY, function()
		pickupCooldown[uid] = nil
	end)

	local character = player.Character
	if not character then
		return
	end

	local rightHand = character:FindFirstChild("RightHand")
	if not rightHand then
		warn("Không tìm thấy RightHand!")
		return
	end

	local handle = prompt.Parent
	if not handle or not handle:IsA("BasePart") then
		return
	end

	-- tìm model pickup
	local pickupModel = handle:FindFirstAncestorWhichIsA("Model") or handle

	----------------------------------------------------
	-- XÁC ĐỊNH LOẠI VŨ KHÍ
	----------------------------------------------------
	local weaponType = getWeaponType(pickupModel)
	if weaponType then
		character:SetAttribute("EquippedWeapon", weaponType)
	end

	----------------------------------------------------
	-- 🔥 DROP VŨ KHÍ CŨ
	----------------------------------------------------
	local oldWeapon = rightHand:FindFirstChild("Weapon")
	if oldWeapon then
		local oldMotor = rightHand:FindFirstChild("WeaponGrip")
		if oldMotor then
			oldMotor:Destroy()
		end

		oldWeapon.Parent = workspace

		for _, part in ipairs(oldWeapon:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = false
				part.CanCollide = true
			end
		end

		local dropPos = rightHand.Position - Vector3.new(0, 1, 0)
		if oldWeapon:IsA("Model") and oldWeapon.PrimaryPart then
			oldWeapon:SetPrimaryPartCFrame(CFrame.new(dropPos))
		end
	end

	----------------------------------------------------
	-- 🔥 CLONE VŨ KHÍ MỚI TỪ REPLICATEDSTORAGE
	----------------------------------------------------
	local weaponTemplate = WeaponAssets:FindFirstChild("Weapon")
	if not weaponTemplate then
		warn("Không tìm thấy Weapon asset!")
		return
	end

	local newWeapon = weaponTemplate:Clone()
	newWeapon.Name = "Weapon"
	newWeapon.Parent = rightHand

	for _, part in ipairs(newWeapon:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
		end
		if part:IsA("ProximityPrompt") then
			part:Destroy()
		end
	end

	----------------------------------------------------
	-- GẮN VÀO TAY
	----------------------------------------------------
	local weaponHandle = newWeapon.PrimaryPart or newWeapon:FindFirstChildWhichIsA("BasePart")

	if not weaponHandle then
		warn("Weapon không có BasePart!")
		newWeapon:Destroy()
		return
	end

	local motor = Instance.new("Motor6D")
	motor.Name = "WeaponGrip"
	motor.Part0 = rightHand
	motor.Part1 = weaponHandle
	motor.C0 = WEAPON_CFRAME
	motor.C1 = CFrame.new()
	motor.Parent = rightHand

	print(player.Name, "đã nhặt vũ khí", weaponType or "")
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
