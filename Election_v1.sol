// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Election Smart Contract version 1
// one independent contract deployment for each constituency election

contract Election {
    address private admin;//admin for this contract
    
    // basic structure of a candidate
    struct Candidate {
        string name;
        string partyName;
        string partyImage;
        uint voteCount;
    }

    string private electionName;
    string private description;
    string private constituencyName;
    uint private startDateTime;//Unix timestamp 
    uint private endDateTime;//Unix timestamp
    Candidate[] private candidates;//Array collection to store multiple candidates
    bool isWinnerDetermined = false;//a flag to confirmed election officer has tally the vote count and officially determine the winner after the election period is over
    uint private winnerIndex = type(uint).max;//set winnerIndex to maximum value to be extra safe

    constructor (
        //for version 1, set these in migration script
        //for version 2, set these from frontend along with in-demand deployment
        string memory _electionName,
        string memory _description,
        string memory _constituencyName,
        uint _startDateTime,
        uint _endDateTime,
        string[] memory candidateNames,
        string[] memory candidatePartyNames,
        string[] memory candidatePartyImages
    ) {
        admin = msg.sender; // set admin Ganache Account 1, the Election Officer
        
        //backend validation 
        require(_startDateTime < _endDateTime, "Start datetime must be before end datetime.");
        require(candidateNames.length == candidatePartyNames.length && candidateNames.length == candidatePartyImages.length, "Candidates information length mismatch.");

        //assigning variables
        electionName = _electionName;
        description = _description;
        constituencyName = _constituencyName;
        startDateTime = _startDateTime;
        endDateTime = _endDateTime;

        //push candidates from multiple arrays into the candidate collection
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                partyName: candidatePartyNames[i],
                partyImage: candidatePartyImages[i],
                voteCount: 0
            }));
        }
    }

    modifier isAdmin()
    {
        require(msg.sender == admin);
        _;
    }

    // Function to get all election information
    function getElectionInformation() public view returns (
        string memory,
        string memory,
        string memory,
        uint,
        uint,
        uint
    ) {
        return (
            electionName,
            description,
            constituencyName,
            startDateTime,
            endDateTime,
            candidates.length
        );
    }
    
    // Function to get candidate information by index
    function getCandidate(uint _index) public view returns (
        string memory,
        string memory,
        string memory,
        uint
    ) {
        // backend validation
        require(_index < candidates.length, "Candidate does not exist.");
        // load called candidates into a local object
        Candidate memory candidate = candidates[_index];
        return (
            candidate.name,
            candidate.partyName,
            candidate.partyImage,
            candidate.voteCount
        );
    }

    // Function to tally votes and set winner
    function tallyVote() public isAdmin {
        // Modifier isAdmin make sure only the contract owner (election officer) can tally vote
        // tally must be perform after the end Date Time
        require(block.timestamp > endDateTime, "Election has not ended yet.");
        uint winningVoteCount = 0;
        uint index = type(uint).max;//local level winner index for better security and efficient in concept

        // Loop through all candidates to find the one with the most votes
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                
                index = i;
            }
        }
        /*
        // Exception situation of a tie not handled...yet
        
        */

        // Store the winner index
        winnerIndex = index;
        // Set flag to true
        isWinnerDetermined = true;
    }

    // Function to get winner
    function getWinner() public view returns (
        string memory,
        string memory,
        string memory,
        uint
    ) {
        // first check whether election is over
        require(block.timestamp > endDateTime, "Election has not ended yet.");
        // second check tallyVote was run
        require(isWinnerDetermined == true, "The winner has not been determined, thank you for your patience");
        // if isWinnerDetermined is true and winnerIndex is out of bound, nobody has voted
        require(winnerIndex != type(uint).max, "Apprently Nobody has voted! Please wait for official announcement");

        // return information of winning candidates
        Candidate memory candidate = candidates[winnerIndex];
        return (
            candidate.name,
            candidate.partyName,
            candidate.partyImage,
            candidate.voteCount
        );
    }




    // Consider adding more functions as needed, e.g., for getting candidate details, election results, etc.

/* Generated code that might be useful, remove before deployment 
    // Function to allow voting for a candidate.
    // Note: Add your logic here to ensure that each eligible voter can only vote once and only within the voting period.
    function vote(uint candidateIndex) public {
        require(block.timestamp >= startDateTime, "Election has not started yet.");
        require(block.timestamp <= endDateTime, "Election has already ended.");
        require(candidateIndex < candidates.length, "Invalid candidate.");

        candidates[candidateIndex].voteCount += 1;
        // Additional logic for recording voter's address to prevent double voting, etc.
    }
*/

}