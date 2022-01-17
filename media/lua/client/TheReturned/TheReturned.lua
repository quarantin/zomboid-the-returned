local TheReturned = {}

TheReturned.modId = "TheReturned"
TheReturned.trait = "Returned"
TheReturned.profession = "returned"

function TheReturned.getBoostLevel(level)

	if level == 0 then
		return 1
	end

	if level % 2 == 0 then
		return level - 1
	end

	return level
end

function TheReturned.toHashMap(table)

	local hashmap = HashMap.new()

	for k, v in pairs(table) do
		hashmap:put(k, v)
	end

	return hashmap
end

function TheReturned.debugPlayerData(playerData)

	for k, v in pairs(playerData) do
		print('DEBUG: THE RETURNED: ' .. tostring(k) .. " " .. tostring(v))
		if type(v) == 'table' then
			for i, j in pairs(v) do
				print('DEBUG: THE RETURNED:     - ' .. tostring(i) .. " " .. tostring(j))
				if type(j) == 'table' then
					for m, n in pairs(j) do
						print('DEBUG: THE RETURNED:         - ' .. tostring(m) .. " " .. tostring(n))
					end
				end
			end
		end
	end
end

function TheReturned.getPlayerData(player)

	if TheReturned.currentServer then
		for k, v in pairs(TheReturned.currentServer) do
			print("DEBUG: " .. tostring(k) .. " = " .. tostring(v))
		end
	end

	local playerData = {}

	playerData.perks = {}
	playerData.traits = {}
	playerData.modData = player:getModData()
	playerData.zombieKills = player:getZombieKills()
	playerData.hoursSurvived = player:getHoursSurvived()
	playerData.profession = player:getDescriptor():getProfession()
	playerData.weight = player:getNutrition():getWeight()
	playerData.regularityMap = transformIntoKahluaTable(player:getFitness():getRegularityMap())

	local xp = player:getXp()
	local perks = PerkFactory.PerkList
	local traits = player:getTraits()

	for i = 0, perks:size() - 1 do

		local perk = perks:get(i)
		local perkName = PerkFactory.getPerkName(perk)
		local perkLevel = player:getPerkLevel(perk)
		local boostLevel = TheReturned.getBoostLevel(perkLevel)

		playerData.perks[perkName] = {
			level = perkLevel,
			minLevel = boostLevel,
			maxLevel = boostLevel + 1,
			boost = xp:getMultiplier(perk),
		}
	end

	for i = 0, traits:size() - 1 do
		table.insert(playerData.traits, traits:get(i))
	end

	TheReturned.debugPlayerData(playerData)
	return playerData
end

function TheReturned.setPlayerData(player, playerData)

	TheReturned.debugPlayerData(playerData)

	player:setTable(playerData.modData)
	player:setZombieKills(playerData.zombieKills)
	player:setHoursSurvived(playerData.hoursSurvived)
	player:getDescriptor():setProfession(playerData.profession)
	player:getNutrition():setWeight(playerData.weight)
	player:getFitness():setRegularityMap(TheReturned.toHashMap(playerData.regularityMap))

	local xp = player:getXp()

	for perkName, perkData in pairs(playerData.perks) do

		local perk = PerkFactory.getPerkFromName(perkName)

		for level = 1, perkData.level do
			local perkLevel = player:getPerkLevel(perk)
			if level > perkLevel then
				player:LevelPerk(perk)
				xp:setXPToLevel(perk, perkData.level)
			end
		end

		xp:addXpMultiplier(perk, perkData.boost, perkData.minLevel, perkData.maxLevel)
	end

	local traits = player:getTraits()
	traits:clear()
	for _, trait in pairs(playerData.traits) do
		traits:add(trait)
	end

	player:transmitModData()
	sendPlayerStatsChange(player)
	if getWorld():getGameMode() == "Multiplayer" then
		print("DEBUG: THE RETURNED: SENDING PLAYER EXTRA INFO!")
		sendPlayerExtraInfo(player)
	else
		print("DEBUG: THE RETURNED: NOT SENDING PLAYER EXTRA INFO!")
	end
end

function TheReturned.AddTrait()

	TraitFactory.addTrait(TheReturned.trait, getText("UI_trait_Returned"), 0, getText("UI_trait_ReturnedDesc"), true)

	local traits = TraitFactory.getTraits()
	for i = 0, traits:size() - 1 do
		TraitFactory.setMutualExclusive(TheReturned.trait, traits:get(i):getType())
	end
end

function TheReturned.AddProfession()

	local prof = ProfessionFactory.addProfession(TheReturned.profession, getText("UI_prof_" .. TheReturned.profession), "profession_" .. TheReturned.profession, 0)

	prof:addFreeTrait(TheReturned.trait)
end

return TheReturned
