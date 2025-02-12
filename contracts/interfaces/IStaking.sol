// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.4;

interface IStaking {
    function stake( uint _amount, address _recipient ) external returns ( bool );

    function claim( address _recipient ) external;

    function forfeit() external returns (uint256);

    function toggleDepositLock() external;

    function unstake( uint _amount, bool _trigger ) external;

    function rebase() external;

    function index() external view returns (uint256);

    function contractBalance() external view returns (uint256);

}