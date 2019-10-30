require('Utilities');

--Remember if we've alerted the instructions so we don't do it twice
ShownInstructions = false;

function Client_GameRefresh(game)
    CheckShowInstructions(game);
end

function CheckShowInstructions(game)

    --Skip if we're not in the game.
    if (game.Us == nil) then 
        return;
    end

    --Skip if it's not the first turn
    if (game.Game.NumberOfTurns ~= 0) then
        return;
    end

    --Skip if we've already shown it
    if (ShownInstructions) then
        return;
    end

    local order = Mod.PublicGameData.PlayerOrder;
    local ourIndex = OurIndex(game.Us.ID);

    ShownInstructions = true;

    UI.Alert("This game uses the Take Turns mod.  Each player will get a turn once every " .. #order .. " turns.  When it's not your turn, you should just commit without entering any orders.  If you do enter orders, they'll be ignored.  On all but the first turn, a sanctions card will be used to remove your income so you don't have to deploy.  Your randomly-determined position is " .. (ourIndex+1));
end

function OurIndex(us)
    local ret = 0;
    for _,pid in pairs(Mod.PublicGameData.PlayerOrder) do
        if (pid == us) then
            return ret;
        end
        ret = ret + 1;
    end
    error("Not in game");
end