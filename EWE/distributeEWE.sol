// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RewardDistribution {
    address public owner;
    IERC20 public token; // The token you'll distribute (e.g., ETH)
    uint256 public totalRewards;
    mapping(address => uint256) public userRewards;
    mapping(address => bool) public isParticipant;
    mapping(address => uint256) public rewardsHistory;

    event RewardClaimed(address indexed user, uint256 amount);
    event ParticipantAdded(address indexed participant);
    event ParticipantRemoved(address indexed participant);
    event RewardsDeposited(uint256 amount);
    event RewardsDistributed(address[] recipients, uint256[] amounts);

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function addParticipant(address participant) external onlyOwner {
        isParticipant[participant] = true;
        emit ParticipantAdded(participant);
    }

    function removeParticipant(address participant) external onlyOwner {
        isParticipant[participant] = false;
        emit ParticipantRemoved(participant);
    }

    function depositRewards(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        totalRewards += amount;
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Reward transfer failed"
        );
        emit RewardsDeposited(amount);
    }

    function claimRewards() external {
        address user = msg.sender;
        require(isParticipant[user], "You are not a participant");
        uint256 userReward = userRewards[user];
        require(userReward > 0, "No rewards to claim");
        userRewards[user] = 0;
        rewardsHistory[user] += userReward;
        require(
            token.transfer(user, userReward),
            "Reward transfer failed"
        );
        emit RewardClaimed(user, userReward);
    }

    function distributeRewards(address[] memory recipients, uint256[] memory amounts)
        external
        onlyOwner
    {
        require(
            recipients.length == amounts.length,
            "Array lengths must match"
        );

        uint256 totalAmountToDistribute = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 amount = amounts[i];

            require(
                isParticipant[recipient],
                "Recipient is not a participant"
            );
            require(
                amount <= totalRewards,
                "Insufficient rewards to distribute"
            );

            userRewards[recipient] += amount;
            totalRewards -= amount;
            totalAmountToDistribute += amount;
        }

        emit RewardsDistributed(recipients, amounts);
    }

    function getUserRewardsHistory(address user) external view returns (uint256) {
        return rewardsHistory[user];
    }
}

