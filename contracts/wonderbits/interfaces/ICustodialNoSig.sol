// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @dev Interface for {CustodialNoSig}.
 */
interface ICustodialNoSig {
    function storeInCustody(address nftContract, address owner, uint256 tokenId) external;
    function releaseFromCustody(address nftContract, address owner, uint256 tokenId) external;
}