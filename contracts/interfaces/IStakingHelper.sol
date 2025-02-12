// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.4;

interface IStakingHelper {
    function stake( uint _amount, address _recipient ) external;
}