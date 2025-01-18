require('Utilities')

--Called when the player attempts to play your card.  You can call playCard directly if no UI is needed, or you can call game.CreateDialog to present the player with options.
function Client_PresentPlayCardUI(game, cardInstance, playCard)
    --If your mod has multiple cards, you can look at game.Settings.Cards[cardInstance.CardID].Name to see which one was played
    game.CreateDialog(function(rootParent, setMaxSize, setScrollable, game, close)
        setMaxSize(400, 200);
        local vert = UI.CreateVerticalLayoutGroup(rootParent).SetFlexibleWidth(1); --set flexible width so things don't jump around while we change InstructionLabel

        TargetTerritoryBtn = UI.CreateButton(vert).SetText("Select Territory").SetOnClick(TargetTerritoryClicked);
        TargetTerritoryInstructionLabel = UI.CreateLabel(vert).SetText("");

        UI.CreateButton(vert).SetText("Play Card").SetOnClick(function() 

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

	if (terrDetails == nil) then
		--The click request was cancelled.   Return to our default state.
		TargetTerritoryInstructionLabel.SetText("");
	else
		--Territory was clicked, remember its ID
		TargetTerritoryInstructionLabel.SetText("Selected territory: " .. terrDetails.Name);
		TargetTerritoryID = terrDetails.ID;
        TargetTerritoryName = terrDetails.Name;
	end
end

