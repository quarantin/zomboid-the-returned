local TheReturned = require("TheReturned/TheReturned")

TheReturned.DoTraits = BaseGameCharacterDetails.DoTraits
function BaseGameCharacterDetails.DoTraits()
	TheReturned.DoTraits()
	TheReturned.AddTrait()
end

TheReturned.DoProfessions = BaseGameCharacterDetails.DoProfessions
function BaseGameCharacterDetails.DoProfessions()
	TheReturned.AddProfession()
	TheReturned.DoProfessions()
end

TheReturned.clickNext = ServerList.clickNext
function ServerList.clickNext(self)
	print("DEBUG: ServerList.clickNext")
	TheReturned.currentServer = self.listbox.items[self.listbox.selected].item.server
	TheReturned.clickNext(self)
end

function CharacterCreationProfession:resetBuild()
    local index = 1;

    while self.listboxProf.items[index].item:getType() ~= "unemployed" do
        index = index + 1;
    end

    self.listboxProf.selected = index;
    self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);

    while #self.listboxTraitSelected.items > 0 do
        self.listboxTraitSelected.selected = 1;
        self:onOptionMouseDown(self.removeTraitBtn);
    end
end

BaseGameCharacterDetails.DoTraits()
BaseGameCharacterDetails.DoProfessions()
