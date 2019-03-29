require('Utilities');

function DoProposalPrompt(game, proposal) 
    local otherPlayer = game.Game.Players[proposal.PlayerOne].DisplayName(nil, false);
    UI.PromptFromList(otherPlayer .. ' has proposed an alliance with you.  Do you accept?', { AcceptProposalBtn(game, proposal), DeclineProposalBtn(game, proposal) });

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