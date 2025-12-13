require('Utilities');
require('WLUtilities');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Game = game;
	Close = close;

	setMaxSize(450, 250);

	local vert = UI.CreateVerticalLayoutGroup(rootParent);


	if (game.Settings.CommerceGame == false) then
		UI.CreateLabel(vert).SetText("This mod only works in commerce games.  This isn't a commerce game.");
		return;
	end
	if (game.Us == nil or game.Us.State ~= WL.GamePlayerState.Playing) then
		UI.CreateLabel(vert).SetText("You cannot gift gold since you're not in the game");
		return;
	end
	if (game.LatestStanding == nil) then
		UI.CreateLabel(vert).SetText("Cannot use until game has begun");
		return;
	end

	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Gift gold to this player: ");
	TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...").SetOnClick(TargetPlayerClicked);

	local goldHave = game.LatestStanding.NumResources(game.Us.ID, WL.ResourceType.Gold);

	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row2).SetText('Amount of gold to give away: ');
    GoldInput = UI.CreateNumberInputField(row2)
		.SetSliderMinValue(1)
		.SetSliderMaxValue(goldHave)
		.SetValue(1);

	UI.CreateButton(vert).SetText("Gift").SetOnClick(SubmitClicked);
end


function TargetPlayerClicked()
	local players = filter(Game.Game.Players, function (p) return p.ID ~= Game.Us.ID end);
	local options = map(players, PlayerButton);
	UI.PromptFromList("Select the player you'd like to give gold to", options);
end
function PlayerButton(player)
	local name = player.DisplayName(nil, false);
	local ret = {};

	if (WL.IsVersionOrHigher("5.41.0")) then
		ret["player"] = player.ID;
	else
		ret["text"] = name;
	end

	ret["selected"] = function() 
		TargetPlayerBtn.SetText(name);
		TargetPlayerID = player.ID;
	end
	return ret;
end


function SubmitClicked()

	if (TargetPlayerID == nil) then
		UI.Alert("Please choose a player first");
		return;
	end

	--Check for negative gold.  We don't need to check to ensure we have this much since the server does that check in Server_GameCustomMessage
	local gold = GoldInput.GetValue();
	if (gold <= 0) then
		UI.Alert("Gold to gift must be a positive number");
		return;
	end

	local payload = {};
	payload.TargetPlayerID = TargetPlayerID;
	payload.Gold = gold;

	Game.SendGameCustomMessage("Gifting gold...", payload, function(returnValue) 
		UI.Alert(returnValue.Message);
		Close(); --Close the dialog since we're done with it
	end);
end