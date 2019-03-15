require('Utilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'GiftArmies_')) then  --look for the order that we inserted in Client_PresentMenuUI

		--in Client_PresentMenuUI, we comma-delimited the number of armies, the target territory ID, and the target player ID.  Break it out here
		local payloadSplit = split(string.sub(order.Payload, 12), ','); 
		local numArmies = tonumber(payloadSplit[1])
		local targetTerritoryID = tonumber(payloadSplit[2]);
		local targetPlayerID = tonumber(payloadSplit[3]);

		local armiesOnTerritory = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].NumArmies.NumArmies;

		if (numArmies < 0) then numArmies = 0 end;
		if (numArmies > armiesOnTerritory) then numArmies = armiesOnTerritory end;

		local targetTerritories = map(filter(game.ServerGame.LatestTurnStanding.Territories, function(t) return t.OwnerPlayerID == targetPlayerID end), function(t) return t.ID; end); --find territories owned by target
		if (#targetTerritories == 0) then return end; --skip if they have no territories

		local terrMods = {};
		--helper function
		local modArmies = function(terrID, numArmies)
			local existing = first(terrMods, function(m) return m.TerritoryID == terrID end);
			if (existing ~= nil) then
				existing.SetArmiesTo = existing.SetArmiesTo + numArmies;
			else
				local mod = WL.TerritoryModification.Create(terrID);
				mod.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[terrID].NumArmies.NumArmies + numArmies;
				table.insert(terrMods, mod);
			end
		end
		--First remove armies from the source territory
		modArmies(targetTerritoryID, -numArmies);

		--Now randomly distribute those armies on the target player's territories, one at a time.
		for i=1,numArmies do
			modArmies(randomFromArray(targetTerritories), 1);
		end
		
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, order.Message, {}, terrMods));
		

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage); --we replaced the GameOrderCustom with a GameOrderEvent, so get rid of the custom order.  There wouldn't be any harm in leaving it there, but it adds clutter to the orders list so it's better to get rid of it.

	end

end
