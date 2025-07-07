local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

export type Answer = {
	Text: string,
	ResponseId: string,
}

export type Line = {
	Pre: () -> { any },
	Text: { [string]: string }?,
	Answers: { Answer }?,
	Mid: ((data: { any }) -> { any })?,
	Responses: { [string]: Line }?,
	Post: (data: { [any]: any }) -> (),
}

local Dialogues: { [string]: { Line } } = {
	Jelly_Tutorial = {
		{
			Pre = function()
				local data = {
					-- camera = workspace.CurrentCamera,
					-- dialogueModel = workspace.PlayPlace:WaitForChild("Dialogues"),
				}
				-- if data.dialogueModel and data.dialogueModel:IsA("Model") then
				-- 	data.JellyTutorial = data.dialogueModel:WaitForChild("Jelly_Tutorial")
				-- 	data.focusPart1 = data.JellyTutorial:WaitForChild("FocusPart1")
				-- 	data.focusPart2 = data.JellyTutorial:WaitForChild("FocusPart2")
				-- 	data.firstPosition = data.JellyTutorial:WaitForChild("CamPos1")
				-- 	data.secondPosition = data.JellyTutorial:WaitForChild("CamPos2")

				-- 	RunService:BindToRenderStep("DIALOGUE_1", Enum.RenderPriority.First.Value, function()
				-- 		data.camera.CameraType = Enum.CameraType.Scriptable
				-- 	end)
				-- end
				return data
			end,
			Mid = function(data)
				-- local tweenInfo1 = TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, false)
				-- local sequence1 = TweenService:Create(
				-- 	data.camera,
				-- 	tweenInfo1,
				-- 	{ CFrame = CFrame.lookAt(data.firstPosition.Position, data.focusPart1.Position) }
				-- )

				-- local tweenInfo2 = TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, false)
				-- local sequence2 = TweenService:Create(
				-- 	data.camera,
				-- 	tweenInfo2,
				-- 	{ CFrame = CFrame.lookAt(data.secondPosition.Position, data.focusPart2.Position) }
				-- )
				-- sequence1:Play()
				-- sequence1.Completed:Wait()
				-- sequence2:Play()
				-- sequence2.Completed:Wait()
			end,
			Text = {
				GLOBAL = "Welcome to the Jelly Land, your task is to building your path to the end of the obby",
				MENA = "مرحباً بكم في جنة تشوبا تشوبس كاندي لاند! أنا مرشدك. استعدوا لرش بعض المرح الحلو في رحلتكم!",
			},

			Post = function()
				-- RunService:UnbindFromRenderStep("DIALOGUE_1")
			end,
		},
	},
}

return Dialogues
