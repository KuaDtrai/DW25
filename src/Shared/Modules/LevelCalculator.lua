function LevelToXP(
	level: number,
	customBaseXp: number?,
	customInitialGrowthRate: number?,
	customGrowthRateIncrease: number?
): number?
	local baseXp: number = customBaseXp or 100
	local initialGrowthRate: number = customInitialGrowthRate or 1.5
	local growthRateIncrease: number = customGrowthRateIncrease or 0.05

	if level < 2 then
		if level == 1 then
			return 0 -- Return 0 XP for level 1
		else
			return nil -- Return nil for level 0 or negative levels
		end
	end

	-- Calculate the growth rate for the current level
	local growthRate: number = initialGrowthRate + (growthRateIncrease * (level - 2))
	local xpForLevel: number = baseXp * (growthRate ^ (level - 2))

	return math.floor(xpForLevel) -- Round down to the nearest whole number
end

local function XPToLevel(xp: number): number
	local level: number = 1
	while xp >= LevelToXP(level) do
		level = level + 1
	end
	return level - 1 -- Subtract 1 because the loop exits when xp is less than the xp required for the next level
end

return {
	XPToLevel = XPToLevel,
	LevelToXP = LevelToXP,
}
