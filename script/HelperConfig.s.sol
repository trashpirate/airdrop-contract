// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {ERC20Token} from "./../src/ERC20Token.sol";

contract HelperConfig is Script {
    // helpers
    uint256 constant AIRDROP_FEE = 1_000 ether;

    // chain configurations
    NetworkConfig public activeNetworkConfig;

    function getActiveNetworkConfig() public view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }

    struct NetworkConfig {
        address feeToken;
        address feeAddress;
        uint256 airdropFee;
    }

    constructor() {
        if (block.chainid == 8453 || block.chainid == 123) {
            activeNetworkConfig = getMainnetConfig();
        } else if (block.chainid == 84532 || block.chainid == 84531) {
            activeNetworkConfig = getTestnetConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getTestnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            feeToken: 0x714e4e99125c47Bd3226d8B644C147D3Ff8e1e3B,
            feeAddress: 0x7Bb8be3D9015682d7AC0Ea377dC0c92B0ba152eF,
            airdropFee: AIRDROP_FEE
        });
    }

    function getMainnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            feeToken: 0x803b629C339941e2b77D2dC499DAc9e1fD9eAC66,
            feeAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            airdropFee: AIRDROP_FEE
        });
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        ERC20Token token = new ERC20Token();
        vm.stopBroadcast();

        return NetworkConfig({
            feeToken: address(token),
            feeAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            airdropFee: AIRDROP_FEE
        });
    }
}
