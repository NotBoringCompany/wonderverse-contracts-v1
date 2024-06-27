// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./ILeagueData.sol";
import "./ILeagueDataErrors.sol";

// Abstract contract to handle league data-related operations.
abstract contract LeagueData is ILeagueData, ILeagueDataErrors {
    /**
     * @dev Mask to extract the league season from the league data's {stats}.
     */
    uint256 internal constant _LEAGUE_DATA_SEASON_MASK = (1 << 232) - 1;

    /**
     * @dev Fetches the league season from the league data's {stats}.
     */
    function _getLeagueSeason(uint256 stats) internal pure returns (uint256) {
        return stats & _LEAGUE_DATA_SEASON_MASK;
    }
}