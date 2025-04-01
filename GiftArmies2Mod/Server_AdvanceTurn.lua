require('Utilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'GiftArmies2_')) then  --look for the order that we inserted in Client_PresentMenuUI

		--in Client_PresentMenuUI, we comma-delimited the number of armies, the target territory ID, and the target player ID.  Break it out here
		local payloadSplit = split(string.sub(order.Payload, 13), ','); 
		local numArmies = tonumber(payloadSplit[1])
		local targetTerritoryID = tonumber(payloadSplit[2]);
		local targetPlayerID = tonumber(payloadSplit[3]);
		local td = game.Map.Territories[targetTerritoryID];

		--Skip if we don't control the territory (this can happen if someone captures the territory before our gift order executes)
		if (order.PlayerID ~= game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].OwnerPlayerID) then
			skipThisOrder(WL.ModOrderControl.Skip);
			return;
		end

		local armiesOnTerritory = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].NumArmies.NumArmies;

		if (numArmies < 0) then numArmies = 0 end;
		if (numArmies > armiesOnTerritory) then numArmies = armiesOnTerritory end;

		if (targetPlayerID == order.PlayerID) then  --can't gift yourself
			skipThisOrder(WL.ModOrderControl.Skip);
			return;
		end 

		--remove armies from the source territory
		local removeFromSource = WL.TerritoryModification.Create(targetTerritoryID);
		removeFromSource.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].NumArmies.NumArmies - numArmies;

		--Add armies to destination player
		local incomeMod = WL.IncomeMod.Create(targetPlayerID, numArmies, 'Gifted ' .. numArmies .. ' armies from ' .. game.Game.Players[order.PlayerID].DisplayName(nil, false));

		local event = WL.GameOrderEvent.Create(order.PlayerID, order.Message, {}, {removeFromSource}, nil, {incomeMod});
		event.JumpToActionSpotOpt = WL.RectangleVM.Create(td.MiddlePointX, td.MiddlePointY, td.MiddlePointX, td.MiddlePointY);

		if (WL.IsVersionOrHigher("5.34.1")) then
			event.TerritoryAnnotationsOpt = { [targetTerritoryID] = WL.TerritoryAnnotation.Create("Gift " .. numArmies) };
		end

		addNewOrder(event);

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage); --we replaced the GameOrderCustom with a GameOrderEvent, so get rid of the custom order.  There wouldn't be any harm in leaving it there, but it adds clutter to the orders list so it's better to get rid of it.
	end

end
