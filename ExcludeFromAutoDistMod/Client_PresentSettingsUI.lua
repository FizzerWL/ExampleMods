
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText('Excluding bonuses: ' .. Mod.Settings.BonusesToExclude);
end

