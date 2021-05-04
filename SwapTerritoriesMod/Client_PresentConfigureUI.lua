
function Client_PresentConfigureUI(rootParent)
	local numTerrs = Mod.Settings.NumTerritories;
	local percent = Mod.Settings.Percentage;
	if numTerrs == nil then numTerrs = 1; end
	if percent == nil then percent = 20; end
    
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText('Number of territories to swap (0 = swap all)');
    numTerrsInputField = UI.CreateNumberInputField(row1)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(15)
		.SetValue(numTerrs);

    local row2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row2).SetText('Percent chance of swapping each turn');
	percentInputField = UI.CreateNumberInputField(row2)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(100)
		.SetValue(percent);

end