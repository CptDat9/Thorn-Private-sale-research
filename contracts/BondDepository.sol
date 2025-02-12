// SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./libraries/SafeMath.sol";
import "./libraries/SafeERC20.sol";
import "./interfaces/ITokenPrice.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/IStakingHelper.sol";

import "./PolicyUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract BondDepository is PolicyUpgradeable, PausableUpgradeable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    /* ======== EVENTS ======== */

    event BondCreated(
        uint deposit,
        uint payout,
        uint expires,
        uint nativePrice
    );
    event BondRedeemed(address recipient, uint payout, uint remaining);
    event BondPriceChanged(uint priceInUSD, uint internalPrice);
    event ControlVariableAdjustment(
        uint initialBCV,
        uint newBCV,
        uint adjustment,
        bool addition
    );
    event WithdrawalStuckAmount(address token, uint amount);
    event Whitelisted(address user);

    /* ======== STATE VARIABLES ======== */

    address public staking; // to auto-stake payout
    address public stakingHelper; // to stake and claim if no staking warmup
    bool public useHelper;

    // address public tokenPrice;
    address public Thorn; // token given as payment for bond
    address public principle; // token used to create bond

    Terms public terms; // stores terms for new bonds

    mapping(address => Bond) public bondInfo; // stores bond information for depositors

    uint public totalDebt; // total value of outstanding bonds; used for pricing

    mapping(address => bool) public whitelisted;
    address[] public whitelist;

    /* ======== STRUCTS ======== */

    // Info for creating new bonds
    struct Terms {
        uint buyingTimeStart;
        uint buyingTime;
        uint vestingTerm; // in blocks
        uint maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint maxDebt; // 9 decimal debt ratio, max % total supply created as debt
        uint discountRatio;
        uint minimumThorn;
    }

    // Info for bond holder
    struct Bond {
        uint totalBought;
        uint payout; // Thorn remaining to be paid
        uint vesting; // Blocks left to vest
        uint lastBlock; // Last interaction
        uint pricePaid; // In DAI, for front end viewing
    }

    /* ======== INITIALIZATION ======== */

    function initialize(
        address _Thorn,
        address _principle
    )
        public
        // address _tokenPrice
        // address _DAO,
        // address _bondCalculator
        initializer
    {
        require(_Thorn != address(0));
        Thorn = _Thorn;
        require(_principle != address(0));
        principle = _principle;
        // require( _tokenPrice != address(0) );
        // tokenPrice = _tokenPrice;
        __Policy_init();
        __Pausable_init_unchained();
    }

    /**
     * Pause relaying.
     */
    function pause() external onlyPolicy {
        _pause();
    }

    function unpauseContract() external onlyPolicy {
        _unpause();
    }

    function initializeBondTerms(
        uint _buyingTimeStart,
        uint _buyingTime,
        uint _vestingTerm,
        uint _maxPayout,
        uint _maxDebt,
        uint _discountRatio,
        uint _minimumThorn
    ) external onlyPolicy {
        terms = Terms({
            buyingTimeStart: _buyingTimeStart,
            buyingTime: _buyingTime,
            vestingTerm: _vestingTerm,
            maxPayout: _maxPayout,
            maxDebt: _maxDebt,
            discountRatio: _discountRatio,
            minimumThorn: _minimumThorn
        });
    }

    /* ======== POLICY FUNCTIONS ======== */

    enum PARAMETER {
        BUYING_TIME_START,
        BUYING_TIME,
        VESTING_TERM,
        PAYOUT,
        MAX_DEBT,
        DISCOUNTRATIO,
        MINIMUMORAI
    }
    /**
     *  @notice set parameters for new bonds
     *  @param _parameter PARAMETER
     *  @param _input uint
     */
    function setBondTerms(
        PARAMETER _parameter,
        uint _input
    ) external onlyPolicy {
        if (_parameter == PARAMETER.BUYING_TIME_START) {
            // 0
            terms.buyingTimeStart = _input;
        } else if (_parameter == PARAMETER.BUYING_TIME) {
            // 0
            terms.buyingTime = _input;
        } else if (_parameter == PARAMETER.VESTING_TERM) {
            // 0
            // require( _input >= 129600, "Vesting must be longer than 36 hours" );
            terms.vestingTerm = _input;
        } else if (_parameter == PARAMETER.VESTING_TERM) {
            // 0
            // require( _input >= 129600, "Vesting must be longer than 36 hours" );
            terms.vestingTerm = _input;
        } else if (_parameter == PARAMETER.PAYOUT) {
            // 1
            // require( _input <= 5000, "Payout cannot be above 5 percent" );
            terms.maxPayout = _input;
        } else if (_parameter == PARAMETER.MAX_DEBT) {
            // 3
            terms.maxDebt = _input;
        } else if (_parameter == PARAMETER.DISCOUNTRATIO) {
            // 4
            require(_input <= 50000, "Discount ratio cannot exceed 50%");
            terms.maxDebt = _input;
        } else if (_parameter == PARAMETER.MINIMUMORAI) {
            // 5
            require(_input > 0, "Invalid minimum thorn price");
            terms.minimumThorn = _input;
        }
    }

    /**
     *  @notice set contract for auto stake
     *  @param _staking address
     *  @param _helper bool
     */
    function setStaking(address _staking, bool _helper) external onlyPolicy {
        require(_staking != address(0));
        if (_helper) {
            useHelper = true;
            stakingHelper = _staking;
        } else {
            useHelper = false;
            staking = _staking;
        }
    }

    function setThornAddress(address _Thorn) external onlyPolicy {
        require(_Thorn != address(0), "invalid address");
        Thorn = _Thorn;
    }
    function setPrincipleAddress(address _principle) external onlyPolicy {
        require(_principle != address(0), "invalid address");
        principle = _principle;
    }

    function setWhitelist(address[] calldata _addresses) external onlyPolicy {
        for (uint i = 0; i < _addresses.length; i++) {
            if (whitelisted[_addresses[i]]) {
                continue;
            }
            whitelisted[_addresses[i]] = true;
            whitelist.push(_addresses[i]);
            emit Whitelisted(_addresses[i]);
        }
    }

    function toggleWhitelisted(
        address _address
    ) external onlyPolicy returns (bool) {
        whitelisted[_address] = !whitelisted[_address];
        if (whitelisted[_address]) {
            whitelist.push(_address);
        } else {
            address[] memory newWhitelist = new address[](whitelist.length - 1);
            for (uint i = 0; i < whitelist.length; i++) {
                if (whitelist[i] == _address) {
                    continue;
                }
                newWhitelist[i] = whitelist[i];
            }
            whitelist = newWhitelist;
        }
        return whitelisted[_address];
    }

    function withdrawStuckAmount(
        uint _amount,
        address _token
    ) external onlyPolicy {
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit WithdrawalStuckAmount(_token, _amount);
    }

    /* ======== USER FUNCTIONS ======== */

    /**
     *  @notice deposit bond
     *  @param _amount uint
     *  @param _depositor address
     *  @return uint
     */
    function deposit(
        uint _amount,
        uint _maxPrice,
        address _depositor
    ) external whenNotPaused returns (uint) {
        require(_depositor != address(0), "Invalid address");
        require(
            whitelisted[_depositor],
            "User is not in whitelist to buy bond"
        );

        require(
            block.timestamp >= terms.buyingTimeStart,
            "It's not time to buy token yet!"
        );

        require(
            block.timestamp <= terms.buyingTimeStart + terms.buyingTime,
            "Bond expired!"
        );

        uint nativePrice = bondPrice();

        require(
            _maxPrice >= nativePrice,
            "Slippage limit: more than max price"
        ); // slippage protection
        require(nativePrice > terms.minimumThorn, "Price is too low");

        uint amountThorn = getPayout(_amount);

        IERC20(principle).safeTransferFrom(msg.sender, address(this), _amount);

        // total debt is increased
        totalDebt = totalDebt.add(amountThorn);
        // require(1<0, "debug 2");

        require(totalDebt <= terms.maxDebt, "Max capacity of presale reached");

        require(
            amountThorn + bondInfo[_depositor].totalBought <=
                getPayout(terms.maxPayout),
            "Amount of Thorn token exceeds the maximum payout!"
        );

        // depositor info is stored
        bondInfo[_depositor] = Bond({
            totalBought: bondInfo[_depositor].totalBought.add(amountThorn),
            payout: bondInfo[_depositor].payout.add(amountThorn),
            vesting: terms.vestingTerm,
            lastBlock: block.timestamp,
            pricePaid: nativePrice
        });

        // indexed events are emitted
        emit BondCreated(
            _amount,
            amountThorn,
            block.timestamp.add(terms.vestingTerm),
            nativePrice
        );
        emit BondPriceChanged(bondPriceInUSD(), bondPrice());

        return amountThorn;
    }

    /**
     *  @notice redeem bond for user
     *  @param _recipient address
     *  @return uint
     */
    function redeem(address _recipient) external whenNotPaused returns (uint) {
        Bond memory info = bondInfo[_recipient];
        uint percentToVest = percentToVestFor(_recipient); // (blocks since last interaction / vesting term remaining)

        if (percentToVest >= 10000) {
            // if fully vested
            delete bondInfo[_recipient]; // delete user info
            emit BondRedeemed(_recipient, info.payout, 0); // emit bond data
            return stakeOrSend(_recipient, info.payout); // pay user everything due
        } else {
            // if unfinished
            // calculate payout vested
            uint payout = info.payout.mul(percentToVest).div(10000);

            // store updated deposit info
            bondInfo[_recipient] = Bond({
                totalBought: info.totalBought,
                payout: info.payout.sub(payout),
                vesting: info.vesting.sub(block.timestamp.sub(info.lastBlock)),
                lastBlock: block.timestamp,
                pricePaid: info.pricePaid
            });

            emit BondRedeemed(_recipient, payout, bondInfo[_recipient].payout);
            return stakeOrSend(_recipient, payout);
        }
    }

    // /* ======== INTERNAL HELPER FUNCTIONS ======== */

    /**
     *  @notice allow user to stake payout automatically
     *  @param _amount uint
     *  @return uint
     */
    function stakeOrSend(
        address _recipient,
        uint _amount
    ) internal returns (uint) {
        require(Thorn != address(0), "invalid thorn address!");
        uint256 amount = _amount.mul(10 ** IERC20(Thorn).decimals()).div(
            10 ** 18
        ); // mockup decimal thorn
        IERC20(Thorn).safeTransfer(_recipient, amount); // send payout
        return _amount;
    }

    /* ======== VIEW FUNCTIONS ======== */

    function getAssetPrice(address _asset) public view returns (uint) {
        if (_asset == Thorn) {
            return uint(2).mul(10 ** IERC20(principle).decimals()).div(100);
        }

        if (_asset == principle) {
            return uint(1).mul(10 ** IERC20(principle).decimals());
        }
        return 0;
    }

    function getPayout(uint256 _amount) public view returns (uint) {
        uint256 payoutRate = getPayoutRate();
        uint payout = _amount
        .mul(payoutRate).div(10 ** IERC20(principle).decimals());
        // .mul( 10 ** 18 )
        // .div(10**18)
        return payout;
    }

    function getPayoutRate() public view returns (uint) {
        uint256 nativePrice = bondPrice();
        uint principlePrice = getAssetPrice(principle);
        uint payoutRate = principlePrice.mul(10 ** 18).div(nativePrice);
        return payoutRate;
    }
    /**
     *  @notice calculate current bond price and remove floor if above
     *  @return price_ uint
     */
    function bondPrice() public view returns (uint price_) {
        uint thornPrice = getThornPrice();

        if (block.timestamp > terms.buyingTime + terms.buyingTimeStart) {
            return thornPrice;
        }

        if (block.timestamp < terms.buyingTimeStart) {
            return thornPrice;
        }

        uint256 discountThornPrice = thornPrice
            .mul(uint(100000).sub(terms.discountRatio))
            .div(100000);

        if (discountThornPrice < terms.minimumThorn) {
            return terms.minimumThorn;
        }
        // newOrachaiPrice = (discountThornPrice - minimunThorn) (buyingTime + buyingTimeStart - block.timestamp) * maxDebt / buyingTime / (maxDebt - totalDebt) + minimumThorn
        uint newThornPrice = (
            (discountThornPrice.sub(terms.minimumThorn))
                .mul(
                    (terms.buyingTimeStart).add(terms.buyingTime).sub(
                        block.timestamp
                    )
                )
                .mul(terms.maxDebt)
                .div(terms.buyingTime)
                .div((terms.maxDebt).sub(totalDebt))
        ).add(terms.minimumThorn);

        return newThornPrice;
    }

    /**
     *  @notice converts bond price to DAI value
     *  @return price_ uint
     */
    function bondPriceInUSD() public view returns (uint price_) {
        return
            bondPrice().mul(10 ** IERC20(principle).decimals()).div(
                getAssetPrice(principle)
            );
    }

    /**
     *  @notice calculate how far into vesting a depositor is
     *  @param _depositor address
     *  @return percentToVest_ uint
     */
    function percentToVestFor(address _depositor) public view returns (uint) {
        Bond memory bond = bondInfo[_depositor];

        uint blocksSinceLast = block.timestamp.sub(bond.lastBlock);
        uint vesting = bond.vesting;

        if (vesting > 0) {
            return blocksSinceLast.mul(10000).div(vesting);
        } else {
            return 0;
        }
    }

    function getBondInfo(address _depositer) public view returns (Bond memory) {
        return bondInfo[_depositer];
    }

    function getWhitelist() public view returns (address[] memory) {
        return whitelist;
    }

    function getWhitelistStatus(address _address) public view returns (bool) {
        return whitelisted[_address];
    }

    function getThornPrice() public view returns (uint) {
        // if(Thorn == address(0)) {
        //     return 0;
        // }

        return getAssetPrice(Thorn);
    }

    function getWithdrawableAmount(
        address _depositor
    ) public view returns (uint) {
        Bond memory info = bondInfo[_depositor];
        uint percentToVest = percentToVestFor(_depositor); // (blocks since last interaction / vesting term remaining)

        if (percentToVest >= 10000) {
            // if fully vested
            return info.payout;
        } else {
            return info.payout.mul(percentToVest).div(10000);
        }
    }
}
