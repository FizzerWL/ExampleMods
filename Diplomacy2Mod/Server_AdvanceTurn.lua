require('Utilities');



function Server_AdvanceTurn_Start(game, addNewOrder)
	--Remember in a global variable all alliances that are breaking this turn
	AlliancesBreakingThisTurn = {};
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderAttackTransfer' and result.IsAttack) then
		--Check if the players are allied
		if (PlayersAreAllied(game, game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID, game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID)) then
			skipThisOrder(WL.ModOrderControl.Skip);
		end
	elseif (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'Diplomacy2_')) then
		local payloadSplit = split(order.Payload, '_'); 
		local msg = payloadSplit[2];
		if (msg == 'BreakAlliance') then
			local allianceBreak = {};
			allianceBreak.OurPlayerID = order.PlayerID;
			allianceBreak.OtherPlayerID = tonumber(payloadSplit[3]);
			AlliancesBreakingThisTurn[#AlliancesBreakingThisTurn + 1] = allianceBreak;
		else
			error("Custom order message not understood (" .. msg .. ")");
		end
	end
end
function AllianceMatchesPlayers(alliance, playerOne, playerTwo)
	return (alliance.PlayerOne == playerOne and alliance.PlayerTwo == playerTwo)
		or (alliance.PlayerOne == playerTwo and alliance.PlayerTwo == playerOne);
end
function PlayersAreAllied(game, playerOne, playerTwo)
	if (playerOne == playerTwo) then return false end; --never allied with yourself.

	return first(Mod.PublicGameData.Alliances or {}, function(alliance) return AllianceMatchesPlayers(alliance, playerOne, playerTwo) end) ~= nil;
end


function Server_AdvanceTurn_End(game, addNewOrder)
	--break any alliances that we saw break orders for	
	local gameData = Mod.PublicGameData;
	for _, allianceBreak in pairs(AlliancesBreakingThisTurn) do
		gameData.Alliances = filter(gameData.Alliances or {}, function(alliance) return not AllianceMatchesPlayers(alliance, allianceBreak.OurPlayerID, allianceBreak.OtherPlayerID) end);
	end
	Mod.PublicGameData = gameData;
end