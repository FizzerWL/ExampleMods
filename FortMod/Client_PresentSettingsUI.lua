
function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent).SetText('Players get a fort every ' .. Mod.Settings.TurnsToGetFort .. ' turns');
end

