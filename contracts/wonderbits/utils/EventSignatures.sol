// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Abstract contract containing event signatures used in Wonderchamps.
abstract contract EventSignatures {
    /**
     * @dev Event signature for emitting a PlayerCreated event upon player creation.
     *
     * This event signature is obtained by: `keccak256("PlayerCreated(address)")`.
     */
    bytes32 internal constant _PLAYER_CREATED_EVENT_SIGNATURE = 0xb4cca19a27ce42915c3cee0cee28fc5d90969ee49f09ec71659546a63b5f7bc0;

    /**
     * @dev Event signature for emitting an ActionCounterIncremented event upon player deletion.
     *
     * This event signature is obtained by: `keccak256("ActionCounterIncremented(address, bytes32)")`.
     */
    bytes32 internal constant _ACTION_COUNTER_INCREMENTED_EVENT_SIGNATURE = 0x69710701062b19143a27e718544ee3813499aed7bee4100ea0976297b8219c3f;

     /**
     * @dev Event signature for emitting an ActionCounterUpdated event upon player deletion.
     *
     * This event signature is obtained by: `keccak256("ActionCounterUpdated(address, bytes32, uint256)")`.
     */
    bytes32 internal constant _ACTION_COUNTER_UPDATED_EVENT_SIGNATURE = 0xfc85501b3fb3517563624ed50021c7fca3024b362001bf0d36f670b7d00d74ad;
}