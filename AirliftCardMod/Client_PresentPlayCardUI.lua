require('Utilities')

--Called when the player attempts to play the card.  We present a dialog modeled after the built-in airlift dialog: pick a source, pick a destination, choose how many armies, and press Play.
function Client_PresentPlayCardUI(game, cardInstance, playCard, closeCardsDialog)
    if (not WL.IsVersionOrHigher(RequiredVersion)) then
        UI.Alert("You must update your app to the latest version to play the Airlift Card");
        return;
    end

    Game = game;

    --If this dialog is already open, close the previous one so that two copies can't fight over the map click interceptor
    if (Close ~= nil) then
        Close();
    end
    closeCardsDialog();

    game.CreateDialog(function(rootParent, setMaxSize, setScrollable, game, close)
        Close = close;
        setMaxSize(520, 400);

        local sourceID = nil;
        local destID = nil;
        local sourceArmies = 0; --how many armies can be airlifted from the source
        local sourceSide, destSide, instructionLabel, errorLabel, armiesInput, playButton;

        local function Instruction()
            if (sourceID ~= nil and destID ~= nil) then
                return "Select Play to finalize your selection";
            else
                return "Select a source and a destination territory";
            end
        end

        --Builds one of the two columns (source or destination): a select button, a snapshot of the territory, its name, and its armies
        local function CreateSide(parent, buttonText)
            local side = {};
            side.Vert = UI.CreateVerticalLayoutGroup(parent).SetFlexibleWidth(1).SetCenter(true);
            side.Button = UI.CreateButton(side.Vert).SetText(buttonText).SetColor("#242D9A");

            --The snapshot stays transparent until we give it territories, but sizing it now keeps the dialog from jumping around when we do
            side.Snapshot = UI.CreateSnapshot(side.Vert).SetPreferredWidth(100).SetPreferredHeight(100);
            side.NameLabel = UI.CreateLabel(side.Vert).SetText(" ").SetAlignment(WL.TextAlignmentOptions.Center);
            side.ArmiesLabel = UI.CreateLabel(side.Vert).SetText(" ").SetAlignment(WL.TextAlignmentOptions.Center);
            return side;
        end

        local function SetSelecting(selecting)
            sourceSide.Button.SetInteractable(not selecting);
            destSide.Button.SetInteractable(not selecting);
            playButton.SetInteractable(not selecting);
        end

        --Returns the armies on the territory that could be airlifted away.  Armies deployed this turn count, since airlifts happen after deploys.
        --Armies already committed to other airlifts from the same territory this turn are excluded.
        local function AvailableArmies(terrID)
            local armies = Game.LatestStanding.Territories[terrID].NumArmies.NumArmies;
            for _, order in pairs(Game.Orders or {}) do
                if (order.proxyType == 'GameOrderDeploy' and order.DeployOn == terrID) then
                    armies = armies + order.NumArmies;
                elseif (order.proxyType == 'GameOrderPlayCardCustom') then
                    local from, to, n = ParseAirliftModData(order.ModData);
                    if (from == terrID) then armies = armies - n; end
                    if (to == terrID) then armies = armies + n; end
                end
            end
            return math.max(armies, 0);
        end

        --Returns nil if the territory can be used, or a message explaining why not
        local function Validate(isSource, terrID)
            local owner = Game.LatestStanding.Territories[terrID].OwnerPlayerID;
            if (isSource) then
                if (owner ~= Game.Us.ID) then
                    return "The source must be a territory you control";
                elseif (terrID == destID) then
                    return "The source and destination must be different territories";
                elseif (AvailableArmies(terrID) < 1) then
                    return "That territory has no armies to airlift";
                end
            else
                if (owner ~= Game.Us.ID and not IsTeammate(Game, Game.LatestStanding, Game.Us.ID, owner)) then
                    return "The destination must be a territory that you or a teammate control";
                elseif (terrID == sourceID) then
                    return "The source and destination must be different territories";
                end
            end
            return nil;
        end

        local function ApplySelection(isSource, td)
            local side = isSource and sourceSide or destSide;
            side.Snapshot.SetTerritoryIDs({ td.ID });
            side.NameLabel.SetText(td.Name);

            if (isSource) then
                sourceID = td.ID;
                sourceArmies = AvailableArmies(td.ID);
                side.ArmiesLabel.SetText(sourceArmies .. " armies");
                armiesInput.SetSliderMaxValue(sourceArmies).SetValue(sourceArmies).SetInteractable(true);
            else
                destID = td.ID;
                side.ArmiesLabel.SetText(Game.LatestStanding.Territories[td.ID].NumArmies.NumArmies .. " armies");
            end

            instructionLabel.SetText(Instruction());
        end

        local function BeginSelect(isSource)
            SetSelecting(true);
            errorLabel.SetText(" ");
            instructionLabel.SetText("Click the " .. (isSource and "source" or "destination") .. " territory on the map.  If needed, you can move this dialog out of the way.");

            UI.InterceptNextTerritoryClick(function(terrDetails)
                if (UI.IsDestroyed(instructionLabel)) then
                    return WL.CancelClickIntercept; --the dialog was closed, so we don't need to intercept anymore
                end

                SetSelecting(false);
                instructionLabel.SetText(Instruction());

                if (terrDetails == nil) then
                    return; --the click request was cancelled
                end

                local problem = Validate(isSource, terrDetails.ID);
                if (problem ~= nil) then
                    errorLabel.SetText(problem);
                    return;
                end

                ApplySelection(isSource, terrDetails);
            end);
        end

        local function Play()
            if (sourceID == nil or destID == nil) then
                errorLabel.SetText("You must select a source and a destination first");
                return;
            end

            local numArmies = math.floor(armiesInput.GetValue());
            if (numArmies < 1) then
                errorLabel.SetText("You must airlift at least 1 army");
                return;
            elseif (numArmies > sourceArmies) then
                errorLabel.SetText("You can't airlift more armies than the source has");
                return;
            end

            local source = Game.Map.Territories[sourceID];
            local dest = Game.Map.Territories[destID];

            --Annotations are shown on the territories while the order is in the orders list, and the camera jumps to the rectangle when the order is selected
            local annotations = {
                [sourceID] = WL.TerritoryAnnotation.Create("Airlift out (" .. numArmies .. ")"),
                [destID] = WL.TerritoryAnnotation.Create("Airlift in (" .. numArmies .. ")")
            };
            local jumpToSpot = WL.RectangleVM.Create(
                math.min(source.MiddlePointX, dest.MiddlePointX), math.min(source.MiddlePointY, dest.MiddlePointY),
                math.max(source.MiddlePointX, dest.MiddlePointX), math.max(source.MiddlePointY, dest.MiddlePointY));

            local message = "Airlift " .. numArmies .. " armies from " .. source.Name .. " to " .. dest.Name;
            if (playCard(message, MakeAirliftModData(sourceID, destID, numArmies), WL.TurnPhase.Airlift, annotations, jumpToSpot, "AirliftIcon")) then
                close();
            end
        end

        local vert = UI.CreateVerticalLayoutGroup(rootParent).SetCenter(true).SetFlexibleWidth(1);

        instructionLabel = UI.CreateLabel(vert).SetText(Instruction()).SetColor("#DDDDDD").SetAlignment(WL.TextAlignmentOptions.Center);
        errorLabel = UI.CreateLabel(vert).SetText(" ").SetColor("#FF6666").SetAlignment(WL.TextAlignmentOptions.Center);

        --Source on the left, destination on the right, and the arrow between them
        local top = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
        sourceSide = CreateSide(top, "Select Source");

        local middle = UI.CreateVerticalLayoutGroup(top).SetCenter(true).SetPreferredWidth(110);
        UI.CreateImage(middle).SetSprite("Arrow.png").SetPreferredWidth(100).SetPreferredHeight(33);
        UI.CreateLabel(middle).SetText("Airlift").SetColor("#DDDDDD").SetAlignment(WL.TextAlignmentOptions.Center);

        destSide = CreateSide(top, "Select Destination");

        sourceSide.Button.SetOnClick(function() BeginSelect(true); end);
        destSide.Button.SetOnClick(function() BeginSelect(false); end);

        --Number of armies.  The slider's range is set once a source is chosen.
        local armiesRow = UI.CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
        armiesInput = UI.CreateNumberInputField(armiesRow)
            .SetSliderMinValue(0)
            .SetSliderMaxValue(1)
            .SetValue(0)
            .SetInteractable(false)
            .SetSliderPreferredWidth(250);
        UI.CreateLabel(armiesRow).SetText("armies");

        playButton = UI.CreateButton(vert).SetText("Play").SetColor("#198225").SetPreferredWidth(250).SetOnClick(Play);
    end);
end
