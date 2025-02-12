// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.4;

import "./IERC20.sol";

interface IsThorn is IERC20 {
    function rebase( uint256 travaProfit_, uint epoch_) external returns (uint256);

    function circulatingSupply() external view returns (uint256);

    function gonsForBalance( uint amount ) external view returns ( uint );

    function balanceForGons( uint gons ) external view returns ( uint );

    function index() external view returns ( uint );
}