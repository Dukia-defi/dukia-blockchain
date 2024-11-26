
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../interface/IERC20.sol";
import "../interface/IPool.sol";
import "../interface/IPoolAddressesProvider.sol";


interface IVariableDebtToken {
    function approveDelegation(address delegatee, uint256 amount) external;
}
interface IAtoken{
     function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
     function approve(address spender, uint256 amount) external returns (bool);
}


contract AaveInteractionDelegate {
    address public owner;
    IPoolAddressesProvider public immutable poolProvider;
    IPool public pool;

    constructor(address _poolProviderAddress) {
        poolProvider = IPoolAddressesProvider(_poolProviderAddress);
        pool = IPool(poolProvider.getPool());
        owner = msg.sender;
    }

    //To get user account data eg ltv, health factor, the borrowing power, etc

    function getUserAccountData(address user) public view returns ( uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor) {
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

    function approveContractForSpending(address tokenAddress, uint256 amount) external {
        require(
            IERC20(tokenAddress).allowance(msg.sender, address(this)) >= amount,
            "Insufficient allowance. Approve the contract first."
        );

        // The contract can now transfer the user's tokens
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
    }

    function approveDelegation(address asset, uint256 amount) public {
        // Fetch the variable debt token address
        address variableDebtTokenAddress = getVariableDebtTokenAddress(asset);
        require(variableDebtTokenAddress != address(0), "Invalid asset or no debt token");

        // Approve delegation to the delegatee
        IVariableDebtToken(variableDebtTokenAddress).approveDelegation(address(this), amount);
    }

    function supply(address tokenAddress, uint256 amount) public {

        DataTypes.ReserveData memory reserveData = pool.getReserveData(tokenAddress);
        require(reserveData.aTokenAddress != address(0), "Token not supported in Aave pool");

        // Check allowance explicitly
        require(IERC20(tokenAddress).allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        
        // Transfer tokens to this contract
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        // Approve Aave pool to spend tokens
        require(IERC20(tokenAddress).approve(address(pool), amount), "Approval failed");
        
        // Supply to Aave pool
        try pool.supply(tokenAddress, amount, msg.sender, 0) {
            // Supply successful
        } catch Error(string memory reason) {
            revert(string(abi.encodePacked("Supply failed: ", reason)));
        } catch {
            revert("Supply failed: unknown reason");
        }
    }
    function borrow(address tokenAddress, uint256 amount, uint256 interestRateMode) public {
        DataTypes.ReserveData memory reserveData = pool.getReserveData(tokenAddress);
        IVariableDebtToken(reserveData.variableDebtTokenAddress).approveDelegation(address(this), amount );
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

    function withdraw(address tokenAddress, uint256 amount) public {
        // Withdraw the specified amount from Aave
        DataTypes.ReserveData memory reserveData = pool.getReserveData(tokenAddress);
        IAtoken(reserveData.aTokenAddress).transferFrom(msg.sender,address(this), amount );
        pool.withdraw(tokenAddress,  type(uint256).max, msg.sender);
    }

}

// import "../interface/IERC20.sol";
// import "../interface/IPool.sol";
// import "../interface/IPoolAddressesProvider.sol";

// contract AaveInteractionDelegate {
//     address public owner;
//     IPoolAddressesProvider public immutable poolProvider;
//     IPool public pool;
    
//     constructor(address _poolProviderAddress) {
//         poolProvider = IPoolAddressesProvider(_poolProviderAddress);
//         pool = IPool(poolProvider.getPool());
//         owner = msg.sender;
//     }

//     modifier onlyOwner() {
//         require(msg.sender == owner, "Not the contract owner");
//         _;
//     }

//     function getUserAccountData(address user)
//         public
//         view
//         returns (
//             uint256 totalCollateralBase,
//             uint256 totalDebtBase,
//             uint256 availableBorrowsBase,
//             uint256 currentLiquidationThreshold,
//             uint256 ltv,
//             uint256 healthFactor
//         )
//     {
//         return pool.getUserAccountData(user);
//     }


//     function approve(address tokenAddress, uint256 amount) external  {
//         IERC20(tokenAddress).approve(address(pool), amount);
//     }

//     // function supply(address tokenAddress, uint256 amount) external payable  {
//     //     // Prepare the calldata for the supply function
//     //     bytes memory data = abi.encodeWithSelector(
//     //         IPool.supply.selector,
//     //         tokenAddress,
//     //         amount,
//     //         address(this),
//     //         0
//     //     );
        
//     //     // Approve before delegatecall
//     //     IERC20(tokenAddress).approve(address(pool), amount);

//     //     // Execute delegatecall
//     //     (bool success, ) = address(pool).delegatecall(data);
//     //     require(success, "Supply delegatecall failed");
//     // }

//     function supply(address tokenAddress, uint256 amount) external {
//         // Transfer tokens from the sender to this contract
//         IERC20 token = IERC20(tokenAddress);
        
//         // Check allowance
//         require(
//             token.allowance(msg.sender, address(this)) >= amount, 
//             "Insufficient token allowance"
//         );
        
//         // Transfer tokens to this contract
//         require(
//             token.transferFrom(msg.sender, address(this), amount), 
//             "Token transfer failed"
//         );
        
//         // Approve the pool to spend tokens
//         require(
//             token.approve(address(pool), amount), 
//             "Token approval failed"
//         );
        
//         // Supply tokens to Aave
//         pool.supply(
//             tokenAddress, 
//             amount, 
//             msg.sender,  // Supply to the original sender
//             0  // Referral code
//         );
//     }


//     function borrow(
//         address tokenAddress,
//         uint256 amount,
//         uint256 interestRateMode
//     ) external  {
//         // Prepare the calldata for the borrow function
//         bytes memory data = abi.encodeWithSelector(
//             IPool.borrow.selector,
//             tokenAddress,
//             amount,
//             interestRateMode,
//             0,
//             address(this)
//         );

//         // Execute delegatecall
//         (bool success, ) = address(pool).delegatecall(data);
//         require(success, "Borrow delegatecall failed");
//     }

//     function repay(
//         address tokenAddress,
//         uint256 amount,
//         uint256 interestRateMode
//     ) external  {
//         // Approve before delegatecall
//         IERC20(tokenAddress).approve(address(pool), amount);

//         // Prepare the calldata for the repay function
//         bytes memory data = abi.encodeWithSelector(
//             IPool.repay.selector,
//             tokenAddress,
//             amount,
//             interestRateMode,
//             address(this)
//         );

//         // Execute delegatecall
//         (bool success, ) = address(pool).delegatecall(data);
//         require(success, "Repay delegatecall failed");
//     }

//     function withdraw(address tokenAddress, uint256 amount) external  {
//         // Prepare the calldata for the withdraw function
//         bytes memory data = abi.encodeWithSelector(
//             IPool.withdraw.selector,
//             tokenAddress,
//             amount,
//             address(this)
//         );

//         // Execute delegatecall
//         (bool success, ) = address(pool).delegatecall(data);
//         require(success, "Withdraw delegatecall failed");
//     }

//     // Function to receive Ether
//     receive() external payable {}
// }