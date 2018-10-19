require('Utilities');
require('Client');

--remembers what proposal IDs and alliance IDs we've alerted the player about so we don't alert them twice.
HighestAllianceIDSeen = 0;
HighestProposalIDSeen = 0; 

function Client_GameRefresh(game)

    if (HighestAllianceIDSeen == 0 and Mod.PlayerGameData.HighestAllianceIDSeen ~= nil and Mod.PlayerGameData.HighestAllianceIDSeen > HighestAllianceIDSeen) then
        HighestAllianceIDSeen = Mod.PlayerGameData.HighestAllianceIDSeen;
    end

    --Check for proposals we haven't alerted the player about yet
    for _,proposal in pairs(filter(Mod.PlayerGameData.PendingProposals or {}, function(proposal) return HighestProposalIDSeen < proposal.ID end)) do
        DoProposalPrompt(game, proposal);
        if (HighestProposalIDSeen < proposal.ID) then
            HighestProposalIDSeen = proposal.ID;
        end
    end

    --Notify players of new alliances via UI.Alert()
    local unseenAlliances = filter(Mod.PublicGameData.Alliances or {}, function(alliance) return HighestAllianceIDSeen < alliance.ID end);
    if (#unseenAlliances > 0) then
        for _,alliance in pairs(unseenAlliances) do
            if (HighestAllianceIDSeen < alliance.ID) then
                HighestAllianceIDSeen = alliance.ID;
            end
        end

        local msgs = map(unseenAlliances, function(alliance)
            local playerOne = game.Game.Players[alliance.PlayerOne].DisplayName(nil, false);
			local playerTwo = game.Game.Players[alliance.PlayerTwo].DisplayName(nil, false);
			return playerOne .. ' and ' .. playerTwo .. ' are now allied until turn ' .. (alliance.ExpiresOnTurn+1) .. '!';
        end);
        local finalMsg = table.concat(msgs, '\n');

        --Let the server know we've seen it.  Wait on doing the alert until after the message is received just to avoid two things appearing on the screen at once.
        local payload = {};
        payload.Message = 'SeenAllianceMessage';
        payload.HighestAllianceIDSeen = HighestAllianceIDSeen;
        game.SendGameCustomMessage('Read receipt...', payload, function(returnValue)
            UI.Alert(finalMsg);
        end);
        
    end

end