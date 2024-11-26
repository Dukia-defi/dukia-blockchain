// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router.sol";
import "../../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

// interface IUniswapV2Router02 {
//     function addLiquidity(
//         address tokenA,
//         address tokenB,
//         uint amountADesired,
//         uint amountBDesired,
//         uint amountAMin,
//         uint amountBMin,
//         address to,
//         uint deadline
//     ) external returns (uint amountA, uint amountB, uint liquidity);

//     function factory() external pure returns (address);

//     function WETH() external pure returns (address);
// }

contract AddLiquidity is Ownable(msg.sender)  {
    // Uniswap V2 Router address
    address public immutable ROUTER_ADDRESS;

    // Token addresses
    address public immutable USDC;
    address public immutable DAI;

    // Events
    event LiquidityAdded(uint256 usdcAmount, uint256 daiAmount, uint256 liquidity);

    event TokensWithdrawn(address token, address to, uint256 amount);

    constructor(address _routerAddress, address _usdc, address _dai) {
        ROUTER_ADDRESS = _routerAddress;
        USDC = _usdc;
        DAI = _dai;
    }

    /**
     * @notice Adds liquidity to USDC-DAI pool
     * @param usdcAmount Amount of USDC to add
     * @param daiAmount Amount of DAI to add
     * @param slippagePercent Maximum slippage allowed (1 = 0.01%)
     */
    function addLiquidity(uint256 usdcAmount, uint256 daiAmount, uint256 slippagePercent) external onlyOwner {
        require(slippagePercent <= 1000, "Slippage too high"); // Max 10%

        // Transfer tokens to this contract
        IERC20(USDC).transferFrom(msg.sender, address(this), usdcAmount);
        IERC20(DAI).transferFrom(msg.sender, address(this), daiAmount);

        // Calculate minimum amounts with slippage
        uint256 minUsdcAmount = usdcAmount * (10000 - slippagePercent) / 10000;
        uint256 minDaiAmount = daiAmount * (10000 - slippagePercent) / 10000;

        // Approve router
        IERC20(USDC).approve(ROUTER_ADDRESS, usdcAmount);
        IERC20(DAI).approve(ROUTER_ADDRESS, daiAmount);

        // Add liquidity
        (uint256 amountUSDC, uint256 amountDAI, uint256 liquidity) = IUniswapV2Router02(ROUTER_ADDRESS).addLiquidity(
            USDC, DAI, usdcAmount, daiAmount, minUsdcAmount, minDaiAmount, address(this), block.timestamp + 15
        );

        emit LiquidityAdded(amountUSDC, amountDAI, liquidity);

        // Refund excess tokens to sender if any
        if (amountUSDC < usdcAmount) {
            IERC20(USDC).transfer(msg.sender, usdcAmount - amountUSDC);
        }
        if (amountDAI < daiAmount) {
            IERC20(DAI).transfer(msg.sender, daiAmount - amountDAI);
        }
    }

    /**
     * @notice Withdraws LP tokens to specified address
     * @param token LP token address
     * @param to Recipient address
     * @param amount Amount to withdraw
     */
    function withdrawTokens(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).transfer(to, amount);
        emit TokensWithdrawn(token, to, amount);
    }

    /**
     * @notice Returns the LP token balance of this contract
     * @param lpToken LP token address to check
     */
    function getLPBalance(address lpToken) external view returns (uint256) {
        return IERC20(lpToken).balanceOf(address(this));
    }

    /**
     * @notice Emergency function to approve tokens if needed
     * @param token Token to approve
     * @param spender Address to approve
     * @param amount Amount to approve
     */
    function approveToken(address token, address spender, uint256 amount) external onlyOwner {
        IERC20(token).approve(spender, amount);
    }
}
