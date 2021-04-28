
function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent)
		.SetText('Limited to ' .. Mod.Settings.Limit .. ' attack/transfer orders');
end

