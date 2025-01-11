// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../utils/Signatures.sol";
import "../utils/Hashes.sol";

/**
 * @dev Base SFT contract to handle all SFTs in Wonderbits. Uses the ERC1155 standard.
 *
 * This is the 'no sig' version which does not require a signature to mint as the admin will handle the minting.
 */
abstract contract SFTBaseNoSig is ERC1155, Signatures, Hashes {
    using MessageHashUtils for bytes32;

    /**
     * @dev Mints {amount} of an SFT with ID {id} to {to}.
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        // optional data for minting
        bytes calldata data
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, id, amount, data);
    }

    /**
     * @dev Batch mints multiple SFTs of IDs {ids} at different amounts to {to}.
     */
    function mintBatch(
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        // optional data for minting
        bytes calldata data
    ) external virtual {
        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev Burns {amount} of an SFT with ID {id} from the sender.
     *
     * NOTE: Optionally, in-game, calling this function will also deposit the equivalent amount of the SFT into an in-game asset, usable in Wonderbits.
     * Calling this function directly may NOT deposit the equivalent amount in-game.
     */
    function burn(
        uint256 id,
        uint256 amount
    ) external virtual {
        _burn(_msgSender(), id, amount);
    }

    /**
     * @dev Batch burns multiple SFTs of IDs {ids} at different amounts from the sender.
     *
     * NOTE: Optionally, in-game, calling this function will also deposit the equivalent amounts of the SFTs into in-game assets, usable in Wonderbits.
     * Calling this function directly may NOT deposit the equivalent amounts in-game.
     */
    function burnBatch(
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external virtual {
        _burnBatch(_msgSender(), ids, amounts);
    }

    /**
     * @dev Consolidated {supportsInterface} to handle multiple inheritance.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
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