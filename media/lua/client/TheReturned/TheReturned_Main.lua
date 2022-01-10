local TheReturned = {}

TheReturned.id = 'TheReturned'
TheReturned.traitId = 'Returner'
TheReturned.traitName = 'Returner name'
TheReturned.traitDesc = 'Returner desc'
TheReturned.professionId = 'returner'
TheReturned.professionName = 'Returner'

function TheReturned.getBoostLevel(level)

	if level == 0 then
		return 1
	end

	if level % 2 == 0 then
		return level - 1
	end

	return level
end

function TheReturned.getPlayerData(player)

	local playerData = {}

	playerData.perks = {}
	playerData.traits = {}
	playerData.profession = player:getDescriptor():getProfession()

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

	player:getDescriptor():setProfession(playerData.profession)

	local xp = player:getXp()
	local traits = player:getTraits()

	for perkName, perkData in pairs(playerData.perks) do

		local perk = PerkFactory.getPerkFromName(perkName)

		for i = 1, perkData.level do
			player:LevelPerk(perk)
		end

		xp:addXpMultiplier(perk, perkData.boost, perkData.minLevel, perkData.maxLevel)
	end

	traits:clear()
	for _, trait in pairs(playerData.traits) do
		traits:add(trait)
	end
end

function TheReturned.DoProfessions()

	TraitFactory.addTrait(TheReturned.traitId, TheReturned.traitName, 0, TheReturned.traitDesc, true, false)

	local traits = TraitFactory.getTraits()
	for i = 0, traits:size() - 1 do
		TraitFactory.setMutualExclusive(TheReturned.traitId, traits:get(i):getType())
	end

	local prof = ProfessionFactory.addProfession(TheReturned.professionId, TheReturned.professionName, "", 0)
	prof:addFreeTrait(TheReturned.traitId)
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

	local modData = ModData.get(TheReturned.id)
	if modData then

		local playerData = modData[getCurrentUserSteamID()]
		if playerData and player:HasTrait(TheReturned.traitId) then
			TheReturned.setPlayerData(player, playerData)
		end

	end
end

function TheReturned.OnPlayerDeath(player)
	local modData = ModData.getOrCreate(TheReturned.id)
	modData[getCurrentUserSteamID()] = TheReturned.getPlayerData(player)
	ModData.transmit(TheReturned.id)
end

Events.OnGameBoot.Add(TheReturned.OnGameBoot)
Events.OnCreatePlayer.Add(TheReturned.OnCreatePlayer)
Events.OnPlayerDeath.Add(TheReturned.OnPlayerDeath)
