//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./interface/IPool.sol";
import "./interface/IPoolAddressesProvider.sol";
import "./interface/IERC20.sol";

contract ReadWalletData {

    address public poolAddress;

    constructor(address _poolAddress) {
        poolAddress = _poolAddress;
    }

    //function to fetch data such as total collateral, total debt, liquidity threshold, and health factor
    function getAaveAccountData(address user) external view returns (
        uint256 totalCollateral,
        uint256 totalDebt,
        uint256 availableBorrow,
        uint256 liquidationThreshold,
        uint256 ltv,
        uint256 healthFactor
    ) {
        IPool pool= IPool(poolAddress);
        return pool.getUserAccountData(user);
    }

    //supply function from IPool interface
    // function lendAssetToAave(address asset, uint256 amount) external {
    //     IPool pool = IPool(poolAddress);
    //     IERC20(asset).approve(poolAddress, amount);
    //     pool.supply(asset, amount, msg.sender, 0);
    // }

    // //borrow() function
    // function borrowAssetFromAave(address asset, uint256 amount, uint256 interestRateMode) external {
    //     IPool pool = IPool(poolAddress);
    //     pool.borrow(asset, amount, interestRateMode, 0, msg.sender);
    // }

    // //withdraw() function 
    // function withdrawAssetFromAave(address asset, uint256 amount) external {
    //     IPool pool = IPool(poolAddress);
    //     pool.withdraw(asset, amount, msg.sender);
    // }
}

