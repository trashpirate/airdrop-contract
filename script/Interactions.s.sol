// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {Airdrop} from "./../src/Airdrop.sol";
import {ERC20Token} from "./../src/ERC20Token.sol";

contract ExecuteAirdrop is Script {
    function airdrop(address recentContractAddress) public {
        uint256 airdropSize = 100;
        uint256 airdropAmount = 100 ether;
        uint256 totalAirdropAmount = airdropSize * airdropAmount;
        address[] memory accounts = new address[](airdropSize);
        uint256[] memory amounts = new uint256[](airdropSize);
        for (uint256 i = 0; i < airdropSize; i++) {
            accounts[i] = makeAddr(string(abi.encode(i + 1)));
            amounts[i] = airdropAmount;
        }

        vm.startBroadcast();
        ERC20Token token = new ERC20Token();

        token.approve(recentContractAddress, airdropSize * airdropAmount);

        address feeToken = Airdrop(recentContractAddress).getFeeToken();
        uint256 airdropFee = Airdrop(recentContractAddress).getAirdropFee();

        ERC20Token(feeToken).approve(recentContractAddress, airdropFee);

        uint256 gasLeft = gasleft();
        uint256 numOfRecipient =
            Airdrop(recentContractAddress).airdrop(address(token), accounts, amounts, totalAirdropAmount);
        console.log("Airdrop gas: ", gasLeft - gasleft());
        console.log("Number of Recipients: ", numOfRecipient);

        vm.stopBroadcast();
    }

    function run() external {
        address recentContractAddress = DevOpsTools.get_most_recent_deployment("Airdrop", block.chainid);
        airdrop(recentContractAddress);
    }
}
