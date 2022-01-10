require('DistributeCities')

function Server_StartGame(game, standing)

	--Don't do anything in StartGame if we're a manual dist game (the cities would already have been distributed in Server_StartDistribution)
	if (game.Settings.AutomaticTerritoryDistribution) then
		DistributeCities(game, standing);
	end


end

