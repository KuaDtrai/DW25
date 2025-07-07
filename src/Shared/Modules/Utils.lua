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
}
