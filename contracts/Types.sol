// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Types {
    struct Identity {
        string fullName;
        uint256 idNumber;
        bool isVerified;
    }

    struct Candidate {
        string name;
        string partyName;
        string partyImage;
        uint voteCount;
    }
}
