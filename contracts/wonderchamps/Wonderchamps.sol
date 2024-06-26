// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./inventory/IInventory.sol";
import "./items/IItem.sol";
import "./items/IItemFragment.sol";
import "./player/IPlayer.sol";
import "./player/IPlayerErrors.sol";
import "./stats/IInGameStats.sol";
import "./stats/ILeagueData.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Wonderchamps is IInventory, IPlayer, IPlayerErrors, AccessControl {
    // a mapping from a player's address to their player data.
    mapping (address => Player) private players;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // modifier that checks if the caller is the player or an admin.
    modifier onlyPlayerOrAdmin(address player) {
        _checkPlayerOrAdmin(player);
        _;
    }

    /**
     * @dev Gets the hash of a player creation request.
     */
    function createPlayerHash(
        address player,
        bytes32 salt,
        uint256 timestamp
    ) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(player, salt, timestamp));
    }

    // checks if the caller is `player` or an admin.
    function _checkPlayerOrAdmin(address player) private view {
        if (_msgSender() != player && !hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
            revert NotSelfOrAdmin();
        }
    }
}