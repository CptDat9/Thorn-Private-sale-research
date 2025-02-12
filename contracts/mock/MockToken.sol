// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.4;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "hardhat/console.sol";

contract MockToken is ERC20 {
    constructor() ERC20("THN", "Thorn") {}

    function mint(address sender, uint256 amount) external {
        console.log("log in contract: mint to ", sender, "amount = ", amount);
        _mint(sender, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function sudoApprove(address _from, address _to, uint256 _amount) external {
        _approve(_from, _to, _amount);
    }
}
