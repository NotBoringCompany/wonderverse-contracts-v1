// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @dev Abstract contract containing event signatures used in Wonderbits.
 */
abstract contract EventSignatures {
    /**
     * @dev Event signature for emitting a StoreInCustody event upon storing an NFT in custody.
     *
     * This event signature is obtained by: `ethers.utils.keccak256(ethers.utils.toUtf8Bytes("StoreInCustody(address, uint256)"))`.
     */
    bytes32 internal constant _STORE_IN_CUSTODY_EVENT_SIGNATURE = 0xefa7d6a6635cdaa2cf85582bc1cf2fc9685b673011b85bb03eff384ed8b7c8ba;
    /**
     * @dev Event signature for emitting a ReleaseFromCustody event upon storing an NFT in custody.
     *
     * This event signature is obtained by: `ethers.utils.keccak256(ethers.utils.toUtf8Bytes("ReleaseFromCustody(address, uint256)"))`.
     */
    bytes32 internal constant _RELEASE_FROM_CUSTODY_EVENT_SIGNATURE = 0x1c3a1e6d4f3180e7e5a46ab42caa172b4ab19cbda48b04f684980baada451795;
    /**
     * @dev Event signature for emitting a LogDailyStreak event upon logging a user's daily streak.
     *
     * This event signature is obtained by: `ethers.utils.keccak256(ethers.utils.toUtf8Bytes("LogDailyStreak(address)"))`.
     */
    bytes32 internal constant _LOG_DAILY_STREAK_EVENT_SIGNATURE = 0x229ee29d55a07d18980c04bc382e17829bbc8d927d0b372c714317503cb0e833;
}