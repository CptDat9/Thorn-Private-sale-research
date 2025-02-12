// SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

interface IBond {
    // Info for creating new bonds
    struct Terms {
        // uint controlVariable; // scaling variable for price
        uint256 buyingTimeStart;
        uint vestingTimeStart; // in blocks
        uint vestingTerm; // in blocks
        // uint minimumPrice; // vs principle value
        uint maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint fee; // as % of bond payout, in hundreths. ( 500 = 5% = 0.05 for every 1 paid)
        uint maxDebt; // 9 decimal debt ratio, max % total supply created as debt
        uint discountRatio;
    }

    // Info for bond holder
    struct Bond {
        uint payout; // Thorn remaining to be paid
        uint vesting; // Blocks left to vest
        uint lastBlock; // Last interaction
        uint pricePaid; // In DAI, for front end viewing
    }

    // Info for incremental adjustments to control variable 
    struct Adjust {
        bool add; // addition or subtraction
        uint rate; // increment
        uint target; // BCV when adjustment finished
        uint buffer; // minimum length (in blocks) between adjustments
        uint lastBlock; // block when last adjustment made
    }

    function deposit(uint _amount, uint _maxPrice, address _depositor) external returns(uint);
    function redeem( address _recipient, bool _stake ) external returns ( uint );
    
    function maxPayout() external view returns(uint);
    function payoutFor(uint _value) external view returns(uint);
    
    function bondPrice() external view returns(uint price_);
    function bondPriceInUSD() external view returns(uint price_);
    
    function debtRation() external view returns(uint debtRatio);
    function standardizedDebtRatio() external view returns ( uint );
    function currentDebt() external view returns ( uint );
    function debtDecay() external view returns ( uint decay_ );
    function percentVestedFor( address _depositor ) external view returns ( uint percentVested_ );
    function pendingPayoutFor( address _depositor ) external view returns ( uint pendingPayout_ );
    
    function Thorn() external returns(address);
    function principle() external returns(address);
    function treasury() external returns(address);
    
    function staking() external returns(address);
    function stakingHelper() external returns(address);
    function useHelper() external returns(bool);
    
    function terms() external returns(Terms memory);
    function adjustment() external returns(Adjust memory);
    
    function getBondInfo(address _depositer) external view returns(Bond memory);
    
    function totalDebt() external returns(uint);
    function lastDecay() external returns(uint);
    function assetPrice() external returns(uint);
    function orchaiPrice() external returns(uint);

}