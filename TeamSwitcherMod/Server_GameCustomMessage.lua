require('Utilities');
require('ServerUtilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	if (payload.Message == 'ProposeTeamChange') then
		ProposeTeamChange(game, playerID, payload, setReturnTable);
	elseif (payload.Message == 'DeclineTeamChange') then
		DeclineTeamChange(game, playerID, payload, setReturnTable);
	elseif (payload.Message == 'AcceptTeamChange') then
		AcceptTeamChange(game, playerID, payload, setReturnTable);
	elseif (payload.Message == 'Unteam') then
		Unteam(game, playerID, payload, setReturnTable);
	elseif (payload.Message == 'AckAlerts') then
		AckAlerts(game, playerID, payload, setReturnTable);
	else
		error("Payload message not understood (" .. tostring(payload.Message) .. ")");
	end
end

--Asks everyone named to form a team together.  Nothing happens until they've all accepted.
function ProposeTeamChange(game, playerID, payload, setReturnTable)
	local playerIDs = payload.PlayerIDs or {};

	if (not contains(playerIDs, playerID)) then
		error("You can't propose a team that you're not a part of");
	end
	--A team of just yourself is the same thing as leaving the team you're on, so send Unteam instead.
	if (count(playerIDs) < 2) then
		error("A team needs at least two players");
	end

	local seen = {};
	for _,pid in pairs(playerIDs) do
		if (seen[pid]) then
			error("The same player was named twice in the proposed team");
		end
		seen[pid] = true;

		local gp = game.Game.Players[pid];
		if (gp == nil or gp.State ~= WL.GamePlayerState.Playing) then
			error("You can't form a team with a player who isn't playing");
		end
	end

	--Everyone must be free of queued-up team changes, otherwise this proposal could never be executed.
	local conflict = FindConflict(game, playerIDs);
	if (conflict ~= nil) then
		setReturnTable({ Error = conflict });
		return;
	end

	local request = {};
	request.ID = NewGuid();
	request.ProposerID = playerID;
	request.PlayerIDs = playerIDs;
	request.Accepted = {};
	request.Accepted[playerID] = true; --proposing it counts as accepting it

	--In single-player, AIs accept immediately so that the mod can be tried out.  In multi-player we never let players name an AI in the first place, since an AI would never respond.
	if (game.Settings.SinglePlayer) then
		for _,pid in pairs(playerIDs) do
			if (game.Game.Players[pid].IsAIOrHumanTurnedIntoAI) then
				request.Accepted[pid] = true;
			end
		end
	end

	SaveRequest(request);
	WriteRequestToPlayerData(request);

	AlertPlayers(playerIDs, PlayerName(game, playerID) .. ' has proposed a team of ' .. PlayerNames(game, playerIDs) .. '.  Open the Team Switcher mod from the game menu to accept or decline it.', playerID);

	--Everyone may have accepted already if we auto-accepted for AIs above.
	if (HasAcceptedAll(request)) then
		TeamChangeAccepted(game, request, playerID);
		setReturnTable({ ID = request.ID, Complete = true });
	else
		setReturnTable({ ID = request.ID, Complete = false });
	end
end

--Turns down a proposal, which cancels it for everyone.
function DeclineTeamChange(game, playerID, payload, setReturnTable)
	local request = GetRequest(payload.ID);
	if (request == nil) then
		setReturnTable({ Error = "That team change is no longer pending" });
		return;
	end
	if (not contains(request.PlayerIDs, playerID)) then
		error("You're not a part of that team change");
	end

	DeleteRequest(request);

	AlertPlayers(request.PlayerIDs, PlayerName(game, playerID) .. ' declined the proposed team of ' .. PlayerNames(game, request.PlayerIDs) .. '.', playerID);

	setReturnTable({ Declined = true });
end

--Agrees to a proposal.  Once everyone named in it has accepted, the team change gets queued up for the turn advance.
function AcceptTeamChange(game, playerID, payload, setReturnTable)
	local request = GetRequest(payload.ID);
	if (request == nil) then
		setReturnTable({ Error = "That team change is no longer pending" });
		return;
	end
	if (not contains(request.PlayerIDs, playerID)) then
		error("You're not a part of that team change");
	end

	--Work out if we're the last one to accept before we write anything, so that we don't record an acceptance that we then can't act on.
	request.Accepted[playerID] = true;
	local complete = HasAcceptedAll(request);

	if (complete) then
		local conflict = FindConflict(game, request.PlayerIDs);
		if (conflict ~= nil) then
			setReturnTable({ Error = conflict });
			return;
		end

		TeamChangeAccepted(game, request, playerID);
	else
		SaveRequest(request);
		WriteRequestToPlayerData(request);
	end

	setReturnTable({ Complete = complete });
end

--Leaves the team you're on, without needing anyone's agreement.
function Unteam(game, playerID, payload, setReturnTable)
	local team = TeamOfPlayer(game, playerID, LatestStanding(game));
	if (team == NoTeam) then
		error("You're not on a team");
	end

	local playerIDs = { playerID };

	local conflict = FindConflict(game, playerIDs);
	if (conflict ~= nil) then
		setReturnTable({ Error = conflict });
		return;
	end

	local teammates = TeammatesOf(game, playerID, LatestStanding(game));

	RecordTeamChange(playerIDs, NoTeam);

	AlertPlayers(teammates, PlayerName(game, playerID) .. ' is leaving your team.  It takes effect when the turn advances.', playerID);

	setReturnTable({ Complete = true });
end

--Everyone in the request has agreed, so queue the team change up for the turn advance and tell everyone about it.
function TeamChangeAccepted(game, request, lastPlayerToActID)
	--Always move everyone onto a brand new team, even if some of them are already together on one.  Anyone who changes teams leaves their cards behind, and it'd be unfair and surprising if that depended on which team they happened to end up on.
	RecordTeamChange(request.PlayerIDs, NewTeamID(game));

	DeleteRequest(request);

	AlertPlayers(request.PlayerIDs, 'The team of ' .. PlayerNames(game, request.PlayerIDs) .. ' has been accepted by everyone.  It takes effect when the turn advances.', lastPlayerToActID);
end

--The client shows alerts and then tells us it's done with them so we don't show them twice.
function AckAlerts(game, playerID, payload, setReturnTable)
	local playerData = Mod.PlayerGameData;

	if (playerData[playerID] ~= nil and playerData[playerID].Alerts ~= nil) then
		--Only remove the alerts the client told us it saw, since we may have added more since it read them.
		playerData[playerID].Alerts = filter(playerData[playerID].Alerts, function(alert) return not contains(payload.AlertIDs or {}, alert.ID); end);
		Mod.PlayerGameData = playerData;
	end

	setReturnTable({ Acknowledged = true });
end
