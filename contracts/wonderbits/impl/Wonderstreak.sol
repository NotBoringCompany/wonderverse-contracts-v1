// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @dev Wonderstreak contract. Used to keep track of daily logins for Wonderbits, storing it in the blockchain.
 */
contract Wonderstreak is AccessControl {
    // keeps track of the total amount of times a user has logged their daily login via this contract.
    mapping (address => uint256) internal _totalLogs;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev Logs a user's daily login.
     */
    function logDailyStreak(address user) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _totalLogs[user]++;
    }
}