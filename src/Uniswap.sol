// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "../src/interface/IERC20.sol";

contract UniswapIntegration {
    IUniswapV2Router02 public immutable uniswapRouter;
    // IUniswapV2Factory public uniswapFactory;

    // address private constant UNISWAP_ROUTER_ADDRESS = 0xB26B2De65D07eBB5E54C7F6282424D3be670E1f0;
    // address private constant UNISWAP_FACTORY_ADDRESS = 0xF62c03E08ada871A0bEb309762E260a7a6a880E6;
    address public immutable ROUTER_ADDRESS = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;
    // Token addresses
    // address public immutable tokenA;
    // address public immutable tokenB;
    address public immutable WETH;
    address public owner;

    event LiquidityAdded(
        uint256 usdcAmount,
        uint256 daiAmount,
        uint256 liquidity
    );

      // Event for liquidity removal
    event LiquidityRemoved(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    constructor(address _routerAddress)
    {
        ROUTER_ADDRESS = _routerAddress;
        owner = msg.sender;
    }


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 slippagePercent
    ) external {
        require(slippagePercent <= 1000, "Slippage too high"); // Max 10%

        // Transfer tokens to this contract
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);

        // Calculate minimum amounts with slippage
        uint256 minAmountA = amountADesired * (10000 - slippagePercent) / 10000;
        uint256 minAmountB = amountBDesired * (10000 - slippagePercent) / 10000;

        // Approve router
        IERC20(tokenA).approve(ROUTER_ADDRESS, amountADesired);
        IERC20(tokenB).approve(ROUTER_ADDRESS, amountBDesired);

       // Add liquidity
        (uint256 amountA, uint256 amountB, uint256 liquidity) =
        IUniswapV2Router02(ROUTER_ADDRESS).addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            minAmountA,
            minAmountB,
            address(this),
            block.timestamp + 15
        );

        emit LiquidityAdded(tokenA, tokenB, amountA, amountB, liquidity);

        // Refund excess tokens to sender if any
        if (amountA < amountADesired) {
            IERC20(tokenA).transfer(msg.sender, amountADesired - amountA);
        }
        if (amountB < amountBDesired) {
            IERC20(tokenB).transfer(msg.sender, amountBDesired - amountB);
        }
    }
    event LiquidityAdded(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );


    function addLiquidityEth(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 slippagePercent
    ) external payable {
        require(slippagePercent <= 1000, "Slippage too high"); // Max 10%
        require(msg.value >= amountETHMin, "Insufficient ETH sent");

        // Transfer token to this contract
        IERC20(token).transferFrom(msg.sender, address(this), amountTokenDesired);

        // Calculate minimum amounts with slippage
        uint256 minAmountToken = amountTokenDesired * (10000 - slippagePercent) / 10000;

        // Approve router
        IERC20(token).approve(ROUTER_ADDRESS, amountTokenDesired);

        // Add liquidity
        (uint256 amountToken, uint256 amountETH, uint256 liquidity) =
            IUniswapV2Router02(ROUTER_ADDRESS).addLiquidity(
                token,
                WETH,
                amountTokenDesired,
                msg.value,
                minAmountToken,
                amountETHMin,
                address(this),
                block.timestamp + 15
            );

        emit LiquidityAdded(token, WETH, amountToken, amountETH, liquidity);

        // Refund excess tokens to sender if any
        if (amountToken > amountTokenDesired) {
            IERC20(token).transfer(msg.sender, amountToken - amountTokenDesired);
        }

        // Transfer ETH back to sender
        payable(msg.sender).transfer(address(this).balance);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin
    ) external {


        // Get the pair address
        address pair = IUniswapV2Factory(IUniswapV2Router02(ROUTER_ADDRESS).factory()).getPair(tokenA, tokenB);
        require(pair != address(0), "Pair does not exist");

        // Transfer liquidity tokens to the contract
        IERC20(pair).transferFrom(msg.sender, address(this), liquidity);

        // Approve the router to spend the liquidity tokens
        IERC20(pair).approve(ROUTER_ADDRESS, liquidity);

        // Remove liquidity
        (uint256 amountA, uint256 amountB) = 
            IUniswapV2Router02(ROUTER_ADDRESS).removeLiquidity(
                tokenA,
                tokenB,
                liquidity,
                amountAMin,
                amountBMin,
                msg.sender, // Send tokens to the caller
                block.timestamp + 15
            );

        emit LiquidityRemoved(tokenA, tokenB, amountA, amountB, liquidity);
   }
  

}
//url:https://sepolia.etherscan.io/address/0x9368e572ebdbb882558e9d1aa68c3bd9cf9c66a6







   // function addLiquidity(
    //     uint256 usdcAmount,
    //     uint256 daiAmount,
    //     uint256 slippagePercent
    // ) external  {
    //     require(slippagePercent <= 1000, "Slippage too high"); // Max 10%
        
    //     // Transfer tokens to this contract
    //     IERC20(USDC).transferFrom(msg.sender, address(this), usdcAmount);
    //     IERC20(DAI).transferFrom(msg.sender, address(this), daiAmount);
        
    //     // Calculate minimum amounts with slippage
    //     uint256 minUsdcAmount = usdcAmount * (10000 - slippagePercent) / 10000;
    //     uint256 minDaiAmount = daiAmount * (10000 - slippagePercent) / 10000;
        
    //     // Approve router
    //     IERC20(USDC).approve(ROUTER_ADDRESS, usdcAmount);
    //     IERC20(DAI).approve(ROUTER_ADDRESS, daiAmount);
        
    //     // Add liquidity
    //     (uint256 amountUSDC, uint256 amountDAI, uint256 liquidity) = 
    //         IUniswapV2Router02(ROUTER_ADDRESS).addLiquidity(
    //             USDC,
    //             DAI,
    //             usdcAmount,
    //             daiAmount,
    //             minUsdcAmount,
    //             minDaiAmount,
    //             address(this),
    //             block.timestamp + 15
    //         );
            
    //     emit LiquidityAdded(amountUSDC, amountDAI, liquidity);
        
    //     // Refund excess tokens to sender if any
    //     if (amountUSDC < usdcAmount) {
    //         IERC20(USDC).transfer(msg.sender, usdcAmount - amountUSDC);
    //     }
    //     if (amountDAI < daiAmount) {
    //         IERC20(DAI).transfer(msg.sender, daiAmount - amountDAI);
    //     }
    // }