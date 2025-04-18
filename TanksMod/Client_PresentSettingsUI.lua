
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	UI.CreateLabel(vert).SetText('Tank cost: ' .. Mod.Settings.CostToBuyTank);
	UI.CreateLabel(vert).SetText('Tank power: ' .. Mod.Settings.TankPower);
	UI.CreateLabel(vert).SetText('Max tanks: ' .. Mod.Settings.MaxTanks);

end

