require('Utilities')

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)

	if (not WL.IsVersionOrHigher("5.38")) then
		UI.Alert("You must update your app to the latest version to use the Fort mod");
		return;
	end

	Game = game;
	Close = close;
	
	setMaxSize(350, 350);

	vert = UI.CreateVerticalLayoutGroup(rootParent).SetFlexibleWidth(1); --set flexible width so things don't jump around while we change InstructionLabel

	local numForts;
	if (Mod.PlayerGameData.NumForts == nil) then
		numForts = 0;
	else
		numForts = Mod.PlayerGameData.NumForts;
	end

	UI.CreateLabel(vert).SetText("You will earn a fort every " .. Mod.Settings.TurnsToGetFort .. " turns.");
	UI.CreateLabel(vert).SetText("Forts you can place now: " .. numForts);
	UI.CreateLabel(vert).SetText("Note that forts get built at the end of your turn, so use caution when building on a territory you may lose control of.");

	SelectTerritoryBtn = UI.CreateButton(vert).SetText("Select Territory").SetOnClick(SelectTerritoryClicked);
	SelectTerritoryBtn.SetInteractable(numForts > 0);
	TargetTerritoryInstructionLabel = UI.CreateLabel(vert).SetText("");

	BuildFortBtn = UI.CreateButton(vert).SetText("Build Fort").SetOnClick(BuildFortClicked).SetInteractable(false);

end

function SelectTerritoryClicked()
	UI.InterceptNextTerritoryClick(TerritoryClicked);
	TargetTerritoryInstructionLabel.SetText("Please click on the territory you wish to build the fort on.  If needed, you can move this dialog out of the way.");
	SelectTerritoryBtn.SetInteractable(false);
end

function TerritoryClicked(terrDetails)
	if UI.IsDestroyed(SelectTerritoryBtn) then
		-- Dialog was destroyed, so we don't need to intercept the click anymore
		return WL.CancelClickIntercept; 
	end
	
	SelectTerritoryBtn.SetInteractable(true);

	if (terrDetails == nil) then
		--The click request was cancelled.   Return to our default state.
		TargetTerritoryInstructionLabel.SetText("");
		SelectedTerritory = nil;
		BuildFortBtn.SetInteractable(false);
	else
		--Territory was clicked, remember it
		TargetTerritoryInstructionLabel.SetText("Selected territory: " .. terrDetails.Name);
		SelectedTerritory = terrDetails;
		BuildFortBtn.SetInteractable(true);
	end
end

function BuildFortClicked()
	local msg = 'Build a fort on ' .. SelectedTerritory.Name;
	local payload = 'BuildFort_' .. SelectedTerritory.ID;

	local order = WL.GameOrderCustom.Create(Game.Us.ID, msg, payload);
	
	if (WL.IsVersionOrHigher("5.34.1")) then
		order.JumpToActionSpotOpt = WL.RectangleVM.Create(SelectedTerritory.MiddlePointX, SelectedTerritory.MiddlePointY, SelectedTerritory.MiddlePointX, SelectedTerritory.MiddlePointY);
		order.TerritoryAnnotationsOpt = { [SelectedTerritory.ID] = WL.TerritoryAnnotation.Create("Build Fort") };
	end



	local orders = Game.Orders;
	table.insert(orders, order);
	Game.Orders = orders;

	Close();
end