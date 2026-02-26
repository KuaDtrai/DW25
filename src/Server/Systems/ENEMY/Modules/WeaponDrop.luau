--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local WeaponFolder = ReplicatedStorage.Shared.Assets:WaitForChild("Weapon")

local WeaponDrop = {}
WeaponDrop.__index = WeaponDrop

export type WeaponDrop = {
	character: Model,
}

--------------------------------------------------
-- INTERNAL
--------------------------------------------------
local function getRandomWeapon(): Model?
	local weapons = WeaponFolder:GetChildren()
	if #weapons == 0 then
		warn("[WeaponDrop] No weapon models found")
		return nil
	end

	local weapon = weapons[math.random(1, #weapons)]
	if not weapon:IsA("Model") then
		return nil
	end

	return weapon
end

local function getDropCFrame(character: Model): CFrame?
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		return hrp.CFrame
	end

	local primary = character.PrimaryPart
	if primary then
		return primary.CFrame
	end

	return nil
end

--------------------------------------------------
-- PUBLIC
--------------------------------------------------
function WeaponDrop.new(character: Model): WeaponDrop
	local self = setmetatable({}, WeaponDrop)
	self.character = character

	-- Theo dõi State
	character:GetAttributeChangedSignal("State"):Connect(function()
		if character:GetAttribute("State") == "Dead" then
			self:Drop()
		end
	end)

	-- Fallback: Humanoid chết
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			self:Drop()
		end)
	end

	return self
end

function WeaponDrop:Drop()
	if not self.character or not self.character.Parent then
		return
	end

	-- Chỉ drop 1 lần
	if self.character:GetAttribute("WeaponDropped") then
		return
	end
	self.character:SetAttribute("WeaponDropped", true)

	local weaponTemplate = getRandomWeapon()
	if not weaponTemplate then
		return
	end

	local dropCF = getDropCFrame(self.character)
	if not dropCF then
		return
	end

	local weapon = weaponTemplate:Clone()
	weapon.Name = "Weapon"

	if not weapon.PrimaryPart then
		weapon.PrimaryPart = weapon:FindFirstChildWhichIsA("BasePart")
	end

	if not weapon.PrimaryPart then
		warn("[WeaponDrop] Weapon has no PrimaryPart:", weaponTemplate.Name)
		weapon:Destroy()
		return
	end

	weapon:SetPrimaryPartCFrame(dropCF * CFrame.new(0, 0, 0))
	weapon.Parent = Workspace

	-- Vật lý nhẹ
	for _, part in weapon:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
		end
	end
end

return WeaponDrop
