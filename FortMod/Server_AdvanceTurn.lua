require('Utilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	--Check if we see a Build Fort event.  If we do, add it to a global list that we'll check in BuildForts() below.
	if (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'BuildFort_')) then  --look for the order that we inserted in Client_PresentMenuUI
		--Extract territory ID from the payload
		local terrID = tonumber(string.sub(order.Payload, 11));

		--Make sure this player has a fort to build, and do nothing if they don't have any.
		local playerData = Mod.PlayerGameData;
		if (playerData[order.PlayerID] == nil) then return; end;
		if (playerData[order.PlayerID].NumForts == nil) then return; end;
		if (playerData[order.PlayerID].NumForts <= 0) then return; end;

		--Deduct one fort from their total
		playerData[order.PlayerID].NumForts = playerData[order.PlayerID].NumForts - 1;
		Mod.PlayerGameData = playerData;

		--Build the fort. We could add it with addNewOrder right here, but that would result in forts being built mid-turn, but we want them built at the end of the turn.  So instead add them to a list here, and we'll call addNewOrder for each in Server_AdvanceTurn_End
		local pendingFort = {};
		pendingFort.PlayerID = order.PlayerID;
		pendingFort.Message = order.Message;
		pendingFort.TerritoryID = terrID;


		local priv = Mod.PrivateGameData;
		if (priv.PendingForts == nil) then priv.PendingForts = {}; end;
		table.insert(priv.PendingForts, pendingFort);
		Mod.PrivateGameData = priv;

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage); --skip this order just to avoid clutter in the orders list, since our GameOrderEvent will serve as the message.
	end

	--Check if this is an attack against a territory with a fort.
	if (order.proxyType == 'GameOrderAttackTransfer' and result.IsAttack) then
		local structures = game.ServerGame.LatestTurnStanding.Territories[order.To].Structures;

		--If no fort here, abort.
		if (structures == nil) then return; end;
		if (structures[WL.StructureType.ArmyCamp] == nil) then return; end;
		if (structures[WL.StructureType.ArmyCamp] <= 0) then return; end;

		--Attack found against a fort!  Cancel the attack and remove the fort.
		structures[WL.StructureType.ArmyCamp] = structures[WL.StructureType.ArmyCamp] - 1;

		local terrMod = WL.TerritoryModification.Create(order.To);
		terrMod.SetStructuresOpt = structures;
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, 'Destroyed a fort', {}, {terrMod}));


		if (result.DefendingArmiesKilled.IsEmpty) then
			--A successful attack on a territory where no defending armies were killed must mean it was a territory defended by 0 armies.  In this case, we can't stop the attack by simply setting DefendingArmiesKilled to 0, since attacks against 0 are always successful.  So instead, we simply skip the entire attack.
			skipThisOrder(WL.ModOrderControl.Skip);
		else
			result.DefendingArmiesKilled = WL.Armies.Create(0);
		end

	end
end
function Server_AdvanceTurn_End(game, addNewOrder)
	BuildForts(game, addNewOrder);
	CheckAwardForts(game);
end

function BuildForts(game, addNewOrder)
	--Build any forts that we queued in up Server_AdvanceTurn_Order
	
	local priv = Mod.PrivateGameData;
	local pending = priv.PendingForts;
	if (pending == nil) then return; end;

	-- Remove any pending builds where the player lost control of the territory, so we don't build a fort for the new owner
	removeWhere(pending, function(t) return t.PlayerID ~= game.ServerGame.LatestTurnStanding.Territories[t.TerritoryID].OwnerPlayerID; end);

 
	-- We will now build a fort for each pending fort.  However, we need to take care to ensure that if there are two build orders for the same territory that we build both of them, so we first group by the territory ID so we get all build orders for the same territory together.
	for territoryID,pendingFortGroup in pairs(groupBy(pending, function(t) return t.TerritoryID; end)) do

		local numFortsToBuildHere = #pendingFortGroup;

		local structures = game.ServerGame.LatestTurnStanding.Territories[territoryID].Structures;

		if (structures == nil) then structures = {}; end;
		if (structures[WL.StructureType.ArmyCamp] == nil) then
			structures[WL.StructureType.ArmyCamp] = numFortsToBuildHere;
		else
			structures[WL.StructureType.ArmyCamp] = structures[WL.StructureType.ArmyCamp] + numFortsToBuildHere;
		end
	
		local terrMod = WL.TerritoryModification.Create(territoryID);
		terrMod.SetStructuresOpt = structures;

		local pendingFort = first(pendingFortGroup);
	
		addNewOrder(WL.GameOrderEvent.Create(pendingFort.PlayerID, pendingFort.Message, {}, {terrMod}));
	end

	priv.PendingForts = nil;
	Mod.PrivateGameData = priv;
end

function CheckAwardForts(game)
	--If it's the right turn to award forts, grant one to each player who's still alive in the game
	if ((game.Game.NumberOfTurns + 1) % Mod.Settings.TurnsToGetFort ~= 0) then return; end; --skip if we don't give forts on this turn

	local playerData = Mod.PlayerGameData;

	for _,gp in pairs(filter(game.Game.PlayingPlayers, function(gp) return not gp.IsAI; end)) do
		if (playerData[gp.ID] == nil) then
			playerData[gp.ID] = {};
		end

		if (playerData[gp.ID].NumForts == nil) then
			playerData[gp.ID].NumForts = 1;
		else
			playerData[gp.ID].NumForts = playerData[gp.ID].NumForts + 1;
		end
		
	end

	Mod.PlayerGameData = playerData;

end

