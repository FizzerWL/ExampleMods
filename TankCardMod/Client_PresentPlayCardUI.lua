require('Utilities')

--Called when the player attempts to play your card.  You can call playCard directly if no UI is needed, or you can call game.CreateDialog to present the player with options.
--If your mod has multiple cards, you can look at game.Settings.Cards[cardInstance.CardID].Name to see which one was played
function Client_PresentPlayCardUI(game, cardInstance, playCard, closeCardsDialog)
    Game = game;

    --If this dialog is already open, close the previous one. This prevents two copies of it from being open at once which can cause errors due to only saving one instance of TargetTerritoryBtn
    if (Close ~= nil) then
        Close();
    end

    if (WL.IsVersionOrHigher("5.34")) then --closeCardsDialog callback did not exist prior to 5.34
        closeCardsDialog();
    end

    game.CreateDialog(function(rootParent, setMaxSize, setScrollable, game, close)
        Close = close;
        setMaxSize(400, 200);
        local vert = UI.CreateVerticalLayoutGroup(rootParent).SetFlexibleWidth(1); --set flexible width so things don't jump around while we change InstructionLabel

        TargetTerritoryBtn = UI.CreateButton(vert).SetText("Select Territory").SetOnClick(TargetTerritoryClicked);
        TargetTerritoryInstructionLabel = UI.CreateLabel(vert).SetText("");

        UI.CreateButton(vert).SetText("Play Card").SetOnClick(function() 
            if (TargetTerritoryID == nil) then
                TargetTerritoryInstructionLabel.SetText("You must select a territory first");
                return;
            end

            if (playCard("Create a tank on " .. TargetTerritoryName, "CreateTank_" .. TargetTerritoryID, WL.TurnPhase.Attacks)) then
                close();
            end
        end);
    end);
end



function TargetTerritoryClicked()
	UI.InterceptNextTerritoryClick(TerritoryClicked);
	TargetTerritoryInstructionLabel.SetText("Please click on the territory you wish to create the tank on.  If needed, you can move this dialog out of the way.");
	TargetTerritoryBtn.SetInteractable(false);
end


function TerritoryClicked(terrDetails)
	TargetTerritoryBtn.SetInteractable(true);

    local terr = Game.LatestStanding.Territories[terrDetails.ID];

	if (terrDetails == nil) then
		--The click request was cancelled.   Return to our default state.
		TargetTerritoryInstructionLabel.SetText("");
        TargetTerritoryID = nil;
        TargetTerritoryName = nil;
    elseif (terr.OwnerPlayerID ~= Game.Us.ID) then
        TargetTerritoryInstructionLabel.SetText("You may only select territories you control");
        TargetTerritoryID = nil;
        TargetTerritoryName = nil;
    else
		--Territory was clicked, remember its ID
		TargetTerritoryInstructionLabel.SetText("Selected territory: " .. terrDetails.Name);
		TargetTerritoryID = terrDetails.ID;
        TargetTerritoryName = terrDetails.Name;
	end
end

