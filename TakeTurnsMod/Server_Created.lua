require('Utilities');

function Server_Created(game, settings)
	--Turn on sanctions card.  Ensure its weight is 0 so players never get it.  This means that the sanctions card can't be used normally by the game creator.  https://www.warzone.com/wiki/Mod_API_Reference:CardGameSanctions
	local cards = BuildMetatable(settings.Cards);
	cards[WL.CardID.Sanctions] = WL.CardGameSanctions.Create(2, 0, 0, 1, 1, 1);
	settings.Cards = cards;
end

