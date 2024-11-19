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

    constructor(address _uniswapRouter) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        // uniswapFactory = IUniswapV2Factory(UNISWAP_FACTORY_ADDRESS);
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

        return uniswapRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
    }

    // // Add liquidity to a pair
    // function addLiquidity(
    //     address tokenA,
    //     address tokenB,
    //     uint amountA,
    //     uint amountB,
    //     uint amountAMin,
    //     uint amountBMin,
    //     uint deadline
    // ) external {
    //     IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
    //     IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

    //     IERC20(tokenA).approve(address(uniswapRouter), amountA);
    //     IERC20(tokenB).approve(address(uniswapRouter), amountB);

    //     uniswapRouter.addLiquidity(
    //         tokenA,
    //         tokenB,
    //         amountA,
    //         amountB,
    //         amountAMin,
    //         amountBMin,
    //         msg.sender,
    //         deadline
    //     );
    // }

    // // Remove liquidity from a pair
    // function removeLiquidity(
    //     address tokenA,
    //     address tokenB,
    //     uint liquidity,
    //     uint amountAMin,
    //     uint amountBMin,
    //     uint deadline
    // ) external {
    //     address pair = uniswapFactory.getPair(tokenA, tokenB);
    //     IERC20(pair).transferFrom(msg.sender, address(this), liquidity);
    //     IERC20(pair).approve(address(uniswapRouter), liquidity);

    //     uniswapRouter.removeLiquidity(
    //         tokenA,
    //         tokenB,
    //         liquidity,
    //         amountAMin,
    //         amountBMin,
    //         msg.sender,
    //         deadline
    //     );
    // }
}
