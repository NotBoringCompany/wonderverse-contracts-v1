// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./zora/ZoraCreator1155FactoryImpl.sol";

/**
 * @dev Proof of Attendence Protocol (POAP) factory contract for Wonderbits.
 */
contract WonderbitsPOAPFactory is AccessControl {
    // maps each POAP token to its respective merkle root
    mapping (uint256 => bytes32) private merkleRoots;
    // Zora Creator 1155 Factory contract address to direct minting-related methods to
    ZoraCreator1155FactoryImpl private constant _zoraCreatorFactory = ZoraCreator1155FactoryImpl(0x777777C338d93e2C7adf08D102d45CA7CC4Ed021);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // creates a new POAP collection. this should only be called once.
    function createPOAPCollection(
        string calldata newContractURI,
        string calldata name,
        ICreatorRoyaltiesControl.RoyaltyConfiguration calldata defaultRoyaltyConfiguration,
        address payable defaultAdmin,
        bytes[] calldata setupActions
    ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (address) {
        return _zoraCreatorFactory.createContract(
            newContractURI,
            name,
            defaultRoyaltyConfiguration,
            defaultAdmin,
            setupActions
        );
    }

    // sets the merkle root for a POAP token
    function setMerkleRoot(uint256 tokenId, bytes32 merkleRoot) external onlyRole(DEFAULT_ADMIN_ROLE) {
        merkleRoots[tokenId] = merkleRoot;
    }

    // gets the merkle root for a POAP token
    function getMerkleRoot(uint256 tokenId) external view returns (bytes32) {
        return merkleRoots[tokenId];
    }

    // gets the Zora Creator 1155 Factory contract address
    function getZoraCreatorFactory() external pure returns (address) {
        return address(_zoraCreatorFactory);
    }
}