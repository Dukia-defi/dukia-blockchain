// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./interface/IERC20.sol";
import "./interface/IPool.sol";
import "./interface/IPoolAddressesProvider.sol";

interface IVariableDebtToken {
    function approveDelegation(address delegatee, uint256 amount) external;
}

interface IAtoken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract AaveInteraction {
    address public owner;
    IPoolAddressesProvider public immutable poolProvider;
    IPool public pool;

    constructor(address _poolProviderAddress) {
        poolProvider = IPoolAddressesProvider(_poolProviderAddress);
        pool = IPool(poolProvider.getPool());
        owner = msg.sender;
    }

    function getVariableDebtTokenAddress(address asset) external view returns (address) {
        DataTypes.ReserveData memory reserveData = pool.getReserveData(asset);
        return reserveData.variableDebtTokenAddress;
    }

    function getAToken(address asset) external view returns (address) {
        DataTypes.ReserveData memory reserveData = pool.getReserveData(asset);
        return reserveData.aTokenAddress;
    }

    function approve(address tokenAddress, uint256 amount) external {
        IERC20(tokenAddress).approve(address(pool), amount);
    }

    function supply(address tokenAddress, uint256 amount) external payable {
        // Supply the token to Aave
        IERC20(tokenAddress).approve(address(pool), amount); // Ensure pool is approved
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        pool.supply(tokenAddress, amount, msg.sender, 0);
        //  DataTypes.ReserveData memory reserveData = pool.getReserveData(tokenAddress);
        // IVariableDebtToken(reserveData.variableDebtTokenAddress).approveDelegation(address(this), amount );
    }

    function borrow(address tokenAddress, uint256 amount, uint256 interestRateMode) external {
        DataTypes.ReserveData memory reserveData = pool.getReserveData(tokenAddress);
        IVariableDebtToken(reserveData.variableDebtTokenAddress).approveDelegation(address(this), amount);
        pool.borrow(
            tokenAddress,
            amount,
            interestRateMode,
            0, // referral code
            msg.sender
        );

        emit Borrowed(msg.sender, tokenAddress, amount, interestRateMode);
    }

    event Borrowed(address indexed user, address indexed token, uint256 amount, uint256 interestRateMode);

    function repay(address tokenAddress, uint256 amount, uint256 interestRateMode) external {
        // Repay the specified amount to Aave
        IERC20(tokenAddress).approve(address(pool), amount); // Ensure pool is approved
        pool.repay(tokenAddress, amount, interestRateMode, msg.sender);
    }

    function withdraw(address tokenAddress, uint256 amount) external {
        // Withdraw the specified amount from Aave
        DataTypes.ReserveData memory reserveData = pool.getReserveData(tokenAddress);
        IAtoken(reserveData.aTokenAddress).transferFrom(msg.sender, address(this), amount);
        pool.withdraw(tokenAddress, type(uint256).max, msg.sender);
    }
}
