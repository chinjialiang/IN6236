// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Types.sol";

contract IdentityVerification {

    mapping(uint256 => Types.Identity) public identities;

    event IdentityVerified(uint256 indexed user);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function registerIdentity(string memory _fullName, uint256 _idNumber, uint256 _age) external onlyAdmin{
        require(_idNumber > 0, "ID number must be greater than zero");
        require(bytes(_fullName).length > 0, "Full name must not be empty");
        require(_age >= 0, "Age must not be empty");

        identities[_idNumber] = Types.Identity({
            fullName: _fullName,
            idNumber: _idNumber,
            isVerified: false,
            voted: false,
            age: _age
        });
    }

    function verifyIdentity(uint256 _idNumber) external {
        Types.Identity storage identity = identities[_idNumber];
        require(bytes(identity.fullName).length > 0, "Identity not registered");
        require(identity.idNumber > 0, "Invalid ID number");
        require(!identity.isVerified, "Identity already verified");
        require(identity.age >= 18, "Below voting age");

        identity.isVerified = true;
        emit IdentityVerified(_idNumber);
    }

    function getIdentity(uint256 _user) external view returns (string memory, uint256, bool, uint256) {
        Types.Identity memory identity = identities[_user];
        return (identity.fullName, identity.idNumber, identity.isVerified, identity.age);
    }

    function initializeVoterDatabase_() internal {
        identities[uint256(11111)] = Types.Identity({
            fullName: "Aby",
            idNumber: uint256(11111),
            isVerified: false,
            voted: false,
            age:20
        });
        identities[uint256(22222)] = Types.Identity({
            fullName: "George",
            idNumber: uint256(22222),
            isVerified: false,
            voted: false,
            age:50
        });
        identities[uint256(33333)] = Types.Identity({
            fullName: "Steve",
            idNumber: uint256(33333),
            isVerified: false,
            voted: false,
            age:12
        });
    }
}