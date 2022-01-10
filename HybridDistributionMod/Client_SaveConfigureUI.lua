
function Client_SaveConfigureUI(alert)
    local numTerritories = _numTerritoriesInputField.GetValue();

    if (numTerritories < 1) then alert("Number of territories to auto distribute must be positive"); end


    Mod.Settings.NumTerritories = numTerritories;
end
