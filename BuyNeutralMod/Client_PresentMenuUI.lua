require('Utilities');
require('WLUtilities');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game)
	Game = game;

	setMaxSize(450, 250);

	vert = UI.CreateVerticalLayoutGroup(rootParent);

	if (game.Settings.CommerceGame == false) then
		UI.CreateLabel(vert).SetText("This mod only works in commerce games.  This isn't a commerce game.");
		return;
	end

	if (game.Us == nil or game.Us.State ~= WL.GamePlayerState.Playing) then
		UI.CreateLabel(vert).SetText("You cannot purchase neutrals since you're not in the game");
		return;
	end

	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	territoryLabel = UI.CreateLabel(row1).SetText("Purchase territory: ");
	UI.InterceptNextTerritoryClick(TargetTerritoryClicked);


	CostLabel = UI.CreateLabel(vert).SetText(" ");
	
	UI.CreateButton(vert).SetText("Purchase").SetOnClick(SubmitClicked).SetInteractable(false);

end


function TargetTerritoryClicked(terrDetails)
	if UI.IsDestroyed(vert) then
		-- Dialog was destroyed, so we don't need to intercept the click anymore
		return WL.CancelClickIntercept; 
	end
	if terrDetails == nil then
		-- We cannot gather information from nil, but we do want a territory to be clicked
		UI.InterceptNextTerritoryClick(TargetTerritoryClicked);
	end

	local terr = Game.LatestStanding.Territories[terrDetails.ID];
	for i, v in pairs(WL.FogLevel) do
		print(i, v);
	end
end

function TerritoryButton(terr)
	local name = Game.Map.Territories[terr.ID].Name;
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function()
		TargetTerritoryBtn.SetText(name);
		TargetTerritoryID = terr.ID;
		Cost = terr.NumArmies.NumArmies * Mod.Settings.CostPerNeutralArmy;
		CostLabel.SetText("Cost = " .. Cost .. " gold");
	end
	return ret;
end

function SubmitClicked()
	if (TargetTerritoryID == nil) then
		UI.Alert("Please choose a territory first");
		return;
	end

	local goldHave = Game.LatestStanding.NumResources(Game.Us.ID, WL.ResourceType.Gold);
	
	if (Game.Us.HasCommittedOrders) then
		UI.Alert("You need to uncommit first");
		--since you can't write in the order table when the player has already commited, he needs to uncommit first before he can purchase the territory
		return;
	end
	
	if (goldHave < Cost) then
		UI.Alert("You can't afford it.  You have " .. goldHave .. " gold and it costs " .. Cost);
		return;
	end

	local msg = 'Request to purchase ' ..  Game.Map.Territories[TargetTerritoryID].Name .. ' for ' .. Cost .. ' gold';

	local payload = 'BuyNeutral_' .. TargetTerritoryID;

    --Pass a cost to the GameOrderCustom as its fourth argument.  This ensures the game takes the gold away from the player for this order, both on the client and server.
	local order = WL.GameOrderCustom.Create(Game.Us.ID, msg, payload, { [WL.ResourceType.Gold] = Cost } );

	local orders = Game.Orders;
	table.insert(orders, order);
	Game.Orders = orders;
end
