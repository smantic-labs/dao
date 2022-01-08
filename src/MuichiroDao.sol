// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;
/// @title 
contract MuichiroDao {

    int totalVoters;
    int totalProposals;

    enum ProposalTypes { Ban, ImmediateBan, Whitelist, ResetWorld }

    Proposal[8] public proposals;

    struct Proposal { 
        uint startTime
        uint endTime 

        uint pro   
    }
    
    struct Voter {
        bool weight
        [8]uint votes
    }

    mapping(address => Voter) public voters; 

    function NewProposal(ProposalType t) public {

        pID = totalProposals + 1
        prev = proposals[pID % 8] 
        require(block.timestamp > prev.endTime, "must wait for the next proposal to end")

        if (t == ProposalTypes.Ban)


        proposals.push({ 
            starTime: block.Timestamp, 
            endTime: block.Timestamp + ,
        })

        totalProposals++
    }


    function Vote(uint proposalID) public { 
        voter = voters[msg.sender]
        pid = proposalID % 8

        // must be a valid voter
        require(voter.weight > 0)

        proposal = proposals[pid]
        votedAt = voter.votes[pid]

        require(votedAt < proposal.startTime, "already voted for this proposal")

        proposal.pro++
        voter.votes[pid] = block.timestamp 

    }
}
