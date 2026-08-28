require('Utilities');

--Alerts we've already told the server about, so that we don't show them twice while we wait for it to reply.
AcknowledgedAlertIDs = {};

function Client_GameRefresh(game)
	--Skip if we're not in the game.  We can't use game.SendGameCustomMessage as a spectator.
	if (game.Us == nil) then
		return;
	end

	local alerts = filter(Mod.PlayerGameData.Alerts or {}, function(alert) return AcknowledgedAlertIDs[alert.ID] ~= true; end);
	if (count(alerts) == 0) then
		return;
	end

	local message = table.concat(map(alerts, function(alert) return alert.Message; end), '\n\n');

	local payload = {};
	payload.Message = 'AckAlerts';
	payload.AlertIDs = map(alerts, function(alert) return alert.ID; end);

	for _,alert in pairs(alerts) do
		AcknowledgedAlertIDs[alert.ID] = true;
	end

	--Let the server know we've seen these so it can delete them.  Wait on showing them until it replies, just to avoid two things appearing on the screen at once.
	game.SendGameCustomMessage('Read receipt...', payload, function(returnValue)
		UI.Alert(message);
	end);
end
