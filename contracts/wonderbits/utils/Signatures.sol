// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ISignatureErrors.sol";

/**
 * @dev Abstract contract containing ECDSA/signature-related operations.
 */ 
abstract contract Signatures is ISignatureErrors, AccessControl {
    using ECDSA for bytes32;

    /**
     * @dev Checks if an admin's signature is valid.
     */
    function _checkAdminSignatureValid(bytes32 messageHash, bytes calldata sig) internal view {
        address recovered = ECDSA.recover(messageHash, sig);

        if (!hasRole(DEFAULT_ADMIN_ROLE, ECDSA.recover(messageHash, sig))) {
            revert InvalidAdminSignature(recovered);
        }
    }
}