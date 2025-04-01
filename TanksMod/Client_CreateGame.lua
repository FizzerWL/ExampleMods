function Client_CreateGame(settings, alert)
    if (not settings.CommerceGame) then
        alert("This mod only works with commerce games.  Enable Commerce under Army Settings");
    end
end