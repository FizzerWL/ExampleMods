require('Utilities');

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
    if (payload.Message == "Propose") then
		--Create a proposal
		local proposal = {};
		proposal.ID = NewIdentity();
		proposal.PlayerOne = playerID;
		proposal.PlayerTwo = payload.TargetPlayerID;

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

		if (proposal == nil) then return; end; --skip if the proposal ID is invalid.  This can happen if it gets accepted/declined twice

		--Remove it from PlayerGameData
		local pgd = Mod.PlayerGameData;
		pgd[playerID].PendingProposals = filter(pgd[playerID].PendingProposals, function(prop) return prop.ID ~= payload.ProposalID end);
		Mod.PlayerGameData = pgd;

		--If we're accepting it, call ProposalAccepted. If we're declining it, just do nothing and let it be removed.
		if (payload.Message == "AcceptProposal") then
			ProposalAccepted(proposal, game);
		end
	elseif (payload.Message == 'SeenAllianceMessage') then
		
		local playerData = Mod.PlayerGameData;
		if (playerData[playerID] == nil) then
			playerData[playerID] = {};
		end
		playerData[playerID].HighestAllianceIDSeen = payload.HighestAllianceIDSeen;
		Mod.PlayerGameData = playerData;
	elseif (payload.Message == 'SeenAlerts') then
		local playerData = Mod.PlayerGameData;
		if (playerData[playerID] == nil) then
			playerData[playerID] = {};
		end
		playerData[playerID].Alerts = nil;
		Mod.PlayerGameData = playerData;
	else
		error("Payload message not understood (" .. payload.Message .. ")");
	end

end

function ProposalAccepted(proposal, game)
	
	--Create the alliance
	local alliance = {};
	alliance.ID = NewIdentity();
	alliance.PlayerOne = proposal.PlayerOne;
	alliance.PlayerTwo = proposal.PlayerTwo;

	local data = Mod.PublicGameData;
	local alliances = data.Alliances or {};

	--Do we already have an alliance? Remove it if so.
	alliances = filter(alliances, function(a) return not ((a.PlayerOne == alliance.PlayerOne and a.PlayerTwo == alliance.PlayerTwo) or (a.PlayerOne == alliance.PlayerTwo and a.PlayerTwo == alliance.PlayerOne)) end);

	--Write it into Mod.PublicGameData for all to see
	table.insert(alliances, alliance);
	data.Alliances = alliances;
	Mod.PublicGameData = data;
end
