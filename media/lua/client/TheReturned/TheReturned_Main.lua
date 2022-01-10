local TheReturned = {}

TheReturned.id = 'TheReturned'

function TheReturned.savePlayerData(player)
	local modData = player:getModData()[TheReturned.id]
	modData.levels = TheReturned.levels
	modData.boosts = TheReturned.boosts
	player:transmitModData()
end

function TheReturned.loadPlayerData(player)
	local modData = player:getModData():getOrCreate(TheReturned.id)
	TheReturned.levels = modData.levels or {}
	TheReturned.boosts = modData.boosts or {}
end

function TheReturned.setPlayerTraits(player)

    local traits = TheReturned.Traits

    for i = 0, traits:size() - 1 do
        player:getTraits():add(traits:get(i))
    end
end

function TheReturned.setPlayerLevels(player)

    for perk, level in pairs(TheReturned.levels) do
        local perkLevel = player:getPerkLevel(perk)

        while perkLevel ~= level do
            if perkLevel < level then
                player:LevelPerk(perk, false)
                perkLevel = perkLevel + 1
            else
                player:LoseLevel(perk)
                perkLevel = perkLevel - 1
            end
            
            player:getXp():setXPToLevel(perk, perkLevel)
        end
    end
end

function TheReturned.setPlayerBoosts(player)

    local prof = ProfessionFactory.getProfession(TheReturned.Id)

    for perk, boost in pairs(TheReturned.boosts) do
        prof:addXPBoost(perk, boost)
    end

    player:getDescriptor():setProfessionSkills(prof)
end

function TheReturned.createPlayerRespawnTrait()

	local trait = TraitFactory.addTrait('Returner', getText('UI_trait_Returner'), 0, getText('Returns from the dead.'), true, false)
	local traits = TraitFactory.getTraits()

	for i = 0, traits:size() - 1 do
		TraitFactory.setMutualExclusive(TheReturned.id, traits:get(i):getType())
	end
end

function TheReturned.updatePlayerTraits(player)
	TheReturned.Traits = player:getTraits()
end

function TheReturned.updatePlayerLevels(player)

	local perks = PerkFactory.PerkList

	for i = 0, perks:size() - 1 do
		local perk = perks:get(i)
		
		TheReturned.levels[perk] = player:getPerkLevel(perk)
	end
end

function TheReturned.updatePlayerBoosts(player)

	local perks = PerkFactory.PerkList
	local boosts = player:getXp()

	for i = 0, perks:size() - 1 do
		local perk = perks:get(i)
		
		TheReturned.boosts[perk] = boosts:getPerkBoost(perk)
	end
end

function TheReturned.OnCreatePlayer(id, player)

    if player:HasTrait(TheReturned.Id) then
		TheReturned.setPlayerTraits(player)
		TheReturned.setPlayerLevels(player)
		TheReturned.setPlayerBoosts(player)
		TheReturned.savePlayerData(player)
    end
end

function TheReturned.OnGameStart()
	TheReturned.loadPlayerData(getPlayer())
end

function TheReturned.OnPlayerDeath(player)

    if player:HasTrait(TheReturned.Id) then
		TheReturned.updatePlayerTraits(player)
		TheReturned.updatePlayerLevels(player)
		TheReturned.updatePlayerBoosts(player)
		TheReturned.savePlayerData(player)
	end
end

return TheReturned
