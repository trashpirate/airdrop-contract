// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Token is ERC20, Ownable {
    constructor() ERC20("AirdropToken", "ATKN") Ownable(msg.sender) {
        _mint(msg.sender, 1_000_000_000 * 10 ** decimals());
    }
}
