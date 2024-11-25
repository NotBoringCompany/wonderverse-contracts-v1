// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @dev Interface for {Custodial} errors.
 */ 
interface ICustodialErrors {
    /**
     * @dev Throws if the function caller doesn't own the specified NFT token.
     */
    error NotTokenOwner();

    /**
     * @dev Throws if the NFT token is already in custody.
     */
    error AlreadyInCustody();
}