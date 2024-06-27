// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// import "../inventory/IInventory.sol";
// import "../stats/IInGameStats.sol";

import "../items/IItem.sol";
import "../items/IItemFragment.sol";
import "../stats/ILeagueData.sol";

// Interface for a player's data.
interface IPlayer is IItem, IItemFragment, ILeagueData {
    function getPlayer(
        address player,
        uint256[] calldata itemIDs,
        uint256[] calldata fragmentIDs,
        uint256[] calldata leagueSeasons
    ) external view returns (
        uint256 _ownedIGC,
        OwnedItem[] memory items,
        OwnedItemFragment[] memory fragments,
        uint256 _drawingStats,
        LeagueData[] memory _leagueData
    );
    function playerExists(address player) external view returns (bool);
    function createPlayer(address player, bytes32 salt, uint256 timestamp, bytes calldata adminSig) external;
    function deletePlayer(
        address player, 
        uint256[] calldata ownedItemIDs,
        uint256[] calldata ownedItemFragmentIDs,
        uint256[] calldata leagueSeasons,
        bytes32 salt, 
        uint256 timestamp, 
        bytes[2] calldata sigs
    ) external;
    function playerDataHash(address player, bytes32 salt, uint256 timestamp) external pure returns (bytes32);
}