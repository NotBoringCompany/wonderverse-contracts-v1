// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ISignatureErrors.sol";

// Abstract contract containing ECDSA/signature-related operations.
abstract contract Signatures is ISignatureErrors, AccessControl {
    using ECDSA for bytes32;

    /**
     * @dev Checks if the recovered address from {_recoverAddress} matches the expected address.
     */
    function _addressMatches(bytes32 messageHash, bytes calldata sig, address expected) internal pure returns (bool) {
        return _recoverAddress(messageHash, sig) == expected;
    }

    /**
     * @dev Checks if the recovered address from {_recoverAddress} is an admin.
     */
    function _addressIsAdmin(bytes32 messageHash, bytes calldata sig) internal view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _recoverAddress(messageHash, sig));
    }

    /**
     * @dev Recovers the address which signed the {messageHash}.
     */
    function _recoverAddress(bytes32 messageHash, bytes calldata sig) internal pure returns (address) {
        return ECDSA.recover(messageHash, sig);
    }

    /**
     * @dev Checks if the recovered address from {_recoverAddress} matches the expected address and throws if it doesn't.
     */
    function _checkAddressMatches(bytes32 messageHash, bytes calldata sig, address expected) internal pure {
        if (!_addressMatches(messageHash, sig, expected)) {
            revert InvalidPlayerSignature();
        }
    }

    /**
     * @dev Checks if the recovered address from {_recoverAddress} is an admin and throws if it isn't.
     */
    function _checkAddressIsAdmin(bytes32 messageHash, bytes calldata sig) internal view {
        if (!_addressIsAdmin(messageHash, sig)) {
            revert InvalidAdminSignature();
        }
    }
}