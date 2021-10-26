// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // from npm/github

contract TokenFarm is Ownable {
    //mapping token address -> staker address -> amount
    mapping(address => mapping(address => uint256)) public stakingBalance; // eg { BTC: {user1: 1, user2: 1}, ETH: {user1: 1} }
    mapping(address => uint256) public uniqueTokenStaked; // { user1: 2, user2: 1 }
    mapping(address => address) public tokenPriceFeedMapping;
    address[] public stakers; // [user1, user2]
    address[] public allowedTokens; // [btc_addr, eth_add, dai_add]
    IERC20 public dappToken;

    constructor(address _dappTokenAddress) public {
        dappToken = IERC20(_dappTokenAddress);
    }

    function setPriceFeedContract(address _token, address _priceFeed)
        public
        onlyOwner
    {
        tokenPriceFeedMapping[_token] = _priceFeed;
    }

    // stakeTokens
    // unStakeTokens
    // issueTokens
    // adAllowedTokens
    // getValue

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

    function unstakeTokens(address _token) public {
        uint256 balance = stakingBalance[_token][msg.sender];
        require(balance > 0, "staking balance cannot be 0");
        IERC20(_token).transfer(msg.sender, balance);
        stakingBalance[_token][msg.sender] = 0; // reentrany attacks (?)
        uniqueTokenStaked[msg.sender] = uniqueTokenStaked[msg.sender] - 1;
        removeSenderFromStakers(msg.sender);
    }

    // loop through array, finds index of _sender, swap, with last element, then delete
    function removeSenderFromStakers(address _sender) internal {
        uint256 targetIndex;
        for (uint256 i = 1; i < stakers.length; i++) {
            if (stakers[i] == _sender) {
                targetIndex = i;
                break;
            }
        }
        stakers[targetIndex] = stakers[stakers.length - 1];
        delete stakers[stakers.length - 1];
        //stakers.length--;
    }

    function updateUniqueTokenStaked(address _user, address _token) internal {
        if (stakingBalance[_token][_user] <= 0) {
            uniqueTokenStaked[_user] = uniqueTokenStaked[_user] + 1;
        }
    }

    // 100 ETH 1:1 for every 1 ETH, we give 1 LUC token

    // instead of contract issue and send token, methods that allow user to claim token
    // less gas-expensive, we're too generous
    function issueTokens() public onlyOwner {
        // issue tokens to all stackers
        for (
            uint256 stakerIndex = 0;
            stakerIndex < stakers.length;
            stakerIndex++
        ) {
            address recipient = stakers[stakerIndex];
            uint256 userTotalValue = getUserTotalValue(recipient);
            // send them token reward
            // based on their total value locked
            dappToken.transfer(recipient, userTotalValue);
        }
    }

    function getUserTotalValue(address _user) public view returns (uint256) {
        uint256 totalValue = 0;
        require(uniqueTokenStaked[_user] > 0, "No token staked");
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ) {
            totalValue =
                totalValue +
                getUserSingleTokenValue(
                    _user,
                    allowedTokens[allowedTokensIndex]
                );
        }
        return totalValue;
    }

    function getUserSingleTokenValue(address _user, address _token)
        public
        view
        returns (uint256)
    {
        // 1 ETH -> $2,000
        // return 2000
        // 200 DAI -> $200
        // return 200
        if (uniqueTokenStaked[_user] <= 0) return 0; // keep going, so don't use require
        // price of the token * stakingBalance[token][user]
        (uint256 price, uint256 decimals) = getTokenValue(_token);
        // 10 ETH
        // ETH/USD -> 100
        // 10 * 100 = 100
        return (stakingBalance[_token][_user] * price) / (10**decimals);
    }

    function getTokenValue(address _token)
        public
        view
        returns (uint256, uint256)
    {
        // call chainLink pricefeed
        address priceFeedContract = tokenPriceFeedMapping[_token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedContract
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 decimals = uint256(priceFeed.decimals());
        return (uint256(price), decimals);
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
