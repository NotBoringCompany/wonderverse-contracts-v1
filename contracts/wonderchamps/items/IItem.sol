// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Interface for a generic item type (i.e. character, vehicle, wheel and gadget).
interface IItem {
    // represents an item owned by a player.
    struct OwnedItem {
        // the skin's numerical data.
        //
        // BIT POSITIONS:
        // [0 - 127] - the item's ID (128 bits)
        // [128 - 143] - the skin's level (16 bits)
        // [144 - 255] - extra data for the skin (112 bits) [e.g. fragments used to level up the item]
        uint256 numData;
        // the item's description
        bytes32 description;
    }
}