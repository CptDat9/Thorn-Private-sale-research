// SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./libraries/SafeMath.sol";
import "./libraries/SafeERC20.sol";
import "./Policy.sol";

contract PrivateSaleRoundThree is Policy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ======== EVENTS ======== */

    event PrivateSaleBuy(uint256 amount, uint256 payout, address depositor);
    event PrivateSaleRedeem(
        uint256 amount,
        uint256 remainning,
        address depositor
    );
    event WithdrawalStuckAmount(address token, uint amount);
    /* ======== STATE VARIABLES ======== */

    mapping(address => PriSale) public bondInfo;

    uint256 private thornPrice; // Price of Thorn token (decimal = 2)
    uint256 public totalDebt; // totalDebt

    address public principle; // USDT
    address public Thorn;
    Terms public terms;

    struct Terms {
        uint buyingTimeStart;
        uint buyingTime;
        uint vestingTimeStart; // in blocks
        uint vestingTerm; // in blocks
        uint cliffingTimeStart;
        uint cliffingTerm;
        uint discountRatio;
        uint maxDebt; //maxDebt
        uint maxPayout;
        uint TGE; // TGE
    }

    struct PriSale {
        uint totalBought;
        uint amountClaim;
        uint payout; // Thorn remaining to be paid
        uint vesting; // Blocks left to vest
        uint lastBlock; // Last interaction
        uint pricePaid; // In principle, for front end viewing
    }

    struct Deposit {
        address depositor;
        uint amount;
    }

    /* ======== INITIALIZATION ======== */

    constructor(address _ethUSDT) {
        require(_ethUSDT != address(0));
        principle = _ethUSDT;
    }

    function initializePrivateSaleRound(
        uint _buyingTimeStart,
        uint _buyingTime,
        uint _vestingTimeStart,
        uint _vestingTerm,
        uint _cliffingTimeStart,
        uint _cliffingTerm,
        uint _discountRatio,
        uint _maxDebt,
        uint _maxPayout,
        uint _TGE
    ) external onlyPolicy {
        require(_vestingTimeStart > _buyingTimeStart, "invalid time!");
        require(_discountRatio <= 50000, "Discount ratio cannot exceed 50%");

        terms = Terms({
            buyingTimeStart: _buyingTimeStart,
            buyingTime: _buyingTime,
            vestingTimeStart: _vestingTimeStart,
            vestingTerm: _vestingTerm,
            cliffingTimeStart: _cliffingTimeStart,
            cliffingTerm: _cliffingTerm,
            discountRatio: _discountRatio,
            maxDebt: _maxDebt,
            maxPayout: _maxPayout,
            TGE: _TGE
        });
    }

    /* ======== POLICY FUNCTIONS ======== */

    enum PARAMETER {
        BUYING_TIME_START,
        BUYING_TIME,
        VESTING_TIME_START,
        VESTING_TERM,
        CLIFFING_TIME_START,
        CLIFFING_TERM,
        DISCOUNTRATIO,
        MAX_DEBT,
        MAX_PAYOUT,
        TGE
    }

    /**
     *  @notice set parameters for new bonds
     *  @param _parameter PARAMETER
     *  @param _input uint
     */
    function setPrivateSale(
        PARAMETER _parameter,
        uint256 _input
    ) external onlyPolicy {
        if (_parameter == PARAMETER.BUYING_TIME_START) {
            terms.buyingTimeStart = _input;
        } else if (_parameter == PARAMETER.BUYING_TIME) {
            terms.buyingTime = _input;
        } else if (_parameter == PARAMETER.VESTING_TIME_START) {
            terms.vestingTimeStart = _input;
        } else if (_parameter == PARAMETER.VESTING_TERM) {
            terms.vestingTerm = _input;
        } else if (_parameter == PARAMETER.CLIFFING_TIME_START) {
            terms.cliffingTimeStart = _input;
        } else if (_parameter == PARAMETER.CLIFFING_TERM) {
            terms.cliffingTerm = _input;
        } else if (_parameter == PARAMETER.MAX_DEBT) {
            terms.maxDebt = _input;
        } else if (_parameter == PARAMETER.MAX_PAYOUT) {
            terms.maxPayout = _input;
        } else if (_parameter == PARAMETER.DISCOUNTRATIO) {
            require(_input <= 50000, "Discount ratio cannot exceed 50%");
            terms.discountRatio = _input;
        } else if (_parameter == PARAMETER.TGE) {
            terms.TGE = _input;
        }
    }

    function setThornPrice(uint256 _thornPrice) external onlyPolicy {
        require(_thornPrice != 0, "invalid price");
        thornPrice = _thornPrice;
    }

    function setThornAddress(address _Thorn) external onlyPolicy {
        require(_Thorn != address(0), "invalid address");
        Thorn = _Thorn;
    }

    function setUsdtAddress(address _ethUSDT) external onlyPolicy {
        require(_ethUSDT != address(0), "invalid address");
        principle = _ethUSDT;
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
     *  @notice deposit private sale
     *  @param _amount principle
     *  @param _depositor address
     *  @return uint256 amount thorn
     */
    function updateDepositInformation(
        uint256 _amount,
        address _depositor
    ) external returns (uint256) {
        require(_depositor != address(0), "Invalid address");

        // require(
        //     isWhiteList[_depositor] || !isUseWhiteList,
        //     "User is not in whitelist to buy bond"
        // );

        uint256 amountTHORN = getPayout(_amount);
        // IERC20(principle).safeTransferFrom(_depositor, address(this), _amount);

        totalDebt = totalDebt.add(amountTHORN);

        uint256 amountClaim = _getAmountTGE(amountTHORN);
        uint256 payout = amountTHORN - amountClaim;

        // _depositor info is stored
        bondInfo[_depositor] = PriSale({
            totalBought: bondInfo[_depositor].totalBought.add(amountTHORN),
            amountClaim: bondInfo[_depositor].amountClaim.add(amountClaim),
            payout: bondInfo[_depositor].payout.add(payout),
            vesting: terms.vestingTerm,
            lastBlock: block.timestamp,
            pricePaid: _amount
        });

        emit PrivateSaleBuy(_amount, amountTHORN, _depositor);
        return _amount;
    }

    function updateBatchDepositInformation(
        Deposit[] calldata depositInformation
    ) external returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](depositInformation.length);
        for (uint i = 0; i < depositInformation.length; i++) {
            address _depositor = depositInformation[i].depositor;
            uint _amount = depositInformation[i].amount;

            require(_depositor != address(0), "Invalid address");

            uint256 amountTHORN = getPayout(_amount);
            totalDebt = totalDebt.add(amountTHORN);

            uint256 amountClaim = _getAmountTGE(amountTHORN);
            uint256 payout = amountTHORN - amountClaim;

            // _depositor info is stored
            bondInfo[_depositor] = PriSale({
                totalBought: bondInfo[_depositor].totalBought.add(amountTHORN),
                amountClaim: bondInfo[_depositor].amountClaim.add(amountClaim),
                payout: bondInfo[_depositor].payout.add(payout),
                vesting: terms.vestingTerm,
                lastBlock: block.timestamp,
                pricePaid: _amount
            });

            emit PrivateSaleBuy(_amount, amountTHORN, _depositor);
            // return _amount;
            amounts[i] = _amount;
        }
        return amounts;
    }

    /**
     *  @notice redeem private sale
     *  @param _recipient address
     *  @return uint256
     */
    function redeem(address _recipient) external returns (uint256) {
        require(_recipient != address(0), "Invalid address");
        require(
            block.timestamp >= terms.cliffingTimeStart,
            "It's not time to vest or claim token"
        );

        PriSale memory private_sale = bondInfo[_recipient];
        uint256 amountToClaim = private_sale.amountClaim;

        if (amountToClaim > 0) {
            bondInfo[_recipient].amountClaim = 0;
        }

        uint percentVested = percentVestedFor(_recipient); // (blocks since last interaction / vesting term remaining)

        if (percentVested >= 10000) {
            // if fully vested
            delete bondInfo[_recipient]; // delete user info
            emit PrivateSaleRedeem(private_sale.payout, 0, _recipient);
            return stakeOrSend(_recipient, private_sale.payout + amountToClaim); // pay user everything due
        } else {
            // if unfinished
            // calculate payout vested
            uint payout = private_sale.payout.mul(percentVested).div(10000);
            uint256 lastBlock = private_sale.lastBlock;

            if (lastBlock < terms.vestingTimeStart) {
                lastBlock = terms.vestingTimeStart;
            }

            uint vestingRemain = private_sale.vesting;
            if (block.timestamp >=  lastBlock) {
                vestingRemain = vestingRemain.sub(block.timestamp.sub(lastBlock));
            }

            // store updated deposit info
            bondInfo[_recipient] = PriSale({
                totalBought: private_sale.totalBought,
                amountClaim: 0,
                payout: private_sale.payout.sub(payout),
                vesting: vestingRemain,
                lastBlock: block.timestamp,
                pricePaid: private_sale.pricePaid
            });

            emit PrivateSaleRedeem(payout, payout + amountToClaim, _recipient);
            return stakeOrSend(_recipient, payout + amountToClaim);
        }
    }

    /* ======== INTERNAL HELPER FUNCTIONS ======== */

    /**
     *  @notice allow user to stake payout automatically
     *  @param _amount uint
     *  @return uint
     */
    function stakeOrSend(
        address _recipient,
        uint _amount
    ) internal returns (uint256) {
        require(Thorn != address(0), "invalid thorn address!");
        IERC20(Thorn).safeTransfer(_recipient, _amount); // send payout
        return _amount;
    }

    /* ======== INTERNAL FUNCTIONS ======== */

    function _getAmountTGE(uint256 _amount) internal view returns (uint256) {
        uint256 tge = terms.TGE;
        return (_amount.mul(tge)).div(100000);
    }

    /* ======== VIEW FUNCTIONS ======== */

    function percentVestedFor(address _depositor) public view returns (uint) {
        PriSale memory private_sale = bondInfo[_depositor];

        if (block.timestamp < terms.vestingTimeStart) {
            return 0;
        }

        uint256 lastBlock = private_sale.lastBlock;
        // if this is the first time claim
        if (lastBlock < terms.vestingTimeStart) {
            lastBlock = terms.vestingTimeStart;
        }

        uint blocksSinceLast = block.timestamp.sub(lastBlock);
        uint vesting = private_sale.vesting;

        if (vesting > 0) {
            return blocksSinceLast.mul(10000).div(vesting);
        } else {
            return 0;
        }
    }

    function getTotalReceived(
        address _depositor
    ) public view returns (uint256) {
        PriSale memory private_sale = bondInfo[_depositor];
        if (private_sale.amountClaim > 0) {
            return private_sale.amountClaim.add(private_sale.payout);
        } else return private_sale.payout;
    }

    function bondPrice() public view returns (uint256) {
        return
            thornPrice.mul(uint(100000).sub(terms.discountRatio)).div(100000);
    }

    // get amount THORN when buying with amount of principle in wei
    function getPayout(uint256 _amount) public view returns (uint256) {
        uint256 payoutRate = getPayoutRate();
        uint payout = _amount
        .mul(payoutRate).div(10 ** IERC20(principle).decimals());
        // .mul( 10 ** 18 )
        // .div(10**18)
        return payout;
    }

    function getPayoutRate() public view returns (uint) {
        uint256 nativePrice = bondPrice();
        uint principlePrice = 10 ** IERC20(principle).decimals();
        uint payoutRate = principlePrice.mul(10 ** 18).div(nativePrice);
        return payoutRate;
    }

    function getThornPrice() public view returns (uint) {
        return thornPrice;
    }

    // for vesting
    function getWithdrawableAmount(
        address _depositor
    ) public view returns (uint) {
        PriSale memory info = bondInfo[_depositor];
        uint percentVested = percentVestedFor(_depositor); // (blocks since last interaction / vesting term remaining)

        if (percentVested >= 10000) {
            // if fully vested
            return info.payout.add(info.amountClaim);
        } else if (percentVested == 0) {
            if(block.timestamp >= terms.cliffingTimeStart)
                return info.amountClaim;
            else return 0;
        } else {
            return
                (info.payout.mul(percentVested).div(10000)).add(
                    info.amountClaim
                );
        }
    }

    // for bought
    function getClaimedAmount(address _depositor) public view returns (uint) {
        PriSale memory info = bondInfo[_depositor];

        // if(info.amountClaim != 0) {
        //     return 0;
        // }

        return (info.totalBought).sub(info.payout).sub(info.amountClaim);
    }

    function getBondInfo(
        address _depositer
    ) public view returns (PriSale memory) {
        return bondInfo[_depositer];
    }

    function getMaxPayout(address _depositor) public view returns (uint256) {
        uint256 maxPayout = getPayout(terms.maxPayout).sub(
            bondInfo[_depositor].totalBought
        );
        uint256 ethUSDTBalance = IERC20(principle).balanceOf(_depositor);

        if (getPayout(ethUSDTBalance) < maxPayout) {
            maxPayout = getPayout(ethUSDTBalance);
        }

        if (maxPayout > (terms.maxDebt).sub(totalDebt)) {
            maxPayout = (terms.maxDebt).sub(totalDebt);
        }

        return maxPayout;
    }
}
