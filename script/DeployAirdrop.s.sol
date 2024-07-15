// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Airdrop} from "./../src/Airdrop.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {ERC20Token} from "./../src/ERC20Token.sol";

contract DeployAirdrop is Script {
    function run() external returns (Airdrop, HelperConfig) {
        HelperConfig config = new HelperConfig();

        (address feeToken, address feeAddress, uint256 airdropFee) = config.activeNetworkConfig();

        vm.startBroadcast();
        Airdrop airdrop = new Airdrop(feeToken, feeAddress, airdropFee);
        vm.stopBroadcast();
        return (airdrop, config);
    }
}
