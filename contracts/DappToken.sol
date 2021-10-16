// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// yield farm/ liquidity farm token contract that user interact with (ERC20)

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DappToken is ERC20 {
    constructor() public ERC20("Luckin Token", "LUC") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}
