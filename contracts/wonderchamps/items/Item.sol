// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./IItem.sol";
import "./IItemErrors.sol";

// Item contract containing item-related operations.
abstract contract Item is IItem, IItemErrors { 
    // mask to extract the item ID from an item's {numData}.
    uint256 internal constant _ITEM_ID_MASK = (1 << 128) - 1;

    // gets the item ID from an item's {numData}.
    function _getItemID(uint256 numData) internal pure returns (uint256) {
        return numData & _ITEM_ID_MASK;
    }

    function itemDataHash(address player, uint256 itemId, bytes32 salt, uint256 timestamp) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(player, itemId, salt, timestamp));
    }
}