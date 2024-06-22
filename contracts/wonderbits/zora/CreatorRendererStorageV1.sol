// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ICreatorRendererControl} from "./ICreatorRendererControl.sol";
import {IRenderer1155} from "./IRenderer1155.sol";

/// @notice Creator Renderer Storage Configuration Contract V1
abstract contract CreatorRendererStorageV1 is ICreatorRendererControl {
    /// @notice Mapping for custom renderers
    mapping(uint256 => IRenderer1155) public customRenderers;

    uint256[50] private __gap;
}
