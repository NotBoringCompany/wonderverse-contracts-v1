// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// import "@openzeppelin/contracts/token/ERC1155.sol";
// import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
import "https://github.com/ourzora/zora-protocol/blob/main/packages/1155-contracts/src/factory/ZoraCreator1155FactoryImpl.sol";

/**
 * @dev Proof of Attendence Protocol (POAP) for Wonderbits.
 */
contract WonderbitsPOAP is ERC1155, AccessControl {
    // maps each POAP token to its respective merkle root
    mapping (uint256 => bytes32) private merkleRoots;

    constructor(string memory uri) ERC1155(uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // sets the merkle root for a POAP token
    function setMerkleRoot(uint256 tokenId, bytes32 merkleRoot) external onlyRole(DEFAULT_ADMIN_ROLE) {
        merkleRoots[tokenId] = merkleRoot;
    }

    // gets the merkle root for a POAP token
    function getMerkleRoot(uint256 tokenId) external view returns (bytes32) {
        return merkleRoots[tokenId];
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}