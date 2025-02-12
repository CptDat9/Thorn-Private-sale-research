// SPDX-License-Identifier:MIT
pragma solidity 0.8.4;
interface ITokenPrice {
    function getAssetPrice(address _asset) external view returns(uint);

}