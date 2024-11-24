// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../src/uniswap/Uniswap.sol";
import "../src/interface/IERC20.sol";

contract UniswapScript is Script {
    address constant ROUTER_ADDRESS = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;
    address constant USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238; // 0x7Fc21ceb0C5003576ab5E101eB240c2b822c95d2
    address constant DAI = 0x68194a729C2450ad26072b3D33ADaCbcef39D574; //0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6
    address constant WETH = 0x7b79995e5F793A07bc00C7c19C34e753eB6e08Fd;

    UniswapIntegration public uniswapIntegration;

    function setUp() public {
        uniswapIntegration = new UniswapIntegration(ROUTER_ADDRESS); // Deploy the integration contract
    }

    function run() external {
        vm.startBroadcast();

        IERC20 usdc = IERC20(USDC);
        IERC20 dai = IERC20(DAI);

        uint256 usdcAmount = 0.5 * 10 ** 6; // 2 USDC (6 decimals)
        uint256 daiAmount = 0.5 * 10 ** 18; // 2 DAI (18 decimals)
        uint256 slippagePercent = 50; // 0.5% slippage tolerance
        uint256 amountETHMin = 0.01 ether;
        uint256 amountTokenMin = 99 * 10 ** 18;

        console.log("uniswapIntegration deployed at:", address(uniswapIntegration));

        // Approve UniswapIntegration to spend tokens
        usdc.approve(address(uniswapIntegration), usdcAmount);
        dai.approve(address(uniswapIntegration), daiAmount);

        console.log("Adding liquidity with:");
        console.log("USDC:", usdcAmount);
        console.log("DAI:", daiAmount);

        try uniswapIntegration.addLiquidity(USDC, DAI, usdcAmount, daiAmount, slippagePercent) {
            console.log("Liquidity added successfully!");
        } catch Error(string memory reason) {
            console.log("Failed to add liquidity:", reason);
        }

        try uniswapIntegration.addLiquidityEth(USDC, usdcAmount, amountTokenMin, amountETHMin, slippagePercent) {
            console.log("Liquidity added successfully!");
        } catch Error(string memory reason) {
            console.log("Failed to add liquidity:", reason);
        }

        address pair = IUniswapV2Factory(IUniswapV2Router02(ROUTER_ADDRESS).factory()).getPair(USDC, DAI);
        console.log("Pairs found", pair);
        IERC20 pairToken = IERC20(pair);
        uint256 liquidity = pairToken.balanceOf(address(this));

        try uniswapIntegration.removeLiquidity(
            USDC,
            DAI,
            liquidity,
            usdcAmount * 95 / 100, // 5% slippage
            daiAmount * 95 / 100, // 5% slippage
            50 // slippage percent
        ) {
            console.log("Liquidity removed successfully!");
        } catch Error(string memory reason) {
            console.log("Failed to remove liquidity:", reason);
        }

        vm.stopBroadcast();
    }
}
