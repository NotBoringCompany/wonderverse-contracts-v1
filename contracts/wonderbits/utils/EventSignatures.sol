// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @dev Abstract contract containing event signatures used in Wonderbits.
 */
abstract contract EventSignatures {
    /**
     * @dev Event signature for emitting a StoreInCustody event upon storing an NFT in custody.
     *
     * This event signature is obtained by: `keccak256("StoreInCustody(address, uint256)")`.
     */
    bytes32 internal constant _STORE_IN_CUSTODY_EVENT_SIGNATURE = 0x9b0afe4bc3ecf126d1be2c2983f0fc55b9db38bbacf14a33fca764a01dc62470;
}