// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../utils/Signatures.sol";
import "../utils/Hashes.sol";

/**
 * @dev Base NFT contract which also extends the ERC721A standard.
 */
abstract contract NFTBase is ERC721AQueryable, ERC721ABurnable, Signatures, Hashes {
    using MessageHashUtils for bytes32;

    /**
     * @dev Stores a mutable base URI for all tokens.
     */
    string private baseURI_;

    /**
     * @dev Returns the next token ID to be minted.
     */
    function nextTokenId() external view returns (uint256) {
        return _nextTokenId();
    }

    /**
     * @dev Mints a new NFT to {to}.
     * 
     * Requires the admin's signature to mint.
     */
    function mint(
        address to,
        // [0] - salt
        // [1] - adminSig
        bytes[2] calldata sigData
    ) external virtual {
        // ensure that the admin's signature is valid
        _checkAdminSignatureValid(
            MessageHashUtils.toEthSignedMessageHash(opHash(to, sigData[0])),
            sigData[1]
        );

        _safeMint(to, 1);
    }

    /**
     * @dev Sets the {_baseURI}.
     */
    function setBaseURI(string calldata uri) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI_ = uri;
    }

    /**
     * @dev Fetches the total number of tokens burned by everyone.
     */
    function totalBurned() public view returns (uint256) {
        return _totalBurned();
    }

    /**
     * @dev Gets the auxiliary data of a token (only used for whitelisting or limited quantity for minting, for example).
     */
    function getAux(address _owner) public view returns (uint64) {
        return _getAux(_owner);
    }

    /**
     * @dev See {ERC721A-tokenURI}.
     * 
     * Overridden to return a JSON file with the token ID.
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(tokenId)) _revert(URIQueryForNonexistentToken.selector);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId), ".json")) : '';
    }

    /**
     * @dev Consolidated {supportsInterface} to handle multiple inheritance.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, IERC721A, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Overrides the start token ID to be 1.
     */
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    /**
     * @dev Overrides {ERC721A-_baseURI} to return the base URI from {_baseURI} instead.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI_;
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