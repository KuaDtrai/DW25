--!strict

export type Item = {
	Name: string,
	Weight: number,
}

export type Items = { Item }

local function GetTotalWeightOfLootTable(items: Items): number
	local weight: number = 0
	for _, item in pairs(items) do
		weight += item.Weight
	end

	return weight
end

local function GetRandomItemFromLootTable(items: Items): string?
	local randomizer: Random = Random.new()
	local totalWeight: number = GetTotalWeightOfLootTable(items)
	local randomNumber: number = randomizer:NextNumber(0, totalWeight)

	for _, entry: Item in pairs(items) do
		if randomNumber <= entry.Weight then
			return entry.Name
		else
			randomNumber = randomNumber - entry.Weight
		end
	end

	return
end

local function ShuffleArray(array: { any }): { any }
	-- fisher-yates
	local output: { any } = {}
	for index = 1, #array do
		local offset: number = index - 1
		local value: any = array[index]
		local randomIndex: number = offset * math.random()

		local flooredIndex: number = randomIndex - randomIndex % 1

		if flooredIndex == offset then
			output[#output + 1] = value
		else
			output[#output + 1] = output[flooredIndex + 1]
			output[flooredIndex + 1] = value
		end
	end

	return output
end

local function GeneratePercentageFromLootTable(items: Items)
	local testItem = {}
	-- creates x amount items
	local count: number = 10000 -- reduce this count if you get lag when trying to run this
	for _ = 1, count do
		local randomItem: string? = GetRandomItemFromLootTable(items)
		testItem[randomItem] = testItem[randomItem] and (testItem[randomItem] :: number) + 1 or 1
	end

	-- converted to percentage
	local percentage: number = 0
	for i: string, v: number in pairs(testItem) do
		local number = math.floor(v / count * 100 * 100) / 100
		percentage += number
		-- print(i, tostring(number) .. "%")
	end
	-- print("Total:", percentage .. "%")
end

return {
	ShuffleArray = ShuffleArray,
	GetRandomItemFromLootTable = GetRandomItemFromLootTable,
	GeneratePercentageFromLootTable = GeneratePercentageFromLootTable,
}
