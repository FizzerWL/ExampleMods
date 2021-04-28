numAttacksTable = {};

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if (order.proxyType == 'GameOrderAttackTransfer') then
		local numAttacks = numAttacksTable[order.PlayerID];
		if numAttacks == nil then numAttacks = 0; end
		if (numAttacks >= Mod.Settings.Limit) then
			skipThisOrder(WL.ModOrderControl.Skip);
		else
			numAttacksTable[order.PlayerID] = numAttacks + 1;
		end
	end
end
