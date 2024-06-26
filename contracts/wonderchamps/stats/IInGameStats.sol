// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./ILeagueData.sol";

// Interface for a user's in-game stats.
interface IInGameStats is ILeagueData {
    // represents a user's in-game stats
    struct InGameStats {
        // the user's drawing stats.
        //
        // BIT POSITIONS:
        // [0 - 127] - currentDrawPerMatchLevel (i.e. how many wheels can be drawn per match)
        // [128 - 255] - currentDrawLengthLevel (i.e. how long a wheel can be drawn)
        uint256 drawingStats;
        // the user's seasonal league data.
        LeagueData[] leagueData;
    }

    function getInGameStats(address player) external view returns (InGameStats memory);
}