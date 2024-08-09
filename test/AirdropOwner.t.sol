// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Airdrop} from "./../src/Airdrop.sol";
import {DeployAirdrop} from "./../script/DeployAirdrop.s.sol";
import {ERC20Token} from "./../src/ERC20Token.sol";
import {HelperConfig} from "./../script/HelperConfig.s.sol";

contract AirdropOwner__Test is Test {
    // configuration
    DeployAirdrop deployment;
    HelperConfig helperConfig;
    HelperConfig.NetworkConfig networkConfig;

    // contracts
    Airdrop airdrop;
    ERC20Token airdropToken;
    ERC20Token feeToken;

    // helpers
    address USER = makeAddr("user");
    uint256 TOKENS = 10_000_000 ether;

    address[] accounts;
    uint256[] amounts;

    // events
    event AirdropFeeSet(address indexed sender, uint256 indexed amount);
    event MaxRecipientsSet(address indexed sender, uint256 indexed amount);
    event FeeAddressSet(address indexed sender, address indexed account);
    event FeeTokenSet(address indexed sender, address indexed token);
    event ExcludedFromFeeSet(address indexed sender, address indexed account, bool indexed isExcluded);

    // modifiers
    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    modifier funded(address account) {
        // fund user with tokens
        airdropToken.transfer(account, TOKENS);

        address feeTokenOwner = feeToken.owner();
        vm.prank(feeTokenOwner);
        feeToken.transfer(account, TOKENS);
        _;
    }

    modifier tokensApproved(address account) {
        uint256 allTokens = airdropToken.balanceOf(account);

        // approve fee amount
        vm.prank(account);
        airdropToken.approve(address(airdrop), allTokens);
        _;
    }

    modifier feeApproved(address account) {
        uint256 fee = airdrop.getAirdropFee();
        // approve fee amount
        vm.prank(account);
        feeToken.approve(address(airdrop), fee);
        _;
    }

    function setUp() external virtual {
        deployment = new DeployAirdrop();
        (airdrop, helperConfig) = deployment.run();

        feeToken = ERC20Token(airdrop.getFeeToken());
        airdropToken = new ERC20Token();

        networkConfig = helperConfig.getActiveNetworkConfig();
    }

    /**
     * SET MAX RECIPIENTS
     */
    function test__unit__Airdrop__SetGasLimit() public {
        uint256 maxRecipients = 100;

        address owner = airdrop.owner();

        vm.prank(owner);
        airdrop.setMaxRecipients(maxRecipients);
        assertEq(airdrop.getMaxRecipients(), maxRecipients);
    }

    function test__unit__Airdrop__EmitEvent__SetGasLimit() public {
        uint256 maxRecipients = 100;
        address owner = airdrop.owner();

        vm.expectEmit(true, true, true, true);
        emit MaxRecipientsSet(owner, maxRecipients);

        vm.prank(owner);
        airdrop.setMaxRecipients(maxRecipients);
    }

    /**
     * SET FEE
     */
    function test__unit__Airdrop__SetAirdropFee() public {
        uint256 fee = 1_000_000 ether;

        address owner = airdrop.owner();

        vm.prank(owner);
        airdrop.setAirdropFee(fee);
        assertEq(airdrop.getAirdropFee(), fee);
    }

    function test__unit__Airdrop__EmitEvent__SetAirdropFee() public {
        uint256 fee = 1_000_000 ether;

        address owner = airdrop.owner();

        vm.expectEmit(true, true, true, true);
        emit AirdropFeeSet(owner, fee);

        vm.prank(owner);
        airdrop.setAirdropFee(fee);
    }

    /**
     * SET FEE ADDRESS
     */
    function test__unit__Airdrop__SetFeeAddress() public {
        address feeAddress = makeAddr("new-fee-address");

        address owner = airdrop.owner();

        vm.prank(owner);
        airdrop.setFeeAddress(feeAddress);
        assertEq(airdrop.getFeeAddress(), feeAddress);
    }

    function test__unit__Airdrop__EmitEvent__SetFeeAddress() public {
        address feeAddress = makeAddr("new-fee-address");

        address owner = airdrop.owner();

        vm.expectEmit(true, true, true, true);
        emit FeeAddressSet(owner, feeAddress);

        vm.prank(owner);
        airdrop.setFeeAddress(feeAddress);
    }

    function test__unit__Airdrop__RevertWhen__FeeAddressIsZero() public {
        address feeAddress = address(0);
        address owner = airdrop.owner();
        vm.prank(owner);

        vm.expectRevert(Airdrop.Airdrop__FeeAddressIsZeroAddress.selector);
        airdrop.setFeeAddress(feeAddress);
    }

    /**
     * SET FEE TOKEN
     */
    function test__unit__Airdrop__SetFeeToken() public {
        address tokenAddress = makeAddr("new-fee-token");

        address owner = airdrop.owner();

        vm.prank(owner);
        airdrop.setFeeToken(tokenAddress);
        assertEq(airdrop.getFeeToken(), tokenAddress);
    }

    function test__unit__Airdrop__EmitEvent__SetFeeToken() public {
        address tokenAddress = makeAddr("new-fee-token");

        address owner = airdrop.owner();

        vm.expectEmit(true, true, true, true);
        emit FeeTokenSet(owner, tokenAddress);

        vm.prank(owner);
        airdrop.setFeeToken(tokenAddress);
    }

    function test__unit__Airdrop__RevertWhen__TokenAddressIsZero() public {
        address tokenAddress = address(0);
        address owner = airdrop.owner();
        vm.prank(owner);

        vm.expectRevert(Airdrop.Airdrop__FeeTokenIsZeroAddress.selector);
        airdrop.setFeeToken(tokenAddress);
    }

    /**
     * EXCLUDE FROM FEE
     */
    function test__unit__Airdrop__ExcludedFromFee() public {
        assertEq(airdrop.isExcluded(USER), false);

        address owner = airdrop.owner();

        vm.prank(owner);
        airdrop.excludeFromFee(USER, true);
        assertEq(airdrop.isExcluded(USER), true);
    }

    function test__unit__Airdrop__EmitEvent__ExcludedFromFee() public {
        address owner = airdrop.owner();

        vm.expectEmit(true, true, true, true);
        emit ExcludedFromFeeSet(owner, USER, true);

        vm.prank(owner);
        airdrop.excludeFromFee(USER, true);
    }
}
