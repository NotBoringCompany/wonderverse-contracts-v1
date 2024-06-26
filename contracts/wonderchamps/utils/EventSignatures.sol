// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Abstract contract containing event signatures used in Wonderchamps.
abstract contract EventSignatures {
    /**
     * @dev Event signature for emitting a PlayerCreated event upon player creation.
     *
     * This event signature is obtained by: `keccak256("PlayerCreated(address)")`.
     */
    bytes32 internal constant _PLAYER_CREATED_EVENT_SIGNATURE = 0xb4cca19a27ce42915c3cee0cee28fc5d90969ee49f09ec71659546a63b5f7bc0;

    /**
     * @dev Event signature for emitting a PlayerDeleted event upon player deletion.
     *
     * This event signature is obtained by: `keccak256("PlayerDeleted(address)")`.
     */
    bytes32 internal constant _PLAYER_DELETED_EVENT_SIGNATURE = 0xc9fb99cf86984520d29d72f3a41fe637cc23cddff11a003f0b9e27c1652d1718;
}