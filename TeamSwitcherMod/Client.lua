require('Utilities');

--Actions the player can take.  These are shared between the menu and the propose dialog.

function SendAccept(game, request, closeOpt)
	local payload = {};
	payload.Message = 'AcceptTeamChange';
	payload.ID = request.ID;

	SendTeamMessage(game, 'Accepting team change...', payload, closeOpt, function(returnValue)
		if (returnValue.Complete) then
			return 'Everyone has accepted.  The team of ' .. PlayerNames(game, request.PlayerIDs) .. ' takes effect when the turn advances.';
		else
			return 'You accepted.  The team takes effect once everyone else has accepted too.';
		end
	end);
end

function SendDecline(game, request, closeOpt)
	local payload = {};
	payload.Message = 'DeclineTeamChange';
	payload.ID = request.ID;

	SendTeamMessage(game, 'Declining team change...', payload, closeOpt, function(returnValue)
		return 'You declined the team of ' .. PlayerNames(game, request.PlayerIDs) .. '.';
	end);
end

function SendUnteam(game, closeOpt)
	local payload = {};
	payload.Message = 'Unteam';

	SendTeamMessage(game, 'Leaving team...', payload, closeOpt, function(returnValue)
		return 'You will leave your team when the turn advances.';
	end);
end

--Every message this mod sends either hands back an Error to show the player, or succeeded.
function SendTeamMessage(game, waitingText, payload, closeOpt, successMessageFn)
	if (closeOpt ~= nil) then
		closeOpt(); --close the dialog now, since whatever it's showing is about to be out of date
	end

	game.SendGameCustomMessage(waitingText, payload, function(returnValue)
		if (returnValue == nil) then
			return;
		elseif (returnValue.Error ~= nil) then
			UI.Alert(returnValue.Error);
		else
			UI.Alert(successMessageFn(returnValue));
		end
	end);
end

--Describes how far along a proposal is, such as "Waiting on Alice and Bob"
function RequestStatus(game, request)
	local waitingOn = filter(request.PlayerIDs, function(playerID) return request.Accepted[playerID] ~= true; end);

	if (count(waitingOn) == 0) then
		return 'Accepted by everyone';
	else
		return 'Waiting on ' .. PlayerNames(game, waitingOn);
	end
end

function HaveWeAccepted(game, request)
	return request.Accepted[game.Us.ID] == true;
end
