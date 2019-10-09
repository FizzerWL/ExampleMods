require('Utilities');
require('WLUtilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)

	if (playerID == payload.TargetPlayerID) then
		setReturnTable({ Message = "You can't gift yourself" });
		return;
	end
	local goldSending = payload.Gold;

	local goldHave = game.ServerGame.LatestTurnStanding.NumResources(playerID, WL.ResourceType.Gold);

	if (goldHave < goldSending) then
		setReturnTable({ Message = "You can't gift " .. goldSending .. " when you only have " .. goldHave });
		return;
	end

	local targetPlayer = game.Game.Players[payload.TargetPlayerID];
	local targetPlayerHasGold = game.ServerGame.LatestTurnStanding.NumResources(targetPlayer.ID, WL.ResourceType.Gold);
	
	--Subtract goldSending from ourselves, add goldSending to target
	game.ServerGame.SetPlayerResource(playerID, WL.ResourceType.Gold, goldHave - goldSending);
	game.ServerGame.SetPlayerResource(targetPlayer.ID, WL.ResourceType.Gold, targetPlayerHasGold + goldSending);
	setReturnTable({ Message = "Sent " .. targetPlayer.DisplayName(nil, false) .. ' ' .. goldSending .. ' gold. You now have ' .. (goldHave - goldSending) .. '.'  });

end
