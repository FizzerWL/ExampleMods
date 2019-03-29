require('Utilities');
require('Client');
require('Diplomacy');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	Game = game; --make it globally accessible


	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	--List pending proposals.  This isn't absolutely necessary since we also alert the player of new proposals, but it's nice to list them here anyway.
	for _,proposal in pairs(Mod.PlayerGameData.PendingProposals or {}) do
		local otherPlayer = game.Game.Players[proposal.PlayerOne].DisplayName(nil, false);
		local row = UI.CreateHorizontalLayoutGroup(vert);
		UI.CreateLabel(row).SetText('Proposal from ' .. otherPlayer);
		UI.CreateButton(row).SetText('Respond').SetOnClick(function() DoProposalPrompt(game, proposal); close(); end);
    end

	local alliances = Mod.PublicGameData.Alliances or {};
	if (#alliances == 0) then
		UI.CreateLabel(vert).SetText("No alliances are currently in effect");
	else
		--Render all alliances that involve us first
		local ourAlliances = filter(alliances, function(alliance) return game.Us ~= nil and (alliance.PlayerOne == game.Us.ID or alliance.PlayerTwo == game.Us.ID) end);
		for _,alliance in pairs(ourAlliances) do
			local otherPlayerID
			if alliance.PlayerOne == game.Us.ID then
				otherPlayerID = alliance.PlayerTwo 
			else
				otherPlayerID = alliance.PlayerOne
			end
			local otherPlayerName = game.Game.Players[otherPlayerID].DisplayName(nil, false);

			
			local horz = UI.CreateHorizontalLayoutGroup(vert);
			UI.CreateLabel(horz).SetText('You are allied with ' .. otherPlayerName);
			UI.CreateButton(horz).SetText("Break").SetOnClick(function() 
				BreakAlliance(otherPlayerID, otherPlayerName);
				close();
			end);
		end

			
		--Render all alliances that don't involve us
		for _,alliance in pairs(filter(alliances, function(alliance) return game.Us == nil or (alliance.PlayerOne ~= game.Us.ID and alliance.PlayerTwo ~= game.Us.ID) end)) do
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

function BreakAlliance(otherPlayerID, otherPlayerName)
	local msg = 'Breaking alliance with ' .. otherPlayerName;

	local payload = 'Diplomacy2_BreakAlliance_' .. otherPlayerID;

	local orders = Game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, msg, payload));
	Game.Orders = orders;
end

function CreateProposeDialog(rootParent, setMaxSize, setScrollable, game, close)
	setMaxSize(390, 300);
	TargetPlayerID = nil;

	local vert = UI.CreateVerticalLayoutGroup(rootParent);

	
	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Propose an alliance with this player: ");
	TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...").SetOnClick(TargetPlayerClicked);

	UI.CreateButton(vert).SetText("Propose Alliance").SetOnClick(function() 

		if (TargetPlayerID == nil) then
			UI.Alert("Please choose a player first");
			return;
		end

		local payload = {};
		payload.Message = "Propose";
		payload.TargetPlayerID = TargetPlayerID;


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

	if (player.State ~= WL.GamePlayerState.Playing) then return false end; --skip players not alive anymore, or that declined the game.

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
