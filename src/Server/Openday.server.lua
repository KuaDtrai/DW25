--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Openday = require(ReplicatedStorage.Shared.Openday)

Openday:AddSystems(ServerScriptService.Systems)
Openday:AddExtensions(ServerScriptService.Extensions.Standards, "Standard")

Openday:Start()
	:Then(function()
		warn("🦀| Openday Server loaded!")
	end)
	:Catch(warn)
	:Await()
