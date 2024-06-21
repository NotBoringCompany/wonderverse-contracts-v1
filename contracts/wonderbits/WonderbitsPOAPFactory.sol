// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./zora/ZoraCreator1155FactoryImpl.sol";
import "./zora/IZoraCreator1155.sol";
import "./zora/ZoraCreatorMerkleMinterStrategy.sol";

/**
 * @dev Proof of Attendence Protocol (POAP) factory contract for Wonderbits.
 */
contract WonderbitsPOAPFactory is AccessControl, ReentrancyGuard {
    // the Wonderbits POAP collection address. if a new collection needs to be created, the new address gets directly updated here.
    address private _wonderbitsPOAP;
    // Zora Creator 1155 Factory contract address to direct contract creation-related functionality to
    // this is constant because the contract address is deterministic
    ZoraCreator1155FactoryImpl private constant _zoraCreatorFactory = ZoraCreator1155FactoryImpl(0x777777C338d93e2C7adf08D102d45CA7CC4Ed021);

    // invalid merkle proof upon verification error
    error InvalidMerkleProof();
    // throws when a transaction's value is less than the required fee to mint a POAP token
    error InvalidFeeSent();

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
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        address _addr = _zoraCreatorFactory.createContract(
            newContractURI,
            name,
            defaultRoyaltyConfiguration,
            defaultAdmin,
            setupActions
        );

        _wonderbitsPOAP = _addr;
    }

    // creates a new POAP token within the POAP collection.
    // a new token usually gets created for a new event which requires a different POAP.
    function createPOAPToken(
        string calldata newURI,
        uint256 maxSupply,
        address createReferral
    ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256) {
        return IZoraCreator1155(_wonderbitsPOAP).setupNewTokenWithCreateReferral(
            newURI,
            maxSupply,
            createReferral
        );
    }

    // sets the merkle sale for a POAP token
    // this allows whitelisted participants to mint the POAP token
    function setMerkleSale(
        uint256 tokenId,
        // [0] - presaleStart, [1] - presaleEnd
        uint64[2] calldata presaleTimestamps,
        address fundsRecipient,
        bytes32 merkleRoot
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // get the ZoraCreatorMerkleMinterStrategy contract instance from the `merkleMinter` address from `_zoraContractFactory`
        // and call `setSale`
        ZoraCreatorMerkleMinterStrategy(address(_zoraCreatorFactory.merkleMinter())).setSale(
            tokenId,
            ZoraCreatorMerkleMinterStrategy.MerkleSaleSettings({
                presaleStart: presaleTimestamps[0],
                presaleEnd: presaleTimestamps[1],
                fundsRecipient: fundsRecipient,
                merkleRoot: merkleRoot
            })
        );
    }

    // mints a POAP token using a merkle proof
    function mintWithMerkleProof(
        // [0] - tokenId, [1] - amount, [2] - maxQuantity, [3] - pricePerToken
        uint256[4] calldata uints,
        address to,
        bytes32[] calldata proof
    ) external payable nonReentrant {
        ZoraCreatorMerkleMinterStrategy merkleMinter = ZoraCreatorMerkleMinterStrategy(address(_zoraCreatorFactory.merkleMinter()));
        (,,,bytes32 merkleRoot) = merkleMinter.allowedMerkles(_wonderbitsPOAP, uints[0]);

        if (!MerkleProof.verify(proof, merkleRoot, keccak256(abi.encodePacked(to)))) {
            revert InvalidMerkleProof();
        }

        if (msg.value != checkFeeRequired(uints[3], uints[1])) {
            revert InvalidFeeSent();
        }

        merkleMinter.requestMint(
            _wonderbitsPOAP, 
            uints[0], 
            uints[1], 
            msg.value, 
            abi.encode(to, uints[2], uints[3], proof)
        );
    }

    // check the fee required to mint a specific POAP token
    function checkFeeRequired(uint256 pricePerToken, uint256 amount) public view returns (uint256) {
        return (pricePerToken + IZoraCreator1155(_wonderbitsPOAP).mintFee()) * amount;
    }
}