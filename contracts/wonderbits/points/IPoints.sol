// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @dev Interface for points-related functionality and logic.
 */
interface IPoints {
    function updatePoints(
        address player, 
        uint256 _points, 
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external;
}