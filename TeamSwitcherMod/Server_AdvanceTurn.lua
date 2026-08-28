require('Utilities');
require('ServerUtilities');

function Server_AdvanceTurn_Start(game, addNewOrder)
	ExecuteTeamChanges(game, addNewOrder);
	CleanUpRequests(game);
end

--Executes every team change that was fully accepted.  We do it when the turn advances rather than the moment everyone accepted, so that teams never change while players are still entering their orders.
function ExecuteTeamChanges(game, addNewOrder)
	local priv = Mod.PrivateGameData;
	local changes = priv.AcceptedTeamChanges;
	if (changes == nil or count(changes) == 0) then return; end;

	--Group everyone moving onto the same team together so that forming a team reads as one event.
	local groups = {};
	local teamIDs = {};
	local leaving = {};

	for playerID,teamID in pairs(changes) do
		if (teamID == NoTeam) then
			table.insert(leaving, playerID);
		else
			if (groups[teamID] == nil) then
				groups[teamID] = {};
				table.insert(teamIDs, teamID);
			end
			table.insert(groups[teamID], playerID);
		end
	end

	--Players leaving a team get their own event, since they're not joining anyone.
	for _,playerID in ipairs(sortedCopy(leaving)) do
		local event = WL.GameOrderEvent.Create(playerID, PlayerName(game, playerID) .. ' left their team');
		event.AssignTeamOpt = { [playerID] = NoTeam };
		addNewOrder(event);
	end

	for _,teamID in ipairs(sortedCopy(teamIDs)) do
		local playerIDs = sortedCopy(groups[teamID]);

		local assign = {};
		for _,playerID in ipairs(playerIDs) do
			assign[playerID] = teamID;
		end

		local event = WL.GameOrderEvent.Create(playerIDs[1], PlayerNames(game, playerIDs) .. ' are now on a team');
		event.AssignTeamOpt = assign;
		addNewOrder(event);
	end

	priv.AcceptedTeamChanges = nil;
	Mod.PrivateGameData = priv;
end

--Cancel any proposal that names someone who isn't playing anymore, since it could never be accepted by everyone.  This also keeps the list players see tidy.
function CleanUpRequests(game)
	local requests = Mod.PrivateGameData.PendingTeamRequest;
	if (requests == nil) then return; end;

	for _,request in pairs(requests) do
		local goneID = first(request.PlayerIDs, function(playerID)
			local gp = game.Game.Players[playerID];
			return gp == nil or gp.State ~= WL.GamePlayerState.Playing;
		end);

		if (goneID ~= nil) then
			DeleteRequest(request);
			AlertPlayers(request.PlayerIDs, 'The proposed team of ' .. PlayerNames(game, request.PlayerIDs) .. ' was cancelled, since ' .. PlayerName(game, goneID) .. ' is no longer playing.', nil);
		end
	end
end
