// SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./interfaces/uniswapV3/IUniswapV3Pool.sol";
import "./interfaces/aaveOracle/IAaveOracle.sol";
import "./interfaces/ILuminexRouter.sol";
import "./interfaces/IERC20.sol";
import "./Policy.sol";
import "./libraries/SafeMath.sol";
import "hardhat/console.sol";

contract TokenPrice is Policy {
    using SafeMath for uint;

    struct LpInfo {
        address lpToken;
        address otherHalf;
    }

    address public USDT_ADDRESS;
    address public AAVE_ORACLE;
    address public ILLUMINEX_ROUTER;
    address public THORN_ADDRESS;
    uint THORN_PRICE;

    mapping(address => bool) public supportTokensPriceOracle;
    mapping(address => LpInfo) public lpTokens;

    constructor(
        address _usdtAddress,
        address _thornAddress
        // address _aaveOracle,
        // address _illuminexRouter,
        // address[] memory _tokensOracleSupported
    ) {
        USDT_ADDRESS = _usdtAddress;
        THORN_ADDRESS = _thornAddress;
        // AAVE_ORACLE = _aaveOracle;
        // ILLUMINEX_ROUTER = _illuminexRouter;

        // uint256 length = _tokensOracleSupported.length;
        // for (uint i = 0; i < length; i++) {
        //     supportTokensPriceOracle[_tokensOracleSupported[i]] = true;
        // }
    }

    // function setUsdtAddress(address _usdtAddress) external onlyPolicy() {
    //     require(_usdtAddress != address(0) && _usdtAddress != USDT_ADDRESS, "invalid new usdt address");
    //     USDT_ADDRESS = _usdtAddress;
    // }

    function setAaveOracle(address _aaveOracle) external onlyPolicy {
        require(
            _aaveOracle != address(0) && _aaveOracle != AAVE_ORACLE,
            "invalid new pancake router address"
        );
        AAVE_ORACLE = _aaveOracle;
    }

    function setSupportTokenOraclePrice(
        address _token,
        bool _status
    ) external onlyPolicy {
        require(
            _token != address(0) && supportTokensPriceOracle[_token] != _status,
            "invalid!"
        );
        supportTokensPriceOracle[_token] = _status;
    }

    function getLpToken(address _token) public view returns (LpInfo memory) {
        return lpTokens[_token];
    }

    function setLpTokens(
        address _tokenA,
        LpInfo memory _multiLpTokens
    ) external onlyPolicy {
        require(_tokenA != address(0), "invalid token address");
        require(
            !supportTokensPriceOracle[_tokenA],
            "Token is supported by oracle"
        );

        require(
            supportTokensPriceOracle[_multiLpTokens.otherHalf],
            "Token B is not supported by oracle"
        );
        lpTokens[_tokenA] = _multiLpTokens;
    }

    function _getAssetPriceUsdt(address _asset) internal view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = _asset;
        path[1] = USDT_ADDRESS;
        if (supportTokensPriceOracle[_asset]) {
            uint[] memory amounts = ILuminexRouter(ILLUMINEX_ROUTER)
                .getAmountsOut(1, path);
            return
                amounts[1].mul(10 ** IERC20(USDT_ADDRESS).decimals()).div(
                    10 ** 18
                );
        }
        return 0;
    }

    function getAssetPrice(address _asset) public view returns (uint) {
        if (_asset == THORN_ADDRESS) {
            return uint(2).mul(10 ** IERC20(USDT_ADDRESS).decimals()).div(100);
        }

        if (_asset == USDT_ADDRESS) {
            return uint(1).mul(10 ** IERC20(USDT_ADDRESS).decimals());
        }

        if (supportTokensPriceOracle[_asset]) {
            return
                IAaveOracle(AAVE_ORACLE)
                    .getAssetPrice(_asset)
                    .mul(10 ** IERC20(USDT_ADDRESS).decimals())
                    .div(10 ** 8);
        }

        uint256 balanceTokenA = IERC20(_asset).balanceOf(
            lpTokens[_asset].lpToken
        );
        address otherHalf = lpTokens[_asset].otherHalf;

        uint256 balanceTokenB = IERC20(otherHalf).balanceOf(
            lpTokens[_asset].lpToken
        );
        uint256 tokenBPrice = IAaveOracle(AAVE_ORACLE).getAssetPrice(otherHalf);

        uint256 amount = balanceTokenB
            .mul(tokenBPrice)
            .mul(10 ** IERC20(_asset).decimals())
            .mul(10 ** IERC20(USDT_ADDRESS).decimals())
            .div(balanceTokenA)
            .div(10 ** IERC20(otherHalf).decimals())
            .div(10 ** 8);
        return amount;
    }
}
