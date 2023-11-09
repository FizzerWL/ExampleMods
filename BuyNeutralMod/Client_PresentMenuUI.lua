require('Utilities');
require('WLUtilities');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game)
	Game = game;

	setMaxSize(450, 250);

	root = rootParent;
	vert = UI.CreateVerticalLayoutGroup(rootParent);

	if (game.Settings.CommerceGame == false) then
		UI.CreateLabel(vert).SetText("This mod only works in commerce games.  This isn't a commerce game.");
		return;
	end

	if (game.Us == nil or game.Us.State ~= WL.GamePlayerState.Playing) then
		UI.CreateLabel(vert).SetText("You cannot purchase neutrals since you're not in the game");
		return;
	end

	purchaseRequests = {};
	for _, order in ipairs(game.Orders) do
		if (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'BuyNeutral_')) then
			table.insert(purchaseRequests, tonumber(string.sub(order.Payload, 12)));
		end
	end

	showMain();
end

function showMain()
	territoryLabel = UI.CreateLabel(vert).SetText("Click the neutral territory that you want to buy").SetColor("#DDDDDD");
	UI.InterceptNextTerritoryClick(TargetTerritoryClicked);
	
	wrongInputLabel = UI.CreateLabel(vert).SetColor("#CC0000");
	
	CostLabel = UI.CreateLabel(vert).SetText(" ").SetColor("#DDDDDD");
	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	submitButton = UI.CreateButton(row1).SetText("Purchase").SetOnClick(SubmitClicked).SetInteractable(false).SetColor("#00FF05");
	requestNewTerritoryButton = UI.CreateButton(row1).SetText("Reselect territory").SetInteractable(false).SetColor("#23A0FF").SetOnClick(function()
			-- Reset the window
			UI.Destroy(vert);
			vert = UI.CreateVerticalLayoutGroup(root);
			showMain();
		end);
end


function TargetTerritoryClicked(terrDetails)
	if UI.IsDestroyed(vert) then
		-- Dialog was destroyed, so we don't need to intercept the click anymore
		return WL.CancelClickIntercept; 
	end

	if terrDetails == nil then
		-- We cannot gather information from nil, but we do want a territory to be clicked
		return UI.InterceptNextTerritoryClick(TargetTerritoryClicked);
	end
	
	if Game == nil then
		-- An error check that I got from time to time
		return WL.CancelClickIntercept;
	end

	local terr = Game.LatestStanding.Territories[terrDetails.ID];

	if valueInTable(purchaseRequests, terrDetails.ID) then
		wrongInputLabel.SetText("You already have a purchase request for this territory");
		UI.InterceptNextTerritoryClick(TargetTerritoryClicked);
		return;
	end

	if terr.FogLevel == WL.StandingFogLevel.You then
		wrongInputLabel.SetText("You cannot purchase a territory you already own");
		UI.InterceptNextTerritoryClick(TargetTerritoryClicked);
		return;	
	end

	if terr.FogLevel ~= WL.StandingFogLevel.Visible then
		wrongInputLabel.SetText("The territory must be fully visible for you to be able to purchase it");
		UI.InterceptNextTerritoryClick(TargetTerritoryClicked);
		return;
	end
	
	if terr.OwnerPlayerID ~= WL.PlayerID.Neutral then
		wrongInputLabel.SetText("You cannot purchase a non-neutral territory");
		UI.InterceptNextTerritoryClick(TargetTerritoryClicked);
		return;
	end
	
	if #terr.NumArmies.SpecialUnits > 0 then
		wrongInputLabel.SetText("You cannot purchase territories that have special units");
		UI.InterceptNextTerritoryClick(TargetTerritoryClicked);
		return;
	end

	wrongInputLabel.SetText(" ");

	territoryLabel.SetText("Chosen territory: " .. Game.Map.Territories[terrDetails.ID].Name);

	Cost = Mod.Settings.CostPerNeutralArmy * terr.NumArmies.NumArmies;
	CostLabel.SetText("This territory costs " .. Cost .. " gold");

	TargetTerritoryID = terrDetails.ID;

	submitButton.SetInteractable(true);
	requestNewTerritoryButton.SetInteractable(true);
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
		UI.Alert("You can't afford it. You have " .. goldHave .. " gold and it costs " .. Cost);
		return;
	end

	local msg = 'Request to purchase ' ..  Game.Map.Territories[TargetTerritoryID].Name .. ' for ' .. Cost .. ' gold';

	local payload = 'BuyNeutral_' .. TargetTerritoryID;

    --Pass a cost to the GameOrderCustom as its fourth argument.  This ensures the game takes the gold away from the player for this order, both on the client and server.
	-- I will be placing the order in the purchase phase
	local custom = WL.GameOrderCustom.Create(Game.Us.ID, msg, payload, { [WL.ResourceType.Gold] = Cost }, WL.TurnPhase.Purchase);
	local orders = Game.Orders;
	local index = 0;
    for i, order in pairs(orders) do
        if order.OccursInPhase ~= nil and order.OccursInPhase > custom.OccursInPhaseOpt then
            index = i;
            break;
        end
    end
    if index == 0 then index = #orders + 1; end
	table.insert(orders, index, custom);
	Game.Orders = orders;
	table.insert(purchaseRequests, TargetTerritoryID);
end