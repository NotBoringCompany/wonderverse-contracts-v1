// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @dev Interface for action-related functionality and logic.
 */
interface IAction {
    function incrementActionCounter(
        address player, 
        bytes32 action
    ) external;
    function updateActionCounter(
        address player, 
        bytes32 action, 
        uint256 newCounter
    ) external;
}