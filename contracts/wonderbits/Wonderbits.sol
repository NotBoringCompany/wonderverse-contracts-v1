// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./player/IPlayer.sol";
import "./player/IPlayerErrors.sol";
import "./utils/IAccessControlErrors.sol";
import "./actions/IAction.sol";
import "./points/IPoints.sol";
import "./utils/EventSignatures.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Wonderbits is IPlayer, IPlayerErrors, IAccessControlErrors, IAction, IPoints, AccessControl, EventSignatures {
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
     * @dev Modifier that checks if the caller is an admin and reverts if not.
     */
    modifier onlyAdmin() {
        _checkAdmin();
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
     */
    function createPlayer(address player) external virtual onlyNewPlayer(player) onlyAdmin() {
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
        bytes32 action
    ) external onlyAdmin() {
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
     * @dev Updates the counter for a specific action of a player to a new value.
     *
     * NOTE: this should be used seldomly and only if needed, such as resetting the counter to a specific number.
     * for most use cases, {incrementActionCounter} should be used to increment the counter.
     */
    function updateActionCounter(
        address player, 
        bytes32 action, 
        uint256 newCounter
    ) external onlyAdmin() {
        // update the action counter to the new value.
        actionCounters[player][action] = newCounter;

        assembly {
            // emit the ActionCounterUpdated event.
            log4(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _ACTION_COUNTER_UPDATED_EVENT_SIGNATURE,
                player,
                action,
                newCounter
            )
        }
    }

    /**
     * @dev Updates the player's points.
     */
    function updatePoints(
        address player,
        uint256 _points
    ) external onlyAdmin() {
        // update the player's points to the new value.
        points[player] = _points;

        assembly {
            // emit the PointsUpdated event.
            log3(
                0, // 0 offset because no additional data is appended
                0, // 0 size because no additional data is appended
                _POINTS_UPDATED_EVENT_SIGNATURE,
                player,
                _points
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
     * @dev Checks if the caller is an admin and reverts if not.
     */
    function _checkAdmin() private view {
        if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
            revert NotAdmin();
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