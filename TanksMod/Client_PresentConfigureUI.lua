
function Client_PresentConfigureUI(rootParent)
	local power = Mod.Settings.TankPower;
	if power == nil then power = 10; end

	local cost = Mod.Settings.CostToBuyTank;
	if cost == nil then cost = 20; end

	local maxTanks = Mod.Settings.MaxTanks;
	if maxTanks == nil then maxTanks = 2; end;
    
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText('How much gold it costs to buy a tank');
    costInputField = UI.CreateNumberInputField(row1)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(40)
		.SetValue(cost);


	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row2).SetText('How powerful the tank is (in armies)');
	powerInputField = UI.CreateNumberInputField(row2)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(30)
		.SetValue(power);

	local row3 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row3).SetText('How many tanks each player can have at a time');
	maxTanksField = UI.CreateNumberInputField(row3)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(5)
		.SetValue(maxTanks);
	
end