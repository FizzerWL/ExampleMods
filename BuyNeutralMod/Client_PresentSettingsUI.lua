
function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent)
		.SetText('Cost per neutral army = ' .. Mod.Settings.CostPerNeutralArmy);
end

