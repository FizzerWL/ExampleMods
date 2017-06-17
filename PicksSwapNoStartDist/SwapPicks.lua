function SwapPicks(game, standing)
	local playersSet = {}
	for _, territory in pairs(standing.Territories) do
		if (not territory.IsNeutral) then
			playersSet[territory.OwnerPlayerID] = true
		end
	end
	
	local playersTable = {}
	local n = 0;
	for key, _ in pairs(playersSet) do
		playersTable[n] = key
		n = n + 1;
	end
	
	-- only with 2 players
	if (n ~= 2) then 
		return 
	end
	
	for _, territory in pairs(standing.Territories) do
		if (territory.OwnerPlayerID == playersTable[0]) then 
			territory.OwnerPlayerID = playersTable[1] 
		elseif (territory.OwnerPlayerID == playersTable[1]) then
			territory.OwnerPlayerID = playersTable[0] 
		end
	end
end
