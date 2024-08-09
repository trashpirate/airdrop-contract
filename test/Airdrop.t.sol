// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Airdrop} from "./../src/Airdrop.sol";
import {DeployAirdrop} from "./../script/DeployAirdrop.s.sol";
import {ERC20Token} from "./../src/ERC20Token.sol";
import {ExecuteAirdrop} from "../script/Interactions.s.sol";
import {HelperConfig} from "./../script/HelperConfig.s.sol";

contract Airdrop__Test is Test {
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

    function initializeInput(uint256 airdropSize, uint256 airdropAmount) public {
        accounts = new address[](airdropSize);
        amounts = new uint256[](airdropSize);
        for (uint256 i = 0; i < airdropSize; i++) {
            accounts[i] = makeAddr(string(abi.encode(i + 1)));
            amounts[i] = airdropAmount;
        }
    }

    function setUp() external virtual {
        deployment = new DeployAirdrop();
        (airdrop, helperConfig) = deployment.run();

        feeToken = ERC20Token(airdrop.getFeeToken());
        airdropToken = new ERC20Token();

        networkConfig = helperConfig.getActiveNetworkConfig();
    }

    /**
     * INITIALIZATION
     */
    function test__unit__Airdrop__Initialization() public view {
        assertEq(airdrop.getMaxRecipients(), 400);
        assertEq(airdrop.getAirdropFee(), networkConfig.airdropFee);
        assertEq(airdrop.getFeeAddress(), networkConfig.feeAddress);
        assertEq(airdrop.getFeeToken(), networkConfig.feeToken);
    }

    /**
     * CONSTRUCTOR
     */
    function test__unit__Airdrop__Deployment() public {
        (address airdropFeeToken, address feeAddress, uint256 airdropFee) = helperConfig.activeNetworkConfig();
        Airdrop airdropContract = new Airdrop(airdropFeeToken, feeAddress, airdropFee);

        assertEq(airdropContract.getAirdropFee(), networkConfig.airdropFee);
        assertEq(airdropContract.getFeeAddress(), networkConfig.feeAddress);
        assertEq(airdropContract.getFeeToken(), networkConfig.feeToken);
    }

    /**
     * AIRDROP
     */
    function test__unit__Airdrop__Airdrop() public funded(USER) tokensApproved(USER) feeApproved(USER) {
        // address array
        uint256 airdropSize = 10;
        uint256 airdropAmount = 100 ether;
        uint256 totalAirdropAmount = airdropSize * airdropAmount;
        initializeInput(airdropSize, airdropAmount);

        vm.startPrank(USER);
        airdrop.airdrop(address(airdropToken), accounts, amounts, totalAirdropAmount);
        vm.stopPrank();

        for (uint256 i = 0; i < airdropSize; i++) {
            assertEq(airdropToken.balanceOf(accounts[i]), amounts[i]);
        }
    }

    function test__unit__Airdrop__TakesFee() public funded(USER) tokensApproved(USER) feeApproved(USER) {
        // address array
        uint256 airdropSize = 10;
        uint256 airdropAmount = 100 ether;
        uint256 totalAirdropAmount = airdropSize * airdropAmount;
        initializeInput(airdropSize, airdropAmount);

        uint256 startingBalance = feeToken.balanceOf(USER);
        vm.startPrank(USER);
        airdrop.airdrop(address(airdropToken), accounts, amounts, totalAirdropAmount);
        vm.stopPrank();

        assertEq(feeToken.balanceOf(USER), startingBalance - airdrop.getAirdropFee());
    }

    function test__unit__Airdrop__TakesFeeNoFeeIfExcluded()
        public
        funded(USER)
        tokensApproved(USER)
        feeApproved(USER)
    {
        // address array
        uint256 airdropSize = 10;
        uint256 airdropAmount = 100 ether;
        uint256 totalAirdropAmount = airdropSize * airdropAmount;
        initializeInput(airdropSize, airdropAmount);

        uint256 startingBalance = feeToken.balanceOf(USER);

        address owner = airdrop.owner();
        vm.prank(owner);
        airdrop.excludeFromFee(USER, true);

        vm.startPrank(USER);
        airdrop.airdrop(address(airdropToken), accounts, amounts, totalAirdropAmount);
        vm.stopPrank();

        assertEq(feeToken.balanceOf(USER), startingBalance);
    }

    function test__unit__Airdrop__TakesFeeNoFeeIfZeroFee() public funded(USER) tokensApproved(USER) feeApproved(USER) {
        // address array
        uint256 airdropSize = 10;
        uint256 airdropAmount = 100 ether;
        uint256 totalAirdropAmount = airdropSize * airdropAmount;
        initializeInput(airdropSize, airdropAmount);

        uint256 startingBalance = feeToken.balanceOf(USER);

        address owner = airdrop.owner();
        vm.prank(owner);
        airdrop.setAirdropFee(0);

        vm.startPrank(USER);
        airdrop.airdrop(address(airdropToken), accounts, amounts, totalAirdropAmount);
        vm.stopPrank();

        assertEq(feeToken.balanceOf(USER), startingBalance);
    }

    function test__unit__Airdrop__ExceedingMaxRecipents() public funded(USER) feeApproved(USER) {
        address owner = airdrop.owner();

        vm.prank(owner);
        airdrop.setMaxRecipients(5);

        //  input
        uint256 airdropSize = 10;
        uint256 airdropAmount = 100 ether;
        uint256 totalAirdropAmount = airdropSize * airdropAmount;
        initializeInput(airdropSize, airdropAmount);

        vm.prank(USER);
        airdropToken.approve(address(airdrop), airdropSize * airdropAmount);

        vm.expectRevert(Airdrop.Airdrop__TooManyRecipients.selector);
        vm.prank(USER);
        uint256 numRecipients = airdrop.airdrop(address(airdropToken), accounts, amounts, totalAirdropAmount);
    }

    function test__unit__Airdrop__FailedTransfer() public funded(USER) feeApproved(USER) {
        // address array
        uint256 airdropSize = 10;
        uint256 airdropAmount = 100 ether;
        uint256 totalAirdropAmount = airdropSize * airdropAmount;
        initializeInput(airdropSize, airdropAmount);

        vm.prank(USER);
        airdropToken.approve(address(airdrop), airdropSize * airdropAmount);

        vm.mockCall(
            address(airdropToken),
            abi.encodeWithSelector(airdropToken.transfer.selector, accounts[5], airdropAmount),
            abi.encode(false)
        );

        vm.expectRevert(Airdrop.Airdrop__TokenTransferFailed.selector);
        vm.prank(USER);
        airdrop.airdrop(address(airdropToken), accounts, amounts, totalAirdropAmount);
    }

    function test__unit__Airdrop__RevertsWhen__FeeTokenTransferFails() public funded(USER) feeApproved(USER) {
        // address array
        uint256 airdropSize = 10;
        uint256 airdropAmount = 100 ether;
        uint256 totalAirdropAmount = airdropSize * airdropAmount;
        initializeInput(airdropSize, airdropAmount);

        vm.prank(USER);
        airdropToken.approve(address(airdrop), airdropSize * airdropAmount);

        address feeAddress = airdrop.getFeeAddress();
        uint256 fee = airdrop.getAirdropFee();
        vm.mockCall(
            address(feeToken),
            abi.encodeWithSelector(feeToken.transferFrom.selector, USER, feeAddress, fee),
            abi.encode(false)
        );

        vm.expectRevert(Airdrop.Airdrop__FeeTokenTransferFailed.selector);
        vm.prank(USER);
        airdrop.airdrop(address(airdropToken), accounts, amounts, totalAirdropAmount);
    }

    function test__unit__Airdrop__RevertsWhen__ArrayMismatch() public funded(USER) feeApproved(USER) {
        // address array
        uint256 airdropSize = 10;
        uint256 airdropAmount = 100 ether;
        uint256 totalAirdropAmount = airdropSize * airdropAmount;
        initializeInput(airdropSize, airdropAmount);
        amounts.pop();

        vm.prank(USER);
        airdropToken.approve(address(airdrop), airdropSize * airdropAmount);

        vm.expectRevert(Airdrop.Airdrop__AddressesMismatchAmounts.selector);
        vm.prank(USER);
        airdrop.airdrop(address(airdropToken), accounts, amounts, totalAirdropAmount);
    }

    function test__integration__Airdrop__Airdrop() public funded(USER) {
        ExecuteAirdrop executeAirdrop = new ExecuteAirdrop();
        executeAirdrop.airdrop(address(airdrop));
    }
}
