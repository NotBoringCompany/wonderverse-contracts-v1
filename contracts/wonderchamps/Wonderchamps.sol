// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./inventory/IInventory.sol";
import "./items/IItem.sol";
import "./items/IItemFragment.sol";
import "./player/IPlayer.sol";
import "./player/IPlayerErrors.sol";
import "./stats/IInGameStats.sol";
import "./stats/ILeagueData.sol";
import "./utils/EventSignatures.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract Wonderchamps is IInventory, IPlayer, IPlayerErrors, EventSignatures, AccessControl {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

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
     * @dev Creates a new player instance.
     *
     * Requires the admin's signature.
     */
    function createPlayer(
        address player,
        bytes32 salt,
        uint256 timestamp,
        bytes calldata adminSig
    ) external {
        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        address recoveredAddress = ECDSA.recover(
            MessageHashUtils.toEthSignedMessageHash(
                createPlayerHash(player, salt, timestamp)
            ),
            adminSig
        );

        if (!hasRole(DEFAULT_ADMIN_ROLE, recoveredAddress)) {
            revert InvalidAdminSignature();
        }

        // create the player instance.
        players[player] = Player(
            player, 
            0,
            Inventory(
                new OwnedItem[](0), 
                new ItemFragment[](0)
            ),
            InGameStats(
                0,
                new LeagueData[](0)
            )
        );

        assembly {
            // emit the PlayerCreated event.
            log2(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _PLAYER_CREATED_EVENT_SIGNATURE,
                player
            )
        }
    }

    /**
     * @dev Gets the hash of a player creation request.
     */
    function createPlayerHash(
        address player,
        bytes32 salt,
        uint256 timestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(player, salt, timestamp));
    }

    // checks if the caller is `player` or an admin.
    function _checkPlayerOrAdmin(address player) private view {
        if (_msgSender() != player && !hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
            revert NotSelfOrAdmin();
        }
    }
}