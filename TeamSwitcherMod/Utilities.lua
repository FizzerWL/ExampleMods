
--The team ID that Warzone uses to mean "this player isn't on a team"
NoTeam = -1;

function map(array, func)
	local new_array = {};
	local i = 1;
	for _,v in pairs(array) do
		new_array[i] = func(v);
		i = i + 1;
	end
	return new_array;
end

function filter(array, func)
	local new_array = {};
	local i = 1;
	for _,v in pairs(array) do
		if (func(v)) then
			new_array[i] = v;
			i = i + 1;
		end
	end
	return new_array;
end

function first(array, func)
	for _,v in pairs(array) do
		if (func == nil or func(v)) then
			return v;
		end
	end
	return nil;
end

function contains(array, value)
	for _,v in pairs(array) do
		if (v == value) then
			return true;
		end
	end
	return false;
end

--Counts the entries in a table.  Works on tables that aren't arrays, where # can't be used.
function count(tbl)
	local ret = 0;
	for _ in pairs(tbl or {}) do
		ret = ret + 1;
	end
	return ret;
end

function sortedCopy(array)
	local ret = {};
	for _,v in pairs(array) do
		table.insert(ret, v);
	end
	table.sort(ret);
	return ret;
end

--Turns a list of strings into "Alice", "Alice and Bob", or "Alice, Bob and Carol"
function joinNames(names)
	local num = #names;
	if (num == 0) then return ''; end;
	if (num == 1) then return names[1]; end;

	local ret = '';
	for i,name in ipairs(names) do
		if (i == num) then
			ret = ret .. ', and ' .. name;
		elseif (i == 1) then
			ret = name;
		else
			ret = ret .. ', ' .. name;
		end
	end
	return ret;
end

function PlayerName(game, playerID)
	local player = game.Game.Players[playerID];
	if (player == nil) then return 'Unknown player'; end;
	return player.DisplayName(nil, false);
end

--Describes a list of players, such as "Alice, Bob and Carol"
function PlayerNames(game, playerIDs)
	return joinNames(map(sortedCopy(playerIDs), function(pid) return PlayerName(game, pid); end));
end

--The team a player is on right now.  Note that GamePlayer.Team is only the team they started the game on, so we must ask the game with the latest standing since this mod changes teams mid-game.
function TeamOfPlayer(game, playerID, standing)
	return game.Game.PlayerTeam(playerID, standing);
end

--Everyone still playing that shares the given player's team, not counting the player themselves.  Returns an empty list if they're not on a team.
function TeammatesOf(game, playerID, standing)
	local team = TeamOfPlayer(game, playerID, standing);
	if (team == NoTeam) then return {}; end;

	local ret = {};
	for _,gp in pairs(game.Game.PlayingPlayers) do
		if (gp.ID ~= playerID and TeamOfPlayer(game, gp.ID, standing) == team) then
			table.insert(ret, gp.ID);
		end
	end
	return ret;
end

--Whether this game has any cards.  If it does, we warn players that cards belong to the team and don't follow a player who leaves it.
function GameHasCards(settings)
	return count(settings.Cards) > 0;
end
