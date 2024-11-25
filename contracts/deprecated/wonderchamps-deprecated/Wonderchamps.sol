// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./items/Item.sol";
import "./items/IItemFragment.sol";
import "./player/Player.sol";

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

    // modifier that checks if the league data for a particular season for a user already exists.
    modifier onlyNewLeagueData(address player, uint256 season) {
        _checkLeagueDataExists(player, season);
        _;
    }

    /**
     * @dev Adds one or multiple items to a player's inventory.
     *
     * If an item is already owned by the player, skip this item.
     *
     * NOTE: Requires the admin's signature.
     */
    function addItemsToInventory(
        address player,
        OwnedItem[] calldata items,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external {
        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(
                dataHash(player, sigData[0])
            ),
            sigData[1]
        );

        for (uint256 i = 0; i < items.length;) {
            uint256 itemId = _getItemID(items[i].numData);

            if (ownedItems[player][itemId].owned) {
                unchecked {
                    ++i;
                    continue;
                }
            }

            // add the item to the player's inventory.
            ownedItems[player][itemId] = items[i];

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

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Removes one or more items from a player's inventory.
     *
     * If one or more items are not owned by the player, skip these items.
     *
     * NOTE: Requires both the admin and the player's signatures.
     */
    function removeItemsFromInventory(
        address player,
        uint256[] calldata itemIds,
        // [0] - salt
        // [1] - adminSig
        // [2] - playerSig
        bytes[3] calldata sigData
    ) external {
        // check if both the admin and the player's signatures are valid.
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(
                dataHash(player, sigData[0])
            ),
            sigData[1]
        );
        _checkSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(
                dataHash(player, sigData[0])
            ),
            sigData[2],
            player
        );

        for (uint256 i = 0; i < itemIds.length;) {
            uint256 itemId = itemIds[i];

            if (!ownedItems[player][itemId].owned) {
                unchecked {
                    ++i;
                    continue;
                }
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

            unchecked {
                ++i;
            }
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
        uint256[2] calldata data,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external onlyOwnedItem(player, data[0]) {
        uint256 itemId = data[0];

        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(
                dataHash(player, sigData[0])
            ),
            sigData[1]
        );

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
        uint256 itemId,
        bytes[] memory _additionalData,
        // [0] - salt
        // [1] - adminSig
        bytes[] calldata sigData
    ) external onlyOwnedItem(player, itemId) {
        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(
                dataHash(player, sigData[0])
            ),
            sigData[1]
        );

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
     * @dev Adds one or more item fragments to a player's inventory.
     *
     * If an item fragment is already owned by the player, skip this item fragment.
     *
     * NOTE: Requires the admin's signature.
     */
    function addItemFragmentsToInventory(
        address player,
        OwnedItemFragment[] calldata fragments,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external {
        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(
                dataHash(player, sigData[0])
            ),
            sigData[1]
        );

        for (uint256 i = 0; i < fragments.length;) {
            uint256 fragmentId = _getItemID(fragments[i].numData);

            if (ownedItemFragments[player][fragmentId].owned) {
                unchecked {
                    ++i;
                    continue;
                }
            }

            // add the item fragment to the player's inventory.
            ownedItemFragments[player][fragmentId] = fragments[i];

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

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Updates an item fragment's {numData} within a player's inventory.
     *
     * NOTE: Requires the admin's signature.
     */
    function updateItemFragmentNumData(
        address player,
        // [0] - fragmentId
        // [1] - numData
        uint256[2] calldata data,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external onlyOwnedItemFragment(player, data[0]) {
        uint256 fragmentId = data[0];

        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(
                dataHash(player, sigData[0])
            ),
            sigData[1]
        );

        // update the item fragment's quantity.
        ownedItemFragments[player][fragmentId].numData = data[1];

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
     * @dev Removes one or more item fragments from a player's inventory.
     *
     * If one or more item fragments are not owned by the player, skip these item fragments.
     *
     * NOTE: Requires both the admin and the player's signatures.
     */
    function removeItemFragmentsFromInventory(
        address player,
        uint256[] calldata fragmentIds,
        // [0] - salt
        // [1] - adminSig
        // [2] - playerSig
        bytes[3] calldata sigData
    ) external {
        // check if both the admin and the player's signatures are valid.
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(
                dataHash(player, sigData[0])
            ),
            sigData[1]
        );
        _checkSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(
                dataHash(player, sigData[0])
            ),
            sigData[2],
            player
        );

        for (uint256 i = 0; i < fragmentIds.length;) {
            uint256 fragmentId = fragmentIds[i];

            if (!ownedItemFragments[player][fragmentId].owned) {
                unchecked {
                    ++i;
                    continue;
                }
            }

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

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Adds a new league data instance/entry after a season ends on the user's in-game stats.
     *
     * NOTE: Requires the admin's signature.
     */
    function addLeagueData(
        address player,
        LeagueData calldata data,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external onlyNewLeagueData(player, _getLeagueSeason(data.stats)) {
        uint256 season = _getLeagueSeason(data.stats);

        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(
                dataHash(player, sigData[0])
            ),
            sigData[1]
        );

        // add the league data to the player's stats.
        leagueData[player][season] = data;

        // emit the LeagueDataAdded event.
        assembly {
            log3(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _LEAGUE_DATA_ADDED_EVENT_SIGNATURE,
                player,
                season
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
    function _checkItemOwned(
        address player,
        uint256 itemId,
        bool add
    ) private view {
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
    function _checkItemFragmentOwned(
        address player,
        uint256 fragmentId,
        bool add
    ) private view {
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

    /**
     * @dev Checks if the league data for a particular season for a user already exists.
     */
    function _checkLeagueDataExists(
        address player,
        uint256 season
    ) private view {
        if (leagueData[player][season].stats != 0) {
            revert LeagueDataAlreadyExists(season);
        }
    }
}
