--!strict
local RunService = game:GetService("RunService")

local CharacterMovementController = {}

local Connections: { [Model]: RBXScriptConnection } = {}

local ATTACK_SPEED = 0
local NORMAL_SPEED = 16

--------------------------------------------------
-- INTERNAL
--------------------------------------------------
local function applyAttackState(humanoid: Humanoid)
	humanoid.AutoRotate = false
	humanoid.WalkSpeed = ATTACK_SPEED
end

local function applyNormalState(humanoid: Humanoid)
	humanoid.AutoRotate = true
	humanoid.WalkSpeed = NORMAL_SPEED
end

--------------------------------------------------
-- PUBLIC API
--------------------------------------------------
function CharacterMovementController.bind(character: Model)
	if Connections[character] then
		Connections[character]:Disconnect()
	end

	local humanoid = character:WaitForChild("Humanoid")

	Connections[character] = RunService.Heartbeat:Connect(function()
		local isAttacking = character:GetAttribute("IsAttacking") == true

		if isAttacking then
			applyAttackState(humanoid)

			-- 🔥 DẬP INPUT
			humanoid:Move(Vector3.zero, false)
		else
			applyNormalState(humanoid)
		end
	end)
end

function CharacterMovementController.unbind(character: Model)
	if Connections[character] then
		Connections[character]:Disconnect()
		Connections[character] = nil
	end
end

return CharacterMovementController
