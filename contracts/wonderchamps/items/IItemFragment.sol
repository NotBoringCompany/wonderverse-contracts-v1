// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Interface for an item fragment.
interface IItemFragment {
    // represents an item fragment owned by a player.
    struct OwnedItemFragment {
        // the item fragment's data
        // [0] - the item fragment's ID
        // [1] - the item fragment's quantity/amount owned by the player
        uint256[2] data;
    }

    function getItemFragment(uint256 id) external view returns (OwnedItemFragment memory);
    function addItemFragmentToInventory(address player, OwnedItemFragment calldata fragment) external;
}