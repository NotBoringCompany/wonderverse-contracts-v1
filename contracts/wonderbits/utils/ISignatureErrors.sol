// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Interface for signature-related errors.
interface ISignatureErrors {
    /**
     * @dev Throws if the recovered address doesn't match the admin's address; i.e. the signature is invalid.
     */
    error InvalidAdminSignature(address recovered);
}