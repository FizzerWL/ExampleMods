
function Client_PresentConfigureUI(rootParent)
	if (not WL.IsVersionOrHigher("5.38")) then
		UI.Alert("You must update your app to the latest version to use the Fort mod");
		return;
	end

	local turnsToGetFort = Mod.Settings.TurnsToGetFort;
	if turnsToGetFort == nil then turnsToGetFort = 4; end
    
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText('Each player can build a fort every X turns');
    turnsInputField = UI.CreateNumberInputField(row1)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(15)
		.SetValue(turnsToGetFort);

end