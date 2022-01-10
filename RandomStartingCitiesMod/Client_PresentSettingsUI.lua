
function Client_PresentSettingsUI(rootParent)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	UI.CreateLabel(vert).SetText("Number of territories to distribute cities on: " .. Mod.Settings.NumTerritories);
	UI.CreateLabel(vert).SetText("Number of cities per territory: " .. Mod.Settings.NumCitiesPerTerritory);
end

