// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ICreatorRoyaltiesControl} from "./ICreatorRoyaltiesControl.sol";

/// Imagine. Mint. Enjoy.
/// @title CreatorRoyaltiesControl
/// @author ZORA @iainnash / @tbtstl
/// @notice Royalty storage contract pattern
abstract contract CreatorRoyaltiesStorageV1 is ICreatorRoyaltiesControl {
    mapping(uint256 => RoyaltyConfiguration) public royalties;

    uint256[50] private __gap;
}
