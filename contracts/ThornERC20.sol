// SPDX-License-Identifier:MIT
pragma solidity 0.8.4;
import "./libraries/SafeMath.sol";

import "./helper/ERC20Permit.sol";
import "./helper/VaultOwned.sol";

contract ThornERC20 is ERC20Permit, VaultOwned {

    using SafeMath for uint256;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) ERC20Token(name_, symbol_, decimals_) {
        _totalSupply = totalSupply_ * (10 ** decimals_) ;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function mint(address account_, uint256 amount_) external onlyVault() {
        _mint(account_, amount_);
    }

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }
     
    function burnFrom(address account_, uint256 amount_) public virtual {
        _burnFrom(account_, amount_);
    }

    function _burnFrom(address account_, uint256 amount_) public virtual {
        uint256 decreasedAllowance_ =
            allowance(account_, msg.sender).sub(
                amount_,
                "ERC20: burn amount exceeds allowance"
            );

        _approve(account_, msg.sender, decreasedAllowance_);
        _burn(account_, amount_);
    }
}