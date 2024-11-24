// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./interface/IERC20.sol";
import "./interface/IPool.sol";
import "./interface/IPoolAddressesProvider.sol";

contract AaveInteractionDelegate {
    address public owner;
    IPoolAddressesProvider public immutable poolProvider;
    IPool public pool;
    
    constructor(address _poolProviderAddress) {
        poolProvider = IPoolAddressesProvider(_poolProviderAddress);
        pool = IPool(poolProvider.getPool());
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

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


    function approve(address tokenAddress, uint256 amount) external  {
        IERC20(tokenAddress).approve(address(pool), amount);
    }

    function supply(address tokenAddress, uint256 amount) external payable  {
        // Prepare the calldata for the supply function
        bytes memory data = abi.encodeWithSelector(
            IPool.supply.selector,
            tokenAddress,
            amount,
            address(this),
            0
        );
        
        // Approve before delegatecall
        IERC20(tokenAddress).approve(address(pool), amount);
        
        // Execute delegatecall
        (bool success, ) = address(pool).delegatecall(data);
        require(success, "Supply delegatecall failed");
    }

    function borrow(
        address tokenAddress,
        uint256 amount,
        uint256 interestRateMode
    ) external  {
        // Prepare the calldata for the borrow function
        bytes memory data = abi.encodeWithSelector(
            IPool.borrow.selector,
            tokenAddress,
            amount,
            interestRateMode,
            0,
            address(this)
        );
        
        // Execute delegatecall
        (bool success, ) = address(pool).delegatecall(data);
        require(success, "Borrow delegatecall failed");
    }

    function repay(
        address tokenAddress,
        uint256 amount,
        uint256 interestRateMode
    ) external  {
        // Approve before delegatecall
        IERC20(tokenAddress).approve(address(pool), amount);
        
        // Prepare the calldata for the repay function
        bytes memory data = abi.encodeWithSelector(
            IPool.repay.selector,
            tokenAddress,
            amount,
            interestRateMode,
            address(this)
        );
        
        // Execute delegatecall
        (bool success, ) = address(pool).delegatecall(data);
        require(success, "Repay delegatecall failed");
    }

    function withdraw(address tokenAddress, uint256 amount) external  {
        // Prepare the calldata for the withdraw function
        bytes memory data = abi.encodeWithSelector(
            IPool.withdraw.selector,
            tokenAddress,
            amount,
            address(this)
        );
        
        // Execute delegatecall
        (bool success, ) = address(pool).delegatecall(data);
        require(success, "Withdraw delegatecall failed");
    }

    // Function to receive Ether
    receive() external payable {}
}