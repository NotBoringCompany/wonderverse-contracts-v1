// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Interface for an item fragment.
interface IItemFragment {
    // represents an item fragment owned by a player.
    struct OwnedItemFragment {
        // if the item fragment is owned by the player.
        bool owned;
        // the item fragment's numerical data
        //
        // BIT POSITIONS:
        // [0 - 127] - the item fragment's ID (128 bits)
        // [128 - 159] - the amount of this item fragment owned by the player (32 bits)
        // [160 - 255] - additional numerical data (96 bits)
        uint256 numData;
    }

    function addItemFragmentToInventory(
        address player, 
        OwnedItemFragment calldata fragment,
        bytes32 salt,
        uint256 timestamp,
        bytes calldata adminSig
    ) external;
    function updateItemFragmentQuantity(
        address player,
        // [0] - fragmentId
        // [1] - quantity
        // [2] - timestamp
        uint256[3] calldata data,
        bytes32 salt,
        bytes calldata adminSig
    ) external;
    function removeItemFragmentFromInventory(
        address player,
        // [0] - fragmentId
        // [1] - timestamp
        uint256[2] calldata data,
        bytes32 salt,
        bytes[2] calldata sigs
    ) external;
}