require('SwapPicks')

function Server_StartGame(game, standing)

	-- only with manual picking
	if (not game.Settings.AutomaticTerritoryDistribution) then
		SwapPicks(game, standing);
	end


end

