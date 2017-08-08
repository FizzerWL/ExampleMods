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
	UI.CreateLabel(row1).SetText("Purchase territory: ");
	TargetTerritoryBtn = UI.CreateButton(row1).SetText("Select territory...").SetOnClick(TargetTerritoryClicked);


	CostLabel = UI.CreateLabel(vert).SetText(" ");
	
	UI.CreateButton(vert).SetText("Purchase").SetOnClick(SubmitClicked);

end


function TargetTerritoryClicked()
	local options = map(filter(Game.LatestStanding.Territories, function(t) 
		return t.FogLevel == WL.StandingFogLevel.Visible and t.OwnerPlayerID == WL.PlayerID.Neutral  --only show unfogged, neutral territories.
		end), TerritoryButton);
	UI.PromptFromList("Select the territory you'd like to purchase", options);
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

	local goldHave = Gold(Game.Us);
	if (goldHave < Cost) then
		UI.Alert("You can't afford it.  You have " .. goldHave .. " gold and it costs " .. Cost);
		return;
	end

	local msg = 'Purchase ' ..  Game.Map.Territories[TargetTerritoryID].Name .. ' for ' .. Cost .. ' gold';

	local payload = 'BuyNeutral_' .. TargetTerritoryID;

    --Pass a cost to the GameOrderCustom as its fourth argument.  This ensures the game takes the gold away from the player for this order, both on the client and server.
	local order = WL.GameOrderCustom.Create(Game.Us.ID, msg, payload, { [WL.ResourceType.Gold] = Cost } );

	local orders = Game.Orders;
	table.insert(orders, orders);
	Game.Orders = orders;
end