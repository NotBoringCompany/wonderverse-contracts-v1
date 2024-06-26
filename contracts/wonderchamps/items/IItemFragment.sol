// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// Interface for an item fragment.
interface IItemFragment {
    // represents an item fragment owned by a player.
    struct ItemFragment {
        // the fragment's name
        bytes32 name;
        // the amount of this fragment owned by the player
        uint256 amount;
    }
}