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
		local structureID = WL.StructureType.Custom("Fort"); --matches to StructureImages/Fort.png
		local backcompatStructureID = WL.StructureType.ArmyCamp; --since we used to use army camps in earlier versions, we treat Army Camps as forts

		local structures = game.ServerGame.LatestTurnStanding.Territories[order.To].Structures;

		--If no fort here, abort.
		if (structures == nil) then return; end;

		local numFortsHere = 0;
		if (structures[structureID] ~= nil) then
			numFortsHere = numFortsHere + structures[structureID];
		end
		if (structures[backcompatStructureID] ~= nil) then
			numFortsHere = numFortsHere + structures[backcompatStructureID];
		end

		--If no fort here, abort.
		if (numFortsHere == 0) then return; end;

		--If an attack of 0, abort, so skipped orders don't destroy the fort
		if (result.ActualArmies.IsEmpty) then return; end;

		--Attack found against a fort!  Cancel the attack and remove the fort.
		if (structures[backcompatStructureID] ~= nil and structures[backcompatStructureID] > 0) then
			structures[backcompatStructureID] = structures[backcompatStructureID] - 1;
		else
			structures[structureID] = structures[structureID] - 1;
		end

		local terrMod = WL.TerritoryModification.Create(order.To);
		terrMod.SetStructuresOpt = structures;
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, 'Destroyed a fort', {}, {terrMod}), true);		-- The second argument makes sure this order isn't processed when the initial attack is skipped


		if (result.DefendingArmiesKilled.IsEmpty) then
			-- A successful attack on a territory where no defending armies were killed must mean it was a territory defended by 0 armies.  In this case, we can't stop the attack by simply setting DefendingArmiesKilled to 0, since attacks against 0 are always successful. 
			-- Instead of skipping the order, we can set the ActualArmies to 0, to make it a 0 army attack. Skipping the order would also skip the destroy fort order
			result.ActualArmies = WL.Armies.Create(0);
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
	local structureID = WL.StructureType.Custom("Fort"); --matches to StructureImages/Fort.png

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
		if (structures[structureID] == nil) then
			structures[structureID] = numFortsToBuildHere;
		else
			structures[structureID] = structures[structureID] + numFortsToBuildHere;
		end

		local terrMod = WL.TerritoryModification.Create(territoryID);
		terrMod.SetStructuresOpt = structures;

		local pendingFort = first(pendingFortGroup);
	
		local event = WL.GameOrderEvent.Create(pendingFort.PlayerID, pendingFort.Message, {}, {terrMod});

		local td = game.Map.Territories[territoryID];
		event.JumpToActionSpotOpt = WL.RectangleVM.Create(td.MiddlePointX, td.MiddlePointY, td.MiddlePointX, td.MiddlePointY);
		if (WL.IsVersionOrHigher("5.34.1")) then
			event.TerritoryAnnotationsOpt = { [territoryID] = WL.TerritoryAnnotation.Create("Build Fort") };
		end


		addNewOrder(event);
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

