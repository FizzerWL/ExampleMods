
function Client_PresentConfigureUI(rootParent)
	local numTerritories = Mod.Settings.NumTerritories;
	local numCitiesPerTerritory = Mod.Settings.NumCitiesPerTerritory;
	if (numTerritories == nil) then numTerritories = 3; end
	if (numCitiesPerTerritory == nil) then numCitiesPerTerritory = 1; end;


    
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Number of territories to place cities on");
    _numTerritoriesInputField = UI.CreateNumberInputField(row1)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(15)
		.SetValue(numTerritories);

	
	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row2).SetText("Number of cities to place on each territory");
	_numCitiesPerTerritoryInputField = UI.CreateNumberInputField(row2)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(5)
		.SetValue(numCitiesPerTerritory);

			
end