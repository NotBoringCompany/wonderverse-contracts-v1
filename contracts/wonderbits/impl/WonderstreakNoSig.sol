// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../utils/EventSignatures.sol";

/**
 * @dev Wonderstreak contract. Used to keep track of daily logins for Wonderbits, storing it in the blockchain.
 *
 * This is the 'no sig' version which does not require a signature to handle actions as the admin will handle the actions.
 */
contract WonderstreakNoSig is AccessControl, EventSignatures {
    // keeps track of the total amount of times a user has logged their daily login via this contract.
    mapping (address => uint256) internal _dailyLogins;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev Logs a user's daily login.
     */
    function logDailyStreak(address user) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _dailyLogins[user]++;

        // emit a LogDailyStreak event efficiently
        assembly {
            log2(
                0,
                0,
                _LOG_DAILY_STREAK_EVENT_SIGNATURE,
                user
            )
        }
    }
    
    /**
     * @dev Fetches the total number of daily logins for a user.
     */
    function getDailyLogins(address user) external view returns (uint256) {
        return _dailyLogins[user];
    }
}