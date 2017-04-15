
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	
	UI.CreateLabel(vert).SetText('Cannot attack other players for the first ' .. Mod.Settings.NumTurns .. ' turns');
end

