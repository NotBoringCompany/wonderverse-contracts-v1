// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Interface for a user's seasonal league data.
interface ILeagueData {
    struct LeagueData {
        // the numerical stats for this particular league season.
        //
        // BIT POSITIONS:
        // [0 - 231] - season (i.e. the season number) (232 bits)
        // [232 - 255] - finalMMR (i.e. the user's final MMR for this season) (24 bits)
        uint256 stats;
        // the user's battle history for this particular league season.
        // each battle is encoded and concatenated into a `bytes` instance.
        bytes battleHistory;
    }

    function addLeagueData(
        address player, 
        LeagueData calldata data,
        bytes32 salt,
        uint256 timestamp,
        bytes calldata adminSig
    ) external;
    function leagueDataHash(
        address player,
        uint256 season,
        bytes32 salt,
        uint256 timestamp
    ) external pure returns (bytes32);
}