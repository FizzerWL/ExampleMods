
function Server_Created(game, settings)
	errror('test');
    local overriddenBonuses = {};

    for _, bonus in pairs(game.Map.Bonuses) do
		--skip negative bonuses unless AllowNegative was checked
		if (bonus.Amount > 0 or Mod.Settings.AllowNegative) then 

			local newValue = bonus.Amount + math.random(-Mod.Settings.RandomizeAmount, Mod.Settings.RandomizeAmount);

			-- don't take a positive or zero bonus negative unless AllowNegative was checked.
			if (newValue < 0 and not Mod.Settings.AllowNegative) then
				newValue = 0;
			end

			-- -1000 to +1000 is the maximum allowed range for overridden bonuses, never go beyond that
			if (newValue < -1000) then newValue = -1000 end;
			if (newValue > 1000) then newValue = 1000 end;
		
			overriddenBonuses[bonus.ID] = newValue;
		end
    end

    settings.OverriddenBonuses = overriddenBonuses;

end

