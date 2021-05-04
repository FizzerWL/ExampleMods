
function Client_SaveConfigureUI(alert)
    local numTerrs = numTerrsInputField.GetValue();
    local percent = percentInputField.GetValue();

    if numTerrs < 0 then alert('Number of territories cannot be negative'); end
    if percent < 0 or percent > 100 then alert('Percentage must be between 0 and 100'); end

    Mod.Settings.NumTerritories = numTerrs;
    Mod.Settings.Percentage = percent;
end
