// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Airdrop Contract
/// @author Nadina Oates
/// @notice Contract to perform airdrop of ERC20 tokens to different wallets
contract Airdrop is Ownable {
    /**
     * Storage Variables
     */
    uint256 private s_maxRecipients = 400;

    IERC20 private s_feeToken;
    address private s_feeAddress;
    uint256 private s_airdropFee;

    mapping(address account => bool excluded) private s_excludedFromFee;

    /**
     * Events
     */
    event AirdropFeeSet(address indexed sender, uint256 indexed amount);
    event MaxRecipientsSet(address indexed sender, uint256 indexed amount);
    event FeeAddressSet(address indexed sender, address indexed account);
    event FeeTokenSet(address indexed sender, address indexed token);
    event ExcludedFromFeeSet(address indexed sender, address indexed account, bool indexed isExcluded);

    /**
     * Errors
     */
    error Airdrop__AddressesMismatchAmounts();
    error Airdrop__FeeTokenTransferFailed();
    error Airdrop__FeeAddressIsZeroAddress();
    error Airdrop__FeeTokenIsZeroAddress();
    error Airdrop__TokenTransferFailed();
    error Airdrop__TooManyRecipients();

    constructor(address feeToken, address feeAddress, uint256 airdropFee) Ownable(msg.sender) {
        s_feeToken = IERC20(feeToken);
        s_feeAddress = feeAddress;
        s_airdropFee = airdropFee;
        _excludeFromFee(msg.sender, true);
    }

    /**
     * @notice Execute airdrop of ERC20 tokent to multiple address
     * @param token ERC20 token address
     * @param recipients Airdrop recipient addresses
     * @param amounts Airdrop amounts associated with address
     */
    function airdrop(address token, address[] calldata recipients, uint256[] calldata amounts, uint256 totalAmount)
        external
        returns (uint256 numOfRecipients)
    {
        if (recipients.length != amounts.length) revert Airdrop__AddressesMismatchAmounts();
        if (recipients.length > s_maxRecipients) revert Airdrop__TooManyRecipients();

        if (!s_excludedFromFee[msg.sender] && s_airdropFee > 0) {
            bool fee_success = s_feeToken.transferFrom(msg.sender, s_feeAddress, s_airdropFee);
            if (!fee_success) {
                revert Airdrop__FeeTokenTransferFailed();
            }
        }

        bool funding_success = IERC20(token).transferFrom(msg.sender, address(this), totalAmount);
        if (!funding_success) {
            revert Airdrop__TokenTransferFailed();
        }

        uint256 i = 0;
        while (i < recipients.length) {
            bool transfer_success = IERC20(token).transfer(recipients[i], amounts[i]);
            if (!transfer_success) {
                revert Airdrop__TokenTransferFailed();
            }

            unchecked {
                i++;
            }
        }
        numOfRecipients += i;
    }
    // 2760802
    // 2723877
    // 2660830
    // 2650470

    /**
     * @notice Sets the maximum gas limit allowed for airdrop (only owner)
     * @param maxRecipients Maximum gas limit allowed for airdrop transaction
     */
    function setMaxRecipients(uint256 maxRecipients) external onlyOwner {
        s_maxRecipients = maxRecipients;
        emit MaxRecipientsSet(msg.sender, maxRecipients);
    }

    /**
     * @notice Sets airdrop fee in ERC20 (only owner)
     * @param fee New fee in ERC20
     */
    function setAirdropFee(uint256 fee) external onlyOwner {
        s_airdropFee = fee;
        emit AirdropFeeSet(msg.sender, fee);
    }

    /**
     * @notice Sets the receiver address for the airdrop fee (only owner)
     * @param feeAddress New receiver address for tokens
     */
    function setFeeAddress(address feeAddress) external onlyOwner {
        if (feeAddress == address(0)) {
            revert Airdrop__FeeAddressIsZeroAddress();
        }
        s_feeAddress = feeAddress;
        emit FeeAddressSet(msg.sender, feeAddress);
    }

    /**
     * @notice Sets the token used for the airdrop fee (only owner)
     * @param feeToken ERC20 token address used for airdrop fee
     */
    function setFeeToken(address feeToken) external onlyOwner {
        if (feeToken == address(0)) {
            revert Airdrop__FeeTokenIsZeroAddress();
        }
        s_feeToken = IERC20(feeToken);
        emit FeeTokenSet(msg.sender, feeToken);
    }

    /**
     * @notice Includes/Excludes wallet from fee
     * @param account Address to be updates
     * @param _isExcluded Flag set to exclude (true) or include (false)
     */
    function excludeFromFee(address account, bool _isExcluded) external onlyOwner {
        _excludeFromFee(account, _isExcluded);
        emit ExcludedFromFeeSet(msg.sender, account, _isExcluded);
    }

    /**
     * @notice Returns the maximum gas limit allowed for airdrops
     */
    function getMaxRecipients() external view returns (uint256) {
        return s_maxRecipients;
    }

    /**
     * @notice Returns token address used for airdrop fee
     */
    function getFeeToken() external view returns (address) {
        return address(s_feeToken);
    }

    /**
     * @notice Returns airdrop fee
     */
    function getAirdropFee() external view returns (uint256) {
        return s_airdropFee;
    }

    /**
     * @notice Returns airdrop fee address
     */
    function getFeeAddress() external view returns (address) {
        return s_feeAddress;
    }

    /**
     * @notice Returns if excluded from fee (true, false)
     * @param account Account address
     */
    function isExcluded(address account) external view returns (bool) {
        return s_excludedFromFee[account];
    }

    /**
     * @notice Includes/Excludes wallet from fee
     * @param account Address to be updates
     * @param _isExcluded Flag set to exclude (true) or include (false)
     */
    function _excludeFromFee(address account, bool _isExcluded) private {
        s_excludedFromFee[account] = _isExcluded;
        emit ExcludedFromFeeSet(msg.sender, account, _isExcluded);
    }
}
