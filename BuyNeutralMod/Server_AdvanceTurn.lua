require('Utilities');
require('WLUtilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'BuyNeutral_')) then  --look for the order that we inserted in Client_PresentMenuUI

		--in Client_PresentMenuUI, we stuck the territory ID after BuyNeutral_.  Break it out and parse it to a number.
		local targetTerritoryID = tonumber(string.sub(order.Payload, 12));

		local targetTerritoryStanding = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID];

		if (targetTerritoryStanding.OwnerPlayerID ~= WL.PlayerID.Neutral) then
			return; --can only buy neutral territories, so ignore this purchase request.  This can happen if someone captured the territory before the purchase order happened. Their gold was still spent, which isn't ideal.  We could try to refund it here to make the mod nicer.  In practice this won't happen often since people will put their purchase order at the start of the turn, before attacks.
		end

		local costFromOrder = order.CostOpt[WL.ResourceType.Gold]; --this is the cost from the order.  We can't trust this is accurate, as someone could hack their client and put whatever cost they want in there.  Therefore, we must calculate it ourselves, and only do the purchase if they match

		local realCost = Mod.Settings.CostPerNeutralArmy * targetTerritoryStanding.NumArmies.NumArmies;

		if (realCost > costFromOrder) then
			return; --don't do the purchase if their cost didn't line up.  This would only really happen if they hacked their client, or if something increased the size of the neutral somehow (perhaps another mod).  if costFromOrder is less than realCost, the player still gets charged their full gold, so we could also issue a partial refund here to make the mod nicer.
		end

		--All checks passed!  Let's change ownership
		local mod = WL.TerritoryModification.Create(targetTerritoryID);
		mod.SetOwnerOpt = order.PlayerID;
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, order.Message, {}, {mod}));
		

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage); --we replaced the GameOrderCustom with a GameOrderEvent, so get rid of the custom order.  There wouldn't be any harm in leaving it there, but it adds clutter to the orders list so it's better to get rid of it.

	end
end
