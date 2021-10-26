// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenFarm is Ownable {
    //mapping token address -> staker address -> amount
    mapping(address => mapping(address => uint256)) public stakingBalance; // eg { BTC: {user1: 1, user2: 1}, ETH: {user1: 1} }
    // we can't loop through a mapping
    address[] public stakers; // [user1, user2]
    address[] public allowedTokens;
    mapping(address => uint256) public uniqueTokenStaked; // { user1: 2, user2: 1 }

    // stakeTokens
    // unStakeTokens
    // issueTokens
    // adAllowedTokens
    // getEthValue

    function stakeToken(uint256 _amount, address _token) public {
        require(_amount > 0, "amount must be more than 0");
        require(tokenIsAllowed(_token), "Token is currently not allowed");
        // transferFrom on ERC20 since our TokenFarm is not the wallet owner of the token (receiver call but only if wallet owner calls approve first) and transfer (call by wallet owner)
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        updateUniqueTokenStaked(msg.sender, _token);
        stakingBalance[_token][msg.sender] =
            stakingBalance[_token][msg.sender] +
            _amount;
        if (uniqueTokenStaked[msg.sender] == 1) {
            // why don't we just do: if msg.sender in stakers (?)
            stakers.push(msg.sender);
        }
    }

    function updateUniqueTokenStaked(address _user, address _token) internal {
        if (stakingBalance[_token][_user] <= 0) {
            uniqueTokenStaked[_user] = uniqueTokenStaked[_user] + 1;
        }
    }

    // 100 ETH 1:1 for every 1 ETH, we give 1 LUC token

    function issueTokens() public onlyOwner {
        // issue tokens to all stackers
        for (uint256 stakerIndex = 0; stakerIndex < stakers.length; staker++) {
            address recipient = stakers[stakerIndex];
            // send them token reward
            // based on their total value locked
        }
    }

    function tokenIsAllowed(address _token) public view returns (bool) {
        for (
            uint256 allowedTokenIndex = 0;
            allowedTokenIndex < allowedTokens.length;
            allowedTokenIndex++
        ) {
            if (allowedTokens[allowedTokenIndex] == _token) {
                return true;
            }
        }
        return false;
    }

    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }
}
