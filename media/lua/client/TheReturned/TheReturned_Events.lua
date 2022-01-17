local TheReturned = require("TheReturned/TheReturned")

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

Events.OnCreatePlayer.Add(TheReturned.OnCreatePlayer)
Events.OnPlayerDeath.Add(TheReturned.OnPlayerDeath)
