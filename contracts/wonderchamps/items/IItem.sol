// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

// Interface for a generic item type (i.e. character, vehicle, wheel and gadget).
interface IItem {
    // represents an item owned by a player.
    struct OwnedItem {
        // if the item is owned by the player.
        bool owned;
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
        // any additional data for the item (e.g. buffs, etc.)
        // each additional data should be grouped into a specific "category" per index.
        // for instance, [0] can be occupied for buffs, [1] can be occupied for debuffs, etc.
        bytes[] additionalData;
    }

    function getItems(address player, uint256[] calldata itemIds) external view returns (OwnedItem[] memory);
    function addItemsToInventory(
        address player, 
        OwnedItem[] calldata items,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external;
    function removeItemsFromInventory(
        address player, 
        uint256[] calldata itemIds,
        // [0] - salt
        // [1] - adminSig
        // [2] - playerSig
        bytes[3] calldata sigData
    ) external;
    function updateOwnedItemNumData(
        address player,
        // [0] - itemId
        // [1] - numData
        uint256[2] calldata data, 
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external;
    function updateOwnedItemAdditionalData(
        address player, 
        uint256 itemId,
        bytes[] memory _additionalData,
        // [0] - salt
        // [1] - adminSig
        bytes[] calldata sigData
    ) external;
}