// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenFarm is Ownable {
    // stakeTokens
    // unStakeTokens
    // issueTokens
    // adAllowedTokens
    // getEthValue

    address[] public allowedTokens;

    function stakeToken(uint256 _amount, address _token) public {
        require(_amount > 0, "amount must be more than 0");
        require(tokenIsAllowed(_token), "Token is currently not allowed");
        // transferFrom (receiver call but only if wallet owner calls approve first) and transfer (call by wallet owner)
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
