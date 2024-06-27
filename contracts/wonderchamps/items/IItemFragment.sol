// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

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

    function getItemFragments(address player, uint256[] calldata fragmentIds) external view returns (OwnedItemFragment[] memory);
    function addItemFragmentToInventory(
        address player, 
        OwnedItemFragment calldata fragment,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external;
    function updateItemFragmentNumData(
        address player,
        // [0] - fragmentId
        // [1] - numData
        uint256[2] calldata data,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external;
    function removeItemFragmentFromInventory(
        address player,
        uint256 fragmentId,
        // [0] - salt
        // [1] - adminSig
        // [2] - playerSig
        bytes[3] calldata sigData
    ) external;
}