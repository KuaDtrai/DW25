--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Openday = require(ReplicatedStorage.Shared.Openday)

Openday:AddSystems(ReplicatedStorage.Controllers.Systems)
Openday:AddExtensions(ReplicatedStorage.Controllers.Extensions.Standards, "Standard")

Openday:Start()
	:Then(function()
		warn("🦀| Openday Client loaded!")
	end)
	:Catch(warn)
	:Await()
