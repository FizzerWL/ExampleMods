require('Utilities');

IDsSeen = {}; --remembers what proposal IDs and alliance IDs we've alerted the player about so we don't alert them twice.

function Client_GameRefresh(game)
    --Check for proposals we haven't alerted the player about yet
    for _,proposal in pairs(filter(Mod.PlayerGameData.PendingProposals or {}, function(proposal) return IDsSeen[proposal.ID] == nil end)) do
        local otherPlayer = game.Game.Players[proposal.PlayerOne].DisplayName(nil, false);
        UI.PromptFromList(otherPlayer .. ' has proposed an alliance with you for ' .. proposal.NumTurns .. ' turns.  Do you accept?', { AcceptProposalBtn(game, proposal), DeclineProposalBtn(game, proposal) });

        IDsSeen[proposal.ID] = true;
    end

    --Notify players of new alliances via UI.Alert()
    local unseenAlliances = filter(Mod.PublicGameData.Alliances or {}, function(alliance) return IDsSeen[alliance.ID] == nil end);
    if (#unseenAlliances > 0) then
        for _,alliance in pairs(unseenAlliances) do
            IDsSeen[alliance.ID] = true;
        end

        local msgs = map(unseenAlliances, function(alliance)
            local playerOne = game.Game.Players[alliance.PlayerOne].DisplayName(nil, false);
			local playerTwo = game.Game.Players[alliance.PlayerTwo].DisplayName(nil, false);
			return playerOne .. ' and ' .. playerTwo .. ' are now allied until turn ' .. (alliance.ExpiresOnTurn+1) .. '!';
        end);
        local finalMsg = table.concat(msgs, '\n');
        UI.Alert(finalMsg);
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