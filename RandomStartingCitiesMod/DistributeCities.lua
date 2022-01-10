require('Utilities');

function DistributeCities(game, standing)

    local terrs = {};
    --First, loop through and extract all possible territories we could put cities on
	for _, territory in pairs(standing.Territories) do
        if (territory.OwnerPlayerID == WL.PlayerID.Neutral) then
            table.insert(terrs, territory);
        end
    end

    --Randomize order of table
    shuffle(terrs);

    local numTerrs = Mod.Settings.NumTerritories;
    if (numTerrs > #terrs) then numTerrs = #terrs; end; --if we request more territories than we have, cap it.

    --Then loop up to the number of territories we need to distribute on
    for i=1,numTerrs do
        local s = terrs[i].Structures;
        if (s == nil) then s = {}; end;
        s[WL.StructureType.City] = Mod.Settings.NumCitiesPerTerritory;
        terrs[i].Structures = s;
    end

end
