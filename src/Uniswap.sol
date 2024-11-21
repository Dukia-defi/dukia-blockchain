// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "./interface/IERC20.sol";

contract UniswapIntegration {
    IUniswapV2Router02 public immutable uniswapRouter;
    // IUniswapV2Factory public uniswapFactory;

    // address private constant UNISWAP_ROUTER_ADDRESS = 0xB26B2De65D07eBB5E54C7F6282424D3be670E1f0;
    // address private constant UNISWAP_FACTORY_ADDRESS = 0xF62c03E08ada871A0bEb309762E260a7a6a880E6;
    address public immutable ROUTER_ADDRESS = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;
    
    // Token addresses
    address public immutable USDC;
    address public immutable DAI;

    event LiquidityAdded(
        uint256 usdcAmount,
        uint256 daiAmount,
        uint256 liquidity
    );


    // constructor(address _uniswapRouter) {
    //     uniswapRouter = IUniswapV2Router02(_uniswapRouter);
    //     // uniswapFactory = IUniswapV2Factory(UNISWAP_FACTORY_ADDRESS);
    // }

    // Swap exact tokens for another token
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        require(IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn), "Transfer of token failed");
        IERC20(path[0]).approve(address(uniswapRouter), amountIn);

        return uniswapRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
    }

    function addLiquidity(
        uint256 usdcAmount,
        uint256 daiAmount,
        uint256 slippagePercent
    ) external  {
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
        (uint256 amountUSDC, uint256 amountDAI, uint256 liquidity) = 
            IUniswapV2Router02(ROUTER_ADDRESS).addLiquidity(
                USDC,
                DAI,
                usdcAmount,
                daiAmount,
                minUsdcAmount,
                minDaiAmount,
                address(this),
                block.timestamp + 15
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
    function withdrawTokens(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
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
    function approveToken(
        address token,
        address spender,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).approve(spender, amount);
    }

}
