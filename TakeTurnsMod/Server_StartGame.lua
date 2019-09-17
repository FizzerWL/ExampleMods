
--When the game starts, take all of the playing players, randomize their order, and store this into Mod.PublicGameData
function Server_StartGame(game, standing)
	--Store all player IDs in a list
	local pids = {};
	for pid,_ in pairs(game.Game.PlayingPlayers) do
		pids[#pids+1] = pid;
	end

	--to randomly sort fairly, generate a random number for each player and then sort by that.
	local rnd = {};
	for _,pid in pairs(pids) do
		rnd[pid] = math.random();
	end
	table.sort(pids, function(a,b) return rnd[a] < rnd[b] end);

	local gameData = Mod.PublicGameData;
	gameData.PlayerOrder = pids;
	Mod.PublicGameData = gameData;
end

