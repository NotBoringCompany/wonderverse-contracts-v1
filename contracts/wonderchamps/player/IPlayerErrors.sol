// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Interface for IPlayer-related errors.
interface IPlayerErrors {
    /**
     * @dev Throws if the caller is trying to fetch a player's data that is not their own or is not an admin.
     */
    error NotSelfOrAdmin();

    /**
     * @dev Throws if the recovered address doesn't match the admin's address; i.e. the signature is invalid.
     */
    error InvalidAdminSignature();

    /**
     * @dev Throws if the recovered address doesn't match the player's address; i.e. the signature is invalid.
     */
    error InvalidPlayerSignature();
}