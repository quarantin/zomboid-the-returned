local TheReturned = {}

TheReturned.modId = 'TheReturned'
TheReturned.trait = 'Returned'
TheReturned.profession = 'returner'

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

function TheReturned.getPlayerData(player)

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

	return playerData
end

function TheReturned.setPlayerData(player, playerData)

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
end

function TheReturned.DoProfessions()

	TraitFactory.addTrait(TheReturned.trait, getText("UI_trait_Returned"), 0, getText("UI_trait_ReturnedDesc"), true, false)

	local traits = TraitFactory.getTraits()
	for i = 0, traits:size() - 1 do
		TraitFactory.setMutualExclusive(TheReturned.trait, traits:get(i):getType())
	end

	local prof = ProfessionFactory.addProfession(TheReturned.profession, getText("UI_prof_returner"), 'profession_' .. TheReturned.profession, 0)
	prof:addFreeTrait(TheReturned.trait)
end

BaseGameCharacterDetails.originalDoProfessions = BaseGameCharacterDetails.DoProfessions
function BaseGameCharacterDetails.DoProfessions()
	TheReturned.DoProfessions()
	BaseGameCharacterDetails.originalDoProfessions()
end

function TheReturned.OnGameBoot()
	ProfessionFactory.Reset()
	BaseGameCharacterDetails.DoProfessions()
end

function TheReturned.OnCreatePlayer(playerId, player)

	local modData = ModData.get(TheReturned.modId)
	if modData then

		local playerData = modData[getCurrentUserSteamID()]
		if playerData and player:HasTrait(TheReturned.trait) then
			TheReturned.setPlayerData(player, playerData)
		end

	end
end

function TheReturned.OnPlayerDeath(player)
	local modData = ModData.getOrCreate(TheReturned.modId)
	modData[getCurrentUserSteamID()] = TheReturned.getPlayerData(player)
	ModData.transmit(TheReturned.modId)
end

Events.OnGameBoot.Add(TheReturned.OnGameBoot)
Events.OnCreatePlayer.Add(TheReturned.OnCreatePlayer)
Events.OnPlayerDeath.Add(TheReturned.OnPlayerDeath)
