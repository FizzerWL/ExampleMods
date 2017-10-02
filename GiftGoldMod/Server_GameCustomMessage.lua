require('Utilities');
require('WLUtilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)

	local goldSending = payload.Gold;

	local us = game.Game.Players[playerID];
	local goldHave = Gold(us);

	if (goldHave < goldSending) then
		setReturnTable({ Message = "You can't gift " .. goldSending .. " when you only have " .. goldHave });
		return;
	end

	local targetPlayer = game.Game.Players[payload.TargetPlayerID];
	local targetPlayerHasGold = Gold(targetPlayer);
	
	--Subtract goldSending from ourselves, add goldSending to target
	game.ServerGame.SetPlayerResource(playerID, WL.ResourceType.Gold, goldHave - goldSending);
	game.ServerGame.SetPlayerResource(targetPlayer.ID, WL.ResourceType.Gold, targetPlayerHasGold + goldSending);
	setReturnTable({ Message = "Sent " .. targetPlayer.DisplayName(nil, false) .. ' ' .. goldSending .. ' gold. You now have ' .. (goldHave - goldSending) .. '.'  });

end
