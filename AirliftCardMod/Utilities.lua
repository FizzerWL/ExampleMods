
--This mod uses UI images, snapshots, button icons, and the Client_Visual hook, which older versions of the app don't have.
RequiredVersion = "6.06.0";

function startsWith(str, sub)
	return string.sub(str, 1, string.len(sub)) == sub;
end

--The card's play order carries its choices in ModData, which is just a string.  We store the source, destination, and number of armies in it.
function MakeAirliftModData(sourceID, destID, numArmies)
	--Format as integers, since a number that came from a slider could otherwise turn into something like "5.0"
	return string.format("Airlift_%d_%d_%d", sourceID, destID, math.floor(numArmies));
end

--Returns sourceID, destID, numArmies, or nil if this isn't our card's ModData
function ParseAirliftModData(modData)
	if (modData == nil) then return nil; end
	local source, dest, armies = string.match(modData, "^Airlift_(%d+)_(%d+)_(%d+)$");
	if (source == nil) then return nil; end
	return tonumber(source), tonumber(dest), tonumber(armies);
end

--True if the other player is on the same team as the player.  Players with no team are never teammates.
--We ask the game for each player's team, passing the current standing, since teams can be changed during a game by mods.
function IsTeammate(game, standing, playerID, otherPlayerID)
	if (game.Game.Players[playerID] == nil or game.Game.Players[otherPlayerID] == nil) then return false; end --neutral
	local team = game.Game.PlayerTeam(playerID, standing);
	if (team == nil or team == -1) then return false; end
	return team == game.Game.PlayerTeam(otherPlayerID, standing);
end
