require('Utilities')

--Called for every order as the turn is processed.  When the card's order comes up (in the phase the client asked for, WL.TurnPhase.Airlift), we move the armies by adding an event.
function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
    if (order.proxyType ~= 'GameOrderPlayCardCustom') then
        return;
    end

    local sourceID, destID, requested = ParseAirliftModData(order.ModData);
    if (sourceID == nil) then
        return; --not our card
    end

    --Everything was validated by the client, but the game may have changed since then (the territory could have been lost, or armies could have been moved by an earlier order), and clients can't be trusted anyway, so check again.
    local standing = game.ServerGame.LatestTurnStanding;
    local source = standing.Territories[sourceID];
    local dest = standing.Territories[destID];

    if (source == nil or dest == nil or sourceID == destID) then
        return;
    end
    if (source.OwnerPlayerID ~= order.PlayerID) then
        return; --we don't own the source anymore
    end
    if (dest.OwnerPlayerID ~= order.PlayerID and not IsTeammate(game, standing, order.PlayerID, dest.OwnerPlayerID)) then
        return; --the destination isn't ours or a teammate's anymore
    end

    --Move as many as we can, up to what was requested
    local numArmies = math.min(requested, source.NumArmies.NumArmies);
    if (numArmies <= 0) then
        return;
    end

    local sourceMod = WL.TerritoryModification.Create(sourceID);
    sourceMod.AddArmies = -numArmies;
    local destMod = WL.TerritoryModification.Create(destID);
    destMod.AddArmies = numArmies;

    local sourceDetails = game.Map.Territories[sourceID];
    local destDetails = game.Map.Territories[destID];

    --An empty set of players to show it to means it's only visible to players who can see one of the territories it changed (and the player who played the card), the same as the real airlift card.
    --The client's Client_Visual hook looks at the two territory modifications in this event to draw the arrow.
    local event = WL.GameOrderEvent.Create(order.PlayerID, "Airlifted " .. numArmies .. " armies from " .. sourceDetails.Name .. " to " .. destDetails.Name, {}, {sourceMod, destMod});
    event.Icon = "AirliftIcon";
    event.JumpToActionSpotOpt = WL.RectangleVM.Create(
        math.min(sourceDetails.MiddlePointX, destDetails.MiddlePointX), math.min(sourceDetails.MiddlePointY, destDetails.MiddlePointY),
        math.max(sourceDetails.MiddlePointX, destDetails.MiddlePointX), math.max(sourceDetails.MiddlePointY, destDetails.MiddlePointY));

    addNewOrder(event);
end
