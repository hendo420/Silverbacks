// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ERC721StakingRewards is Ownable, Pausable, Initializable {
    IERC721 public stakingToken;
    IERC20 public rewardToken;
    uint256 public rewardDuration = 3 * 365 * 6500;

    struct StakeInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    mapping(address => StakeInfo) public stakers;
    uint256 public totalStaked;
    uint256 public accRewardPerToken;
    uint256 public lastRewardUpdate;

    event Staked(address indexed user, uint256 tokenId);
    event Withdrawn(address indexed user, uint256 tokenId);
    event Rewards(address indexed user, uint256 amount);

    function initialize(IERC721 _stakingToken, IERC20 _rewardToken) public initializer {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
        lastRewardUpdate = block.number;
    }

    function _updateAccRewardPerToken() internal {
        if (totalStaked > 0) {
            uint256 blockElapsed = block.number - lastRewardUpdate;
            uint256 rewardAmount = rewardToken.balanceOf(address(this)) * blockElapsed / rewardDuration;
            accRewardPerToken += (rewardAmount * 1e18) / totalStaked;
        }
        lastRewardUpdate = block.number;
    }

    function _updateReward(address account) internal {
        _updateAccRewardPerToken();

        if (account != address(0)) {
            StakeInfo storage stakeInfo = stakers[account];
            stakeInfo.rewardDebt = (stakeInfo.amount * accRewardPerToken) / 1e18;
        }
    }

    function stake(uint256 tokenId) public whenNotPaused {
        stakingToken.transferFrom(msg.sender, address(this), tokenId);
        _updateReward(msg.sender);

        StakeInfo storage stakeInfo = stakers[msg.sender];
        stakeInfo.amount += 1;
        totalStaked += 1;
        emit Staked(msg.sender, tokenId);
    }

    function withdraw(uint256 tokenId) public whenNotPaused {
        StakeInfo storage stakeInfo = stakers[msg.sender];
        require(stakeInfo.amount > 0, "No staked tokens to withdraw");

        _updateReward(msg.sender);

        uint256 pendingReward = (stakeInfo.amount * accRewardPerToken) / 1e18 - stakeInfo.rewardDebt;
        if (pendingReward > 0) {
            rewardToken.transfer(msg.sender, pendingReward);
            emit Rewards(msg.sender, pendingReward);
        }

        stakingToken.transferFrom(address(this), msg.sender, tokenId);
        stakeInfo.amount -= 1;
        totalStaked -= 1;
        emit Withdrawn(msg.sender, tokenId);
    }

    function setStakingToken(IERC721 _stakingToken) public onlyOwner {
        stakingToken = _stakingToken;
    }

    function setRewardToken(IERC20 _rewardToken) public onlyOwner {
        rewardToken = _rewardToken;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function drainERC20(IERC20 token, uint256 amount) public onlyOwner {
        require(token != rewardToken, "Cannot drain reward tokens");
        token.transfer(msg.sender, amount);
    }
}
