
function Client_PresentConfigureUI(rootParent)
	local numTerritories = Mod.Settings.NumTerritories;
	if (numTerritories == nil) then numTerritories = 1; end


    
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Number of territories to auto distribute to each player");
    _numTerritoriesInputField = UI.CreateNumberInputField(row1)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(10)
		.SetValue(numTerritories);

	

	UI.CreateLabel(vert).SetText("Note: You must set the game's distribution mode to Manual for this mod to work properly");
			
end