require('Utilities');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Game = game; --make it globally accessible

	local alliances = Mod.PublicGameData.Alliances or {};

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	if (#alliances == 0) then
		UI.CreateLabel(vert).SetText("No alliances are currently in effect");
	else
		for _,alliance in pairs(alliances) do
			local playerOne = game.Game.Players[alliance.PlayerOne].DisplayName(nil, false);
			local playerTwo = game.Game.Players[alliance.PlayerTwo].DisplayName(nil, false);
			UI.CreateLabel(vert).SetText(playerOne .. ' and ' .. playerTwo .. ' are allied until turn ' .. (alliance.ExpiresOnTurn+1));
		end
	end

	if (game.Us ~= nil) then --don't show propose button to spectators
		UI.CreateButton(vert).SetText("Propose Alliance").SetOnClick(function()
			game.CreateDialog(CreateProposeDialog);
		end);
	end

end

function CreateProposeDialog(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(390, 300);
	TargetPlayerID = nil;

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Propose an alliance with this player: ");
	TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...").SetOnClick(TargetPlayerClicked);

	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row2).SetText("Alliance will last this many turns: ");
	local numTurnsSlider = UI.CreateNumberInputField(row2)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(10)
		.SetValue(5);

	UI.CreateButton(vert).SetText("Propose Alliance").SetOnClick(function() 

		if (TargetPlayerID == nil) then
			UI.Alert("Please choose a player first");
			return;
		end

		local numTurns = numTurnsSlider.GetValue();
		if (numTurns <= 0) then
			UI.Alert("Numer of turns must be a positive number");
			return;
		end

		local payload = {};
		payload.Message = "Propose";
		payload.TargetPlayerID = TargetPlayerID;
		payload.NumTurns = numTurns;

		Game.SendGameCustomMessage("Proposing alliance...", payload, function(returnValue) 
			UI.Alert("Proposal sent!");
			close(); --Close the propose dialog since we're done with it
		end);
	end);


end



function TargetPlayerClicked()
	local options = map(filter(Game.Game.Players, IsPotentialTarget), PlayerButton);
	UI.PromptFromList("Select the player you'd like to propose an alliance with", options);
end

--Determines if the player is one we can propose an alliance to.
function IsPotentialTarget(player)
	if (Game.Us.ID == player.ID) then return false end; -- we can never propose an alliance with ourselves.

	if (Game.Settings.SinglePlayer) then return true end; --in single player, allow proposing with everyone

	return not player.IsAI; --In multi-player, never allow proposing with an AI.
end

function PlayerButton(player)
	local name = player.DisplayName(nil, false);
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		TargetPlayerBtn.SetText(name);
		TargetPlayerID = player.ID;
	end
	return ret;
end
