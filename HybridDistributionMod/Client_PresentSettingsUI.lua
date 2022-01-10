
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	UI.CreateLabel(vert).SetText("Number of territories to auto distribute to each player: " .. Mod.Settings.NumTerritories);
end

