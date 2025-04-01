require("Utilities");

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)


    if (order.proxyType == 'GameOrderPlayCardCustom' and startsWith(order.ModData, "CreateTank_")) then
        local cardGame = game.Settings.Cards[order.CardID];
        
        local targetTerritoryID = tonumber(string.sub(order.ModData, 12))
		if (game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].OwnerPlayerID ~= order.PlayerID) then
			return; --not our territory
		end

		local tankPower = 10;

		local builder = WL.CustomSpecialUnitBuilder.Create(order.PlayerID);
		builder.Name = 'Tank';
		builder.IncludeABeforeName = true;
		builder.ImageFilename = 'Tank.png';
		builder.AttackPower = tankPower;
		builder.DefensePower = tankPower;
		builder.CombatOrder = 3415; --defends commanders
		builder.DamageToKill = tankPower;
		builder.DamageAbsorbedWhenAttacked = tankPower;
		builder.CanBeGiftedWithGiftCard = true;
		builder.CanBeTransferredToTeammate = true;
		builder.CanBeAirliftedToSelf = true;
		builder.CanBeAirliftedToTeammate = true;
		builder.IsVisibleToAllPlayers = false;

		local terrMod = WL.TerritoryModification.Create(targetTerritoryID);
		terrMod.AddSpecialUnits = {builder.Build()};

		local td = game.Map.Territories[targetTerritoryID];
	
		local event = WL.GameOrderEvent.Create(order.PlayerID, 'Created a tank', {}, {terrMod});
		event.JumpToActionSpotOpt = WL.RectangleVM.Create(td.MiddlePointX, td.MiddlePointY, td.MiddlePointX, td.MiddlePointY);

		if (WL.IsVersionOrHigher("5.34.1")) then
			event.TerritoryAnnotationsOpt = { [targetTerritoryID] = WL.TerritoryAnnotation.Create("Built Tank") };
		end

		addNewOrder(event);
    end
end
