// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @dev Interface for player-related functionality.
 */
interface IPlayer {
    /**
     * @dev Represents a player in the game.
     */
    struct Player {
        // the player's address
        address addr;
        // the amount of points the player owns
        // this will be up-to-date with the backend
        uint256 points;
        // an action refers to an activity in-game that is tracked my mixpanel.
        // the amount of times an action is done is stored within 32 bits.
        // this means that each uint256 instance can store up to 8 actions via bit manipulation.
        // as more actions are tracked, they will be carried over into the next uint256 in the array.
        // e.g. in the first uint256:
        //
        // action 1 - 0
        // action 2 - 0
        // action 3 - 0
        // if action 3 is completed, then the uint256 will use bit manipulation to increment the value of action 3 by 1 (i.e. bit position 24 to 31).
        uint256[] actionData;
    }
}