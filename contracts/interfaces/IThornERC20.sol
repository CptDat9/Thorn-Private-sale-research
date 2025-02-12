// SPDX-License-Identifier:MIT
pragma solidity 0.8.4;
interface IThornERC20 {
    function burnFrom(address account_, uint256 amount_) external;
}