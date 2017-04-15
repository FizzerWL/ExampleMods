
function Client_PresentConfigureUI(rootParent)
	local turnsInitial = Mod.Settings.NumTurns;
	if turnsInitial == nil then turnsInitial = 10; end
    
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local horz = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(horz).SetText("Cannot attack other players for this many turns");
    numberInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(30)
		.SetValue(turnsInitial);

end