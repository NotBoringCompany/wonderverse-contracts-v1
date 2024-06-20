// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC165Upgradeable} from "@zoralabs/openzeppelin-contracts-upgradeable/contracts/interfaces/IERC165Upgradeable.sol";
import {ILimitedMintPerAddressErrors} from "./IZoraCreator1155Errors.sol";

interface ILimitedMintPerAddress is IERC165Upgradeable, ILimitedMintPerAddressErrors {
    function getMintedPerWallet(address token, uint256 tokenId, address wallet) external view returns (uint256);
}
