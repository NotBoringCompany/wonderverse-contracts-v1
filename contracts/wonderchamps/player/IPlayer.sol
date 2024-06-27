// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

// import "../inventory/IInventory.sol";
// import "../stats/IInGameStats.sol";

import "../items/IItem.sol";
import "../items/IItemFragment.sol";
import "../stats/ILeagueData.sol";

// Interface for a player's data.
interface IPlayer is IItem, IItemFragment, ILeagueData {
    /**
     * @dev Represents a player instance. Mainly used when retrieving player data.
     *
     * For specifics on what each field represents, please refer to the Player contract.
     */
    struct Player {
        uint256 ownedIGC;
        OwnedItem[] items;
        OwnedItemFragment[] fragments;
        uint256 drawingStats;
        LeagueData[] leagueData;
    }

    function getPlayer(
        address player,
        uint256[] calldata itemIDs,
        uint256[] calldata fragmentIDs,
        uint256[] calldata leagueSeasons
    ) external view returns (Player memory);
    function getOwnedIGC(address player) external view returns (uint256);
    function playerExists(address player) external view returns (bool);
    function createPlayer(
        address player, 
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external;
    function deletePlayer(
        address player, 
        uint256[] calldata ownedItemIDs,
        uint256[] calldata ownedItemFragmentIDs,
        uint256[] calldata leagueSeasons,
        // [0] - salt
        // [1] - adminSig
        // [2] - playerSig
        bytes[3] calldata sigData
    ) external;
}