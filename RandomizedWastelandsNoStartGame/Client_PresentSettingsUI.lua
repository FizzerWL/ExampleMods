
function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent)
		.SetText('Random +/- limit of ' .. Mod.Settings.RandomizeAmount);
end

