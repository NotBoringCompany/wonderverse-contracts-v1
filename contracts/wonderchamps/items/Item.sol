// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./IItem.sol";
import "./IItemErrors.sol";
import "./IItemFragmentErrors.sol";

// Item contract containing item- and item fragment-related operations.
abstract contract Item is IItem, IItemErrors, IItemFragmentErrors { 
    /**
     * @dev Mask to extract the item ID from an item's {numData} or an item fragment's {numData}.
     *
     * NOTE: Both items and item fragments store the ID in the lower 128 bits of the {numData}, so a singular mask can be used.
     */
    uint256 internal constant _ITEM_ID_MASK = (1 << 128) - 1;

    /**
     * @dev Gets the item ID from an item's {numData} or an item fragment's ID from an item fragment's {numData}.
     */
    function _getItemID(uint256 numData) internal pure returns (uint256) {
        return numData & _ITEM_ID_MASK;
    }
}