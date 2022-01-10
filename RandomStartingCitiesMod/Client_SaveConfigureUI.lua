
function Client_SaveConfigureUI(alert)
    local numTerritories = _numTerritoriesInputField.GetValue();
    local numCitiesPerTerritory = _numCitiesPerTerritoryInputField.GetValue();

    if (numTerritories < 1) then alert("Number of territories to place cities on must be positive"); end
    if (numCitiesPerTerritory < 1) then alert("Number of cities to place must be positive"); end
    if (numCitiesPerTerritory > 50) then alert("Number of cities to place cannot be greater than 50"); end


    Mod.Settings.NumTerritories = numTerritories;
    Mod.Settings.NumCitiesPerTerritory = numCitiesPerTerritory;
end
