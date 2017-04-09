
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	UI.CreateLabel(vert).SetText('Random +/- limit of ' .. Mod.Settings.RandomizeAmount);
	UI.CreateLabel(vert).SetText('Allow negative: ' .. tostring(Mod.Settings.AllowNegative));
end

