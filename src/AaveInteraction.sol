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

    //To get user account data eg ltv, health factor, the borrowing power, etc

    function getUserAccountData(address user)
        public
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        return pool.getUserAccountData(user);
    }

    function getVariableDebtTokenAddress(address asset) public view returns (address) {
        DataTypes.ReserveData memory reserveData = pool.getReserveData(asset);
        return reserveData.variableDebtTokenAddress;
    }

    function getAToken(address asset) public view returns (address) {
        DataTypes.ReserveData memory reserveData = pool.getReserveData(asset);
        return reserveData.aTokenAddress;
    }

    function approve(address tokenAddress, uint256 amount) external {
        IERC20(tokenAddress).approve(address(pool), amount);
    }

    function supply(address tokenAddress, uint256 amount) public payable {
        // Supply the token to Aave
        IERC20(tokenAddress).approve(address(pool), amount); // Ensure pool is approved
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        pool.supply(tokenAddress, amount, msg.sender, 0);
        //  DataTypes.ReserveData memory reserveData = pool.getReserveData(tokenAddress);
        // IVariableDebtToken(reserveData.variableDebtTokenAddress).approveDelegation(address(this), amount );
    }

    function approveAndSupply(address contractAddress, address tokenAddress, uint256 amount) external {
        require(IERC20(tokenAddress).approve(contractAddress, amount), "approval failed");
        supply(tokenAddress, amount);
    }

    function borrow(address tokenAddress, uint256 amount, uint256 interestRateMode) public {
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

    function approveAndBorrow(address contractAddress, address asset, uint256 amount, uint256 interestRateMode)
        external
    {
        address debtTokenAddress = getVariableDebtTokenAddress(asset);
        IVariableDebtToken(debtTokenAddress).approveDelegation(contractAddress, type(uint256).max);

        borrow(asset, amount, interestRateMode);
    }

    event Borrowed(address indexed user, address indexed token, uint256 amount, uint256 interestRateMode);

    function repay(address tokenAddress, uint256 amount, uint256 interestRateMode) external {
        // Repay the specified amount to Aave
        IERC20(tokenAddress).approve(address(pool), amount); // Ensure pool is approved
        pool.repay(tokenAddress, amount, interestRateMode, msg.sender);
    }

    function withdraw(address tokenAddress, uint256 amount) public {
        // Withdraw the specified amount from Aave
        DataTypes.ReserveData memory reserveData = pool.getReserveData(tokenAddress);
        IAtoken(reserveData.aTokenAddress).transferFrom(msg.sender, address(this), amount);
        pool.withdraw(tokenAddress, type(uint256).max, msg.sender);
    }

    function approveAndWithdraw(address contractAddress, address tokenAddress, uint256 amount) external {
        address aTokenAddress = getAToken(tokenAddress);
        IAtoken(aTokenAddress).approve(contractAddress, type(uint256).max);
        withdraw(tokenAddress, amount);
    }
}
