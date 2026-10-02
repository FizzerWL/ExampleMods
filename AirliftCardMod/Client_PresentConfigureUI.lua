require('Utilities')

function Client_PresentConfigureUI(rootParent)

    if (not WL.IsVersionOrHigher(RequiredVersion)) then
        UI.Alert("You must update your app to the latest version to use the Airlift Card mod");
        return;
    end

    local vert = UI.CreateVerticalLayoutGroup(rootParent);

    local horz = UI.CreateHorizontalLayoutGroup(vert);
    UI.CreateLabel(horz).SetText('Number of pieces to divide the card into').SetPreferredWidth(290);
    numPieces = UI.CreateNumberInputField(horz)
        .SetSliderMinValue(1)
        .SetSliderMaxValue(11)
        .SetValue(Mod.Settings.NumPieces or 6);

    local horz = UI.CreateHorizontalLayoutGroup(vert);
    UI.CreateLabel(horz).SetText('Card weight (how common the card is)').SetPreferredWidth(290);
    cardWeight = UI.CreateNumberInputField(horz)
        .SetWholeNumbers(false)
        .SetSliderMinValue(0)
        .SetSliderMaxValue(5)
        .SetValue(Mod.Settings.CardWeight or 1.0);

    local horz = UI.CreateHorizontalLayoutGroup(vert);
    UI.CreateLabel(horz).SetText('Minimum pieces awarded per turn').SetPreferredWidth(290);
    minPieces = UI.CreateNumberInputField(horz)
        .SetSliderMinValue(0)
        .SetSliderMaxValue(5)
        .SetValue(Mod.Settings.MinPieces or 0);

    local horz = UI.CreateHorizontalLayoutGroup(vert);
    UI.CreateLabel(horz).SetText('Pieces given to each player at the start').SetPreferredWidth(290);
    initialPieces = UI.CreateNumberInputField(horz)
        .SetSliderMinValue(0)
        .SetSliderMaxValue(5)
        .SetValue(Mod.Settings.InitialPieces or 0);

end
