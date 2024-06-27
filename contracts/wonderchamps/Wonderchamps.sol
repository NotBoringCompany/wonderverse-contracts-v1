// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./inventory/IInventory.sol";
import "./items/Item.sol";
import "./items/IItemFragment.sol";
import "./player/Player.sol";
import "./stats/IInGameStats.sol";
import "./stats/ILeagueData.sol";

contract Wonderchamps is Item, Player {
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // modifier that checks if an item to be added to the player's inventory is not already owned by the player.
    modifier onlyUnownedItem(address player, uint256 itemId) {
        _checkItemOwned(player, itemId);
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
        players[player].inventory.items.push(item);

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
     * @dev Checks whether an item to be added to the player's inventory is already owned by the player.
     */
    function _checkItemOwned(address player, uint256 itemId) private view {
        // to check if the item to be added already exists in the player's inventory, we need to iterate over the player's items.
        // if the item is found, an error is thrown to prevent any unintentional overwriting.
        for (uint256 i = 0; i < players[player].inventory.items.length;) {
            if (_getItemID(players[player].inventory.items[i].numData) == itemId) {
                revert ItemAlreadyOwned(itemId);
            }

            unchecked {
                ++i;
            }
        }
    }
}