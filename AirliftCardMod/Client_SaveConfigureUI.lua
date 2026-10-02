function Client_SaveConfigureUI(alert, addCard)
    if (numPieces == nil) then
        return; --Client_PresentConfigureUI didn't build the UI because the app is out of date
    end

    Mod.Settings.NumPieces = numPieces.GetValue();
    Mod.Settings.CardWeight = cardWeight.GetValue();
    Mod.Settings.MinPieces = minPieces.GetValue();
    Mod.Settings.InitialPieces = initialPieces.GetValue();

    if (Mod.Settings.NumPieces < 1) then
        alert("Number of pieces cannot be less than 1");
        return;
    end
    if (Mod.Settings.CardWeight < 0) then
        alert("Card weight cannot be less than 0");
        return;
    end
    if (Mod.Settings.MinPieces < 0) then
        alert("Minimum pieces cannot be less than 0");
        return;
    end
    if (Mod.Settings.InitialPieces < 0) then
        alert("Initial pieces cannot be less than 0");
        return;
    end

    addCard("Airlift Card", "Play this card to move armies from one of your territories to another territory that you or a teammate control, no matter how far apart they are.  The armies move after deployments and before attacks.", "AirliftCard.png", Mod.Settings.NumPieces, Mod.Settings.MinPieces, Mod.Settings.InitialPieces, Mod.Settings.CardWeight);
end
