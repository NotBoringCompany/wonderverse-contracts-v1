// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Interface for league data-related errors.
interface ILeagueDataErrors {
    /**
     * @dev Thrown when trying to add league data for a season for a user that already has data for that season.
     */
    error LeagueDataAlreadyExists(uint256 season);
}