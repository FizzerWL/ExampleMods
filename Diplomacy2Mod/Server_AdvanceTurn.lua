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

			--Don't show the break order here. Instead, we'll insert it ourselves at the bottom in Server_AdvanceTurn_End
			skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

			--Insert a message into player data for the target so that they know to alert the player.
			local ourPlayerName = game.Game.Players[allianceBreak.OurPlayerID].DisplayName(nil, false);
			AlertPlayer(allianceBreak.OtherPlayerID, ourPlayerName .. ' has broken their alliance with you');
		else
			error("Custom order message not understood (" .. msg .. ")");
		end
	end
end

function AlertPlayer(playerID, msg)
	local playerData = Mod.PlayerGameData;
	if (playerData[playerID] == nil) then
		playerData[playerID] = {};
	end
	local payload = {};
	payload.Message = msg;
	payload.ID = NewIdentity();

	local alerts = playerData[playerID].Alerts or {};
	table.insert(alerts, payload);
	playerData[playerID].Alerts = alerts;
	Mod.PlayerGameData = playerData;
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

		--Add an order so everyone is aware of the breakage
		local ourPlayerName = game.Game.Players[allianceBreak.OurPlayerID].DisplayName(nil, false);
		local otherPlayerName = game.Game.Players[allianceBreak.OtherPlayerID].DisplayName(nil, false);
		local msg = ourPlayerName .. ' broke alliance with ' .. otherPlayerName;
		addNewOrder(WL.GameOrderEvent.Create(allianceBreak.OurPlayerID, msg));
	end
	
	--Remove alliances from players who aren't alive anymore, just to keep the list of alliances tidy.
	gameData.Alliances = filter(gameData.Alliances or {}, function(alliance) return game.Game.Players[alliance.PlayerOne].State == WL.GamePlayerState.Playing and game.Game.Players[alliance.PlayerTwo].State == WL.GamePlayerState.Playing; end);
	
	
	Mod.PublicGameData = gameData;
end