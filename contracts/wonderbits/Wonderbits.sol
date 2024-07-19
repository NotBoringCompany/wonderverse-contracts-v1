// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./player/IPlayer.sol";
import "./player/IPlayerErrors.sol";
import "./actions/IAction.sol";
import "./utils/Signatures.sol";
import "./utils/EventSignatures.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract Wonderbits is IPlayer, IPlayerErrors, IAction, Signatures, EventSignatures {
    using MessageHashUtils for bytes32;

    // maps from the player's address to a boolean value indicating whether they've created an account.
    mapping (address => bool) internal hasAccount;
    // maps from the player's address to a uint256 indicating the amount of points they currently own.
    mapping (address => uint256) internal points;
    // an action refers to an activity in-game that is tracked my mixpanel on the backend.
    // each action will be hashed into a bytes32 which maps to a uint256 value indicating the amount of times this action has been done.
    // therefore, this maps from the player's address to the relevant action in bytes32 format to the amount of times it has been done.
    mapping (address => mapping (bytes32 => uint256)) internal actionCounters;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev Modifier to check for caller being the player or an admin.
     */
    modifier onlyPlayerOrAdmin(address player) {
        _checkPlayerOrAdmin(player);
        _;
    }

    /**
     * @dev Modifier that checks if the player is new.
     */
    modifier onlyNewPlayer(address player) {
        _checkPlayerExists(player);
        _;
    }

    /**
     * @dev Creates a new player instance.
     *
     * The player must NOT already exist.
     *
     * Requires the admin's signature.
     */
    function createPlayer(
        address player,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external virtual onlyNewPlayer(player) {
        // ensure that the signature is valid (i.e. the recovered address is the admin's address)
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(dataHash(player, sigData[0])),
            sigData[1]
        );

        // create the player instance by setting the player's {hasAccount} mapping to true.
        // NOTE:
        // other mappings are not set here because they can be left at default values.
        hasAccount[player] = true;

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
     * @dev Fetches the player data instance.
     *
     * Given the player's address and an array of actions, returns the player's points and the amount of times each action has been done.
     */ 
    function getPlayer(address player, bytes32[] calldata actions) external view virtual returns (
        uint256 _points,
        // index 0 corresponds to the counter for action[0], index 1 for action[1] and so on.
        uint256[] memory _actionCounters
    ) {
        _points = points[player];
        _actionCounters = new uint256[](actions.length);

        for (uint256 i = 0; i < actions.length;) {
            _actionCounters[i] = actionCounters[player][actions[i]];

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Increments the counter for a specific action of a player by 1.
     *
     * This should be called when the user completes an action tracked by Mixpanel in the game.
     */
    function incrementActionCounter(
        address player,
        bytes32 action,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external virtual override onlyPlayerOrAdmin(player) {
        // ensure that the signature is valid (i.e. the recovered address is the player's address)
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(dataHash(player, sigData[0])),
            sigData[1]
        );

        // increment the action counter by 1.
        unchecked {
            actionCounters[player][action]++;
        }

        assembly {
            // emit the ActionCounterIncremented event.
            log3(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _ACTION_COUNTER_INCREMENTED_EVENT_SIGNATURE,
                player,
                action
            )
        }
    }

    /**
     * @dev Checks whether a player exists.
     */
    function playerExists(address player) public view virtual returns (bool) {
        return hasAccount[player];
    }

    /**
     * @dev Fetches the data hash for any signature-related operation given a specific {salt}.
     */
    function dataHash(address player, bytes calldata salt) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(player, salt));
    }

    /**
     * @dev Checks if the caller is the player or an admin and reverts if not.
     */
    function _checkPlayerOrAdmin(address player) private view {
       if (_msgSender() != player && !hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
            revert NotSelfOrAdmin();
        } 
    }

    /**
     * @dev Checks whether a player exists.
     */
    function _checkPlayerExists(address player) private view {
        if (playerExists(player)) {
            revert PlayerAlreadyExists();
        }
    }
}