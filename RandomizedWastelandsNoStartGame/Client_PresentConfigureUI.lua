
function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.RandomizeAmount;
	if initialValue == nil then
		initialValue = 5;
	end
    
    local horz = UI.CreateHorizontalLayoutGroup(rootParent);
	UI.CreateLabel(horz).SetText('Random +/- limit');
    numberInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(15)
		.SetValue(initialValue);

end