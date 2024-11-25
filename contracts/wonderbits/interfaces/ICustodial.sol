// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @dev Interface for {Custodial}.
 */
interface ICustodial {
    function storeInCustody(address nftContract, uint256 tokenId, bytes[2] calldata sigData) external;
    function releaseFromCustody(address nftContract, uint256 tokenId, bytes[2] calldata sigData) external;
}