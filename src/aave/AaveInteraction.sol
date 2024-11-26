// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../interface/IERC20.sol";
import "../interface/IPool.sol";
import "../interface/IPoolAddressesProvider.sol";

interface IVariableDebtToken {
    function approveDelegation(address delegatee, uint256 amount) external;
}

interface IAtoken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
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

    // Get user account data (e.g., LTV, health factor, borrowing power)
    function getUserAccountData(address user) public view returns (
        uint256 totalCollateralBase,
        uint256 totalDebtBase,
        uint256 availableBorrowsBase,
        uint256 currentLiquidationThreshold,
        uint256 ltv,
        uint256 healthFactor
    ) {
        return pool.getUserAccountData(user);
    }

    // Get the variable debt token address for an asset
    function getVariableDebtTokenAddress(address asset) public view returns (address) {
        DataTypes.ReserveData memory reserveData = pool.getReserveData(asset);
        return reserveData.variableDebtTokenAddress;
    }

    // Get the aToken address for an asset
    function getAToken(address asset) public view returns (address) {
        DataTypes.ReserveData memory reserveData = pool.getReserveData(asset);
        return reserveData.aTokenAddress;
    }

     function approveTokens(address tokenAddress, uint256 amount) public {
        IERC20(tokenAddress).approve(address(this), amount);
    }

    // Supply tokens to Aave
    function supply(address tokenAddress, uint256 amount) public {
        // Approve the pool to spend tokens
        IERC20(tokenAddress).approve(address(pool), amount);

        require(IERC20(tokenAddress).allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");

        // Transfer tokens from user to this contract
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        // Supply tokens to Aave
        pool.supply(tokenAddress, amount, msg.sender, 0);
    }

    // Borrow tokens from Aave
    function borrow(address tokenAddress, uint256 amount, uint256 interestRateMode) public {
        // Get variable debt token address
        address variableDebtTokenAddress = getVariableDebtTokenAddress(tokenAddress);

        // Approve delegation for variable debt token
        IVariableDebtToken(variableDebtTokenAddress).approveDelegation(address(this), amount);

        // Borrow tokens from Aave
        pool.borrow(tokenAddress, amount, interestRateMode, 0, msg.sender);

        emit Borrowed(msg.sender, tokenAddress, amount, interestRateMode);
    }

    event Borrowed(address indexed user, address indexed token, uint256 amount, uint256 interestRateMode);

    // Repay borrowed tokens to Aave
    function repay(address tokenAddress, uint256 amount, uint256 interestRateMode) external {
        // Approve the pool to spend tokens for repayment
        IERC20(tokenAddress).approve(address(pool), amount);
        

        // Repay the specified amount to Aave
        pool.repay(tokenAddress, amount, interestRateMode, msg.sender);
    }

    // Withdraw supplied tokens from Aave
    function withdraw(address tokenAddress, uint256 amount) public {
        // Get aToken address for the asset being withdrawn
        DataTypes.ReserveData memory reserveData = pool.getReserveData(tokenAddress);
        
        // Transfer aTokens from user to this contract (if necessary)
        IAtoken(reserveData.aTokenAddress).transferFrom(msg.sender, address(this), amount);

        // Withdraw the specified amount from Aave
        pool.withdraw(tokenAddress, type(uint256).max, msg.sender);
    }

    // Function to receive Ether (if needed)
    receive() external payable {
        // This function allows the contract to receive Ether
    }

}