require('Utilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
    if (payload.Message == "Propose") then
		--Create a proposal
		local proposal = {};
		proposal.ID = math.random(2000000000);
		proposal.PlayerOne = playerID;
		proposal.PlayerTwo = payload.TargetPlayerID;
		proposal.NumTurns = payload.NumTurns;

		if (game.Settings.SinglePlayer) then
			--In single-player, just auto-accept proposals for testing.
			ProposalAccepted(proposal, game);
		else
			--Write it into the player-specific data
			local playerData = Mod.PlayerGameData;
			if (playerData[payload.TargetPlayerID] == nil) then
				playerData[payload.TargetPlayerID] = {};
			end

			local pendingProposals = playerData[payload.TargetPlayerID].PendingProposals or {};
			table.insert(pendingProposals, proposal);
			playerData[payload.TargetPlayerID].PendingProposals = pendingProposals;
			Mod.PlayerGameData = playerData;
		end
	elseif (payload.Message == "AcceptProposal" or payload.Message == "DeclineProposal") then
		local proposal = first(Mod.PlayerGameData[playerID].PendingProposals, function(prop) return prop.ID == payload.ProposalID end);

		if (proposal == nil) then error("Proposal with ID " .. payload.ProposalID .. ' not found') end;

		--Remove it from PlayerGameData
		local pgd = Mod.PlayerGameData;
		pgd[playerID].PendingProposals = filter(pgd[playerID].PendingProposals, function(prop) return prop.ID ~= payload.ProposalID end);
		Mod.PlayerGameData = pgd;

		--If we're accepting it, call ProposalAccepted. If we're declining it, just do nothing and let it be removed.
		if (payload.Message == "AcceptProposal") then
			ProposalAccepted(proposal, game);
		end
	else
		error("Payload message not understood (" .. payload.Message + ")");
	end

end


function ProposalAccepted(proposal, game)
	--Create the alliance
	local alliance = {};
	alliance.ID = math.random(2000000000);
	alliance.PlayerOne = proposal.PlayerOne;
	alliance.PlayerTwo = proposal.PlayerTwo;
	alliance.ExpiresOnTurn = game.Game.NumberOfTurns + proposal.NumTurns;

	--Write it into Mod.PublicGameData for all to see
	local data = Mod.PublicGameData;
	local alliances = data.Alliances or {};
	table.insert(alliances, alliance);
	data.Alliances = alliances;
	Mod.PublicGameData = data;
end
