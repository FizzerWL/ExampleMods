require('Utilities');

--remembers what proposal IDs and alliance IDs we've alerted the player about so we don't alert them twice.
HighestAllianceIDSeen = 0;
HighestProposalIDSeen = 0; 

function Client_GameRefresh(game)

    if (HighestAllianceIDSeen == 0 and Mod.PlayerGameData.HighestAllianceIDSeen ~= nil and Mod.PlayerGameData.HighestAllianceIDSeen > HighestAllianceIDSeen) then
        HighestAllianceIDSeen = Mod.PlayerGameData.HighestAllianceIDSeen;
    end

    --Check for proposals we haven't alerted the player about yet
    for _,proposal in pairs(filter(Mod.PlayerGameData.PendingProposals or {}, function(proposal) return HighestProposalIDSeen < proposal.ID end)) do
        local otherPlayer = game.Game.Players[proposal.PlayerOne].DisplayName(nil, false);
        UI.PromptFromList(otherPlayer .. ' has proposed an alliance with you for ' .. proposal.NumTurns .. ' turns.  Do you accept?', { AcceptProposalBtn(game, proposal), DeclineProposalBtn(game, proposal) });

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

function AcceptProposalBtn(game, proposal)
	local ret = {};
	ret["text"] = 'Accept';
	ret["selected"] = function() 
        local payload = {};
        payload.Message = "AcceptProposal";
        payload.ProposalID = proposal.ID;
		game.SendGameCustomMessage('Accepting proposal...', payload, function(returnValue) end);
	end
	return ret;
end


function DeclineProposalBtn(game, proposal)
	local ret = {};
	ret["text"] = 'Decline';
	ret["selected"] = function() 
        local payload = {};
        payload.Message = "DeclineProposal";
        payload.ProposalID = proposal.ID;
		game.SendGameCustomMessage('Declining proposal...', payload, function(returnValue) end);
	end
	return ret;
end