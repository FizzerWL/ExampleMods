require('Utilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderAttackTransfer' and result.IsAttack) then
		--Check if the players are allied
		if (PlayersAreAllied(game, game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID, game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID)) then
			skipThisOrder(WL.ModOrderControl.Skip);
		end
	end
end

function PlayersAreAllied(game, playerOne, playerTwo)
	if (playerOne == playerTwo) then return false end; --never allied with yourself.

	return first(Mod.PublicGameData.Alliances or {}, function(alliance) 
		return (alliance.PlayerOne == playerOne and alliance.PlayerTwo == playerTwo)
			or (alliance.PlayerOne == playerTwo and alliance.PlayerTwo == playerOne);
		end
	) ~= nil;
end
