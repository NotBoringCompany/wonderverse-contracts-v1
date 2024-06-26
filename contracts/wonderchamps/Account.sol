// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract Account {
    // represents a player's data instance.
    struct Player {
        // the user's address
        address addr;
        // the user's owned in-game currencies (IGC)
        // BIT POSITIONS:
        // [0 - 127] - gold (premium currency)
        // [128 - 255] - marble (common currency)
        uint256 ownedIGC;
        // the user's inventory
        Inventory inventory;
    }

    // represents a user's inventory instance.
    struct Inventory {
        // the user's owned character skins
        CharacterSkin[] characterSkins;
        // the user's owned vehicle skins
        VehicleSkin[] vehicleSkins;
        // the user's owned wheels
        Wheel[] wheels;
        // the user's owned gadgets
        Gadget[] gadgets;
        // the user's owned item fragments
        ItemFragment[] itemFragments;
    }
}