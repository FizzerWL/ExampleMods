

function RandomizeWastelands(game, standing)
	for _, territory in pairs(standing.Territories) do
        local numArmies = territory.NumArmies.NumArmies;
        if (territory.OwnerPlayerID == WL.PlayerID.Neutral and numArmies == game.Settings.WastelandSize) then
            local newArmies = math.random(-Mod.Settings.RandomizeAmount, Mod.Settings.RandomizeAmount) + numArmies;
            if (newArmies < 0) then newArmies = 0 end;
            if (newArmies > 100000) then newArmies = 100000 end;
            territory.NumArmies = WL.Armies.Create(newArmies);
        end
    end
end
