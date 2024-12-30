require("Utilities");

function Server_StartGame(game, standing)
	if (not game.Settings.AutomaticTerritoryDistribution) then return; end;  --We only work in Automatic Distribution

    local bonusesToExcludeDict = {};
    for _, bonusName in pairs(ParseCommaDelimitedString(Mod.Settings.BonusesToExclude)) do
        bonusesToExcludeDict[bonusName] = 1;
    end

	-- Loop through all bonuses we've been instructed to exclude
	for _, bonus in pairs(game.Map.Bonuses) do
		if (bonusesToExcludeDict[bonus.Name] ~= nil) then 
			for _, territoryID in pairs(bonus.Territories) do --loop through each territory in this bonus
				if (standing.Territories[territoryID].OwnerPlayerID ~= WL.PlayerID.Neutral) then 
					--This is a territiory in a bonus we've been instructed to exclude, so move it to another bonus
					MoveTerritory(game, standing, territoryID, bonusesToExcludeDict);
				end
			end
		end
	end
end

function BonusIsCompletelyNeutral(standing, bonus)
	for _, territoryID in pairs(bonus.Territories) do
		if (standing.Territories[territoryID].OwnerPlayerID ~= WL.PlayerID.Neutral) then
			return false;
		end
	end
	return true;
end

function MoveTerritory(game, standing, territoryIDFrom, bonusesToExcludeDict)

	-- Find bonuses we could move to
	local possibleBonuses = {}
	for _, bonus in pairs(game.Map.Bonuses) do
		if (bonusesToExcludeDict[bonus.Name] == nil and BonusIsCompletelyNeutral(standing, bonus)) then
			table.insert(possibleBonuses, bonus.ID);
		end
	end

	if (#possibleBonuses == 0) then return; end; --no possible bonus to move to

	local bonusID = randomFromArray(possibleBonuses);

	--Pick a random territory in the bonus
	local territoryIDTo = randomFromArray(game.Map.Bonuses[bonusID].Territories);

	--Move us
	local armiesBefore = standing.Territories[territoryIDTo].NumArmies;
	standing.Territories[territoryIDTo].OwnerPlayerID = standing.Territories[territoryIDFrom].OwnerPlayerID;
	standing.Territories[territoryIDTo].NumArmies = standing.Territories[territoryIDFrom].NumArmies;
	standing.Territories[territoryIDFrom].OwnerPlayerID = WL.PlayerID.Neutral;
	standing.Territories[territoryIDFrom].NumArmies = armiesBefore;
	print("Swapped " .. territoryIDFrom .. ' to ' .. territoryIDTo);
end

