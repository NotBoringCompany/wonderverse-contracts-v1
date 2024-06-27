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
        address recoveredAddress = ECDSA.recover(
            MessageHashUtils.toEthSignedMessageHash(
                itemDataHash(player, itemId, salt, timestamp)
            ),
            adminSig
        );

        if (!hasRole(DEFAULT_ADMIN_ROLE, recoveredAddress)) {
            revert InvalidAdminSignature();
        }

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
        uint256 itemId,
        bytes32 salt,
        uint256 timestamp,
        bytes[2] calldata sigs
    )  external onlyOwnedItem(player, itemId) {
        // ensure that the signatures are valid (i.e. the recovered addresses are the admin's and the player's addresses)
        address recoveredAdminAddress = ECDSA.recover(
            MessageHashUtils.toEthSignedMessageHash(
                itemDataHash(player, itemId, salt, timestamp)
            ),
            sigs[0]
        );

        address recoveredPlayerAddress = ECDSA.recover(
            MessageHashUtils.toEthSignedMessageHash(
                itemDataHash(player, itemId, salt, timestamp)
            ),
            sigs[1]
        );

        if (!hasRole(DEFAULT_ADMIN_ROLE, recoveredAdminAddress)) {
            revert InvalidAdminSignature();
        }

        if (recoveredPlayerAddress != player) {
            revert InvalidPlayerSignature();
        }

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
}