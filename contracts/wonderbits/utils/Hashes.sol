// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @dev Contract to handle hashes in Wonderbits.
 */
abstract contract Hashes {
    /**
     * @dev Fetches the bytes32 hash for operations.
     */
    function opHash(address addr, bytes calldata salt) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(addr, salt));
    }
}