
function Client_PresentConfigureUI(rootParent)

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	UI.CreateLabel(vert).SetText("List bonuses you wish to exclude from distribution. Enter the names of the bonuses separated by commas, for example: Asia,Europe");
	bonusesToExclude = UI.CreateTextInputField(vert)
		.SetText(Mod.Settings.BonusesToExclude or "")
		.SetFlexibleWidth(1);
		
end