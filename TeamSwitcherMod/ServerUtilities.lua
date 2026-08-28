require('Utilities');

--Helpers shared by the server hooks.  None of these can be called from the client, since the client can't write mod data.

function LatestStanding(game)
	return game.ServerGame.LatestTurnStanding;
end

--Writes a message into a player's data.  Their client will show it the next time it refreshes, and then acknowledge it so we can remove it.
function AlertPlayer(playerID, message)
	local playerData = Mod.PlayerGameData;
	if (playerData[playerID] == nil) then
		playerData[playerID] = {};
	end

	local alert = {};
	alert.ID = NewGuid();
	alert.Message = message;

	local alerts = playerData[playerID].Alerts or {};
	table.insert(alerts, alert);
	playerData[playerID].Alerts = alerts;
	Mod.PlayerGameData = playerData;
end

--Alerts everyone in the list, other than exceptPlayerIDOpt who we skip since they're the one who just acted.
function AlertPlayers(playerIDs, message, exceptPlayerIDOpt)
	for _,pid in pairs(playerIDs) do
		if (pid ~= exceptPlayerIDOpt) then
			AlertPlayer(pid, message);
		end
	end
end

--Gives everyone in the request a copy of it so their client knows what to show.  Called again on each acceptance so clients can see who's accepted so far.
function WriteRequestToPlayerData(request)
	local playerData = Mod.PlayerGameData;

	for _,pid in pairs(request.PlayerIDs) do
		if (playerData[pid] == nil) then
			playerData[pid] = {};
		end

		local requests = filter(playerData[pid].PendingTeamRequests or {}, function(r) return r.ID ~= request.ID; end);
		table.insert(requests, request);
		playerData[pid].PendingTeamRequests = requests;
	end

	Mod.PlayerGameData = playerData;
end

function RemoveRequestFromPlayerData(request)
	local playerData = Mod.PlayerGameData;

	for _,pid in pairs(request.PlayerIDs) do
		if (playerData[pid] ~= nil and playerData[pid].PendingTeamRequests ~= nil) then
			playerData[pid].PendingTeamRequests = filter(playerData[pid].PendingTeamRequests, function(r) return r.ID ~= request.ID; end);
		end
	end

	Mod.PlayerGameData = playerData;
end

function GetRequest(requestID)
	return (Mod.PrivateGameData.PendingTeamRequest or {})[requestID];
end

function SaveRequest(request)
	local priv = Mod.PrivateGameData;
	if (priv.PendingTeamRequest == nil) then priv.PendingTeamRequest = {}; end;
	priv.PendingTeamRequest[request.ID] = request;
	Mod.PrivateGameData = priv;
end

function DeleteRequest(request)
	local priv = Mod.PrivateGameData;
	if (priv.PendingTeamRequest ~= nil) then
		priv.PendingTeamRequest[request.ID] = nil;
		Mod.PrivateGameData = priv;
	end

	RemoveRequestFromPlayerData(request);
end

function HasAcceptedAll(request)
	for _,pid in pairs(request.PlayerIDs) do
		if (request.Accepted[pid] ~= true) then
			return false;
		end
	end
	return true;
end

--Team changes don't happen until the turn advances, so we can only have one queued up per player at a time.  Returns an error message if any of these players already has one queued, or nil if they're all free.
function FindConflict(game, playerIDs)
	local accepted = Mod.PrivateGameData.AcceptedTeamChanges or {};

	for _,pid in pairs(playerIDs) do
		if (accepted[pid] ~= nil) then
			return 'A team change for ' .. PlayerName(game, pid) .. ' is already pending, please wait until the next turn';
		end
	end

	return nil;
end

--Queues up the team change.  Server_AdvanceTurn_Start will execute everything queued here when the turn advances.
function RecordTeamChange(playerIDs, teamID)
	local priv = Mod.PrivateGameData;
	if (priv.AcceptedTeamChanges == nil) then priv.AcceptedTeamChanges = {}; end;

	for _,pid in pairs(playerIDs) do
		priv.AcceptedTeamChanges[pid] = teamID;
	end

	Mod.PrivateGameData = priv;
end

--A team ID that nobody is using, or is about to use.
function NewTeamID(game)
	local standing = LatestStanding(game);
	local highest = NoTeam;

	for _,gp in pairs(game.Game.Players) do
		local team = TeamOfPlayer(game, gp.ID, standing);
		if (team > highest) then highest = team; end;
	end

	--Also consider the teams that queued-up changes are about to move players onto, since those haven't been applied to the standing yet.
	for _,team in pairs(Mod.PrivateGameData.AcceptedTeamChanges or {}) do
		if (team > highest) then highest = team; end;
	end

	return highest + 1;
end
