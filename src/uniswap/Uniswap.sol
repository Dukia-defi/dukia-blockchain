// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../../lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "../../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../../lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "../../src/interface/IERC20.sol";

contract UniswapIntegration {
    IUniswapV2Router02 public immutable uniswapRouter;
    address public immutable WETH;
    address public owner;

    event TokensSwapped(
        address indexed sender,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] path,
        address indexed to,
        uint256 deadline,
        uint256[] amounts
    );

    event LiquidityAdded(uint256 token, uint256 Amount, uint256 liquidity);

    // Event for liquidity removal
    event LiquidityRemoved(address tokenA, address tokenB, uint256 amountA, uint256 amountB, uint256 liquidity);
    // IUniswapV2Factory public uniswapFactory;

    constructor(address _uniswapRouter) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        owner = msg.sender;
    }

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

        amounts = uniswapRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);

        emit TokensSwapped(msg.sender, amountIn, amountOutMin, path, to, deadline, amounts);

        return amounts;
    }

    // function addLiquidity(
    //     address tokenA,
    //     address tokenB,
    //     uint256 amountADesired,
    //     uint256 amountBDesired,
    //     uint256 slippagePercent
    // ) external {
    //     require(slippagePercent <= 1000, "Slippage too high"); // Max 10%
    //     // Check allowance before transfer
    //     require(
    //         IERC20(tokenA).allowance(msg.sender, address(this)) >= amountADesired,
    //         "Insufficient allowance for tokenA"
    //     );
    //     require(
    //         IERC20(tokenB).allowance(msg.sender, address(this)) >= amountBDesired,
    //         "Insufficient allowance for tokenB"
    //     );

    //     // Transfer tokens to this contract
    //     require(
    //         IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired),
    //         "Transfer of tokenA failed"
    //     );
    //     require(
    //         IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired),
    //         "Transfer of tokenB failed"
    //     );

    //     // Calculate minimum amounts with slippage
    //     uint256 minAmountA = amountADesired * (10000 - slippagePercent) / 10000;
    //     uint256 minAmountB = amountBDesired * (10000 - slippagePercent) / 10000;

    //     // Approve router (check current allowance first)
    //     if (IERC20(tokenA).allowance(address(this), address(uniswapRouter)) < amountADesired) {
    //         require(
    //             IERC20(tokenA).approve(address(uniswapRouter), amountADesired),
    //             "Failed to approve tokenA"
    //         );
    //     }
    //     if (IERC20(tokenB).allowance(address(this), address(uniswapRouter)) < amountBDesired) {
    //         require(
    //             IERC20(tokenB).approve(address(uniswapRouter), amountBDesired),
    //             "Failed to approve tokenB"
    //         );
    //     }
    //     // Add liquidity
    //     (uint256 amountA, uint256 amountB, uint256 liquidity) = uniswapRouter.addLiquidity(
    //         tokenA,
    //         tokenB,
    //         amountADesired,
    //         amountBDesired,
    //         minAmountA,
    //         minAmountB,
    //         msg.sender, // Changed to msg.sender instead of address(this)
    //         block.timestamp + 300 // Increased deadline to 5 minutes
    //     );

    //     emit LiquidityAdded(tokenA, tokenB, amountA, amountB, liquidity);

    //     // Refund excess tokens to sender if any
    //     if (amountA < amountADesired) {
    //         require(
    //             IERC20(tokenA).transfer(msg.sender, amountADesired - amountA),
    //             "Failed to refund excess tokenA"
    //         );
    //     }

    //     if (amountB < amountBDesired) {
    //         require(
    //             IERC20(tokenB).transfer(msg.sender, amountBDesired - amountB),
    //             "Failed to refund excess tokenB"
    //         );
    //     }
    // }

    function approve(address tokenAddress, uint256 amount) external  {
        IERC20(tokenAddress).approve(address(uniswapRouter), amount);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 slippagePercent
    ) external {
        require(slippagePercent <= 1000, "Slippage too high"); // Max 10%

        bytes memory data = abi.encodeWithSelector(
            uniswapRouter.addLiquidity.selector,
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            address(this),
            block.timestamp + 300
        );

        IERC20(tokenA).approve(address(uniswapRouter), amountADesired);
        IERC20(tokenB).approve(address(uniswapRouter), amountBDesired);
        
        // Execute delegatecall
        (bool success, ) = address(uniswapRouter).delegatecall(data);
        require(success, "Add liquidity failed");

        // emit LiquidityAdded(token amount, liquidity);
    }

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
        IERC20(token).approve(address(uniswapRouter), amountTokenDesired);

        // Add liquidity
        (uint256 amountToken, uint256 amountETH, uint256 liquidity) = uniswapRouter.addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            minAmountToken,
            amountETHMin,
            address(this),
            block.timestamp + 15
        );

        //emit LiquidityAdded(token, WETH, amountToken, amountETH, liquidity);

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
        address pair = IUniswapV2Factory(uniswapRouter.factory()).getPair(tokenA, tokenB);
        require(pair != address(0), "Pair does not exist");

        // Transfer liquidity tokens to the contract
        IERC20(pair).transferFrom(msg.sender, address(this), liquidity);

        // Approve the router to spend the liquidity tokens
        IERC20(pair).approve(address(uniswapRouter), liquidity);

        // Remove liquidity
        (uint256 amountA, uint256 amountB) = uniswapRouter.removeLiquidity(
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



    // function addLiquidity(
    //     address tokenA,
    //     address tokenB,
    //     uint256 amountADesired,
    //     uint256 amountBDesired,
    //     uint256 slippagePercent
    // ) external {
    //     require(slippagePercent <= 1000, "Slippage too high"); // Max 10%

    //     // Transfer tokens to this contract
    //     IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
    //     IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);

    //     // Calculate minimum amounts with slippage
    //     uint256 minAmountA = amountADesired * (10000 - slippagePercent) / 10000;
    //     uint256 minAmountB = amountBDesired * (10000 - slippagePercent) / 10000;

    //     // Approve router
    //     IERC20(tokenA).approve(address(uniswapRouter), amountADesired);
    //     IERC20(tokenB).approve(address(uniswapRouter), amountBDesired);

    //     // Add liquidity
    //     (uint256 amountA, uint256 amountB, uint256 liquidity) = uniswapRouter.addLiquidity(
    //         tokenA, tokenB, amountADesired, amountBDesired, minAmountA, minAmountB, address(this), block.timestamp + 15
    //     );

    //     emit LiquidityAdded(tokenA, tokenB, amountA, amountB, liquidity);

    //     // Refund excess tokens to sender if any
    //     if (amountA < amountADesired) {
    //         IERC20(tokenA).transfer(msg.sender, amountADesired - amountA);
    //     }
    //     if (amountB < amountBDesired) {
    //         IERC20(tokenB).transfer(msg.sender, amountBDesired - amountB);
    //     }
    // }

    // event LiquidityAdded(address tokenA, address tokenB, uint256 amountA, uint256 amountB, uint256 liquidity)

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
