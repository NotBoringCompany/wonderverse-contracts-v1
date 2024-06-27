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

    /**
     * @dev Event signature for emitting an ItemAdded event upon adding an item to the inventory.
     *
     * This event signature is obtained by: `keccak256("ItemAdded(address,uint256)")`.
     */
    bytes32 internal constant _ITEM_ADDED_EVENT_SIGNATURE = 0x253f6b1995c330c2910a1fc84688341255a45574abc14d9c8deadaa3f45457a2;

    /**
     * @dev Event signature for emitting an ItemRemoved event upon removing an item from the inventory.
     *
     * This event signature is obtained by: `keccak256("ItemRemoved(address,uint256)")`.
     */
    bytes32 internal constant _ITEM_REMOVED_EVENT_SIGNATURE = 0x678419c073b2eba6e89e003798c3e19e378b27373fa408a4dd0347e052487bda;

    /**
     * @dev Event signature for emitting an ItemUpdated event upon updating an item in the inventory.
     *
     * This event signature is obtained by: `keccak256("ItemUpdated(address,uint256)")`.
     */
    bytes32 internal constant _ITEM_UPDATED_EVENT_SIGNATURE = 0xc36605e3afc7883a4162fc7d6ad90a5c08b78a73d0bd1bea0288b746046ecfef;

    /**
     * @dev Event signature for emitting an ItemFragmentAdded event upon adding an item fragment to the inventory.
     *
     * This event signature is obtained by `keccak256("ItemFragmentAdded(address,uint256,uint256)")`.
     */
    bytes32 internal constant _ITEM_FRAGMENT_ADDED_EVENT_SIGNATURE = 0x461d12aa98a20b4fabc02b04b95f8efbbdd00699d6826cd244814cd862fe08fb;

    /**
     * @dev Event signature for emitting an ItemFragmentRemoved event upon removing an item fragment from the inventory.
     *
     * This event signature is obtained by `keccak256("ItemFragmentRemoved(address,uint256,uint256)")`.
     */
    bytes32 internal constant _ITEM_FRAGMENT_REMOVED_EVENT_SIGNATURE = 0xab2ac95583fd8c7a6ed44777780607d32a472d5da94d68a60b2dc51db28dccd7;

    /**
     * @dev Event signature for emitting an ItemFragmentUpdated event upon updating an item fragment in the inventory.
     *
     * This event signature is obtained by `keccak256("ItemFragmentUpdated(address,uint256,uint256)")`.
     */
    bytes32 internal constant _ITEM_FRAGMENT_UPDATED_EVENT_SIGNATURE = 0x2d52772a1b0b9560e4b017c0f93dcb1257ab0c2ba6ff79c4bdc289137b8e0ff2;
}