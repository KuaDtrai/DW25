--!strict
local Utility = require(script.Parent.Parent.Utility)
--------- ENTRANCE ANIMATION FUNCTIONS ---------

-- These are functions responsible for animating how text enters. The functions are passed:
-- characters: A list of the characters to be animated.
-- animateAlpha: A value of 0 - 1 that represents the lifetime of the animation
-- properties: A dictionary of all the properties at that character, including InitialSize and InitialPosition

local Styles = {}

function Styles.Appear(character: GuiObject)
	character.Visible = true
end

function Styles.Fade(
	character: GuiObject,
	animateAlpha: number,
	properties: { TextTransparency: number?, ImageTransparency: number? }
)
	character.Visible = true
	if character:IsA("TextLabel") and properties.TextTransparency then
		character.TextTransparency = 1 - (animateAlpha * (1 - properties.TextTransparency))
	elseif character:IsA("ImageLabel") and properties.ImageTransparency then
		character.ImageTransparency = 1 - (animateAlpha * (1 - properties.ImageTransparency))
	end
end

function Styles.Wiggle(
	character: GuiObject,
	animateAlpha: number,
	properties: {
		InitialPosition: UDim2,
		InitialSize: UDim2,
		AnimateStyleNumPeriods: number,
		AnimateStyleAmplitude: number,
	}
)
	character.Visible = true
	local amplitude: number = properties.InitialSize.Y.Offset * (1 - animateAlpha) * properties.AnimateStyleAmplitude
	character.Position = properties.InitialPosition
		+ UDim2.new(0, 0, 0, math.sin(animateAlpha * math.pi * 2 * properties.AnimateStyleNumPeriods) * amplitude / 2)
end

function Styles.Swing(
	character: GuiObject,
	animateAlpha: number,
	properties: {
		AnimateStyleNumPeriods: number,
		AnimateStyleAmplitude: number,
	}
)
	character.Visible = true
	local amplitude = 90 * (1 - animateAlpha) * properties.AnimateStyleAmplitude
	character.Rotation = math.sin(animateAlpha * math.pi * 2 * properties.AnimateStyleNumPeriods) * amplitude
end

function Styles.Spin(
	character: GuiObject,
	animateAlpha: number,
	properties: { InitialPosition: UDim2, InitialSize: UDim2, AnimateStyleNumPeriods: number }
)
	character.Visible = true
	character.Position = properties.InitialPosition
		+ UDim2.new(0, properties.InitialSize.X.Offset / 2, 0, properties.InitialSize.Y.Offset / 2)
	character.AnchorPoint = Vector2.new(0.5, 0.5)
	character.Rotation = animateAlpha * properties.AnimateStyleNumPeriods * 360
end

function Styles.Rainbow(
	character: TextLabel | ImageLabel,
	animateAlpha: number,
	properties: { AnimateStyleNumPeriods: number, TextColor3: string?, ImageColor3: string? }
)
	local rainbowColor: Color3 = Color3.fromHSV(animateAlpha * properties.AnimateStyleNumPeriods % 1, 1, 1)
	if character:IsA("TextLabel") and properties.TextColor3 then
		character.Visible = true
		local initialColor: Color3 = Utility.GetColorFromString(properties.TextColor3)
		character.TextColor3 = Color3.new(
			rainbowColor.R + animateAlpha * (initialColor.R - rainbowColor.R),
			rainbowColor.G + animateAlpha * (initialColor.G - rainbowColor.G),
			rainbowColor.B + animateAlpha * (initialColor.B - rainbowColor.B)
		)
	elseif character:IsA("ImageLabel") and properties.ImageColor3 then
		character.Visible = true
		local initialColor: Color3 = Utility.GetColorFromString(properties.ImageColor3)
		character.ImageColor3 = Color3.new(
			rainbowColor.R + animateAlpha * (initialColor.R - rainbowColor.R),
			rainbowColor.G + animateAlpha * (initialColor.G - rainbowColor.G),
			rainbowColor.B + animateAlpha * (initialColor.B - rainbowColor.B)
		)
	end
end

return Styles
