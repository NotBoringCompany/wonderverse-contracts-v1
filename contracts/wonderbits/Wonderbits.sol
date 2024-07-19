// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./IPlayer.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Wonderbits is IPlayer, AccessControl {
    // maps from the player's address to their player data
    mapping (address => Player) private players;
}