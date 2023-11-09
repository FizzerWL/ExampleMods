require('Client_PresentMenuUI');

function Client_PresentCommercePurchaseUI(rootParent, game, close)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	UI.CreateLabel(vert).SetText("You can try to purchase neutral territories for " .. Mod.Settings.CostPerNeutralArmy .. " per army on that territory").SetColor("#DDDDDD");
	CreateButton(vert).SetText("Purchase territory").SetColor("#00FF05").SetOnClick(function()
			-- Call Client_PresentMenuUI that will handle everything else
			game.CreateDialog(Client_PresentMenuUI); 
			close();
		end);
end

