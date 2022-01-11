local TheReturned = require('TheReturned/TheReturned_Main')

local BaseGameCharacterDetails_DoProfessions = BaseGameCharacterDetails.DoProfessions

function BaseGameCharacterDetails.DoProfessions()
	local prof = ProfessionFactory.addProfession(TheReturned.trait, getText('UI_prof_returner'), '', 0)
	prof:setDescription('Respawn with same skills and traits.')

	TheReturned.createRespawnTrait()
	prof:addFreeTrait(TheReturned.trait)

	BaseGameCharacterDetails.SetProfessionDescription(prof)
	BaseGameCharacterDetails_DoProfessions(self)
end

function CharacterCreationProfession:resetBuild()
	local index = 1

	while self.listboxProf.items[index].item:getType() ~= 'unemployed' do
		index = index + 1
	end

	self.listboxProf.selected = index
	self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item)

	while #self.listboxTraitSelected.items > 0 do
		self.listboxTraitSelected.selected = 1
		self:onOptionMouseDown(self.removeTraitBtn)
	end
end

Events.OnCreatePlayer.Add(TheReturned.OnCreatePlayer)
--Events.OnGameStart.Add(TheReturned.OnGameStart)
Events.OnPlayerDeath.Add(TheReturned.OnPlayerDeath)
