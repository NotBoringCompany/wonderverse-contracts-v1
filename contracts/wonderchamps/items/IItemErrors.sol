// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Interface for item-related errors.
interface IItemErrors {
    /**
     * @dev Thrown when trying to add an item the user already owns; prevents any overwriting.
     */
    error ItemAlreadyOwned(uint256 itemId);
}