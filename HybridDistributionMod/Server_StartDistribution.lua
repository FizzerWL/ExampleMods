require('Utilities');

function Server_StartDistribution(game, standing)
    local terrs = {};

    --Collect every territory that we could distribute to
    for _,territory in pairs(standing.Territories) do
        if (territory.OwnerPlayerID ~= WL.PlayerID.AvailableForDistribution) then
            table.insert(terrs, territory);
        end
    end

    --Randomize order
    shuffle(terrs);

    --Collect all players that are eligible for being distributed to
    local players = {};

    for _,gp in pairs(game.Game.PlayingPlayers) do
        table.insert(players, gp);
    end
    
    local numTerrs = Mod.Settings.NumTerritories; --num territories each player will get
    if (numTerrs * #players > #terrs) then numTerrs = math.floor(#terrs / #players); end; --if there are fewer terrs than what's requested, reduce how many we'll change

    --Change owners to players
    local i = 1;
    for terrIndex=1,numTerrs do
        for _,gp in pairs(players) do
            terrs[i].OwnerPlayerID = gp.ID;
            i = i + 1;
        end
    end
end

