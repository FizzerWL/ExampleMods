
function Client_SaveConfigureUI(alert)
    local turns = turnsInputField.GetValue();

    if turns < 1 then alert('Turns to get a fort must be positive'); end

    Mod.Settings.TurnsToGetFort = turns;
end
