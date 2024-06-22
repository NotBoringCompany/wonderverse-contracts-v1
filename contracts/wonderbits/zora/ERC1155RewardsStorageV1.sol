// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ERC1155RewardsStorageV1 {
    mapping(uint256 => address) public createReferrals;

    mapping(uint256 => address) public firstMinters;
}
