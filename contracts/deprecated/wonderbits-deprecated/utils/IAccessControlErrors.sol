// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @dev Interface for access control-related errors.
 */
interface IAccessControlErrors {
    /**
     * @dev Throws if the caller is not an admin.
     */
    error NotAdmin();
}