require("Utilities");

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType == 'GameOrderPlayCardCustom' and startsWith(order.ModData, "SmokeBomb_")) then
        local targetTerritoryID = tonumber(string.sub(order.ModData, 11));
		local td = game.Map.Territories[targetTerritoryID];
		
		local td = game.Map.Territories[targetTerritoryID];
		local terrs = {targetTerritoryID};
		for k,v in pairs(td.ConnectedTo) do
			table.insert(terrs, k);
		end

		local priority = 7000; -- between 6000 and 8999 means it won't obscure a player's own territories
		local fogMod = WL.FogMod.Create('Obscured by smoke bomb', WL.StandingFogLevel.Fogged, priority, terrs, nil);

		local event = WL.GameOrderEvent.Create(order.PlayerID, 'Detonated a smoke bomb', {});
		event.FogModsOpt = {fogMod};
		event.JumpToActionSpotOpt = WL.RectangleVM.Create(td.MiddlePointX, td.MiddlePointY, td.MiddlePointX, td.MiddlePointY);

		if (WL.IsVersionOrHigher("5.34.1")) then
			event.TerritoryAnnotationsOpt = { [targetTerritoryID] = WL.TerritoryAnnotation.Create("Smoke Bomb") };
		end
		
		addNewOrder(event);

		--Store the ID so we can later disable it
		local priv = Mod.PrivateGameData;
		local allIDs = priv.FogModIDs or {};
		table.insert(allIDs, fogMod.ID);
		priv.FogModIDs = allIDs;
		Mod.PrivateGameData = priv;
    end
end


function Server_AdvanceTurn_Start(game, addNewOrder)
	--If we have any existing fog mods, remove them
	local priv = Mod.PrivateGameData;
	if (priv.FogModIDs == nil) then
		return; 
	end

	local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Smoke bombs dissipate', {});
	event.RemoveFogModsOpt = priv.FogModIDs;
	addNewOrder(event);

	priv.FogModIDs = nil;
	Mod.PrivateGameData = priv;
end
