--!strict
local SHORT_CUTS = {
	Properties = { -- Color shortcuts: you can use these strings instead of full property names
		Color = "TextColor3",
		StrokeColor = "TextStrokeColor3",
		ImageColor = "ImageColor3",
	},

	Colors = { -- Color shortcuts: you can use these strings instead of defining exact color values
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
		Red = Color3.new(1, 0.4, 0.4),
		Green = Color3.new(0.4, 1, 0.4),
		Blue = Color3.new(0.4, 0.4, 1),
		Cyan = Color3.new(0.4, 0.85, 1),
		Orange = Color3.new(1, 0.5, 0.2),
		Yellow = Color3.new(1, 0.9, 0.2),

		Pink = Color3.fromHex("#ee3d96"),
		Purple = Color3.fromHex("#583599"),
	},

	Images = { -- Image shortcuts: you can use these string instead of using image ids
		Eggplant = 639588687,
		Thinking = 955646496,
		Sad = 947900188,
		Happy = 414889555,
		Despicable = 711674643,
	},
}

local DEFAULTS = {
	--Text alignment default properties
	ContainerHorizontalAlignment = "Left", -- Align,ent of text within frame container
	ContainerVerticalAlignment = "Top",
	TextYAlignment = "Bottom", -- Alignment of the text on the line, only makes a difference if the line has variable text sizes

	-- Text size default properties
	TextScaled = true,
	TextScaleRelativeTo = "Frame", -- "Frame" or "Screen" If Frame, will scale relative to vertical size of the parent frame. If Screen, will scale relative to vertical size of the ScreenGui.
	TextScale = 0.35, -- If you want the frame to have a nominal count of n lines of text, make this value 1 / n. For four lines, 1 / 4 = 0.25.
	TextSize = 20, -- Only applicable if TextScaled = false

	-- TextLabel default properties
	Font = "Nunito",
	-- FontWeight = Enum.FontWeight.Regular,
	TextColor3 = "Purple",
	TextStrokeColor3 = "Black",
	TextTransparency = 0,
	TextStrokeTransparency = 1,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,

	-- Image label default properties
	ImageColor3 = "White",
	ImageTransparency = 0,
	ImageRectOffset = "0,0",
	ImageRectSize = "0,0",

	-- Text animation default properties
	-- character appearance timing:
	AnimateStepTime = 0.035, -- Seconds between newframes
	AnimateStepGrouping = "Letter", -- "Word" or "Letter" or "All"
	AnimateStepFrequency = 4, -- How often to step, 1 is all, 2 is step in pairs, 3 is every three, etc.
	-- yielding:
	AnimateYield = 0, -- Set this markup to yield
	-- entrance style parameters:
	AnimateStyle = "Appear",
	AnimateStyleTime = 1, -- How long it takes for an entrance style to fully execute
	AnimateStyleNumPeriods = 3, -- Used differently for each entrance style
	AnimateStyleAmplitude = 0.5, -- Used differently for each entrance style
}

local function GetColorFromString(value: string): Color3
	if SHORT_CUTS.Colors[value] then
		return SHORT_CUTS.Colors[value]
	else
		local r: string?, g: string?, b: string? = value:match("(%d+),(%d+),(%d+)")
		return Color3.new((tonumber(r) or 255) / 255, (tonumber(g) or 255) / 255, (tonumber(b) or 255) / 255)
	end
end

local function GetLayerCollector(frame: Instance): LayerCollector?
	if not frame then
		return nil
	elseif frame:IsA("LayerCollector") then
		return frame
	elseif frame and frame.Parent then
		return GetLayerCollector(frame.Parent)
	else
		return nil
	end
end

local function ShallowCopy(tab: { [string]: any }): { [string]: any }
	local ret: { [string]: any } = {}
	for key: string, value: any in pairs(tab) do
		ret[key] = value
	end
	return ret
end

local function GetVector2FromString(value: string): Vector2?
	local x: string?, y: string? = value:match("(%d+),(%d+)")
	return Vector2.new(tonumber(x), tonumber(y))
end

local function SetHorizontalAlignment(frame: GuiObject, alignment: "Left" | "Center" | "Right")
	if alignment == "Left" then
		frame.AnchorPoint = Vector2.new(0, 0)
		frame.Position = UDim2.new(0, 0, 0, 0)
	elseif alignment == "Center" then
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.new(0.5, 0, 0, 0)
	elseif alignment == "Right" then
		frame.AnchorPoint = Vector2.new(1, 0)
		frame.Position = UDim2.new(1, 0, 0, 0)
	end
end

return {
	GetColorFromString = GetColorFromString,
	GetLayerCollector = GetLayerCollector,
	ShallowCopy = ShallowCopy,
	SetHorizontalAlignment = SetHorizontalAlignment,
	GetVector2FromString = GetVector2FromString,

	SHORT_CUTS = SHORT_CUTS,
	DEFAULTS = DEFAULTS,
}
