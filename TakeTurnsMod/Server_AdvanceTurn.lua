require('Utilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if (order.proxyType == 'GameOrderEvent') then
		return; --don't do anything to events, since they get inserted when we do .Skip below
	end
	--Check if this is an order by a player whose turn it isn't.
	local turnOrder = Mod.PublicGameData.PlayerOrder;
	local currTurn = turnOrder[game.Game.NumberOfTurns % #turnOrder + 1];

	if (order.PlayerID ~= currTurn and order.PlayerID ~= WL.PlayerID.Neutral) then
		skipThisOrder(WL.ModOrderControl.Skip);
	end
end


function Server_AdvanceTurn_End(game, addNewOrder)
	--Just for convenience, drop a 100% sanctions on anyone whose turn it isn't next turn.  This makes it so they don't have to deploy needlessly.
	local turnOrder = Mod.PublicGameData.PlayerOrder;
	local currTurn = turnOrder[game.Game.NumberOfTurns % #turnOrder + 1];
	local nextTurn = turnOrder[(game.Game.NumberOfTurns+1) % #turnOrder + 1];

	for _,sanction in pairs(turnOrder) do
		if (sanction ~= nextTurn) then
			local inst = WL.NoParameterCardInstance.Create(WL.CardID.Sanctions);
			addNewOrder(WL.GameOrderReceiveCard.Create(currTurn, {inst}));
			addNewOrder(WL.GameOrderPlayCardSanctions.Create(inst.ID, currTurn, sanction));
		end
	end
end