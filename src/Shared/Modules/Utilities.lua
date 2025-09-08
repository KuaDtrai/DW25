local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
export type PropertyArray = { [string]: any }
export type InstancePropertyArray = { [Instance]: PropertyArray }

local BASE_PART_PROPERTIES = {
	"Anchored",
	"CanCollide",
	"Transparency",
	"Orientation",
	"Color",
	"Size",
	"Reflectance",
	"Rotation",
	"CFrame",
	"Position",
	"PivotOffset",
}

local function Lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function GetOrCreateAttachment(part: BasePart, name: string, axis: Vector3?, secondaryAxis: Vector3?): Attachment
	local attachment = part:FindFirstChild(name)
	if attachment and attachment:IsA("Attachment") then
		-- If the attachment already exists, return it
		return attachment
	end

	-- No attachment exists, so we'll create a new one
	local newAttachment = Instance.new("Attachment")
	newAttachment.Name = name
	if axis then
		newAttachment.Axis = axis
	end
	if secondaryAxis then
		newAttachment.SecondaryAxis = secondaryAxis
	end
	newAttachment.Parent = part

	return newAttachment
end

local function CalculateVelocityForHeight(height: number): number
	-- Equation to find the Y velocity required to reach a specific height derived from basic kinematic equations
	return math.sqrt(2 * workspace.Gravity * height)
end

local function SetVerticalVelocity(part: BasePart, velocity: number)
	part.AssemblyLinearVelocity = Vector3.new(part.AssemblyLinearVelocity.X, velocity, part.AssemblyLinearVelocity.Z)
end

local function TimedParticle(effectTemplate: BasePart, cframe: CFrame, lifetime: number, attachTo: BasePart?)
	local effect = effectTemplate:Clone()
	effect.CFrame = if attachTo then attachTo.CFrame * cframe else cframe
	effect.Parent = workspace

	if attachTo then
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = attachTo
		weld.Part1 = effect
		weld.Parent = effect
	end

	local particleEmitters = {}
	local particleLifetime = 0

	-- Find all the particle emitters and get the maximum lifetime for them
	for _, v in effect:GetDescendants() do
		if not v:IsA("ParticleEmitter") then
			continue
		end

		table.insert(particleEmitters, v)
		particleLifetime = math.max(particleLifetime, v.Lifetime.Max)
	end

	task.delay(lifetime, function()
		-- Disable all the particle emitters
		for _, emitter in particleEmitters do
			emitter.Enabled = false
		end

		-- Wait for them to fade before destroying the effect
		task.delay(particleLifetime, function()
			effect:Destroy()
		end)
	end)
end

local EMIT_AMOUNT_ATTRIBUTE = "EmitCount"

local function ParticleBurst(effectTemplate: BasePart, cframe: CFrame, attachTo: BasePart?)
	local effect = effectTemplate:Clone()
	effect.CFrame = if attachTo then attachTo.CFrame * cframe else cframe
	effect.Parent = workspace
	if attachTo then
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = attachTo
		weld.Part1 = effect
		weld.Parent = effect
	end

	local lifetime = 0

	-- Get all the particle emitters and have them emit, as well as get the maximum particle lifetime
	for _, v in effect:GetDescendants() do
		if not v:IsA("ParticleEmitter") then
			continue
		end

		lifetime = math.max(lifetime, v.Lifetime.Max)

		local emitAmount = v:GetAttribute(EMIT_AMOUNT_ATTRIBUTE)
		if emitAmount then
			v:Emit(emitAmount)
		end
	end

	Debris:AddItem(effect, lifetime * 2)
end

local function PlaySoundFromSource(soundTemplate: Sound, source: Instance, pitchAdjustment: number?)
	local sound = soundTemplate:Clone()
	if pitchAdjustment then
		sound.PlaybackSpeed *= pitchAdjustment
	end
	sound.Parent = source

	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
end

function HasProperty(instance: Instance, property: string): boolean
	local hasProperty: boolean = false

	pcall(function()
		local _ = instance[property]
		hasProperty = true -- This line only runs if the previous line didn't error
	end)

	return hasProperty
end

function ConvertPartProperty(part: BasePart): PropertyArray
	local dictEntry: PropertyArray = {}

	for _, property: string in BASE_PART_PROPERTIES do
		if HasProperty(part, property) then
			dictEntry[property] = part[property]
		end
	end

	return dictEntry
end

function GetDescendantsWhichAre(ancestor: Instance, className: string): { Instance }
	local descendants = {}

	for _, descendant in pairs(ancestor:GetDescendants()) do
		if descendant:IsA(className) then
			table.insert(descendants, descendant)
		end
	end

	return descendants
end

function HideModel(model: Model): InstancePropertyArray
	local count: number = 0
	local properties: { [Instance]: PropertyArray } = {}
	local instances: { Instance } = GetDescendantsWhichAre(model, "BasePart")
	for _, part: Instance in instances do
		count += 1
		local property: PropertyArray = HidePart(part :: BasePart)
		properties[part] = property
	end

	return properties
end

function HidePart(part: BasePart): PropertyArray
	local properties: PropertyArray = ConvertPartProperty(part)
	part.CanCollide = false
	part.Transparency = 1
	part.Reflectance = 0

	ToggleExtra(part, false)

	return properties
end

function ToggleExtra(part: BasePart, toggle: boolean)
	for _, descendant: Instance in pairs(part:GetDescendants()) do
		if descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
			(descendant :: any).Enabled = toggle
		elseif descendant:IsA("Light") then
			local tween: Tween
			if not toggle then
				tween = TweenService:Create(
					descendant,
					TweenInfo.new(0.5),
					{ Brightness = descendant:GetAttribute("Brightness") or 0 }
				)
			else
				descendant:SetAttribute("Brightness", descendant.Brightness)
				tween = TweenService:Create(descendant, TweenInfo.new(0.5), { Brightness = 0 })
			end

			tween:Play()
			tween.Completed:Connect(function()
				descendant.Enabled = toggle
			end)
		end
	end
end

function GetClosestModelFromPosition(position: Vector3, models: { Model }): Model
	local closestModel: Model = nil
	local shortestDistance: number = math.huge -- Initially set to a very high number

	-- Iterate through all models in the Workspace
	for _, model: Model in models do
		-- Find a primary part (could be customized to find a specific part)
		local primaryPart: BasePart? = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
		if primaryPart then
			-- Calculate the distance from the character's root to the model's primary part
			local distance: number = (position - primaryPart.Position).Magnitude
			-- If this distance is the shortest we've found so far, update our tracking variables
			if distance < shortestDistance then
				closestModel = model
				shortestDistance = distance
			end
		end
	end

	return closestModel
end

function GetPrimaryPart(model: Model): BasePart?
	return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
end

function GetAssemblyMass(model: Model): number
	local mass = 0
	for _, v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			mass += v.AssemblyMass
		end
	end
	return mass
end

function GetMass(instance: Instance): number
	local mass = 0

	if instance:IsA("Model") then
		for _, part in pairs(instance:GetDescendants()) do
			if part:IsA("BasePart") then
				mass += part.Mass
			end
		end
	elseif instance:IsA("BasePart") then
		mass = instance.Mass
	end

	return mass
end

function GetLongestAxis(model: Model): number
	local longest = 0
	local size = model:GetExtentsSize()

	if size.X > longest then
		longest = size.X
	end

	if size.Z > longest then
		longest = size.Z
	end

	if size.Y / 2 > longest then
		longest = size.Y / 2
	end

	return longest
end

function GetVolume(model: Model, scale: number): number
	local size = model:GetExtentsSize()

	return size.Z * size.X * size.Y * scale
end

function QuadBezier(t: number, p0: Vector3, p1: Vector3, p2: Vector3): Vector3
	local l1 = p0:Lerp(p1, t)
	local l2 = p1:Lerp(p2, t)

	return l1:Lerp(l2, t)
end

return {
	GetAssemblyMass = GetAssemblyMass,
	GetLongestAxis = GetLongestAxis,
	GetVolume = GetVolume,
	GetMass = GetMass,
	GetPrimaryPart = GetPrimaryPart,
	GetClosestModelFromPosition = GetClosestModelFromPosition,
	GetDescendantsWhichAre = GetDescendantsWhichAre,
	ConvertPartProperty = ConvertPartProperty,
	HasProperty = HasProperty,
	HideModel = HideModel,
	HidePart = HidePart,
	ToggleExtra = ToggleExtra,
	Lerp = Lerp,
	GetOrCreateAttachment = GetOrCreateAttachment,
	CalculateVelocityForHeight = CalculateVelocityForHeight,
	SetVerticalVelocity = SetVerticalVelocity,
	TimedParticle = TimedParticle,
	ParticleBurst = ParticleBurst,
	PlaySoundFromSource = PlaySoundFromSource,

	QuadBezier = QuadBezier,
}
