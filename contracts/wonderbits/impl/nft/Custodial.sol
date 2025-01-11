// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../../interfaces/ICustodial.sol";
import "../../errors/ICustodialErrors.sol";
import "../../utils/EventSignatures.sol";
import "../../utils/Signatures.sol";
import "erc721a/contracts/IERC721A.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "../../utils/Hashes.sol";

/**
 * @dev Custodial contract to handle custody of a user's NFTs while being used in-game.
 *
 * Supports all NFT contracts in Wonderbits.
 */
contract Custodial is ICustodial, ICustodialErrors, AccessControl, Signatures, EventSignatures, Hashes {
    // maps from the NFT contract address to the token ID to the original owner's address.
    // NOTE: if the token has not been transferred into custody, the zero address will be returned.
    mapping (address => mapping (uint256 => address)) private _custody;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev Stores an NFT in custody, allowing the user to use it in-game.
     *
     * NOTE: {contract} - the NFT contract address of the token to store in custody.
     *
     * Requires the admin's signature.
     */
    function storeInCustody(
        address nftContract, 
        uint256 tokenId,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external virtual {
        // ensure that the admin's signature is valid
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(opHash(_msgSender(), sigData[0])),
            sigData[1]
        );

        IERC721A c = IERC721A(nftContract);

        // check if the token is owned by the caller. throws if not
        if (c.ownerOf(tokenId) != _msgSender()) {
            revert NotTokenOwner();
        }

        // check if the token is already in custody. throws if it is
        if (_custody[nftContract][tokenId] != address(0)) {
            revert AlreadyInCustody();
        }

        // transfer the NFT to this contract
        c.safeTransferFrom(_msgSender(), address(this), tokenId);

        // record the custody of the token.
        _custody[nftContract][tokenId] = _msgSender();

        // emit a StoreInCustody event efficiently
        assembly {
            log3(
                0,
                0,
                _STORE_IN_CUSTODY_EVENT_SIGNATURE,
                nftContract,
                tokenId
            )
        }
    }

    /**
     * @dev Releases an NFT from custody, transferring the NFT back to the original owner.
     *
     * Requires the admin's signature.
     */
    function releaseFromCustody(
        address nftContract, 
        uint256 tokenId,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external {// ensure that the admin's signature is valid
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(opHash(_msgSender(), sigData[0])),
            sigData[1]
        );

        IERC721A c = IERC721A(nftContract);

        // check if the address calling this function is the original owner of the NFT
        if (_custody[nftContract][tokenId] != _msgSender()) {
            revert NotTokenOwner();
        }

        // transfer the NFT to this contract.
        c.safeTransferFrom(address(this), _msgSender(), tokenId);

        // record the custody of the token.
        _custody[nftContract][tokenId] = address(0);

        // emit a ReleaseFromCustody event efficiently
        assembly {
            log3(
                0,
                0,
                _RELEASE_FROM_CUSTODY_EVENT_SIGNATURE,
                nftContract,
                tokenId
            )
        }
    }

    /********* WITHDRAWALS*************** */
    /**
     * @dev Withdraws balance from this contract to admin. 
     * NOTE: Please do NOT send unnecessary funds to this contract.
     * This is used as a mechanism to transfer any balance that this contract has to admin.
     * We will NOT be responsible for any funds transferred accidentally.
     */ 
    function withdrawFunds() external onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(_msgSender()).transfer(address(this).balance);
    }
    /**
     * @dev Withdraws tokens from this contract to admin.
     * NOTE: Please do NOT send unnecessary tokens to this contract.
     * This is used as a mechanism to transfer any tokens that this contract has to admin.
     * We will NOT be responsible for any tokens transferred accidentally.
     */
    function withdrawTokens(address _tokenAddr, uint256 _amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20 _token = IERC20(_tokenAddr);
        _token.transfer(_msgSender(), _amount);
    }
    /**************************************** */
}