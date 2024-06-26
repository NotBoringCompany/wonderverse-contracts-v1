// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Interface for a generic item type (i.e. character, vehicle, wheel and gadget).
interface IItem {
    // represents an item owned by a player.
    struct OwnedItem {
        // the item's type
        ItemType itemType;
        // the item's numerical data.
        //
        // BIT POSITIONS:
        // [0 - 127] - the item's ID (128 bits)
        // [128 - 143] - the item's level (16 bits)
        // [144 - 159] - fragments used to upgrade the item (16 bits)
        // [160 - 255] - additional numerical data (96 bits)
        //
        // NOTE: for vehicles: 
        // [160 - 176] is stored for the base speed
        // [177 - 191] is stored for the speed limit
        uint256 numData;
        // the item's name and description
        // [0] - the item's name
        // [1] - the item's description
        bytes32[] details;
        // any additional data for the item (e.g. buffs, etc.)
        // each additional data should be grouped into a specific "category" per index.
        // for instance, [0] can be occupied for buffs, [1] can be occupied for debuffs, etc.
        bytes[] additionalData;
    }

    // represents an item type.
    enum ItemType {
        CHARACTER,
        VEHICLE,
        WHEEL,
        GADGET
    }
    
    function addItemToInventory(address player, OwnedItem calldata item) external;
    function deleteItemFromInventory(address player, uint256 id) external;
    function updateOwnedItemNumData(address player, uint256 id, uint256 numData) external;
    function updateOwnedItemDetails(address player, uint256 id, bytes32[] calldata details) external;
    function updateOwnedItemAdditionalData(address player, uint256 id, bytes calldata data) external;
}