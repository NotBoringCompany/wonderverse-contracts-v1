// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./IPlayer.sol";
import "./IPlayerErrors.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../utils/EventSignatures.sol";

// Contract for player-related operations.
abstract contract Player is IPlayer, IPlayerErrors, AccessControl, EventSignatures {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    // a mapping from a player's address to their player data.
    mapping (address => Player) private players;

    // modifier that checks if the caller is the player or an admin.
    modifier onlyPlayerOrAdmin(address player) {
        _checkPlayerOrAdmin(player);
        _;
    }

    /**
     * @dev Gets a player's data.
     */
    function getPlayer(address player) onlyPlayerOrAdmin(player) external view override returns (Player memory) {
        return players[player];
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
                playerDataHash(player, salt, timestamp)
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
     * @dev Deletes a player's data.
     *
     * NOTE: Requires both the admin and the player's signatures to ensure that the player is the one who wishes to delete their account.
     *
     * sigs[0] - the admin's signature
     * sigs[1] - the player's signature
     */
    function deletePlayer(address player, bytes32 salt, uint256 timestamp, bytes[2] calldata sigs) external {
        address recoveredAdmin = ECDSA.recover(
            MessageHashUtils.toEthSignedMessageHash(
                playerDataHash(player, salt, timestamp)
            ),
            sigs[0]
        );

        address recoveredPlayer = ECDSA.recover(
            MessageHashUtils.toEthSignedMessageHash(
                playerDataHash(player, salt, timestamp)
            ),
            sigs[1]
        );

        if (!hasRole(DEFAULT_ADMIN_ROLE, recoveredAdmin)) {
            revert InvalidAdminSignature();
        }

        if (recoveredPlayer != player) {
            revert InvalidPlayerSignature();
        }

        delete players[player];

        // emit the PlayerDeleted event.
        assembly {
            log2(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _PLAYER_DELETED_EVENT_SIGNATURE,
                player
            )
        }
    }

    /**
     * @dev Gets the hash of a player creation or deletion request.
     */
    function playerDataHash(
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