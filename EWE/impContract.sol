pragma solidity ^0.8.0;

contract ProofOfEnvironment {
    struct Submission {
        address submitter;
        string mediaHash;
        bool agreement;
    }

    Submission[] public submissions;

    function submitProof(address ethAddress, string memory mediaHash, bool agreement) public {
        require(agreement == true, "You must agree to the PoE agreement.");
        submissions.push(Submission(msg.sender, mediaHash, agreement));
    }

    // Add functions for retrieving submissions as needed
}
