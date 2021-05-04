require('Utilities');

function HasCommander(territory)
	return #territory.NumArmies.SpecialUnits ~= 0;
end

function NumTerritoriesToSwap(terrs)
	--Return Mod.Settings.NumTerritories, unless at least one player doesn't have that many swappable terrs, in which case return smallest player's number of territories
	local ret = Mod.Settings.NumTerritories;
	for playerID, playerTerrs in pairs(terrs) do
		if #playerTerrs < ret then ret = #playerTerrs; end
	end
	return ret;
end

-- Gets the index after i from tbl.  If i is the last index, returns the first item in tbl.
function GetNextWrapped(tbl, i)
	if i >= #tbl then 
		return tbl[1];
	else
		return tbl[i + 1];
	end
end

function CreateTerritoryMod(terrID, newOwner)
	local mod = WL.TerritoryModification.Create(terrID);
	mod.SetOwnerOpt = newOwner;
	return mod;
end

function Server_AdvanceTurn_End(game, addNewOrder)
	-- do nothing if we fail the random check
	if math.random() > Mod.Settings.Percentage / 100 then return; end

	-- gather all territories owned by players, skipping those with a commander
	local terrs = {};

	for _, territory in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if territory.OwnerPlayerID ~= WL.PlayerID.Neutral and not HasCommander(territory) then
			if terrs[territory.OwnerPlayerID] == nil then terrs[territory.OwnerPlayerID] = {}; end
			table.insert(terrs[territory.OwnerPlayerID], territory.ID);
		end
	end

	-- Collect a table of just the player IDs
	local playerIDs = {};
	for playerID, _ in pairs(terrs) do table.insert(playerIDs, playerID); end;

	-- Randomize order of players, in case there's more than 2 we want to swap randomly
	shuffle(playerIDs);

	-- Randomize order of territories so it's random which are swapped
	for playerID, playerTerrs in pairs(terrs) do
		shuffle(playerTerrs);
	end


	local mods = {};

	if Mod.Settings.NumTerritories == 0 then
		SwapAll(playerIDs, terrs, mods);
	else
		local numSwaps = NumTerritoriesToSwap(terrs);
		for i=1,numSwaps do
			-- Swap the territories at index i
			for p=1,#playerIDs do
				local pid1 = playerIDs[p];
				local pid2 = GetNextWrapped(playerIDs, p);
				table.insert(mods, CreateTerritoryMod(terrs[pid1][i], pid2));
			end
		end
	end

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "Swap territories!", {}, mods));

end


function SwapAll(playerIDs, terrs, mods) 
	for p=1,#playerIDs do
		local pid1 = playerIDs[p];
		local pid2 = GetNextWrapped(playerIDs, p);

		for _, territoryID in pairs(terrs[pid1]) do
			table.insert(mods, CreateTerritoryMod(territoryID, pid2));
		end
	end
end