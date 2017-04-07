
function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.RandomizeAmount;
	local initialNegatives = Mod.Settings.AllowNegative;
	if initialValue == nil then initialValue = 5; end
	if initialNegatives == nil then initialNegatives = false; end
    
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local horz = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(horz).SetText('Random +/- limit for each bonus');
    numberInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(15)
		.SetValue(initialValue);

	allowNegativeBonusesCheckBox = UI.CreateCheckBox(vert).SetText('Allow Negative Bonuses').SetIsChecked(initialNegatives);

end