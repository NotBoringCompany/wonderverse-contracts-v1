// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "../inventory/IInventory.sol";

// Interface for a player's data.
interface IPlayer is IInventory {
    // represents a player's data instance.
    struct Player {
        // the user's address
        address addr;
        // the user's owned in-game currencies (IGC)
        // BIT POSITIONS:
        // [0 - 127] - gold (premium currency)
        // [128 - 255] - marble (common currency)
        uint256 ownedIGC;
        // the user's inventory
        Inventory inventory;
    }

    function getPlayer(address player) external view returns (Player memory);
    function createPlayer(address player, bytes calldata adminSig) external;
    function createPlayerHash(address player, bytes32 salt, uint256 timestamp) external pure returns (bytes32);
}