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
    
    function getLeagueData(address player, uint256[] calldata seasons) external view returns (LeagueData[] memory);
    function addLeagueData(
        address player, 
        LeagueData calldata data,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external;
}