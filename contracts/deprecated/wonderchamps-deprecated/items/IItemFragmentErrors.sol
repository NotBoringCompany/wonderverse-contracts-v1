// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

// Interface for item fragment-related errors.
interface IItemFragmentErrors {
    /**
     * @dev Thrown when trying to add an item fragment the user already owns; prevents any overwriting.
     */
    error ItemFragmentAlreadyOwned(uint256 fragmentId);

    /**
     * @dev Thrown when trying to remove an item fragment the user doesn't own; prevents any unauthorized removals.
     */
    error ItemFragmentNotOwned(uint256 fragmentId);
}