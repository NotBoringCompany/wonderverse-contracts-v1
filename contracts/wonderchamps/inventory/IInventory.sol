// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "../items/IItem.sol";
import "../items/IItemFragment.sol";

interface IInventory is IItem, IItemFragment {
    // represents a user's inventory instance.
    struct Inventory {
        // the user's owned items (characters, vehicles, wheels and gadgets)
        OwnedItem[] items;
        // the user's owned item fragments
        ItemFragment[] itemFragments;
    }

    function getInventory(address player) external view returns (Inventory memory);
}