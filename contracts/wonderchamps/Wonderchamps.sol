// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./items/Item.sol";
import "./items/IItemFragment.sol";
import "./player/Player.sol";
import "./stats/ILeagueData.sol";

contract Wonderchamps is Player {
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // modifier that checks if an item to be added to the player's inventory is not already owned by the player.
    modifier onlyUnownedItem(address player, uint256 itemId) {
        _checkItemOwned(player, itemId, true);
        _;
    }

    // modifier that checks if an item to be deleted from the player's inventory is owned by the player.
    modifier onlyOwnedItem(address player, uint256 itemId) {
        _checkItemOwned(player, itemId, false);
        _;
    }

    // modifier that checks if an item fragment to be added to the player's inventory is not already owned by the player.
    modifier onlyUnownedItemFragment(address player, uint256 fragmentId) {
        _checkItemFragmentOwned(player, fragmentId, true);
        _;
    }

    // modifier that checks if an item fragment to be deleted from the player's inventory is owned by the player.
    modifier onlyOwnedItemFragment(address player, uint256 fragmentId) {
        _checkItemFragmentOwned(player, fragmentId, false);
        _;
    }

    /**
     * @dev Adds an item to a player's inventory.
     *
     * If an item is already owned by the player, an error is thrown to prevent any unintentional overwriting.
     *
     * NOTE: Requires the admin's signature.
     */
    function addItemToInventory(
        address player, 
        OwnedItem calldata item, 
        bytes32 salt,
        uint256 timestamp,
        bytes calldata adminSig
    ) external onlyUnownedItem(player, _getItemID(item.numData)) {
        uint256 itemId = _getItemID(item.numData);

        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAddressIsAdmin(MessageHashUtils.toEthSignedMessageHash(itemDataHash(player, itemId, salt, timestamp)), adminSig);

        // add the item to the player's inventory.
        ownedItems[player][itemId] = item;

        // emit the ItemAdded event.
        assembly {
            log3(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _ITEM_ADDED_EVENT_SIGNATURE,
                player,
                itemId
            )
        }
    } 

    /**
     * @dev Removes an item from a player's inventory.
     *
     * NOTE: Requires both the admin and the player's signatures.
     */
    function removeItemFromInventory(
        address player, 
        // [0] - itemId
        // [1] - timestamp
        uint256[2] calldata data,
        bytes32 salt,
        // [0] - adminSig
        // [1] - playerSig
        bytes[2] calldata sigs
    )  external onlyOwnedItem(player, data[0]) {
        uint256 itemId = data[0];

        // check if both the admin and the player's signatures are valid.
        _checkAddressIsAdmin(MessageHashUtils.toEthSignedMessageHash(itemDataHash(player, itemId, salt, data[1])), sigs[0]);
        _checkAddressMatches(MessageHashUtils.toEthSignedMessageHash(itemDataHash(player, itemId, salt, data[1])), sigs[1], player);

        // remove the item from the player's inventory.
        delete ownedItems[player][itemId];

        // emit the ItemRemoved event.
        assembly {
            log3(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _ITEM_REMOVED_EVENT_SIGNATURE,
                player,
                itemId
            )
        }
    }

    /**
     * @dev Updates the {numData} of an owned item.
     *
     * NOTE: Requires the admin's signature.
     */
    function updateOwnedItemNumData(
        address player, 
        // [0] - itemId
        // [1] - numData
        // [2] - timestamp
        uint256[3] calldata data,
        bytes32 salt,
        bytes calldata adminSig
    ) external onlyOwnedItem(player, data[0]) {
        uint256 itemId = data[0];

        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAddressIsAdmin(MessageHashUtils.toEthSignedMessageHash(itemDataHash(player, itemId, salt, data[2])), adminSig);

        // update the item's {numData}.
        ownedItems[player][itemId].numData = data[1];

        // emit the ItemUpdated event.
        assembly {
            log3(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _ITEM_UPDATED_EVENT_SIGNATURE,
                player,
                itemId
            )
        }
    }

    /**
     * @dev Updates the {additionalData} of an owned item.
     *
     * NOTE: Requires the admin's signature.
     */
    function updateOwnedItemAdditionalData(
        address player, 
        // [0] - itemId
        // [1] - timestamp
        uint256[2] calldata data,
        bytes32 salt,
        bytes[] calldata _additionalData,
        bytes calldata adminSig
    ) external onlyOwnedItem(player, data[0]) {
        uint256 itemId = data[0];

        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAddressIsAdmin(MessageHashUtils.toEthSignedMessageHash(itemDataHash(player, itemId, salt, data[1])), adminSig);

        // update the item's {additionalData}.
        ownedItems[player][itemId].additionalData = _additionalData;

        // emit the ItemUpdated event.
        assembly {
            log3(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _ITEM_UPDATED_EVENT_SIGNATURE,
                player,
                itemId
            )
        }
    }

    /**
     * @dev Adds an item fragment to a player's inventory.
     *
     * NOTE: Requires the admin's signature.
     */
    function addItemFragmentToInventory(
        address player, 
        OwnedItemFragment calldata fragment,
        bytes32 salt,
        uint256 timestamp,
        bytes calldata adminSig
    ) external onlyUnownedItemFragment(player, _getItemID(fragment.numData)) {
        uint256 fragmentId = _getItemID(fragment.numData);

        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAddressIsAdmin(MessageHashUtils.toEthSignedMessageHash(itemDataHash(player, fragmentId, salt, timestamp)), adminSig);

        // add the item fragment to the player's inventory.
        ownedItemFragments[player][fragmentId] = fragment;

        // emit the ItemFragmentAdded event.
        assembly {
            log3(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _ITEM_FRAGMENT_ADDED_EVENT_SIGNATURE,
                player,
                fragmentId
            )
        }
    }

    /**
     * @dev Updates an item fragment's quantity within a player's inventory.
     *
     * NOTE: Requires the admin's signature.
     */
    function updateItemFragmentQuantity(
        address player,
        // [0] - fragmentId
        // [1] - quantity
        // [2] - timestamp
        uint256[3] calldata data,
        bytes32 salt,
        bytes calldata adminSig
    ) external onlyOwnedItemFragment(player, data[0]) {
        uint256 fragmentId = data[0];

        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAddressIsAdmin(MessageHashUtils.toEthSignedMessageHash(itemDataHash(player, fragmentId, salt, data[2])), adminSig);

        // update the item fragment's quantity.
        ownedItemFragments[player][fragmentId].numData = _getUpdatedItemFragmentNumData(ownedItemFragments[player][fragmentId].numData, data[1]);

        // emit the ItemFragmentUpdated event.
        assembly {
            log3(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _ITEM_FRAGMENT_UPDATED_EVENT_SIGNATURE,
                player,
                fragmentId
            )
        }
    }

    /**
     * @dev Removes an item fragment from a player's inventory.
     *
     * NOTE: Requires both the admin and the player's signatures.
     */
    function removeItemFragmentFromInventory(
        address player,
        // [0] - fragmentId
        // [1] - timestamp
        uint256[2] calldata data,
        bytes32 salt,
        // [0] - adminSig
        // [1] - playerSig
        bytes[2] calldata sigs
    ) external onlyOwnedItemFragment(player, data[0]) {
        uint256 fragmentId = data[0];

        // check if both the admin and the player's signatures are valid.
        _checkAddressIsAdmin(MessageHashUtils.toEthSignedMessageHash(itemDataHash(player, fragmentId, salt, data[1])), sigs[0]);
        _checkAddressMatches(MessageHashUtils.toEthSignedMessageHash(itemDataHash(player, fragmentId, salt, data[1])), sigs[1], player);

        // remove the item fragment from the player's inventory.
        delete ownedItemFragments[player][fragmentId];

        // emit the ItemFragmentRemoved event.
        assembly {
            log3(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _ITEM_FRAGMENT_REMOVED_EVENT_SIGNATURE,
                player,
                fragmentId
            )
        }
    }

    /**
     * @dev Checks whether an item to be added to the player's inventory is already owned by the player.
     *
     * NOTE: This is a multi-purpose function that can be used to check if an item is owned by the player or not.
     *
     * In the case this function is called for checking if an item to be added is already owned, {add} should be true.
     * If the case is to check if an item to be deleted isn't owned, {add} should be false.
     */
    function _checkItemOwned(address player, uint256 itemId, bool add) private view {
        // to check if an item exists, we can simply check if the item's {owned} field is set to true.
        if (add) {
            if (ownedItems[player][itemId].owned) {
                revert ItemAlreadyOwned(itemId);
            }
        } else {
            if (!ownedItems[player][itemId].owned) {
                revert ItemNotOwned(itemId);
            }
        }
    }

    /**
     * @dev Checks whether an item fragment to be added to the player's inventory is already owned by the player.
     *
     * NOTE: This is a multi-purpose function that can be used to check if an item fragment is owned by the player or not.
     *
     * In the case this function is called for checking if an item fragment to be added is already owned, {add} should be true.
     * If the case is to check if an item fragment to be deleted isn't owned, {add} should be false.
     */
    function _checkItemFragmentOwned(address player, uint256 fragmentId, bool add) private view {
        // to check if an item fragment exists, we can simply check if the item fragment's {owned} field is set to true.
        if (add) {
            if (ownedItemFragments[player][fragmentId].owned) {
                revert ItemFragmentAlreadyOwned(fragmentId);
            }
        } else {
            if (!ownedItemFragments[player][fragmentId].owned) {
                revert ItemFragmentNotOwned(fragmentId);
            }
        }
    }
}