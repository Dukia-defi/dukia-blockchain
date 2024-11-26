// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/uniswap/UniswapLisk.sol";

contract AddLiquidityLiskScript is Script {
    // Addresses for deployment

    uint32 _toChainId = 11155111;
    uint256 usdcAmount = 2 * 10 ** 6;
    uint256 daiAmount = 2 * 10 ** 18;
    uint256 slippagePercent = 5;

    function run() external {
        vm.startBroadcast();

        UniswapTest uniswapTest = new UniswapTest();
        console.log("UniswapTest deployed at:", address(uniswapTest));

        // Call the `addLiquidityCrossChain` function
        uniswapTest.addLiquidity(_toChainId, usdcAmount, daiAmount, slippagePercent);

        console.log("Liquidity request sent successfully");

        vm.stopBroadcast();
    }
}
