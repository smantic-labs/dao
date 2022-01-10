// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;
/// @title MuichiroDao
contract MuichiroDao {

    uint totalVoters;
    uint totalProposals;


    // vault is the receiptent of membership fees. 
    address payable vault; 

    enum ProposalType{ ImmediateBan, Ban,  Whitelist, ResetWorld }
    uint[8] Times = [ 1 hours, 1 days, 1 days, 1 weeks ];
    uint[8] RequiredPercentage = [ 60, 30, 30, 75  ];

    struct Proposal { 
        ProposalType kind;
        uint startTime;

        uint pro;
    }
    
    struct Voter {
        uint weight;
        uint[8] votes;

        address delegate;
    }

    Proposal[8] public proposals;

    mapping(address => Voter) public voters; 

    event CreatedProposal(uint indexed ProposalID, ProposalType indexed kind, string data );
    event FinishedProposal(uint indexed ProposalID, ProposalType indexed kind, uint startTime, uint pro, uint totalVoters, bool passed);
    event VoteEvent(uint indexed ProposalID, address voter);

    constructor(address payable _vault){ 
        vault = _vault
    }

    function NewProposal(ProposalType t, string calldata data) public {
        //  we have 8 proposal slots, 
        //  to add a new proposal, the slot should be empty
        //  or the prev proposal should have ended.

        // TODO: if type is reset world, ensure it is unique.

        uint proposalID = totalProposals + 1;
        uint pID = proposalID % 8;
        Proposal memory prev = proposals[pID];

        require(block.timestamp > prev.startTime + Times[uint(prev.kind)], "must wait for the next proposal to end");

        proposals[pID] = Proposal({kind: t, startTime: block.timestamp, pro: 0});

        totalProposals++;
        emit CreatedProposal(proposalID, t, data);
    }

    function Vote(uint proposalID) public { 
        // requirements to vote 
        // 1. is a valid voter 
        // 2. voter hasnt voted yet
        // 3. proposal has started
        // 4. proposal hasnt ended

        uint pid = proposalID % 8;
        Proposal storage proposal = proposals[pid];
        Voter storage voter = voters[msg.sender];
        uint votedAt = voter.votes[pid];

        assert(voter.weight > 0);
        assert(voter.delegate == msg.sender);
        assert(votedAt < proposal.startTime, "already voted for this proposal");
        assert(block.timestamp > proposal.startTime );
        assert(block.timestamp < proposal.startTime + Times[uint(proposal.kind)]);

        proposal.pro++;
        voter.votes[pid] = block.timestamp ;

        emit VoteEvent(proposalID, msg.sender);
    }


    function CompleteProposal(uint proposalID) public {
        // no restriction on completing a proposal more than once.  
        // but we cant vote on a proposal past its end

        uint pID = proposalID % 8;
        Proposal storage proposal = proposals[pID];
        uint time = Times[uint(proposal.kind)];
        uint required = RequiredPercentage[uint(proposal.kind)];

        assert(block.timestamp > proposal.startTime + time);

        bool passed;

        if ((proposal.pro * 100) / totalVoters  > required){
            passed = true;
        }
        else {
            passed = false;
        }

        emit FinishedProposal(proposalID, proposal.kind, proposal.startTime, proposal.pro, totalVoters, passed);
    }


    function Voter(address addr) public payable { 
        // Become a voter or pay for someone else to become a voter. 

        // value should be 0.05 eth
        assert(msg.value >= 50000000000000000);
        Voter storage voter = Voters[addr];
        assert(voter.weight == 0);

        bool sent = vault.send(msg.value);

        require(sent == true, "failed to send eth to vault");

        voter.weight = 1;
        voter.delegate = addr;
    }


    function Delegate(address _delegate) public { 
        // Delegate your vote to someone else 
        // Delegate to yourself to unassign delagation.
        // cannot delegate if you are not a valid voter.
        // cannot delegate to a non voter
        Voter storage voter = Voters[msg.sender]
        Voter storage delegate = Voters[_delegate) 

        assert(voter.weight != 0);
        assert(delegate.weight != 0);

        voter.delegate = _delegate;

        delegate.weight++;
    }
}
