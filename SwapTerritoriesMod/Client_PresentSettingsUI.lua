
function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent)
		.SetText('Will swap ' .. Mod.Settings.NumTerritories .. ' territories ' .. Mod.Settings.Percentage .. '% of the time');
end

