// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "../items/IItem.sol";
import "../items/IItemFragment.sol";

interface IInventory is IItem, IItemFragment {
    // represents a user's inventory instance.
    // NOTE: temporarily unoptimized, as owning a large number of items may be expensive to operate upon.
    // will be optimized in future versions.
    struct Inventory {
        // the user's owned items
        OwnedItem[] items;
        // the user's owned item fragments
        OwnedItemFragment[] fragments;
    }
}